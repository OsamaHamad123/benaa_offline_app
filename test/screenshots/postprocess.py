#!/usr/bin/env python3
"""Optimise the rendered screenshots and build docs/screenshots/overview.png.

Run after the screenshot test (needs Pillow: pip install pillow):
    python3 test/screenshots/postprocess.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parents[2] / "docs" / "screenshots"
OVERVIEW = ["01_dashboard", "02_dashboard_insights", "03_beneficiaries", "05_activity_log"]
MAX_BYTES = 400 * 1024
SHOT_HEIGHT = 960
GAP = 40
BACKGROUND = (241, 245, 251)
RADIUS = 36


def optimise(path: Path) -> None:
    img = Image.open(path).convert("RGB")
    img.save(path, optimize=True)
    if path.stat().st_size > MAX_BYTES:
        w, h = img.size
        img = img.resize((780, round(h * 780 / w)), Image.LANCZOS)
        img.save(path, optimize=True)


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *img.size), radius, fill=255)
    out = Image.new("RGBA", img.size)
    out.paste(img, (0, 0), mask)
    return out


def overview() -> None:
    shots = []
    for name in OVERVIEW:
        img = Image.open(OUT / f"{name}.png").convert("RGB")
        w, h = img.size
        img = img.resize((round(w * SHOT_HEIGHT / h), SHOT_HEIGHT), Image.LANCZOS)
        shots.append(rounded(img, RADIUS))
    width = sum(s.width for s in shots) + GAP * (len(shots) + 1)
    assert width <= 2000, width
    canvas = Image.new("RGBA", (width, SHOT_HEIGHT + 2 * GAP), BACKGROUND + (255,))
    draw = ImageDraw.Draw(canvas)
    x = GAP
    for s in shots:
        # thin outline so white app bars don't dissolve into the background
        draw.rounded_rectangle(
            (x - 2, GAP - 2, x + s.width + 1, GAP + s.height + 1),
            RADIUS + 2, fill=(214, 222, 235))
        canvas.alpha_composite(s, (x, GAP))
        x += s.width + GAP
    canvas.convert("RGB").save(OUT / "overview.png", optimize=True)


if __name__ == "__main__":
    for png in sorted(OUT.glob("0*.png")):
        optimise(png)
    overview()
    for png in sorted(OUT.glob("*.png")):
        print(f"{png.name}: {Image.open(png).size} {png.stat().st_size // 1024} KB")
