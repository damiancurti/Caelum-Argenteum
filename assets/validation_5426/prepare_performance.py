"""Build matched registry controls from #304's frozen, populated MAP06 baseline."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_5425'))
import prepare_study as study

def prepare_late(out,name):
    late=out.with_name(out.name+'-late-'+name);late.mkdir(exist_ok=False)
    (late/'runtime.pk3').hardlink_to(out/(name+'.pk3'))
    shutil.copyfile(out/'observer.pk3',late/'observer.pk3')
    shutil.copyfile(ROOT/'build/issue304-late-stage/combat.zds',late/'combat.zds')
    shutil.copyfile(out/'manifest.json',late/'manifest.json')
    (late/'late.cfg').write_text('wait 5; ca_test_siege_reinforcements true; ca304_window 350; netevent ca304_measure; wait 800; quit\n',encoding='utf-8')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
    assert all(c.isalnum() or c in '-_' for c in a.directory)
    source=ROOT/'build/issue304-study-04';out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    with zipfile.ZipFile(source/'base.pk3') as z:base={n:z.read(n) for n in z.namelist()}
    registry=base.copy();changed=['MAPINFO','caelum/actors/CaelumChannelEffect.zs','caelum/world/CaelumSealClimate.zs']
    for name in changed:registry[name]=(ROOT/'src'/name).read_bytes()
    study.SELECTED['CaelumSealClimate']={'ApplyThermal':40}
    study.SELECTED['CaelumThermalEnvironment']['SampleWater']=41
    study.SELECTED['CaelumThermalShelter']={'Roof':42,'WindBlocked':43}
    study.SELECTED['CaelumThermalBody']['SampleCoverage']=44
    study.SELECTED['CaelumSealRegistry']={'Rebuild':45,'Track':46,'Forget':47}
    manifest=json.loads((source/'manifest.json').read_text());manifest['variants']={}
    # The old study's 105-tic setting describes its separate targeting variant.
    # Both controls here retain the frozen base's native 8-tic cadence.
    manifest['source_study_settings']=manifest['settings'].copy()
    manifest['settings'].update(issue=305,target_period_tics=8)
    manifest['baseline_sha256']=hashlib.sha256((source/'base.pk3').read_bytes()).hexdigest()
    manifest['changed_production_members']={name:hashlib.sha256(registry[name]).hexdigest() for name in changed}
    for name,members in [('base',base),('registry',registry),('profile-base',base.copy()),('profile-registry',registry.copy())]:
        meta={}
        if name.startswith('profile-'):meta['methods']=study.profile(members)
        meta['sha256']=study.package(out/(name+'.pk3'),members);manifest['variants'][name]=meta
    shutil.copyfile(source/'observer-v5.pk3',out/'observer.pk3')
    for name in ('study.cfg','long.cfg','budget.cfg'):shutil.copyfile(source/name,out/name)
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    for name in ('base','registry','profile-base','profile-registry'):prepare_late(out,name)
    print(json.dumps({'directory':a.directory,'variants':{k:v['sha256'] for k,v in manifest['variants'].items()}}))

if __name__=='__main__':main()
