========================================================================
MVEC FONT TOOLS
Version 1.0
Created by: Michael Lane
========================================================================

INTRODUCTION
------------
These Python scripts allow you to convert fonts between standard 
TrueType/OpenType formats (.ttf/.otf) and the Playground SDK's 
proprietary vector font format (.mvec).

MVEC is the format used by "Chocolatier: Decadence by Design". Because 
MVEC stores glyphs as raw vector commands (MOVETO, LINETO, CURVETO) 
rather than standard outlines, precise conversion is required to 
maintain correct spacing, alignment, and rendering quality.

REQUIREMENTS
------------
1. Python 3.x installed on your system.
2. The `fonttools` library.
   Install via pip: pip install fonttools

------------------------------------------------------------------------
TECHNICAL OVERVIEW
------------------------------------------------------------------------
The MVEC format utilizes:
- Quadratic Bézier curves (3 control points per curve).
- 9.7 fixed-point values (9 integer bits, 7 fractional bits).
- Per-glyph advance widths (No kerning tables supported).
- Line height scaling derived from specific reference glyphs (usually 
  "W" for ascenders and "y" for descenders).

These tools include calibration features to match the exact spacing 
of legacy PlayFirst fonts while allowing you to add new glyphs for 
localization.

------------------------------------------------------------------------
SCRIPT 1: ttf_to_mvec.py (THE CONVERTER)
------------------------------------------------------------------------
Converts a standard font file into an MVEC file for the game.

KEY ARGUMENTS:
  --flip-y
    Required. Flips glyphs vertically (MVEC's Y-axis is inverted 
    compared to standard TTF).

  --scale-xy [VALUE]
    Uniform scale factor to match MVEC's coordinate system. 
    (Recommended for Fertigo: 233.264706)

  --calibrate-from [FILE.mvec]
    Copies advance widths from an existing MVEC file. Use this to 
    ensure your new font matches the spacing of the original game font.

  --align-lsb-from [FILE.mvec]
    Aligns Left Side Bearings (minX) with a legacy file. Critical for 
    punctuation alignment.

  --override-adv [FILE.txt]
    Applies per-glyph spacing overrides. See "Override Files" below.

  --ranges [ascii,latin1,latina,all]
    Selects which Unicode ranges to export.
    - ascii:  U+0020 to U+007E
    - latin1: U+00A0 to U+00FF
    - latina: U+0100 to U+017F
    - all:    Everything available in the font

  --no-close
    Prevents force-closing contours. Keeps outlines faithful to source.

------------------------------------------------------------------------
SCRIPT 2: mvec_to_ttf.py (THE DEBUGGER)
------------------------------------------------------------------------
Converts an .mvec file back into a .ttf file.
Use this for inspection, debugging, or validating round-trip conversion.

Usage:
  python mvec_to_ttf.py Input.mvec Output.ttf [options]

------------------------------------------------------------------------
USAGE EXAMPLES
------------------------------------------------------------------------

1. FULL CONVERSION WITH CALIBRATION (Recommended)
   This creates a new font that matches the original game's spacing 
   but includes new characters (e.g. for localization).

   python ttf_to_mvec.py fertigo.ttf fertigo.mvec \
     --flip-y --no-close --scale-xy 233.264706 \
     --calibrate-from fertigo-old.mvec \
     --align-lsb-from fertigo-old.mvec \
     --ranges all --verbose

2. QUICK ASCII TEST
   Fast export for testing basic English text.

   python ttf_to_mvec.py fertigo.ttf fertigo-ascii.mvec \
     --flip-y --scale-xy 233.264706 \
     --ranges ascii --verbose

3. APPLYING MANUAL OVERRIDES
   For fine-tuning specific problem characters.

   python ttf_to_mvec.py fertigo.ttf fertigo.mvec \
     --flip-y --scale-xy 233.264706 \
     --calibrate-from fertigo-old.mvec \
     --override-adv adv_overrides.txt \
     --ranges all

------------------------------------------------------------------------
OVERRIDE FILES
------------------------------------------------------------------------
You can create a text file (e.g., adv_overrides.txt) to manually tweak 
spacing for specific characters.

FORMAT:
  [Character/Code] [Operation]

EXAMPLES:
  'p' +0.010em      (Add extra breathing room to letter 'p')
  'd' +0.008em      (Add extra breathing room to letter 'd')
  U+0027 0.132      (Set absolute advance of apostrophe to 0.132)
  U+0031 *1.02      (Multiply digit '1' width by 1.02)

OPERATIONS:
  0.500     -> Set absolute advance (MVEC units)
  0.49em    -> Set advance as fraction of em (auto-scaled)
  +0.01em   -> Add to current advance
  -0.01     -> Subtract from current advance
  *1.02     -> Multiply current advance

------------------------------------------------------------------------
TROUBLESHOOTING
------------------------------------------------------------------------
- Output file is too small (~8KB)?
  Usually caused by --no-close on older builds. Ensure you are using 
  the latest version of the script included in this package.

- Text not rendering in-game?
  Verify the file header (MVC4) is present. Ensure you exported at 
  least the ASCII range.

- Spacing feels "off" compared to vanilla?
  Use --align-lsb-from to lock the left-side bearings to the original 
  font file.

- Glyph shape differences?
  If using a modern version of a font (e.g., Fertigo Pro vs Fertigo), 
  shapes may differ. Use overrides to fix spacing issues caused by 
  wider glyphs.

------------------------------------------------------------------------
LICENSE
------------------------------------------------------------------------
These Python scripts (`ttf_to_mvec.py` and `mvec_to_ttf.py`) are 
original works created for this mod.

They are licensed under the MIT License. You are free to use, modify, 
and distribute these scripts in your own projects.