"""Verify final native evidence, immutable source packaging and prior-save rollback."""
from pathlib import Path
import hashlib,json,re,shutil,zipfile
from functools import lru_cache
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent
W=R/'build/issue410-dining';N=H/'native';N.mkdir(exist_ok=True)
@lru_cache(maxsize=None)
def digest(p):
 with p.open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()
package=W/'final40a/caelum_argenteum_dev.pk3';prior=W/'prior39/caelum_argenteum_dev.pk3'
counts={'catalogue':35,'craft':98,'trade':73,'items':84,'legacy':14,'seed':150,'resume':55,
        'hub':205,'nestedhub':211,'input':2,'weather':162,'exposure':5,'studyhub':34,'priorload':17,
        'view0':4,'view1':8,'view2':14,'view3':8,'icon0':2,'icon1':2,'icon2':2,'icon3':2,'loadedtrade':14}
def collect(label,count,expected):
 log=(W/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
 run=json.loads((W/(label+'-run.json')).read_text(encoding='utf-8-sig'))
 assert run['exit_code']==0 and not run.get('timed_out'),label
 assert not re.search(r'CA410DS FAIL|VM execution aborted|Script error|failed=[1-9]|Trying to serialize out-of-bounds|This savegame needs|DIED WITH FATAL ERROR',log),label
 actual=len(re.findall(r'^CA410DS PASS ',log,re.M));assert actual==count,(label,actual,count)
 assert run['package_sha256'].lower()==digest(expected),label
 for suffix in ('.txt','-run.json'):shutil.copy2(W/(label+suffix),N/(label+suffix))
 return {'label':label,'executed_passes':actual,'package_sha256':digest(expected),'addon_sha256':run['addon_sha256'].lower()}
rows=[collect('releasea-'+case,count,package) for case,count in counts.items()]
original=[collect('prior01-seed',9,prior),collect('prior01-rollback',13,prior)]
with zipfile.ZipFile(package) as z,zipfile.ZipFile(prior) as old:
 source={p.relative_to(R/'src').as_posix():p for p in (R/'src').rglob('*') if p.is_file()}
 assert set(z.namelist())==set(source) and all(z.read(n)==p.read_bytes() for n,p in source.items())
 kept=[n for n in old.namelist() if n.startswith(('maps/','models/','sprites/','graphics/','textures/'))]
 assert all(z.read(n)==old.read(n) for n in kept)
det=json.loads((H/'determinism.json').read_text(encoding='utf-8'))
for name,expected in det['generator_outputs'].items():assert digest(R/name)==expected,name
for name,expected in det['sprite_hashes'].items():
 assert digest(R/'assets/art_source/dining_sets'/name)==expected
 assert digest(R/'src/sprites/caelum/rest_furniture'/(Path(name).stem+'A0.png'))==expected
for kind in ('world','inventory'):
 for n in range(4):shutil.copy2(W/f'dining-{kind}-{n}.png',N/f'dining-{kind}-{n}.png')
static=json.loads((W/'static-validation.txt').read_text(encoding='utf-8-sig'))
assert static['version']=='5.8.40' and not static['errors']
(H/'static-validation.json').write_text(json.dumps(static,indent=2)+'\n',encoding='utf-8')
result={'version':'5.8.40','issue':410,'base':'d3706154db2eb19c5ed440825e9e5146ca503f12',
 'runtime_sha256':digest(package),'native_passes':sum(counts.values()),'original_runtime_passes':22,'native_failures':0,
 'runs':rows,'original_runs':original,'source_matching_package_members':len(source),'unchanged_map_art_members':len(kept),
 'prior_save_sha256':digest(W/'dining-prior39.zds'),'seats_exercised':26,
 'scope':'Four complete native dining sets; manufacture/trade/learning/stock, every seat and facing, full ownership/weight/content identity, packed Box food ageing and water cooling, current save/load, native input, actual nested chest hub transport, previous study hub regression and original 5.8.39 save upgrade/rollback. Real used-set resale retains contents and stock identity.',
 'visual_review':'Agent inspected all four native world and painted-inventory views. Existing ordinary/luxury chairs and luxury table are reused; authored source PNG alpha is copied unchanged.',
 'regressions':'Probe trial04-nestedhub emitted four out-of-bounds floor/ceiling warnings and was rejected. Chest/native inventory contacts are now cleared before travel and floor/ceiling references recomputed at destination. Final nested and study hub runs are warning-free. Packing settles exposure before ownership changes and deployment re-registers chairs/blocks.',
 'limitations':'Private isolated engine checks, not a claim of measured frame presentation, multiplayer acceptance or full V5.8 completion. Retained counters in save-loaded RESULT lines are cumulative; totals count only PASS lines actually executed in each run.',
 'author_acceptance':'Pending CA410-DINING-SETS-01; prior checks preserved for grouped full-version handoff.'}
(H/'report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('native_passes','original_runtime_passes','runtime_sha256','source_matching_package_members','unchanged_map_art_members')}))
