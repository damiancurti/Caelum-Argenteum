"""Build deterministic private clothing fixtures; no game assets are distributed."""
from pathlib import Path
import zipfile
import struct

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / 'build/issue386'
OUT.mkdir(parents=True, exist_ok=True)
def room():
    text='namespace="ZDoom";\nsector { heightfloor=0; heightceiling=256; texturefloor="FLOOR0_1"; textureceiling="CEIL1_1"; lightlevel=220; }\n'
    for x,y in [(-512,-512),(-512,512),(512,512),(512,-512)]:
        text+=f'vertex {{ x={x}; y={y}; }}\n'
    for edge in range(4):
        text+=f'sidedef {{ sector=0; texturemiddle="STARTAN3"; }}\nlinedef {{ v1={edge}; v2={(edge+1)%4}; sidefront={edge}; blocking=true; }}\n'
    text+='thing { x=0; y=0; type=1; angle=0; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
    lumps=[('CLTHQA',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    data=bytearray(b'PWAD'+struct.pack('<II',len(lumps),0));directory=[]
    for name,content in lumps:
        directory.append(struct.pack('<II8s',len(data),len(content),name.encode().ljust(8,b'\0')));data.extend(content)
    struct.pack_into('<I',data,8,len(data));data.extend(b''.join(directory));return data
for name, current in [('checks.pk3', True), ('legacy-checks.pk3', False), ('baseline-checks.pk3', False)]:
    members = {'legacy.zs': (HERE/'legacy.zs').read_bytes(),
               'ZSCRIPT': b'version "4.14"\n#include "legacy.zs"\n',
               'MAPINFO': b'GameInfo { AddEventHandlers = "CA386Legacy" }\n'}
    if current:
        members['ZSCRIPT'] += b'#include "checks.zs"\n'
        members['checks.zs'] = (HERE/'checks.zs').read_bytes()
        members['MAPINFO'] = b'GameInfo { AddEventHandlers = "CA386Legacy", "CA386Checks" }\n'
        members['MAPINFO'] += b'map CLTHQA "Isolated clothing checks" { nointermission }\n'
        members['maps/CLTHQA.wad'] = room()
    with zipfile.ZipFile(OUT/name, 'w', zipfile.ZIP_STORED) as archive:
        for member, content in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(member, (2000,1,1,0,0,0)), content)
scripts = {
    'suite': 'wait 35; netevent ca386_suite; wait 5; quit',
    'save': 'wait 35; netevent ca386_save; wait 5; save ca386-current; wait 5; quit',
    'verify': 'wait 35; netevent ca386_verify; wait 5; quit',
    'travel': 'wait 35; changemap THAZARD; wait 35; netevent ca386_verify; changemap TMAINT; wait 35; netevent ca386_verify; changemap CLTHQA; wait 35; netevent ca386_verify; changemap TMAINT; wait 35; netevent ca386_verify; wait 5; quit',
    'legacy-save': 'wait 35; netevent ca386_legacy; wait 1; save ca386-legacy; wait 5; quit',
    'upgrade': 'wait 1; netevent ca386_upgrade; wait 1; save ca386-upgraded; wait 5; quit',
    'baseline-save': 'wait 35; netevent ca386_legacy; wait 1; save ca386-baseline; wait 5; quit',
    'baseline-upgrade': 'wait 1; netevent ca386_upgrade; wait 1; save ca386-baseline-upgraded; wait 5; quit',
    'rollback': 'wait 1; netevent ca386_rollback; wait 5; quit',
    'ui-en': 'wait 35; changemap CLTHQA; wait 35; netevent ca386_author; ca_journal_open true; ca_journal_page 0; language enu; wait 35; screenshot clothing-en.png; wait 5; quit',
    'ui-es': 'wait 35; changemap CLTHQA; wait 35; netevent ca386_author; ca_journal_open true; ca_journal_page 0; language es; wait 35; screenshot clothing-es.png; wait 5; quit',
    'interactive': 'exec ../../assets/playtest/default_controls.cfg\nlanguage es; wait 35; changemap CLTHQA; wait 35; netevent ca386_author; ca_journal_open true; ca_journal_page 0; wait 5; toggleconsole',
}
for name, script in scripts.items():
    (OUT/(name+'.cfg')).write_text(script+'\n', encoding='utf-8')
print('Prepared issue386 fixtures.')
