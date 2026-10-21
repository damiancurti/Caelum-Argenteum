"""Collect focused lock evidence without distributing private runtimes or saves."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue382'
LABELS=['final-suite','final-visibility','final-house-migration','final-save','final-reload',
        'final-travel','final-hub','final-house','final-upgrade','final-upgraded-reload',
        'baseline-save-01','final-baseline-upgrade','final-baseline-reload',
        'baseline-rollback-01','legacy-save-01','legacy-rollback-01',
        'final-ui','final-ui-en','final-attack','final-author-check']

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def redact(text):
    text=text.replace(str(ROOT),'<repo>').replace(str(ROOT).replace('\\','/'),'<repo>')
    text=re.sub(r'C:\\Program Files \(x86\)\\Steam[^"\r\n]*DOOM2\.WAD','<iwad>',text,flags=re.I)
    text=text.replace(r'C:\Program Files (x86)\GZDoom\gzdoom.exe','<engine>')
    return text

def clean(value):
    if isinstance(value,str):return redact(value)
    if isinstance(value,list):return [clean(v) for v in value]
    if isinstance(value,dict):return {k:clean(v) for k,v in value.items()}
    return value

package=WORK/'current/caelum_argenteum_dev.pk3'
package_hash=sha(package)
runs=[]
for label in LABELS:
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    assert record['exit_code']==0 and not record.get('timed_out'),label
    assert not re.search(r'CA382 FAIL|Script error|VM execution aborted',log),label
    if record['runtime']=='current':assert record['package_sha256'].lower()==package_hash,label
    count=len(re.findall(r'CA382 PASS ',log))
    assert count>0 or label in ('final-ui','final-ui-en'),label
    runs.append(dict(label=label,passes=count,record=clean(record),raw_log_sha256=sha(WORK/(label+'.txt'))))
    (HERE/(label+'.txt')).write_text(redact(log),encoding='utf-8')

# Preserve failed experiments separately; they are not counted as successful gates.
experiments={}
for label in ['suite-01','suite-02','hub-01','hub-02','visibility-02',
              'author-check-02','author-check-03','attack-01','attack-02']:
    path=WORK/(label+'.txt')
    log=path.read_text(encoding='utf-8',errors='replace')
    experiments[label]=dict(passes=len(re.findall(r'CA382 PASS ',log)),
                           failures=len(re.findall(r'CA382 FAIL ',log)),raw_log_sha256=sha(path))
    (HERE/(label+'.txt')).write_text(redact(log),encoding='utf-8')

with zipfile.ZipFile(package) as tested,zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
    assert set(tested.namelist())==set(normal.namelist())
    source_hashes={}
    for name in tested.namelist():
        assert tested.read(name)==normal.read(name),name
        source=(ROOT/'src'/name).read_bytes()
        assert source.replace(b'\r\n',b'\n')==tested.read(name).replace(b'\r\n',b'\n'),name
    with zipfile.ZipFile(WORK/'legacy/caelum_argenteum_dev.pk3') as previous:
        changed=[n for n in tested.namelist() if n not in previous.namelist() or tested.read(n)!=previous.read(n)]
    source_hashes={n:hashlib.sha256(tested.read(n)).hexdigest() for n in changed}

result=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8')
assert result.returncode==0,result.stdout+result.stderr
validation=json.loads(result.stdout)
assert not validation['errors'],validation['errors']
(HERE/'project-validation.json').write_text(json.dumps(validation,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
report=dict(issue=382,version='5.6.5',baseline_commit='cee86040',
            original_baseline_commit='92be078e7ee2902a98f2c29603717a35b51647a8',
            package_sha256=package_hash,runs=runs,passes=sum(r['passes'] for r in runs),
            exploratory_runs=experiments,changed_runtime_members=source_hashes,
            review='Independent static review: capacity/identity/AI/household findings corrected; no outstanding P1/P2.',
            limitations=['No author acceptance','No multiplayer/FPS claim','Private saves and packages retained locally'])
(HERE/'report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
for path in HERE.glob('*.txt'):
    text=path.read_text(encoding='utf-8')
    path.write_text('\n'.join(line.rstrip() for line in text.splitlines()).rstrip()+'\n',encoding='utf-8')
print(f"{len(runs)} required runs, {report['passes']} passing assertions; normal package matches tested runtime.")
