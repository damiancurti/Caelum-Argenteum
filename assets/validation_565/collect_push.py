"""Collect the author-reported chest push correction and its focused regression."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue382'
LABELS=['push-fixed-01','push-controls-01','push-save-01','push-reload-01']

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def redact(value):
    if isinstance(value,list):return [redact(v) for v in value]
    if isinstance(value,dict):return {k:redact(v) for k,v in value.items()}
    if not isinstance(value,str):return value
    value=value.replace(str(ROOT),'<repo>')
    value=value.replace(r'C:\Program Files (x86)\GZDoom\gzdoom.exe','<engine>')
    return re.sub(r'C:\\Program Files \(x86\)\\Steam[^"\r\n]*DOOM2\.WAD','<iwad>',value,flags=re.I)

current=WORK/'current/caelum_argenteum_dev.pk3'
previous=WORK/'pre-push-fix/caelum_argenteum_dev.pk3'
current_hash=sha(current)
runs=[]
for label in ['push-before-01']+LABELS:
    log_path=WORK/(label+'.txt')
    log=log_path.read_text(encoding='utf-8',errors='replace')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    failures=len(re.findall(r'CA382 FAIL ',log))
    assert failures==(1 if label=='push-before-01' else 0),label
    assert record['exit_code']==0 and not record.get('timed_out'),label
    assert not re.search(r'Script error|VM execution aborted',log),label
    assert record['package_sha256'].lower()==(sha(previous) if label=='push-before-01' else current_hash),label
    runs.append(dict(label=label,passes=len(re.findall(r'CA382 PASS ',log)),failures=failures,
                     record=redact(record),raw_log_sha256=sha(log_path)))
    clean='\n'.join(line.rstrip() for line in redact(log).splitlines()).rstrip()+'\n'
    (HERE/(label+'.txt')).write_text(clean,encoding='utf-8')

with zipfile.ZipFile(previous) as before,zipfile.ZipFile(current) as after,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
    assert set(before.namelist())==set(after.namelist())==set(normal.namelist())
    changed=[n for n in after.namelist() if before.read(n)!=after.read(n)]
    assert sorted(changed)==['caelum/actors/CaelumCombatActor.zs','caelum/player/CaelumPlayer.zs'],changed
    for name in after.namelist():
        assert after.read(name)==normal.read(name),name
        assert after.read(name).replace(b'\r\n',b'\n')==(ROOT/'src'/name).read_bytes().replace(b'\r\n',b'\n'),name
    sources={n:hashlib.sha256(after.read(n)).hexdigest() for n in changed}

check=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8')
assert check.returncode==0,check.stdout+check.stderr
validation=json.loads(check.stdout)
assert not validation['errors']
(HERE/'push-project-validation.json').write_text(json.dumps(validation,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
report=dict(issue=382,version='5.6.5',baseline_commit='59f9844c',baseline_package_sha256=sha(previous),
            package_sha256=current_hash,runs=runs,passing_runs=len(LABELS),
            passes=sum(r['passes'] for r in runs if not r['failures']),changed_runtime_members=sources,
            independent_review='Both guards and zeroed uppercut impulse reviewed statically; no outstanding P1/P2.',
            author_status='Reported chest push defect; corrected retest pending')
(HERE/'push-report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f"{len(LABELS)} focused passing runs, {report['passes']} assertions; original movement failure reproduced.")
