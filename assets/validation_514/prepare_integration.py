"""Build small persistence, immersion and established native-effort regressions."""
from prepare import HERE, OUT, ROOT, package
import shutil
import zipfile
import subprocess
from geometry_maps import wad, geo_wad

if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
    raise SystemExit('Finish the owned native run before replacing packages.')

with zipfile.ZipFile(OUT/'checks.pk3') as z:
    room=z.read('maps/CA140.wad')
for folder in ('old','new'):
    (OUT/folder).mkdir(exist_ok=True)
    shutil.copyfile(OUT/('baseline.pk3' if folder=='old' else 'production.pk3'),OUT/folder/'production.pk3')
    script=b'version "4.14"\n#include "persistence.zs"\n'
    handlers='"CA140Seed"'
    members={'persistence.zs':(HERE/'persistence.zs').read_bytes(),
        'maps/CA140.wad':room,'maps/CA140B.wad':room.replace(b'CA140',b'C140B')}
    if folder=='new':
        script+=b'#include "upgrade.zs"\n'
        members['upgrade.zs']=(HERE/'upgrade.zs').read_bytes();handlers+=',"CA140Upgrade"'
        members['CVARINFO']=b'server bool ca140_queue_seed=false;\n'
    members['ZSCRIPT']=script
    members['MAPINFO']=('cluster 434 { hub }\nmap CA140 "Persistence" { cluster=434 }\n'
        'map CA140B "Hub excursion" { cluster=434 }\nGameInfo { AddEventHandlers='+handlers+' }\n').encode()
    package(folder+'/persistence.pk3',members)
(OUT/'seed.cfg').write_text('wait 60; save ca140-rev3; wait 5; quit\n')
(OUT/'upgrade.cfg').write_text('wait 5; save ca140-rev6; wait 5; quit\n')
(OUT/'energy-seed.cfg').write_text('ca140_queue_seed true; wait 65; save ca140-energy; wait 5; quit\n')
(OUT/'load.cfg').write_text('wait 5; quit\n')
(OUT/'hub.cfg').write_text('wait 5; changemap CA140B; wait 10; changemap CA140; wait 5; quit\n')
members={'maps/QA130G.wad':geo_wad,'MAPINFO':b'map QA130G "Thermal geometry" { }\nGameInfo { AddEventHandlers="CA130Geometry" }\n',
    'ZSCRIPT':b'version "4.14"\n#include "geometry.zs"\n',
    'geometry.zs':(ROOT/'assets/validation_510/geometry.zs').read_bytes()}
members['ZSCRIPT']+=b'\n#include "immersion.zs"\n#include "drying.zs"\n'
members['immersion.zs']=(HERE/'immersion.zs').read_bytes()
members['drying.zs']=(HERE/'drying.zs').read_bytes()
members['MAPINFO']=members['MAPINFO'].replace(b'"CA130Geometry"',b'"CA130Geometry", "CA140Immersion", "CA140Drying"')
package('immersion.pk3',members)
(OUT/'immersion.cfg').write_text('wait 40; quit\n')
members={'maps/QA130A.wad':wad,'MAPINFO':b'map QA130A "Thermal effects" { }\nGameInfo { AddEventHandlers="CA130Effects" }\n',
    'ZSCRIPT':b'version "4.14"\n#include "effects.zs"\n',
    'effects.zs':(ROOT/'assets/validation_510/effects.zs').read_bytes()}
for name in members:
    if name.endswith('.zs'):
        members[name]=members[name].replace(b'Near(100-User.CurrentThirst,thirst*2)',b'Near(100-User.CurrentThirst,thirst)').replace(b'native heat doubles thirst depletion once',b'native heat has no abstract Thirst multiplier')
package('effects.pk3',members)
(OUT/'effects.cfg').write_text('wait 45; +forward; wait 35; -forward; wait 11; +jump; wait 1; -jump; wait 23; quit\n')
print('Prepared persistence and small native geometry/effort fixtures.')
