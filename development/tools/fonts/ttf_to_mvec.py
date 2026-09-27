
#!/usr/bin/env python3
"""
ttf_to_mvec.overrides.py — TTF/OTF -> MVEC with advance + LSB calibration and per-glyph overrides

New:
  --override-adv FILE    Per-glyph advance overrides (set/add/scale), supports 'em' units.

Also supports:
  --calibrate-from P     Copy advances from legacy MVEC for overlapping codepoints
  --align-lsb-from P     Shift outlines so minX matches legacy MVEC (LSB parity)
  --scale-xy S           Scale coords & advances (keeps em logic intact)
  --no-close             Don't add explicit close segment
  --ranges/--include-file  Character selection

Override file format (one per line; comments '# ...' allowed):
  U+0070 0.500        # set ABS advance to 0.500 *in MVEC units*
  U+0064 0.49em       # set ABS advance to 0.49 em (converted by --scale-xy)
  'p' +0.01em         # ADD 0.01 em to current advance (after calibration)
  U+0031 *1.02        # MULTIPLY current advance by 1.02
Codepoint may be U+XXXX, 0xXXXX, a decimal, or a single-quoted character.
"""

import argparse, math, struct, sys, re
from typing import List, Tuple, Dict, Set

from fontTools.ttLib import TTFont
from fontTools.pens.basePen import BasePen
try:
    from fontTools.pens.cu2quPen import Cu2QuPen
except Exception:
    Cu2QuPen = None

def write_value_9_7(v: float, sink):
    s = v * 128.0
    s = int((abs(s) + 0.5)) * (1 if s >= 0 else -1)
    if s < -32768: s = -32768
    if s >  32767: s =  32767
    packed = struct.pack('<h', s)
    if hasattr(sink, 'write'): sink.write(packed)
    else: sink.extend(packed)

class ContourRecordPen(BasePen):
    def __init__(self, glyphSet, upm: int, flip_y: bool, explicit_close: bool=True, scale: float=1.0):
        super().__init__(glyphSet)
        self.upm = float(upm)
        self.flip = -1.0 if flip_y else 1.0
        self.explicit_close = explicit_close
        self.scale = float(scale)
        self.contours: List[List[Tuple]] = []
        self._cur: List[Tuple] = []
        self._first = None
    def _finalize_current(self):
        if not self._cur: return
        if self.explicit_close and self._first and self._cur[-1][0] != "M":
            self._cur.append(("L", self._first))
        self.contours.append(self._cur); self._cur = []; self._first = None
    def _moveTo(self, p0):
        self._finalize_current(); x,y = p0; y *= self.flip
        p = ((x/self.upm)*self.scale, (y/self.upm)*self.scale)
        self._first = p; self._cur = [("M", p)]
    def _lineTo(self, p1):
        x,y = p1; y *= self.flip
        p = ((x/self.upm)*self.scale, (y/self.upm)*self.scale); self._cur.append(("L", p))
    def _qCurveToOne(self, p1, p2):
        (cx,cy) = p1; (x,y) = p2; cy *= self.flip; y *= self.flip
        pc = ((cx/self.upm)*self.scale, (cy/self.upm)*self.scale)
        p  = ((x /self.upm)*self.scale, (y /self.upm)*self.scale)
        self._cur.append(("Q", pc, p))
    def _closePath(self): self._finalize_current()
    def _endPath(self): self._finalize_current()

def shift_contours(contours: List[List[Tuple]], dx: float) -> List[List[Tuple]]:
    if not contours or dx == 0.0: return contours
    out = []
    for contour in contours:
        newc = []
        for seg in contour:
            if seg[0] == "M":
                x,y = seg[1]; newc.append(("M", (x+dx, y)))
            elif seg[0] == "L":
                x,y = seg[1]; newc.append(("L", (x+dx, y)))
            elif seg[0] == "Q":
                (cx,cy) = seg[1]; (x,y) = seg[2]
                newc.append(("Q", (cx+dx, cy), (x+dx, y)))
        out.append(newc)
    return out

