"""Collect final native evidence, source identity and deterministic asset checks."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import subprocess
import sys
import zipfile
from verify import CASES

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue487'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
package=OUT/'current/caelum_argenteum_dev.pk3'
package_hash=sha(package)
with zipfile.ZipFile(package) as z:
    assert set(z.namelist())=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert all(z.read(n)==(ROOT/'src'/n).read_bytes() for n in z.namelist())
    entries=len(z.namelist())
expected={'network02':10,'mansion-es02':16,'city-en02':16,'old-upgrade02':15,
          'reload02':15,'removed-save02':1,'removed-load02':1,'blocked-save02':1,
          'blocked-load02':16,'collision03':2,'views02':0}
runs=[]
for label,script,start,load in CASES:
    log=(OUT/f'{label}.txt').read_text(encoding='utf-8-sig')
    assert not re.search(r'CA487 FAIL|Script error|VM execution aborted|Execution could not continue',log),label
    counts=re.findall(r'CA487 RESULT passed=(\d+) failed=(\d+)',log)
    assert counts and tuple(map(int,counts[-1]))==(expected[label],0),(label,counts)
    record=json.loads((OUT/f'{label}-run.json').read_text(encoding='utf-8-sig'))
    assert record['package_sha256'].lower()==package_hash and record['exit_code']==0
    assert record['addon_sha256'].lower()==sha(OUT/'checks.pk3')
    for suffix in ('.txt','-run.json'):
        dest=HERE/'native'/f'{label}{suffix}';dest.parent.mkdir(exist_ok=True)
        shutil.copyfile(OUT/f'{label}{suffix}',dest)
    runs.append({'label':label,'passed':expected[label]})
for name in ('es-view','es-menu','enu-view','enu-menu','side-view','back-view'):
    dest=HERE/'visuals'/f'{name}.png';dest.parent.mkdir(exist_ok=True)
    shutil.copyfile(OUT/f'{name}.png',dest)
for suffix in ('.txt','-run.json'):
    shutil.copyfile(OUT/f'collision02{suffix}',HERE/'native'/f'collision02{suffix}')
common=Path(subprocess.check_output(['git','rev-parse','--path-format=absolute','--git-common-dir'],cwd=ROOT,text=True).strip()).parent
rollback=common/'build/issue486-work/build/issue486'
assert sha(OUT/'ca486-original.zds')==sha(rollback/'ca486-original.zds')
rollback_log=(rollback/'rollback-original01.txt').read_text(encoding='utf-8-sig')
assert 'CA470 RESULT passed=1 failed=0' in rollback_log
for suffix in ('.txt','-run.json'):shutil.copyfile(rollback/f'rollback-original01{suffix}',HERE/'native'/f'rollback-original01{suffix}')
for log_path in (HERE/'native').glob('*.txt'):
    raw=log_path.read_text(encoding='utf-8-sig')
    log_path.write_text('\n'.join(line.rstrip() for line in raw.splitlines())+'\n',encoding='utf-8')

sys.path.insert(0,str(ROOT/'assets/generators'))
import generate_fermentation_station as generator
manifest_path=ROOT/'assets/generators/fermentation_station_manifest.json'
before=manifest_path.read_bytes()
generator.main()
assert manifest_path.read_bytes()==before
manifest=json.loads(before)
assert all(sha(ROOT/p)==h for p,h in manifest['outputs'].items())
mesh=generator.geometry()
assert all(3<=len(face)<=4 for material,face in mesh.faces)
assert all(abs(v[0])*1.5<=30 and abs(v[2])*1.5<=30 and 0<=v[1]*1.5<=72 for v in mesh.vertices)
# Independent midpoint integration of the approved radial inner surface.
profile=[(y*1.5/32,r*1.5/32) for y,r in generator.DATA['body_profile_y_radius']]
lo,hi=.03,profile[-1][0]-.03
steps=100000;dy=(hi-lo)/steps;volume=0
for i in range(steps):
    y=lo+(i+.5)*dy
    for (a,ra),(b,rb) in zip(profile,profile[1:]):
        if a<=y<=b:
            r=ra+(rb-ra)*(y-a)/(b-a)-.03
            volume+=math.pi*r*r*dy*1000
            break
assert abs(volume-manifest['interior_liters'])<.001
assert math.floor(volume*.8)==manifest['working_liters']==3402
validation=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',check=True)
(HERE/'project-validation.json').write_text(validation.stdout,encoding='utf-8')
report={'version':'5.7.12','issue':487,'package_sha256':package_hash,
        'source_entries':entries,'source_bytes_match':True,'runs':runs,
        'native_assertions':sum(r['passed'] for r in runs),'original_runtime_rollback_assertions':1,
        'original_save_preserved_sha256':sha(OUT/'ca486-original.zds'),
        'deterministic_generation':True,'independent_capacity_liters':volume,
        'working_liters':3402,'mesh_within_collision_bounds':True,
        'six_native_views_inspected':True,'author_accepted':False,
        'limitations':['#471 recipes and actual unattended batches remain pending.',
                       'No rendering-performance claim; native checks are functional and visual.',
                       'Initial collision02 quit before its queued event; collision03 adds the required wait and passes.']}
(HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2))
