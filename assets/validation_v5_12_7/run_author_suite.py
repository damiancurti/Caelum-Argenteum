"""One persistent manual-test terminal, with isolated native two-player scenarios.

Uses the production registry/admission and real UI actions. No test acceptance is
inferred from this launcher; the author must confirm each issue separately.
"""
from pathlib import Path
import argparse,datetime,importlib.util,json,subprocess,sys,time,zipfile
import native_sync

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns
from caelum_sessions import Sessions,manifest,command,watch,digest

IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
SCENES={0:('#435 - Identidad y guardado',
    'F1: estado propio. F2 suma una moneda SOLO al personaje de esa ventana.\n'
    'Compara las dos ventanas. Guarda desde el anfitrion (F5). Cierra ambas\n'
    'con Escape > Salir. Opcion 9 reabre el ultimo guardado comun.'),
    1:('#436 - Descanso y unanimidad',
    'F2 en cada ventana: sentarse. Luego T desde el descanso abre la propuesta.\n'
    'Elegi la duracion y acepta en cada ventana.\n'
    'Con un solo voto el reloj no se acelera; rechazar cancela. W: levantarse tras cerrar la votacion.\n'
    'Repite aceptando ambos y comprueba que despertar/interrumpir detiene a todos.'),
    2:('#437 - El Loco, muerte y espiritu',
    'F3 mata SOLO al personaje de esa ventana (preparacion de prueba).\n'
    'F2 activa El Loco: acepta en ambas ventanas y comprueba el cobro unico.\n'
    'En la mansion el fallecido se mueve como espiritu, sin usar objetos.\n'
    'F2 alli abre a Palomo para volver por unanimidad. Sigue muerto al volver.\n'
    'F4 permite resucitar en esta prueba; no es un atajo del juego normal.\n'
    'Para el caso todos muertos, vuelve a abrir esta opcion y usa F3 en ambos.'),
    3:('#438 - Ring',
    'F2 abre al organizador. Elige ring y modo, propone y acepta en ambas ventanas.\n'
    'Comprueba posiciones separadas, combate real y resultado al rendirse.\n'
    'F2/F3 al terminar propone volver: requiere ambos votos.'),
    4:('#438 - Alcantarillas PvP',
    'F2 abre al organizador con laberinto seleccionado. Confirma ambos jugadores.\n'
    'Comprueba el mapa, modo individual/equipos y regreso por unanimidad.'),
    5:('#590 - Truco en la misma mesa',
    'Ambos empiezan sentados en una mesa real; solo el segundo tiene mazo.\n'
    'E (Usar) abre la mesa; invita, elige Truco y acepta en ambas ventanas.\n'
    'Comprueba manos privadas, turnos y cantos. Escape pide confirmar el abandono; cierra el resultado y W permite levantarse.'),
    6:('#590 - Trucazo en la misma mesa',
    'E (Usar) abre la mesa; invita, selecciona Trucazo y acepta en ambas ventanas.\n'
    'La Vida de las cartas depende de Paciencia; no es la Vida del personaje.\n'
    'Comprueba manos privadas y turnos. Escape pide confirmar el abandono; cierra el resultado y W permite levantarse.')}


def fixture(output,anchor,scene,diagnose=False):
    with zipfile.ZipFile(anchor.parent.parent/'checks.pk3') as seed:
        geometry=seed.read('maps/MAP03.wad')
    source=Path(__file__).with_name('author_probe.zs').read_bytes().replace(b'const SCENE=0;',f'const SCENE={scene};'.encode())
    members={'ZSCRIPT':b'version "4.14.2"\n#include "author.zs"\n',
        'MAPINFO':b'gameinfo { AddEventHandlers="CA512AuthorScene" }\n',
        'author.zs':source,'maps/MAP03.wad':geometry}
    if scene<0:members={'maps/MAP03.wad':geometry}
    if scene==2:
        members.update({'maps/MAP01.wad':geometry,'maps/MAP02.wad':geometry})
    if diagnose:
        source=(ROOT/'src/caelum/ui/CaelumLiveMenu.zs').read_text(encoding='utf-8')
        marker='        if(Wanted(Subject)!=Context)return true;'
        probe='''
        if(type==InputEvent.Type_KeyDown && Context==CTX_REST)
        {
            let seat=CaelumRestState(Subject.FindInventory("CaelumRestState"));
            let chair=seat!=null?CaelumRestChair(seat.Furniture):null;
            Console.Printf("CA512KEY scan=%d char=%d key=%s binding=%s table=%d chair=%d occupant=%d link=%d mode=%d predict=%d",
                scan,character,keyString,Bindings.GetBinding(scan),CaelumCardSeat.Table(Subject)!=null,chair!=null,
                chair!=null && chair.Occupant==Subject,chair!=null && chair.DiningTable!=null,seat!=null?seat.Mode:-1,
                int((Subject.player.cheats&CF_PREDICTING)!=0));
        }
'''
        members['caelum/ui/CaelumLiveMenu.zs']=source.replace(marker,marker+probe,1).encode()
    with zipfile.ZipFile(output,'x') as z:
        for name,data in sorted(native_sync.instrument(members).items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)