def encode_mvec_glyph(contours: List[List[Tuple]]):
    xs, ys = [], []
    blob = bytearray()
    if contours:
        blob += b"\x02\x01"
        for contour in contours:
            for seg in contour:
                if seg[0] == "M":
                    blob += b"\x04"; (x,y) = seg[1]
                    write_value_9_7(x, blob); write_value_9_7(y, blob)
                    xs.append(x); ys.append(y)
                elif seg[0] == "L":
                    blob += b"\x05"; (x,y) = seg[1]
                    write_value_9_7(x, blob); write_value_9_7(y, blob)
                    xs.append(x); ys.append(y)
                elif seg[0] == "Q":
                    blob += b"\x06"; (cx,cy) = seg[1]; (x,y) = seg[2]
                    write_value_9_7(cx, blob); write_value_9_7(cy, blob)
                    write_value_9_7(x,  blob); write_value_9_7(y,  blob)
                    xs.extend([cx, x]); ys.extend([cy, y])
    blob += b"\x08"
    if xs and ys: minx, maxx, miny, maxy = min(xs), max(xs), min(ys), max(ys)
    else: minx = maxx = miny = maxy = 0.0
    return bytes(blob), (minx, maxx, miny, maxy)

SETS = {
    "ascii":      list(range(0x20, 0x7F)),
    "latin1":     list(range(0x00A0, 0x0100)),
    "latina":     list(range(0x0100, 0x0180)),
}

def read_include_file(path: str) -> Set[int]:
    s = set()
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"): continue
            if line.upper().startswith("U+"):
                s.add(int(line[2:], 16))
            elif all(c in "0123456789ABCDEFabcdef" for c in line) and len(line) <= 6:
                s.add(int(line, 16))
            else:
                for ch in line: s.add(ord(ch))
    return s

def charset_from_ranges(ranges: str, cmap_keys: Set[int]) -> Set[int]:
    if not ranges: return set(cmap_keys)
    s = set()
    for token in [t.strip().lower() for t in ranges.split(",") if t.strip()]:
        if token in SETS: s.update(SETS[token])
        elif token == "all": s.update(cmap_keys)
        else:
            if "-" in token:
                a,b = token.split("-",1)
                if a.upper().startswith("U+"): a = a[2:]
                if b.upper().startswith("U+"): b = b[2:]
                s.update(range(int(a,16), int(b,16)+1))
            else:
                if token.upper().startswith("U+"): token = token[2:]
                s.add(int(token,16))
    return s & set(cmap_keys)

def parse_calibrator_bbox_and_adv(path: str) -> Dict[int, Tuple[float,float,float,float,float]]:
    out = {}
    with open(path, "rb") as f:
        if f.read(4) != b"MVC4": raise ValueError("Bad MVEC header")
        count = struct.unpack("<H", f.read(2))[0]
        _ = f.read(6)
        for _ in range(count):
            uni = struct.unpack("<I", f.read(4))[0]
            minx = struct.unpack("<h", f.read(2))[0] / 128.0
            maxx = struct.unpack("<h", f.read(2))[0] / 128.0
            miny = struct.unpack("<h", f.read(2))[0] / 128.0
            maxy = struct.unpack("<h", f.read(2))[0] / 128.0
            adv  = struct.unpack("<h", f.read(2))[0] / 128.0
            _off = f.read(4)
            out[uni] = (minx,maxx,miny,maxy,adv)
    return out

def parse_codepoint(tok: str) -> int:
    tok = tok.strip()
    if tok.startswith("'") and tok.endswith("'") and len(tok) >= 3:
        return ord(tok[1])
    if tok.upper().startswith("U+"): return int(tok[2:], 16)
    if tok.lower().startswith("0x"): return int(tok, 16)
    if tok.isdigit(): return int(tok)
    if len(tok) == 1: return ord(tok)
    raise ValueError(f"Unrecognized codepoint: {tok}")

def parse_amount(tok: str, scale_xy: float):
    tok = tok.strip().lower()
    if tok.startswith(('*','x')):  # multiply
        return ('mul', float(tok[1:]))
    mode = 'set'
    if tok.startswith('+') or tok.startswith('-'):
        mode = 'add'
    num = tok.lstrip('+-')
    is_em = False
    if num.endswith('em'):
        is_em = True; num = num[:-2]
    val = float(num)
    if is_em: val *= scale_xy
    if mode == 'add' and tok.startswith('-'): val = -val
    return (mode, val)

