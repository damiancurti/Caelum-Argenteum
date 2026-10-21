"""Verify final native evidence and collect portable issue386 results."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue386'
LABELS=['baseline-save-01','baseline-rollback-01','delivery-suite',
        'delivery-baseline','delivery-save','delivery-load','delivery-travel',
        'delivery-legacy-save','delivery-legacy-upgrade','delivery-legacy-rollback',
        'delivery-ui-en','delivery-ui-es','delivery-smoke']

def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream,'sha256').hexdigest()

def redact(value):
    if isinstance(value,list):return [redact(v) for v in value]
    if isinstance(value,dict):return {k:redact(v) for k,v in value.items()}
    if not isinstance(value,str):return value
    value=value.replace(str(ROOT),'<repo>').replace(str(ROOT).replace('\\','/'),'<repo>')
    value=value.replace(r'C:\Program Files (x86)\GZDoom\gzdoom.exe','<engine>')
    value=re.sub(r'C:\\Program Files \(x86\)\\Steam[^"\r\n]*DOOM2\.WAD','<iwad>',value,flags=re.I)
    return re.sub(r'C:\\Users\\[^\\\s]+',r'<user>',value,flags=re.I)

hashes={runtime:sha(WORK/runtime/'caelum_argenteum_dev.pk3') for runtime in ['current','legacy','baseline']}
assert hashes['current']==sha(ROOT/'build/caelum_argenteum_dev.pk3')
runs=[]
(HERE/'native').mkdir(exist_ok=True)
for label in LABELS:
    log_path=WORK/(label+'.txt')
    log=log_path.read_text(encoding='utf-8',errors='replace')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not record.get('timed_out'),label
    assert not re.search(r'CA386 FAIL|Script error|VM execution aborted',log),label
    assert record['package_sha256'].lower()==hashes[record['runtime']],label
    if record['addon_sha256']:
        addon='checks.pk3' if record['runtime']=='current' else 'baseline-checks.pk3' if record['runtime']=='baseline' else 'legacy-checks.pk3'
        assert record['addon_sha256'].lower()==sha(WORK/addon),label
    runs.append({'label':label,'passes':len(re.findall(r'CA386 PASS ',log)),
                 'record':redact(record),'raw_log_sha256':sha(log_path)})
    clean='\n'.join(line.rstrip() for line in redact(log).splitlines()).rstrip()+'\n'
    (HERE/'native'/(label+'.txt')).write_text(clean,encoding='utf-8')

with zipfile.ZipFile(WORK/'current/caelum_argenteum_dev.pk3') as package:
    source_manifest={}
    for name in package.namelist():
        data=package.read(name)
        assert data.replace(b'\r\n',b'\n')==(ROOT/'src'/name).read_bytes().replace(b'\r\n',b'\n'),name
        source_manifest[name]=hashlib.sha256(data).hexdigest()
    source_digest=hashlib.sha256(json.dumps(source_manifest,sort_keys=True).encode()).hexdigest()
check=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8')
assert check.returncode==0,check.stdout+check.stderr
validation=json.loads(check.stdout);assert not validation['errors']
(HERE/'project-validation.json').write_text(json.dumps(validation,indent=2)+'\n',encoding='utf-8')
screens={}
for name in ['clothing-en.png','clothing-es.png']:
    shutil.copy2(WORK/name,HERE/name);screens[name]=sha(HERE/name)
report={'issue':386,'version':'5.6.6','base_commit':'b92de0b3503a3b585870615606803adf1fbf5d8f',
        'qualification':'Issue386 working tree; native runtime verified byte-for-byte against packaged source.',
        'package_hashes':hashes,'source_member_count':len(source_manifest),'source_manifest_sha256':source_digest,
        'runs':runs,'native_runs':len(runs),'passes':sum(r['passes'] for r in runs),'failures':0,
        'screenshots':screens,'author_acceptance':'CA386-01 pending',
        'limitations':['Not a rendering or large-map performance benchmark.','Shop assignments/stock remain #383; models remain #387.']}
(HERE/'report.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps({'runs':len(runs),'passes':report['passes'],'errors':validation['errors'],'source_members':len(source_manifest)}))
