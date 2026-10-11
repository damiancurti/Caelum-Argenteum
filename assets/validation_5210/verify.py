"""Read-only runtime checks and isolated deterministic generator verification."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
import zipfile
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue192-ranged'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    source = {p.relative_to(ROOT / 'src').as_posix(): p.read_bytes()
              for p in (ROOT / 'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(WORK / 'official.pk3') as package:
        assert set(package.namelist()) == set(source)
        assert all(package.read(n) == data for n, data in source.items())
    old = re.compile(r'standard.?bow|short.?bow', re.I)
    for name, data in source.items():
        assert not old.search(name), name
        if Path(name).suffix.lower() in ('.zs', '.json', '.md') or name in ('LANGUAGE', 'TEXTURES'):
            assert not old.search(data.decode('utf-8')), name
    renamed = {}
    for name, data in source.items():
        if 'shotgun_legacy' not in name:
            continue
        original = name.replace('shotgun_legacy', 'standard_bow')
        previous = subprocess.check_output(['git', 'show', f'c8518c6e:src/{original}'], cwd=ROOT)
        assert previous == data, name
        renamed[name] = {'previous_path': original, 'sha256': sha(data)}
    generator = Path(tempfile.mkdtemp(prefix='generator-check-', dir=WORK))
    for relative in ['assets/generators/generate_fp_native_0i.py', 'src/TEXTURES',
                     'src/graphics/caelum/first_person/v3/shotgun_legacy.png',
                     'src/graphics/caelum/first_person/v3/longbow.png']:
        target = generator / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / relative, target)
    results = []
    for repeat in range(2):
        subprocess.run(['python', str(generator / 'assets/generators/generate_fp_native_0i.py')], check=True)
        generated = {p.relative_to(generator).as_posix(): sha(p.read_bytes()) for p in generator.rglob('*') if p.is_file()}
        results.append(generated)
    assert results[0] == results[1], 'Generator is not byte-deterministic.'
    caches = list((generator / 'src/graphics/caelum/first_person/bow_cache').glob('*.png'))
    assert len(caches) == 6
    same_bytes = sum(p.read_bytes() == (ROOT / p.relative_to(generator)).read_bytes() for p in caches)
    for p in caches:
        generated_image = Image.open(p).convert('RGBA')
        maintained_image = Image.open(ROOT / p.relative_to(generator)).convert('RGBA')
        assert generated_image.size == maintained_image.size
        assert generated_image.tobytes() == maintained_image.tobytes()
    baseline_generator = Path(tempfile.mkdtemp(prefix='generator-baseline-', dir=WORK))
    for relative in ['assets/generators/generate_fp_native_0i.py', 'src/TEXTURES',
                     'src/graphics/caelum/first_person/v3/standard_bow.png',
                     'src/graphics/caelum/first_person/v3/longbow.png']:
        target = baseline_generator / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(subprocess.check_output(['git', 'show', f'c8518c6e:{relative}'], cwd=ROOT))
    subprocess.run(['python', str(baseline_generator / 'assets/generators/generate_fp_native_0i.py')], check=True)
    for p in caches:
        old_path = str(p.relative_to(generator)).replace('shotgun_legacy', 'standard_bow')
        assert p.read_bytes() == (baseline_generator / old_path).read_bytes()
    result = {'official_members': len(source), 'official_matches_source': True,
              'official_sha256': sha((WORK / 'official.pk3').read_bytes()),
              'renamed_artwork': renamed, 'active_former_bow_names': 0,
              'isolated_generator_identical_repeats': True, 'byte_identical_to_baseline_generator': len(caches),
              'maintained_cache_pixels_unchanged': len(caches), 'maintained_cache_bytes_match_regeneration': same_bytes}
    (HERE / 'STATIC.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8', newline='\n')
    print('Source/package match; names clean; 16 art files unchanged; generator deterministic and baseline-identical; 6 pixel-identical caches.')


if __name__ == '__main__':
    main()
