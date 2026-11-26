"""Run one current-runtime contact profile with the retained siege observer."""
from pathlib import Path
import json, re, subprocess, sys

root = Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
layer = Path('C:/GZDooMProjects/CaelumArgenteum/build/v515/tools/presentation')
active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace')
assert 'gzdoom.exe' not in active.lower(),'Another native engine is running'
label = sys.argv[1] if len(sys.argv) > 1 else 'deep01'
profile = root/f'build/issue868-{label}'
assert (profile/'services.pk3').is_file()
logpath = root/f'build/issue868-{label}-run.log'
assert not logpath.exists()
command = [sys.executable, 'assets/validation_v5_16_2/run_barracas_presentation.py',
    '--runtime', 'build/issue866-review01.pk3', '--map', 'MAP03', '--players', '1',
    '--siege', '--presentation-layer', str(layer), '--overlay', str(profile/'services.pk3')]
with logpath.open('wb') as log:
    result = subprocess.run(command, cwd=root, stdout=log, stderr=log)
assert result.returncode == 0, f'Read {logpath}'
log = logpath.read_text(encoding='utf-8')
directory = Path(re.search(r'Campaign peers started: (.+)', log)[1].strip())
directory.relative_to(root)
run = json.loads((directory/'results.json').read_text())
assert run['passed'], f'Read {directory}/results.json'
for suffix, arguments in (
    ('queue', ['assets/validation_v5_12_7/analyze_vulkan_presents.py', str(directory)]),
    ('analysis', ['assets/validation_v5_17_104/analyze_services.py', '--profile', str(profile),
        '--run', str(directory), '--output', str(root/f'build/issue868-{label}-analysis.json')]),
):
    with (root/f'build/issue868-{label}-{suffix}.log').open('wb') as log:
        subprocess.run([sys.executable, *arguments], cwd=root, stdout=log, stderr=log, check=True)
row = dict(label=label, directory=directory.relative_to(root).as_posix(), runtime_sha256=run['runtime_sha256'],
    engine=run['engine'], layer=run['presentation_layer'], states=run['peers'][0]['states'],
    census=run['peers'][0]['census'], simulation=run['peers'][0]['simulation'],
    presentation=json.loads((directory/'presentation.json').read_text())['peers'][0])
(root/f'build/issue868-{label}-summary.json').write_text(json.dumps(row, indent=2)+'\n', encoding='utf-8')
print(json.dumps(dict(label=label, directory=row['directory'], passed=True)))
