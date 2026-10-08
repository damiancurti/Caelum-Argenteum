"""Native original-save/original-package migration and reversible rollback probes."""
from prepare import ROOT, HERE, OUT, package, test_map
import shutil
import subprocess
import io
import zipfile

if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
    raise SystemExit('Finish the owned native run before preparing saves.')
if not (OUT/'pre-sweat.pk3').exists():
    raw=subprocess.check_output(['git','archive','--format=zip','df49f40b','src'],cwd=ROOT)
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        package('pre-sweat.pk3',{n[4:]:z.read(n) for n in z.namelist() if not n.endswith('/')})
for revision in ('old','new'):
    target=OUT/('sweat-'+revision);target.mkdir(exist_ok=True)
    shutil.copyfile(OUT/('pre-sweat.pk3' if revision=='old' else 'production.pk3'),target/'production.pk3')
    members={'maps/CA133.wad':test_map(),'sweat_save.zs':(HERE/'sweat_save.zs').read_bytes(),
        'ZSCRIPT':b'version "4.14"\n#include "sweat_save.zs"\n',
        'MAPINFO':b'map CA133 "Sweat migration" {}\nGameInfo { AddEventHandlers="CA133SweatSeed" }\n'}
    if revision=='new':
        members['sweat_upgrade.zs']=(HERE/'sweat_upgrade.zs').read_bytes()
        members['ZSCRIPT']+=b'#include "sweat_upgrade.zs"\n'
        members['MAPINFO']=b'map CA133 "Sweat migration" {}\nGameInfo { AddEventHandlers="CA133SweatSeed", "CA133SweatUpgrade" }\n'
    package('sweat-'+revision+'/sweat-migration.pk3',members)
(OUT/'sweat-seed.cfg').write_text('wait 70; save sweat-original; wait 5; quit\n',encoding='utf-8')
(OUT/'sweat-upgrade.cfg').write_text('wait 5; save sweat-upgraded; wait 5; quit\n',encoding='utf-8')
(OUT/'sweat-rollback.cfg').write_text('wait 5; quit\n',encoding='utf-8')
