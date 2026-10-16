"""Build a zero-seal-query cost control; valid only with zero channel actors."""
import argparse
import json
import zipfile
from pathlib import Path
from prepare import package
from prepare_study import inject

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);a=p.parse_args()
    with zipfile.ZipFile(a.directory/'base.pk3') as z:members={n:z.read(n) for n in z.namelist()}
    inject(members,'CaelumSealClimate','CaelumSealClimate','Delta','return 0,0,0,baseDirection;')
    target=a.directory/'no-seal-scan.pk3';assert not target.exists()
    digest=package(target,members)
    (a.directory/'no-seal-scan-manifest.json').write_text(json.dumps({'sha256':digest,'source':'base.pk3',
        'scope':'Diagnostic only: Delta returns zero. Valid cost control only when no seals are active; no production change.'},indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
