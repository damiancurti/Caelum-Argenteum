"""Build original and upgraded carbine save controls with identical package names."""
from prepare import ROOT,HERE,OUT,BASE,package,room
import subprocess,zipfile,io

if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
    raise SystemExit('Finish native runs before replacing packages.')
archive=subprocess.check_output(['git','archive','--format=zip',BASE,'src'])
with zipfile.ZipFile(io.BytesIO(archive)) as z:
    old={n[4:]:z.read(n) for n in z.namelist() if n.startswith('src/') and not n.endswith('/')}
for name in ('old','new'):
    (OUT/name).mkdir(exist_ok=True)
    if name=='old':package(name+'/production.pk3',old)
    else:(OUT/name/'production.pk3').write_bytes((OUT/'production.pk3').read_bytes())
    members={'maps/CA143.wad':room(),'maps/CA143B.wad':room().replace(b'CA143',b'C143B'),
        'persistence.zs':(HERE/'persistence.zs').read_bytes()}
    script='version "4.14"\n#include "persistence.zs"\n';handlers='"CA143Seed"'
    if name=='new':
        script+='#include "upgrade.zs"\n';handlers+=',"CA143Upgrade"'
        members['upgrade.zs']=(HERE/'upgrade.zs').read_bytes()
    members['ZSCRIPT']=script.encode()
    members['MAPINFO']=('cluster 443 { hub }\nmap CA143 "Persistence" { cluster=443 }\n'
        'map CA143B "Hub excursion" { cluster=443 }\nGameInfo { AddEventHandlers='+handlers+' }\n').encode()
    package(name+'/persistence.pk3',members)
for name,commands in {
    'seed':'wait 85; save ca143-original; wait 5; quit',
    'upgrade':'wait 5; save ca143-migrated; wait 5; quit',
    'load':'wait 5; quit',
    'migration-hub':'wait 5; changemap CA143B; wait 10; changemap CA143; wait 5; quit',
}.items():(OUT/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8')
print('Prepared original 5.1.5 and current 5.1.6 persistence packages.')
