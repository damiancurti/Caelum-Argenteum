"""Build unmodified normal packages plus a shared fixed-save observation addon."""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile
import importlib.util

spec=importlib.util.spec_from_file_location('cache_preparation',Path(__file__).with_name('prepare.py'))
prepare=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepare)

ROOT=prepare.ROOT
HERE=Path(__file__).parent

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory',required=True)
    parser.add_argument('--baseline-runtime',type=Path,required=True)
    args=parser.parse_args()
    out=ROOT/'build'/args.directory;out.mkdir(exist_ok=False)
    with zipfile.ZipFile(args.baseline_runtime) as archive:
        previous={n:archive.read(n) for n in archive.namelist()}
    current={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    hashes={}
    for name,members in [('baseline.pk3',previous),('current/baseline.pk3',current)]:
        (out/name).parent.mkdir(exist_ok=True)
        hashes[name]=prepare.prior.base.package(out/name,members)
    source=(HERE/'performance.zs').read_text(encoding='utf-8')
    for site,name in [(0,'city.pk3'),(1,'front/city.pk3')]:
        (out/name).parent.mkdir(exist_ok=True)
        hashes[name]=prepare.prior.base.package(out/name,{'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
            'probe.zs':source.replace('const SITE=0;',f'const SITE={site};').encode(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA353Performance" }\n'})
    manifest=dict(issue=353,release='5.4.43',hashes=hashes,runtime_sha256=hashes['current/baseline.pk3'],
        baseline_input_sha256=hashlib.sha256(args.baseline_runtime.read_bytes()).hexdigest(),
        normal_source_members=len(current),baseline_members=len(previous),runtime_instrumentation='none; common observation addon only')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    settings='vid_vsync false; vid_maxfps 0; cl_capfps false; con_notifylines 0; '
    (out/'seed.cfg').write_text(settings+'wait 3640; storesavepic false; save cache-battle; wait 3; netevent ca353_seed_done; wait 2; quit\n')
    (out/'measure.cfg').write_text('wait 35; '+settings+'wait 700; quit\n')
    runner=(ROOT/'assets/validation_5422/run_native.ps1').read_text(encoding='utf-8-sig')
    # Allow DXGI startup while capped, then uncap before the FPS window at tic +70.
    assert 'vid_vsync=true' in runner and 'vid_maxfps=60' in runner
    (out/'run_perf.ps1').write_text(runner,encoding='utf-8-sig')
    print(json.dumps(manifest))

if __name__=='__main__':main()
