"""Preserve only the affected #479 floating-Orb validation and original art."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / 'assets/validation_578'
WORK = ROOT / 'build/issue479'
ART = ROOT / 'assets/art_source/support_sprites'
LABEL = 'floating-orb-01'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


package = WORK / 'current/caelum_argenteum_dev.pk3'
sources = {p.relative_to(ROOT / 'src').as_posix(): p for p in (ROOT / 'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist()) == set(sources)
    for name, path in sources.items():
        assert archive.read(name) == path.read_bytes(), name
art_hash = digest(ART / 'MANIFEST.json')
subprocess.run([sys.executable, str(ROOT / 'assets/generators/pack_support_sprites.py')], check=True)
assert art_hash == digest(ART / 'MANIFEST.json')
manifest = json.loads((ART / 'MANIFEST.json').read_text(encoding='utf-8'))
protected = {}
for section in ('inputs', 'outputs'):
    for name, expected in manifest[section].items():
        assert digest(ROOT / name) == expected, name
        if name.startswith('src/') and name.endswith('.png') and '/orb_' not in name:
            assert (ROOT / name).read_bytes() == subprocess.check_output(['git', 'show', f'ee99a337:{name}'], cwd=ROOT), name
            protected[name] = expected

meta = json.loads((WORK / f'{LABEL}-run.json').read_text(encoding='utf-8-sig'))
log = (WORK / f'{LABEL}.txt').read_text(encoding='utf-8', errors='replace')
assert meta['exit_code'] == 0 and not meta.get('timed_out')
assert meta['package_sha256'].lower() == digest(package)
assert meta['addon_sha256'].lower() == digest(WORK / 'fixture.pk3')
assert not re.search(r'CA479 FAIL|Script error|VM execution aborted|Unknown command|not flagged for use', log)
assert 'Orb uses active appearance palm variant=18' in log
count = len(re.findall(r'^CA479 PASS ', log, re.M))
assert count == 23, count
for suffix in ('.txt', '-run.json'):
    shutil.copyfile(WORK / (LABEL + suffix), HERE / 'native' / (LABEL + suffix))

sheet = Image.new('RGB', (1280, 800), (24, 24, 26))
draw = ImageDraw.Draw(sheet)
captures = {}
for tier in range(3):
    for column, mode in enumerate(('world', 'inventory', 'action', 'return')):
        name = f'{LABEL}-art-orb-{mode}-{tier}.png'
        captures[name] = digest(WORK / name)
        image = Image.open(WORK / name).convert('RGB')
        image.thumbnail((320, 180))
        sheet.paste(image, (column * 320, tier * 200 + 20))
        draw.text((column * 320 + 4, tier * 200 + 4), f'Orb T{tier + 1}: {mode}', fill='white')
for column, kind in enumerate(('book-return', 'orb-female')):
    name = f'{LABEL}-art-{kind}.png'
    captures[name] = digest(WORK / name)
    image = Image.open(WORK / name).convert('RGB')
    image.thumbnail((320, 180))
    sheet.paste(image, (column * 320, 620))
    draw.text((column * 320 + 4, 604), kind, fill='white')
for name in (f'{LABEL}-art-orb-world-0.png', f'{LABEL}-art-orb-inventory-2.png', f'{LABEL}-art-orb-female.png'):
    shutil.copyfile(WORK / name, HERE / 'visuals' / name)
sheet.save(HERE / 'visuals/floating-orb-contact.png')
report = {
    'issue': 479, 'release': '5.7.8', 'date': '2026-10-22',
    'status': 'five other designs visually accepted; floating Orb awaits author review; CA479-01 remains pending',
    'package_sha256': digest(package), 'source_entries': len(sources), 'source_bytes_match': True,
    'fixture_sha256': digest(WORK / 'fixture.pk3'), 'native_pass': count, 'native_fail': 0, 'exit_code': 0,
    'art_manifest_sha256': art_hash, 'registration_byte_identical_twice': True,
    'protected_original_images': protected, 'captures': captures,
    'scope': 'Three Orb tiers, inventory, primary/return, Book switch, 38 palm states, active male/female palm and Book pivot.',
    'limits': 'Presentation-only correction; previous gameplay and other visual evidence retained. No new performance or author gameplay acceptance claim.',
}
(HERE / 'floating_orb_report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({key: report[key] for key in ('package_sha256', 'source_entries', 'native_pass', 'native_fail')}, indent=2))