def load_overrides(path: str, scale_xy: float) -> Dict[int, Tuple[str, float]]:
    out = {}
    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'): continue
            parts = line.split()
            if len(parts) < 2: continue
            cp = parse_codepoint(parts[0])
            mode, val = parse_amount(parts[1], scale_xy)
            out[cp] = (mode, val)
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("ttf"); ap.add_argument("out")
    ap.add_argument("--flip-y", action="store_true")
    ap.add_argument("--no-close", action="store_true")
    ap.add_argument("--scale-xy", type=float, default=1.0)
    ap.add_argument("--max-err", type=float, default=0.002)
    ap.add_argument("--ranges", type=str, default="")
    ap.add_argument("--include-file", type=str, default="")
    ap.add_argument("--calibrate-from", type=str, default="")
    ap.add_argument("--align-lsb-from", type=str, default="")
    ap.add_argument("--override-adv", type=str, default="")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()

    font = TTFont(args.ttf)
    upm = font["head"].unitsPerEm
    glyphSet = font.getGlyphSet()
    cmap = font.getBestCmap() or {}
    include = charset_from_ranges(args.ranges, set(cmap.keys()))
    if args.include_file:
        include |= read_include_file(args.include_file)
        include &= set(cmap.keys())
    include = sorted(include)

    calib_adv = {}; calib_lsb = {}
    if args.calibrate_from or args.align_lsb_from:
        try:
            table = parse_calibrator_bbox_and_adv(args.calibrate_from or args.align_lsb_from)
            if args.calibrate_from: calib_adv = {cp: v[4] for cp,v in table.items()}
            if args.align_lsb_from: calib_lsb = {cp: v[0] for cp,v in table.items()}
        except Exception as e:
            print(f"[warn] calibrator read failed: {e}", file=sys.stderr)

    overrides = {}
    if args.override_adv:
        try:
            overrides = load_overrides(args.override_adv, args.scale_xy)
        except Exception as e:
            print(f"[warn] override-adv ignored: {e}", file=sys.stderr)

    is_glyf = "glyf" in font
    records = []
    for cp in include:
        gname = cmap.get(cp)
        if not gname: continue
        pen = ContourRecordPen(glyphSet, upm=upm, flip_y=args.flip_y,
                               explicit_close=(not args.no_close), scale=args.scale_xy)
        if is_glyf:
            glyphSet[gname].draw(pen)
        else:
            if Cu2QuPen is None: raise RuntimeError("cu2quPen not available for cubic fonts")
            cu = Cu2QuPen(pen, max_err=args.max_err, reverse_direction=False)
            glyphSet[gname].draw(cu)

        contours = pen.contours
        if cp in calib_lsb:
            cur_minx = None
            for c in contours:
                for seg in c:
                    if seg[0] == "M": x = seg[1][0]
                    elif seg[0] == "L": x = seg[1][0]
                    elif seg[0] == "Q": x = min(seg[1][0], seg[2][0])
                    else: continue
                    cur_minx = x if cur_minx is None else min(cur_minx, x)
            if cur_minx is not None:
                dx = calib_lsb[cp] - cur_minx
                contours = shift_contours(contours, dx)

        blob, (minx, maxx, miny, maxy) = encode_mvec_glyph(contours)

        adv = (float(font["hmtx"][gname][0]) / float(upm)) * args.scale_xy
        if cp in calib_adv: adv = calib_adv[cp]
        if cp in overrides:
            mode, val = overrides[cp]
            if mode == 'set': adv = val
            elif mode == 'add': adv += val
            elif mode == 'mul': adv *= val

        records.append((cp, minx, maxx, miny, maxy, adv, blob))

    with open(args.out, "wb") as w:
        w.write(b"MVC4")
        w.write(struct.pack("<H", len(records)))
        w.write(b"\x00"*6)
        table_pos = w.tell()
        for _ in records: w.write(b"\x00"*18)
        offsets = []
        for (_,_,_,_,_,_, blob) in records:
            offsets.append(w.tell()); w.write(blob)
        w.seek(table_pos)
        for (uni, minx, maxx, miny, maxy, adv, _), off in zip(records, offsets):
            w.write(struct.pack("<I", uni))
            write_value_9_7(minx, w); write_value_9_7(maxx, w)
            write_value_9_7(miny, w); write_value_9_7(maxy, w)
            write_value_9_7(adv,  w)
            w.write(struct.pack("<I", off))

    if args.verbose:
        total_blob = sum(len(b) for *_, b in records)
        print(f"Wrote {len(records)} glyphs to {args.out}  (table={18*len(records)} bytes, blobs={total_blob} bytes)")

if __name__ == "__main__":
    main()
