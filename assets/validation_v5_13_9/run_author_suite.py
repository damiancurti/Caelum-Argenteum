"""Keep one numbered author terminal; every scene uses fresh, private native peers."""
from pathlib import Path
import argparse
import datetime
import json
import subprocess
import sys
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path[:0]=[str(ROOT),str(ROOT/'assets/validation_v5_12_7')]
import native_sync
from caelum_standalone import prepare,isolated_config
from caelum_sessions import digest

SCENES={
0:("#439 - Colección, selección y pasivos",2,0,0,
   "Tab > Tarot: seleccioná cartas y comprobá el orden indicado. Los Mayores\n"
   "requieren estar equipados; los bonos de Menores adquiridos se conservan.\n"
   "Ermitaño/Diablo amplían los espacios. No deben poder quitarse si sobran cartas."),
1:("#441 - Captura y esencia unificada",2,0,0,
   "Tenés 77 esencias y El Mundo equipado. Usá la esencia delante tuyo con E,\n"
   "aceptá capturarla y permanecé cerca hasta terminar. Cada jugador la captura\n"
   "por separado. Con las 78, activá la esencia unificada desde el inventario.\n"
   "Durante su efecto podés dañar al Palomo de prueba; antes no."),
2:("#442 - Despertar equipo",2,0,0,
   "B: inventario. Elegí un arma, armadura o escudo y pulsá A para asociar una\n"
   "esencia. Comprobá +25 % de daño/defensa, exclusividad y retirada reversible.\n"
   "Soltar o transferir la pieza debe quitar la asociación, conservando desgaste."),
3:("#440 - Poderes y anexo de la mansión",2,0,0,
   "Tab > Tarot permite elegir las cartas; T activa la secuencia por 1.000 Ánima.\n"
   "Probá el autómata 3D con El Mago, las rocas con Estrella+Sol, el obstáculo\n"
   "vivo con Muerte, el espíritu con Juicio/Justicia y las puertas especiales.\n"
   "F3 recorre anexo, pared falsa, paso maldito, habitación de Rueda y autómata.\n"
   "F4 crea un bandido inmóvil; pulsándolo otra vez lo activa o inmoviliza.\n"
   "Con él podés probar Emperatriz, Justicia, Emperador, Luna y los efectos\n"
   "de área. Los demás poderes se eligen desde la misma colección completa."),
4:("#598 - Deathmatch",2,0,0,
   "Combatí entre las dos ventanas: baja rival +1; suicidio -1. F2 causa una\n"
   "muerte de prueba. Reaparece tras 3 s con el residente y equipo iniciales.\n"
   "20 bajas o 10 min determinan el resultado; empate continúa hasta una ventaja."),
5:("#599 - Deathmatch por equipos",4,1,0,
   "Cuatro ventanas: los jugadores 1/3 son un equipo y 2/4 el otro. Comprobá\n"
   "colores, daño aliado real y penalización al matar a un compañero.\n"
   "El resultado y la puntuación del equipo deben coincidir en todas las ventanas."),
6:("#600 - Capturar el Arcano, ring",4,2,0,
   "Tocá el arcano rival y regresá a tu base con el propio presente.\n"
   "F3 te acerca a la base rival; F4, a la propia. F2 mata al portador de prueba:\n"
   "el arcano cae y puede recogerse; un defensor lo devuelve, o vuelve tras 30 s.\n"
   "Tres capturas ganan. Q muestra resultados y permite votar la revancha."),
7:("#600 - Capturar el Arcano, alcantarillas",4,2,1,
   "Mismas reglas de captura; recorré también los accesos y las dos bases del\n"
   "laberinto. F3/F4 acercan a la base rival/propia sin conceder puntos."),
8:("#601 - Búsqueda cooperativa",4,3,0,
   "Recogé esencias distintas: el contador es compartido, sin duplicarlas.\n"
   "Palomo patrulla, ve, recuerda y captura por contacto. F2 captura al personaje\n"
   "de esa ventana como preparación. En otra, F3 te lleva junto al cautivo:\n"
   "mantené E durante 3 s; soltar antes interrumpe el rescate. Conserva recursos.\n"
   "F4 recorre las trampas de prueba; deben rearmarse tras 60 s activos.\n"
   "El equipo pierde si todos quedan cautivos y gana con las 78 esencias.\n"
   "F6 prepara 77 recogidas y te deja ante la última para comprobar la victoria."),
9:("#440 - El Loco, viaje y muerte",2,0,0,
   "El Loco ya está equipado. F6 mata solo al personaje de esa ventana.\n"
   "T propone el viaje: deben aceptar ambos antes del cobro. El fallecido\n"
   "controla su espíritu en la mansión. Palomo permite regresar con El Loco\n"
   "equipado y unanimidad; volver no resucita. Repetí muriendo ambos con F6.")}


