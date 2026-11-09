"""Open isolated V5.14 author scenes; all acceptance remains manual (#443-446)."""
from pathlib import Path
import argparse,datetime,importlib.util,json,re,subprocess,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('card_fixture',ROOT/'assets/validation_v5_12_5/run_card_probe.py')
fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
SCENES={'magic':0,'teams':1,'wagers':2,'ranked':3,'tournament':4}

def launch(runtime,scene,players,language,hidden=False,recovery=None):
 if scene=='tournament' and players not in (4,8):raise ValueError('Tournaments require four or eight peers.')
 out=ROOT/'build/v514/author'/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
 package=out/'scene.pk3';fixture.fixture(package,players)
 with zipfile.ZipFile(package) as archive:members={n:archive.read(n) for n in archive.namelist()}
 source=(Path(__file__).parent/'author_probe.zs').read_bytes()
 members['probe.zs']=source.replace(b'const PEERS=2;',f'const PEERS={players};'.encode()).replace(b'const SCENE=0;',f'const SCENE={SCENES[scene]};'.encode())
 with zipfile.ZipFile(package,'w',compression=zipfile.ZIP_STORED) as archive:
  for name,data in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,9,0,0,0)),data)
 startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0 if hidden else 1
 with zipfile.ZipFile(runtime) as archive:
  controls=re.search(r'^alias ca_controls_defaults "([^"]+)"',archive.read('KEYCONF').decode('utf-8'),re.M).group(1)
 processes=[];commands=[]
 for i in range(players):
  peer=out/f'peer{i}';peer.mkdir();config=peer/'isolated.ini'
  config.write_text(f'[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage={language}\n[Player]\nname=Review{i+1}\n',encoding='utf-8')
  cfg=peer/'controls.cfg';cfg.write_text(controls+'\n'+('wait 100; netevent ca_session_recover\n' if recovery and i==0 else ''),encoding='utf-8')
  entry=['+map','MAP03']
  if recovery:
   (peer/'restore.zds').write_bytes(recovery.read_bytes());entry=['-loadgame','restore.zds']
  net=['-host',str(players),'-port','32514','-netmode','0'] if i==0 else ['-join','127.0.0.1:32514','-port',str(32514+i)]
  cmd=[str(fixture.ENGINE),'-noautoload','-iwad',str(fixture.IWAD),'-file',str(runtime.resolve()),str(package),'-config',str(config),'-savedir',str(peer),'-window','-width','960','-height','720',*net,'+name',f'Review{i+1}','+logfile',str(peer/'engine.log'),*entry,'+exec',str(cfg)]
  with (peer/'process.log').open('wb') as stream:processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream))
  commands.append(cmd);time.sleep(.3)
 (out/'session.json').write_text(json.dumps(dict(scene=scene,players=players,language=language,pids=[p.pid for p in processes],commands=commands),indent=2))
 print(f'Scene: {out}',flush=True)
 return processes,out

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,default=ROOT/'build/v514/issue446-final.pk3');p.add_argument('--scene',choices=SCENES);p.add_argument('--players',type=int,choices=(2,4,6,8),default=2);p.add_argument('--language',choices=('es','en'),default='es');p.add_argument('--hidden',action='store_true');p.add_argument('--detach',action='store_true');p.add_argument('--recover',type=Path);a=p.parse_args()
 if a.scene:
  processes,_=launch(a.runtime,a.scene,a.players,a.language,a.hidden,a.recover)
  if not a.detach:
   for process in processes:process.wait()
  return
 active=[];last=None
 while True:
  print('\nV5.14 - Pruebas manuales aisladas. Tus partidas habituales no se modifican.\n1 Magia #443 (2 jugadores)\n2 Equipos #445 (8 jugadores)\n3 Apuestas #444 (4 jugadores)\n4 Clasificatoria #446 (2 jugadores)\n5 Torneo #446 (4 jugadores)\n6 Torneo #446 (8 jugadores)\n7 Cambiar idioma ES/EN\n8 Cerrar solo las escenas abiertas por esta terminal\n9 Recuperar checkpoint automatico comun de la ultima escena\n0 Salir\nLee pending_test.txt para los resultados esperados. Cambia entre ventanas para controlar cada jugador.')
  choice=input('Opcion: ').strip()
  if choice=='7':a.language='en' if a.language=='es' else 'es';print('Idioma:',a.language);continue
  if choice in ('8','0'):
   for proc in active:
    if proc.poll() is None:proc.terminate();proc.wait(timeout=10)
   active=[]
   if choice=='0':return
   continue
  options={'1':('magic',2),'2':('teams',8),'3':('wagers',4),'4':('ranked',2),'5':('tournament',4),'6':('tournament',8)}
  if choice not in options and choice!='9':continue
  if any(proc.poll() is None for proc in active):print('Cierra la escena anterior con la opcion 8 antes de abrir otra.');continue
  if choice=='9':
   saves=[] if last is None else list((last[2]/'peer0').glob('save*.zds'))
   if not saves:print('Todavia no hay un checkpoint del anfitrion. La escena lo guarda automaticamente cada 10 segundos cuando cambia.');continue
   checkpoint=max(saves,key=lambda path:(path.stat().st_mtime_ns,path.name))
   scene,players,previous=last;active,out=launch(a.runtime,scene,players,a.language,recovery=checkpoint)
  else:scene,players=options[choice];active,out=launch(a.runtime,scene,players,a.language)
  last=(scene,players,out)

if __name__=='__main__':main()
