from pathlib import Path
import importlib.util,zipfile,subprocess
root=Path(__file__).resolve().parents[2];out=root/'build/issue581/handoff';out.mkdir(parents=True,exist_ok=True)
for script in [('assets/validation_v5_11_1/prepare.py','--full'),('assets/validation_v5_11_4/prepare_manual.py',),('assets/validation_v5_11_4/prepare.py','--full')]:
 subprocess.run(['python',*script],cwd=root,check=True)
with zipfile.ZipFile(root/'build/issue430/manual.pk3') as z:files={n:z.read(n) for n in z.namelist()}
extra='''class CA581Handoff : EventHandler
{
 void Visit(CaelumPlayer user,Actor body)
 {if(body!=null){user.SetOrigin(body.Pos+(64,0,0),false);user.Angle=user.AngleTo(body);user.Pitch=0;}}
 override void NetworkProcess(ConsoleEvent e)
 {
  let user=CaelumPlayer(players[0].mo);if(user==null)return;
  if(e.Name=='ca581_rental' || e.Name=='ca581_guard')
  {
   let port=CaelumPortSiege.Get();if(port==null)return;
   if(e.Name=='ca581_rental')Visit(user,port.RentalAgent);
   else for(int i=0;i<port.Defenders.Size();i++)if(port.Defenders[i]!=null && port.Defenders[i].health>0){Visit(user,port.Defenders[i]);break;}
   Console.Printf("CA581 RESULT dialogue visit ready");
  }
  if(e.Name=='ca581_access')
  {
   let property=CaelumPropertyRules.Find(69,true);property.Holder=CaelumLockRules.Character(user,true);property.Purchased=true;
   Console.Printf("CA581 RESULT local house access fixture ready");
  }
  if(e.Name=='ca581_room')
  {user.SetOrigin(CaelumCityData.HouseOrigin(69)+(656,1000,0),false);user.Angle=90;user.Pitch=0;Console.Printf("CA581 RESULT workshop view ready");}
  if(e.Name=='ca581_cot')
  {user.SetOrigin(CaelumCityData.HouseOrigin(69)+(320,256,0),false);user.Angle=180;user.Pitch=0;Console.Printf("CA581 RESULT cot view ready");}
  if(e.Name=='ca581_outside')
  {user.SetOrigin((-768,1344,0),false);user.Angle=90;user.Pitch=0;Console.Printf("CA581 RESULT former street location ready");}
 }
}
'''
files['handoff.zs']=extra.encode();files['ZSCRIPT']+=b'\n#include "handoff.zs"\n';files['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA581Handoff" }\n'
with zipfile.ZipFile(out/'manual.pk3','w') as z:
 for n,b in sorted(files.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
# Dedicated rat fixture, no production source override.
spec=importlib.util.spec_from_file_location('room',root/'assets/validation_595/prepare.py');room=importlib.util.module_from_spec(spec);spec.loader.exec_module(room)
with zipfile.ZipFile(out/'rat.pk3','w') as z:
 for n,b in {'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':(root/'assets/validation_v5_11_6/checks.zs').read_bytes(),'maps/MAP03.wad':room.wad(),'MAPINFO':b'GameInfo { AddEventHandlers="CA582Checks" }\n'}.items():z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
# Production-final regression fixture contains only diagnostic classes.
with zipfile.ZipFile(root/'build/issue430/full-checks.pk3') as z:files={n:z.read(n) for n in z.namelist()}
files['motion_checks.zs']=(root/'assets/validation_v5_11_4/motion_checks.zs').read_bytes();files['ZSCRIPT']+=b'\n#include "motion_checks.zs"\n';files['MAPINFO']+=b'\nGameInfo { AddEventHandlers="CA430MotionChecks" }\n'
with zipfile.ZipFile(out/'motion.pk3','w') as z:
 for n,b in sorted(files.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
