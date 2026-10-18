"""Reuse the accepted legend fixture with the author's complete-collapse contract."""
from pathlib import Path
import argparse
import importlib.util
import json
import zipfile
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('quick',ROOT/'assets/validation_5422/prepare.py')
quick=importlib.util.module_from_spec(spec);spec.loader.exec_module(quick)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);a=p.parse_args()
assert a.directory.startswith('issue321-') and all(c in 'abcdefghijklmnopqrstuvwxyz0123456789-_' for c in a.directory)
out=ROOT/'build'/a.directory;out.mkdir(exist_ok=False)
probe=(ROOT/'assets/validation_5431/probe.zs').read_text(encoding='utf-8').replace('Leyenda [%s]','ver leyenda (%s)').replace('Legend [%s]','show legend (%s)')
fixture={'ZSCRIPT':b'version "4.14"\n#include "quick.zs"\n#include "probe.zs"\n',
    'quick.zs':(ROOT/'assets/validation_5422/probe.zs').read_bytes(),'probe.zs':probe.encode(),
    'maps/MAP99.wad':quick.seal.wad(),'maps/MAP98.wad':quick.seal.wad(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA321Probe" }\ncluster 99 { hub }\nmap MAP99 "Legend panel fixture" { cluster=99 nointermission sky1="SKY1",0 }\nmap MAP98 "Legend hub" { cluster=99 nointermission sky1="SKY1",0 }\n'}
package=quick.seal.shared.package
manifest={'runtime_sha256':package(out/'production.pk3',{f.relative_to(ROOT/'src').as_posix():f.read_bytes() for f in (ROOT/'src').rglob('*') if f.is_file()}),
    'fixture_sha256':package(out/'quick.pk3',fixture)}
start='wait 100; netevent c282_setup; wait 35; con_notifytime 0; am_overlay 0; togglemap; wait 10; '
done='event c321_done; wait 10; quit\n'
scripts={'ui':start+'event c321_hidden; event c321_text; screenshot quick-hidden.png; wait 5; ca_map_legend; wait 5; event c321_visible; screenshot quick-expanded.png; wait 5; ca_map_legend; wait 5; event c321_hidden; bind f9 ca_map_legend; unbind L; wait 5; event c321_rebind; ca_map_legend; wait 5; togglemap; wait 5; togglemap; wait 5; event c321_hidden; mapbind f9 am_setmark; wait 5; event c321_shadowed; unmapbind f9; unbind f9; wait 5; event c321_unbound; screenshot quick-unbound.png; wait 5; '+done,
    'save':start+'ca_map_legend; wait 5; event c321_visible; storesavepic false; save legend.zds; wait 35; '+done,
    'load':'wait 35; togglemap; wait 5; event c321_hidden; ca_map_legend; wait 5; event c321_visible; changemap MAP98; wait 70; togglemap; wait 5; event c321_hidden; '+done,
    'manual':'wait 100; language es; bind L ca_map_legend; bind M togglemap; unmapbind M; netevent c321_manual; wait 35; am_overlay 0; togglemap; event c321_done;\n'}
for name,code in scripts.items():(out/(name+'.cfg')).write_text(code,encoding='utf-8',newline='\n')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest))
