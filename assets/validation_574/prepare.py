"""Prepare isolated #470 tests, reusing frozen #405 geometry and #376 checks."""
from pathlib import Path
import json
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue470'
OUT.mkdir(parents=True,exist_ok=True)
# Resolve the main checkout from Git's common directory without embedding a user path.
import subprocess
common=Path(subprocess.check_output(['git','rev-parse','--path-format=absolute','--git-common-dir'],cwd=ROOT,text=True).strip()).parent
with zipfile.ZipFile(common/'build/issue405/checks.pk3') as z: room=z.read('maps/CARESRC.wad')
base={'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n',
      'MAPINFO':b'GameInfo { AddEventHandlers="CA376Checks" }\nmap CARESRC "Alchemy network checks" {}\n',
      'legacy.zs':(ROOT/'assets/validation_560/checks.zs').read_bytes(), 'maps/CARESRC.wad':room}
current=base.copy()
current['legacy.zs']=base['legacy.zs'].replace(b"stations.Push('CaelumMasterBenchStation');",b"stations.Push('CaelumMasterBenchStation');stations.Push('CaelumAlchemyStation');")
current['ZSCRIPT']+=b'#include "checks.zs"\n'
current['MAPINFO']=b'GameInfo { AddEventHandlers="CA376Checks", "CA470Checks" }\nmap CARESRC "Alchemy network checks" {}\n'
current['checks.zs']=(HERE/'checks.zs').read_bytes()
for name,members in [('checks.pk3',current),('legacy-checks.pk3',base),('upgrade/legacy-checks.pk3',current)]:
    (OUT/name).parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
scripts={
    'network':'wait 70; netevent ca470_network; wait 5; quit',
    'crafting':'wait 70; netevent ca376_suite; wait 5; quit',
    'placement':'wait 105; netevent ca470_placement; wait 5; quit',
    'save':'wait 105; netevent ca470_placement; save ca470-current; wait 5; quit',
    'legacy-save':'wait 105; save ca470-legacy; wait 5; quit',
    'legacy-city-save':'wait 105; save ca470-city-legacy; wait 5; quit',
    'task-save':'wait 70; netevent ca376_save; wait 2; save ca470-task; wait 5; quit',
    'task-load':'wait 70; netevent ca376_verify; wait 5; quit',
    'upgrade':'wait 105; netevent ca470_placement; save ca470-upgraded; wait 5; quit',
    'travel':'wait 105; netevent ca470_placement; wait 5; changemap MAP03; wait 105; netevent ca470_placement; wait 5; changemap MAP01; wait 105; netevent ca470_placement; wait 5; quit',
    'removed':'wait 105; netevent ca470_placement; netevent ca470_remove; wait 70; netevent ca470_removed; save ca470-removed; wait 5; quit',
    'removed-load':'wait 105; netevent ca470_removed; wait 5; quit',
    'manual-smoke':'wait 105; netevent ca470_author; wait 5; +use; wait 2; -use; wait 5; netevent ca470_use; wait 5; screenshot; wait 5; quit',
    'blocked-save':'wait 105; netevent ca470_block; wait 72; netevent ca470_blocked; save ca470-blocked; wait 5; quit',
    'blocked-load':'wait 72; netevent ca470_blocked; netevent ca470_unblock; wait 72; netevent ca470_placement; wait 5; quit',
    'performance':'wait 735; quit',
    'interactive':'bind w +forward; bind s +back; bind a +moveleft; bind d +moveright; bind e +use; bind tab ca_journal; bind q ca_journal; bind f1 "map MAP01; wait 105; netevent ca470_author"; bind f2 "map MAP03; wait 105; netevent ca470_author"; bind f3 "save ca470-author"; bind f4 "load ca470-author.zds"; wait 105; netevent ca470_author',
}
scripts['manual-smoke']=f'wait 105; netevent ca470_author; wait 70; screenshot "{OUT.as_posix()}/station-view.png"; wait 5; +use; wait 2; -use; wait 35; netevent ca470_use; wait 5; screenshot "{OUT.as_posix()}/station-menu.png"; wait 35; quit'
for name,data in scripts.items():(OUT/f'{name}.cfg').write_text(data+'\n',encoding='utf-8')
with zipfile.ZipFile(OUT/'performance.pk3','w',zipfile.ZIP_STORED) as z:
    for key,data in {'ZSCRIPT':b'version "4.14"\n#include "performance.zs"\n',
                     'MAPINFO':b'GameInfo { AddEventHandlers="CA470Performance" }\n',
                     'performance.zs':(HERE/'performance.zs').read_bytes()}.items():
        z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
print(json.dumps({'prepared':str(OUT),'source_room':'frozen #405','crafting_suite':'unchanged #376'}))
