"""Freeze the original runtime and test reversible, idempotent save migration."""
from prepare import ROOT,HERE,OUT,BASE,package
import subprocess,zipfile,io

if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
    raise SystemExit('Finish native runs before replacing packages.')
archive=subprocess.check_output(['git','archive','--format=zip',BASE,'src'])
with zipfile.ZipFile(io.BytesIO(archive)) as z:
    old={n[4:]:z.read(n) for n in z.namelist() if n.startswith('src/') and not n.endswith('/')}
with zipfile.ZipFile(OUT/'checks.pk3') as z:room=z.read('maps/CA135.wad')
for name in ('old','new'):
    (OUT/name).mkdir(exist_ok=True)
    if name=='old':package(name+'/production.pk3',old)
    else:(OUT/name/'production.pk3').write_bytes((OUT/'production.pk3').read_bytes())
    members={'maps/CA135.wad':room,'maps/CA135B.wad':room.replace(b'CA135',b'C135B'),
        'persistence.zs':(HERE/'persistence.zs').read_bytes()}
    script='version "4.14"\n#include "persistence.zs"\n';handlers='"CA135Seed"'
    if name=='new':
        script+='#include "upgrade.zs"\n';handlers+=',"CA135Upgrade"'
        members['upgrade.zs']=(HERE/'upgrade.zs').read_bytes()
    members['ZSCRIPT']=script.encode()
    members['MAPINFO']=('cluster 435 { hub }\nmap CA135 "Persistence" { cluster=435 }\n'
        'map CA135B "Hub excursion" { cluster=435 }\nGameInfo { AddEventHandlers='+handlers+' }\n').encode()
    package(name+'/persistence.pk3',members)
(OUT/'seed.cfg').write_text('wait 110; save ca135-original; wait 5; quit\n',encoding='utf-8')
(OUT/'upgrade.cfg').write_text('wait 5; save ca135-migrated; wait 5; quit\n',encoding='utf-8')
(OUT/'load.cfg').write_text('wait 5; quit\n',encoding='utf-8')
(OUT/'hub.cfg').write_text('wait 5; changemap CA135B; wait 10; changemap CA135; wait 5; quit\n',encoding='utf-8')
print('Prepared original 5.1.4 and current 5.1.5 persistence packages.')
