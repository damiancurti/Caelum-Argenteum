"""Test exact-layout save continuation, hub returns and reversible rollback.

Run after normal and LegacyMap06Furnished builders produce current/runtime.pk3
and legacy/runtime.pk3 in the selected new evidence directory. Uses copies only.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from geometry_verify import package

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    a=p.parse_args();out=ROOT/'build'/a.directory
    base=out/'base';base.mkdir(exist_ok=False)
    shutil.copyfile(ROOT/'build/issue318-geometry-01/base/runtime.pk3',base/'runtime.pk3')
    members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs':(HERE/'geometry_saves.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA318GeometrySaveProbe" }\n'}
    for mode in ('base','legacy','current'):
        work=out/mode
        package(work/'geometry-saves.pk3',members)
        (work/'manifest.json').write_text(json.dumps({'runtime_sha256':hashlib.sha256((work/'runtime.pk3').read_bytes()).hexdigest()},indent=2)+'\n')
    scripts={
        'seed':'wait 100; netevent c318_seed; netevent c318_saved; storesavepic false; save inside.zds; wait 5; netevent c318_done; wait 5; quit\n',
        'load':'wait 20; netevent c318_saved; storesavepic false; save repeated.zds; wait 5; netevent c318_done; wait 5; quit\n',
        'hub-seed':'wait 20; netevent c318_saved; changemap MAP07; wait 30; netevent c318_hub; storesavepic false; save outside.zds; wait 5; netevent c318_done; wait 5; quit\n',
        'hub-load':'wait 20; netevent c318_hub; changemap MAP06; wait 30; netevent c318_saved; storesavepic false; save returned.zds; wait 5; netevent c318_done; wait 5; quit\n',
        'catalogue':'wait 100; netevent c318_seed; netevent c318_catalogue; netevent c318_done; wait 5; quit\n',
    }
    for name,value in scripts.items():(out/(name+'.cfg')).write_text(value)
    def run(mode,label,script,save=None):
        cmd=[sys.executable,str(HERE/'run.py'),'--directory',a.directory,'--variant',mode,'--label',label,
             '--fixture','geometry-saves.pk3','--global-presentmon','--script',str(out/(script+'.cfg'))]
        if save:cmd+=['--load',save]
        subprocess.run(cmd,cwd=ROOT,check=True)
    run('base','save-inside','seed')
    run('base','save-outside','hub-seed','inside.zds')
    for name in ('inside.zds','outside.zds'):shutil.copyfile(base/name,out/'legacy'/name)
    run('legacy','continue-inside','load','inside.zds')
    run('legacy','continue-repeated','load','repeated.zds')
    run('legacy','continue-hub','hub-load','outside.zds')
    run('legacy','continue-returned','load','returned.zds')
    # The original package/save pair remains independently usable.
    run('base','rollback-inside','load','inside.zds')
    run('base','rollback-hub','hub-load','outside.zds')
    run('current','compact-new-map','seed')
    run('current','compact-reload','load','inside.zds')
    run('current','compact-hub-seed','hub-seed','inside.zds')
    run('current','compact-hub-return','hub-load','outside.zds')
    for mode in ('base','legacy','current'):
        run(mode,'catalogue','catalogue')

if __name__=='__main__':main()
