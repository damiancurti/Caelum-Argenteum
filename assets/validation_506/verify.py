"""Check the final runtime boundary and retain exact native-evidence identities."""
from pathlib import Path
import hashlib
import importlib.util
import json
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue128'
BASE='0e2b9eab9e93096993f04beab5d5ef94d69ca0e3'
spec=importlib.util.spec_from_file_location('audit',ROOT/'assets/validation_500/audit_sources.py')
audit=importlib.util.module_from_spec(spec);spec.loader.exec_module(audit)

def canonical(data):return data.replace(b'\r\n',b'\n') if b'\0' not in data else data
def digest(data):return hashlib.sha256(data).hexdigest()
def methods(data):
    source=data.decode('utf-8-sig').replace('\r\n','\n')
    return {(c['name'],m['name']):source[m['body_start']:m['body_end']+1] for c in audit.declarations(source) for m in c['methods']}

with zipfile.ZipFile(WORK/'baseline.pk3') as z:base={n:z.read(n) for n in z.namelist()}
current={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
changed=sorted(n for n in base if canonical(base[n])!=canonical(current[n]))
allowed=['ZSCRIPT','caelum/actors/CaelumMassAIScheduler.zs','caelum/core/CaelumConstants.zs',
         'caelum/world/CaelumCannon.zs','caelum/world/CaelumPortSiege.zs','caelum/world/CaelumSiegeEncounter.zs',
         'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
assert changed==sorted(allowed),changed
assert sorted(set(current)-set(base))==['caelum/actors/CaelumPopulationState.zs']
assert set(base)<=set(current),'A production member was removed'
allowed_methods={('CaelumMassAIScheduler','WorldLoaded'),('CaelumMassAIScheduler','WorldTick'),
                 ('CaelumPortSiege','ElectCommands'),('CaelumPortSiege','EnsureTargetingRevision'),
                 ('CaelumPortSiege','AttackerTarget'),('CaelumPortSiege','OrderGuns'),('CaelumPortSiege','Tick'),
                 ('CaelumHostileMachine','ObserveGuards')}
unchanged_methods=0
for path in base:
    if not path.endswith('.zs'):continue
    before=methods(base[path]);after=methods(current[path])
    for key,body in before.items():
        if key in allowed_methods:continue
        expected=body.replace('[Caelum 5.0.5]','[Caelum 5.0.6]')
        assert after[key]==expected,(path,key)
        unchanged_methods+=1
before=methods(base['caelum/world/CaelumPortSiege.zs'])
after=methods(current['caelum/world/CaelumPortSiege.zs'])
assert before['CaelumPortSiege','AttackerTarget']==after['CaelumPortSiege','IndividualAttackerTarget']
with zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as z:
    packaged={n:z.read(n) for n in z.namelist()}
assert packaged==current,'Rebuild production PK3 after the last src change'
with zipfile.ZipFile(WORK/'current.pk3') as z:
    tested={n:z.read(n) for n in z.namelist()}
assert set(tested)==set(current)
assert all(canonical(tested[n])==canonical(current[n]) for n in current),'Final test package does not match source'
assert not any(n.startswith(('ca121_','ca128_')) or n in ['observer.zs','checks.zs','battle.zs'] for n in packaged)
result={'baseline_commit':BASE,'changed_members':changed,'added_members':sorted(set(current)-set(base)),
        'unchanged_method_bodies':unchanged_methods,'individual_target_body_exact':True,
        'normal_actor_tick_attacks_resources_unchanged':True,'map_assets_unchanged':True,
        'production_package_exact_src':True,'production_members':len(current),
        'production_sha256':digest((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()),
        'tested_current_sha256':digest((WORK/'current.pk3').read_bytes()),
        'map06_sha256':digest(current['maps/MAP06.wad']),
        'no_diagnostic_fixtures_in_production':True}
(HERE/'SOURCE_VERIFICATION.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,indent=2))
