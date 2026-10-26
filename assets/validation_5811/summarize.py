"""Preserve focused runs and count executed checks, never cumulative totals."""
from pathlib import Path
import hashlib,json,shutil,re,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent;WORK=ROOT/'build/issue410-bath'
NATIVE=HERE/'native';NATIVE.mkdir(exist_ok=True)
for pattern in ['*.txt','*-run.json','*.ini']:
    for source in WORK.glob(pattern):shutil.copyfile(source,NATIVE/source.name)
labels=['core-final-h','fill-final-c','property-b','relocated-b','last-b','save-final-f','load-final-f','hub-final-c','legacy-final-f','rollback-final','manual-final-h','retry-final-g','capture-final-e']
records=[]
for label in labels:
    text=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
    assert not re.search(r'CA410B FAIL|VM execution aborted|Script error',text),label
    run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert run['exit_code']==0 and not run.get('timed_out'),label
    records.append({'label':label,'passes':len(re.findall(r'^CA410B PASS ',text,re.M)),'runtime':run['runtime'],'sha256':run['package_sha256'],'addon_sha256':run['addon_sha256']})
for name in ['bathroom','sink','bathtub','toilet','toilet-sprite']:
    shutil.copyfile(WORK/(name+'.png'),HERE/'captures'/(name+'-final05.png'))
with zipfile.ZipFile(WORK/'final03/caelum_argenteum_dev.pk3') as old,zipfile.ZipFile(WORK/'final07/caelum_argenteum_dev.pk3') as new:
    changes=[name for name in new.namelist() if old.read(name)!=new.read(name)]
    code=[name for name in changes if name.endswith('.zs')]
    for name in code:
        a=old.read(name).replace(b'\r\n',b'\n').replace(b'5.8.9',b'5.8.11')
        assert a==new.read(name).replace(b'\r\n',b'\n'),name
timing=re.search(r'CA410B TIMING.*',(WORK/'retry-final-g.txt').read_text(encoding='utf-8-sig')).group(0)
report={'passes':sum(r['passes'] for r in records),'runs':records,'final03_to_final07_members':changes,'reused_behavior_evidence':'All ZScript behavior identical after normalizing line endings and two diagnostic release labels. Final06 executes blocked-placement retry; final07 executes core/manual smoke. Model/notice changes have final05 captures.','timing':timing,'failed_probes':['house-a: delayed PostBeginPlay overwrote House; final sizing and installation flag fix it. Approach test corrected to usable side of fixture; closed doorway test now checks added obstruction.','legacy-final: old save restores old fixture handler; diagnostic bridge added.','legacy-final-b: saved Prepared flag skipped new installation; transient BathroomReady now forces idempotent load validation.','manual-smoke-e: temporary one-line wrapper lacked terminating newline; prepared script now includes newline and directly appends quit.'],'author_test':'CA410-BATH-01 accepted without qualifications on 2026-10-25; inherited CA502-TREATMENT-01 remains pending.'}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'passes':report['passes'],'runs':len(records),'timing':timing,'changed_members':changes}))
