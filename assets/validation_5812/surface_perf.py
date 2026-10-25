"""Measure one serial, peaceful native window with render-callback timing."""
from pathlib import Path
import argparse
import json
import re
import statistics
import subprocess
import zipfile

here=Path(__file__).resolve().parent
root=here.parents[1]
work=root/'build/issue502-hygiene'
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime',required=True)
parser.add_argument('--label',required=True)
parser.add_argument('--map',default='MAP01')
parser.add_argument('--pitch',choices=('0','75'),default='0')
args=parser.parse_args()
if subprocess.run(['powershell.exe','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True).stdout.strip():
    raise RuntimeError('Preserve existing GZDoom session; measurements must be serial.')
source='''class CA502SurfacePerf : EventHandler {
int Begin;bool Started,Finished;double BeginMS;
ui double LastFrame;ui Array<double> Frames;ui bool Flushed;
override void NetworkProcess(ConsoleEvent e) {
let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
if(e.Name=='ca502p_setup'){u.Attributes.Toughness=100;u.ApplyCharacterProfile();u.health=u.CaelumMaximumHealth;u.player.health=u.health;u.Angle=0;u.Pitch=0;}
else if(e.Name=='ca502p_down')u.Pitch=75;
else if(e.Name=='ca502p_begin'){Begin=level.maptime;BeginMS=MSTimeF();Started=true;Console.Printf("CA502H PERF begin %d",Begin);}
else if(e.Name=='ca502p_end'){Finished=true;Console.Printf("CA502H PERF end %d tics=%d milliseconds=%.6f",level.maptime,level.maptime-Begin,MSTimeF()-BeginMS);Console.Printf("CA502H RESULT performance window complete");}
}
override void RenderOverlay(RenderEvent e){
double now=MSTimeF();
if(Started && !Finished){if(LastFrame>0)Frames.Push(now-LastFrame);LastFrame=now;}
if(Finished && !Flushed){Flushed=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA502H FRAME %.6f",Frames[i]);}
}}
'''
addon=work/'surface-perf.pk3'
with zipfile.ZipFile(addon,'w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted({'ZSCRIPT':b'version "4.14.2"\n#include "perf.zs"\n','perf.zs':source.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA502SurfacePerf"}\n'}.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
script='wait 70; netevent ca502p_setup; '+('netevent ca502p_down; ' if args.pitch=='75' else '')+'wait 140; netevent ca502p_begin; wait 350; netevent ca502p_end; wait 5; quit\n'
(work/(args.label+'.cfg')).write_text(script,encoding='utf-8',newline='\n')
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
result=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(here/'run_native.ps1'),
    '-Runtime',args.runtime,'-Label',args.label,'-Script',args.label,'-Addon',addon.name,'-StartMap',args.map,'-Checks','-TimeoutSeconds','140'],capture_output=True,text=True)
log=(work/(args.label+'.txt')).read_text(encoding='utf-8',errors='replace')
record=json.loads((work/(args.label+'-run.json')).read_text(encoding='utf-8-sig'))
if result.returncode or record.get('exit_code')!=0 or 'CA502H PERF end' not in log:raise RuntimeError(result.stdout+result.stderr)
frames=sorted(float(s) for s in re.findall(r'^CA502H FRAME ([\d.]+)',log,re.M))
assert len(frames)>20
elapsed=float(re.search(r'PERF end \d+ tics=350 milliseconds=([\d.]+)',log)[1])
metrics={'label':args.label,'map':args.map,'pitch':int(args.pitch),'runtime':args.runtime,'frames':len(frames),
         'mean_ms':statistics.mean(frames),'p95_ms':frames[int(.95*(len(frames)-1))],
         'p99_ms':frames[int(.99*(len(frames)-1))],'max_ms':max(frames),'simulation_tics_s':350000/elapsed,
         'scope':'RenderOverlay callback intervals, not application presents or display refresh. PresentMon access denied; no elevated trace requested.'}
(work/(args.label+'-metrics.json')).write_text(json.dumps(metrics,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(metrics),flush=True)
