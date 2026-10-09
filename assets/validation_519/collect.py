"""Collect bounded #152 native evidence; never distribute save files or PK3s."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue152'
LABELS=('saved-before','saved-before-b','input-before','input-before-b',
        'pickups-before','saved-fixed-a','checks-fixed-a','visual-fixed-a',
        'input-fixed-shotgun','input-fixed-carbine','input-fixed-longbow',
        'input-fixed-crossbow','thermal-diagnostic','world-fixed','world-fixed-b',
        'save-upgrade','save-reload','release-checks','release-final')

def digest(data):
    return hashlib.sha256(data).hexdigest()

def main():
    normalization=[]
    for label in LABELS:
        for suffix in ('.txt','.ini','-run.json','-exec.cfg'):
            p=WORK/(label+suffix)
            if not p.exists():
                continue
            raw=p.read_bytes()
            normalized=('\n'.join(line.rstrip() for line in raw.decode('utf-8-sig').splitlines()).rstrip('\n')+'\n').encode('utf-8')
            (HERE/p.name).write_bytes(normalized)
            normalization.append({'file':p.name,'raw_sha256':digest(raw),'normalized_sha256':digest(normalized)})
    for label in ('visual-fixed-a','world-fixed-b','saved-before-b','saved-fixed-a'):
        for p in WORK.glob(label+'-*.png'):
            (HERE/p.name).write_bytes(p.read_bytes())
    power=json.loads((ROOT/'build/issue140/power-152.json').read_text(encoding='utf-8-sig'))
    assert power['release_result'] and power['active_plan_before']==power['active_plan_after']
    (HERE/'power-152.json').write_text(json.dumps(power,indent=2)+'\n',encoding='utf-8')
    (HERE/'TEXT_NORMALIZATION.json').write_text(json.dumps(normalization,indent=2)+'\n',encoding='utf-8')
    passed=('checks-fixed-a','input-fixed-shotgun','input-fixed-carbine','input-fixed-longbow',
            'input-fixed-crossbow','world-fixed-b','save-upgrade','save-reload','thermal-diagnostic','release-final')
    for label in passed:
        record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert record['exit_code']==0,label
        log=(HERE/(label+'.txt')).read_text(encoding='utf-8')
        assert 'CA152 FAIL' not in log and 'Script error' not in log and 'VM execution aborted' not in log,label
    package=ROOT/'build/caelum_argenteum_dev.pk3'
    with zipfile.ZipFile(package) as z:
        assert len(z.namelist())==6293
        for name in z.namelist():
            assert z.read(name)==(ROOT/'src'/name).read_bytes(),name
    release=json.loads((WORK/'release-final-run.json').read_text(encoding='utf-8-sig'))
    assert release['package_sha256'].lower()==digest(package.read_bytes())
    check=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,check=True)
    (HERE/'static-validation.txt').write_bytes(check.stdout.replace(b'\r\n',b'\n'))
    delivery={'release':'5.1.9','issue':152,'package_sha256':digest(package.read_bytes()),
              'files':6293,'all_entries_match_src':True,'native_final':'release-final',
              'passed_recorded_runs':list(passed),'validation':json.loads(check.stdout),
              'art_reference_cm':6,'art_reference_author_approved':'2026-10-09',
              'pending_author_checks':['CA152-01','CA152-02','CA152-03'],
              'temporary_power_request_released':True}
    (HERE/'DELIVERY.json').write_text(json.dumps(delivery,indent=2)+'\n',encoding='utf-8')
    print('Collected native logs, configurations, captures and verified final package.')

if __name__=='__main__':
    main()
