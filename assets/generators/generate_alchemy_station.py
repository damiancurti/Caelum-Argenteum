"""Build the approved #470 station and icon deterministically."""
from pathlib import Path
import hashlib
import json
import math
from PIL import Image, ImageDraw
from generate_station_models import Mesh, MATERIALS

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE / 'alchemy_station.json').read_text(encoding='utf-8'))


def geometry():
    mesh = Mesh('CaelumAlchemyStation')
    mesh.table()
    # A closed fermentation cask and a still share the existing station table.
    mesh.rod('wood', (-9, 26.5, 0), (-9, 38.5, 0), 5.5, sides=12)
    for height in (28, 36.5):
        mesh.ring('iron', (-9, height, 0), 5.55, .4, plane='xz', segments=12)
    mesh.rod('wood', (-9, 38.5, 0), (-9, 39.5, 0), 1.0)
    mesh.rod('brass', (-9, 29, 4.5), (-9, 29, 7), .65)
    mesh.rod('brass', (-10.5, 30, 6), (-7.5, 30, 6), .3)
    for x in (3, 9):
        mesh.rod('iron', (x, 26.5, -3), (x, 29, -3), .6)
        mesh.rod('iron', (x, 26.5, 3), (x, 29, 3), .6)
    mesh.ball('brass', (6, 33, 0), (5.5, 5.5, 5.5), rings=6, segments=12)
    mesh.ring('iron', (6, 32, 0), 5.45, .35, plane='xz', segments=12)
    mesh.rod('brass', (6, 37, 0), (6, 41, 0), 3.8, .9, sides=12)
    mesh.rod('brass', (6, 41, 0), (6, 44, 0), .9)
    mesh.ball('brass', (6, 44, 0), (2.7, 2.3, 2.7), rings=4, segments=12)
    mesh.rod('brass', (6, 46.3, 0), (6, 48, 0), .45)
    mesh.rod('brass', (7.5, 44, 0), (14, 42, 2), .6)
    mesh.rod('brass', (14, 42, 2), (14, 33, 2), .6)
    mesh.ball('brass', (14, 29, 2), (2.1, 2.5, 2.1), rings=4, segments=10)
    mesh.rod('brass', (14, 31, 2), (14, 33, 2), .9)
    return mesh


def icon(mesh, target):
    # Orthographic rendering of the same owned mesh; no separate sprite design.
    canvas = Image.new('RGBA', (384, 384))
    draw = ImageDraw.Draw(canvas)
    azimuth = math.radians(24)
    def project(v):
        x, y, z = v
        horizontal = x * math.cos(azimuth) + z * math.sin(azimuth)
        depth = z * math.cos(azimuth) - x * math.sin(azimuth)
        return (192 + horizontal * 7, 355 - y * 6.5 + depth * 2.3), depth + y * .35
    polygons = []
    for material, indices in mesh.faces:
        vertices = [mesh.vertices[i-1] for i in indices]
        projected = [project(v) for v in vertices]
        a, b, c = vertices[:3]
        ab = [b[i]-a[i] for i in range(3)]
        ac = [c[i]-a[i] for i in range(3)]
        normal = (ab[1]*ac[2]-ab[2]*ac[1], ab[2]*ac[0]-ab[0]*ac[2], ab[0]*ac[1]-ab[1]*ac[0])
        length = math.sqrt(sum(v*v for v in normal)) or 1
        shade = .65 + .35 * abs((normal[0]*-.4+normal[1]*.8+normal[2]*.45)/length)
        kind = Path(material).stem.removeprefix('ca_station_')
        color = tuple(round(channel*shade) for channel in MATERIALS[kind]) + (255,)
        polygons.append((sum(p[1] for p in projected)/len(projected), [p[0] for p in projected], color))
    for _, points, color in sorted(polygons, key=lambda p: p[0]):
        draw.polygon(points, fill=color)
    canvas.resize((128,128), Image.Resampling.LANCZOS).save(target)


def main():
    mesh = geometry()
    model = ROOT / 'src/models/caelum/props/stations/ca_station_alchemy.obj'
    mesh.write(model)
    sprite = ROOT / 'src/sprites/CALCA0.png'
    icon(mesh, sprite)
    bounds = [[round(min(v[i] for v in mesh.vertices), 4), round(max(v[i] for v in mesh.vertices), 4)] for i in range(3)]
    manifest = {'issue': 470, 'provenance': DATA['provenance'], 'vertices': len(mesh.vertices),
                'faces': len(mesh.faces), 'model_bounds_xyz_y_up': bounds,
                'actor_model_scale': 1.5, 'outputs': {str(p.relative_to(ROOT)).replace('\\','/'): hashlib.sha256(p.read_bytes()).hexdigest() for p in (model,sprite)}}
    (HERE / 'alchemy_station_manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8', newline='\n')
    print(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
