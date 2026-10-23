"""Collect bounded native evidence for the author's #479 sprite correction."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WORK = ROOT / 'build/issue479'
ART = ROOT / 'assets/art_source/support_sprites'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


package = WORK / 'current/caelum_argenteum_dev.pk3'
package_hash = digest(package)
sources = {p.relative_to(ROOT / 'src').as_posix(): p
           for p in (ROOT / 'src').rglob('*') if p.is_file()}
with zipfile.ZipFile(package) as archive:
    assert set(archive.namelist()) == set(sources), 'Package membership differs'
    for name, path in sources.items():
        assert archive.read(name) == path.read_bytes(), name

fixture_hash = digest(WORK / 'fixture.pk3')
subprocess.run([sys.executable, str(HERE / 'prepare.py')], check=True)
assert digest(WORK / 'fixture.pk3') == fixture_hash
manifest_hash = digest(ART / 'MANIFEST.json')
subprocess.run([sys.executable, str(ROOT / 'assets/generators/pack_support_sprites.py')], check=True)
assert digest(ART / 'MANIFEST.json') == manifest_hash
manifest = json.loads((ART / 'MANIFEST.json').read_text(encoding='utf-8'))
for section in ('inputs', 'outputs'):
    for name, expected in manifest[section].items():
        assert digest(ROOT / name) == expected, name

protected = {}
for family in ('book', 'statuette'):
    paths = list((ROOT / f'src/sprites/caelum/first_person/v1/{family}').glob('*.png'))
    paths += list((ROOT / 'src/graphics/caelum/icons').glob(f'ca_{family}*.png'))
    for path in paths:
        name = path.relative_to(ROOT).as_posix()
        original = subprocess.check_output(['git', 'show', f'87089226:{name}'], cwd=ROOT)
        assert path.read_bytes() == original, name
        protected[name] = digest(path)

runs = []
for label, expected_count in [('painted-final-gallery3', 41), ('painted-final-controls', 14), ('painted-actions', 20)]:
    log = (WORK / f'{label}.txt').read_text(encoding='utf-8', errors='replace')
    meta = json.loads((WORK / f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert meta['exit_code'] == 0 and not meta.get('timed_out'), label
    assert meta['package_sha256'].lower() == package_hash, label
    assert meta['addon_sha256'].lower() == fixture_hash, label
    assert 'CA479 RESULT' in log and not re.search(
        r'CA479 FAIL|Script error|VM execution aborted|Unknown command|not flagged for use', log), label
    count = len(re.findall(r'^CA479 PASS ', log, re.M))
    assert count == expected_count, (label, count)
    for suffix in ('.txt', '-run.json'):
        shutil.copyfile(WORK / (label + suffix), HERE / 'native' / (label + suffix))
    if meta.get('chained_script'):
        assert digest(Path(meta['chained_script']['file'])) == meta['chained_script']['sha256'].lower()
    runs.append({'label': label, 'pass': count, 'fail': 0, 'exit_code': 0,
                 'log_sha256': digest(WORK / f'{label}.txt')})

visuals = HERE / 'visuals'
screenshots = {}
names = ('Scepter', 'Orb', 'Book (original)', 'Censer', 'Statuette (original)', 'Effigy')
for mode in ('world', 'inventory'):
    # Review sheets retain every native view; crops only expose the inventory row.
    size = (384, 236) if mode == 'world' else (620, 74)
    sheet = Image.new('RGB', (size[0] * 3, size[1] * 6), (24, 24, 26))
    draw = ImageDraw.Draw(sheet)
    for i in range(18):
        name = f'painted-final-gallery3-art-{mode}-{i:02}.png'
        screenshots[name] = digest(WORK / name)
        frame = Image.open(WORK / name).convert('RGB')
        if mode == 'inventory':
            frame = frame.crop((343, 333, 943, 382))
        else:
            frame.thumbnail((384, 216))
        x, y = i % 3 * size[0], i // 3 * size[1]
        sheet.paste(frame, (x, y + 20))
        draw.text((x + 4, y + 3), f'{names[i // 3]} T{i % 3 + 1}', fill='white')
        if i in (0, 6, 12, 17):
            shutil.copyfile(WORK / name, visuals / name)
    assert len({screenshots[f'painted-final-gallery3-art-{mode}-{i:02}.png'] for i in range(18)}) == 18
    sheet.save(visuals / f'painted-{mode}-contact.png')

sheet = Image.new('RGB', (1152, 1416), (24, 24, 26))
draw = ImageDraw.Draw(sheet)
for i, family in enumerate(names):
    for column, mode in enumerate(('action', 'block', 'return')):
        name = f'painted-actions-art-{mode}-{i:02}.png'
        screenshots[name] = digest(WORK / name)
        frame = Image.open(WORK / name).convert('RGB')
        frame.thumbnail((384, 216))
        sheet.paste(frame, (column * 384, i * 236 + 20))
        draw.text((column * 384 + 4, i * 236 + 3), f'{family} T1: {mode}', fill='white')
sheet.save(visuals / 'painted-actions-contact.png')

# Preserve failed harness diagnostics separately; none is a production pass.
for label in ('painted-final-gallery', 'painted-final-gallery2'):
    for suffix in ('.txt', '-run.json'):
        shutil.copyfile(WORK / (label + suffix), HERE / 'diagnostics' / (label + suffix))

report = {
    'issue': 479, 'release': '5.7.8', 'date': '2026-10-22',
    'status': 'painted correction; author check CA479-01 pending',
    'package_sha256': package_hash, 'source_entries': len(sources), 'source_bytes_match': True,
    'fixture_sha256': fixture_hash, 'fixture_deterministic': True,
    'art_manifest_sha256': manifest_hash, 'art_registration_byte_identical_twice': True,
    'protected_original_images': protected,
    'runs': runs, 'native_assertions': sum(run['pass'] for run in runs),
    'gallery_capture_sha256': screenshots,
    'visual_review': '18 native world/held views, 18 actual Journal inventory rows and six T1 primary/block/return sequences; agent inspection only.',
    'previous_evidence': 'final_report.json records the pre-correction runtime package, retained under build/issue479/pre-sprite.',
    'limits': ['No gameplay/balance changes or full gameplay rerun in this visual correction.',
               'Initial procedural art was rejected; new art is not author-accepted.',
               'No frame-presentation or large-map performance claim.'],
}
(HERE / 'painted_report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({key: report[key] for key in ('status', 'package_sha256', 'source_entries', 'native_assertions')}, indent=2))
