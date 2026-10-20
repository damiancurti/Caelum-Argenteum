"""Deterministically bake the editable #369 Blender source to native MD3 v15.

Run with Blender 4.5.3: blender -b --python assets/generators/export_bull_model.py
-- --output build/issue369-export. The source is art, not a generated runtime file.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import shutil
import struct
import sys
import zlib

import bpy

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'assets/source/art/bull_3d'


def fixed(value, length):
    value = value.encode('ascii')
    if len(value) >= length:
        raise ValueError(value)
    return value.ljust(length, b'\0')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--source', default='bull.blend')
    parser.add_argument('--install', action='store_true', help='Install the generated runtime assets and registrations.')
    args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
    if bpy.app.version != (4, 5, 3):
        raise RuntimeError('Use the pinned Blender 4.5.3 authoring/export version.')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    source = ART / args.source
    bpy.ops.wm.open_mainfile(filepath=str(source))
    scene = bpy.context.scene
    rig = bpy.data.objects['Bull_Rig']
    objects = [bpy.data.objects['Bull_surface']]
    # Sample counts/timings are art data. Runtime action timings remain native.
    design = json.loads((ART / 'DESIGN.json').read_text(encoding='utf-8'))
    config = design['export_actions']
    visual_scale = design.get('visual_scale_revision', {}).get('factor', 1)
    export_scale = design['export_transform']['scale'] * visual_scale
    bounds = []
    frames = []
    sample_times = []
    actions = {}
    for name, options in config.items():
        sequence = options['frames']
        playback = options.get('sample_tics', sequence)
        if (len(playback) != len(sequence) or not playback or playback[0] != 0
                or any(not isinstance(t, int) or t < 0 for t in playback)
                or playback != sorted(playback) or playback[-1] > options['tics']):
            raise ValueError(f'Invalid native sample timing: {name}')
        actions[name] = dict(options, start=len(frames), count=len(sequence))
        frames.extend((name, f) for f in sequence)
        sample_times.extend(playback)
    uv = []
    triangles = []
    mapping = []
    pose_bytes = bytearray()
    headers = bytearray()
    for frame_number, (name, frame) in enumerate(frames):
        rig.animation_data.action = bpy.data.actions[name]
        scene.frame_set(frame)
        graph = bpy.context.evaluated_depsgraph_get()
        locations = []
        cursor = 0
        for obj in objects:
            evaluated = obj.evaluated_get(graph)
            data = evaluated.to_mesh()
            data.calc_loop_triangles()
            if frame_number == 0:
                lookup = {}
                local_map = []
                for triangle in data.loop_triangles:
                    indices = []
                    for loop in triangle.loops:
                        vertex = data.loops[loop].vertex_index
                        coord = tuple(data.uv_layers.active.data[loop].uv)
                        key = (vertex, coord)
                        if key not in lookup:
                            lookup[key] = len(uv)
                            uv.append((coord[0], 1 - coord[1]))
                            local_map.append(vertex)
                        indices.append(lookup[key])
                    triangles.append(indices)
                mapping.append(local_map)
            local_map = mapping[cursor]
            normal_matrix = evaluated.matrix_world.to_3x3().inverted().transposed()
            for vertex in local_map:
                position = (evaluated.matrix_world @ data.vertices[vertex].co) * export_scale
                normal = (normal_matrix @ data.vertices[vertex].normal).normalized()
                lat = round(math.atan2(normal.y, normal.x) * 128 / math.pi) & 255
                lng = round(math.acos(max(-1, min(1, normal.z))) * 128 / math.pi) & 255
                xyz = [round(v * 64) for v in position]
                if any(not -32768 <= v <= 32767 for v in xyz):
                    raise ValueError('MD3 coordinate exceeds signed 16-bit range')
                pose_bytes.extend(struct.pack('<3hH', *xyz, (lat << 8) | lng))
                locations.append(tuple(position))
            evaluated.to_mesh_clear()
            cursor += 1
        minimum = [min(v[i] for v in locations) for i in range(3)]
        maximum = [max(v[i] for v in locations) for i in range(3)]
        bounds.append({'pose': name, 'sample': frame, 'min': minimum, 'max': maximum})
        radius = max(math.sqrt(sum(x * x for x in v)) for v in locations)
        headers.extend(struct.pack('<10f16s', *minimum, *maximum, 0, 0, 0, radius, fixed('f%04d' % frame_number, 16)))
    tri_bytes = b''.join(struct.pack('<3I', *t) for t in triangles)
    skin = struct.pack('<64sI', fixed('bull_skin.png', 64), 0)
    uv_bytes = b''.join(struct.pack('<2f', *t) for t in uv)
    tri_offset = 108
    skin_offset = tri_offset + len(tri_bytes)
    uv_offset = skin_offset + len(skin)
    pose_offset = uv_offset + len(uv_bytes)
    surface_end = pose_offset + len(pose_bytes)
    surface = struct.pack('<4s64s10I', b'IDP3', fixed('Bull cleaned surface', 64),
                          0, len(frames), 1, len(uv), len(triangles), tri_offset,
                          skin_offset, uv_offset, pose_offset, surface_end)
    surfaces_offset = 108 + len(headers)
    header = struct.pack('<4sI64s9I', b'IDP3', 15, fixed('Bull #369', 64),
                         0, len(frames), 0, 1, 1, 108, surfaces_offset,
                         surfaces_offset, surfaces_offset + surface_end)
    blob = header + headers + surface + tri_bytes + skin + uv_bytes + pose_bytes
    (output / 'bull.md3').write_bytes(blob)
    (output / 'bull_skin.png').write_bytes((ART / 'bull_skin.png').read_bytes())
    # Every MD3 frame has a unique native state/sprite pair. The sprite is only
    # a transparent owned fallback; no Doom graphics are incorporated.
    textures = []
    states = ['// Generado desde DESIGN.json y el Blender editable del #369.',
              'class CaelumBullModelFrames : Actor', '{']
    states.append(f'    const WALK_STRIDE={design["motion"]["walk_stride_mu"] * visual_scale:g};')
    states.append(f'    const RUN_STRIDE={design["motion"]["run_stride_mu"] * visual_scale:g};')
    states.append(f'    const VISUAL_RADIUS={math.ceil(max(max(abs(b["min"][i]),abs(b["max"][i])) for b in bounds for i in (0,1)))};')
    states.append(f'    const VISUAL_HEIGHT={math.ceil(max(b["max"][2] for b in bounds))};')
    for index, name in enumerate(actions):
        states.append(f'    const {name.upper()}={index};')
    for method, field in [('Start', 'start'), ('Count', 'count'), ('Duration', 'tics')]:
        values = ','.join(str(a[field]) for a in actions.values())
        states += [f'    static clearscope int {method}(int poseId)', '    {',
                   f'        static const int values[]={{{values}}};',
                   f'        return values[Clamp(poseId,0,{len(actions)-1})];', '    }']
    times = ','.join(str(t) for t in sample_times)
    states += ['    static clearscope int Sample(int frame)', '    {',
               f'        static const int times[]={{{times}}};',
               f'        return times[Clamp(frame,0,{len(frames)-1})];', '    }',
               '    static clearscope int FrameFor(int poseId,int elapsed)', '    {',
               '        int first=Start(poseId),count=Count(poseId);',
               '        for(int i=count-1;i>0;i--)if(elapsed>=Sample(first+i))return first+i;',
               '        return first;', '    }', '    States', '    {', '    Spawn:', '        Goto F0;']
    model = ['Model CaelumBullModelBody', '{', '    Path "models/caelum/bull"',
             '    Model 0 "bull.md3"', '    Skin 0 "bull_skin.png"',
             '    Scale 1 1 1', '    DontCullBackFaces']
    for number, (name, frame) in enumerate(frames):
        sprite = 'B3%02X' % (number // 26)
        letter = chr(65 + number % 26)
        model.append(f'    FrameIndex {sprite} {letter} 0 {number}')
        textures.append(f'Sprite "{sprite}{letter}0", 1, 1 {{ Patch "graphics/caelum/bull_invisible.png", 0, 0 }}')
        action = actions[name]
        last = number == action['start'] + action['count'] - 1
        delay = action['tics'] - sample_times[number] if last else sample_times[number+1] - sample_times[number]
        terminal = last and not action['loop']
        states += [f'    F{number}:', f'        {sprite} {letter} {-1 if terminal else max(1,delay)};',
                   '        Stop;' if terminal else f'        Goto F{action["start"] if last else number+1};']
    states += ['    }', '}', '']
    model += ['}', '']
    (output / 'frames.zs').write_text('\n'.join(states), encoding='utf-8', newline='\n')
    (output / 'MODELDEF').write_text('\n'.join(model), encoding='utf-8', newline='\n')
    (output / 'TEXTURES').write_text('\n'.join(textures) + '\n', encoding='utf-8', newline='\n')
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data))
    transparent = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', 1, 1, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(bytes(5), 9)) + chunk(b'IEND', b'')
    (output / 'bull_invisible.png').write_bytes(transparent)
    report = {'source': source.relative_to(ROOT).as_posix(), 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
              'blender': bpy.app.version_string, 'surfaces': 1, 'vertices': len(uv), 'triangles': len(triangles),
              'frames': len(frames), 'bytes': len(blob), 'md3_sha256': hashlib.sha256(blob).hexdigest(), 'actions': actions, 'bounds': bounds}
    (output / 'manifest.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    if args.install:
        for source_name, target in [
            ('bull.md3', 'src/models/caelum/bull/bull.md3'),
            ('bull_skin.png', 'src/models/caelum/bull/bull_skin.png'),
            ('frames.zs', 'src/caelum/actors/CaelumBullModelFrames.zs'),
            ('TEXTURES', 'src/graphics/caelum/bull_model.textures'),
            ('bull_invisible.png', 'src/graphics/caelum/bull_invisible.png'),
        ]:
            path = ROOT / target
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(output / source_name, path)
        modeldef = ROOT / 'src/MODELDEF'
        content = modeldef.read_text(encoding='utf-8')
        begin, end = '// BEGIN BULL 3D MODEL\n', '// END BULL 3D MODEL'
        if content.count(begin) != 1 or content.count(end) != 1:
            raise ValueError('Expected one dedicated #369 model registration block')
        first = content.index(begin)
        last = content.index(end, first)
        content = content[:first] + begin + '\n'.join(model) + content[last:]
        modeldef.write_text(content, encoding='utf-8', newline='\n')
    print('CA369 EXPORT', json.dumps({k: v for k, v in report.items() if k not in ('actions','bounds')}))


if __name__ == '__main__':
    main()
