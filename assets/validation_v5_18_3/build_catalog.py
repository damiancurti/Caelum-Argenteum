"""Carry every pending author check and original scene into the final terminal."""
from pathlib import Path
import argparse,hashlib,json,re

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--release-directory',type=Path,required=True)
    p.add_argument('--diagnostic-runtime',type=Path,required=True)
    p.add_argument('--composition-config',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();release=a.release_directory.resolve(strict=True)
    runtime=release/'caelum_argenteum.ipk3';assert runtime.is_file()
    old=json.loads((ROOT/'assets/validation_v5_17_123/CATALOG.json').read_text(encoding='utf8'))
    actions=old['actions'][:]
    actions += [
        dict(id='motion-author',title='Sentarse, acostarse, levantarse, comer y beber (#460)',kind='runner',group='beta',
             script='assets/validation_v5_18_3/run_motion_author.py',arguments=['--interactive'],close_setup_menu=True,
             help='F1 silla; F2 cama; F3 suelo; F4 levantarse; F5 comer; F6 beber; F7 cámara; F8 cuerpo base/candidato. Primero siéntate o acuéstate. Revisa transiciones, escudo visible, arma oculta durante el gesto y retorno al equipo normal. Sala diagnóstica: sus objetos y atributos no representan una campaña.',
             smoke_commands='netevent ca460_begin 0 0; wait 75; netevent ca460_meal 0; wait 65; netevent ca460_meal_check 5; wait 90; netevent ca460_cancel; wait 75; '),
        dict(id='independent-resources',title='Efectos y recursos propios del juego independiente (#467)',kind='runner',group='beta',independent=True,
             script='assets/validation_v5_18_3/run_resource_author.py',arguments=['--interactive'],close_setup_menu=True,
             help='F1 muestra sangre, impactos, armadura y palanca; F2 vuelve al mundo. La escena comprueba también voces y menús. Usa Escape para guardar. El juego usa su propio IPK3 como archivo principal; el observador de revisión es local.'),
        dict(id='independent-play',title='Iniciar la entrega independiente con su lanzador',kind='tool',group='beta',mode='Play',
             help='Abre la beta entregada, sin observadores ni Doom. Perfil de revisión separado; conserva aquí tus preferencias y guardados. Cierra GZDoom para volver.'),
        dict(id='beta-multiplayer',title='Multijugador: modos independientes y host/unirse',kind='tool',group='beta',mode='Multiplayer',
             help='El lanzador abre el menú nativo y coordina host/unirse. Cada partida usa su propia carpeta. Cierra el título al terminar para volver a esta terminal. Las pruebas locales no certifican Internet.'),
        dict(id='beta-profiles',title='Perfiles de campaña, sesiones, transferencia y copias',kind='tool',group='beta',mode='Profiles',
             help='Coordinador con almacén separado para esta revisión. Usa copias compatibles de tus guardados y conserva los originales. Elige 0 para volver; ninguna transferencia se realiza sin tu selección explícita en este menú.'),
        dict(id='beta-guide',title='Guía de instalación, controles, actualización y límites',kind='gallery',group='beta',path='{release_directory}/PLAYER_GUIDE.txt'),
        dict(id='effect-source',title='Fuente de arte: impactos y sangre (#467)',kind='gallery',group='beta',path='assets/source/art/standalone_467/impact-blood-source.png'),
        dict(id='effect-prompt',title='Prompt y procedencia del nuevo arte (#467)',kind='gallery',group='beta',path='assets/source/art/standalone_467/PROMPT.json')]
    mapping={
        'CA460-MOTION-01':['motion-author','equipment','campaign'],
        'CA464-AUDIO-01':['independent-play','campaign'],
        'CA465-UI-01':['independent-play','campaign','beta-guide'],
        'CA466-RIGHTS-01':['independent-resources','independent-play','effect-source','effect-prompt','beta-guide'],
        'CA467-STARTUP-01':['independent-resources','independent-play','effect-source','effect-prompt','beta-guide'],
        'CA468-BETA-01':['campaign','beta-multiplayer','beta-profiles','beta-guide'],
        'CA469-DELIVERY-01':['independent-play','beta-multiplayer','beta-profiles','beta-guide']}
    previous={r['id']:r for r in old['checks']}
    path=ROOT/'pending_test.txt';text=path.read_text(encoding='utf8')
    headings=list(re.finditer(r'^(CA\S+) \| Origin[^\n]*$',text,re.M));checks=[]
    for i,match in enumerate(headings):
        ident=match[1];block=text[match.start():headings[i+1].start() if i+1<len(headings) else len(text)].strip()
        if ident in previous:
            assert previous[ident]['instructions'].strip()==block,ident
            selected=previous[ident]['actions']
        else:selected=mapping[ident]
        checks.append(dict(id=ident,instructions=block,actions=selected))
    assert len(checks)==115 and set(previous)<={r['id'] for r in checks}
    ids={r['id'] for r in actions};assert len(ids)==len(actions)
    assert all(r['actions'] and set(r['actions'])<=ids for r in checks)
    data=dict(issue=469,version='5.18.3',pending_sha256=hashlib.sha256(path.read_bytes()).hexdigest(),checks=checks,actions=actions,
        status_es='Beta independiente del prólogo MAP01–MAP03. Los issues #460 y #464–469 tienen implementaciones y evidencia separadas; las PR quedan para revisión. Todas las 115 comprobaciones siguen pendientes de tu veredicto. La campaña posterior necesita diseño. Persisten las limitaciones de fluidez del asedio, Internet/equipos separados y las decisiones visuales pendientes. La opción 10 abre la entrega, modos, perfiles y nuevas pruebas. Las escenas antiguas usan sus fixtures locales; nunca se distribuyen con el juego. Registrar una observación no aprueba ni cierra una prueba.')
    (HERE/'CATALOG.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf8',newline='\n')
    config=json.loads(a.composition_config.resolve(strict=True).read_text(encoding='utf8'))
    config.update(issue=469,runtime=str(runtime),diagnostic_runtime=str(a.diagnostic_runtime.resolve(strict=True)),
        independent=True,release_directory=str(release),catalog=str(HERE/'CATALOG.json'),
        title='Caelum Argenteum — beta 5.18.3 / revisión completa',
        review_profile=str(ROOT/'build/author-889/beta-5.18.3-profile'))
    out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    (out/'session-config.json').write_text(json.dumps(config,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print(json.dumps(dict(checks=len(checks),actions=len(actions),config=str(out/'session-config.json'),author_acceptance=False)))

if __name__=='__main__':main()
