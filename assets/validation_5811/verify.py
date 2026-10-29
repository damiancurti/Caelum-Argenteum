"""Static asset/package/geometry evidence; native behavior is tested separately."""
from pathlib import Path
import hashlib,json,os,subprocess,sys,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=ROOT/'assets/art_source/bathrooms/MANIFEST.json'
before=manifest.read_bytes()
subprocess.run([sys.executable,str(ROOT/'assets/generators/generate_domestic_bathrooms.py')],cwd=ROOT,check=True)
assert before==manifest.read_bytes(),'Repeated generation differs'
data=json.loads(manifest.read_text())
for name,expected in data['inputs'].items():assert digest(ROOT/name)==expected,name
for name,expected in data['outputs'].items():assert digest(ROOT/name)==expected,name
for name,row in data['assets'].items():
    assert row['vertices']>0 and row['sprite_scale']>0,name
    assert all(0<=value<=128 for value in row['registered_alpha_bounds']),name
package=ROOT/'build/issue410-bath/final07/caelum_argenteum_dev.pk3'
baseline=ROOT/'build/issue410-bath/baseline/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as current,zipfile.ZipFile(baseline) as old:
    members=current.namelist()
    assert len(members)==len(set(members))
    assert all(current.read(name)==(ROOT/'src'/name).read_bytes() for name in members)
    maps=[name for name in old.namelist() if name.lower().startswith('maps/')]
    assert all(old.read(name)==current.read(name) for name in maps),'Map geometry changed'
    assert len([n for n in maps if '/CAH' in n])==160
result=subprocess.run([sys.executable,'validate_project.py'],cwd=ROOT,capture_output=True)
(HERE/'static_validation.json').write_bytes(result.stdout)
report=json.loads(result.stdout.decode('utf-8-sig'))
assert result.returncode==0 and not report['errors'],report['errors']
summary={'package':str(package.relative_to(ROOT)),'package_sha256':digest(package),'members':len(members),'unchanged_maps':len(maps),'unchanged_house_maps':160,'repeated_generator_identical':True,'validator_errors':report['errors']}
(HERE/'static_report.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
print(json.dumps(summary))
