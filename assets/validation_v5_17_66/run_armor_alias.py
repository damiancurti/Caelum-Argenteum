"""Check the medium-armor alias and native save/pickup continuity for #775."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__)
 for n in ('baseline','runtime','output'):p.add_argument('--'+n,type=Path,required=True)
 a=p.parse_args();baseline=a.baseline.resolve(strict=True);runtime=a.runtime.resolve(strict=True);out=a.output.resolve();out.relative_to(ROOT/'build')
 assert b'"gzdoom.exe"' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower(),'Another engine is running'
 out.mkdir(parents=True,exist_ok=False);fixture=out/'fixture.pk3';source=Path(__file__).with_name('armor_alias.zs').read_bytes();(out/'fixture.zs').write_bytes(source)
 with zipfile.ZipFile(fixture,'w') as z:
  for n,b in {'ZSCRIPT':b'version "4.14.2"\n'+source,'maps/CA455V.wad':wad(),'MAPINFO':b'gameinfo { AddEventHandlers="CA775Events" }\nmap CA455V "Medium armor alias" { sky1="CABASKY",0 nointermission }'}.items():z.writestr(zipfile.ZipInfo(n,(2026,11,15,0,0,0)),b)
 (out/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n[LastRun]\nVersion=225\n')
 common='screenblocks 12; crosshair 0; con_notifytime 0; wait 140; '
 fresh='netevent ca775_prepare; wait 35; netevent ca775_verify {candidate}; netevent ca775_view; wait 5; screenshot {label}.png; '
 load='wait 35; netevent ca775_verify {candidate}; netevent ca775_view; wait 5; screenshot {label}.png; netevent ca775_repick; wait 35; netevent ca775_verify {candidate}; '
 runs=[('baseline',baseline,False,['+map','CA455V'],fresh+'save armor-old; wait 20; quit',157),('old-save-load',runtime,True,['-loadgame','armor-old.zds'],load+'wait 5; quit',293),('candidate-fresh',runtime,True,['+map','CA455V'],fresh+'save armor-new; wait 20; quit',157),('candidate-reload',runtime,True,['-loadgame','armor-new.zds'],load+'wait 5; quit',293),('rollback-load',baseline,False,['-loadgame','armor-new.zds'],load+'wait 5; quit',293)]
 report=dict(issue=775,scope=__doc__,baseline_sha256=digest(baseline),runtime_sha256=digest(runtime),engine_sha256=digest(ENGINE),fixture_sha256=digest(fixture),runs=[])
 for label,package,candidate,entry,commands,expected in runs:
  cfg=out/(label+'.cfg');cfg.write_text(common+commands.format(candidate=int(candidate),label=label)+'\n');logpath=out/(label+'.log')
  command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(package),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(logpath),*entry,'+exec',str(cfg)]
  startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
  with (out/(label+'-process.log')).open('wb') as stream:
   process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup);deadline=time.monotonic()+120
   while process.poll() is None and time.monotonic()<deadline:
    text=logpath.read_text(errors='replace') if logpath.exists() else ''
    if any(t in text for t in ('Script error','Execution could not continue','VM execution aborted')):break
    time.sleep(.2)
   if process.poll() is None:process.terminate()
   code=process.wait(timeout=10)
  text=logpath.read_text(errors='replace') if logpath.exists() else ''
  errors=[v for v in text.splitlines() if any(t in v for t in ('Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model','CA775 FAIL'))]
  count=len(re.findall(r'^CA775 PASS ',text,re.M));completions=re.findall(r'CA775 COMPLETE failures=(\d+)',text)
  result=dict(phase=label,exit_code=code,errors=errors,assertions=count,expected_assertions=expected,completions=completions,passed=code==0 and not errors and count==expected and bool(completions) and set(completions)=={'0'})
  report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(result),flush=True)
  if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
