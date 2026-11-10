"""Open separate disposable V5.15 author scenes; acceptance remains manual."""
from pathlib import Path
import argparse,datetime,importlib.util,json,re,subprocess,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('battle_fixture',ROOT/'assets/validation_v5_15_0/run_native.py')
fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
SCENES={'director':0,'command':1,'machines':2,'reports':3,'outcomes':4,'routes':5,'city':6}
HELP={
 'director':'#447: F5 cae un defensor; F6 retirada confirmada de Zupay; F7 destruye una maquina; F8 solicita una tanda real disponible. Dos defensores en esta escena aislada; no representa el ejercito de produccion.',
 'command':'#448: agachate y usa al guardia. F5 alterna pertenencia; F6 cargo reconocido; F7 reputacion49/50; F8 cae el primer guardia. Retirada de laboratorio al puesto original; el cuartel real se revisa en Ciudad.',
 'machines':'#449: usa una pieza del canon para reparar, sabotear, capturar u operar. F5 prepara10% de dano; F6 ubica junto al banco; F7 completa trabajo activo SOLO como ayuda de prueba; F8 vuelve al canon. Recetas aprendidas, estaciones y materiales de prueba disponibles. Sabotaje/captura duran30 segundos si no usas F7.',
 'reports':'#450: cuenta de prisionero oida y una hora antes del asedio. F5 abre el dialogo real del guardia; F6 inicia el asedio; F7 prepara captura intacta para Unitarios; F8 vuelve al guardia. Informa por el dialogo y compara reputacion/reserva. Rutas fisicas: opcion6.',
 'outcomes':'#451: F5 caen ambos defensores; F6 neutraliza las doce maquinas y confirma retirada; F7 adelanta hasta la reapertura; F8 intenta comerciar; F12 prepara la muerte del segundo comerciante. Repite F6/F7 y revisa reputacion y Diario. Para victoria sin derrota, F6 antes de F5. F9 sale al hub; F10 regresa.',
 'routes':'#450: geometria real, sin ejercitos. F5 coloca al pie de la escalera oeste; F6 en el exterior oeste. Camina y revisa solo los puntos descubiertos; no hay movimiento automatico.',
 'city':'#447/#448: ciudad real y reglas normales. F5 coloca en escalera oeste; F6 en exterior oeste; F7 fija la fecha aprobada del asedio. Rendimiento de asedio severamente limitado en el equipo registrado. No activa ningun caso retirado de6000 simultaneos.'}

