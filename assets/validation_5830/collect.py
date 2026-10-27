"""Collect executed checks against the final immutable runtime and source."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-luxury'
NATIVE=HERE/'native';NATIVE.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
package=WORK/'final30c/caelum_argenteum_dev.pk3'
expected={'core':50,'input':2,'seed':2,'resume':5,'hub':7,'migration':3,'transactions':10,
          'view0':2,'view1':2,'view2':2,'view3':2,'view4':2,'view5':2,'spanish':5}
rows=[]
for name,count in expected.items():
    label='release-'+name
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not re.search(r'CA410LX FAIL|VM execution aborted|Script error|failed=[1-9]',log),label
    executed=len(re.findall(r'^CA410LX PASS ',log,re.M));assert executed==count,(label,executed,count)
    assert record['package_sha256'].lower()==digest(package),label
    rows.append({'label':label,'executed_passes':executed,'runtime_sha256':record['package_sha256'].lower(),
                 'addon_sha256':record['addon_sha256'].lower()})
    for suffix in ('.txt','-run.json'):shutil.copy2(WORK/(label+suffix),NATIVE/(label+suffix))
assert len({r['addon_sha256'] for r in rows})==1
with zipfile.ZipFile(package) as z:
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(z.namelist())==set(source)
    assert all(z.read(n)==p.read_bytes() for n,p in source.items())
    with zipfile.ZipFile(ROOT.parent/'issue410-sofas-work/build/issue410-sofas/final29d/caelum_argenteum_dev.pk3') as previous:
        kept=[n for n in previous.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
        line_endings=[]
        for name in kept:
            current,prior=z.read(name),previous.read(name)
            if current==prior:continue
            assert name in ('models/caelum/props/sofas/ca_sofa_2.obj','models/caelum/props/sofas/ca_sofa_3.obj'),name
            assert current.replace(b'\r\n',b'\n')==prior.replace(b'\r\n',b'\n'),name
            line_endings.append(name)
generated=list((ROOT/'src/models/caelum/props/luxury').glob('*.obj'))+[
    ROOT/'src/caelum/data/CaelumLuxuryData.zs',ROOT/'assets/art_source/luxury_furniture/GENERATED.json']
before=[digest(p) for p in generated]
subprocess.run(['python','assets/generators/generate_luxury_furniture.py'],cwd=ROOT,check=True,capture_output=True)
assert before==[digest(p) for p in generated]
static=json.loads((WORK/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.30' and not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
for path in WORK.glob('luxury-*.png'):shutil.copy2(path,HERE/path.name)
save=WORK/'reading-progress.zds'
original=ROOT.parent/'issue410-reading-work/build/issue410-reading/reading-progress.zds'
assert digest(save)==digest(original)
result={'version':'5.8.30','issue':410,'runtime_sha256':digest(package),'runs':rows,
        'native_passes':sum(r['executed_passes'] for r in rows),'native_failures':0,
        'source_matching_package_members':len(source),'preserved_map_art_members':len(kept)-len(line_endings),
        'prior_obj_line_endings_only':line_endings,
        'deterministic_generated_outputs':len(generated),'original_save_sha256':digest(save),
        'migration':'Original 5.8.26 partial-library save retains321.75s and existing mansion table. Native current save and hub retain real table items, six seats and contamination.',
        'evidence_reuse':'Final native assertions all execute against one final30c package and one unchanged addon. Original-runtime rollback for the identical untouched legacy save is reused from validation_5826/5829, not counted as new execution.',
        'performance_scope':'New table initializes at most six blocks and six existing rest chairs once; later ticks only check its revision. No new global actor scan. No measured display-FPS or multiplayer claim.',
        'remaining':'Campaign acquisition, portable-item inventory sprites and broader placement remain a separate #410 integration. Gallery access is not campaign completion.',
        'author_acceptance':'Pending CA410-LUXURY-01; manual handoff deferred until the complete V5.8 implementation.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','native_failures','runtime_sha256','source_matching_package_members','preserved_map_art_members')}))
