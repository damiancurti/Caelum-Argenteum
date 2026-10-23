"""Build #471 art only: original meshes, textures and matching depth-tested icons."""
from pathlib import Path
import hashlib
import json
import math
import random
from PIL import Image, ImageDraw
from generate_environment_models import Mesh
from generate_marine_models import iodine

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE / 'alchemy_ingredients.json').read_text(encoding='utf-8'))
DIRECTORY = 'models/caelum/world/alchemy_ingredients'
OUT = ROOT / 'src' / DIRECTORY
ICONS = ROOT / 'src/graphics/caelum/icons/materials'


def material(key):
    return f'{DIRECTORY}/{key}.png'


def textures():
    for index, (key, spec) in enumerate(DATA['materials'].items()):
        rng = random.Random(471000 + index)
        pixels = []
        for y in range(64):
            for x in range(64):
                grain = rng.randint(-spec['grain'], spec['grain'])
                if spec['pattern'] == 'wood':
                    grain += round(7 * math.sin(x * .8 + math.sin(y * .16)))
                    if (x + round(2 * math.sin(y * .09))) % 13 == 0:
                        grain -= 17
                elif spec['pattern'] == 'cloth':
                    grain += (x % 2 + y % 2 - 1) * 5
                pixels.append(tuple(max(0, min(255, c + grain)) for c in spec['rgb']))
        image = Image.new('RGB', (64, 64))
        image.putdata(pixels)
        image.save(OUT / f'{key}.png')
        for level, factor in enumerate(DATA['baked_shades']):
            image.point([min(255,round(c*factor)) for c in range(256)]*3).save(OUT/f'{key}_shade{level}.png')


