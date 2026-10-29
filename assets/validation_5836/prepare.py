"""Build isolated furniture acquisition checks and reproducible probe packages."""
from pathlib import Path
import argparse
import zipfile
import struct
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-study-acquisition'
WORK.mkdir(parents=True,exist_ok=True)
a=argparse.ArgumentParser();a.add_argument('--probe',action='store_true');args=a.parse_args()
if args.probe:
 import subprocess
 prior=ROOT.parent/'issue410-sofa-acquisition-work/build/issue410-sofa-acquisition/final35a/caelum_argenteum_dev.pk3'
 changed=set(subprocess.check_output(['git','diff','--name-only','d9f561f953a53dbe48d43480fd5f331a529b659a','--','src'],cwd=ROOT,text=True).splitlines())
 changed.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines())
 changed={n[4:] for n in changed if (ROOT/n).is_file()}
 (WORK/'probe').mkdir(exist_ok=True)
 with zipfile.ZipFile(prior) as old,zipfile.ZipFile(WORK/'probe/caelum_argenteum_dev.pk3','w',zipfile.ZIP_STORED) as z:
  for name in sorted(set(old.namelist())|changed):
   data=(ROOT/'src'/name).read_bytes() if name in changed else old.read(name)
   z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
if (HERE/'checks.zs').exists():
 text='namespace="ZDoom";\n'
 for x,y in [(-1024,-1024),(-1024,1024),(1024,1024),(1024,-1024)]:text+=f'vertex {{x={x};y={y};}}\n'
 for i in range(4):text+=f'sidedef {{sector=0;texturemiddle="CMST01";}}\nlinedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}\n'
 text+='sector {heightfloor=0;heightceiling=256;texturefloor="CMST01";textureceiling="CMST01";lightlevel=224;}\nthing {x=0;y=-256;type=1;angle=90;}\n'
 lumps=[('CSUP410',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')];payload=b''.join(d for _,d in lumps);directory=b'';offset=12
 for n,d in lumps:directory+=struct.pack('<ii8s',offset,len(d),n.encode());offset+=len(d)
 flat=b'PWAD'+struct.pack('<ii',len(lumps),12+len(payload))+payload+directory
 legacy=(ROOT/'assets/validation_5826/checks.zs').read_text(encoding='utf-8')
 legacy=legacy.replace("if(e.Name=='ca410rd_profile')","if(e.Name=='ca410rf_legacy'){let c=new('CA410RestChecks');c.Legacy(u);c.Result();return;}\n        if(e.Name=='ca410rd_profile')",1)
 members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "legacy.zs"\n','checks.zs':(HERE/'checks.zs').read_bytes(),'legacy.zs':legacy.encode(),
 'MAPINFO':b'GameInfo {AddEventHandlers="CA410RestChecks"}\ncluster 8522 {hub}\nmap CSUP410 "Storage supplies"{cluster=8522}\nmap MAP01 "Mansion"{cluster=8522}\nmap CBTH410 "Away"{cluster=8522}\n',
 'maps/CSUP410.wad':flat,'maps/CBTH410.wad':(ROOT/'assets/validation_5826/away.wad').read_bytes()}
 with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as z:
  for n,d in sorted(members.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),d)
 for case in ['catalogue','craft','trade','placement','items','resume','legacy','oldresume','sofaplace','sofaresume','sofaupgrade']:
  (WORK/(case+'.cfg')).write_text('wait 210; netevent ca410rf_'+case+'; wait 35; quit\n',encoding='utf-8')
 (WORK/'oldseed.cfg').write_text('wait 210; netevent ca410rf_oldseed; wait 35; save prior-rest-supply; wait 35; quit\n',encoding='utf-8')
 (WORK/'seed.cfg').write_text('wait 210; netevent ca410rf_seed; wait 35; save rest-furniture; wait 35; quit\n',encoding='utf-8')
 (WORK/'hub.cfg').write_text('wait 210; netevent ca410rf_seed; wait 35; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410rf_resume; wait 35; quit\n',encoding='utf-8')
 (WORK/'use.cfg').write_text('wait 210; netevent ca410rf_use_seed; wait 35; +crouch; wait 10; +use; wait 10; -use; wait 35; netevent ca410rf_use_result; -crouch; wait 35; quit\n',encoding='utf-8')
 for v in range(8):
  (WORK/f'view{v}.cfg').write_text(f'wait 210; netevent ca410rf_view {v}; wait 70; screenshot rest-inventory-{v}.png; wait 35; quit\n',encoding='utf-8')