SCENES.update({
10:("#614 - Seis power ups en alcantarillas",2,0,1,
    "F2 prepara recursos y equipo dañados. F3 te deja ante un power up; cada\n"
    "pulsación prepara el tipo siguiente (los seis). Caminá hacia la esfera para\n"
    "recogerla. Comunes plateadas, raras doradas; emblemas distintos. F1 muestra\n"
    "el antes/después. Sin volver a pulsar F3, esperá 60 s para su reaparición\n"
    "aleatoria. El descanso afecta solo a ese jugador; conserva el daño normal."),
11:("#614 - Power ups en la búsqueda",4,3,0,
    "Mismas ayudas F2/F3 para los seis efectos. Palomo empieza inmóvil solo en\n"
    "esta preparación; F4 alterna su persecución. Hay 16 puntos en el laberinto.\n"
    "Un cautivo no puede recogerlos. F6 prepara la última esencia para terminar."),
12:("#616 - Arcanos en el laberinto de Palomo",4,3,0,
    "Los 22 Mayores encontrados se comparten como preparación. F3 recorre sus\n"
    "22 lugares y muestra el nombre. Tab > Tarot equipa; T activa. F2 repone\n"
    "recursos y limpia la recarga cuando no hay poderes activos. F4 alterna\n"
    "la persecución de Palomo (inicialmente inmóvil para revisar los lugares).\n"
    "F7 captura solo a ese personaje: en otra ventana, equipá El Loco y pulsá T;\n"
    "elegí al cautivo y comprobá que aparece cerca, sin atravesar paredes.\n"
    "En Estrella, agachate y usá la cama para transportarla; guardala en la Caja.\n"
    "Probá también Mago, Emperador, Rueda, Muerte, Templanza, Torre, Sol y Juicio."),
13:("#617 - Un jugador controla a Palomo",4,3,0,
    "La primera ventana es Palomo; las otras tres son buscadores. Palomo se\n"
    "mueve y captura por contacto, pero no usa armas, Tarot ni power ups.\n"
    "F3 acerca al jugador junto a un cautivo; F4 acerca a Palomo a un buscador\n"
    "libre (solo preparación). Buscadores: mantené E durante 3 s para rescatar.\n"
    "Palomo gana al capturar a los tres; ellos ganan reuniendo las 78 esencias.\n"
    "F6 prepara 77 para probar esa victoria; Q permite votar la revancha.")})

def menu_pair(args,home):
    """Open two independent production menu bridges so host/join can coexist."""
    folder=home/datetime.datetime.now().strftime('menu-pair-%Y%m%d-%H%M%S-%f');folder.mkdir()
    print('Dos menús independientes: en uno creá una partida para 2 jugadores.\n'
          'La terminal imprimirá su archivo session.json. En el otro elegí Unirse,\n'
          'dirección 127.0.0.1 y ese archivo de sesión. Elegí residentes distintos.\n'
          'Cerrá ambos menús al terminar para volver a la lista.',flush=True)
    processes=[]
    try:
        for slot in range(2):
            config=folder/f'menu{slot}.ini';config.write_bytes(isolated_config())
            command=[sys.executable,str(ROOT/'caelum_standalone.py'),'--engine',str(args.engine),
                     '--iwad',str(args.iwad),'--package',str(args.runtime),'--config',str(config),
                     '--root',str(folder/f'player{slot}')]
            processes.append(subprocess.Popen(command,cwd=ROOT))
        for process in processes:process.wait()
    finally:
        for process in processes:
            if process.poll() is None:process.terminate()


