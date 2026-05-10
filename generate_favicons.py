"""
Generate favicon files from the transparent logo PNG.
Detects the gap between mountain emblem and text, crops just the emblem,
pads to square (with transparency), then exports multi-size favicons.
"""
from PIL import Image
from pathlib import Path

SRC = Path("assets/logo_house_of_anatolia_transparent.png")
OUT_DIR = Path(".")

img = Image.open(SRC).convert("RGBA")
w, h = img.size
print(f"Source: {w}x{h}")

alpha = img.split()[3]

row_density = []
for y in range(h):
    row = alpha.crop((0, y, w, y + 1))
    pixels = list(row.getdata())
    count = sum(1 for p in pixels if p > 30)
    row_density.append(count)

bbox = img.getbbox()
if bbox is None:
    raise SystemExit("Image is fully transparent.")
left, top, right, bottom = bbox
print(f"Content bbox: left={left}, top={top}, right={right}, bottom={bottom}")

content_rows = [(y, c) for y, c in enumerate(row_density) if c > 3]
gaps = []
prev_y = None
for y, _ in content_rows:
    if prev_y is not None and y - prev_y > 1:
        gaps.append((prev_y + 1, y - 1, y - prev_y - 1))
    prev_y = y

interior_gaps = [g for g in gaps if top < g[0] < bottom and top < g[1] < bottom]
print(f"Interior gaps found: {len(interior_gaps)}")
for g in interior_gaps:
    print(f"  rows {g[0]}-{g[1]} (height {g[2]})")

if interior_gaps:
    biggest_gap = max(interior_gaps, key=lambda g: g[2])
    split_y = biggest_gap[0]
    print(f"Splitting at y={split_y} (gap height {biggest_gap[2]})")
else:
    split_y = top + (bottom - top) // 2
    print(f"No gap found, splitting at midpoint y={split_y}")

mountain_alpha_crop = (left, top, right, split_y)
mountain = img.crop(mountain_alpha_crop)
m_bbox = mountain.getbbox()
if m_bbox:
    mountain = mountain.crop(m_bbox)
mw, mh = mountain.size
print(f"Mountain crop: {mw}x{mh}")

padding = max(mw, mh) // 10
size = max(mw, mh) + 2 * padding
square = Image.new("RGBA", (size, size), (0, 0, 0, 0))
paste_x = (size - mw) // 2
paste_y = (size - mh) // 2
square.paste(mountain, (paste_x, paste_y), mountain)
print(f"Square canvas: {size}x{size}")

square.resize((32, 32), Image.LANCZOS).save(OUT_DIR / "favicon-32x32.png", optimize=True)
square.resize((192, 192), Image.LANCZOS).save(OUT_DIR / "favicon-192x192.png", optimize=True)
square.resize((180, 180), Image.LANCZOS).save(OUT_DIR / "apple-touch-icon.png", optimize=True)

ico_sizes = [(16, 16), (32, 32), (48, 48)]
square.save(OUT_DIR / "favicon.ico", sizes=ico_sizes)

print("\nGenerated:")
for f in ["favicon.ico", "favicon-32x32.png", "favicon-192x192.png", "apple-touch-icon.png"]:
    p = OUT_DIR / f
    print(f"  {f}: {p.stat().st_size} bytes")
