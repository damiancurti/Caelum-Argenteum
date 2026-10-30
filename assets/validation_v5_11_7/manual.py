"""One numbered terminal for the separate V5.11 author scenarios."""
from pathlib import Path
import argparse,datetime,subprocess,os
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue581/handoff'
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
RUNTIME=ROOT/'build/issue581/final/caelum_argenteum_dev.pk3'
CASES={
 '1':('Mansion: companeros','MAP01','manual.pk3','netevent ca511_ready; netevent ca511_visit 0; netevent ca511_kit',
      'F1-F4: visitar residentes. Usar: conversar. F5: panel del residente.\nEn el panel: 1 incorporar, 2 seguir, 3 esperar, 4 despedir; F formacion.\nI cambia inventario; Enter regalar/solicitar; L prestar; E equipar; Tab cierra.\nF7 imprime grupo/confianza en consola. F8 cambia formacion. F9 guarda; F10 carga.\nCierra el panel con Tab antes de pulsar F1-F10. Los prestamos vuelven sin tirada.'),
 '2':('Alcantarillas: prisioneros','MAP02','manual.pk3','netevent ca511_ready; netevent ca511_visit 0',
      'F1-F4: visitar prisioneros. F5: panel; cautivo no puede incorporarse.\nF6 libera al prisionero seleccionado para la prueba; vuelve a F5 y pulsa 1.\nLa escolta hasta Barracas sigue vigente aunque lo despidas. Tab cierra el panel.'),
 '3':('Formaciones: paso estrecho','CA429B','manual.pk3','netevent ca511_ready',
      'F1 inicia la marcha una sola vez. Cinco guardias atraviesan el paso.\nDeben pasar en columna y recuperar la formacion sin superponer cuerpos.\nPuedes caminar para observarlos; la comprobacion termina a los 40 segundos activos.'),
 '4':('Mision de la casa: agente y guardia','MAP03','manual.pk3','netevent ca511_ready; netevent ca581_rental',
      'F1 te lleva al agente; E conversa e inicia la investigacion.\nCierra el dialogo. F2 te lleva a un guardia; E conversa.\nCierra y vuelve con F1 al agente: ahora debe permitir verificar el registro.\nDebe devolverte la propiedad una sola vez. F9 guarda y F10 carga.'),
 '5':('Casa centrica: estaciones, barril y catre','MAP03','manual.pk3','netevent ca511_ready; netevent ca581_access; changemap CAH069; wait 90; netevent ca581_room',
      'F1: taller dentro de la casa. F2: catre del dormitorio. E: usar.\nF3: antigua ubicacion exterior, que debe estar vacia. F4: volver a la casa.\nComprueba acceso y colisiones; F9 guarda y F10 carga.\nSolo esta partida de prueba concede la propiedad para comprobar los muebles.'),
 '6':('Ratas: inmunidad al dano de contaminacion','MAP03','rat.pk3','netevent ca582_seed; wait 5; netevent ca582_check; save rat-check; wait 5; load rat-check.zds; wait 10; netevent ca582_reload; toggleconsole',
      'La consola debe mostrar siete PASS y ningun FAIL.\nLa rata conserva contaminacion, pero no pierde vida por enfermedad.\nSigue recibiendo dano normal; Mandinga conserva su susceptibilidad.')}


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
 if choice=='4':bindings += ['bind F1 "netevent ca581_rental"','bind F2 "netevent ca581_guard"']
 if choice=='5':bindings += ['bind F1 "netevent ca581_room"','bind F2 "netevent ca581_cot"','bind F3 "changemap MAP03; wait 90; netevent ca581_outside"','bind F4 "changemap CAH069; wait 90; netevent ca581_room"']
 if choice=='3':bindings += ['bind F1 "netevent ca511_march"']
 text='\n'.join(bindings)+'\nwait 80; '+commands+'; wait 10; save ca511-manual'
 if qa:text+='; wait 30; load ca511-manual.zds; wait 10; bind F1; bind F5; bind F10; netevent ca511_panel; wait 10; screenshot manual-es.png; wait 10; quit\n'
 cfg.write_text(text,encoding='utf-8')
 print('\n'+title+'\n'+helptext+'\n\nCierra el juego para regresar a este menu.\n',flush=True)
 command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(RUNTIME),str(OUT/fixture),'-config',str(ini),'-savedir',str(folder),'-window','-width','1280','-height','720','-rngseed','430','+logfile',str(log),'+map',mapname,'+exec',str(cfg)]
 startup=None
 if qa:
  startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
 process=subprocess.Popen(command,cwd=folder,startupinfo=startup)
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
  print('\nCAELUM ARGENTEUM - CORRECCIONES V5.11 - 5.11.7\n')
  for key,(title,*_) in CASES.items():print(key+' - '+title)
  print('7 - Resultados de rendimiento #431/#432 y evaluacion #433\n0 - Salir')
  try:choice=input('Elige un numero y pulsa Enter: ').strip()
  except (EOFError,KeyboardInterrupt):return
  if choice=='0':return
  if choice=='7':
   print('\n#431: perfilado y PresentMon archivados; la batalla grande sigue siendo lenta.\n#432: caches exactas verificadas; no prometen 60 FPS en asedio.\n#433: candidato de busqueda distante evaluado y NO incorporado: no demostro mejora.\nNo se elimina combate, colision ni actores fuera de pantalla.\n')
  elif choice in CASES:launch(choice)

if __name__=='__main__':main()
