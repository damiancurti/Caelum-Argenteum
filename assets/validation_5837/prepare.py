"""Build deterministic isolated seal-history fixtures and an optional probe."""
from pathlib import Path
import argparse, importlib.util, subprocess, sys, zipfile
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue502-seal-history'
WORK.mkdir(exist_ok=True,parents=True)
parser=argparse.ArgumentParser();parser.add_argument('--probe',action='store_true');args=parser.parse_args()
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
room=module('placement',ROOT/'assets/validation_588/prepare.py').room().replace('textureceiling="CMST02"','textureceiling="F_SKY1"').replace('sector {','sector { user_ca_contamination_class=2;')
wad=module('water',ROOT/'assets/validation_580/prepare.py').wad
legacy=(ROOT/'assets/validation_5828/checks.zs').read_text(encoding='utf-8').replace('n.Revision==3','n.Revision==4').replace('revision3','revision4')
members={'ZSCRIPT':b'version "4.14"\n#include "weather.zs"\n#include "checks.zs"\n','weather.zs':legacy.encode(),'checks.zs':(HERE/'checks.zs').read_bytes(),
 'MAPINFO':b'GameInfo {AddEventHandlers="CA502SealChecks","CA502SealObserver"}\ncluster 8537 {hub}\nmap CWH502 "Seal history" {cluster=8537}\nmap CWH502B "Away" {cluster=8537}\n',
 'maps/CWH502.wad':wad(room,'CWH502'),'maps/CWH502B.wad':wad(room,'CWH502B')}
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
(WORK/'bridge').mkdir(exist_ok=True)
(WORK/'bridge/prior-checks.pk3').write_bytes((WORK/'checks.pk3').read_bytes())
commands={'core':'netevent ca502h_core','weather':'netevent ca502w_core','seed':'netevent ca502h_seed; wait 35; save seal-current37','load':'netevent ca502h_load',
 'hub':'netevent ca502h_seed; wait 35; changemap CWH502B; wait 70; netevent ca502w_away; changemap CWH502; wait 70; netevent ca502w_resume',
 'perf':'netevent ca502h_perf','legacy':'netevent ca502h_legacy','oldseed':'netevent ca502h_oldseed; save seal-prior36','oldcheck':'netevent ca502h_oldcheck',
 'rainseed':'netevent ca502h_rainseed; save seal-rain37','rainload':'netevent ca502h_rainload'}
for name,command in commands.items():(WORK/(name+'.cfg')).write_text('wait 140; '+command+'; wait 10; quit\n',encoding='utf-8')
source=(HERE/'checks.zs').read_text(encoding='utf-8')
begin=source[source.index('    void BeginSeal'):source.index('    void Seals')]
old='''class CA502SealChecks : CA502WeatherChecks
{
    CaelumChannelEffect Channel;bool SealDepartureObserved;
'''+begin+'''
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        let n=CaelumContaminationStorage.Get(Probe).Exposure;
        if(e.Name=='ca502h_oldseed')
        {
            Probe.bSolid=false;BeginSeal(user,CaelumConstants.SEAL_FIRE);n.Advance();
            CaelumContaminationStorage.Set(Probe,60);n.ChangeStatNum(Thinker.STAT_FIRST_THINKING-5);
            Check(n.Revision==3 && !n.HistoryReady,"original runtime has unrecorded actual seal interval");
            Check(CaelumSealClimate.Active(Channel),"original runtime has actual active channel");
        }
        else if(e.Name=='ca502h_oldcheck')
        {
            Check(n.Revision==3 && !n.HistoryReady,"unchanged original save reopens in original runtime");
            Check(Near(CaelumContaminationStorage.Get(Probe).Concentration,60),"original rollback retains exact saved concentration");
        }
        else return;
        Console.Printf("CA502W RESULT passed=%d failed=%d",Passed,Failed);
    }
}
'''
oldmembers=dict(members);oldmembers['weather.zs']=(ROOT/'assets/validation_5828/checks.zs').read_bytes();oldmembers['checks.zs']=old.encode()
oldmembers['MAPINFO']=members['MAPINFO'].replace(b',"CA502SealObserver"',b'')
with zipfile.ZipFile(WORK/'prior-checks.pk3','w',zipfile.ZIP_STORED) as z:
 for n,d in sorted(oldmembers.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),d)
if args.probe:
 prior=ROOT.parent/'issue410-study-acquisition-work/build/issue410-study-acquisition/final36b/caelum_argenteum_dev.pk3'
 changed=set(subprocess.check_output(['git','diff','--name-only','685c8d76372efbe27798d3577a1ab31edebd2d12','--','src'],cwd=ROOT,text=True).splitlines())
 changed.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines())
 changed={n[4:] for n in changed if (ROOT/n).is_file()};(WORK/'probe').mkdir(exist_ok=True)
 with zipfile.ZipFile(prior) as old,zipfile.ZipFile(WORK/'probe/caelum_argenteum_dev.pk3','w',zipfile.ZIP_STORED) as z:
  for n in sorted(set(old.namelist())|changed):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),(ROOT/'src'/n).read_bytes() if n in changed else old.read(n))
print('Prepared seal-history fixtures.')
