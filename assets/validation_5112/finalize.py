"""Verify final #158 native evidence, original-save integrity and packaged source."""
from hashlib import sha256
from pathlib import Path
import json
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / 'build/issue158'

def digest(path):
    return sha256(path.read_bytes()).hexdigest().upper()

def main():
    package = ROOT / 'build/caelum_argenteum_dev.pk3'
    assert digest(package) == digest(WORK/'candidate/caelum_argenteum_dev.pk3')
    with zipfile.ZipFile(package) as archive:
        files = {p.relative_to(ROOT/'src').as_posix(): p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(archive.namelist()) == set(files)
        for name, source in files.items():
            assert archive.read(name) == source.read_bytes(), name
    runs = {}
    for label, expected in [('baseline-final', (18,12)), ('regression-final', (30,0)),
                            ('reload-final', (6,0)), ('completed-final', (1,0))]:
        log = (WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
        counts = (len(re.findall(r'^CA158 PASS ',log,re.M)),len(re.findall(r'^CA158 FAIL ',log,re.M)))
        assert counts == expected, (label, counts)
        assert not re.search(r'VM execution aborted|Script error|Execution could not continue',log,re.I), label
        if label == 'baseline-final':
            assert all('via fixed recipe' in line for line in log.splitlines() if line.startswith('CA158 FAIL'))
        record = json.loads((WORK/f'{label}-run.json').read_text(encoding='utf-8-sig'))
        assert record['exit_code'] == 0
        expected_package = WORK/'baseline/caelum_argenteum_dev.pk3' if label == 'baseline-final' else package
        assert record['package_sha256'] == digest(expected_package)
        addon = WORK/('checks.pk3' if label in ('baseline-final','regression-final') else 'reload/checks.pk3' if label=='reload-final' else 'done/checks.pk3')
        assert record['addon_sha256'] == digest(addon)
        runs[label] = {'passed':counts[0], 'failed':counts[1], 'package_sha256':record['package_sha256'], 'addon_sha256':record['addon_sha256']}
        for suffix in ('.txt','-run.json'):
            shutil.copyfile(WORK/f'{label}{suffix}', HERE/f'{label}{suffix}')
    # The personal checkpoint is deliberately neither edited nor distributed.
    original = Path.home()/'Saved Games/GZDoom/doom.id.doom2.commercial/save05.zds'
    protected = WORK/'materiales-palomo-original.zds'
    assert digest(original) == digest(protected) == digest(ROOT/'build/palomo-materials/materiales-palomo-original.zds')
    power = json.loads((ROOT/'build/issue140/power-158.json').read_text(encoding='utf-8-sig'))
    assert power.get('released_utc') and power['active_plan_before']==power['active_plan_after']
    shutil.copyfile(ROOT/'build/issue140/power-158.json',HERE/'power-release.json')
    for relative in ('checks.pk3','reload/checks.pk3','done/checks.pk3'):
        prior=digest(WORK/relative)
        subprocess.run(['python','-X','utf8',str(HERE/'prepare.py')],check=True,cwd=ROOT,capture_output=True)
        assert digest(WORK/relative)==prior,relative
    results = {'issue':158,'version':'5.1.12','native_runs':runs,'final_passed':37,
               'package_sha256':digest(package),'source_members_verified':len(files),
               'original_checkpoint_sha256':digest(original),'original_checkpoint_unchanged':True,
               'fixture_packages_deterministic':True,'power_released':True,'author_pending':['CA158-01'],
               'source_sha256':{str(p.relative_to(ROOT)).replace('\\','/'):digest(p) for p in sorted(HERE.glob('*.zs'))}}
    (HERE/'RESULTS.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Verified 37 final native checks, 12 baseline reproductions, source package, original save and power release.')

if __name__ == '__main__':
    main()
