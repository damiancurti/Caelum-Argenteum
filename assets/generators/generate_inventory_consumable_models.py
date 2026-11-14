"""Export reference-led medikit and flask geometry without changing item rules."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import zipfile
from PIL import Image

try:
    from .generate_nahuelito_model import Mesh, md3, fixed, add, sub, mul, dot, cross, unit
    from .generate_pombero_model import orient
except ImportError:
    from generate_nahuelito_model import Mesh, md3, fixed, add, sub, mul, dot, cross, unit
    from generate_pombero_model import orient

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/inventory_models_647/consumables'


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def tube(mesh, shape):
    """Carry a continuous cross-section basis around handles and straps."""
    rows, segments = shape['rows'], shape['segments']
    rings = []
    across = None
    for index, row in enumerate(rows):
        tangent = unit(sub(rows[min(index + 1, len(rows) - 1)][:3], rows[max(index - 1, 0)][:3]))
        projected = sub(across, mul(tangent, dot(across, tangent))) if across is not None else (0, 0, 0)
        if dot(projected, projected) < 1e-12:
            reference = (0, 0, 1) if abs(tangent[2]) < .9 else (1, 0, 0)
            projected = cross(tangent, reference)
        across = unit(projected)
        up = unit(cross(across, tangent))
        ring = []
        for step in range(segments + 1):
            angle = math.tau * step / segments
            point = add(row[:3], add(mul(across, row[3] * math.cos(angle)), mul(up, row[4] * math.sin(angle))))
            ring.append(mesh.vertex(point, (step / segments, index / (len(rows) - 1)), shape['part']))
        rings.append(ring)
    for index in range(len(rows) - 1):
        for step in range(segments):
            a, b, c, d = rings[index][step], rings[index + 1][step], rings[index + 1][step + 1], rings[index][step + 1]
            outward = sub(mesh.vertices[a], rows[index][:3])
            for triangle in ((a, b, c), (a, c, d)):
                mesh.faces.append((shape['material'], orient(mesh, triangle, outward)))
    for index, neighbor in ((0, 1), (-1, -2)):
        center = mesh.vertex(rows[index][:3], (.5, .5), shape['part'])
        for step in range(segments):
            triangle = (center, rings[index][step], rings[index][step + 1])
            mesh.faces.append((shape['material'], orient(mesh, triangle, sub(rows[index][:3], rows[neighbor][:3]))))


def loft(mesh, shape):
    """Closed elliptical or rounded-rectangle horizontal rings."""
    rows = shape['rows']
    segments = shape['segments']
    exponent = shape.get('exponent', 1)
    rings = []
    for index, (z, x, y, rx, ry) in enumerate(rows):
        ring = []
        for step in range(segments + 1):
            angle = math.tau * step / segments
            cosine, sine = math.cos(angle), math.sin(angle)
            # Fractional powers amplify floating-point residue at quadrant seams.
            cosine = 0 if abs(cosine) < 1e-12 else cosine
            sine = 0 if abs(sine) < 1e-12 else sine
            point = (x + rx * math.copysign(abs(cosine) ** exponent, cosine),
                     y + ry * math.copysign(abs(sine) ** exponent, sine), z)
            ring.append(mesh.vertex(point, (step / segments, 1 - (z-rows[0][0])/(rows[-1][0]-rows[0][0])), shape['part']))
        rings.append(ring)
    for row in range(len(rings) - 1):
        for step in range(segments):
            mesh.quad((rings[row][step], rings[row][step + 1], rings[row + 1][step + 1],
                       rings[row + 1][step]), shape['material'])
    for row, direction in ((0, (0, 0, -1)), (-1, (0, 0, 1))):
        z, x, y, _, _ = rows[row]
        center = mesh.vertex((x, y, z), (.5, .5), shape['part'])
        for step in range(segments):
            mesh.faces.append((shape['material'], orient(mesh, (center, rings[row][step],
                                                                rings[row][step + 1]), direction)))


def prism(mesh, shape):
    """Closed front/back polygon with independent cap UVs, facing negative Y."""
    controls = shape['outline']
    steps = shape.get('outline_subdivisions', 1)
    outline = []
    for index, point in enumerate(controls):
        following = controls[(index + 1) % len(controls)]
        for step in range(steps):
            outline.append(tuple(a + (b-a)*step/steps for a,b in zip(point, following)))
    depth = shape['depth']
    center = shape['center']
    xs, zs = [p[0] for p in outline], [p[1] for p in outline]
    def vertex(x, z, side):
        px, pz = center[0] + x, center[2] + z
        py = center[1]
        if 'surface_profile' in shape:
            profile = shape['surface_profile']
            if len(profile[0]) == 4:
                # Optional elliptical crown: Z, X radius, Y radius, Y center.
                rx,ry,cy = profile[0][1:] if pz <= profile[0][0] else profile[-1][1:]
                for before,after in zip(profile,profile[1:]):
                    if before[0] <= pz <= after[0]:
                        fraction=(pz-before[0])/(after[0]-before[0])
                        rx,ry,cy=(a+(b-a)*fraction for a,b in zip(before[1:],after[1:]))
                        break
                py=cy-ry*math.sqrt(max(0,1-(px/rx)**2))-shape['surface_offset']
            else:
                radius = profile[0][1] if pz <= profile[0][0] else profile[-1][1]
                for (za, ra), (zb, rb) in zip(profile, profile[1:]):
                    if za <= pz <= zb:
                        radius = ra + (rb-ra)*(pz-za)/(zb-za)
                        break
                py = -math.sqrt(max(0, radius*radius-px*px)) - shape['surface_offset']
        return mesh.vertex((px, py + side * depth / 2, pz),
                           ((x-min(xs))/(max(xs)-min(xs)), 1-(z-min(zs))/(max(zs)-min(zs))), shape['part'])
    rings = []
    for side in (-1, 1):
        radial_steps = shape.get('surface_subdivisions', 1)
        rows = [[vertex(x*radial/radial_steps, z*radial/radial_steps, side) for x,z in outline]
                for radial in range(1, radial_steps+1)]
        mid = vertex(0, 0, side)
        for index in range(len(outline)):
            tri = (mid, rows[0][index], rows[0][(index + 1) % len(outline)])
            mesh.faces.append((shape['material'], orient(mesh, tri, (0, side, 0))))
        for row in range(len(rows)-1):
            for index in range(len(outline)):
                following = (index+1) % len(outline)
                a,b,c,d = rows[row][index], rows[row+1][index], rows[row+1][following], rows[row][following]
                for tri in ((a,b,c),(a,c,d)):
                    mesh.faces.append((shape['material'], orient(mesh,tri,(0,side,0))))
        rings.append(rows[-1])
    for index in range(len(outline)):
        following = (index + 1) % len(outline)
        outward = (outline[index][0], 0, outline[index][1])
        a, b, c, d = rings[0][index], rings[1][index], rings[1][following], rings[0][following]
        for tri in ((a, b, c), (a, c, d)):
            mesh.faces.append((shape['material'], orient(mesh, tri, outward)))


def geometry(config, family, tier):
    mesh = Mesh()
    for original in family['parts']:
        if tier not in original.get('tiers', config['tiers']):
            continue
        shape = dict(original)
        shape['material'] = config['tier_materials'][tier].get(shape['material'], shape['material'])
        begin = len(mesh.vertices)
        first_face = len(mesh.faces)
        {'loft': loft, 'tube': tube, 'prism': prism}[shape['kind']](mesh, shape)
        if shape.get('uv_projection') == 'box':
            low = [min(point[axis] for point in mesh.vertices[begin:]) for axis in range(3)]
            high = [max(point[axis] for point in mesh.vertices[begin:]) for axis in range(3)]
            projected = []
            for material, triangle in mesh.faces[first_face:]:
                points = [mesh.vertices[index] for index in triangle]
                normal = cross(sub(points[1], points[0]), sub(points[2], points[0]))
                axis = max(range(3), key=lambda index: abs(normal[index]))
                uaxis, vaxis = ((1, 2), (0, 2), (0, 1))[axis]
                projected.append((material, [(point, ((point[uaxis]-low[uaxis])/(high[uaxis]-low[uaxis]),
                                                       1-(point[vaxis]-low[vaxis])/(high[vaxis]-low[vaxis]))) for point in points]))
            mesh.vertices[begin:] = []
            mesh.uv[begin:] = []
            mesh.parts[begin:] = []
            mesh.faces[first_face:] = []
            for material, triangle in projected:
                indices = tuple(mesh.vertex(point, uv, shape['part']) for point, uv in triangle)
                mesh.faces.append((material, indices))
        column, row = config['atlas']['tiles'][shape['material']]
        inset = config['atlas']['inset']
        for index in range(begin, len(mesh.vertices)):
            u, v = mesh.uv[index]
            mesh.uv[index] = ((column + inset + (1 - 2 * inset) * u) / config['atlas']['columns'],
                              (row + inset + (1 - 2 * inset) * v) / config['atlas']['rows'])
    # Validate each authored component, including UV seams, before native quantization.
    edges = {}
    directions = {}
    volumes = {}
    for _, triangle in mesh.faces:
        points = [tuple(round(value, 7) for value in mesh.vertices[index]) for index in triangle]
        part = mesh.parts[triangle[0]]
        for a, b in zip(points, points[1:] + points[:1]):
            key = part, tuple(sorted((a, b)))
            edges[key] = edges.get(key, 0) + 1
            directions[key] = directions.get(key, 0) + (1 if a < b else -1)
        a, b, c = points
        volumes[part] = volumes.get(part, 0) + (a[0]*(b[1]*c[2]-b[2]*c[1]) + a[1]*(b[2]*c[0]-b[0]*c[2]) + a[2]*(b[0]*c[1]-b[1]*c[0])) / 6
    if any(count != 2 for count in edges.values()):
        raise ValueError('Open/nonmanifold authored component: ' + str([key[0] for key, count in edges.items() if count != 2][:8]))
    if any(value != 0 for value in directions.values()):
        raise ValueError('Inconsistent component winding: ' + str([key[0] for key, value in directions.items() if value != 0][:8]))
    if any(volume <= 0 for volume in volumes.values()):
        raise ValueError('Inward/empty authored component: ' + str(volumes))
    return mesh, volumes


def output_files(source=SOURCE, definition_name='inventory_consumables.modeldef'):
    config = json.loads((source / 'DESIGN.json').read_text(encoding='utf-8'))
    outputs = {}
    definitions = []
    records = {}
    model_path = config['model_path']
    texture = (source / config['atlas']['image']).read_bytes()
    if digest(texture) != config['atlas']['sha256']:
        raise ValueError('Owned atlas changed; inspect and update its provenance first.')
    outputs[model_path + '/materials.png'] = texture
    for key, item in config['variants'].items():
        icon_path = ROOT / item['icon']
        if digest(icon_path.read_bytes()) != item['icon_sha256']:
            raise ValueError('Existing identity reference changed: ' + key)
        image = Image.open(icon_path).convert('RGBA')
        bounds = image.getchannel('A').point(lambda value: 255 if value >= 128 else 0).getbbox()
        target_height = bounds[3] - bounds[1]
        mesh, volumes = geometry(config, config['families'][item['family']], item['tier'])
        floor = min(p[2] for p in mesh.vertices)
        height = max(p[2] for p in mesh.vertices) - floor
        extent = max(p[0] for p in mesh.vertices) - min(p[0] for p in mesh.vertices)
        width_scaled = config.get('reference_axis', 'height') == 'width'
        factor = (bounds[2] - bounds[0]) / extent if width_scaled else target_height / height
        frame = [(x * factor, y * factor, (z - floor) * factor) for x, y, z in mesh.vertices]
        native = Mesh()
        native.vertices, native.uv, native.parts = mesh.vertices, mesh.uv, mesh.parts
        native.faces = [('atlas', triangle) for _, triangle in mesh.faces]
        binary, surfaces, native_bounds = md3(native, [frame], {'atlas': model_path + '/materials.png'})
        binary = binary[:8] + fixed('CA647 ' + key, 64) + binary[72:]
        outputs[model_path + '/' + key + '.md3'] = binary
        definitions.append(f'Model {item["class"]} {{ Path "{model_path}" Model 0 "{key}.md3" Skin 0 "materials.png" Scale 1 1 1 CorrectPixelStretch FrameIndex {item["sprite"]} A 0 0 }}')
        for binding in item.get('additional_bindings', []):
            scale = ' '.join(str(value) for value in binding['scale'])
            definitions.append(f'Model {binding["class"]} {{ Path "{model_path}" Model 0 "{key}.md3" Skin 0 "materials.png" Scale {scale} CorrectPixelStretch FrameIndex {item["sprite"]} A 0 0 }}')
        obj = ['# Editable neutral mesh; OBJ Y up. Native item rules remain unchanged.', 'mtllib materials.mtl']
        obj += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x, y, z in frame]
        obj += [f'vt {u:.8f} {1-v:.8f}' for u, v in mesh.uv]
        previous = None
        for _, triangle in mesh.faces:
            part = mesh.parts[triangle[0]]
            if part != previous:
                obj += ['g ' + part, 'usemtl atlas']
                previous = part
            obj.append('f ' + ' '.join(f'{index+1}/{index+1}' for index in triangle))
        outputs['editable/' + key + '.obj'] = ('\n'.join(obj) + '\n').encode()
        records[key] = {'class': item['class'], 'family': item['family'], 'tier': item['tier'], 'parts': list(volumes),
                        'closed_outward_components': len(volumes), 'vertices': len(mesh.vertices), 'triangles': len(mesh.faces),
                        'surfaces': surfaces, 'source_opaque_bounds': bounds, 'model_height_art_pixels': height * factor if width_scaled else target_height,
                        'native_bounds': native_bounds}
    outputs['editable/materials.mtl'] = ('newmtl atlas\nKd 1 1 1\nmap_Kd ../' + model_path + '/materials.png\n').encode()
    outputs['caelum/data/' + definition_name] = ('\n'.join(definitions) + '\n').encode()
    manifest = {'schema_revision': 1, 'issue': 647, 'status': config['status'], 'variants': records,
                'generator_sha256': digest(Path(__file__).read_bytes()),
                'shared_generator_sha256': {name: digest(Path(__file__).with_name(name).read_bytes()) for name in
                                            ('generate_nahuelito_model.py', 'generate_pombero_model.py', *config.get('generator_dependencies', []))},
                'source_sha256': {name: digest((source / name).read_bytes()) for name in
                                  ('DESIGN.json', 'PROVENANCE.json', config['atlas']['image'], *config['prompt_files'])},
                'sha256': {name: digest(blob) for name, blob in outputs.items()}}
    outputs['manifest.json'] = (json.dumps(manifest, indent=2) + '\n').encode()
    return outputs


def main(source=SOURCE, definition_name='inventory_consumables.modeldef'):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--install', action='store_true', help='Install/check native files and the source export manifest; editable OBJ remains in the export directory.')
    args = parser.parse_args()
    files = output_files(source, definition_name)
    for name, blob in files.items():
        path = args.output / name
        if args.check:
            if not path.is_file() or path.read_bytes() != blob:
                raise ValueError('Stale export: ' + name)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(blob)
        if args.install and not name.startswith('editable/'):
            installed = source / 'EXPORT.json' if name == 'manifest.json' else ROOT / 'src' / name
            if args.check:
                if not installed.is_file() or installed.read_bytes() != blob:
                    raise ValueError('Stale installed consumable: ' + name)
            else:
                installed.parent.mkdir(parents=True, exist_ok=True)
                installed.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output / 'preview.pk3', 'w') as package:
            for name, blob in sorted(files.items()):
                if name == 'manifest.json' or name.startswith('editable/'):
                    continue
                package.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name, (2026, 11, 13, 0, 0, 0)), blob)
    summary = json.loads(files['manifest.json'])['variants']
    print(json.dumps({key: {'parts': item['closed_outward_components'], 'triangles': item['triangles']} for key, item in summary.items()}))


if __name__ == '__main__':
    main()
