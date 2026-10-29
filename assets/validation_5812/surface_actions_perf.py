"""Measure the laboratory's real rain setup and time-advance controls serially."""
from pathlib import Path
import argparse
import json
import re
import statistics
import subprocess
import zipfile

here = Path(__file__).resolve().parent
work = here.parents[1] / 'build/issue502-hygiene'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--label', required=True)
parser.add_argument('--bounded', action='store_true')
parser.add_argument('--fixture', default='surface-checks.pk3')
parser.add_argument('--repeats', type=int, default=0)
args = parser.parse_args()
if args.repeats<0 or args.repeats>20: parser.error('--repeats must be between 0 and 20')
advance = ('helper.StartWait(u);' if args.bounded else
           'for(int i=0;i<CaelumWorldClock.TicsPerHour()/2;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);helper.Status(u);')
source = '''class CA502SurfaceActionsPerf : EventHandler {
int Phase,BeginTic;double BeginMS;
ui double LastFrame;ui Array<double> Frames;ui Array<int> Phases;ui bool Flushed;
override void NetworkProcess(ConsoleEvent e) {
let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
let helper=CA502SChecks(EventHandler.Find('CA502SChecks'));
if(e.Name=='ca502p_dry'){helper.Manual(u);Phase=1;BeginTic=level.maptime;BeginMS=MSTimeF();}
else if(e.Name=='ca502p_rain'){
Console.Printf("CA502H WINDOW dry tics=%d ms=%.6f",level.maptime-BeginTic,MSTimeF()-BeginMS);
double start=MSTimeF();helper.RainSetup(u);Console.Printf("CA502H ACTION F4 ms=%.6f",MSTimeF()-start);
Phase=2;BeginTic=level.maptime;BeginMS=MSTimeF();}
else if(e.Name=='ca502p_wait'){
Console.Printf("CA502H WINDOW rain tics=%d ms=%.6f",level.maptime-BeginTic,MSTimeF()-BeginMS);
double start=MSTimeF();ADVANCE
Console.Printf("CA502H ACTION F5 ms=%.6f",MSTimeF()-start);
Phase=3;BeginTic=level.maptime;BeginMS=MSTimeF();}
else if(e.Name=='ca502p_rerain'){double start=MSTimeF();helper.RainSetup(u);Console.Printf("CA502H REPEATED_F4 ms=%.6f",MSTimeF()-start);}
else if(e.Name=='ca502p_end'){
Console.Printf("CA502H WINDOW wait tics=%d ms=%.6f",level.maptime-BeginTic,MSTimeF()-BeginMS);
Phase=4;Console.Printf("CA502H RESULT action performance complete");}
}
override void RenderOverlay(RenderEvent e){double now=MSTimeF();
if(Phase>0 && Phase<4){if(LastFrame>0){Frames.Push(now-LastFrame);Phases.Push(Phase);}LastFrame=now;}
if(Phase==4 && !Flushed){Flushed=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA502H FRAME %d %.6f",Phases[i],Frames[i]);}
}}
'''.replace('ADVANCE', advance)
with zipfile.ZipFile(work/args.fixture) as archive:
    members = {n: archive.read(n) for n in archive.namelist()}
members['ZSCRIPT'] = members['ZSCRIPT'].replace(b'#include "actions-perf.zs"\n',b'')+b'#include "actions-perf.zs"\n'
members['actions-perf.zs'] = source.encode()
members['MAPINFO'] = members['MAPINFO'].replace(b'GameInfo {AddEventHandlers="CA502SurfaceActionsPerf"}\n',b'')+b'GameInfo {AddEventHandlers="CA502SurfaceActionsPerf"}\n'
addon = work/(args.label+'.pk3')
with zipfile.ZipFile(addon,'w',zipfile.ZIP_STORED) as archive:
    for name, blob in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
(work/(args.label+'.cfg')).write_text(
    'wait 70; netevent ca502p_dry; wait 350; netevent ca502p_rain; wait 350; '+
    'netevent ca502p_rerain; wait 35; '*args.repeats+
    'netevent ca502p_wait; wait 350; netevent ca502p_end; wait 5; quit\n',
    encoding='utf-8',newline='\n')
result = subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(here/'run_native.ps1'),
    '-Runtime','surface-final05','-Label',args.label,'-Script',args.label,'-Addon',addon.name,
    '-StartMap','CAS502','-Checks','-TimeoutSeconds','140'],capture_output=True,text=True)
log = (work/(args.label+'.txt')).read_text(encoding='utf-8',errors='replace')
if result.returncode or 'CA502H RESULT action performance complete' not in log:
    raise RuntimeError(result.stdout+result.stderr)
metrics = {'label':args.label,'bounded':args.bounded,'fixture':args.fixture,'repeats':args.repeats,
    'scope':'Native render-callback intervals, not presentation or GPU timing.',
    'repeated_f4_ms':[float(ms) for ms in re.findall(r'CA502H REPEATED_F4 ms=([\d.]+)',log)],
    'actions_ms':{name:float(ms) for name,ms in re.findall(r'CA502H ACTION (F[45]) ms=([\d.]+)',log)},'windows':{}}
for phase,name in enumerate(('dry','rain','wait'),1):
    frames = sorted(float(ms) for p,ms in re.findall(r'CA502H FRAME (\d) ([\d.]+)',log) if int(p)==phase)
    tics,ms = re.search(r'CA502H WINDOW '+name+r' tics=(\d+) ms=([\d.]+)',log).groups()
    if len(frames)<20: raise RuntimeError('Missing frame samples: '+name)
    metrics['windows'][name]={'frames':len(frames),'mean_ms':statistics.mean(frames),
        'p95_ms':frames[int(.95*(len(frames)-1))],'p99_ms':frames[int(.99*(len(frames)-1))],
        'max_ms':max(frames),'simulation_tics_s':int(tics)*1000/float(ms)}
(work/(args.label+'-metrics.json')).write_text(json.dumps(metrics,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(metrics),flush=True)
