"""Prepare deterministic isolated #382 addons and console scripts."""
from pathlib import Path
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue382'
OUT.mkdir(parents=True,exist_ok=True)
HERE=Path(__file__).resolve().parent

def room_map():
    text='namespace="ZDoom";\n'
    for sector,(x0,x1) in enumerate([(-1200,256),(256,2200)]):
        text+='sector { heightfloor=0; heightceiling=256; texturefloor="FLOOR0_1"; textureceiling="CEIL1_1"; lightlevel=192; }\n'
        for x,y in [(x0,-1200),(x0,1200),(x1,1200),(x1,-1200)]:
            text+=f'vertex {{ x={x}; y={y}; }}\n'
        for edge in range(4):
            index=sector*4+edge
            text+=f'sidedef {{ sector={sector}; texturemiddle="STARTAN3"; }}\n'
            text+=f'linedef {{ v1={index}; v2={sector*4+(edge+1)%4}; sidefront={index}; blocking=true; }}\n'
    text+='thing { x=0; y=0; type=1; angle=0; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
    lumps=[('LOCKTEST',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    data=bytearray(b'PWAD'+struct.pack('<II',len(lumps),0));directory=[]
    for name,content in lumps:
        directory.append(struct.pack('<II8s',len(data),len(content),name.encode().ljust(8,b'\0')));data.extend(content)
    struct.pack_into('<I',data,8,len(data));data.extend(b''.join(directory));return data

legacy={'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n',
        'MAPINFO':b'GameInfo { AddEventHandlers = "CA382LegacyChecks" }\n',
        'legacy.zs':(HERE/'legacy.zs').read_bytes()}
current=dict(legacy)
current['ZSCRIPT']+=b'#include "checks.zs"\n'
current['ZSCRIPT']+=b'#include "baseline.zs"\n'
current['baseline.zs']=(HERE/'baseline.zs').read_bytes()
current['checks.zs']=(HERE/'checks.zs').read_bytes()
current['MAPINFO']=b'GameInfo { AddEventHandlers = "CA382LegacyChecks", "CA382Checks", "CA382BaselineChecks" }\nmap LOCKTEST "Isolated lock checks" { nointermission }\n'
current['maps/LOCKTEST.wad']=room_map()
baseline={'ZSCRIPT':b'version "4.14"\n#include "baseline.zs"\n',
          'MAPINFO':b'GameInfo { AddEventHandlers = "CA382BaselineChecks" }\n',
          'baseline.zs':current['baseline.zs']}
for name,members in [('checks.pk3',current),('legacy-checks.pk3',legacy),('baseline-checks.pk3',baseline)]:
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as archive:
        for member,content in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(member,(2000,1,1,0,0,0)),content)
scripts={
    'suite':'wait 35; netevent ca382_suite; wait 5; quit',
    'visibility':'wait 35; changemap LOCKTEST; wait 35; netevent ca382_visibility; wait 5; quit',
    'save':'wait 35; netevent ca382_save; wait 5; save ca382-current; wait 5; quit',
    'verify':'wait 35; netevent ca382_verify; wait 5; quit',
    'travel':'wait 35; changemap THAZARD; wait 35; netevent ca382_verify; changemap TMAINT; wait 35; netevent ca382_verify; changemap MAP01; wait 70; netevent ca382_verify; wait 5; quit',
    'hub':'wait 35; netevent ca382_hub_setup; wait 5; changemap THAZARD; wait 35; changemap TMAINT; wait 35; netevent ca382_hub_verify; wait 5; quit',
    'house':'wait 35; changemap CAH000; wait 105; netevent ca382_house; changemap CAH001; wait 105; netevent ca382_house; changemap CAH000; wait 105; netevent ca382_house_return; wait 5; quit',
    'house-migration':'wait 35; changemap CAH002; wait 105; netevent ca382_house_migration; wait 5; quit',
    'legacy-save':'wait 35; netevent ca382_legacy_save; wait 5; save ca382-legacy; wait 5; quit',
    'legacy-verify':'wait 35; netevent ca382_legacy_verify; wait 5; quit',
    'baseline-save':'wait 35; netevent ca382_baseline_save; wait 5; save ca382-baseline; wait 5; quit',
    'baseline-verify':'wait 35; netevent ca382_baseline_verify; wait 5; quit',
    'baseline-upgrade':'wait 35; netevent ca382_baseline_verify; netevent ca382_baseline_upgrade; wait 5; save ca382-baseline-upgraded; wait 5; quit',
    'upgrade':'wait 35; netevent ca382_legacy_verify; netevent ca382_upgrade; wait 5; save ca382-upgraded; wait 5; quit',
    'ui':'wait 35; changemap LOCKTEST; wait 35; netevent ca382_ui; language enu; wait 10; screenshot locks-en.png; language es; wait 10; screenshot locks-es.png; wait 5; quit',
    'ui-en':'wait 35; changemap LOCKTEST; wait 35; netevent ca382_ui; language enu; wait 35; screenshot locks-english.png; wait 35; quit',
    'author-check':'wait 35; changemap LOCKTEST; wait 35; netevent ca382_author; wait 70; screenshot author.png; wait 5; quit',
    'attack':'wait 35; changemap LOCKTEST; wait 35; netevent ca382_attack_setup; use CaelumFlailSelectorWeapon; wait 70; +attack; wait 35; -attack; wait 5; netevent ca382_attack_verify; screenshot attack.png; wait 5; quit',
    'interactive':'exec ../../assets/playtest/default_controls.cfg\nbind e +use; bind mouse1 +attack; language es; wait 35; changemap LOCKTEST; wait 35; netevent ca382_author; wait 5; toggleconsole',
}
for name,script in scripts.items():(OUT/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared deterministic issue382 fixtures.')
