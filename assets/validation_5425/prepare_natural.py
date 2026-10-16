"""Add the same sparse, read-only death-cause counters to both long controls."""
import argparse
import json
import zipfile
from pathlib import Path
from prepare import HERE,package
from prepare_study import inject

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);a=p.parse_args();result={}
    for variant in ('base','thermal-off'):
        target=a.directory/('natural-'+variant+'.pk3');assert not target.exists()
        with zipfile.ZipFile(a.directory/(variant+'.pk3')) as z:members={n:z.read(n) for n in z.namelist()}
        inject(members,'CaelumCombatActor','CaelumCombatActor','Die','CA304Deaths.Record(self,MeansOfDeath);')
        members['ZSCRIPT']+=b'\n#include "ca304_deaths.zs"\n'
        members['ca304_deaths.zs']=(HERE/'deaths.zs').read_bytes()
        members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA304Deaths" }\n'
        result[variant]={'sha256':package(target,members)}
    (a.directory/'natural-manifest.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
