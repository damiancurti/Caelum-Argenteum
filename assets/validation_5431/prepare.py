"""Reuse quick-item native launch infrastructure for issue #321 UI tests."""
from pathlib import Path
import argparse
import importlib.util
import json

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('quick',HERE.parent/'validation_5422/prepare.py')
quick=importlib.util.module_from_spec(spec);spec.loader.exec_module(quick)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
    if not a.directory or any(c not in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in a.directory):p.error('Plain lowercase directory required')
    out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
    package=quick.seal.shared.package
    manifest={'runtime_sha256':package(out/'production.pk3',{f.relative_to(ROOT/'src').as_posix():f.read_bytes() for f in (ROOT/'src').rglob('*') if f.is_file()}),
        'fixture_sha256':package(out/'quick.pk3',{
            'ZSCRIPT':b'version "4.14"\n#include "quick.zs"\n#include "probe.zs"\n',
            'quick.zs':(HERE.parent/'validation_5422/probe.zs').read_bytes(),'probe.zs':(HERE/'probe.zs').read_bytes(),
            'maps/MAP99.wad':quick.seal.wad(),'maps/MAP98.wad':quick.seal.wad(),
            'MAPINFO':b'GameInfo { AddEventHandlers="CA321Probe" }\ncluster 99 { hub }\nmap MAP99 "Map legend fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Legend hub" { cluster=99 nointermission sky1="SKY1",0 }\n'})}
    start='wait 100; netevent c282_setup; wait 35; con_notifytime 0; am_overlay 0; togglemap; wait 10; '
    done='event c321_done; wait 10; quit\n'
    commands={
        'ui.cfg':start+'event c321_hidden; event c321_text; screenshot quick-hidden.png; wait 5; ca_map_legend; wait 5; event c321_visible; screenshot quick-expanded.png; wait 5; ca_map_legend; wait 5; event c321_hidden; bind f9 ca_map_legend; unbind L; wait 5; event c321_rebind; ca_map_legend; wait 5; togglemap; wait 5; togglemap; wait 5; event c321_hidden; mapbind f9 am_setmark; wait 5; event c321_shadowed; unmapbind f9; unbind f9; wait 5; event c321_unbound; screenshot quick-unbound.png; wait 5; '+done,
        'save.cfg':start+'ca_map_legend; wait 5; event c321_visible; storesavepic false; save legend.zds; wait 35; '+done,
        'load.cfg':'wait 35; togglemap; wait 5; event c321_hidden; ca_map_legend; wait 5; event c321_visible; changemap MAP98; wait 70; togglemap; wait 5; event c321_hidden; '+done,
        'manual.cfg':'wait 100; language es; bind L ca_map_legend; bind M togglemap; unmapbind M; netevent c321_manual; wait 35; am_overlay 0; togglemap; event c321_done;\n'}
    for name,code in commands.items():(out/name).write_text(code,encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(manifest))

if __name__=='__main__':main()
