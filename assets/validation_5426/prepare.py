"""Reuse accepted seal geometry/tests and freeze a previous-scan oracle."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('archive_helpers',HERE.parent/'validation_5425/prepare.py')
shared=importlib.util.module_from_spec(spec);spec.loader.exec_module(shared)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
    subprocess.run(['python',str(HERE.parent/'validation_5421/prepare.py'),'--directory',a.directory],check=True)
    out=ROOT/'build'/a.directory
    previous=ROOT/'build/issue304-final-01/production.pk3'
    assert hashlib.sha256(previous.read_bytes()).hexdigest()=='ba234504f6cd502285e040f5276edb49ae5eea3b8bea786c62632451aa417e81'
    with zipfile.ZipFile(previous) as z:old=z.read('caelum/world/CaelumSealClimate.zs').decode('utf-8-sig')
    method=old[old.index('    static double,double,double,double Delta('):old.index('    static void ApplyWeather(')]
    method=method.replace('!Active(effect)','!CaelumSealClimate.Active(effect)').replace('!ClearPath(effect,body)','!CaelumSealClimate.ClearPath(effect,body)')
    with zipfile.ZipFile(out/'seal.pk3') as z:members={n:z.read(n) for n in z.namelist()}
    legacy=out.with_name(out.name+'-legacy');legacy.mkdir(exist_ok=False)
    shutil.copyfile(previous,legacy/'production.pk3');shutil.copyfile(out/'seal.pk3',legacy/'registry.pk3')
    members['ZSCRIPT']+=b'\n#include "golden.zs"\n#include "registry.zs"\n'
    members['golden.zs']=('class CA305Golden : Object play {\n'+method+'}\n').encode()
    members['registry.zs']=(HERE/'registry.zs').read_bytes()
    members['MAPINFO']=members['MAPINFO'].replace(b'"CA252Legacy","CA252Probe"',b'"CA252Legacy","CA305Probe"')
    digest=shared.package(out/'registry.pk3',members)
    seed='storesavepic false; wait 100; netevent c252_setup; netevent c252_seed; wait 2; save seal.zds; wait 70; netevent c252_done; wait 35; quit\n'
    for folder in (out,legacy):(folder/'seed.cfg').write_text(seed,encoding='utf-8')
    scripts={
        'registry.cfg':'wait 100; netevent c252_setup; netevent c305_equivalence; netevent c305_done; wait 35; quit\n',
        'registry-load.cfg':'wait 5; netevent c305_loaded; netevent c305_done; wait 35; quit\n',
        'registry-travel.cfg':'wait 5; netevent c305_loaded; changemap MAP98; wait 20; netevent c252_travelled; netevent c305_empty; changemap MAP99; wait 20; netevent c252_travelled; netevent c305_empty; netevent c305_done; wait 35; quit\n'}
    for name,t in scripts.items():(out/name).write_text(t,encoding='utf-8')
    (out/'registry-manifest.json').write_text(json.dumps({'fixture_sha256':digest,'previous_runtime_sha256':hashlib.sha256(previous.read_bytes()).hexdigest(),'oracle':'exact previous Delta body, shared unchanged Active/ClearPath rules'},indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
