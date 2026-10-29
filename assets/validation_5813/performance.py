"""Native frame-callback comparison on the same small, peaceful placement fixture."""
from pathlib import Path
import argparse,hashlib,json,re,statistics,subprocess,time,zipfile
import prepare

root=prepare.ROOT;work=prepare.WORK
parser=argparse.ArgumentParser();parser.add_argument('runtime');parser.add_argument('label');parser.add_argument('--camp',action='store_true');args=parser.parse_args()
assert not (work/(args.label+'.json')).exists()
assert not subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True).stdout.strip()
placement=prepare.module('placement',root/'assets/validation_588/prepare.py');wad=prepare.module('water',root/'assets/validation_580/prepare.py')
spawn="let fire=CaelumCampFire(Actor.Spawn('CaelumCampFire',(100,128,0),NO_REPLACE));fire.Prepare();fire.Fuel.FuelGrams=10000;fire.Fuel.Lit=true;fire.RefreshVisual();" if args.camp else "let fire=Actor.Spawn('CaelumThermalFireSource',(100,128,0),NO_REPLACE);fire.args[0]=2;fire.args[1]=10;fire.args[2]=16;"
source='''class CA411Perf : EventHandler {
ui Array<double> Frames;ui double Previous;ui bool Printed;
override void RenderOverlay(RenderEvent e){
 if(level.maptime>=175 && level.maptime<875){double now=MSTimeF();if(Previous>0)Frames.Push(now-Previous);Previous=now;}
 else if(level.maptime>=875 && !Printed){Printed=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA411P FRAME %.6f",Frames[i]);}}
override void WorldTick(){let u=CaelumPlayer(players[0].mo);if(u==null)return;
 if(level.maptime<3){u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);u.A_SetBlend("Black",0,1);}
 if(level.maptime==100){u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;u.SetOrigin((30,92,0),false);u.Angle=30;u.Pitch=30;SPAWN}
 if(level.maptime==175)Console.Printf("CA411P START");
 if(level.maptime==875)Console.Printf("CA411P END");}}
'''.replace('SPAWN',spawn)
addon=work/(args.label+'.pk3')
with zipfile.ZipFile(addon,'w',zipfile.ZIP_STORED) as z:
    for name,data in sorted({'ZSCRIPT':b'version "4.14"\n#include "perf.zs"\n','perf.zs':source.encode(),'MAPINFO':b'GameInfo {AddEventHandlers="CA411Perf"}\n','maps/MAP01.wad':wad.wad(placement.room(),'MAP01')}.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
config='[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nvid_fullscreen=false\nuse_mouse=false\nsnd_mastervolume=0.05\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\n'
prefix=work/args.label;prefix.with_suffix('.ini').write_text(config);prefix.with_suffix('.cfg').write_text('wait 885; quit\n')
package=(work/args.runtime/'caelum_argenteum_dev.pk3').resolve();engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
command=[str(engine),'-noautoload','-iwad',str(iwad),'-file',str(package),str(addon),'-config',str(prefix.with_suffix('.ini')),'-width','1280','-height','720','-window','-rngseed','411','-nomouse','+logfile',str(prefix.with_suffix('.txt')),'+con_notifytime','0','+map','MAP01','+exec',str(prefix.with_suffix('.cfg'))]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
proc=subprocess.Popen(command,cwd=work,startupinfo=startup,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL);deadline=time.monotonic()+60;start=end=None
try:
    while proc.poll() is None:
        log=prefix.with_suffix('.txt').read_text(encoding='utf-8',errors='replace') if prefix.with_suffix('.txt').exists() else ''
        if start is None and 'CA411P START' in log:start=time.perf_counter()
        if end is None and 'CA411P END' in log:end=time.perf_counter()
        if re.search(r'Script error|VM execution aborted|Fatal:',log):raise RuntimeError(log[-1500:])
        if time.monotonic()>deadline:raise TimeoutError(args.label)
        time.sleep(.1)
    assert proc.returncode==0
finally:
    if proc.poll() is None:proc.terminate();proc.wait()
log=prefix.with_suffix('.txt').read_text(encoding='utf-8',errors='replace');values=sorted(float(x) for x in re.findall(r'^CA411P FRAME ([0-9.]+)',log,re.M));assert len(values)>100 and start is not None and end is not None
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();quantile=lambda p:values[int((len(values)-1)*p)]
result={'label':args.label,'runtime_sha256':digest(package),'addon_sha256':digest(addon),'engine_sha256':digest(engine),'arguments':command,'config':config,'simulation_tics':700,'phase_elapsed_ms':(end-start)*1000,'phase_bound_uncertainty_ms':100,'frames':len(values),'mean_callback_ms':statistics.mean(values),'p95_callback_ms':quantile(.95),'p99_callback_ms':quantile(.99),'worst_callback_ms':max(values),'note':'1280x720 Vulkan, 60 FPS cap, one player. Fixed source is identical before/after; --camp adds the new burning model. Callback intervals are a rendering-cadence proxy, not GPU/display presentation. This small fixture does not establish mansion, sewer or army performance.'}
prefix.with_suffix('.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps({k:v for k,v in result.items() if k not in ('arguments','config')}))
