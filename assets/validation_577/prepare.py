"""Build a private #481 interaction fixture using owned project textures."""
from pathlib import Path
import struct
import sys
import subprocess
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue481'
OUT.mkdir(parents=True,exist_ok=True)
text=['namespace="ZDoom";', 'sector { heightfloor=0; heightceiling=256; texturefloor="T481FLAT"; textureceiling="T481FLAT"; lightlevel=224; }']
for x,y in [(-512,-1024),(-512,1024),(1800,1024),(1800,-1024),(1200,-1024),(1200,1024),(960,-512),(960,-768),(960,-384)]:text.append(f'vertex {{ x={x}; y={y}; }}')
for i,(a,b) in enumerate([(0,1),(1,2),(2,3),(3,0),(4,5)]):
 text+=['sidedef { sector=0; texturemiddle="T481WALL"; }',f'linedef {{ v1={a}; v2={b}; sidefront={i}; {"sideback=5; twosided=true;" if i==4 else ""} blocking=true; }}']
text+=['sidedef { sector=0; texturemiddle="T481WALL"; }','sidedef { sector=0; }','sidedef { sector=0; }',
 'linedef { v1=6; v2=7; sidefront=6; sideback=7; twosided=true; special=74; arg0=1; playercross=true; }',
 'sidedef { sector=0; texturemiddle="T481WALL"; }',
 'linedef { v1=8; v2=6; sidefront=8; sideback=9; twosided=true; blocking=true; special=10; playeruse=true; }']
text.append('sidedef { sector=0; texturemiddle="T481WALL"; }')
text.append('thing { x=-200; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
lumps=[('CTGT481',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]
body=b'';directory=b''
for name,data in lumps:
 directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode().ljust(8,b'\0'));body+=data
wad=b'PWAD'+struct.pack('<ii',len(lumps),12+len(body))+body+directory
members={'ZSCRIPT':b'version "4.14"\n'+(HERE/'fixture.zs').read_bytes(),
 'MAPINFO':b'GameInfo { AddEventHandlers="CA481Fixture", "CA481UICheck" }\nmap CTGT481 "Target panel checks" { }\n',
 'TEXTURES':b'Texture T481FLAT, 64, 64 { Patch "models/caelum/world/alchemy_ingredients/host.png", 0, 0 }\nTexture T481WALL, 64, 64 { Patch "models/caelum/props/stations/ca_station_wood.png", 0, 0 }\n',
 'maps/CTGT481.wad':wad}
if '--overlay' in sys.argv:
 changed=subprocess.check_output(['git','diff','--name-only','--','src'],cwd=ROOT,text=True).splitlines()
 changed+=subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'],cwd=ROOT,text=True).splitlines()
 for name in changed:
  if name!='src/ZSCRIPT':members[name[4:]]=(ROOT/name).read_bytes()
with zipfile.ZipFile(OUT/'gallery.pk3','w',zipfile.ZIP_STORED) as package:
 for key,data in sorted(members.items()):package.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)
baseline=dict(members)
baseline['ZSCRIPT']=b'version "4.14"\nclass CA481Baseline : StaticEventHandler { override void NetworkProcess(ConsoleEvent e) { if(e.Name!="ca481_baseline")return; let u=CaelumPlayer(players[e.Player].mo); u.bInvulnerable=true; u.CreationWizardOpen=false; u.CharacterCreationComplete=true; u.SetOrigin((192,0,0),false); u.Angle=0; u.Pitch=20; Actor.Spawn("CaelumStashChest",(256,0,0),NO_REPLACE); Console.Printf("CA481 RESULT baseline save prepared"); } }'
baseline['MAPINFO']=b'GameInfo { AddEventHandlers="CA481Baseline" }\nmap CTGT481 "Target panel baseline" { }\n'
with zipfile.ZipFile(OUT/'baseline-gallery.pk3','w',zipfile.ZIP_STORED) as package:
 for key in ('ZSCRIPT','MAPINFO','TEXTURES','maps/CTGT481.wad'):package.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),baseline[key])
scripts={'smoke':'wait 70; netevent ca481_setup; wait 5; netevent ca481_checks; wait 5; quit',
 'interactive':'bind w +forward; bind s +back; bind a +moveleft; bind d +moveright; bind e +use; bind f1 "netevent ca481_next"; bind f2 "netevent ca481_insight"; language es; wait 70; netevent ca481_setup'}
for i in range(7):
 scripts[f'view-{i}']=f'netevent ca481_select {i}; wait 15; screenshot "{OUT.as_posix()}/target-{i}.png"; '+(f'exec "{OUT.as_posix()}/view-{i+1}.cfg"' if i<6 else 'wait 5; quit')
scripts['baseline']='wait 70; netevent ca481_baseline; wait 10; save ca481-baseline; wait 10; quit'
scripts['performance']='wait 70; netevent ca481_setup; wait 70; event ca481_perf_start; wait 350; event ca481_perf_stop; wait 5; quit'
scripts['save']='wait 70; netevent ca481_setup; wait 5; netevent ca481_select 1; wait 10; save ca481-current; wait 10; quit'
scripts['load']='wait 70; netevent ca481_reloaded; wait 10; quit'
scripts['remap']=f'language es; unbind e; bind r +use; wait 70; netevent ca481_setup; wait 5; netevent ca481_select 1; wait 10; event ca481_ui_check; screenshot "{OUT.as_posix()}/remapped-es.png"; wait 5; quit'
scripts['views']=f'wait 70; netevent ca481_setup; wait 5; netevent ca481_checks; exec "{OUT.as_posix()}/view-0.cfg"'
for name,data in scripts.items():(OUT/f'{name}.cfg').write_text(data+'\n',encoding='utf-8',newline='\n')
print('Prepared isolated #481 native fixture.')
