"""Verify maximum-body passing, keyed boss retreat and pre-boss exit guards.

The fixture opens P4 with its real key and activates the existing wounded-retreat
state. It does not simulate a complete boss fight or grant the Ace of Cups.
"""
from pathlib import Path
import argparse
import json
import zipfile
from run_native import run,digest,HERE,ENGINE

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    runtime=args.runtime.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    fixture=out/'boss.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,data in sorted({'ZSCRIPT':b'version "4.14.2"\n#include "probe.zs"',
            'MAPINFO':b'gameinfo { AddEventHandlers="CA454BossProbe" }',
            'probe.zs':(HERE/'boss_probe.zs').read_bytes()}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,12,0,0,0)),data)
    result=run(runtime,out,'retreat',fixture,extra='wait 2100; netevent ca454_boss_report; screenshot boss-final.png; ')
    report=dict(issue=454,scope=__doc__.strip(),runtime_sha256=digest(runtime),engine_sha256=digest(ENGINE),fixture_sha256=digest(fixture),runs=[result])
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'passed':result['passed'],'output':str(out)}));raise SystemExit(not result['passed'])

if __name__=='__main__':main()
