"""Compare the real four-resident house before and during domestic cleaning."""
import argparse, hashlib, json, re, statistics, subprocess, time, zipfile
from pathlib import Path
from datetime import datetime, timezone

root = Path(__file__).resolve().parents[2]
work = root / 'build/issue502-hygiene'
parser = argparse.ArgumentParser()
parser.add_argument('runtime')
parser.add_argument('label')
args = parser.parse_args()
assert not (work / (args.label + '.json')).exists()
assert not subprocess.run(['powershell', '-NoProfile', '-Command', '(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'], capture_output=True, text=True).stdout.strip()
source = '''class CA502DomesticPerf : EventHandler {
ui Array<double> Frames;ui double Previous;ui bool Printed;
override void RenderOverlay(RenderEvent e){
 if(level.maptime>=175 && level.maptime<875){double now=MSTimeF();if(Previous>0)Frames.Push(now-Previous);Previous=now;}
 else if(level.maptime>=875 && !Printed){Printed=true;for(int i=0;i<Frames.Size();i++)Console.Printf("CA502P FRAME %.6f",Frames[i]);}}
override void WorldTick(){
 let u=CaelumPlayer(players[0].mo);if(u==null)return;
 if(level.maptime==100){
  let it=ThinkerIterator.Create('CaelumStashChest');let chest=CaelumStashChest(it.Next());
  let soap=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos,NO_REPLACE));soap.args[0]=CaelumHygieneData.SOAP;soap.args[1]=1;soap.Amount=300;soap.AttachToOwner(chest);
  let cloth=Inventory(Actor.Spawn('CaelumCleaningCloth',u.Pos,NO_REPLACE));cloth.AttachToOwner(chest);
  Console.Printf("CA502P SUPPLIES soap=300 cloth=1");}
 if(level.maptime==175)Console.Printf("CA502P START");
 if(level.maptime==875){let it=ThinkerIterator.Create('CaelumStashChest');let chest=CaelumStashChest(it.Next());int soap=0;
  for(Inventory item=chest.Inv;item!=null;item=item.Inv){let mat=CaelumMaterialPickup(item);if(mat!=null && mat.GetSpecialType()==CaelumHygieneData.SOAP)soap+=item.Amount;}
  Console.Printf("CA502P END soap=%d",soap);}
}}
'''
addon = work / 'domestic-perf.pk3'
with zipfile.ZipFile(addon, 'w', zipfile.ZIP_STORED) as archive:
    for name, data in sorted({'ZSCRIPT': b'version "4.14.2"\n#include "perf.zs"\n', 'perf.zs': source.encode(), 'MAPINFO': b'GameInfo { AddEventHandlers="CA502DomesticPerf" }\n'}.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
config = '[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nvid_fullscreen=false\nuse_mouse=false\nsnd_mastervolume=0.05\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\n'
prefix = work / args.label
prefix.with_suffix('.ini').write_text(config, encoding='utf-8')
prefix.with_suffix('.cfg').write_text('wait 885; quit\n', encoding='utf-8')
package = work / args.runtime / 'caelum_argenteum_dev.pk3'
engine = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
iwad = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
command = [str(engine), '-noautoload', '-iwad', str(iwad), '-file', str(package), str(addon), '-config', str(prefix.with_suffix('.ini')), '-width', '1280', '-height', '720', '-window', '-rngseed', '502', '-nomouse', '+logfile', str(prefix.with_suffix('.txt')), '+con_notifytime', '0', '+map', 'CAH000', '+exec', str(prefix.with_suffix('.cfg'))]
startup = subprocess.STARTUPINFO()
startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
startup.wShowWindow = 0
proc = subprocess.Popen(command, cwd=work, startupinfo=startup, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
deadline = time.monotonic() + 60
start = end = None
try:
    while proc.poll() is None:
        log = prefix.with_suffix('.txt').read_text(encoding='utf-8', errors='replace') if prefix.with_suffix('.txt').exists() else ''
        if start is None and 'CA502P START' in log:
            start = time.perf_counter()
        if end is None and 'CA502P END' in log:
            end = time.perf_counter()
        if re.search(r'Script error|VM execution aborted|Fatal:', log):
            raise RuntimeError(log[-1800:])
        if time.monotonic() > deadline:
            raise TimeoutError(args.label)
        time.sleep(.1)
    assert proc.returncode == 0
finally:
    if proc.poll() is None:
        proc.terminate()
        proc.wait()
log = prefix.with_suffix('.txt').read_text(encoding='utf-8', errors='replace')
values = sorted(float(x) for x in re.findall(r'^CA502P FRAME ([0-9.]+)', log, re.M))
assert len(values) > 100 and start is not None and end is not None
quantile = lambda p: values[int((len(values)-1)*p)]
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
report = {'label': args.label, 'utc': datetime.now(timezone.utc).isoformat(), 'runtime_sha256': digest(package), 'fixture_sha256': digest(addon), 'engine_sha256': digest(engine), 'arguments': command, 'config': config, 'simulation_tics': 700, 'phase_elapsed_ms': (end-start)*1000, 'phase_bound_uncertainty_ms': 100, 'frames': len(values), 'mean_callback_ms': statistics.mean(values), 'p95_callback_ms': quantile(.95), 'p99_callback_ms': quantile(.99), 'worst_callback_ms': max(values), 'soap_remaining_whole_grams': int(re.search(r'CA502P END soap=(\d+)', log).group(1)), 'note': 'Native CAH000 with its four residents and normal AI/collision. Identical real coffer supplies and camera, no diagnostic actor population. RenderOverlay intervals are a rendering cadence proxy, not displayed frames or GPU time. PresentMon unavailable in this environment (objects evidence).'}
prefix.with_suffix('.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print(json.dumps({key: report[key] for key in ['label', 'frames', 'mean_callback_ms', 'p95_callback_ms', 'p99_callback_ms', 'worst_callback_ms', 'phase_elapsed_ms', 'soap_remaining_whole_grams']}))