def launch(args,home,scene,previous=None):
    out=home/datetime.datetime.now().strftime(f'scene{scene}-%Y%m%d-%H%M%S-%f');out.mkdir()
    if previous:
        addon=Path(previous['addon']);store=ProfileStore(previous['store'])
    else:
        addon=out/'checks.pk3';fixture(addon,args.anchor,scene,args.diagnose_ui)
        store=ProfileStore(out/'profiles.sqlite3',create=True)
    campaigns=Campaigns(store,PersonalGraph(NativeSchema(args.engine.parent/'gzdoom.pk3',args.runtime)))
    if not previous:campaigns.register('author-test',args.anchor.read_bytes())
    sessions=Sessions(campaigns);token=out.name;packages=[args.runtime,addon]
    sessions.prepare('author-test',manifest(args.engine,IWAD,packages),token);sessions.export(token,out/'bundle')
    processes=[];peers=[];streams=[];commands=[];error=None
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0 if args.smoke else 1
    print('\n'+SCENES[scene][0]+'\n'+SCENES[scene][1],flush=True)
    print('Cambiar de jugador: Alt+Tab. Flechas/Enter en menus. Escape para volver.\n'
          'F1 muestra estado fuera de los menus; dentro usa las opciones del menu.\n'
          'Cierra las DOS ventanas para regresar aqui.\n'
          'Registro y guardados privados: '+str(out),flush=True)
    try:
        for slot in range(2):
            cmd,peer=command(out/'bundle',slot,args.engine,IWAD,packages,31535,'127.0.0.1');peers.append(peer)
            with (peer/'session.ini').open('a') as f:
                f.write('vid_preferbackend=1\nvid_vsync=false\nvid_maxfps=60\ncl_capfps=false\n'
                    'vid_fullscreen=false\nvid_defwidth=800\nvid_defheight=600\nwin_w=816\nwin_h=639\n'
                    'i_soundinbackground=true\nuse_mouse=true\nlanguage=es\n')
            with (peer/'start.cfg').open('a') as f:
                f.write('bind f1 "netevent ca512_status; toggleconsole"\n'
                    'bind f2 "netevent ca512_action"\nbind f3 "netevent ca512_secondary"\n'
                    'bind f4 "netevent ca512_restore"\nbind f5 "save manual-checkpoint"\n'
                    'bind w "+forward"\nbind s "+back"\nbind a "+moveleft"\nbind d "+moveright"\n'
                    'bind e "+use"\nbind mouse1 "+attack"\nbind space "+jump"\n')
                if getattr(args,'open_request',False):f.write('wait 140; netevent ca512_action\n')
                if args.smoke:f.write(f'wait 350; save manual-checkpoint; wait {70+(2-slot)*35}; netevent ca512_status; wait 5; quit\n')
            cmd+=['-window','-width','800','-height','600'];commands.append(cmd)
            stream=(peer/'process.log').open('wb');streams.append(stream)
            sessions.claim(token,slot);process=subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream)
            processes.append(process);sessions.attach(token,slot,process.pid);time.sleep(.4)
        deadline=time.monotonic()+90 if args.smoke else float('inf')
        (out/'active.json').write_text(json.dumps(dict(pids=[p.pid for p in processes],commands=commands),indent=2))
        while any(p.poll() is None for p in processes):
            if time.monotonic()>deadline:raise RuntimeError('Manual-scene smoke timed out; logs retained.')
            if any(any(mark in (p/'engine.log').read_text(errors='replace') for mark in ('Execution could not continue','CA512 FAIL','CA435SYNC FAIL')) for p in peers if (p/'engine.log').exists()):
                raise RuntimeError('Native scene failed; complete logs retained.')
            time.sleep(.5)
    except (OSError,RuntimeError) as exc:
        error=str(exc);print(error,flush=True)
    finally:
        for process in processes:
            if process.poll() is None:process.terminate()
        for process in processes:process.wait(timeout=15)
        for stream in streams:stream.close()
        for slot in range(len(processes)):sessions.finished(token,slot)
        if processes:watch(processes[0],peers[0],sessions,token,0)
        recovery=sessions.close(token);store.close()
    reports=[]
    for slot,(process,peer) in enumerate(zip(processes,peers)):
        log=(peer/'engine.log').read_text(errors='replace') if (peer/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(x in line for x in (' FAIL ','Script error','Execution could not continue','VM execution aborted','CA_SESSION REJECT','out of sync','Savegame is from a different level'))]
        reports.append(dict(slot=slot,exit=process.returncode,errors=errors,
            ready='CA512 READY' in log and 'CA_SESSION READY' in log and native_sync.clean(log),
            status=[line for line in log.splitlines() if line.startswith('CA512 player=')]))
    result=dict(scene=scene,commands=commands,peers=reports,recovery=recovery,
        runtime_sha256=digest(args.runtime),engine_sha256=digest(args.engine),addon=str(addon),
        store=previous['store'] if previous else str(out/'profiles.sqlite3'),author_accepted=False,error=error,
        scope='Startup, process exits and native sync only; interactive acceptance must be recorded separately.',
        passed=not error and len(reports)==2 and all(p['ready'] and p['exit']==0 and not p['errors'] for p in reports))
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('Escenario cerrado. Registros: '+str(out),flush=True)
    return result


