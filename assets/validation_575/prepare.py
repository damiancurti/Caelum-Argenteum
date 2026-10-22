"""Prepare #407 fixtures, reusing the frozen #405 room and #376 regression."""
from pathlib import Path
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue407'
OUT.mkdir(parents=True,exist_ok=True)
common=Path(subprocess.check_output(['git','rev-parse','--path-format=absolute','--git-common-dir'],cwd=ROOT,text=True).strip()).parent
with zipfile.ZipFile(common/'build/issue405/checks.pk3') as z: room=z.read('maps/CARESRC.wad')
base={'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n#include "regression.zs"\n',
      'MAPINFO':b'GameInfo { AddEventHandlers="CA407Legacy", "CA376Checks" }\ncluster 8407 { hub }\nmap CARESRC "Marine resource checks" { cluster=8407 }\nmap CARESR2 "Marine travel checks" { cluster=8407 }\n',
      'legacy.zs':(HERE/'legacy.zs').read_bytes(),
      'regression.zs':(ROOT/'assets/validation_560/checks.zs').read_bytes(),
      'maps/CARESRC.wad':room,'maps/CARESR2.wad':room}
current=base.copy()
current['ZSCRIPT']+=b'#include "checks.zs"\n'
current['MAPINFO']=base['MAPINFO'].replace(b'"CA407Legacy",',b'"CA407Legacy", "CA407Checks",')
current['checks.zs']=(HERE/'checks.zs').read_bytes()
for name,members in [('checks.pk3',current),('legacy-checks.pk3',base),('upgrade/legacy-checks.pk3',current)]:
    (OUT/name).parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
scripts={
    'contract':'wait 70; netevent ca407_contract; wait 5; quit',
    'trade':'wait 70; netevent ca407_trade; wait 5; quit',
    'craft':'wait 70; netevent ca407_craft; wait 5; quit',
    'storage':'wait 70; netevent ca407_storage; wait 5; quit',
    'regression':'wait 70; netevent ca376_suite; wait 5; quit',
    'legacy-save':'wait 70; netevent ca407_legacy_save; wait 2; save ca407-legacy; wait 5; quit',
    'rollback':'wait 70; netevent ca407_rollback; wait 5; quit',
    'upgrade':'wait 70; netevent ca407_upgrade; save ca407-upgraded; wait 5; quit',
    'upgrade-load':'wait 70; netevent ca407_upgrade; wait 5; quit',
    'save':'wait 70; netevent ca407_save; wait 2; save ca407-current; wait 5; quit',
    'load':'wait 70; netevent ca407_verify; wait 5; quit',
    'travel':'wait 70; netevent ca407_verify; changemap CARESR2; wait 70; netevent ca407_inventory; changemap CARESRC; wait 70; netevent ca407_verify; wait 5; quit',
    'task-save':'wait 70; netevent ca407_task_save; wait 2; save ca407-task; wait 5; quit',
    'task-load':'wait 70; netevent ca407_task_load; wait 5; quit',
    'legacy-task-save':'wait 70; netevent ca376_save; wait 2; save ca407-legacy-task; wait 5; quit',
    'legacy-task-load':'wait 70; netevent ca376_verify; wait 5; quit',
    'gallery':f'wait 70; netevent ca407_gallery; wait 35; screenshot "{OUT.as_posix()}/marine-front.png"; netevent ca407_side; wait 35; screenshot "{OUT.as_posix()}/marine-side.png"; wait 5; quit',
    'campaign':'wait 105; netevent ca407_campaign; wait 5; quit',
    'live':'wait 70; netevent ca407_live; wait 2140; netevent ca407_live_verify; wait 5; quit',
    'performance':'wait 70; netevent ca407_perf; wait 560; quit',
    'author-smoke':f'wait 70; netevent ca407_author; wait 10; +use; wait 2; -use; wait 35; netevent ca407_use; screenshot "{OUT.as_posix()}/iodine-menu.png"; wait 5; quit',
    'author-save':'wait 70; netevent ca407_author; netevent ca407_shop; wait 5; netevent ca407_alchemy; wait 5; netevent ca407_use; save ca407-author-check; wait 5; quit',
    'author-load':'wait 70; netevent ca407_alchemy; wait 5; netevent ca407_use; wait 5; quit',
    'interactive':'bind w +forward; bind s +back; bind a +moveleft; bind d +moveright; bind e +use; bind q ca_journal; bind tab ca_journal; bind f1 "netevent ca407_shop"; bind f2 "netevent ca407_alchemy"; bind f3 "save ca407-author"; bind f4 "load ca407-author.zds"; bind f5 "netevent ca407_fast"; language es; wait 70; netevent ca407_author',
}
for name,data in scripts.items():(OUT/f'{name}.cfg').write_text(data+'\n',encoding='utf-8',newline='\n')
print('Prepared isolated #407 native fixtures.')
