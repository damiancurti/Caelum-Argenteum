"""Retain surface-stage evidence, validating exact reuse boundaries and source bytes."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

here=Path(__file__).resolve().parent
root=here.parents[1]
work=root/'build/issue502-hygiene'
out=here/'surfaces'
package=work/'surface-final05/caelum_argenteum_dev.pk3'
digest=hashlib.sha256(package.read_bytes()).hexdigest()
cases=['surface-rules','surface-weather','surface-rain-live',
       'surface-save','surface-load','surface-hub','surface-legacy','clean-core']
labels=['surface-final03-'+case for case in cases]
labels += ['surface-final05-native','surface-final05-forecast','surface-final04-wet-floor',
           'surface-final04-bath','surface-final04-toilet','surface-final05-capture','surface-original-rollback']
(out/'native').mkdir(parents=True,exist_ok=True)
verified={}
records=[]
for label in labels:
    log=(work/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    assert not re.search(r'^CA502H FAIL|Script error|VM execution aborted|failures=[1-9]',log,re.M),label
    assert 'CA502H RESULT' in log,label
    row=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert row['exit_code']==0 and not row.get('timed_out'),label
    runtime=row['runtime']
    if runtime not in verified:
        with zipfile.ZipFile(package) as final,zipfile.ZipFile(work/runtime/'caelum_argenteum_dev.pk3') as tested:
            names=set(tested.namelist())
            differences=[name for name in final.namelist() if name not in names or final.read(name)!=tested.read(name)]
            if runtime in ('surface-final03','surface-final04'):
                name='caelum/survival/CaelumContaminationSurface.zs'
                assert differences==[name],differences
                normalized=tested.read(name)
                if runtime=='surface-final03':
                    assert normalized.count(b'user.WaterLevel==0 && ')==1
                    normalized=normalized.replace(b'user.WaterLevel==0 && ',b'')
                for part in ('Floor','Wall'):
                    old=f'if({part}!=null){{Sheet.Sync({part},Stamp);'.encode()
                    new=f'if({part}!=null){{if({part}.Profile==0)CaelumContaminationSurfaceContact.Configure(user,thermal,{part});Sheet.Sync({part},Stamp);'.encode()
                    assert normalized.count(old)==1
                    normalized=normalized.replace(old,new)
                assert final.read(name)==normalized
            elif runtime=='surface-final05':assert not differences
            else:assert label=='surface-original-rollback' and runtime=='clean-final06'
        verified[runtime]=differences
    records.append({'label':label,'passes':len(re.findall(r'^CA502H PASS',log,re.M)),
                    'runtime':runtime,'package_sha256':row['package_sha256'].lower(),
                    'source_differences':verified[runtime]})
    for suffix in ('.txt','-run.json'):shutil.copyfile(work/(label+suffix),out/'native'/(label+suffix))
with zipfile.ZipFile(package) as current,zipfile.ZipFile(work/'clean-final06/caelum_argenteum_dev.pk3') as prior:
    for name in current.namelist():assert current.read(name)==(root/'src'/name).read_bytes(),name
    maps=[n for n in current.namelist() if n.startswith('maps/')]
    art=[n for n in current.namelist() if n.startswith(('sprites/','models/','graphics/','textures/','flats/'))]
    for name in maps+art:assert current.read(name)==prior.read(name),name
    count=len(current.namelist())
(out/'captures').mkdir(exist_ok=True)
for name in ('surface-lab.png','surface-rain.png'):shutil.copyfile(work/name,out/'captures'/name)
(out/'performance').mkdir(exist_ok=True)
performance=[]
for scene in ('mansion','sewer','city','ground'):
    for prefix in ('surface-perf02-base-','surface-perf04-current-'):
        label=prefix+scene
        metric=json.loads((work/(label+'-metrics.json')).read_text(encoding='utf-8'))
        performance.append(metric)
        for suffix in ('.txt','-run.json','-metrics.json'):shutil.copyfile(work/(label+suffix),out/'performance'/(label+suffix))
for suffix in ('-presentmon.txt','-run.json'):
    shutil.copyfile(work/('surface-perf-current-mansion'+suffix),out/'performance'/('presentmon-denied'+suffix))
report={'issue':502,'version':'5.8.12','package_sha256':digest,'source_members':count,
        'passes':sum(row['passes'] for row in records),'runs':records,'performance':performance,
        'unchanged_maps':len(maps),'unchanged_art_members':len(art),'author_test':'CA502-SURFACE-01 pending',
        'reuse':'Verified byte deltas: final04 adds immersed support; final05 initializes unseen forecast climate before catch-up. Both changed paths have focused native checks; final03 arithmetic/save/hub/cleaning and final04 wet/bath/toilet remain applicable. Performance uses final04: final05 only changes forecast capture, outside those idle windows.',
        'limits':['Player-to-floor/wall and outer equipment only; other actors, combat and housekeeping remain unfinished.',
                  'One representative foot zone and nearest torso wall; no physical contact mesh is invented.',
                  'Unloaded catch-up uses saved regional climate/shelter; transient magical emitters are not reconstructed while absent.',
                  'No multiplayer acceptance. Fixed-camera render callbacks are not application presentation or whole-map FPS acceptance.'],
        'resolved_probes':['Reserved ZScript local/method names corrected before native checks.',
                           'Diagnostic climate marker initially collided with HousePortal editor number; production number30950 is reused.',
                           'Fixture hub uses campaign cluster434/nointermission; saved proof zone is away from arrival spawn.',
                           'Old-save diagnostics dispatch through an already-saved event handler.',
                           'Near-zero drizzle uses a stable integral series; missing forecast weather is null-safe.',
                           'Bath regression runs the accepted bath addon, rather than the surface diagnostic dispatch.',
                           'New forecast zones configure climate before replaying elapsed time, without creating live tiles.',
                           'Native pool-bottom contact remains active while immersed.']}
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({key:report[key] for key in ('passes','source_members','unchanged_maps','unchanged_art_members','package_sha256')},indent=2))
