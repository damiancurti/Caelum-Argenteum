"""Verify unchanged declarations and the exact baseline-to-service move."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile
from audit_sources import declarations, mask

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
BASE = '20143c3154617309912a493fa2a7be3c7c2c9ff4'
path = 'src/caelum/player/CaelumPlayer.zs'
old = subprocess.check_output(['git','show',f'{BASE}:{path}'], cwd=ROOT).decode('utf-8')
new = (ROOT/path).read_text(encoding='utf-8')
service = (ROOT/'src/caelum/player/CaelumPlayerPresentation.zs').read_text(encoding='utf-8')
before = next(c for c in declarations(old) if c['name']=='CaelumPlayer')
after = next(c for c in declarations(new) if c['name']=='CaelumPlayer')
helper = declarations(service)[0]
assert [f['declaration'] for f in before['fields']] == [f['declaration'] for f in after['fields']]
assert [m['signature'] for m in before['methods']] == [m['signature'] for m in after['methods']]
assert not helper['fields'], 'The helper must not introduce state'
moved=[]
for prior,current in zip(before['methods'],after['methods']):
    left=old[prior['body_start']:prior['body_end']+1]
    right=new[current['body_start']:current['body_end']+1]
    if left==right: continue
    name=prior['name']
    assert right == '{\n        CaelumPlayerPresentation.'+name+'(self);\n    }', name
    target=next(m for m in helper['methods'] if m['name']==name)
    body=service[target['body_start']:target['body_end']+1]
    restored=re.sub(r'\buser\.', '', body)
    restored=re.sub(r'\buser\b', 'self', restored)
    assert re.sub(r'\s+', '', mask(left))==re.sub(r'\s+', '', mask(restored)), name
    moved.append(name)
assert moved==['RefreshSocialJournalSnapshot','SyncHUDActiveWeaponState','SyncHUDLoadState']
with zipfile.ZipFile(ROOT/'build/issue116/baseline.pk3') as baseline, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as current:
    removed=set(baseline.namelist())-set(current.namelist())
    added=set(current.namelist())-set(baseline.namelist())
    changed=sorted(n for n in baseline.namelist() if n in current.namelist() and baseline.read(n)!=current.read(n))
    assert not removed
    assert added=={'caelum/player/CaelumPlayerPresentation.zs'}
    assert changed==['ZSCRIPT','caelum/player/CaelumPlayer.zs','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
    for name in changed[2:]:
        assert baseline.read(name).decode('utf-8').replace('4.37.24','5.0.0').replace('\r\n','\n')==current.read(name).decode('utf-8').replace('\r\n','\n'),name
report={'baseline':BASE,'unchanged_player_field_declarations':len(before['fields']),
        'unchanged_player_method_signatures':len(before['methods']), 'moved_methods':moved,
        'new_service_fields':0, 'runtime_members_added':sorted(added),'runtime_members_changed':changed,
        'diagnostic_only_version_updates':changed[2:],
        'runtime_members_removed':sorted(removed),
        'final_package_sha256':hashlib.sha256((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()).hexdigest(),
        'result':'PASS'}
(HERE/'EXTRACTION.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2))
