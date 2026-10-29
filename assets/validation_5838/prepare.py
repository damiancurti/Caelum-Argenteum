"""Build deterministic NPC illness fixtures and a source-overlay probe."""
from pathlib import Path
import argparse,importlib.util,subprocess,sys,zipfile
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue502-npc-illness';WORK.mkdir(parents=True,exist_ok=True)
p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');args=p.parse_args()
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
room=module('placement',ROOT/'assets/validation_588/prepare.py').room()
wad=module('water',ROOT/'assets/validation_580/prepare.py').wad
members={'ZSCRIPT':b'version "4.14"\n#include "npc.zs"\n#include "checks.zs"\n',
 'npc.zs':(ROOT/'assets/validation_5812/npc_checks.zs').read_bytes(),'checks.zs':(HERE/'checks.zs').read_bytes(),
 'MAPINFO':b'GameInfo {AddEventHandlers="CA502IllnessChecks"}\ncluster 8538 {hub}\nmap CIN502 "NPC illness" {cluster=8538}\nmap CIN502B "Away" {cluster=8538}\n',
 'maps/CIN502.wad':wad(room,'CIN502'),'maps/CIN502B.wad':wad(room,'CIN502B')}
def package(path,items):
 with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
  for n,d in sorted(items.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),d)
package(WORK/'checks.pk3',members)
(WORK/'bridge').mkdir(exist_ok=True);(WORK/'bridge/prior-checks.pk3').write_bytes((WORK/'checks.pk3').read_bytes())
old=dict(members);old['checks.zs']=b'''class CA502IllLive : CaelumPortDefender {bool Running;override void Tick(){if(Running)Super.Tick();}}
class CA502IllnessChecks : CA502NPCChecks {
CA502IllLive LiveNPC;double SavedFraction,SavedDirt;int SavedHealth,BeginTic;
override void NetworkProcess(ConsoleEvent e){
let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
if(e.Name=='ca502i_oldseed'){
Prepare(u);Soldier.ChangeTid(905038);Soldier.CombatMaximumHealth=Soldier.health=100;Soldier.CombatToughness=0;
CaelumContaminationStorage.Set(Soldier,60);
Check(CaelumContaminationStorage.Value(Soldier)==60 && Soldier.health==100,"original runtime retains contaminated body without illness damage");
}else if(e.Name=='ca502i_oldcheck'){
Soldier=CA502NPCSoldier(ActorIterator.Create(905038).Next());
Check(Soldier!=null && Soldier.health==100 && CaelumContaminationStorage.Value(Soldier)==60,"original saved body rolls back unchanged");
}else {Super.NetworkProcess(e);return;}Console.Printf("CA502N RESULT passed=%d failures=%d",Passed,Failed);
}}
'''
package(WORK/'prior-checks.pk3',old)
commands={'core':'netevent ca502i_core','recovery':'netevent ca502i_recovery','exposure':'netevent ca502n_prepare; netevent ca502n_core',
 'seed':'netevent ca502i_seed; save npc-current38','load':'netevent ca502i_load',
 'hub':'netevent ca502i_seed; changemap CIN502B; wait 70; changemap CIN502; wait 35; netevent ca502i_load',
 'legacy':'netevent ca502i_legacy','oldseed':'netevent ca502i_oldseed; save npc-prior37','oldcheck':'netevent ca502i_oldcheck',
 'live':'netevent ca502i_start; wait 70; netevent ca502i_mark; wait 70; netevent ca502i_end',
 'clock':'netevent ca502i_start; wait 70; netevent ca502i_jump; wait 70; netevent ca502i_end','perf':'netevent ca502i_perf'}
for name,c in commands.items():
 if name in ('core','recovery','seed','hub','exposure','oldseed'):c='netevent ca502n_prepare; wait 3; '+c
 (WORK/(name+'.cfg')).write_text('wait 105; '+c+'; wait 3; quit\n',encoding='utf-8')
if args.probe:
 prior=ROOT.parent/'issue502-seal-history-work/build/issue502-seal-history/final37a/caelum_argenteum_dev.pk3'
 changed=set(subprocess.check_output(['git','diff','--name-only','39adda1c','--','src'],cwd=ROOT,text=True).splitlines())
 changed.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines())
 changed={n[4:] for n in changed if (ROOT/n).is_file()};(WORK/'probe').mkdir(exist_ok=True)
 with zipfile.ZipFile(prior) as old,zipfile.ZipFile(WORK/'probe/caelum_argenteum_dev.pk3','w',zipfile.ZIP_STORED) as z:
  for n in sorted(set(old.namelist())|changed):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),(ROOT/'src'/n).read_bytes() if n in changed else old.read(n))
print('Prepared NPC illness fixtures.')
