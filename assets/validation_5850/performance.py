"""Compare renderer cadence and initialization cost with 1,000 unlinked generic inventory piles."""
import argparse,csv,ctypes,hashlib,json,re,statistics,subprocess,time,zipfile
from pathlib import Path
from datetime import datetime,timezone
root=Path(__file__).resolve().parents[2];work=root/'build/issue502-adapters'
parser=argparse.ArgumentParser();parser.add_argument('runtime');parser.add_argument('label')
a=parser.parse_args()
assert not (work/(a.label+'.json')).exists()
assert not subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True).stdout.strip()
engine=Path(r'C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path(r'C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
pm=Path(r'C:/GZDooMProjects/CaelumArgenteum/build/tools/PresentMon-2.6.0-x64.exe')
addon=work/'object-perf.pk3'
source="""class CA502PerfProp : CaelumCleaningCloth {
Default {Radius 12;Height 8;Inventory.Amount 1000000;+NOGRAVITY +NOBLOCKMAP}
States {Spawn:M042 A -1;Stop;}}
class CA502Perf : EventHandler {
Array<Actor> Bodies;ui Array<double> Frames;ui double PreviousFrame;ui bool FrameDone;
override void RenderOverlay(RenderEvent e){
if(level.maptime>=175 && level.maptime<875){double now=MSTimeF();if(PreviousFrame>0)Frames.Push(now-PreviousFrame);PreviousFrame=now;}
else if(level.maptime>=875 && !FrameDone){FrameDone=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA502P FRAME %.6f",Frames[i]);}}
override void WorldTick(){
let u=CaelumPlayer(players[0].mo);if(u==null)return;
if(level.maptime==70){u.SetOrigin((-960,-640,0),false);u.Angle=0;
for(int i=0;i<1000;i++)Bodies.Push(Actor.Spawn('CA502PerfProp',(-800+(i%25)*64,-600+(i/25)*64,0),NO_REPLACE));
int population=0;let it=ThinkerIterator.Create('Actor');while(it.Next()!=null)population++;
WorldEvent reload;double begin=MSTimeF();CaelumContaminationWorld.Get().WorldLoaded(reload);
Console.Printf("CA502P CENSUS actors=%d elapsed_ms=%.6f",population,MSTimeF()-begin);}
if(level.maptime==175)Console.Printf("CA502P START bodies=%d",Bodies.Size());
if(level.maptime==875){int intact=0,exposed=0;for(int i=0;i<Bodies.Size();i++){
if(Bodies[i]!=null && !Bodies[i].bDestroyed)intact++;
if(CaelumContaminationStorage.Value(Bodies[i])>0)exposed++;}
Console.Printf("CA502P CONTACT receivers_exposed=%d",exposed);
Console.Printf("CA502P END tics=700 bodies=%d intact=%d",Bodies.Size(),intact);}
}}
"""
# Rebuild only the diagnostic arena size; no production map is modified.
import struct
textmap='namespace="ZDoom";\n'
for x,y in [(-4096,-4096),(-4096,4096),(4096,4096),(4096,-4096)]:textmap+=f'vertex {{x={x};y={y};}}\n'
for i in range(4):textmap+=f'linedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}\n'
for i in range(4):textmap+='sidedef {sector=0;texturemiddle="CMST01";}\n'
textmap+='sector {heightfloor=0;heightceiling=256;texturefloor="CMST01";textureceiling="F_SKY1";lightlevel=192;user_ca_contamination_class=2;}\n'
textmap+='thing {x=-960;y=-640;type=1;angle=0;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;}\n'
wad=bytearray(b'PWAD'+struct.pack('<ii',3,0));direct=[]
for name,blob in [(b'MAP01',b''),(b'TEXTMAP',textmap.encode()),(b'ENDMAP',b'')]:
 direct.append((len(wad),len(blob),name));wad.extend(blob)
offset=len(wad)
for row in direct:wad.extend(struct.pack('<ii8s',*row))
struct.pack_into('<i',wad,8,offset);wad=bytes(wad)
count,offset=struct.unpack_from('<ii',wad,4);lumps=[]
for i in range(count):
 start,size,name=struct.unpack_from('<ii8s',wad,offset+i*16);blob=wad[start:start+size]
 if name.rstrip(b'\0')==b'TEXTMAP':blob=blob.replace(b'-320',b'-4096').replace(b'320',b'4096').replace(b'lightlevel=192;',b'lightlevel=192;user_ca_contamination_class=2;')
 lumps.append((name,blob))
data=bytearray(b'PWAD'+struct.pack('<ii',len(lumps),0));directory=[]
for name,blob in lumps:directory.append((len(data),len(blob),name));data.extend(blob)
offset=len(data)
for row in directory:data.extend(struct.pack('<ii8s',*row))
struct.pack_into('<i',data,8,offset)
with zipfile.ZipFile(addon,'w',zipfile.ZIP_STORED) as z:
 for n,b in sorted({'ZSCRIPT':b'version "4.14.2"\n#include "perf.zs"\n','perf.zs':source.encode(),'maps/MAP01.wad':bytes(data),'MAPINFO':b'GameInfo { AddEventHandlers="CA502Perf" }\nmap MAP01 "Object exposure performance laboratory" {cluster=434 sky1="SKY1"}\n'}.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
config='[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nvid_fullscreen=false\nuse_mouse=false\nsnd_mastervolume=0.05\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\n'
prefix=work/a.label;cfg=prefix.with_suffix('.ini');cfg.write_text(config)
script=prefix.with_suffix('.cfg');script.write_text('wait 885; quit\n')
log=prefix.with_suffix('.txt');csvpath=prefix.with_suffix('.csv')
package=work/a.runtime/'caelum_argenteum_dev.pk3'
args=[str(engine),'-noautoload','-iwad',str(iwad),'-file',str(package),str(addon),'-config',str(cfg),'-width','1280','-height','720','-window','-rngseed','502','-nomouse','+logfile',str(log),'+con_notifytime','0','+map','MAP01','+exec',str(script)]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
pmargs=[str(pm),'--process_name','gzdoom.exe','--output_file',str(csvpath),'--no_console_stats','--qpc_time_ms','--session_name','Caelum502Objects','--timed','65','--terminate_after_timed','--terminate_on_proc_exit']
with (work/(a.label+'-presentmon.txt')).open('w') as pmout:
 monitor=subprocess.Popen(pmargs,cwd=work,startupinfo=startup,stdout=pmout,stderr=subprocess.STDOUT);time.sleep(.3)
 proc=subprocess.Popen(args,cwd=work,startupinfo=startup,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 start=end=None;deadline=time.monotonic()+55
 try:
  while proc.poll() is None:
   data=log.read_text(errors='replace') if log.exists() else ''
   if start is None and 'CA502P START' in data:start=time.perf_counter()*1000
   if end is None and 'CA502P END' in data:end=time.perf_counter()*1000
   if 'Script error' in data or 'VM execution aborted' in data:raise RuntimeError(data[-1600:])
   if time.monotonic()>deadline:raise TimeoutError(a.label)
   time.sleep(.1)
  assert proc.returncode==0,proc.returncode
  monitor.wait(timeout=8)
 finally:
  if proc.poll() is None:proc.terminate();proc.wait()
  if monitor.poll() is None:monitor.terminate();monitor.wait()
assert start is not None and end is not None
rows=list(csv.DictReader(csvpath.open(encoding='utf-8-sig'))) if csvpath.exists() else []
values=[float(v) for v in re.findall(r'^CA502P FRAME ([0-9.]+)',log.read_text(),re.M)]
assert len(values)>100, len(values)
values.sort();percentile=lambda p:values[min(len(values)-1,int((len(values)-1)*p))]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
report={'label':a.label,'utc':datetime.now(timezone.utc).isoformat(),'runtime_sha256':digest(package),'fixture_sha256':digest(addon),'engine_sha256':digest(engine),'presentmon_sha256':digest(pm),'arguments':args,'presentmon_arguments':pmargs,'config':config,'simulation_tics':700,'receivers_exposed':int(re.search(r'CA502P CONTACT receivers_exposed=(\d+)',data).group(1)),'spawned_objects':1000,'census_population':int(re.search(r'CA502P CENSUS actors=(\d+)',data).group(1)),'census_ms':float(re.search(r'elapsed_ms=([0-9.]+)',data).group(1)),'phase_elapsed_ms':end-start,'phase_bound_uncertainty_ms':100,'frames':len(values),'mean_callback_ms':statistics.mean(values),'p95_callback_ms':percentile(.95),'p99_callback_ms':percentile(.99),'worst_callback_ms':max(values),'present_modes':sorted({r.get('PresentMode','') for r in rows}),'presentmon_available':bool(rows),'presentmon_result':(work/(a.label+'-presentmon.txt')).read_text(encoding='utf-16'),'note':'Peaceful 1,000 unlinked generic inventory piles, one million native units each; active exposure and climate sampling, no artificial per-object Tick. One complete initialization census is measured immediately after spawning. Not a 6,000-attacker scenario. Not whole-campaign or siege FPS acceptance. RenderOverlay callback intervals are a renderer cadence proxy, not displayed frames or GPU execution. PresentMon capture requires unavailable Windows privileges.'}
report['object_kind']='unlinked generic inventory pile'
if a.runtime!='original49':assert report['receivers_exposed']==1000,report['receivers_exposed']
(work/(a.label+'.json')).write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:report[k] for k in ['label','census_population','census_ms','receivers_exposed','frames','mean_callback_ms','p95_callback_ms','p99_callback_ms','worst_callback_ms','phase_elapsed_ms']}),flush=True)