def fixture(path,scene):
    source=Path(__file__).with_name('author_scene.zs').read_bytes().replace(b'const SCENE=0;',f'const SCENE={scene};'.encode())
    members=native_sync.instrument({'ZSCRIPT':b'version "4.14.2"\n#include "author_scene.zs"\n',
        'MAPINFO':b'gameinfo { AddEventHandlers="CA513ManualScene" }\n','author_scene.zs':source})
    with zipfile.ZipFile(path,'x') as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

def launch(args,home,scene,previous=None):
    title,count,mode,venue,instructions=SCENES[scene]
    out=home/datetime.datetime.now().strftime(f'scene{scene}-%Y%m%d-%H%M%S-%f');out.mkdir()
    addon=Path(previous['addon']) if previous else out/'checks.pk3'
    if not previous:fixture(addon,scene)
    packages=[args.runtime,addon]
    compile_cmd=[str(args.engine),'-noautoload','-iwad',str(args.iwad),'-file',*map(str,packages),
                 '-norun','-nosound','-config',str(out/'compile.ini'),'-errorlog',str(out/'compile.log')]
    compile_result=subprocess.run(compile_cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
    (out/'compile-process.log').write_bytes(compile_result.stdout)
    if compile_result.returncode!=1337:
        errors=list(dict.fromkeys(line for line in compile_result.stdout.decode(errors='replace').splitlines()
                    if any(x in line.lower() for x in ('error','unknown','expect','line ','could not'))))
        raise RuntimeError('Native preflight failed: '+str(out)+'\n'+'\n'.join(errors[:40]))
    print('\n'+title+'\n'+instructions+'\n',flush=True)
    print('Ayudas F1-F4: solo preparan esta prueba, no son funciones de la campaña.\n'
          'F1: estado en consola (cerrala con la misma tecla). F5: guardar en anfitrión.\n'
          'Tarot: F2 repone recursos y elimina recarga cuando terminaron los activos.\n'
          'Alt+Tab cambia de jugador. Cerrá TODAS las ventanas para volver aquí.\n'
          'Logs y guardados: '+str(out),flush=True)
    processes=[];streams=[];peers=[];commands=[];error=None
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0 if args.smoke else 1
    try:
        for slot in range(count):
            peer=out/f'peer{slot}';peers.append(peer)
            selection=dict(role=min(slot,1),mode=mode,preset=slot%4,players=count,port=args.port,
                           venue=venue,host='127.0.0.1',session=str(out/'peer0/session.json'),palomo=1 if scene==13 else 0)
            cmd,_=prepare(selection,peer,args.engine,args.iwad,packages)
            if scene<4 or scene==9:
                cmd[cmd.index('+ca_standalone_mode')+1]='0'
                if '+map' in cmd:cmd[cmd.index('+map')+1]='MAP01' if scene in (0,3) else 'CARING'
            if previous:
                saved=Path(previous['directory'])/'peer0/ca513-manual.zds'
                if not saved.is_file():raise RuntimeError('No hay un guardado F5 del anfitrión para reabrir.')
                (peer/'recovery.zds').write_bytes(saved.read_bytes())
                if '+map' in cmd:at=cmd.index('+map');del cmd[at:at+2]
                cmd+=['-loadgame','recovery.zds']
            with (peer/'game.ini').open('a',encoding='utf-8') as f:
                f.write('vid_maxfps=60\nvid_vsync=false\nvid_defwidth=800\nvid_defheight=600\ni_soundinbackground=true\nlanguage=es\n')
            with (peer/'controls.cfg').open('a',encoding='utf-8') as f:
                f.write('bind f1 "netevent ca513_status; toggleconsole"\nbind f2 "netevent ca513_reset"\n'
                        'bind f3 "netevent ca513_place"\nbind f4 "netevent ca513_target"\n'
                        'bind f5 "save ca513-manual"\nbind f6 "netevent ca513_finish_setup"\n'
                        'bind q "openmenu CaelumStandaloneScoreMenu"\n'
                        'bind f7 "netevent ca513_capture"\n'
                        'bind w "+forward"\nbind s "+back"\nbind a "+moveleft"\nbind d "+moveright"\n'
                        'bind e "+use"\nbind mouse1 "+attack"\nbind space "+jump"\n')
                if args.smoke:
                    if slot==0 and scene in (10,11):f.write('wait 120; netevent ca513_reset; netevent ca513_place; wait 10; ')
                    if slot==0 and scene==12:f.write('wait 120; netevent ca513_place; netevent ca513_reset; wait 10; ')
                    f.write('wait 160; netevent ca513_status; wait 10; screenshot author-scene.png; ')
                    if slot==0:f.write('save ca513-manual; ')
                    f.write(f'wait {150+(count-slot)*35}; quit\n')
            cmd+=['-window','-width','800','-height','600'];commands.append(cmd)
            stream=(peer/'process.log').open('wb');streams.append(stream)
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.4)
        (out/'active.json').write_text(json.dumps({'pids':[p.pid for p in processes],'commands':commands},indent=2))
        deadline=time.monotonic()+100 if args.smoke else float('inf')
        while any(p.poll() is None for p in processes):
            if time.monotonic()>deadline:raise RuntimeError('Native author-scene smoke timed out; logs retained.')
            for peer in peers:
                log=(peer/'engine.log').read_text(errors='replace') if (peer/'engine.log').exists() else ''
                if any(x in log for x in ('Execution could not continue','VM execution aborted','CA435SYNC FAIL')):
                    raise RuntimeError('Native scene failed: '+str(peer/'engine.log'))
            time.sleep(.5)
    except (OSError,RuntimeError) as exc:error=str(exc);print(error,flush=True)
    finally:
        for p in processes:
            if p.poll() is None:p.terminate()
        for p in processes:p.wait(timeout=15)
        for stream in streams:stream.close()
    results=[]
    for slot,(p,peer) in enumerate(zip(processes,peers)):
        log=(peer/'engine.log').read_text(errors='replace') if (peer/'engine.log').exists() else ''
        failures=[line for line in log.splitlines() if any(x in line for x in (' FAIL ','Script error','Execution could not continue','VM execution aborted','out of sync'))]
        results.append(dict(slot=slot,exit=p.returncode,errors=failures,ready='CA513 READY' in log,
                            synchronized=native_sync.clean(log),status=[x for x in log.splitlines() if x.startswith('CA513 ')]))
    report=dict(directory=str(out),scene=scene,addon=str(addon),commands=commands,peers=results,error=error,
                runtime_sha256=digest(args.runtime),engine_sha256=digest(args.engine),author_accepted=False,
                passed=not error and len(results)==count and all(p['exit']==0 and not p['errors'] and p['ready'] and p['synchronized'] for p in results))
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print('Escenario cerrado: '+str(out),flush=True)
    print('Verificación técnica:',report['passed'],'— aceptación manual pendiente.',flush=True)
    return report

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True)
    p.add_argument('--iwad',type=Path,required=True);p.add_argument('--port',type=int,default=32620)
    p.add_argument('--scene',type=int,choices=range(14));p.add_argument('--smoke',action='store_true')
    p.add_argument('--reload',type=Path)
    args=p.parse_args()
    for field in ('runtime','engine','iwad'):setattr(args,field,getattr(args,field).resolve(strict=True))
    home=ROOT/'build/issue596'/datetime.datetime.now().strftime('author-suite-%Y%m%d-%H%M%S-%f');home.mkdir(parents=True)
    previous=json.loads(args.reload.read_text()) if args.reload else None
    if args.scene is not None:return not launch(args,home,args.scene,previous)['passed']
    while True:
        print('\nCAELUM ARGENTEUM — PRUEBAS V5.13\n')
        for scene,row in SCENES.items():print(f'{scene+1}. {row[0]}')
        print('15. #597 — Dos menús Multijugador (crear/unirse)\n16. Reabrir último guardado F5\n0. Salir')
        selected=input('Escenario: ').strip()
        if selected=='0':return 0
        try:
            if selected=='15':
                menu_pair(args,home);continue
            if selected=='16':
                if previous is None:print('Primero abrí un escenario y guardá con F5.');continue
                previous=launch(args,home,previous['scene'],previous);continue
            scene=int(selected)-1
            if scene not in SCENES:continue
            previous=launch(args,home,scene)
        except (ValueError,OSError,RuntimeError,subprocess.SubprocessError) as exc:
            print('No se pudo abrir el escenario:',exc,flush=True)

if __name__=='__main__':raise SystemExit(main())
