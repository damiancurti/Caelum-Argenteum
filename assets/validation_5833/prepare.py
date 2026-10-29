"""Prepare focused chair/cot native checks; production map geometry stays intact."""
from pathlib import Path
import struct
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-basic-rest'
WORK.mkdir(parents=True,exist_ok=True)
legacy=(ROOT/'assets/validation_5826/checks.zs').read_text(encoding='utf-8')
legacy=legacy.replace("if(e.Name=='ca410rd_profile')",'''if(e.Name=='ca410br_migration')
        {let check=new('CA410BasicRestChecks');check.Migration(u);Console.Printf("CA410BR RESULT passed=%d failed=%d",check.Passed,check.Failed);return;}
        if(e.Name=='ca410rd_profile')''',1)
text='namespace="ZDoom";\n'
for x,y in [(-1024,-1024),(-1024,1024),(1024,1024),(1024,-1024)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
for i in range(4):
 text+='sidedef { sector=0; texturemiddle="CMST01"; }\n'
 text+=f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
text+='sector { heightfloor=0; heightceiling=256; texturefloor="CMST01"; textureceiling="CMST01"; lightlevel=224; }\nthing { x=0; y=-256; type=1; angle=90; }\n'
lumps=[('CLUX410',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
payload=b''.join(data for _,data in lumps);directory=b'';offset=12
for name,data in lumps:
 directory+=struct.pack('<ii8s',offset,len(data),name.encode());offset+=len(data)
wad=b'PWAD'+struct.pack('<ii',len(lumps),12+len(payload))+payload+directory
members={'MAPINFO':b'GameInfo { AddEventHandlers="CA410BasicRestChecks" }\ncluster 8530 {hub}\nmap CLUX410 "Furniture gallery"{cluster=8530}\nmap CLUX411 "Away"{cluster=8530}\ncluster 8522 {hub}\nmap MAP01 "Mansion"{cluster=8522}\nmap CBTH410 "Away"{cluster=8522}\n',
 'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "legacy.zs"\n','legacy.zs':legacy.encode(),
 'maps/CBTH410.wad':(ROOT/'assets/validation_5826/away.wad').read_bytes(),'checks.zs':(HERE/'checks.zs').read_bytes(),
 'maps/CLUX410.wad':wad,'maps/CLUX411.wad':wad}
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
prefix='wait 70; netevent ca410br_setup; wait 35; '
commands={'core':prefix+'netevent ca410br_core; wait 35; quit',
 'seed':prefix+'netevent ca410br_seed; wait 35; save basic-rest; wait 35; quit',
 'resume':'wait 70; netevent ca410br_resume; wait 35; quit',
 'hub':prefix+'netevent ca410br_seed; wait 35; changemap CLUX411; wait 70; changemap CLUX410; wait 70; netevent ca410br_resume; wait 35; quit',
 'migration':'wait 210; netevent ca410br_migration; wait 35; quit','interactive':prefix}
for k in range(6):commands[f'view{k}']=prefix+f'netevent ca410br_view {k}; wait 35; screenshot basic-rest-{k}.png; wait 35; quit'
commands['legacyseed']=prefix+'netevent ca410br_legacyseed; wait 35; save basic-old; wait 35; quit'
commands['legacyresume']='wait 70; netevent ca410br_legacyresume; wait 35; quit'
commands['legacyrollback']='wait 70; netevent ca410br_legacyrollback; wait 35; quit'
for k in (3,4,5):commands[f'side{k}']=prefix+f'netevent ca410br_view {k}; wait 35; netevent ca410br_camera; wait 35; screenshot basic-side-{k}.png; wait 35; quit'
for k in (0,1):commands[f'input{k}']=prefix+f'netevent ca410br_input {k} 0; wait 35; +use; wait 10; -use; wait 35; netevent ca410br_input {k} 1; wait 35; quit'
for name,script in commands.items():(WORK/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared ordinary rest furniture diagnostics.')
