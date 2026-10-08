"""Bind final #135 source, native packages and selected passing evidence."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,subprocess,zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
runtime={p.relative_to(ROOT/'src').as_posix():sha(p) for p in sorted((ROOT/'src').rglob('*')) if p.is_file()}
tree=hashlib.sha256(json.dumps(runtime,sort_keys=True,separators=(',',':')).encode()).hexdigest()
packages={}
for relative in ('build/caelum_argenteum_dev.pk3','build/issue135/production.pk3'):
    path=ROOT/relative
    with zipfile.ZipFile(path) as z:
        payload={n:hashlib.sha256(z.read(n)).hexdigest() for n in z.namelist() if not n.endswith('/')}
    assert payload==runtime,relative
    packages[relative]={'sha256':sha(path),'files':len(payload),'matches_final_src':True}
(HERE/'BUILD.json').write_text(json.dumps({'command':'powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1',
    'exit_code':0,'packages':packages,'checked_utc':datetime.now(timezone.utc).isoformat()},indent=2)+'\n',encoding='utf-8')
labels=['potions-final-a','potions-reload-final-a','consumption-b','breath-art-b','integration-art-a',
    'ability-reload-art-a','ability-hub-art-a','migration-seed-final','migration-upgrade-final',
    'migration-hub-final','migration-rollback-final','visuals-art-c','orientation-fixed-a',
    'cost-0-final','cost-4-final','cost-16-final']
for label in labels:
    record=json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0,label
changed=subprocess.check_output(['git','diff','--name-only','5f9202ad42f3dd0750f5368e2e15b28d98fac4a5','--','src'],cwd=ROOT,text=True).splitlines()
changed+=subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'],cwd=ROOT,text=True).splitlines()
report={'release':'5.1.5','issue':135,'baseline':'5f9202ad42f3dd0750f5368e2e15b28d98fac4a5',
    'runtime_tree_sha256':tree,'runtime_file_count':len(runtime),'packages':packages,'passing_native_labels':labels,
    'changed_runtime':{p:sha(ROOT/p) for p in sorted(set(changed))},
    'evidence':{p.name:sha(p) for p in sorted(HERE.iterdir()) if p.is_file() and p.name!='MANIFEST.json'}}
(HERE/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f'PASS: {len(runtime)} final source files match both packages; {len(labels)} clean native runs bound.')
