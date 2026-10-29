"""Matched peaceful mansion render-callback comparison, not display presentation."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import statistics
import subprocess
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / 'build/issue410-cooking'
parser = argparse.ArgumentParser()
parser.add_argument('runtime')
parser.add_argument('label')
args = parser.parse_args()
prefix = WORK / args.label
assert not prefix.with_suffix('.json').exists(), 'Preserve previous evidence.'
assert not subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'], capture_output=True,text=True).stdout.strip()
source = '''class CA410MBPerf : EventHandler {
 ui Array<double> Frames;ui double Previous;ui bool Printed;
 override void RenderOverlay(RenderEvent e){
  if(level.maptime>=175 && level.maptime<875){double now=MSTimeF();if(Previous>0)Frames.Push(now-Previous);Previous=now;}
  else if(level.maptime>=875 && !Printed){Printed=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA410P FRAME %.6f",Frames[i]);}}
 override void WorldTick(){let u=CaelumPlayer(players[0].mo);if(u==null)return;
  if(level.maptime<3){u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);u.A_SetBlend("Black",0,1);}
  if(level.maptime==100){u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
   u.SetOrigin((-224,344,136),false);u.Angle=0;u.Pitch=20;
   let camera=Actor.Spawn('CA410MBPerfCamera',(-220,408,232),NO_REPLACE);
   camera.Angle=242.241459;camera.Pitch=22.740376;u.player.camera=camera;}
  if(level.maptime==175)Console.Printf("CA410P START");
  if(level.maptime==875)Console.Printf("CA410P END");}}
class CA410MBPerfCamera:Actor {Default {+NOGRAVITY +NOINTERACTION} States {Spawn:TNT1 A -1;Stop;}}
'''
addon = prefix.with_suffix('.pk3')
with zipfile.ZipFile(addon,'w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted({'ZSCRIPT':b'version "4.14"\n#include "perf.zs"\n','perf.zs':source.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA410MBPerf"}\n'}.items()):
        archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
config = '[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nvid_fullscreen=false\nuse_mouse=false\nsnd_mastervolume=0.05\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\n'
prefix.with_suffix('.ini').write_text(config)
prefix.with_suffix('.cfg').write_text('wait 885; quit\n')
package = (WORK/args.runtime/'caelum_argenteum_dev.pk3').resolve()
engine = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
iwad = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
command = [str(engine),'-noautoload','-iwad',str(iwad),'-file',str(package),str(addon),'-config',str(prefix.with_suffix('.ini')),'-width','1280','-height','720','-window','-rngseed','410','-nomouse','+logfile',str(prefix.with_suffix('.txt')),'+con_notifytime','0','+map','MAP01','+exec',str(prefix.with_suffix('.cfg'))]
startup = subprocess.STARTUPINFO()
startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
startup.wShowWindow = 0
proc = subprocess.Popen(command,cwd=WORK,startupinfo=startup,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
deadline = time.monotonic()+60
start = end = None
try:
    while proc.poll() is None:
        log = prefix.with_suffix('.txt').read_text(encoding='utf-8',errors='replace') if prefix.with_suffix('.txt').exists() else ''
        if start is None and 'CA410P START' in log: start=time.perf_counter()
        if end is None and 'CA410P END' in log: end=time.perf_counter()
        if re.search(r'Script error|VM execution aborted|Fatal:',log): raise RuntimeError(log[-1500:])
        if time.monotonic()>deadline: raise TimeoutError(args.label)
        time.sleep(.1)
    assert proc.returncode==0
finally:
    if proc.poll() is None: proc.terminate();proc.wait()
log = prefix.with_suffix('.txt').read_text(encoding='utf-8',errors='replace')
values = sorted(float(x) for x in re.findall(r'^CA410P FRAME ([0-9.]+)',log,re.M))
assert len(values)>100 and start is not None and end is not None
digest = lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
quantile = lambda p:values[int((len(values)-1)*p)]
result = {'label':args.label,'runtime_sha256':digest(package),'addon_sha256':digest(addon),'engine_sha256':digest(engine),'arguments':command,'config':config,
          'simulation_tics':700,'phase_elapsed_ms':(end-start)*1000,'phase_bound_uncertainty_ms':100,'frames':len(values),
          'mean_callback_ms':statistics.mean(values),'p95_callback_ms':quantile(.95),'p99_callback_ms':quantile(.99),'worst_callback_ms':max(values),
          'scene':'Unchanged campaign MAP01, northwest bedroom; matched viewpoint, RNG410,1280x720 Vulkan,60FPS cap; added12 bathroom fixtures and one installation controller without a custom Tick.',
          'limits':'Render-callback cadence is not GPU/display presentation; no60FPS or whole-map/sewer/army acceptance claim. No added per-tic diagnostic scan.'}
prefix.with_suffix('.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({key:value for key,value in result.items() if key not in ('arguments','config')}))
