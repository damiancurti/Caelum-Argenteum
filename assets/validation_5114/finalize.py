"""Verify #165 screen/travel evidence and original-save integrity."""
from hashlib import sha256
from pathlib import Path
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue165'
def digest(path):return sha256(path.read_bytes()).hexdigest().upper()
def main():
    package=ROOT/'build/caelum_argenteum_dev.pk3'
    assert digest(package)==digest(WORK/'candidate/caelum_argenteum_dev.pk3')
    with zipfile.ZipFile(package) as z:
        sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(z.namelist())==set(sources)
        for name,p in sources.items():assert z.read(name)==p.read_bytes(),name
    runs={}
    for label,expected,addon in [('baseline-final',1,'baseline/checks.pk3'),('regression-final',14,'checks.pk3'),('reload-final',2,'reload/checks.pk3'),('travel-airborne',18,'travel/checks.pk3')]:
        log=(WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
        passed=len(re.findall(r'^CA165 PASS ',log,re.M))
        assert passed==expected and 'CA165 FAIL' not in log,(label,passed)
        assert not re.search(r'Script error|VM execution aborted|Execution could not continue',log,re.I)
        record=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
        assert record['exit_code']==0
        assert record['package_sha256']==digest(WORK/'baseline/caelum_argenteum_dev.pk3' if label=='baseline-final' else package)
        assert record['addon_sha256']==digest(WORK/addon)
        runs[label]={'passed':passed,'failed':0,'package_sha256':record['package_sha256'],'addon_sha256':record['addon_sha256']}
        for suffix in ('.txt','-run.json'):shutil.copyfile(WORK/f'{label}{suffix}',HERE/f'{label}{suffix}')
    for name in ('baseline-final-view.png','regression-final-view.png'):shutil.copyfile(WORK/name,HERE/name)
    original=json.loads((WORK/'original-record.json').read_text(encoding='utf-8'))
    assert digest(Path(original['path']))==original['sha256'].upper()==digest(WORK/'loco-map02-original.zds')==digest(ROOT/'build/map02-red/loco-map02-original.zds')
    power=json.loads((ROOT/'build/issue140/power-165.json').read_text(encoding='utf-8-sig'))
    assert power.get('released_utc') and power['active_plan_before']==power['active_plan_after']
    shutil.copyfile(ROOT/'build/issue140/power-165.json',HERE/'power-release.json')
    hashes={name:digest(WORK/name) for name in ('baseline/checks.pk3','checks.pk3','reload/checks.pk3','travel/checks.pk3')}
    subprocess.run(['python','-X','utf8',str(HERE/'prepare.py')],cwd=ROOT,check=True,capture_output=True)
    assert all(digest(WORK/name)==value for name,value in hashes.items())
    result={'issue':165,'version':'5.1.14','native_runs':runs,'final_passed':34,
            'package_sha256':digest(package),'source_members_verified':len(sources),
            'original_checkpoint_sha256':original['sha256'].upper(),'original_checkpoint_unchanged':True,
            'fixture_packages_deterministic':True,'power_released':True,'author_pending':['CA165-01'],
            'evidence_sha256':{p.name:digest(p) for p in sorted(HERE.iterdir()) if p.suffix in ('.zs','.png')}}
    (HERE/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Verified 34 final checks, baseline reproduction, screenshots, source package, original save and power release.')
if __name__=='__main__':main()
