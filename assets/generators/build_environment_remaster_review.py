"""Audit and assemble the exact author-provided #866 texture review overlay.

No bitmap is transformed. The recovered binding fragment is copied byte-for-byte.
Production maps, raw PNG paths and derived compositions remain unchanged.
"""
from pathlib import Path
import argparse
from collections import Counter
import hashlib
import json
import re
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'assets/source/art/environment_remasters_866'
SHA = lambda data: hashlib.sha256(data).hexdigest()


def definitions(text):
    """Extract balanced native texture blocks, including nested patch options."""
    for match in re.finditer(r'(?im)^\s*(Texture|Flat|Sprite|Graphic|WallTexture)\s+"([^\"]+)"[^\n]*\n?\s*\{', text):
        start = match.end() - 1
        depth = 1
        end = start + 1
        while depth:
            depth += (text[end] == '{') - (text[end] == '}')
            end += 1
        yield match[1], match[2], text[match.start():end]


def textmap(data):
    magic, count, offset = struct.unpack_from('<4sii', data)
    assert magic in (b'PWAD', b'IWAD')
    for i in range(count):
        pos, size, name = struct.unpack_from('<ii8s', data, offset + i * 16)
        if name.rstrip(b'\0') == b'TEXTMAP':
            return data[pos:pos + size].decode('utf-8')
    return None


def audit():
    provenance = json.loads((SOURCE / 'PROVENANCE.json').read_text(encoding='utf-8'))
    for row in provenance['files']:
        assert SHA((SOURCE / row['file']).read_bytes()) == row['sha256'], row['file']
    bindings = (SOURCE / 'TEXTURES_MEJORAS_V3.txt').read_text(encoding='utf-8-sig')
    aliases = sorted({name for _, name, _ in definitions(bindings)})
    exports = [row for row in provenance['files'] if row['file'].startswith('exports/')]
    raw_paths = {f'graphics/caelum/textures/mansion/{Path(row["file"]).name}' for row in exports}
    compositions = []
    native_bindings = []
    texture_sources = [ROOT / 'src/TEXTURES', *sorted((ROOT / 'src').rglob('*.textures'))]
    for path in texture_sources:
        original = path.read_text(encoding='utf-8-sig')
        for kind, name, block in definitions(original):
            if name in aliases:
                native_bindings.append(dict(kind=kind, name=name, source=block))
            used = [p for p in sorted(raw_paths) if p in block]
            if used:
                compositions.append(dict(kind=kind, name=name, raw_paths=used,
                                         file=path.relative_to(ROOT).as_posix(),
                                         overridden_by_candidate=name in aliases))
    models = []
    for path in sorted((ROOT / 'src').rglob('*')):
        if path.suffix.lower() not in ('.obj', '.mtl', '.modeldef') and path.name.upper() != 'MODELDEF':
            continue
        content = path.read_text(encoding='utf-8-sig')
        used = [p for p in sorted(raw_paths) if p.lower() in content.lower()]
        if used:
            models.append(dict(file=path.relative_to(ROOT).as_posix(), raw_paths=used,
                               sha256=SHA(path.read_bytes()), candidate_changes=False))
    maps = []
    for path in sorted((ROOT / 'src/maps').glob('*.wad')):
        data = path.read_bytes()
        content = textmap(data)
        if content is None:
            maps.append(dict(map=path.name, sha256=SHA(data), format='non-UDMF', inspected=False))
            continue
        counts = Counter(re.findall(r'(?im)\btexture(?:floor|ceiling|top|middle|bottom)\s*=\s*"([^\"]+)"', content))
        uses = {name: counts[name] for name in aliases if counts[name]}
        if uses:
            maps.append(dict(map=path.name, sha256=SHA(data), aliases=uses))
    base_bytes = sum(r['size'][0] * r['size'][1] * 4 for r in exports)
    report = dict(issue=866, source_archive_sha256=provenance['archive_sha256'],
                  scope='Opt-in global aliases in dedicated review sessions; no production replacement or acceptance.',
                  aliases=aliases, binding_count=len(list(definitions(bindings))),
                  source_files_verified=len(provenance['files']), exports=exports,
                  world_repeat_mu=[128, 128], pixels_per_mu=4,
                  budget=dict(export_bytes=sum(r['bytes'] for r in exports),
                              unique_rgba_base_bytes=base_bytes,
                              unique_rgba_full_mips_bytes=8 * sum(4 * n * n for n in (512,256,128,64,32,16,8,4,2,1)),
                              qualification='Decoded unique-image estimate only; aliases may allocate separate textures. Not measured VRAM, driver overhead or an approved production budget.'),
                  original_alias_bindings=native_bindings, raw_image_compositions=compositions,
                  raw_model_consumers=models, map_consumers=maps)
    return report


def build(output):
    report = audit()
    members = {'TEXTURES': (SOURCE / 'TEXTURES_MEJORAS_V3.txt').read_bytes()}
    for row in report['exports']:
        members['graphics/caelum/textures/entornos_v1/mejoradas/' + Path(row['file']).name] = (SOURCE / row['file']).read_bytes()
    output = output.resolve()
    output.relative_to(ROOT / 'build')
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, 'x') as package:
        for name, data in sorted(members.items()):
            package.writestr(zipfile.ZipInfo(name, (2026, 11, 21, 0, 0, 0)), data)
    report['overlay'] = dict(sha256=SHA(output.read_bytes()), bytes=output.stat().st_size,
                             members={n: SHA(b) for n, b in sorted(members.items())})
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--inventory', type=Path, required=True)
    args = parser.parse_args()
    result = build(args.output)
    with args.inventory.open('x', encoding='utf-8', newline='\n') as stream:
        stream.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(overlay=result['overlay']['sha256'], aliases=result['aliases'], maps=len(result['map_consumers']), raw_models=len(result['raw_model_consumers']), verified=result['source_files_verified'])))
