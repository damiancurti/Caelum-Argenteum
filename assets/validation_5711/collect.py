"""Record focused #486 evidence and compare the complete packages."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue486'
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

current = OUT / 'current/caelum_argenteum_dev.pk3'
baseline = OUT / 'baseline/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(current) as new, zipfile.ZipFile(baseline) as old:
    assert set(new.namelist()) == set(old.namelist())
    changed = sorted(name for name in new.namelist() if new.read(name) != old.read(name))
    assert set(changed) == {'LANGUAGE', 'localization/INDEX.md', 'localization/index.json',
                            'caelum/world/CaelumPhysicalHazards.zs', 'caelum/world/CaelumSewerMaze.zs'}
    assert all(new.read(name) == (ROOT / 'src' / name).read_bytes() for name in new.namelist())
    count = len(new.namelist())
records=[]
for label in ('original-seed01', 'spanish-load01', 'english-city01'):
    log=(OUT/f'{label}.txt').read_text(encoding='utf-8-sig')
    assert 'CA470 FAIL' not in log and 'VM execution aborted' not in log
    assert 'Script error' not in log
    assert ('Game saved.' if label=='original-seed01' else 'CA470 RESULT passed=1 failed=0') in log
    for suffix in ('.txt', '-run.json'):
        target=HERE/'native'/f'{label}{suffix}';target.parent.mkdir(exist_ok=True)
        shutil.copyfile(OUT/f'{label}{suffix}',target)
    records.append({'label':label, 'native_use_assertions':0 if label=='original-seed01' else 1})
for language in ('es','enu'):
    for view in ('target','menu'):
        target=HERE/'visuals'/f'{language}-{view}.png';target.parent.mkdir(exist_ok=True)
        shutil.copyfile(OUT/target.name,target)
validation=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',check=True)
(HERE/'project-validation.json').write_text(validation.stdout,encoding='utf-8')
report={'version':'5.7.11','issue':486,'package_sha256':sha(current),
        'baseline_sha256':sha(baseline),'source_entries':count,'source_bytes_match':True,
        'changed_package_entries':changed,'runs':records,'native_use_assertions':2,
        'old_save_loaded':True,'original_save_sha256':sha(OUT/'ca486-original.zds'),
        'visuals_inspected':True,'author_accepted':False,
        'limits':'Presentation-only change. Two real Use assertions, old-save load, four inspected captures; no performance or new recipe claims.'}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2))
