"""Verify #160 final native evidence and preserve the author's checkpoint."""
from hashlib import sha256
from pathlib import Path
import json
import re
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue160'

def digest(path):
    return sha256(path.read_bytes()).hexdigest().upper()

def main():
    package=ROOT/'build/caelum_argenteum_dev.pk3'
    assert digest(package)==digest(WORK/'candidate/caelum_argenteum_dev.pk3')
    with zipfile.ZipFile(package) as z:
        sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(z.namelist())==set(sources)
        for name,p in sources.items():assert z.read(name)==p.read_bytes(),name
    runs={}
    for label,expected in [('baseline-b',(10,6)),('regression-b',(16,0)),('reload-b',(4,0))]:
        log=(WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
        counts=(len(re.findall(r'^CA160 PASS ',log,re.M)),len(re.findall(r'^CA160 FAIL ',log,re.M)))
        assert counts==expected,(label,counts)
        assert not re.search(r'Script error|VM execution aborted|Execution could not continue',log,re.I)
        record=json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
        assert record['exit_code']==0
        assert record['package_sha256']==digest(WORK/'baseline/caelum_argenteum_dev.pk3' if label=='baseline-b' else package)
        assert record['addon_sha256']==digest(WORK/('reload/checks.pk3' if label=='reload-b' else 'checks.pk3'))
        runs[label]={'passed':counts[0],'failed':counts[1],'package_sha256':record['package_sha256'],'addon_sha256':record['addon_sha256']}
    for label in list(runs)+['regression-final','reload-final']:
        for suffix in ('.txt','-run.json'):shutil.copyfile(WORK/f'{label}{suffix}',HERE/f'{label}{suffix}')
    original=json.loads((WORK/'original-record.json').read_text(encoding='utf-8'))
    assert digest(Path(original['path']))==original['sha256'].upper()==digest(WORK/'llave-plata-original.zds')
    power=json.loads((ROOT/'build/issue140/power-160.json').read_text(encoding='utf-8-sig'))
    assert power.get('released_utc') and power['active_plan_before']==power['active_plan_after']
    shutil.copyfile(ROOT/'build/issue140/power-160.json',HERE/'power-release.json')
    hashes={name:digest(WORK/name) for name in ('checks.pk3','reload/checks.pk3')}
    subprocess.run(['python','-X','utf8',str(HERE/'prepare.py')],cwd=ROOT,check=True,capture_output=True)
    assert all(digest(WORK/name)==value for name,value in hashes.items())
    result={'issue':160,'version':'5.1.13','native_runs':runs,'final_passed':20,
            'package_sha256':digest(package),'source_members_verified':len(sources),
            'original_checkpoint_sha256':original['sha256'].upper(),'original_checkpoint_unchanged':True,
            'fixture_packages_deterministic':True,'power_released':True,'author_pending':['CA158-01','CA160-01'],
            'source_sha256':{str(p.relative_to(ROOT)).replace('\\','/'):digest(p) for p in sorted(HERE.glob('*.zs'))}}
    (HERE/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Verified 20 final native checks, six baseline failures, source bytes, original save and power release.')

if __name__=='__main__':main()
