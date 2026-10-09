"""Register complete Domingo/giant-rat death frames without rewriting PNG pixels."""
from pathlib import Path
import hashlib, json, re, shutil
from register_carbine_world import rgba, alpha_bounds

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/death_repair_518'
OUT = ROOT / 'src/graphics/caelum/death_repair'
BEGIN = '// BEGIN GENERATED RAT DEATH REPAIR 518'
END = '// END GENERATED RAT DEATH REPAIR 518'


def main():
    data = json.loads((SOURCE / 'DESIGN.json').read_text())
    OUT.mkdir(parents=True, exist_ok=True)
    target = ROOT / 'src/TEXTURES'
    text = target.read_text(encoding='utf-8')
    added = []
    records = []
    for actor in data['actors']:
        source = SOURCE / (actor['atlas'] + '.png')
        w, h, rows = rgba(source)
        xs, ys = actor['columns'], actor['rows']
        assert xs[0] == ys[0] == 0 and xs[-1] == w and ys[-1] == h
        first = alpha_bounds(rows, (xs[0], ys[0], xs[1], ys[1]))
        scale = (first[3] - first[1] + 1) / actor['first_pose_height']
        shutil.copyfile(source, OUT / source.name)
        for index, frame in enumerate(actor['frames']):
            col, row = index % 4, index // 4
            x1, x2 = xs[col:col+2]
            y1, y2 = ys[row:row+2]
            bounds = alpha_bounds(rows, (x1, y1, x2, y2))
            # Detect a slice through opaque artwork, not just an empty canvas.
            assert x1 < bounds[0] < bounds[2] < x2-1
            assert y1 < bounds[1] < bounds[3] < y2-1
            pivot = [(bounds[0] + bounds[2] + 1)//2-x1, bounds[3]-y1+1]
            name = actor['prefix'] + frame + '0'
            line = (f'Sprite "{name}", {x2-x1}, {y2-y1} {{ XScale {scale:.9f} YScale {scale:.9f} '
                    f'Offset {pivot[0]}, {pivot[1]} Patch "graphics/caelum/death_repair/{source.name}", {-x1}, {-y1} }}')
            if actor['prefix'] == 'DOMI':
                pattern = rf'^Sprite "{name}",[^\r\n]*$'
                text, count = re.subn(pattern, line, text, flags=re.M)
                assert count == 1, (name, count)
            else:
                added.append(line)
            records.append({'name': name, 'clip': [x1,y1,x2,y2], 'opaque_bounds': bounds,
                            'pivot': pivot, 'scale': scale, 'source': source.name,
                            'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest()})
    block = BEGIN + '\n' + '\n'.join(added) + '\n' + END
    if BEGIN in text:
        text = text[:text.index(BEGIN)] + block + text[text.index(END)+len(END):]
    else:
        text += '\n' + block + '\n'
    target.write_text(text, encoding='utf-8')
    (SOURCE / 'REGISTRATION.json').write_text(json.dumps(records, indent=2) + '\n', encoding='utf-8')
    print('Registered 16 complete death frames; original PNGs and state timing preserved.')


if __name__ == '__main__':
    main()
