"""Integrate the measured Value-only candidate and assign its patch version."""
from pathlib import Path
import hashlib, json, re, subprocess, sys

root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue864-contact-settlement'
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()=='e9bd0915dde87dd9d451371dfbfa7aa119f63de1'
checks=json.loads((root/'build/issue864-value-checks03/RESULTS.json').read_text())
assert checks['passed'] and not checks['errors']
candidate=root/'build/issue864-value02'
manifest=json.loads((candidate/'manifest.json').read_text())
path='caelum/survival/CaelumContaminationState.zs';target=root/'src'/path
assert hashlib.sha256(target.read_bytes()).hexdigest()==manifest['original_sha256']
data=(candidate/'source'/path).read_bytes()
assert hashlib.sha256(data).hexdigest()==manifest['candidate_sha256']
target.write_bytes(data)
for name in ('AGENTS.md','docs/ASSETS.md','docs/CONTEXT.md','docs/HISTORY.md','docs/MAP01.txt','docs/PROJECT.md','docs/SPRITE_ART_DIRECTION.md','docs/SYSTEMS.md','docs/TASKS.md'):
    p=root/name;s=p.read_text(encoding='utf-8')
    head,n=re.subn(r'(Documentation version:\s*\*\*)5\.17\.109(\*\*\s*-\s*)2026-11-19',r'\g<1>5.17.110\g<2>2026-11-21',s[:1000],count=1)
    assert n==1,name
    p.write_text(head+s[1000:],encoding='utf-8',newline='\n')
p=root/'README.md';s=p.read_text(encoding='utf-8');assert s.count('**Current release: 5.17.109.**')==1
p.write_text(s.replace('**Current release: 5.17.109.**','**Current release: 5.17.110.**'),encoding='utf-8',newline='\n')
for name in ('CaelumPhysicalHazards.zs','CaelumSewerMaze.zs'):
    p=root/'src/caelum/world'/name;raw=p.read_bytes();assert raw.count(b'5.17.109')==1,name
    p.write_bytes(raw.replace(b'5.17.109',b'5.17.110'))
subprocess.run([sys.executable,'build_document_index.py'],cwd=root,check=True,stdout=subprocess.DEVNULL)
print('Integrated exact candidate02; current headers and release diagnostics are5.17.110.')
