"""Prepare a manual MAP06 corpse demonstration without replacing the dev runtime."""
import argparse
import json
from prepare import ROOT,HERE,package

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
    assert all(c.isalnum() or c in '-_' for c in a.directory)
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    digest=package(out/'author.pk3',{'ZSCRIPT':b'version "4.14"\n#include "author.zs"\n',
        'author.zs':(HERE/'author.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers="CA304Author" }\n'})
    script='bind f6 "netevent ca304_bodies"; bind f7 "netevent ca304_raise"; bind f8 "netevent ca304_count"; language esp; snd_mastervolume 0.05\n'
    (out/'author.cfg').write_text(script,encoding='utf-8')
    (out/'smoke.cfg').write_text(script+'wait 75; netevent ca304_bodies; wait 35; netevent ca304_count; netevent ca304_raise; wait 5; netevent ca304_count; wait 5; echo "CA304 DONE failures=0 manual fixture smoke"; quit\n',encoding='utf-8')
    (out/'clock.cfg').write_text('wait 75; netevent ca304_bodies; wait 35; netevent ca304_clock; echo "CA304 DONE failures=0 archived clock probe"; wait 5; quit\n',encoding='utf-8')
    (out/'manifest.json').write_text(json.dumps({'fixture_sha256':digest},indent=2)+'\n',encoding='utf-8')

if __name__=='__main__':main()
