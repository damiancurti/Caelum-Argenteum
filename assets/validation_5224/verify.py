"""Check generated carrier coverage and byte-for-byte regeneration stability."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUTPUTS = ['src/maps/MAP02.wad', 'src/caelum/world/CaelumMazeLayout.zs',
           'src/caelum/world/CaelumMazeLootCatalogue.zs',
           'assets/map02_maze/MAP02_MANIFEST.json']


def hashes():
    return {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
            for name in OUTPUTS}


before = hashes()
for _ in range(2):
    subprocess.run(['python', 'assets/generators/generate_map02_maze.py'],
                   cwd=ROOT, check=True, capture_output=True)
    assert hashes() == before, 'Regeneration changed checked outputs'
manifest = json.loads((ROOT / OUTPUTS[3]).read_text(encoding='utf-8'))
expected = {d['tid'] for d in manifest['drops']}
source = (ROOT / OUTPUTS[1]).read_text(encoding='utf-8')
predicate = source.split('static bool HasDeathDrop(int tid)', 1)[1].split('}', 1)[0]
actual = set()
for token in predicate.split('return ', 1)[1].rstrip(';').split(' || '):
    single = re.fullmatch(r'tid==(\d+)', token)
    span = re.fullmatch(r'\(tid>=(\d+) && tid<=(\d+)\)', token)
    assert single or span, token
    actual.update([int(single[1])] if single else range(int(span[1]), int(span[2]) + 1))
branches = [int(n) for n in re.findall(r'if\(tid==(\d+)\)\{item=', source)]
assert actual == expected == set(branches)
assert len(branches) == len(expected)
report = dict(deterministic_runs=2, assigned_mandingas=sum(47000 <= n < 47096 for n in actual),
              assigned_rats=sum(48000 <= n < 48192 for n in actual), outputs=before)
(Path(__file__).parent / 'static-results.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
