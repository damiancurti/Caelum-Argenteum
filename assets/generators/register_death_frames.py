"""Register original Domingo death frames without rewriting PNG pixels."""
from pathlib import Path
import hashlib, json, re, shutil
from register_carbine_world import rgba, alpha_bounds

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/death_repair_518'
OUT = ROOT / 'src/graphics/caelum/death_repair'
BEGIN = '// BEGIN GENERATED RAT DEATH REPAIR 518'
END = '// END GENERATED RAT DEATH REPAIR 518'
PART_BEGIN = '// BEGIN GENERATED ORIGINAL DOMINGO CLIPS 518'
PART_END = '// END GENERATED ORIGINAL DOMINGO CLIPS 518'


def main():
    data = json.loads((SOURCE / 'DESIGN.json').read_text())
    OUT.mkdir(parents=True, exist_ok=True)
    target = ROOT / 'src/TEXTURES'
    text = target.read_text(encoding='utf-8')
    added = []
    helpers = []
    records = []
    for actor in data['actors']:
        source = SOURCE / (actor['atlas'] + '.png')
        w, h, rows = rgba(source)
        if 'clips' in actor:
            clips = actor['clips']
            reference = alpha_bounds(rows, actor['standing_reference_clip'])
            rw, rh, standing = rgba(ROOT / actor['standing_reference'])
            native = alpha_bounds(standing, (0, 0, rw, rh))
            scale = (reference[3] - reference[1] + 1) / (native[3] - native[1] + 1)
        else:
            xs, ys = actor['columns'], actor['rows']
            assert xs[0] == ys[0] == 0 and xs[-1] == w and ys[-1] == h
            clips = [[xs[i % 4], ys[i // 4], xs[i % 4 + 1], ys[i // 4 + 1]]
                     for i in range(len(actor['frames']))]
            first = alpha_bounds(rows, clips[0])
            scale = (first[3] - first[1] + 1) / actor['first_pose_height']
        parts = actor.get('parts', [[clip] for clip in clips])
        assert len(clips) == len(parts) == len(actor['frames'])
        if 'coverage_clip' in actor:
            # The irregular corpse silhouettes overlap in X, but never in pixels.
            # Native rectangular subtextures preserve them without editing the PNG.
            a, b, c, d = actor['coverage_clip']
            for y in range(b, d):
                for x in range(a, c):
                    if rows[y][4*x+3] >= 16:
                        assert sum(x1 <= x < x2 and y1 <= y < y2
                                   for pieces in parts for x1,y1,x2,y2 in pieces) == 1, (x, y)
        shutil.copyfile(source, OUT / source.name)
        for index, frame in enumerate(actor['frames']):
            x1, y1, x2, y2 = clips[index]
            piece_bounds = []
            for a,b,c,d in parts[index]:
                assert 0 <= x1 <= a < c <= x2 <= w and 0 <= y1 <= b < d <= y2 <= h
                if any(rows[y][4*x+3] >= 128 for y in range(b,d) for x in range(a,c)):
                    piece_bounds.append(alpha_bounds(rows, (a,b,c,d)))
            assert piece_bounds, actor['prefix'] + frame
            bounds = (min(b[0] for b in piece_bounds), min(b[1] for b in piece_bounds),
                      max(b[2] for b in piece_bounds), max(b[3] for b in piece_bounds))
            # Detect a slice through opaque artwork, not just an empty canvas.
            assert x1 < bounds[0] < bounds[2] < x2-1
            assert y1 < bounds[1] < bounds[3] < y2-1
            pivot = [(bounds[0] + bounds[2] + 1)//2-x1, bounds[3]-y1+1]
            name = actor['prefix'] + frame + '0'
            patches = f'Patch "graphics/caelum/death_repair/{source.name}", {-x1}, {-y1}'
            if len(parts[index]) > 1:
                patches = ''
                for part, (a,b,c,d) in enumerate(parts[index]):
                    key = f'CA518_{name}_{part}'
                    helpers.append(f'Graphic "{key}", {c-a}, {d-b} {{ Patch "graphics/caelum/death_repair/{source.name}", {-a}, {-b} }}')
                    patches += f'Graphic "{key}", {a-x1}, {b-y1} '
            line = (f'Sprite "{name}", {x2-x1}, {y2-y1} {{ XScale {scale:.9f} YScale {scale:.9f} '
                    f'Offset {pivot[0]}, {pivot[1]} {patches.rstrip()} }}')
            if actor['prefix'] == 'DOMI':
                pattern = rf'^Sprite "{name}",[^\r\n]*$'
                text, count = re.subn(pattern, line, text, flags=re.M)
                assert count == 1, (name, count)
            else:
                added.append(line)
            records.append({'name': name, 'clip': [x1,y1,x2,y2], 'opaque_bounds': bounds,
                            'pivot': pivot, 'scale': scale, 'source': source.name,
                            'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest()})
            if 'parts' in actor:
                records[-1]['native_clip_parts'] = parts[index]
    block = PART_BEGIN + '\n' + '\n'.join(helpers) + '\n' + PART_END
    if PART_BEGIN in text:
        text = text[:text.index(PART_BEGIN)] + block + text[text.index(PART_END)+len(PART_END):]
    else:
        text += '\n' + block + '\n'
    if added:
        block = BEGIN + '\n' + '\n'.join(added) + '\n' + END
        if BEGIN in text:
            text = text[:text.index(BEGIN)] + block + text[text.index(END)+len(END):]
        else:
            text += '\n' + block + '\n'
    target.write_text(text, encoding='utf-8')
    (SOURCE / 'REGISTRATION.json').write_text(json.dumps(records, indent=2) + '\n', encoding='utf-8')
    print(f'Registered {len(records)} complete death frames; original PNGs and state timing preserved.')


if __name__ == '__main__':
    main()
