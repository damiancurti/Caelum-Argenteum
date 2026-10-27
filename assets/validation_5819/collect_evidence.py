"""Collect selected native evidence, counting executed assertions instead of saved totals."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
WORK=ROOT/'build/issue410-cooking'
HERE=Path(__file__).resolve().parent
LABELS=(
    'process-final19b','process-guards05','process-library05',
    'process-seed04','process-resume04','process-hub07',
    'process-taskseed05','process-taskresume05','process-fast07c',
    'process-menu07','process-mansion08','process-oldsave07',
    'process-original-rollback18')
runtime=WORK/'final19b/caelum_argenteum_dev.pk3'
source=ROOT/'src'
with zipfile.ZipFile(runtime) as archive:
    files={p.relative_to(source).as_posix():p for p in source.rglob('*') if p.is_file()}
    assert set(archive.namelist())==set(files), 'Runtime membership differs from source.'
    for name,path in files.items():
        assert archive.read(name)==path.read_bytes(), f'Runtime bytes differ: {name}'
    matched=len(files)
report={'issue':410,'version':'5.8.19',
        'runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),
        'source_matching_members':matched,'native_passes':0,'native_failures':0,'runs':[],
        'author_check':'CA410-COOKING-01','author_acceptance':'pending'}
(HERE/'native').mkdir(exist_ok=True)
for label in LABELS:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig',errors='strict')
    metadata=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    passes=len(re.findall(r'^CA410[FMKC] PASS ',log,re.M))
    failures=len(re.findall(r'^CA410[FMKC] FAIL ',log,re.M))
    assert passes>0 and failures==0 and metadata['exit_code']==0,label
    assert not re.search(r'Script error|VM execution aborted|Fatal:|failed=[1-9]',log),label
    report['runs'].append({'label':label,'executed_passes':passes,
                          'runtime_sha256':metadata['package_sha256'].lower()})
    report['native_passes']+=passes
    report['native_failures']+=failures
    for suffix in ('.txt','-run.json'):
        shutil.copy2(WORK/(label+suffix),HERE/'native'/(label+suffix))
(HERE/'captures').mkdir(exist_ok=True)
for name in ('kitchen-mansion.png','kitchen-proofing-menu.png','kitchen-cooking-menu.png'):
    shutil.copy2(WORK/name,HERE/'captures'/name)
static_bytes=(WORK/'final19b-static.json').read_bytes()
static=json.loads(static_bytes.decode('utf-16' if static_bytes.startswith((b'\xff\xfe',b'\xfe\xff')) else 'utf-8-sig'))
assert not static['errors'],static['errors']
report['static_errors']=static['errors']
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
(HERE/'static.txt').write_text(
    'validate_project.py: exit 0, zero errors. Dialogue/localization and document indexes current.\n'
    'Official build_dev.ps1: final19b, current map geometry; all members match source.\n'
    'Native engine evidence is separate from pending author corroboration and rendering performance.\n',
    encoding='utf-8')
print(json.dumps({key:report[key] for key in ('runtime_sha256','source_matching_members','native_passes','native_failures')}))