print('Prepared rest furniture diagnostics.')


for case in ('study','studyseed','studyresume','studyinput','studyupgrade'):
 (WORK/(case+'.cfg')).write_text('wait 210; netevent ca410rf_'+case+'; wait 35; quit\n',encoding='utf-8')

(WORK/'studyseed.cfg').write_text('wait 210; netevent ca410rf_studyseed; wait35; save study-furniture; wait35; quit\n'.replace('wait35','wait 35'),encoding='utf-8')
(WORK/'studyhub.cfg').write_text('wait 210; netevent ca410rf_studyseed; wait 35; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410rf_studyresume; wait 35; quit\n',encoding='utf-8')

(WORK/'studyinput.cfg').write_text('wait 210; netevent ca410rf_studyinput 0; wait 35; +crouch; wait 10; +use; wait 10; -use; wait 35; netevent ca410rf_studyinput 1; wait 35; +use; wait 10; -use; wait 35; netevent ca410rf_studyinput 2; -crouch; wait 35; quit\n',encoding='utf-8')
for k in range(2):
 (WORK/f'studygallery{k}.cfg').write_text(f'wait 210; netevent ca410rf_studygallery {k}; wait 70; screenshot study-world-{k}.png; wait 35; quit\n',encoding='utf-8')
prior=(ROOT/'assets/validation_5835/checks.zs').read_text(encoding='utf-8')
prior=prior.replace('\n    }\n    void Resume','\n        proof.Vendor=CaelumCityMerchant(Actor.Spawn(\'CaelumCityMerchant\',(0,-128,0)));\n        proof.Vendor.Category=0;proof.Vendor.StockInitialized=true;proof.Vendor.CatalogueRevision=1;proof.Vendor.RestockRevision=1;\n        CaelumRestFurnitureCatalogue.Ensure(proof.Vendor,u);\n        for(int k=0;k<6;k++){proof.Vendor.Products[k].Stock.Amount=1;u.GetPersistentCharacterState(true).LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1);}\n        Check(proof.Vendor.RestFurnitureRevision==3,"original runtime records revision3 merchant");\n    }\n    void Resume',1)
prior=prior.replace('        Check(FaceClear(u,2) && p.Item.Place(u)','        for(int k=0;k<6;k++)Check(p.Vendor.Products[k].Stock.Amount==1 && u.GetPersistentCharacterState(true).KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1),"original rollback preserves catalogue and learning");\n        Check(FaceClear(u,2) && p.Item.Place(u)',1)
oldmembers=dict(members);oldmembers['checks.zs']=prior.encode('utf-8')
with zipfile.ZipFile(WORK/'prior-checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted(oldmembers.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
(WORK/'priorseed.cfg').write_text('wait 210; netevent ca410rf_seed; wait 35; save study-prior; wait 35; quit\n',encoding='utf-8')

(WORK/'studyinstall.cfg').write_text('wait 210; netevent ca410rf_studyinstall; wait 35; quit\n',encoding='utf-8')

with zipfile.ZipFile(WORK/'gallery.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted({'ZSCRIPT':b'version "4.14"\n#include "gallery.zs"\n','gallery.zs':(HERE/'gallery.zs').read_bytes(),
                         'MAPINFO':b'GameInfo {AddEventHandlers="CA410StudyGallery"}\nmap CSUP410 "Study gallery"{}\n','maps/CSUP410.wad':flat}.items()):
  z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
for k in range(2):
 (WORK/f'visual{k}.cfg').write_text(f'wait 210; netevent ca410study_view {k}; wait 70; screenshot study-visual-{k}.png; wait 35; quit\n',encoding='utf-8')
