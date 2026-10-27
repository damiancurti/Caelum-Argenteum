"""Collect final native evidence without counting serialized cumulative totals."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue502-weather'
PERF=ROOT/'build/issue502-hygiene'
native=HERE/'native'
native.mkdir(exist_ok=True)
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
labels=[('weather-delivery-'+name,'CA502W') for name in ['core','seed','resume','hub','perf','legacy']]
labels += [('weather-delivery-'+name,tag) for name,tag in [('objects','CA502O'),('storage','CA502O'),('limbo','CA502H'),('limbohub','CA502H')]]
labels += [('weather-old-seed27','CA502W'),('weather-old-rollback27','CA502W')]
rows=[]
for label,tag in labels:
    log=(WORK/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
    record=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    assert record['exit_code']==0 and not record.get('timed_out')
    assert not re.search(tag+r' FAIL|VM execution aborted|Script error|fail(?:ed|ures)=[1-9]',log),label
    rows.append({'label':label,'executed_passes':len(re.findall('^'+tag+' PASS ',log,re.M)),
                 'runtime_sha256':record['package_sha256'].lower(),'addon_sha256':record['addon_sha256'].lower()})
    for suffix in ['.txt','-run.json']:shutil.copy2(WORK/(label+suffix),native/(label+suffix))
package=WORK/'final28b/caelum_argenteum_dev.pk3'
old=ROOT.parent/'issue411-interior-work/build/issue411-interior/final27/caelum_argenteum_dev.pk3'
with zipfile.ZipFile(package) as current,zipfile.ZipFile(old) as previous:
    sources={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(current.namelist())==set(sources)
    assert all(current.read(name)==path.read_bytes() for name,path in sources.items())
    retained=[name for name in previous.namelist() if name.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
    assert all(current.read(name)==previous.read(name) for name in retained)
assert all(r['runtime_sha256']==digest(package) for r in rows if r['label'].startswith('weather-delivery-'))
timings=[]
for label in ['weather-perf-base27','weather-perf-final28b']:
    result=json.loads((PERF/(label+'.json')).read_text())
    assert result['spawned_objects']==result['receivers_exposed']==1000
    assert result['runtime_sha256']==digest(package if 'final' in label else old)
    timings.append(result)
    for suffix in ['.json','.txt','-presentmon.txt']:
        shutil.copy2(PERF/(label+suffix),native/(label+suffix))
uncached=json.loads((WORK/'weather-probe-perf01-run.json').read_text(encoding='utf-8-sig'))
for suffix in ['.txt','-run.json']:
    shutil.copy2(WORK/('weather-probe-perf01'+suffix),native/('weather-probe-perf01'+suffix))
with zipfile.ZipFile(WORK/'probe/caelum_argenteum_dev.pk3') as archive:
    (HERE/'uncached-prototype.zs').write_bytes(archive.read('caelum/survival/CaelumContaminationObject.zs'))
def replay_time(label):
    text=(WORK/(label+'.txt')).read_text(encoding='utf-8')
    m=re.search(r'thousand_day_ms=([0-9.]+) checksum=([0-9.]+)',text)
    return {'milliseconds':float(m[1]),'checksum':float(m[2])}
before=replay_time('weather-probe-perf01');after=replay_time('weather-delivery-perf')
assert before['checksum']==after['checksum']
static_bytes=(WORK/'static-validation.json').read_bytes()
static=json.loads(static_bytes.decode('utf-16' if static_bytes.startswith(b'\xff\xfe') else 'utf-8-sig'))
assert not static['errors']
(HERE/'static-validation.json').write_text(json.dumps(static,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
result={'version':'5.8.28','issue':502,'runtime_sha256':digest(package),'previous_runtime_sha256':digest(old),
        'runs':rows,'native_passes':sum(r['executed_passes'] for r in rows),'native_failures':0,'static_errors':0,
        'source_matching_package_members':len(sources),'preserved_map_art_members':len(retained),
        'original_save_sha256':digest(WORK/'weather-legacy27.zds'),
        'performance':timings,'replay_comparison':{'uncached':before,'shared_cache':after,'uncached_runtime_sha256':uncached['package_sha256'].lower()},
        'migration':'Revision1/2 dirt preserved; revision2 constant intervals still settled; exterior history starts at migration. Original native save forward-loaded and reopened in unchanged original runtime.',
        'limitations':'Natural weather for existing physical-object nodes only. Temporary seals, NPC physiology, unloaded housekeeping and remaining contact/stackable adapters still pending. Replay remains linear in elapsed civil minutes; the cache bounds memory, not historical time. No displayed-frame/GPU FPS claim.',
        'author_acceptance':'CA502-WEATHER-HISTORY-01 pending; defer all manual checks/questions until allV5.8 implementation is ready.'}
(HERE/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ['native_passes','native_failures','static_errors','runtime_sha256','source_matching_package_members','preserved_map_art_members']}))