def shade_faces(mesh, first, center):
    # GZDoom sector lighting alone does not reveal the normal of each model face.
    # Bake a restrained fixed key light into owned material variants, not engine rules.
    light=(-.4,.8,-.6)
    length=math.sqrt(sum(v*v for v in light))
    for face in range(first,len(mesh.faces)):
        texture, indices=mesh.faces[face]
        points=[mesh.vertices[i-1] for i in indices]
        a=[points[1][i]-points[0][i] for i in range(3)]
        b=[points[2][i]-points[0][i] for i in range(3)]
        normal=(a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
        normal_length=math.sqrt(sum(v*v for v in normal)) or 1
        outward=[sum(p[i] for p in points)/len(points)-center[i] for i in range(3)]
        sign=1 if sum(normal[i]*outward[i] for i in range(3))>=0 else -1
        brightness=.55+.49*max(0,sign*sum(normal[i]*light[i] for i in range(3))/normal_length/length)
        level=min(range(len(DATA['baked_shades'])),key=lambda i:abs(DATA['baked_shades'][i]-brightness))
        mesh.faces[face]=(texture.removesuffix('.png')+f'_shade{level}.png',indices)


def ellipsoid(mesh, kind, center, radii, seed, rings=4, segments=9, irregularity=.17):
    first=len(mesh.faces)
    mesh.add_ellipsoid(material(kind), center, radii, seed, rings, segments, irregularity)
    shade_faces(mesh,first,center)


def rod(mesh, kind, start, end, r1, r2=None, sides=12):
    first=len(mesh.faces)
    mesh.add_frustum(material(kind), start, end, r1, r1 if r2 is None else r2, sides)
    shade_faces(mesh,first,tuple((start[i]+end[i])/2 for i in range(3)))


def mineral(mesh, kind, deposit=False):
    if deposit:
        ellipsoid(mesh, 'host', (0, 4, 0), (17, 4, 12), 471, rings=4, segments=11)
        # Separate lobes leave visible host rock and crevices, without billboard planes.
        spots = [(-10, 5.2, -3), (-3, 6.4, 4), (6, 6.7, -2), (11, 4.8, 4), (-2, 6.5, -7)]
        for i, (x, y, z) in enumerate(spots):
            ellipsoid(mesh, kind, (x, y, z), (4.8, 1.3 if kind == 'salt' else 2.7, 3.6), 471+i)
    else:
        for i, (x, y, z, r) in enumerate([(-2, 2, 0, 2.7), (1, 2.8, -1, 3.2), (2, 1.6, 2, 2), (-2, 1, 3, 1.6)]):
            ellipsoid(mesh, kind, (x, y, z), (r, min(y, r*.7), r*.8), 471+i)
        if kind == 'salt':
            for i in range(7):
                x, z = 1+math.cos(i*2.4)*1.4, -1+math.sin(i*2.4)*1.2
                ellipsoid(mesh, kind, (x, 4.15, z), (.7, .6, .65), 491+i, rings=3, segments=5)


def geometry(shape):
    if shape == 'existing_iodine':
        return iodine()
    mesh = Mesh(f'ca_{shape}')
    if shape in ('saltpeter', 'sulfur', 'saltpeter_deposit', 'sulfur_deposit'):
        mineral(mesh, 'salt' if shape.startswith('saltpeter') else 'sulfur', shape.endswith('deposit'))
    elif shape == 'charcoal':
        for i, (start, end, radius) in enumerate([((-3, 1.5, -3), (2, 1.5, 3), 1.5), ((2, 1.1, -3), (-3, 1.8, 2), 1.3), ((-3, 3, 0), (2, 3.5, 1), 1.1)]):
            rod(mesh, 'charcoal', start, end, radius, radius*.72, sides=7)
            ellipsoid(mesh, 'charcoal', end, (radius, radius*.8, radius*.7), 510+i, rings=3, segments=7)
    elif shape == 'molasses':
        rod(mesh, 'ceramic', (0, 0, 0), (0, 1, 0), 2.7, 3.5)
        rod(mesh, 'ceramic', (0, 1, 0), (0, 5.6, 0), 3.5, 3.8)
        rod(mesh, 'ceramic', (0, 5.6, 0), (0, 6.2, 0), 3.8, 3.2)
        rod(mesh, 'molasses', (0, 6.21, 0), (0, 6.23, 0), 2.9)
        for x in (-4, 4):
            rod(mesh, 'ceramic', (x, 3.2, 0), (x, 5.1, 0), .75)
    elif shape == 'cask':
        rod(mesh, 'wood', (0, 0, 0), (0, 2, 0), 3.4, 4)
        rod(mesh, 'wood', (0, 2, 0), (0, 7, 0), 4)
        rod(mesh, 'wood', (0, 7, 0), (0, 9, 0), 4, 3.4)
        for y, radius in ((1, 3.8), (3, 4.1), (6, 4.1), (8, 3.8)):
            rod(mesh, 'iron', (0, y, 0), (0, y+.4, 0), radius)
        rod(mesh, 'cork', (0, 9, 0), (0, 9.5, 0), .8)
    elif shape == 'alcohol':
        rod(mesh, 'glass', (0, 0, 0), (0, 7, 0), 2.3)
        rod(mesh, 'glass', (0, 7, 0), (0, 8.6, 0), 2.3, .9)
        rod(mesh, 'glass', (0, 8.6, 0), (0, 11, 0), .9)
        rod(mesh, 'cloth', (0, 8.5, 0), (0, 9.5, 0), 1.03)
        rod(mesh, 'cork', (0, 11, 0), (0, 11.7, 0), 1)
    elif shape == 'yeast':
        ellipsoid(mesh, 'cloth', (0, .45, 0), (5, .45, 3.7), 471, rings=3, segments=8)
        ellipsoid(mesh, 'yeast', (0, 1.8, 0), (3.4, 1.3, 2.3), 472, rings=3, segments=6, irregularity=.05)
        for x in (-3.5, 3.5):
            ellipsoid(mesh, 'cloth', (x, 1.1, 0), (1.2, .6, 3.5), 473, rings=3, segments=6)
    elif shape == 'tin':
        rod(mesh, 'iron', (0, 0, 0), (0, 5.3, 0), 3.7)
        rod(mesh, 'iron', (0, 5.3, 0), (0, 5.8, 0), 3.9)
        rod(mesh, 'iron', (0, 5.8, 0), (0, 6.2, 0), .7)
        rod(mesh, 'cloth', (0, 1.2, 0), (0, 2.3, 0), 3.72)
    else:
        raise ValueError(shape)
    return mesh


def icon(mesh, target):
    """Orthographic textured triangle rasterizer; depth resolves overlapping parts."""
    size = 256
    def dot(a, b):
        return sum(x*y for x, y in zip(a, b))
    def cross(a, b):
        return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])
    def normalize(v):
        length = math.sqrt(dot(v, v)) or 1
        return tuple(x/length for x in v)
    vertices = mesh.vertices
    # View the iodine marker on the negative-Z face and the tops of vessels.
    camera = normalize((-.35, .48, -.805))
    right = normalize(cross(camera, (0, 1, 0)))
    up = normalize(cross(right, camera))
    projected = [(dot(v, right), -dot(v, up)) for v in vertices]
    low = [min(v[i] for v in projected) for i in range(2)]
    high = [max(v[i] for v in projected) for i in range(2)]
    scale = (size-28)/max(high[i]-low[i] for i in range(2))
    screen = [tuple((v[i]-(low[i]+high[i])/2)*scale+size/2 for i in range(2)) for v in projected]
    depths = [dot(v, camera) for v in vertices]
    canvas = Image.new('RGBA', (size, size))
    rgba = canvas.load()
    zbuffer = [-math.inf]*(size*size)
    textures_by_path = {}
    light = normalize((-.4, .8, -.6))
    for texture, indices in mesh.faces:
        if texture not in textures_by_path:
            textures_by_path[texture] = Image.open(ROOT/'src'/texture).convert('RGB')
        texture_image = textures_by_path[texture]
        pixels = texture_image.load()
        for n in range(1, len(indices)-1):
            ids = [indices[0]-1, indices[n]-1, indices[n+1]-1]
            p = [screen[i] for i in ids]
            x0, y0 = [max(0, math.floor(min(v[i] for v in p))) for i in range(2)]
            x1, y1 = [min(size-1, math.ceil(max(v[i] for v in p))) for i in range(2)]
            denominator = (p[1][1]-p[2][1])*(p[0][0]-p[2][0])+(p[2][0]-p[1][0])*(p[0][1]-p[2][1])
            if abs(denominator) < 1e-8:
                continue
            normal = normalize(cross(tuple(vertices[ids[1]][i]-vertices[ids[0]][i] for i in range(3)),
                                     tuple(vertices[ids[2]][i]-vertices[ids[0]][i] for i in range(3))))
            if dot(normal, camera) < 0:
                normal = tuple(-v for v in normal)
            shade = .58 + .42*max(0, dot(normal, light))
            for y in range(y0, y1+1):
                for x in range(x0, x1+1):
                    a = ((p[1][1]-p[2][1])*(x+.5-p[2][0])+(p[2][0]-p[1][0])*(y+.5-p[2][1]))/denominator
                    b = ((p[2][1]-p[0][1])*(x+.5-p[2][0])+(p[0][0]-p[2][0])*(y+.5-p[2][1]))/denominator
                    weights = (a, b, 1-a-b)
                    if min(weights) < -1e-8:
                        continue
                    depth = sum(weights[i]*depths[ids[i]] for i in range(3))
                    offset = y*size+x
                    if depth <= zbuffer[offset]:
                        continue
                    uv = [sum(weights[i]*mesh.uvs[ids[i]][j] for i in range(3)) for j in range(2)]
                    tx = max(0, min(texture_image.width-1, round(uv[0]*(texture_image.width-1))))
                    ty = max(0, min(texture_image.height-1, round((1-uv[1])*(texture_image.height-1))))
                    rgba[x, y] = tuple(round(c*shade) for c in pixels[tx, ty])+(255,)
                    zbuffer[offset] = depth
    canvas.resize((128, 128), Image.Resampling.LANCZOS).save(target)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    ICONS.mkdir(parents=True, exist_ok=True)
    textures()
    records = []
    for spec in DATA['assets']:
        mesh = geometry(spec['shape'])
        if spec['key'] != 'iodine':
            # Each usemtl run becomes an OBJ surface. GZDoom 4.14.2 has 32 skin slots.
            # Keep one contiguous surface per material, not one per shaded face.
            mesh.faces.sort(key=lambda face:face[0])
        surface_runs=sum(i==0 or mesh.faces[i-1][0]!=face[0] for i,face in enumerate(mesh.faces))
        if surface_runs>32:
            raise ValueError(f'{spec["key"]}: {surface_runs} OBJ surfaces exceed the engine skin array')
        model = ROOT/'src/models/caelum/world/marine_resources/iodine.obj' if spec['key']=='iodine' else OUT/f"{spec['key']}.obj"
        if spec['key'] != 'iodine':
            mesh.write(model)
        sprite = ICONS/f"ca_material_{spec['key']}.png"
        icon(mesh, sprite)
        records.append({**spec, 'model': model.relative_to(ROOT/'src').as_posix(),
                        'icon': sprite.relative_to(ROOT/'src').as_posix(),
                        'vertices': len(mesh.vertices), 'faces': len(mesh.faces), 'surface_runs':surface_runs,
                        'bounds_xyz_y_up': [[round(min(v[i] for v in mesh.vertices),4), round(max(v[i] for v in mesh.vertices),4)] for i in range(3)],
                        'model_sha256': digest(model), 'icon_sha256': digest(sprite),
                        'textures': sorted({m for m, _ in mesh.faces})})
    inputs = [HERE/'alchemy_ingredients.json', Path(__file__), HERE/'generate_marine_models.py', HERE/'generate_environment_models.py']
    used = sorted({p for r in records for p in r['textures']} |
                  {p.relative_to(ROOT/'src').as_posix() for p in OUT.glob('*.png')})
    manifest = {'issue': 471, 'provenance': DATA['provenance'], 'rules': DATA['rules'],
                'inputs': {p.relative_to(ROOT).as_posix(): digest(p) for p in inputs},
                'textures': {p: digest(ROOT/'src'/p) for p in used}, 'assets': records}
    (HERE/'alchemy_ingredients_manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8', newline='\n')
    # A review sheet lives outside src and is never an inventory texture.
    sheet = Image.new('RGB', (4*180, 3*164), (36, 33, 30))
    draw = ImageDraw.Draw(sheet)
    for i, r in enumerate(records):
        x, y = i%4*180, i//4*164
        sprite = Image.open(ROOT/'src'/r['icon'])
        sheet.paste(sprite, (x+26, y+4), sprite)
        draw.text((x+8, y+140), r['en'], fill=(227,216,190))
    review = ROOT/'assets/validation_576'
    review.mkdir(parents=True, exist_ok=True)
    sheet.save(review/'ingredient-sheet.png')
    print(f'Generated {len(records)} matching icons, 10 new models; iodine mesh unchanged.')


if __name__ == '__main__':
    main()
