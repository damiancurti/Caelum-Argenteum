"""Collect bounded #408 evidence and verify the final package against source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue408'
FINAL=['final-suite-01','final-sources-01','final-save-02','final-reload-02',
       'final-travel-01','final-upgrade-01','final-upgraded-reload-01',
       'final-rollback-01','final-ui-es-01','final-ui-en-01','final-dispatch-01',
       'final-hud-01','final-map01-01','baseline-save-01']
DIAGNOSTIC=['diagnostic-suite-01','diagnostic-suite-02','diagnostic-suite-03',
            'diagnostic-sources-01','final-save-01','final-reload-01']
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    evidence=HERE/'native';evidence.mkdir(exist_ok=True)
    runs=[]
    for label in FINAL:
        logfile=OUT/f'{label}.txt';log=logfile.read_text(encoding='utf-8-sig')
        record=json.loads((OUT/f'{label}-run.json').read_text(encoding='utf-8-sig'))
        assert record.get('exit_code')==0 and not record.get('timed_out'),label
        assert not re.search(r'CA408 FAIL|Script error|VM execution aborted|failed=[1-9]|DIED WITH FATAL ERROR|This savegame needs|Cannot find savegame',log),label
        runs.append({'label':label,'pass':len(re.findall(r'^CA408 PASS ',log,re.M)),
                     'package_sha256':record['package_sha256'].lower(),
                     'addon_sha256':record['addon_sha256'].lower(),'log_sha256':digest(logfile)})
        shutil.copyfile(logfile,evidence/logfile.name)
        shutil.copyfile(OUT/f'{label}-run.json',evidence/f'{label}-run.json')
    for label in DIAGNOSTIC:
        for suffix in ['.txt','-run.json']:
            shutil.copyfile(OUT/(label+suffix),evidence/('diagnostic-'+label+suffix))
    for name in ['ui-es.png','ui-en.png','hud-es.png']:
        shutil.copyfile(OUT/name,HERE/name)
    package=OUT/'current/caelum_argenteum_dev.pk3'
    tested=OUT/'tested/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as final,zipfile.ZipFile(tested) as prior:
        sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(final.namelist())==set(sources)
        for name,path in sources.items():
            assert final.read(name)==path.read_bytes(),name
        metadata_only=[]
        for name in final.namelist():
            old=prior.read(name);new=final.read(name)
            if old!=new:
                assert name in ['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'],name
                assert old.replace(b'[Caelum 5.6.11a]',b'[Caelum 5.7.0]')==new,name
                metadata_only.append(name)
    baseline=OUT/'baseline/caelum_argenteum_dev.pk3'
    assert digest(baseline)=='b4d75590e5f16edaccfb3e05377d6c2e633b59a8e04f3553030e520e90a0fd69'
    result={'issue':408,'version':'5.7.0','native_runs':runs,'pass':sum(r['pass'] for r in runs),
            'fail':0,'final_package_sha256':digest(package),'tested_package_sha256':digest(tested),
            'source_members':len(sources),'metadata_only_final_differences':metadata_only,
            'baseline_package_sha256':digest(baseline),'baseline_ref':'c6f13acd',
            'author_acceptance':'pending CA408-01','performance_claim':None}
    (HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    validation=subprocess.run([sys.executable,str(ROOT/'validate_project.py')],capture_output=True,text=True,encoding='utf-8')
    (HERE/'project-validation.json').write_text(validation.stdout,encoding='utf-8')
    assert validation.returncode==0,validation.stdout+validation.stderr
    print(f"#408: {len(runs)} runs, {result['pass']} PASS, zero FAIL; {len(sources)} exact packaged source members; static validation passed.")

if __name__=='__main__':main()
