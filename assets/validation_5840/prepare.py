"""Package focused dining diagnostics; retain all earlier native evidence."""
from pathlib import Path
import subprocess,zipfile,struct,argparse
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue410-dining';W.mkdir(exist_ok=True)
a=argparse.ArgumentParser();a.add_argument('--probe',action='store_true');args=a.parse_args()
def pack(path,members):
 with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
  for n,d in sorted(members.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),d)
if args.probe:
 old=R.parent/'issue415-combat-work/build/issue415-aim/final39a/caelum_argenteum_dev.pk3'
 names=set(subprocess.check_output(['git','diff','d3706154db2eb19c5ed440825e9e5146ca503f12','--name-only','--','src'],cwd=R,text=True).splitlines())|set(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
 changed={n[4:] for n in names};(W/'probe').mkdir(exist_ok=True)
 with zipfile.ZipFile(old) as z:pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
 print('Probe ready:',len(changed),'changed files')
if not (H/'run_native.ps1').exists():(H/'run_native.ps1').write_text((R/'assets/validation_5836/run_native.ps1').read_text(encoding='utf-8').replace('issue410-study-acquisition','issue410-dining').replace('CA410RF','CA410DS'),encoding='utf-8')
if (H/'checks.zs').exists():
 prior=(R/'assets/validation_5836/checks.zs').read_text(encoding='utf-8').replace('RecipeBookVersion==22','RecipeBookVersion==23')
 # Shared acquisition code uses actual public crafting/trade APIs, while the
 # additional suite owns dining-specific geometry/cargo assertions.
 prior=prior.replace('v<CaelumRestFurnitureData.COUNT;v++','v<CaelumRestFurnitureData.COUNT;v++').replace('CA410RF','CA410DS')
 prior=prior.replace('u.DerivedStats.CarryCapacity=2000;u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"second same furniture', 'Material(u,CaelumConstants.MATERIAL_WOOD,1,400000);u.DerivedStats.CarryCapacity=2000;u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"second same furniture')
 text='namespace="ZDoom";\n'
 for x,y in [(-1024,-1024),(-1024,1024),(1024,1024),(1024,-1024)]:text+=f'vertex {{x={x};y={y};}}\n'
 for i in range(4):text+=f'sidedef {{sector=0;texturemiddle="CMST01";}}\nlinedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}\n'
 text+='sector {heightfloor=0;heightceiling=256;texturefloor="CMST01";textureceiling="CMST01";lightlevel=224;}\nthing {x=0;y=-256;type=1;angle=90;}\n'
 lumps=[('CDIN410',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')];data=b''.join(d for _,d in lumps);directory=b'';offset=12
 for n,d in lumps:directory+=struct.pack('<ii8s',offset,len(d),n.encode());offset+=len(d)
 flat=b'PWAD'+struct.pack('<ii',len(lumps),12+len(data))+data+directory
 pack(W/'checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "prior.zs"\n#include "checks.zs"\n','prior.zs':prior.encode(),'checks.zs':(H/'checks.zs').read_bytes(),'MAPINFO':b'GameInfo {AddEventHandlers="CA410DiningChecks"}\ncluster 8540 {hub}\nmap CDIN410 "Dining checks" {cluster=8540}\nmap MAP01 "Mansion" {cluster=8540}\nmap CBTH410 "Away" {cluster=8540}\n','maps/CDIN410.wad':flat,'maps/CBTH410.wad':(R/'assets/validation_5826/away.wad').read_bytes()})
 for case in ['catalogue','craft','trade','items','seed','resume','input0','input1','weather','exposure','loadedtrade','nested','nestedresume','legacy']:
  (W/(case+'.cfg')).write_text('wait 210; netevent ca410ds_'+case+'; wait 35; '+('save dining-current; wait 35; ' if case=='seed' else '')+'quit\n',encoding='utf-8')
 (W/'hub.cfg').write_text('wait 210; netevent ca410ds_seed; wait 35; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410ds_resume; wait 35; quit\n',encoding='utf-8')
 (W/'nestedhub.cfg').write_text('wait 210; netevent ca410ds_nested; wait 35; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410ds_nestedresume; wait 35; quit\n',encoding='utf-8')
 (W/'studyhub.cfg').write_text('wait 210; netevent ca410ds_studyseed; wait 35; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410ds_studyresume; wait 35; quit\n',encoding='utf-8')
 for v in range(4):(W/f'view{v}.cfg').write_text(f'wait 210; netevent ca410ds_view {v}; wait 70; screenshot dining-world-{v}.png; wait 35; quit\n',encoding='utf-8')
 for v in range(4):(W/f'icon{v}.cfg').write_text(f'wait 210; netevent ca410ds_icon {v}; wait 70; screenshot dining-inventory-{v}.png; wait 35; quit\n',encoding='utf-8')
 (W/'input.cfg').write_text('wait 210; netevent ca410ds_input 0; wait 35; +crouch; wait 10; +use; wait 10; -use; wait 35; netevent ca410ds_input 1; -crouch; wait 35; quit\n',encoding='utf-8')
 pack(W/'legacy-checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "legacy.zs"\n','legacy.zs':(H/'legacy.zs').read_bytes(),'MAPINFO':b'GameInfo {AddEventHandlers="CA410DiningLegacyChecks"}\ncluster 8540 {hub}\nmap CDIN410 "Dining checks" {cluster=8540}\n','maps/CDIN410.wad':flat})
 (W/'priorseed.cfg').write_text('wait 210; netevent ca410ds_priorseed; wait 35; save dining-prior39; wait 35; quit\n',encoding='utf-8')
 (W/'priorload.cfg').write_text('wait 210; netevent ca410ds_priorload; wait 35; quit\n',encoding='utf-8')
