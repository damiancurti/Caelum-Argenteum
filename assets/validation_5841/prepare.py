"""Prepare private native household persistence diagnostics."""
from pathlib import Path
import subprocess,zipfile,argparse
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-house-absence';W.mkdir(parents=True,exist_ok=True)
p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
def pack(path,members):
 with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
  for n,d in sorted(members.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),d)
if a.probe:
 old=R.parent/'issue410-dining-work/build/issue410-dining/final40a/caelum_argenteum_dev.pk3'
 names=set(subprocess.check_output(['git','diff','4b9b70d329b325a654f7a0540691b32941e1e427','--name-only','--','src'],cwd=R,text=True).splitlines())|set(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
 changed={n[4:] for n in names};(W/'probe').mkdir(exist_ok=True)
 with zipfile.ZipFile(old) as z:pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
 print('Probe ready:',len(changed),'changed files')
prior=(R/'assets/validation_5812/domestic_checks.zs').read_text(encoding='utf-8').replace('"CA502D ','"CA502H ')


# The inherited fixture picked a merely visible route; current furniture may
# obstruct it on the unchanged prior runtime as well. Select using real native
# collision, restore the worker, then exercise the actual accelerated clock.
walkable=""" bool DiagnosticWalkable(CaelumPortDefender body,vector3 point){
 vector3 origin=body.Pos;vector2 delta=point.XY-origin.XY;bool fits=true;
 if(delta.Length()<=body.MeleeRange+body.Speed || delta.Length()>192)return false;
 for(int step=0;step<256 && (body.Pos.XY-point.XY).Length()>body.MeleeRange;step++){
 delta=point.XY-body.Pos.XY;
 if(!body.ThermalTryMove(body.Pos.XY+delta.Unit()*Min(body.Speed,delta.Length()))){fits=false;break;}}
 if((body.Pos.XY-point.XY).Length()>body.MeleeRange)fits=false;
 body.SetOrigin(origin,false);body.FindFloorCeiling();CaelumStudyUse.ClearContacts(body);return fits;
 }
"""
prior=prior.replace(' void Skipped(CaelumPlayer u){',walkable+' void Skipped(CaelumPlayer u){')
prior=prior.replace('if(d<best && w.Worker.CheckSight(w.Goal,SF_IGNOREVISIBILITY)){best=d;chosen=i;}', 'if(d<best && w.Worker.CheckSight(w.Goal,SF_IGNOREVISIBILITY) && DiagnosticWalkable(w.Worker,t.Position)){best=d;chosen=i;}')
prior=prior.replace('accelerated-clock target is behind real resident in accessible room','accelerated-clock target has a verified native collision path')
pack(W/'checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "prior.zs"\n#include "checks.zs"\n','prior.zs':prior.encode(),'checks.zs':(H/'house_checks.zs').read_bytes(),'MAPINFO':b'GameInfo {AddEventHandlers="CA502HouseAbsenceChecks"}\n'})
scripts={'seed':'wait 350; netevent ca502h_market; wait 35; changemap CAH000; wait 210; netevent ca502h_seed; wait 35; changemap MAP01; wait 210; netevent ca502h_away; wait 35; save house-current; wait 35; quit',
 'load':'wait 210; netevent ca502h_load; wait 35; quit',
 'back':'wait 210; netevent ca502h_load; wait 35; changemap CAH000; wait 210; netevent ca502h_back; wait 35; changemap MAP01; wait 210; netevent ca502h_load; wait 35; changemap CAH000; wait 210; netevent ca502h_back; wait 35; quit'}
for n,s in scripts.items():(W/(n+'.cfg')).write_text(s+'\n',encoding='utf-8')
if not(H/'run_native.ps1').exists():(H/'run_native.ps1').write_text((R/'assets/validation_5840/run_native.ps1').read_text(encoding='utf-8').replace('issue410-dining','issue502-house-absence').replace('CA410DS','CA502H'),encoding='utf-8')

# Reuse loaded-house assertions on both runtimes; only the skipped-route selector
# is adapted above to verify current native collision before simulating time.
pack(W/'domestic-checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':prior.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA502DomesticChecks"}\n'})
regression={
 'domestic-core':'wait 350; netevent ca502d_market; wait 3; changemap CAH000; wait 100; netevent ca502d_house; wait 3; netevent ca502d_clean; wait 3; netevent ca502d_save; wait 3; save domestic-current; wait 3; quit',
 'domestic-load':'wait 70; netevent ca502d_load; wait 3; quit',
 'domestic-hub':'wait 35; changemap MAP03; wait 100; netevent ca502d_return; wait 3; changemap CAH000; wait 100; netevent ca502d_load; wait 3; quit',
 'domestic-shortages':'wait 35; netevent ca502d_shortages; wait 3; quit',
 'domestic-clock':'wait 35; netevent ca502d_auto_start; wait 350; netevent ca502d_auto_check; wait 3; quit',
 'domestic-skipped':'wait 35; netevent ca502d_skipped; wait 3; quit',
 'prior-seed':'wait 350; netevent ca502d_market; wait 3; changemap CAH000; wait 100; netevent ca502d_house; wait 3; netevent ca502d_clean; wait 3; netevent ca502d_save; wait 3; save house-prior40; wait 3; quit'}
for n,s in regression.items():(W/(n+'.cfg')).write_text(s+'\n',encoding='utf-8')

bridge=prior.replace('else return;Console.Printf("CA502H RESULT', """else if(e.Name=='ca502d_adopt'){
let w=Work();let store=CaelumHouseStorage.Get();
Check(w!=null && w.Chest!=null && w.Chest.DomesticStorage!=null,"old household adopts storage automatically on load");
Check(store!=null && store.Revision==1 && store.Houses.Size()==1,"additive registry starts at revision one without duplication");
Loaded(u);
} else return;Console.Printf("CA502H RESULT""")
pack(W/'legacy-checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':bridge.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA502DomesticChecks"}\n'})
(W/'migration.cfg').write_text('wait 70; netevent ca502d_adopt; wait 3; changemap MAP01; wait 100; changemap CAH000; wait 100; netevent ca502d_adopt; wait 3; save house-upgraded; wait 3; quit\n')
(W/'samehub.cfg').write_text('wait 70; netevent ca502h_load; wait 3; changemap CAH000; wait 100; netevent ca502h_back; wait 3; changemap MAP03; wait 100; netevent ca502h_load; wait 3; changemap CAH000; wait 100; netevent ca502h_back; wait 3; quit\n')

(W/'perf.cfg').write_text('wait 70; changemap CAH000; wait 100; netevent ca502h_perf; wait 3; quit\n')
