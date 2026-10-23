"""Prepare isolated #487 fixtures; reuse the frozen #405 room and #470 handler."""
from pathlib import Path
import subprocess
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue487'
OUT.mkdir(parents=True,exist_ok=True)
common=Path(subprocess.check_output(['git','rev-parse','--path-format=absolute','--git-common-dir'],cwd=ROOT,text=True).strip()).parent
with zipfile.ZipFile(common/'build/issue405/checks.pk3') as z:room=z.read('maps/CARESRC.wad')
members={'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n#include "checks.zs"\n',
         'MAPINFO':b'GameInfo { AddEventHandlers="CA470Checks", "CA487Checks" }\nmap CARESRC "Barrel network checks" {}\n',
         'legacy.zs':(ROOT/'assets/validation_574/checks.zs').read_bytes(),
         'checks.zs':(HERE/'checks.zs').read_bytes(),'maps/CARESRC.wad':room}
with zipfile.ZipFile(OUT/'checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
scripts={
    'network':'wait 105; netevent ca487_network; wait 10; quit',
    'collision':'wait 105; netevent ca487_author; wait 10; +forward; wait 35; -forward; wait 10; netevent ca487_collision; wait 10; quit',
    'views':f'language enu; wait 105; netevent ca487_author; netevent ca487_side; wait 35; screenshot "{OUT.as_posix()}/side-view.png"; wait 5; netevent ca487_back; wait 35; screenshot "{OUT.as_posix()}/back-view.png"; wait 10; quit',
    'placement':'wait 105; netevent ca487_placement; wait 10; quit',
    'upgrade':'wait 105; netevent ca487_placement; save ca487-current; wait 10; quit',
    'removed-save':'wait 105; netevent ca487_remove; wait 70; netevent ca487_removed; save ca487-removed; wait 10; quit',
    'removed-load':'wait 105; netevent ca487_removed; wait 10; quit',
    'blocked-save':'wait 105; netevent ca487_block; wait 105; netevent ca487_blocked; save ca487-blocked; wait 10; quit',
    'blocked-load':'wait 105; netevent ca487_blocked; netevent ca487_unblock; wait 105; netevent ca487_placement; wait 10; quit',
    'interactive':'language es; bind w +forward; bind s +back; bind a +moveleft; bind d +moveright; bind e +use; bind q ca_journal; bind tab ca_journal; bind f1 "map MAP01; wait 105; netevent ca487_author"; bind f2 "map MAP03; wait 105; netevent ca487_author"; bind f3 "save ca487-author"; bind f4 "load ca487-author.zds"; bind f5 "netevent ca487_disconnect"; bind f6 "netevent ca487_reconnect"; bind f7 "language enu"; bind f8 "language es"; wait 105; netevent ca487_author',
}
for language in ('es','enu'):
    scripts[language]=f'language {language}; wait 105; netevent ca487_author; netevent ca487_placement; wait 35; screenshot "{OUT.as_posix()}/{language}-view.png"; wait 5; +use; wait 2; -use; wait 35; netevent ca487_use; screenshot "{OUT.as_posix()}/{language}-menu.png"; wait 10; quit'
for name,script in scripts.items():(OUT/f'{name}.cfg').write_text(script+'\n',encoding='utf-8')
print(f'Prepared {OUT}')
