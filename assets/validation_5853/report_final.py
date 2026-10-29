"""Preserve native incident evidence and verify the complete review package."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HOME=Path(__file__).parent
WORK=ROOT/'build/issue417-incidents'
rows=[]
for case in ['core','reload','bandits','encounter','resume','clock','camp']:
    label='review53-'+case
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not record.get('timed_out'), label
    assert not re.search(r'CA417 FAIL|failed=[1-9]|Script error|VM execution aborted',log),label
    passed=len(re.findall(r'^CA417 PASS ',log,re.M))
    assert passed,label
    rows.append({'case':case,'executed_assertions':passed,'package_sha256':record['package_sha256'],
                 'log_sha256':hashlib.sha256((WORK/(label+'.txt')).read_bytes()).hexdigest()})
    (HOME/'native').mkdir(exist_ok=True)
    for suffix in ['.txt','-run.json']:
        target=HOME/'native'/(label+suffix);data=(WORK/(label+suffix)).read_bytes()
        if target.exists():assert target.read_bytes()==data,target
        else:target.write_bytes(data)
package=WORK/'review53/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as archive:
    files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(files)==set(archive.namelist())
    for name,path in files.items():assert archive.read(name)==path.read_bytes(),name
report={'version':'5.8.53','issue':417,'native_runs':rows,'executed_assertions':sum(r['executed_assertions'] for r in rows),
        'source_matched_members':len(files),'package_sha256':hashlib.sha256(package.read_bytes()).hexdigest(),
        'engine':'GZDoom 4.14.2 / Windows 11 / Vulkan / 1280x720 / background unpaused / 5% audio',
        'scope':'Real resource clock, saved rolls, native hub escape/return, finite native shots and loot, survivor camp theft/discovery/recovery.',
        'fixture_corrections':'Earlier private scenarios waited for deferred PostBeginPlay, checked zero-amount original inventory rather than owner pointer, waited for queued travel and opened the actual wait menu before checking it. Earlier failed diagnostic logs remain in build.',
        'author_acceptance':'Pending grouped V5.8 corroboration. No author entry removed.'}
(HOME/'final-results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'runs':len(rows),'assertions':report['executed_assertions'],'members':len(files)}))
