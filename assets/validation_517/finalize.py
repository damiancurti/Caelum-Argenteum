"""Record exact delivery sources, payloads, selected native evidence and gates."""
from pathlib import Path
import hashlib,json,re,subprocess,sys,zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue136'
def sha(data):return hashlib.sha256(data).hexdigest()
def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Native testing must finish before finalization.')
    validation=subprocess.run([sys.executable,str(ROOT/'validate_project.py')],cwd=ROOT,capture_output=True,check=True)
    (HERE/'VALIDATOR.json').write_bytes(validation.stdout)
    payload={p.relative_to(ROOT/'src').as_posix():sha(p.read_bytes()) for p in (ROOT/'src').rglob('*') if p.is_file()}
    packages={}
    for name in ['build/caelum_argenteum_dev.pk3','build/issue136/production.pk3']:
        with zipfile.ZipFile(ROOT/name) as z:members={n:sha(z.read(n)) for n in z.namelist() if not n.endswith('/')}
        assert members==payload, 'Package differs from final src: '+name
        packages[name]={'sha256':sha((ROOT/name).read_bytes()),'members':len(members),'matches_final_src':True}
    runs={}
    for label in ['delivery-catalogue','delivery-integration','final-map02','final-visual','delivery-upgrade','delivery-hub','rollback-a','migration-seed-b']:
        record=json.loads((HERE/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        log=(HERE/(label+'.txt')).read_text(encoding='utf-8-sig')
        assert record['exit_code']==0 and re.search(r'CA136 COMPLETE checks=\d+ failures=0',log)
        assert not re.search(r'CA136 FAIL|VM execution aborted|Script error,|DIED WITH FATAL ERROR',log)
        runs[label]={'checks':[int(x) for x in re.findall(r'CA136 COMPLETE checks=(\d+) failures=0',log)],
                     'exit_code':0,'package_sha256':record['package_sha256'],'fixture_sha256':record['addon_sha256']}
    power=json.loads((HERE/'POWER.json').read_text(encoding='utf-8-sig'))
    assert power['released_utc'] and power['active_plan_before']==power['active_plan_after']
    captures={p.name:sha(p.read_bytes()) for p in sorted(OUT.glob('final-visual-*.png'))}
    assert len(captures)==58
    diff=subprocess.run(['git','diff','--check'],cwd=ROOT,capture_output=True,check=True)
    record={'issue':136,'release':'5.1.7','base':'abd4f578a698cefc72e91d5176c79458276e6115',
            'packages':packages,'src_payload_sha256':sha(json.dumps(payload,sort_keys=True).encode()),
            'src_members':len(payload),'native_runs':runs,'visual_capture_sha256':captures,
            'static_validation':json.loads(validation.stdout),'diff_check':'passed','temporary_keep_awake_released':power['released_utc'],
            'original_save_sha256':sha((OUT/'ca136-old-shortbow.zds').read_bytes()),
            'migrated_save_sha256':sha((OUT/'ca136-migrated.zds').read_bytes()),
            'author_acceptance_pending':['CA136-01','CA143-01'],
            'evidence_sha256':{p.name:sha(p.read_bytes()) for p in sorted(HERE.iterdir()) if p.is_file() and p.name!='MANIFEST.json'}}
    (HERE/'MANIFEST.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'members':len(payload),'native_runs':len(runs),'captured_views':len(captures),'validator_errors':[],'keep_awake_released':True}))
if __name__=='__main__':main()