def profile_menu(args,home):
    folder=home/'profile-menu';folder.mkdir(exist_ok=True);database=folder/'profiles.sqlite3';addon=folder/'checks.pk3'
    if not database.exists():
        fixture(addon,args.anchor,-1)
        store=ProfileStore(database,create=True)
        Campaigns(store,PersonalGraph(NativeSchema(args.engine.parent/'gzdoom.pk3',args.runtime))).register('prueba-a',args.anchor.read_bytes());store.close()
    print('\n#434: registro privado, dos personajes en prueba-a.\n'
        '1 muestra identidades/custodia; 11 crea prueba-b con 2 plazas;\n'
        '6 traslada un personaje a prueba-b, y luego permite devolverlo a prueba-a.\n'
        'Comprueba una sola custodia, inventario y dinero conservados.\n'
        '8/9 comprueban copia y recuperacion en una ubicacion nueva. 0 vuelve aqui.\n')
    subprocess.run([sys.executable,str(ROOT/'caelum_session_menu.py'),'--engine',str(args.engine),'--iwad',str(IWAD),
        '--package',str(args.runtime),'--package',str(addon),'--store',str(database)])


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--engine',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True)
    p.add_argument('--anchor',type=Path,required=True);p.add_argument('--scene',type=int,choices=range(7))
    p.add_argument('--smoke',action='store_true');p.add_argument('--diagnose-ui',action='store_true')
    p.add_argument('--open-request',action='store_true',help='Schedule the fixture action through its native event to review the real UI')
    args=p.parse_args()
    for key in ('engine','runtime','anchor'):setattr(args,key,getattr(args,key).resolve(strict=True))
    home=ROOT/'build/issue435'/datetime.datetime.now().strftime('author-suite-%Y%m%d-%H%M%S-%f');home.mkdir()
    print('CAELUM ARGENTEUM 5.12 - PRUEBAS POR ISSUE\n'
        'Motor privado 4.14.2 con correccion del temporizador; instalacion original intacta.\n'
        'Dos clientes nativos en este equipo. Guardados y perfiles de prueba separados.\n',flush=True)
    last=None
    if args.scene is not None:
        result=launch(args,home,args.scene);raise SystemExit(not result['passed'])
    while True:
        print('\n'+ '\n'.join(f'{n+1}. {v[0]}' for n,v in SCENES.items())+
            '\n8. #434 - Perfiles entre campanas\n9. Reabrir el ultimo escenario desde su guardado\n0. Salir')
        try:
            selected=input('Opcion: ').strip()
            if selected=='0':break
            if selected=='8':profile_menu(args,home)
            elif selected=='9' and last:last=launch(args,home,last['scene'],last)
            elif selected.isdigit() and 1<=int(selected)<=7:last=launch(args,home,int(selected)-1)
            else:print('Elige una opcion disponible.')
        except (OSError,RuntimeError,ValueError) as exc:print('No se completo la operacion:',exc)


if __name__=='__main__':main()
