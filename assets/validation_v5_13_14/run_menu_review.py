"""Capture the production main menu and both submenus through native commands."""
from pathlib import Path
import argparse,datetime,sys,subprocess,json
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_standalone import isolated_config
from caelum_sessions import digest
p=argparse.ArgumentParser();p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True);p.add_argument('--iwad',type=Path,required=True);a=p.parse_args()
for field in ('runtime','engine','iwad'):setattr(a,field,getattr(a,field).resolve(strict=True))
out=ROOT/'build/issue597'/datetime.datetime.now().strftime('menus-%Y%m%d-%H%M%S');out.mkdir(parents=True)
(out/'game.ini').write_bytes(isolated_config()+b'language=es\nvid_maxfps=60\nvid_vsync=false\n')
names=['MainMenu','CaelumSinglePlayerMenu','CaelumMultiplayerMenu','CaelumStandaloneMenu']
cfg='wait 70; '+''.join(f'openmenu {name}; wait 12; screenshot "{(out/(name+".png")).as_posix()}"; wait 8; ' for name in names)+'quit\n'
(out/'review.cfg').write_text(cfg,encoding='utf-8')
cmd=[str(a.engine),'-noautoload','-iwad',str(a.iwad),'-file',str(a.runtime),'-config',str(out/'game.ini'),'-window','-width','1024','-height','768','+logfile',str(out/'engine.log'),'+ca_standalone_bridge','1','+exec',str(out/'review.cfg')]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
with (out/'process.log').open('wb') as f:run=subprocess.run(cmd,cwd=out,stdout=f,stderr=f,startupinfo=startup,timeout=60)
log=(out/'engine.log').read_text(errors='replace');errors=[s for s in log.splitlines() if any(x in s for x in ('Script error','Unknown','Execution could not continue'))]
result=dict(directory=str(out),runtime_sha256=digest(a.runtime),exit=run.returncode,errors=errors,images=[str(out/(n+'.png')) for n in names],passed=run.returncode==0 and not errors and all((out/(n+'.png')).is_file() for n in names))
Path(__file__).with_name('results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));raise SystemExit(not result['passed'])