def launch(runtime,scene,players,language,hidden=False,recovery=None,smoke=False):
 out=ROOT/'build/v515/author'/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
 package=out/'scene.pk3';fixture.fixture(package,players,travel=True)
 with zipfile.ZipFile(package) as z:members={n:z.read(n) for n in z.namelist()}
 members['MAPINFO']=members['MAPINFO'].replace(b'CA447Checks',b'CA515Author').replace(b'T447',b'T451')
 members['maps/T451.wad']=members.pop('maps/T447.wad')
 source=(HERE/('city_author.zs' if SCENES[scene]>=5 else 'author_probe.zs')).read_text(encoding='utf-8')
 source=source.replace('const SCENE=0;',f'const SCENE={SCENES[scene]};')
 if SCENES[scene]>=5:
  with zipfile.ZipFile(runtime) as z:members['maps/MAP03.wad']=z.read(next(n for n in z.namelist() if n.lower()=='maps/map03.wad'))
 if scene=='city':source=source.replace('class CA515QuietPort : CaelumPortSiege replaces CaelumPortSiege { override void Tick(){} }','')
 members['checks.zs']=source.encode('utf-8')
 with zipfile.ZipFile(package,'w',compression=zipfile.ZIP_STORED) as z:
  for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,10,0,0,0)),data)
 startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0 if hidden else 1
 with zipfile.ZipFile(runtime) as z:controls=re.search(r'^alias ca_controls_defaults "([^"]+)"',z.read('KEYCONF').decode('utf-8'),re.M).group(1)
 processes=[];commands=[]
 for i in range(players):
  peer=out/f'peer{i}';peer.mkdir();config=peer/'isolated.ini';cfg=peer/'controls.cfg'
  config.write_text(f'[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage={language}\n[Player]\nname=Review{i+1}\n',encoding='utf-8')
  bindings='\n'.join(f'bind F{key} "netevent ca515_{event}"' for key,event in [(5,'a'),(6,'b'),(7,'c'),(8,'d'),(9,'hub'),(10,'return'),(12,'e')])
  actions={'director':'a;a;b;c;d','command':'a;a;b;b;c;c;d','machines':'a;b;d','reports':'c;a','outcomes':'a;b;c;d;e','routes':'a;b','city':''}
  exercise=''.join('netevent ca515_'+event+'; wait 5; ' for event in actions[scene].split(';') if event) if smoke else ''
  if smoke and scene=='outcomes':exercise+='netevent ca515_hub; wait 70; netevent ca515_return; wait 70; '
  if smoke and SCENES[scene]<5:exercise+='netevent ca515_probe; wait 5; '
  host='wait 160; '+exercise+'save author; ' if not recovery else 'wait 100; netevent ca_session_recover; wait 5; '+exercise+'save author; '
  cfg.write_text(controls+'\n'+bindings+'\nbind F11 "save author"\n'+(host if i==0 else '')+(f'wait {400+i*35}; quit' if smoke else '')+'\n',encoding='utf-8')
  entry=['+map','MAP03']
  if recovery:(peer/'restore.zds').write_bytes(recovery.read_bytes());entry=['-loadgame','restore.zds']
  net=[] if players==1 else ['-host',str(players),'-port','32515','-netmode','0'] if i==0 else ['-join','127.0.0.1:32515','-port',str(32515+i)]
  cmd=[str(fixture.ENGINE),'-noautoload','-iwad',str(fixture.IWAD),'-file',str(runtime.resolve()),str(package),'-config',str(config),'-savedir',str(peer),'-window','-width','960','-height','720',*net,'+logfile',str(peer/'engine.log'),*entry,'+exec',str(cfg)]
  with (peer/'process.log').open('wb') as stream:processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream))
  commands.append(cmd);time.sleep(.3)
 (out/'session.json').write_text(json.dumps(dict(scene=scene,players=players,language=language,pids=[p.pid for p in processes],commands=commands),indent=2),encoding='utf-8')
 print(HELP[scene]);print(f'Scene: {out}',flush=True)
 return processes,out

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,default=ROOT/'build/v515/issue451-release.pk3');p.add_argument('--scene',choices=SCENES);p.add_argument('--players',type=int,choices=(1,2),default=2);p.add_argument('--language',choices=('es','en'),default='es');p.add_argument('--hidden',action='store_true');p.add_argument('--detach',action='store_true');p.add_argument('--smoke',action='store_true');p.add_argument('--recover',type=Path);a=p.parse_args()
 if a.scene:
  processes,out=launch(a.runtime,a.scene,a.players,a.language,a.hidden,recovery=a.recover,smoke=a.smoke)
  if not a.detach:
   for process in processes:process.wait()
  if a.smoke:
   logs=[(out/f'peer{i}/engine.log').read_text(errors='replace') for i in range(a.players)]
   okay=all(proc.returncode==0 and ('CA515 AUTHOR READY' in log or a.recover) and 'CA435SYNC OK' in log and (SCENES[a.scene]>=5 or 'CA515 AUTHOR CHECK PASS' in log) and not any(s in log for s in ('VM execution aborted','Script error','CA435SYNC FAIL','CA515 AUTHOR CHECK FAIL')) for proc,log in zip(processes,logs))
   (out/'smoke.json').write_text(json.dumps(dict(passed=okay,scene=a.scene),indent=2));print('Smoke:',okay)
   if not okay:raise SystemExit(1)
  return
 active=[];last=None
 while True:
  print('\nV5.15 - Pruebas aisladas por issue. No modifican tus partidas habituales.\n1 Director #447\n2 Mando #448\n3 Maquinas #449\n4 Informes #450\n5 Consecuencias #451\n6 Rutas reales #450\n7 Ciudad real #447/#448\n8 Cambiar ES/EN\n9 Cerrar solo las escenas de esta terminal\n10 Recuperar guardado comun de la ultima escena\n0 Salir\nF11 guarda. F9/F10 salen/regresan en los laboratorios. Lee pending_test.txt. Cambia de ventana para controlar cada jugador.')
  choice=input('Opcion: ').strip()
  if choice=='8':a.language='en' if a.language=='es' else 'es';print('Idioma:',a.language);continue
  if choice in ('9','0'):
   for proc in active:
    if proc.poll() is None:proc.terminate();proc.wait(timeout=10)
   active=[]
   if choice=='0':return
   continue
  options={str(i+1):name for i,name in enumerate(SCENES)}
  if choice not in options and choice!='10':continue
  if any(proc.poll() is None for proc in active):print('Cierra la escena anterior con9 antes de abrir otra.');continue
  if choice=='10':
   checkpoint=None if last is None else last[1]/'peer0/author.zds'
   if checkpoint is None or not checkpoint.exists():print('No hay guardado comun. Usa F11 en el anfitrion.');continue
   scene=last[0];active,out=launch(a.runtime,scene,a.players,a.language,recovery=checkpoint)
  else:scene=options[choice];active,out=launch(a.runtime,scene,a.players,a.language)
  last=(scene,out)

if __name__=='__main__':main()
