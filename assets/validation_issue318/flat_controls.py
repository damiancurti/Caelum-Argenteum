"""Prepare render-only and sampled-method controls from the immutable flat runtime."""
from pathlib import Path
import argparse
import importlib.util
import json
import shutil
import zipfile
from flat_army_fixture import package

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
    base=ROOT/'build'/a.directory/'current'
    package(base/'freeze.pk3',{'ZSCRIPT':b'version "4.14"\n#include "freeze.zs"\n',
       'freeze.zs':(HERE/'flat_freeze.zs').read_bytes(),
       'MAPINFO':b'GameInfo { AddEventHandlers="CA318FlatFreeze" }\n'})
    dest=base.parent/'profile';dest.mkdir(exist_ok=False)
    spec=importlib.util.spec_from_file_location('ca318_prepare',HERE/'prepare.py')
    prepare=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepare)
    with zipfile.ZipFile(base/'runtime.pk3') as z:members={n:z.read(n) for n in z.namelist()}
    manifest=json.loads((base/'manifest.json').read_text());manifest['methods']=prepare.profile(members)
    members['ZSCRIPT']+=b'\n#include "ca318_profiler.zs"\n'
    members['ca318_profiler.zs']=(HERE/'profiler.zs').read_bytes()
    members['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA318Profiler" }\n'
    prepare.package(dest/'runtime.pk3',members)
    shutil.copyfile(base/'observer.pk3',dest/'observer.pk3')
    (dest/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print('Prepared freeze and profile controls')

if __name__=='__main__':main()
