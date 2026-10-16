"""Prepare matched saved-combat probes; keep native save package names identical."""
import argparse
import json
import shutil
from pathlib import Path
from prepare import ROOT

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);a=p.parse_args()
    for name,variant in [('stage','deep-no-seal-scan'),('on','deep-base'),('off','deep-thermal-off')]:
        out=ROOT/'build'/('issue304-late-'+name);out.mkdir(exist_ok=False)
        shutil.copyfile(a.directory/(variant+'.pk3'),out/'runtime.pk3')
        shutil.copyfile(a.directory/'observer-v5.pk3',out/'observer.pk3')
        shutil.copyfile(a.directory/'manifest.json',out/'manifest.json')
        if name=='stage':
            script='ca_test_siege_reinforcements true; ca304_window 10000; storesavepic false; wait 6000; save combat.zds; wait 70; echo "CA304 DONE failures=0 staged combat save requested"; quit\n'
        else:
            script='wait 5; ca_test_siege_reinforcements true; ca304_window 350; netevent ca304_measure; wait 730; quit\n'
        (out/'run.cfg').write_text(script,encoding='utf-8')
    print(json.dumps({'staging':'thermal retained, empty seal lookup bypassed; no active channels',
        'measurement':'same saved combat; 350 warm-up plus 350 observed tics; instrumented attribution only'}))

if __name__=='__main__':main()
