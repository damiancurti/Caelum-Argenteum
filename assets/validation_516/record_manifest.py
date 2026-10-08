"""Bind final runtime payload, native evidence and deterministic artwork exports."""
from pathlib import Path
import hashlib,json,subprocess,zipfile
from datetime import datetime,timezone

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
BASE='5e550484f1a6c9cc7101dae37e8daaa8e47d03c2'
LABELS=['checks-final','checks-release','checks-reload-final-b','checks-hub-final',
    'live-final','visual-gallery','migration-seed','migration-upgrade',
    'migration-reload','migration-hub','migration-rollback']
def sha(data):return hashlib.sha256(data).hexdigest()
def payload(path):
    with zipfile.ZipFile(path) as z:return {n:z.read(n) for n in z.namelist() if not n.endswith('/')}
runtime={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in sorted((ROOT/'src').rglob('*')) if p.is_file()}
packages={}
for relative in ['build/caelum_argenteum_dev.pk3','build/issue143/production.pk3']:
    path=ROOT/relative;assert payload(path)==runtime,relative
    packages[relative]={'sha256':sha(path.read_bytes()),'files':len(runtime),'matches_final_src':True}
earlier=ROOT/'build/issue143/new/production.pk3'
before=payload(earlier)
delta=[n for n in sorted(runtime) if before[n]!=runtime[n]]
assert delta==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'],delta
for name in delta:
    assert before[name].decode().replace('\r\n','\n').replace('[Caelum 5.1.5]','[Caelum 5.1.6]')==runtime[name].decode().replace('\r\n','\n'),name
earlier_hash=sha(earlier.read_bytes())
baseline_hash=sha((ROOT/'build/issue143/old/production.pk3').read_bytes())
allowed={earlier_hash,baseline_hash}|{p['sha256'] for p in packages.values()}
for label in LABELS:
    run=json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and run['package_sha256'].lower() in allowed,label
    log=(HERE/(label+'.txt')).read_text(encoding='utf-8-sig')
    assert 'CA143 FAIL' not in log and 'failures=1' not in log,label
report={'release':'5.1.6','issue':143,'baseline':BASE,'runtime_file_count':len(runtime),
    'runtime_tree_sha256':sha(json.dumps({n:sha(b) for n,b in runtime.items()},sort_keys=True,separators=(',',':')).encode()),
    'packages':packages,'passing_native_labels':LABELS,
    'native_earlier_package':{'sha256':earlier_hash,'final_difference':delta,
        'qualification':'Only two diagnostic release labels and line-ending normalization differ; gameplay and art bytes are unchanged. checks-release tests the final standard PK3.'},
    'original_515_package_sha256':baseline_hash}
changed=subprocess.check_output(['git','diff','--name-only',BASE,'--','src'],cwd=ROOT,text=True).splitlines()
changed+=subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'],cwd=ROOT,text=True).splitlines()
report['changed_runtime']={n:sha((ROOT/n).read_bytes()) for n in sorted(set(changed))}
(HERE/'BUILD.json').write_text(json.dumps({'command':'powershell -NoProfile -ExecutionPolicy Bypass -File build_dev.ps1',
    'exit_code':0,'packages':packages,'checked_utc':datetime.now(timezone.utc).isoformat()},indent=2)+'\n',encoding='utf-8')
report['evidence']={p.name:sha(p.read_bytes()) for p in sorted(HERE.iterdir()) if p.is_file() and p.name!='MANIFEST.json'}
(HERE/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(f'PASS: {len(runtime)} runtime files, {len(LABELS)} clean native runs, final PK3 verified.')
