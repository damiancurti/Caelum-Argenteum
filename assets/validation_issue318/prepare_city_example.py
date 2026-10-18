"""Prepare an isolated user-supplied reference city; never distribute its assets.

The third-party map stays under build and is not modified. Attribution and hashes
identify the example; they do not grant redistribution or incorporation rights.
"""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile
from geometry_verify import package

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--archive',type=Path,required=True)
p.add_argument('--directory',default='issue318-city-example')
p.add_argument('--kind',choices=['bigcity','hgc'],default='bigcity')
a=p.parse_args();out=ROOT/'build'/a.directory/'original';out.mkdir(exist_ok=False,parents=True)
with zipfile.ZipFile(a.archive) as z:
    if a.kind=='bigcity':
        for name,target in [('gz_bigcity.pk3','runtime.pk3'),('ObAddon_Textures.wad','ObAddon_Textures.wad'),('Voxel Vehicles.pk3','Voxel Vehicles.pk3')]:
            (out/target).write_bytes(z.read(name))
    else:
        package(out/'runtime.pk3',{'hgccity.wad':z.read('HGCCITY-R1.wad')})
package(out/'observer.pk3',{'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
    'probe.zs':(HERE/'city_example.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA318CityExampleProbe" }\n',
    'CVARINFO':b'server int ca318_phase=0; server int ca318_site=0; server int ca318_pitch=0; server int ca318_warmup=140; server int ca318_window=350; server bool ca318_freeze=false; server bool ca_test_siege_reinforcements=false; server bool ca318_fixed=false; server float ca318_x=0; server float ca318_y=0; server float ca318_height=0; server float ca318_yaw=0;\n'})
(out/'manifest.json').write_text(json.dumps({'archive_sha256':hashlib.sha256(a.archive.read_bytes()).hexdigest(),
    'runtime_sha256':hashlib.sha256((out/'runtime.pk3').read_bytes()).hexdigest(),
    'map':'OPENCITY' if a.kind=='bigcity' else 'MAP01','author':'inkoalawetrust' if a.kind=='bigcity' else 'Hans George Campbell',
    'scope':'External reference map; no Caelum runtime or soldiers'},indent=2)+'\n')
print(out)
