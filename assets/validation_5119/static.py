"""Read-only catalogue/package checks plus deterministic generator verification."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
rows = json.loads((ROOT / 'assets/dialogue_history.json').read_text())['entries']
source = (ROOT / 'src/CAPALOMO').read_text(encoding='utf-8')
old = subprocess.check_output(['git', 'show', '4248dfce:src/CAPALOMO'], cwd=ROOT).decode('utf-8')
checks = {'native_dialogues_unchanged': source == old}
checks['unique_keys'] = len({(r['source'], r['reply']) for r in rows}) == len(rows)
language = (ROOT / 'src/LANGUAGE').read_text(encoding='utf-8')
checks['bilingual_answers'] = all(len(re.findall(r'^' + re.escape(r['answer'][1:]) + r'\s*=', language, re.M)) >= 2 for r in rows)
parents = {}
for p in (ROOT / 'src/caelum').rglob('*.zs'):
    parents.update(re.findall(r'class\s+(\w+ConversationMenu)\s*:\s*(\w+)', p.read_text(encoding='utf-8-sig')))
def inherits(name):
    return name == 'CaelumHistoryConversationMenu' or name in parents and inherits(parents[name])
checks['all_menus_share_history'] = all(inherits(c) for c in re.findall(r'\bclass\s*=\s*"([^"]+)"', source))
generated = ROOT / 'src/caelum/dialogue/CaelumDialogueHistoryData.zs'
before = generated.read_bytes()
subprocess.run(['python', str(ROOT / 'assets/generators/generate_dialogue_history.py')], check=True)
checks['deterministic_catalogue'] = before == generated.read_bytes()
package = ROOT / 'build/issue172/production.pk3'
with zipfile.ZipFile(package) as z, zipfile.ZipFile(ROOT / 'build/caelum_argenteum_dev.pk3') as built:
    checks['source_matches_native_package'] = all(z.read(p.relative_to(ROOT / 'src').as_posix()) == p.read_bytes() for p in (ROOT / 'src').rglob('*') if p.is_file())
    checks['standard_build_matches'] = set(z.namelist()) == set(built.namelist()) and all(z.read(n) == built.read(n) for n in z.namelist())
result = dict(checks=checks, catalogue_entries=len(rows), production_sha256=hashlib.sha256(package.read_bytes()).hexdigest())
(ROOT / 'build/issue172/static.json').write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
print(json.dumps(result, indent=2))
assert all(checks.values())
