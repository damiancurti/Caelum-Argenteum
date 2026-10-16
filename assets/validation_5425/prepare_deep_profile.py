"""Refine thermal attribution without changing or replacing the paired controls."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path
import prepare_study as study

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path)
    p.add_argument('--variants',nargs='+',default=['base','thermal-off']);a=p.parse_args()
    study.SELECTED['CaelumSealClimate']={'ApplyThermal':40}
    study.SELECTED['CaelumThermalEnvironment']['SampleWater']=41
    study.SELECTED['CaelumThermalShelter']={'Roof':42,'WindBlocked':43}
    study.SELECTED['CaelumThermalBody']['SampleCoverage']=44
    result={}
    for variant in a.variants:
        source=a.directory/(variant+'.pk3');dest=a.directory/('deep-'+variant+'.pk3')
        assert not dest.exists(),dest
        with zipfile.ZipFile(source) as z:members={n:z.read(n) for n in z.namelist()}
        methods=study.profile(members)
        result[variant]={'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
                         'sha256':study.package(dest,members),'methods':methods}
    dest=a.directory/('deep-manifest-'+('-'.join(a.variants))+'.json')
    assert not dest.exists();dest.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
