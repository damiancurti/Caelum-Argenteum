"""Build deterministic, unshipped surface-contact tests and a two-room map."""
from pathlib import Path
import runpy
import struct
import zipfile

here = Path(__file__).resolve().parent
out = here.parents[1] / 'build/issue502-hygiene'
out.mkdir(parents=True,exist_ok=True)
runpy.run_path(str(here/'prepare_clean.py'))
textmap = ['namespace="ZDoom";']
points = [(-320,-320),(-320,320),(0,320),(0,-320),(320,320),(320,-320)]
for x,y in points:
    textmap.append(f'vertex {{x={x};y={y};}}')
for ceiling in ('CEIL1_1','F_SKY1'):
    textmap.append('sector {heightfloor=0;heightceiling=160;texturefloor="FLAT5_4";textureceiling="'+ceiling+'";lightlevel=192;user_ca_contamination_class=2;}')
side=0
for a,b,front,back in [(0,1,0,-1),(1,2,0,-1),(2,3,0,1),(3,0,0,-1),(2,4,1,-1),(4,5,1,-1),(5,3,1,-1)]:
    textmap.append(f'sidedef {{sector={front};texturemiddle="'+('STARTAN3' if back<0 else '-')+'";}')
    line=f'linedef {{v1={a};v2={b};sidefront={side};';side+=1
    if back>=0:
        textmap.append(f'sidedef {{sector={back};texturemiddle="-";}}')
        line+=f'sideback={side};twosided=true;';side+=1
    else:line+='blocking=true;'
    textmap.append(line+'}')
textmap.append('thing {x=64;y=64;type=1;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;dm=true;}')
textmap.append('thing {x=64;y=64;type=30950;arg0=1;arg1=5;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;dm=true;}')
# Reuse the production climate editor number; never override a campaign actor.
lumps=[('CAS502',b''),('TEXTMAP','\n'.join(textmap).encode()),('ENDMAP',b'')]
data=bytearray(b'PWAD'+struct.pack('<ii',len(lumps),0));directory=[]
for name,blob in lumps:
    directory.append((len(data),len(blob),name.encode().ljust(8,b'\0')));data.extend(blob)
offset=len(data)
for row in directory:data.extend(struct.pack('<ii8s',*row))
struct.pack_into('<i',data,8,offset)
members={
    'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n#include "surface_checks.zs"\n',
    'surface_checks.zs':(here/'surface_checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA502HChecks","CA502SChecks" }\nmap CAS502 "Surface contact laboratory" {levelnum=502 cluster=434 nointermission next="CAH001" sky1="SKY1"}\n',
    'maps/CAS502.wad':bytes(data),
}
with zipfile.ZipFile(out/'clean-checks.pk3') as archive:
    legacy=archive.read('checks.zs').decode('utf-8')
    legacy=legacy.replace("        if(e.Name=='ca_inventory_boil'", """        if(e.Name=='ca502s_legacy') {
            Check(CaelumContaminationSurfaces.Get(false)!=null,"old save initializes new ledger on first active tic");
            Check(CaelumCleaningTask.Attended(u),"pre-surface saved equipment cleaning stays active");
            Console.Printf("CA502H RESULT passed=%d failures=%d",Passed,Failed);return;
        }
        else if(e.Name=='ca_inventory_boil'""",1)
    members['checks.zs']=legacy.encode('utf-8')
with zipfile.ZipFile(out/'surface-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
status_command='netevent ca502s_status; wait 2; toggleconsole'
scripts={
    'surface-rules':'wait 70; netevent ca502s_rules; wait 5; quit',
    'surface-native':'wait 70; netevent ca502s_native; wait 5; quit',
    'surface-weather':'wait 70; netevent ca502s_weather; wait 5; quit',
    'surface-rain-live':'wait 70; netevent ca502s_rain_live; wait 5; quit',
    'surface-forecast':'wait 70; netevent ca502s_forecast; wait 5; quit',
    'surface-wet-floor':'wait 70; netevent ca502s_wet_floor; wait 5; quit',
    'surface-capture':'wait 70; netevent ca502s_manual; wait 10; screenshot surface-lab.png; netevent ca502s_rain_live; toggleconsole; wait 10; screenshot surface-rain.png; wait 5; quit',
    'surface-save':'wait 70; netevent ca502s_seed; save ca502s-surfaces; wait 5; quit',
    'surface-load':'wait 1; netevent ca502s_load; wait 5; quit',
    'surface-hub':'wait 1; changemap CAH001; wait 70; netevent ca502s_hub; changemap CAS502; wait 70; netevent ca502s_hub; wait 5; quit',
    'surface-legacy':'wait 1; netevent ca502s_legacy; wait 5; quit',
    'surface-manual':f'wait 70; netevent ca502s_manual; bind F1 "netevent ca502s_manual"; bind F2 "{status_command}"; bind F3 "netevent ca502s_wall"; bind F4 "netevent ca502s_rain"; bind F5 "netevent ca502s_wait"; bind F6 toggleconsole',
    'surface-reading':f'wait 70; netevent ca502s_manual; wait 70; {status_command}; wait 10; screenshot surface-f2-reading.png; wait 5; quit',
    'surface-bounded-wait':'wait 70; netevent ca502s_wait_check; wait 350; quit',
    'surface-fresh-trial':'wait 70; netevent ca502s_trial_check; wait 5; quit',
    'surface-responsive-capture':f'wait 70; netevent ca502s_wait_check; wait 350; {status_command}; wait 10; screenshot surface-responsive-rain.png; wait 5; quit',
}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
print('Prepared deterministic surface fixtures.')
