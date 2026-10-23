"""Reuse the frozen #405 room geometry without touching the active author session."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue406';OUT.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(ROOT/'build/issue405/checks.pk3') as z: room=z.read('maps/CARESRC.wad')
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers="CA406Checks" }\ncluster 8406 { hub }\nmap CARESRC "Source recovery checks" { cluster=8406 }\nmap CARESR2 "Recovery hub checks" { cluster=8406 }\n',
    'checks.zs':(HERE/'checks.zs').read_bytes(),'maps/CARESRC.wad':room,'maps/CARESR2.wad':room}
for name in ['checks.pk3','legacy-checks.pk3','upgrade/legacy-checks.pk3']:
    path=OUT/name;path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
scripts={
    'matrix':'wait 35; netevent ca406_matrix; wait 5; quit',
    'boundaries':'wait 35; netevent ca406_boundaries; wait 5; quit',
    'separation':'wait 35; netevent ca406_separation; wait 5; quit',
    'active':'wait 35; netevent ca406_active; wait 105; netevent ca406_active_verify; wait 5; quit',
    'save':'wait 35; netevent ca406_save; wait 2; save ca406-current; wait 5; quit',
    'legacy-save':'wait 35; netevent ca406_legacy_save; wait 2; save ca406-legacy; wait 5; quit',
    'verify':'wait 35; netevent ca406_verify; wait 5; quit',
    'resume':'wait 35; netevent ca406_resume; wait 2; save ca406-resumed; wait 5; quit',
    'travel':'wait 35; netevent ca406_verify; changemap CARESR2; wait 35; netevent ca406_verify; changemap CARESRC; wait 35; netevent ca406_verify; wait 5; quit',
    'upgrade':'wait 35; netevent ca406_resume; wait 2; save ca406-upgraded; wait 5; quit',
    'interactive':'bind w +forward; bind s +back; bind a +moveleft; bind d +moveright; bind e +use; bind mouse1 +attack; bind tab ca_journal; bind f1 "netevent ca406_author 0"; bind f2 "netevent ca406_author 1"; bind f3 "netevent ca406_author 2"; bind f4 "save ca406-author"; bind f5 "load ca406-author.zds"; bind f6 "netevent ca406_author 3"; wait 70; netevent ca406_author 0',
    'manual-smoke':'wait 70; netevent ca406_author 0; wait 5; netevent ca406_author 1; wait 5; netevent ca406_author 2; wait 5; quit',
    'manual-controls':'wait 70; netevent ca406_author 0; wait 5; +use; wait 2; -use; wait 5; netevent ca406_author_verify 450; netevent ca406_author 1; wait 5; netevent ca406_author_verify 500; +use; wait 2; -use; wait 5; netevent ca406_author_verify 450; netevent ca406_author 3; wait 5; netevent ca406_author 1; wait 5; netevent ca406_author_verify 450; save ca406-manual; wait 5; quit',
    'manual-load':'wait 70; netevent ca406_author_verify 450; wait 5; quit',
}
for name,data in scripts.items():(OUT/f'{name}.cfg').write_text(data+'\n',encoding='utf-8')
print('Prepared #406 fixtures from the immutable #405 geometry.')
