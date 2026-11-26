"""Run isolated visibility boundaries and reversible save continuation."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,shutil,subprocess,time,zipfile
root=Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime',type=Path,required=True)
parser.add_argument('--known-distance',action='store_true')
parser.add_argument('--output',type=Path,required=True)
parser.add_argument('--candidate',type=Path)
parser.add_argument('--load',type=Path)
args=parser.parse_args()
out=args.output.resolve();out.relative_to(root/'build');out.mkdir(parents=True,exist_ok=False)
spec=importlib.util.spec_from_file_location('vision_fixture',root/'assets/validation_5100/prepare.py');fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
source=Path(__file__).with_name('vision_edge_checks.zs').read_text(encoding='utf-8')
if args.candidate or args.known_distance:source=source.replace('return CaelumVisualPerception.CanSee(Observer,subject);','return CaelumVisualPerception.CanSee(Observer,subject,Observer.Distance3D(subject));')
checks=out/'checks.pk3'
members={'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA425A.wad':fixture.room(),'MAPINFO':b'gameinfo { AddEventHandlers="CA454VisionEdges" }\nmap CA425A "Visibility edges" {}\n'}
with zipfile.ZipFile(checks,'w',zipfile.ZIP_STORED) as archive:
    for name,data in members.items():archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),data)
runtime=args.runtime.resolve(strict=True);engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
config=out/'session.ini';config.write_bytes(b'[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_maxfps=60\nlanguage=en\n')
commands=out/'commands.cfg';commands.write_text('wait 100; netevent '+('ca454reload' if args.load else 'ca454seed')+'; wait 10; save vision.zds; wait 10; quit\n',encoding='utf-8')
packages=[runtime]+([args.candidate.resolve()] if args.candidate else [])+[checks]
command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',*map(str,packages),'-config',str(config),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log')]
if args.load:
    shutil.copyfile(args.load.resolve(),out/'input.zds')
    command+=['-loadgame','input.zds']
else:command+=['+map','CA425A']
command+=['+exec',str(commands)]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
inventory=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
if '"gzdoom.exe"' in inventory.lower():raise SystemExit('Another native engine is running; preserve it before starting this test.')
with (out/'process.log').open('wb') as log:
    proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup)
    deadline=time.monotonic()+90;stopped=None
    while proc.poll() is None:
        log_path=out/'engine.log';sample=log_path.read_text(encoding='utf-8',errors='replace') if log_path.exists() else ''
        if any(e in sample for e in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')):stopped='Native error'
        if time.monotonic()>deadline:stopped='Timeout'
        if stopped:proc.terminate();break
        time.sleep(.25)
    code=proc.wait(timeout=10)
text=(out/'engine.log').read_text(encoding='utf-8',errors='replace')
errors=[x for x in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR','CA454 EDGE FAIL','result=FAIL') if x in text]
if stopped:errors.append(stopped)
report={'issue':454,'command':command,'exit_code':code,'errors':errors,'checks':[s for s in text.splitlines() if s.startswith('CA454 EDGE')],'sha256':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in packages},'engine_sha256':hashlib.sha256(engine.read_bytes()).hexdigest(),'loaded_save_sha256':hashlib.sha256((out/'input.zds').read_bytes()).hexdigest() if args.load else None,'scope':'Direct native visibility edges and original/candidate save continuation; frozen fixture probes, not ordinary combat.'}
(out/'RESULTS.json').write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps({'exit_code':code,'errors':errors,'results':report['checks'][-2:]}))
assert code==0 and not errors and 'CA454 EDGE_RESULT' in text
