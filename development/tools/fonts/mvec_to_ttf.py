#!/usr/bin/env python3
"""
mvec_to_ttf.py — Convert Playground SDK .mvec back to a basic TrueType TTF.

Features:
- Parses MVEC header, glyph table, and vector commands (START/MOVETO/LINETO/CURVETO/STOP)
- Builds a quadratic 'glyf' font using fontTools.FontBuilder
- Half-away-from-zero decode for 9.7 fixed (inverse of the writer’s rounding)
- Optional Y flip and XY scaling to map MVEC's internal "em-like" units to chosen UPM
- Uses MVEC advance widths; LSB derived from minX

Usage:
  python mvec_to_ttf.py Input.mvec Output.ttf [options]

Options:
  --upm N          Units per em for the TTF (default 1000)
  --flip-y         Flip Y back to TrueType (+up), default off
  --div-scale S    Divide all MVEC coords by S before mapping to UPM (default 1.0)
  --family NAME    Name table family name (default 'MVEC Font')
  --style NAME     Subfamily/style (default 'Regular')
"""

import argparse, struct, math
from typing import Dict, List, Tuple

from fontTools.fontBuilder import FontBuilder
from fontTools.ttLib import newTable
from fontTools.pens.ttGlyphPen import TTGlyphPen

# ---------- MVEC parsing ----------

def read_value_9_7(data: bytes) -> float:
    s = struct.unpack('<h', data)[0]
    return s / 128.0

def parse_mvec(path: str) -> Tuple[Dict[int, Dict], List[int]]:
    """Return (glyphs, codepoint order). Each glyph: {'bbox':(minx,maxx,miny,maxy), 'adv': float, 'prog': list of ops}"""
    with open(path, 'rb') as f:
        if f.read(4) != b'MVC4':
            raise ValueError('Bad MVEC header')
        count = struct.unpack('<H', f.read(2))[0]
        _ = f.read(6)
        table = []
        for _i in range(count):
            uni = struct.unpack('<I', f.read(4))[0]
            minx = read_value_9_7(f.read(2))
            maxx = read_value_9_7(f.read(2))
            miny = read_value_9_7(f.read(2))
            maxy = read_value_9_7(f.read(2))
            adv  = read_value_9_7(f.read(2))
            off  = struct.unpack('<I', f.read(4))[0]
            table.append((uni, minx, maxx, miny, maxy, adv, off))
        glyphs: Dict[int, Dict] = {}
        for (uni, minx, maxx, miny, maxy, adv, off) in table:
            f.seek(off)
            prog = []
            while True:
                b = f.read(1)
                if not b:
                    break
                op = b[0]
                if op == 0x02:     # START (2 bytes total; we've read first)
                    _ = f.read(1)  # 0x01
                    prog.append(("START",))
                elif op == 0x04:   # MOVETO
                    x = read_value_9_7(f.read(2))
                    y = read_value_9_7(f.read(2))
                    prog.append(("M", x, y))
                elif op == 0x05:   # LINETO
                    x = read_value_9_7(f.read(2))
                    y = read_value_9_7(f.read(2))
                    prog.append(("L", x, y))
                elif op == 0x06:   # CURVETO (quadratic)
                    cx = read_value_9_7(f.read(2)); cy = read_value_9_7(f.read(2))
                    x  = read_value_9_7(f.read(2)); y  = read_value_9_7(f.read(2))
                    prog.append(("Q", cx, cy, x, y))
                elif op == 0x08:   # STOP
                    prog.append(("STOP",))
                    break
                else:
                    # Unknown opcode: break to avoid runaway
                    break
            glyphs[uni] = {"bbox": (minx, maxx, miny, maxy), "adv": adv, "prog": prog}
    return glyphs, [x[0] for x in table]


# ---------- Build TTF ----------

def build_ttf(glyphs: Dict[int, Dict], order: List[int], upm: int, flip_y: bool, div_scale: float,
              family: str, style: str, out_path: str):
    fb = FontBuilder(upm)
    # Name & cmap
    glyphOrder = [".notdef"]
    cmap = {}
    for cp in order:
        name = f"uni{cp:04X}"
        glyphOrder.append(name)
        cmap[cp] = name

    fb.setupGlyphOrder(glyphOrder)
    fb.setupCharacterMap(cmap)

    # Glyf outlines
    glyf = {}
    hmtx = {}
    for cp in order:
        name = cmap[cp]
        rec = glyphs[cp]
        pen = TTGlyphPen(None)
        for op in rec["prog"]:
            if op[0] == "M":
                x = op[1] / div_scale
                y = op[2] / div_scale
                if flip_y: y = -y
                pen.moveTo((int(round(x*upm)), int(round(y*upm))))
            elif op[0] == "L":
                x = op[1] / div_scale
                y = op[2] / div_scale
                if flip_y: y = -y
                pen.lineTo((int(round(x*upm)), int(round(y*upm))))
            elif op[0] == "Q":
                cx = op[1] / div_scale; cy = op[2] / div_scale
                x  = op[3] / div_scale; y  = op[4] / div_scale
                if flip_y:
                    cy = -cy; y = -y
                pen.qCurveTo((int(round(cx*upm)), int(round(cy*upm))),
                             (int(round(x*upm)),  int(round(y*upm))))
            elif op[0] == "STOP":
                pen.endPath()
        g = pen.glyph()
        glyf[name] = g

        adv = rec["adv"] / div_scale
        aw  = int(round(adv * upm))
        # LSB: use minx * upm (after scaling & flip at write time)
        minx = rec["bbox"][0] / div_scale
        lsb  = int(round(minx * upm))
        hmtx[name] = (aw, lsb)

    fb.setupGlyf(glyf)
    fb.setupHorizontalMetrics(hmtx)
    fb.setupHorizontalHeader(ascent=int(0.8*upm), descent=int(-0.2*upm))
    fb.setupOS2()
    fb.setupPost()
    fb.setupNameTable({1: family, 2: style, 4: f"{family} {style}", 6: f"{family.replace(' ','')}-{style}"})
    fb.save(out_path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mvec", help="Input MVEC file")
    ap.add_argument("out", help="Output TTF path")
    ap.add_argument("--upm", type=int, default=1000, help="Units per em in the new TTF (default 1000)")
    ap.add_argument("--flip-y", action="store_true", help="Flip Y back to TrueType up")
    ap.add_argument("--div-scale", type=float, default=1.0, help="Divide MVEC coords by this before mapping to UPM")
    ap.add_argument("--family", type=str, default="MVEC Font", help="Name table family")
    ap.add_argument("--style",  type=str, default="Regular", help="Name table subfamily")
    args = ap.parse_args()

    glyphs, order = parse_mvec(args.mvec)
    build_ttf(glyphs, order, upm=args.upm, flip_y=args.flip_y, div_scale=args.div_scale,
              family=args.family, style=args.style, out_path=args.out)
    print(f"Wrote {len(order)} glyphs to {args.out}")

if __name__ == "__main__":
    main()
