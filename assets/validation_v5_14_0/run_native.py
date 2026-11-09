"""Run focused #443 checks with real native peers and untouched sync diagnostics."""
from pathlib import Path
import argparse, datetime, hashlib, importlib.util, json, subprocess, sys, time, zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_12_7'))
import native_sync
spec=importlib.util.spec_from_file_location('legacy_fixture',ROOT/'assets/validation_v5_12_5/run_card_probe.py')
fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--overlay',action='store_true')
 p.add_argument('--suite',choices=('rules','integration'),default='rules');p.add_argument('--players',type=int,default=2);p.add_argument('--port',type=int,default=31443)
 p.add_argument('--load-directory',type=Path);p.add_argument('--hold',action='store_true');a=p.parse_args()
 out=ROOT/'build/issue443'/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
 package=out/'checks.pk3';fixture.fixture(package,a.players)
 with zipfile.ZipFile(package) as archive:members={n:archive.read(n) for n in archive.namelist()}
 members['probe.zs']=(Path(__file__).parent/(a.suite+'_probe.zs')).read_bytes()
 members=native_sync.instrument(members)
 if a.overlay:
  names=subprocess.check_output(['git','-c','core.safecrlf=false','diff','--name-only','--','src'],cwd=ROOT,text=True).splitlines()
  names+=subprocess.check_output(['git','ls-files','--others','--exclude-standard','src'],cwd=ROOT,text=True).splitlines()
  for name in names:
   if name!='src/ZSCRIPT' and (ROOT/name).is_file():members[Path(name).relative_to('src').as_posix()]=(ROOT/name).read_bytes()
  rules='caelum/trucazo/CaelumTrucazoRules.zs'
  members[rules]=(ROOT/'src'/rules).read_bytes()+b'\n#include "caelum/data/CaelumTrucazoData.zs"\n#include "caelum/trucazo/CaelumTrucazoGame.zs"\n#include "caelum/trucazo/CaelumTrucazoGameMenu.zs"\n'
 with zipfile.ZipFile(package,'w',compression=zipfile.ZIP_STORED) as archive:
  for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,8,0,0,0)),data)
 processes=[];streams=[];commands=[];startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
 try:
  for i in range(a.players):
   peer=out/f'peer{i}';peer.mkdir();config=peer/'isolated.ini';cfg=peer/'commands.cfg'
   config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n',encoding='utf-8')
   prefix='wait 100; netevent ca_session_recover; wait 5; netevent ca443_restored; ' if a.load_directory and i==0 else ''
   cfg.write_text(prefix+f'wait {4200 if a.hold else 700+(a.players-i)*35}; quit\n')
   entry=['+map','MAP03']
   if a.load_directory:
    source=a.load_directory/'peer0/save00.zds';(peer/'restore.zds').write_bytes(source.read_bytes());entry=['-loadgame','restore.zds']
   net=['-host',str(a.players),'-port',str(a.port),'-netmode','0'] if i==0 else ['-join',f'127.0.0.1:{a.port}','-port',str(a.port+i)]
   cmd=[str(fixture.ENGINE),'-noautoload','-iwad',str(fixture.IWAD),'-file',str(a.runtime.resolve()),str(package),'-config',str(config),'-savedir',str(peer),'-window','-width','960','-height','720',*net,'+logfile',str(peer/'engine.log'),*entry,'+exec',str(cfg)]
   stream=(peer/'process.log').open('wb');streams.append(stream);commands.append(cmd);processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.3)
  print(str(out),flush=True);deadline=time.monotonic()+(160 if a.hold else 100)
  fatal=('Script error','Execution could not continue','VM execution aborted','compile errors','Unable to resolve','Attempt to redefine','Internal script compiler','Attempting to open menu of unknown type','DIED WITH FATAL ERROR')
  while any(p.poll() is None for p in processes) and time.monotonic()<deadline:
   if any(any(token in log.read_text(errors='replace') for token in fatal) for log in out.glob('peer*/engine.log')):break
   time.sleep(.2)
 finally:
  for process in processes:
   if process.poll() is None:process.terminate();process.wait(timeout=10)
  for stream in streams:stream.close()
 peers=[]
 for i,process in enumerate(processes):
  log=(out/f'peer{i}/engine.log').read_text(errors='replace');lines=log.splitlines()
  errors=[line for line in lines if any(token in line for token in (' FAIL',*fatal))]
  checks=[line for line in lines if line.startswith('CA443 ')]
  okay=process.returncode==0 and not errors and 'CA443 RESULT PASS' in log and native_sync.clean(log)
  peers.append(dict(peer=i,exit=process.returncode,passed=okay,checks=checks,errors=errors,native_sync=native_sync.clean(log)))
 result=dict(issue=443,suite=a.suite,source_overlay=a.overlay,restored=bool(a.load_directory),runtime_sha256=digest(a.runtime),engine_sha256=digest(fixture.ENGINE),fixture_sha256=digest(package),commands=commands,peers=peers,passed=all(p['passed'] for p in peers))
 (out/'results.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
 print(json.dumps(dict(directory=str(out),passed=result['passed'],peers=[dict(peer=p['peer'],passed=p['passed'],checks=len(p['checks']),errors=p['errors']) for p in peers]),indent=2),flush=True)
 if not result['passed']:raise SystemExit(1)
if __name__=='__main__':main()
