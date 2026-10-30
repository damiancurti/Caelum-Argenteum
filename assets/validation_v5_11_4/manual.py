"""One numbered terminal for the separate V5.11 author scenarios."""
from pathlib import Path
import argparse,datetime,subprocess,os
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue430'
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
RUNTIME=OUT/'final/caelum_argenteum_dev.pk3'
CASES={
 '1':('Mansion: companeros','MAP01','manual.pk3','netevent ca511_ready; netevent ca511_visit 0; netevent ca511_kit',
      'F1-F4: visitar residentes. Usar: conversar. F5: panel del residente.\nEn el panel: 1 incorporar, 2 seguir, 3 esperar, 4 despedir; F formacion.\nI cambia inventario; Enter regalar/solicitar; L prestar; E equipar; Tab cierra.\nF7 imprime grupo/confianza en consola. F8 cambia formacion. F9 guarda; F10 carga.\nCierra el panel con Tab antes de pulsar F1-F10. Los prestamos vuelven sin tirada.'),
 '2':('Alcantarillas: prisioneros','MAP02','manual.pk3','netevent ca511_ready; netevent ca511_visit 0',
      'F1-F4: visitar prisioneros. F5: panel; cautivo no puede incorporarse.\nF6 libera al prisionero seleccionado para la prueba; vuelve a F5 y pulsa 1.\nLa escolta hasta Barracas sigue vigente aunque lo despidas. Tab cierra el panel.'),
 '3':('Formaciones: paso estrecho','CA429B','manual.pk3','netevent ca511_ready',
      'F1 inicia la marcha una sola vez. Cinco guardias atraviesan el paso.\nDeben pasar en columna y recuperar la formacion sin superponer cuerpos.\nPuedes caminar para observarlos; la comprobacion termina a los 40 segundos activos.'),
 '4':('Equipo y confianza: comprobaciones','MAP01','full-checks.pk3','netevent ca430_seed; wait 10; netevent ca430_clothing; netevent ca430_jewelry; netevent ca430_gifts; wait 10; toggleconsole',
      'Se ejecutan las comprobaciones de equipo, joyas, prestamos y regalos.\nEn la consola deben aparecer PASS y ningun FAIL. No duplica confianza al dividir pilas.'),
 '5':('Muerte y resurreccion pagada','MAP01','full-checks.pk3','netevent ca430_seed; wait 10; netevent ca430_abilityrevival; wait 180; toggleconsole',
      'Se mata al companero de prueba y se lanza la habilidad existente de Peregrino.\nDebe revivir conservando sus objetos, pagando Anima y respetando el cooldown.\nLa consola muestra las comprobaciones; el protagonista tiene proteccion de prueba.'),
 '6':('Ciudad: comportamiento y rendimiento','MAP03','manual.pk3','netevent ca511_ready; vid_fps 1',
      'Camina por la ciudad y mira al suelo/calles. Comprueba respuesta y estabilidad.\nF7 imprime el grupo; no se inicia un asedio artificial. La gran batalla sigue siendo lenta.'),
 '8':('Mansion: rendimiento sin companeros','MAP01','manual.pk3','netevent ca511_ready; vid_fps 1',
      'Camina sin reclutar. Comprueba la fluidez y que los residentes conservan sus dialogos.'),
 '9':('Alcantarillas: rendimiento','MAP02','manual.pk3','netevent ca511_ready; vid_fps 1',
      'Camina por las alcantarillas. Se conserva la percepcion y el combate individuales.')}

def launch(choice,qa=False):
 title,mapname,fixture,commands,helptext=CASES[choice]
 if subprocess.check_output(['powershell','-NoProfile','-Command',"Get-Process | Where-Object ProcessName -eq 'gzdoom' | Select-Object -ExpandProperty Id"],text=True).strip():
  print('Cierra primero la instancia de GZDoom que ya esta abierta.');return
 stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
 folder=OUT/'author'/stamp;folder.mkdir(parents=True,exist_ok=True)
 ini=folder/'test.ini';cfg=folder/'test.cfg';log=folder/'engine.log'
 ini.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=true\nvid_maxfps=60\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_fullscreen=false\nuse_mouse=true\nlanguage=es\n',encoding='utf-8')
 bindings=['bind e +use','bind w +forward','bind s +back','bind a +moveleft','bind d +moveright','bind grave toggleconsole']
 if fixture=='manual.pk3':
  bindings += [f'bind F{i+1} "netevent ca511_visit {i}"' for i in range(4)]
  bindings += ['bind F5 "netevent ca511_panel"', 'bind F6 "netevent ca511_release"' if choice=='2' else 'bind F6 "netevent ca511_kit"',
   'bind F7 "netevent ca511_status"','bind F8 "netevent ca511_shape"','bind F9 "save ca511-manual"','bind F10 "load ca511-manual.zds"']
 if choice=='3':bindings += ['bind F1 "netevent ca511_march"']
 text='\n'.join(bindings)+'\nwait 80; '+commands+'; wait 10; save ca511-manual'
 if qa:text+='; wait 30; load ca511-manual.zds; wait 10; bind F1; bind F5; bind F10; netevent ca511_panel; wait 10; screenshot manual-es.png; wait 10; quit\n'
 cfg.write_text(text,encoding='utf-8')
 print('\n'+title+'\n'+helptext+'\n\nCierra el juego para regresar a este menu.\n',flush=True)
 command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(RUNTIME),str(OUT/fixture),'-config',str(ini),'-savedir',str(folder),'-window','-width','1280','-height','720','-rngseed','430','+logfile',str(log),'+map',mapname,'+exec',str(cfg)]
 process=subprocess.Popen(command,cwd=folder)
 (OUT/'author-current.txt').write_text(str(folder)+'\n'+str(process.pid)+'\n',encoding='utf-8')
 process.wait()
 if qa:
  output=log.read_text(encoding='utf-8',errors='replace')
  problems=[line for line in output.splitlines() if any(token in line for token in (' FAIL','Script error','VM execution aborted','Execution could not continue','Unknown command','Cannot find savegame'))]
  if problems:raise SystemExit('\n'.join(problems))
  if 'Partida guardada.' not in output and 'Game saved.' not in output:raise SystemExit('Native launcher did not reach its save checkpoint.')
 print('Registro:',log,flush=True)

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--scenario',choices=CASES);parser.add_argument('--qa',action='store_true');args=parser.parse_args()
 if args.scenario:launch(args.scenario,args.qa);return
 while True:
  print('\nCAELUM ARGENTEUM - PRUEBAS V5.11\n')
  for key,(title,*_) in CASES.items():print(key+' - '+title)
  print('7 - Resultados de rendimiento #431/#432 y evaluacion #433\n0 - Salir')
  try:choice=input('Elige un numero y pulsa Enter: ').strip()
  except (EOFError,KeyboardInterrupt):return
  if choice=='0':return
  if choice=='7':
   print('\n#431: perfilado y PresentMon archivados; la batalla grande sigue siendo lenta.\n#432: caches exactas verificadas; no prometen 60 FPS en asedio.\n#433: candidato de busqueda distante evaluado y NO incorporado: no demostro mejora.\nNo se elimina combate, colision ni actores fuera de pantalla.\n')
  elif choice in CASES:launch(choice)

if __name__=='__main__':main()
