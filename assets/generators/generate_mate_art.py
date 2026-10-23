"""Generate owned mate props and inventory sprites using the established prop renderer."""
import hashlib
import json
import math
from pathlib import Path
import random
from PIL import Image, ImageDraw
from generate_alchemy_ingredients import Mesh, shade_faces, icon, DATA as SHADING

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE / "mate_vessels.json").read_text(encoding="utf-8"))
DIRECTORY = "models/caelum/world/mate"
OUT = ROOT / "src" / DIRECTORY
ICONS = ROOT / "src/graphics/caelum/icons/mate"
PALETTE = {"gourd": (145, 99, 51), "wood": (84, 49, 29), "bronze": (161, 119, 56),
           "silver": (174, 177, 172), "gold": (183, 143, 62)}

def texture(key):
    return f"{DIRECTORY}/{key}.png"

def textures():
    for index, (key, color) in enumerate(PALETTE.items()):
        rng = random.Random(472000 + index)
        image = Image.new("RGB", (64, 64))
        pixels = []
        for y in range(64):
            for x in range(64):
                noise = rng.randrange(-5, 6) + (5 * math.sin(x * .5 + y * .04) if key in ("wood", "gourd") else 0)
                pixels.append(tuple(max(0, min(255, round(c + noise))) for c in color))
        image.putdata(pixels)
        image.save(OUT / f"{key}.png")
        for shade, factor in enumerate(SHADING["baked_shades"]):
            image.point([min(255, round(c * factor)) for c in range(256)] * 3).save(OUT / f"{key}_shade{shade}.png")

def bowl(mesh, outer, inner, kind):
    first = len(mesh.faces)
    segments, rings = 20, 7
    for radius, inward in ((outer, False), (inner, True)):
        for ring in range(rings):
            a, b = ring / rings * math.pi / 2, (ring + 1) / rings * math.pi / 2
            for sector in range(segments):
                u, v = sector / segments * 2 * math.pi, (sector + 1) / segments * 2 * math.pi
                points = [(radius * math.sin(t) * math.cos(p), outer - radius * math.cos(t), radius * math.sin(t) * math.sin(p)) for t, p in ((a, u), (b, u), (b, v), (a, v))]
                mesh.add_quad(texture("wood" if inward and kind != "gourd" else kind), list(reversed(points)) if inward else points)
    for sector in range(segments):
        u, v = sector / segments * 2 * math.pi, (sector + 1) / segments * 2 * math.pi
        mesh.add_quad(texture(kind), [(radius * math.cos(angle), outer, radius * math.sin(angle)) for radius, angle in ((inner, u), (outer, u), (outer, v), (inner, v))])
    shade_faces(mesh, first, (0, outer, 0))
    # Open bowls need a soft height gradient on the underside as well: a single
    # overhead key light leaves an entire rear hemisphere uniformly dark.
    for face in range(first, len(mesh.faces)):
        material, indices = mesh.faces[face]
        height = sum(mesh.vertices[index - 1][1] for index in indices) / len(indices)
        current = int(material.rsplit("_shade", 1)[1].split(".")[0])
        brightness = .5 + .35 * min(1, height / outer) + .15 * (SHADING["baked_shades"][current] - .55)
        shade = min(range(len(SHADING["baked_shades"])), key=lambda index: abs(SHADING["baked_shades"][index] - brightness))
        mesh.faces[face] = (material.rsplit("_shade", 1)[0] + f"_shade{shade}.png", indices)

def rod(mesh, kind, start, end, radius, tip=None):
    first = len(mesh.faces)
    mesh.add_frustum(texture(kind), start, end, radius, radius if tip is None else tip, 12)
    shade_faces(mesh, first, tuple((start[i] + end[i]) / 2 for i in range(3)))

def make(row, straw=True):
    mesh = Mesh("ca_mate_" + row["key"])
    radius = (3 * row["capacity_liters"] / 1000 / (2 * math.pi)) ** (1 / 3) * 32
    outer = radius + (row["wall_meters"] + row["coating_meters"]) * 32
    bowl(mesh, outer, radius, row["key"])
    if straw:
        rod(mesh, "bronze", (-radius * .45, .45, 0), (-radius * .35, 4.3, 0), .10)
        rod(mesh, "bronze", (-radius * .35, 4.3, 0), (-radius * .8, 5.2, 0), .10, .09)
        rod(mesh, "bronze", (-radius * .45, .4, 0), (-radius * .45, .8, 0), .26, .15)
        rod(mesh, "bronze", (-radius * .8, 5.15, 0), (-radius * .83, 5.28, 0), .13, .10)
    mesh.faces.sort(key=lambda face: face[0])
    assert len({face[0] for face in mesh.faces}) <= 32
    return mesh

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    OUT.mkdir(parents=True, exist_ok=True); ICONS.mkdir(parents=True, exist_ok=True)
    textures(); records = []; bindings = []; sprites = []
    rows = DATA["vessels"] + [{**DATA["vessels"][0], "key": "dry_gourd"}]
    for i, row in enumerate(rows):
        mesh = make(DATA["vessels"][0] if i == 3 else row, i < 3)
        key = row["key"]; model = OUT / f"{key}.obj"; sprite = ICONS / f"{key}.png"
        mesh.write(model); icon(mesh, sprite)
        name = "CaelumMaterialPickup" if i == 3 else "CaelumMate" + key.title()
        frame = "M104" if i == 3 else f"CMA{i}"
        bindings += [f'Model {name} {{ Path "{DIRECTORY}" Model 0 "{key}.obj" Scale 4 4 4 FrameIndex {frame} A 0 0 }}']
        sprites += [f'Sprite {frame}A0, 128, 128 {{ Offset 64, 120 Patch "graphics/caelum/icons/mate/{key}.png", 0, 0 }}']
        records.append({"key": key, "model": model.relative_to(ROOT).as_posix(), "icon": sprite.relative_to(ROOT).as_posix(), "model_sha256": digest(model), "icon_sha256": digest(sprite), "surfaces": len({f[0] for f in mesh.faces})})
    for ext, lines in (("modeldef", bindings), ("textures", sprites)):
        (ROOT / f"src/caelum/data/mate.{ext}").write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    manifest = {"issue": 472, "provenance": "Original project-owned procedural meshes/textures; existing owned depth-tested renderer. No external or Doom art.", "inputs": {p.relative_to(ROOT).as_posix(): digest(p) for p in (Path(__file__), HERE / "mate_vessels.json", HERE / "generate_alchemy_ingredients.py", HERE / "generate_environment_models.py")}, "assets": records}
    (HERE / "mate_art_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8", newline="\n")
    sheet = Image.new("RGB", (720, 164), (36, 33, 30)); draw = ImageDraw.Draw(sheet)
    for i, record in enumerate(records):
        sprite = Image.open(ROOT / record["icon"]); sheet.paste(sprite, (i * 180 + 26, 4), sprite)
        draw.text((i * 180 + 8, 140), record["key"], fill=(227, 216, 190))
    review = ROOT / "assets/validation_5714"; review.mkdir(exist_ok=True)
    sheet.save(review / "mate-contact-sheet.png")
    print("Generated three mate models/icons with fixed bronze straws and dry-gourd material")

if __name__ == "__main__":
    main()
