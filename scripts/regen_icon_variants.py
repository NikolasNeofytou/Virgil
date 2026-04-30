#!/usr/bin/env python3
"""regen_icon_variants.py — derive Coral and Ochre app-icon variants.

The base Aegean V icon (`app/assets/icon/icon.png`) is a flat
two-colour composite — Aegean ground (#1F2A5C) + Linen V (#F6EFE6).
This script swaps the ground colour to produce the Coral and Ochre
variants the deck calls for, keeping the V untouched. Re-run whenever
`icon.png` changes; both variants are deterministic from the source.

iOS alternate-icon files at 120×120 and 180×180 are also generated
under `app/ios/Runner/AppIcon-{Variant}@{Nx}.png` so the iOS bundle
sees them at the standard locations referenced by Info.plist.

Usage:  python3 scripts/regen_icon_variants.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parents[1]
SRC  = REPO / "app" / "assets" / "icon" / "icon.png"
ASSETS_DIR = REPO / "app" / "assets" / "icon"
IOS_XCASSETS = REPO / "app" / "ios" / "Runner" / "Assets.xcassets"

# Palette — must match `app/lib/theme/app_theme.dart`.
AEGEAN = (0x1F, 0x2A, 0x5C)
CORAL  = (0xD9, 0x57, 0x3F)
OCHRE  = (0xC3, 0x94, 0x48)

# Tolerance for the colour match. The base icon is rendered with anti-
# aliased edges between the V and the ground, so a tight match would
# leave a halo of un-swapped pixels at the boundary. 32 is enough to
# absorb the AA without bleeding into the V (which is far from Aegean
# in colour space).
TOL = 32

# iOS alternate-icon sizes — only the iPhone Home Screen icon family.
# iPad alternates fall back to the primary icon (acceptable per spec).
IOS_SIZES = [("@2x", 120), ("@3x", 180)]


def swap_ground(src: Image.Image, target: tuple[int, int, int]) -> Image.Image:
    """Replace any pixel within TOL of AEGEAN with `target`. Other
    pixels (the cream V) pass through unchanged."""
    rgb = src.convert("RGB")
    px = rgb.load()
    w, h = rgb.size
    ar, ag, ab = AEGEAN
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            if abs(r - ar) <= TOL and abs(g - ag) <= TOL and abs(b - ab) <= TOL:
                px[x, y] = target
    return rgb


def main() -> None:
    src = Image.open(SRC)
    print(f"source:  {SRC.relative_to(REPO)}  ({src.size[0]}×{src.size[1]})")

    for name, target in (("coral", CORAL), ("ochre", OCHRE)):
        variant = swap_ground(src, target)

        # 1024×1024 master, alongside icon.png — kept for parity with the
        # base Aegean source, also used as the Profile picker thumbnail.
        master = ASSETS_DIR / f"icon_{name}.png"
        variant.save(master, format="PNG")
        print(f"  wrote {master.relative_to(REPO)}")

        # iOS Asset-Catalog appiconset — referenced from Info.plist's
        # CFBundleAlternateIcons. The Contents.json is hand-authored
        # alongside this script and unchanged by re-runs.
        cap = name.capitalize()
        appiconset = IOS_XCASSETS / f"AppIcon-{cap}.appiconset"
        appiconset.mkdir(parents=True, exist_ok=True)
        for suffix, side in IOS_SIZES:
            sized = variant.resize((side, side), Image.LANCZOS)
            ios_path = appiconset / f"Icon-{cap}-60x60{suffix}.png"
            sized.save(ios_path, format="PNG")
            print(f"  wrote {ios_path.relative_to(REPO)}  ({side}×{side})")


if __name__ == "__main__":
    main()
