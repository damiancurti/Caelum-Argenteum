"""Build private #405 fixtures; no test map or IWAD content is distributed."""
from pathlib import Path
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue405'
OUT.mkdir(parents=True, exist_ok=True)

def wad():
    text = ['namespace="ZDoom";', 'sector { heightfloor=0; heightceiling=256; texturefloor="FLOOR4_8"; textureceiling="CEIL1_1"; lightlevel=224; }']
    for x,y in [(-1024,-1024),(-1024,2048),(3072,2048),(3072,-1024)]:
        text.append(f'vertex {{ x={x}; y={y}; }}')
    for i in range(4):
        text += ['sidedef { sector=0; texturemiddle="STARTAN3"; }',f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}']
    text.append('thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
    lumps=[('CARESRC',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]
    body=b''; directory=b''
    for name,data in lumps:
        directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode().ljust(8,b'\0'));body+=data
    return b'PWAD'+struct.pack('<ii',len(lumps),12+len(body))+body+directory

members={'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n#include "checks.zs"\n',
    'MAPINFO':b'GameInfo { AddEventHandlers="CA405Legacy", "CA405Checks" }\ncluster 8405 { hub }\nmap CARESRC "Land resource checks" { cluster=8405 }\nmap CARESR2 "Resource travel checks" { cluster=8405 }\n',
    'legacy.zs':(HERE/'legacy.zs').read_bytes(),'checks.zs':(HERE/'checks.zs').read_bytes(),
    'maps/CARESRC.wad':wad(),'maps/CARESR2.wad':wad()}
def package(path,contents):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(contents.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
package(OUT/'checks.pk3',members)
package(OUT/'upgrade/legacy-checks.pk3',members)
legacy={k:v for k,v in members.items() if k!='checks.zs'}
legacy['ZSCRIPT']=b'version "4.14"\n#include "legacy.zs"\n'
legacy['MAPINFO']=legacy['MAPINFO'].replace(b', "CA405Checks"',b'')
package(OUT/'legacy-checks.pk3',legacy)
scripts={
    'suite':'wait 35; netevent ca405_suite; wait 5; quit',
    'trade':'wait 35; netevent ca405_trade; wait 5; quit',
    'save':'wait 35; netevent ca405_save; wait 2; save ca405-current; wait 3; quit',
    'verify':'wait 5; netevent ca405_verify; wait 3; quit',
    'travel':'wait 5; netevent ca405_verify; changemap CARESR2; wait 35; netevent ca405_verify; changemap CARESRC; wait 35; netevent ca405_verify; wait 3; quit',
    'legacy-save':'wait 35; netevent ca405_legacy_save; wait 2; save ca405-legacy; wait 3; quit',
    'rollback':'wait 5; netevent ca405_legacy_verify; wait 3; quit',
    'upgrade':'wait 5; netevent ca405_upgrade; wait 2; save ca405-upgraded; wait 3; quit',
    'upgraded-verify':'wait 5; netevent ca405_upgrade; wait 3; quit',
    'map':'wait 70; netevent ca405_map; wait 3; quit',
    'map-save':'wait 70; netevent ca405_map; netevent ca405_remove; wait 2; save ca405-map; wait 3; quit',
    'map-verify':'wait 70; netevent ca405_map_removed; wait 5; quit',
    'gallery':'language es; wait 35; netevent ca405_gallery; wait 20; screenshot "gallery-front.png"; netevent ca405_angle; wait 15; screenshot "gallery-side.png"; wait 3; quit',
    'use':'wait 35; netevent ca405_use_setup; wait 5; +use; wait 10; -use; wait 5; netevent ca405_use_check; wait 3; quit',
    'cut':'wait 35; netevent ca405_cut_setup; wait 35; +attack; wait 20; -attack; wait 10; netevent ca405_cut_check; wait 3; quit',
    'closeups':'language es; wait 35; netevent ca405_gallery; netevent ca405_closeup 0; wait 15; screenshot "hive-close.png"; netevent ca405_closeup 1; wait 15; screenshot "marcela-close.png"; wait 3; quit',
    'maplegacy-save':'wait 70; netevent ca405_legacy_save; wait 2; save ca405-maplegacy; wait 3; quit',
    'mapupgrade':'wait 70; netevent ca405_map; wait 2; save ca405-mapupgrade; wait 3; quit',
    'perf':'wait 70; netevent ca405_perf; wait 370; screenshot "presentation.png"; wait 5; quit',
    'interactive':'exec ../../assets/playtest/default_controls.cfg\nlanguage es\nbind F1 "map CARESRC; wait 70; netevent ca405_author 0"\nbind F2 "netevent ca405_author 1"\nbind F3 "netevent ca405_author 2"\nbind F4 "netevent ca405_author 3"\nbind F5 "map MAP03; wait 70; netevent ca405_campaign"\nbind F6 "map MAP01; wait 70; netevent ca405_campaign"\nwait 35; netevent ca405_author 0; wait 5; toggleconsole',
}
for name,data in scripts.items(): (OUT/f'{name}.cfg').write_text(data+'\n',encoding='utf-8')
print('Prepared #405 native fixtures and Spanish author controls.')
