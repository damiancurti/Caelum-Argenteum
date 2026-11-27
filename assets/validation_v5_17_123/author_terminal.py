"""One consolidated V5.16/V5.17 author terminal; every verdict remains manual."""
from pathlib import Path
import argparse,ctypes,datetime,json,os,subprocess,sys
from sessions import ROOT,HERE,load_config,new_output,prepare,reload_session,run,sha,write_json,no_engine

def catalog(config=None):
    path=Path(config['catalog']) if config and config.get('catalog') else HERE/'CATALOG.json'
    data=json.loads(path.read_text(encoding='utf-8'))
    text=(ROOT/'pending_test.txt').read_text(encoding='utf-8')
    if not text.strip():
        return dict(data, checks=[], status_es='No hay comprobaciones pendientes. El historial conserva los resultados confirmados.')
    assert data['pending_sha256']==sha(ROOT/'pending_test.txt'),'El catálogo quedó desactualizado; regenerar antes de revisar.'
    for row in data['checks']:assert row['instructions'] in text
    return data

def choose(rows,title):
    if not rows:return None
    print('\n'+title)
    for index,row in enumerate(rows,1):print(f'{index:3}. '+row.get('title',row['id']))
    value=input('Número (Enter vuelve): ').strip()
    return rows[int(value)-1] if value.isdigit() and 1<=int(value)<=len(rows) else None

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--config',type=Path,required=True)
    p.add_argument('--check',action='store_true')
    p.add_argument('--action')
    p.add_argument('--prepare-only',action='store_true')
    p.add_argument('--smoke',action='store_true')
    p.add_argument('--reload',type=Path)
    p.add_argument('--save',type=Path)
    p.add_argument('--original-iwad-sha256',help='Original verified IWAD digest for older author sessions')
    p.add_argument('--output',type=Path)
    a=p.parse_args();config=load_config(a.config);data=catalog(config)
    actions={row['id']:row for row in data['actions']}
    assert len(actions)==len(data['actions'])
    for row in data['checks']:assert row['actions'] and all(key in actions for key in row['actions'])
    for row in actions.values():
        if row['kind']=='runner':assert (ROOT/row['script']).is_file()
        elif row['kind']=='gallery':assert (ROOT/row['path'].format(**config)).is_file()
        elif row['kind']=='tool':assert (Path(config['release_directory'])/'run_release.ps1').is_file()
    if a.check:
        print(json.dumps(dict(checks=len(data['checks']),actions=len(actions),covered=True,author_acceptance=False)))
        return
    if a.action or a.reload:
        out=a.output or new_output(a.action or 'reload')
        if a.reload:
            assert a.save;record=reload_session(a.reload,a.save,out,smoke=a.smoke,original_iwad_sha256=a.original_iwad_sha256)
        else:record=prepare(actions[a.action],config,out,smoke=a.smoke)
        if a.prepare_only:print(record['cwd']);return
        result=run(record,hidden=a.smoke)
        print(json.dumps(result));raise SystemExit(not result['passed'])
    last=None;language='es'
    # The lease belongs to this terminal thread and is released on every exit.
    awake=ctypes.windll.kernel32.SetThreadExecutionState(0x80000001)
    if not awake:print('No se pudo solicitar protección temporal contra suspensión.')
    notes=ROOT/'build/author-889/author-notes.jsonl'
    state_path=notes.parent/'terminal-state.json'
    state=dict(issue=config['issue'],pid=os.getpid(),active=True,system_required=bool(awake),wake_request_succeeded=bool(awake),
               checks=len(data['checks']),actions=len(actions),
               started=datetime.datetime.now().isoformat(),author_acceptance=False)
    def open_action(action):
        nonlocal last
        if action['kind']=='gallery':
            os.startfile(str((ROOT/action['path'].format(**config)).resolve(strict=True)));return
        if action['kind']=='tool':
            no_engine()
            command=['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',
                str(Path(config['release_directory'])/'run_release.ps1'),'-Mode',action['mode'],
                '-ProfileDirectory',config['review_profile'],'-Language',language]
            print('\n'+action['help']);print('Perfil de revisión: '+config['review_profile'],flush=True)
            result=subprocess.run(command,cwd=ROOT)
            print('Lanzador terminado. Ninguna comprobación fue aprobada automáticamente. Código: '+str(result.returncode))
            return
        print('\n'+action.get('help','Cierra GZDoom para volver a esta terminal. Guarda desde el menú Escape; los archivos quedan en la carpeta de esta sesión.'))
        out=new_output(action['id'])
        record=prepare(action,config,out,language=language);last=out
        print('Sesión: '+str(out),flush=True)
        for help_line in record.get('controls_help',[]):print(help_line,flush=True)
        result=run(record)
        print('La escena terminó.' if result['passed'] else 'La escena terminó con un problema: '+str(result['errors']))
        print('Ninguna comprobación fue marcada como aprobada.')
    try:
        notes.parent.mkdir(parents=True,exist_ok=True)
        write_json(state_path,state)
        while True:
            print('\n'+config.get('title','Caelum Argenteum — revisión consolidada V5.16 / V5.17'))
            print(f'{len(data["checks"])} comprobaciones pendientes. Idioma: {language.upper()}.')
            print('1 Campaña nueva\n2 Mapas y propuestas de ambiente\n3 Equipo real / vestuario\n4 Buscar comprobaciones por issue o texto\n5 Propuestas de personajes\n6 Recargar un guardado de la última escena\n7 Registrar observación\n8 Estado y decisiones pendientes\n9 Cambiar ES/EN\n10 Entrega independiente / modos / perfiles / nuevas pruebas\n0 Salir')
            option=input('Opción: ').strip()
            try:
                if option=='0':break
                if option=='1':open_action(actions['campaign'])
                elif option=='2':
                    row=choose([r for r in actions.values() if r.get('group')=='environment'],'Comparaciones de mapas')
                    if row:open_action(row)
                elif option=='3':
                    row=choose([actions[key] for key in ['equipment','wardrobe-art','v5_17_92-run_underbody']],'Equipo y cuerpo')
                    if row:open_action(row)
                elif option=='4':
                    query=input('Issue, nombre o palabra (Enter muestra todas): ').strip().casefold()
                    rows=[dict(row,title=row['id']) for row in data['checks'] if query in row['instructions'].casefold()]
                    row=choose(rows,'Comprobaciones')
                    if row:
                        print('\n'+row['instructions'])
                        action=choose([actions[key] for key in row['actions']],'Abrir escena o referencia')
                        if action:open_action(action)
                elif option=='5':open_action(actions['gallery-CA736-MODULAR-STYLE-01'])
                elif option=='6':
                    if last is None:
                        prior=[]
                        for session in (ROOT/'build/author-889').glob('*/session.json'):
                            saved=json.loads(session.read_text(encoding='utf-8'))
                            if not saved.get('smoke') and list(session.parent.glob('*.zds')):
                                prior.append(dict(id=session.parent.name,title=session.parent.name,path=session.parent))
                        selected=choose(sorted(prior,key=lambda r:r['id'],reverse=True),'Sesiones anteriores de esta terminal')
                        if not selected:continue
                        last=selected['path']
                    saves=sorted(last.glob('*.zds'))
                    row=choose([dict(id=p.name,title=p.name,path=p) for p in saves],'Guardados de la última escena')
                    if row:
                        out=new_output('reload');record=reload_session(last,row['path'],out,original_iwad_sha256=a.original_iwad_sha256)
                        last=out;print('Recarga aislada: '+str(out),flush=True);result=run(record)
                        print('Recarga terminada; tu veredicto sigue pendiente.' if result['passed'] else str(result['errors']))
                elif option=='7':
                    ident=input('ID o tema: ').strip();note=input('Observación: ').strip()
                    if note:
                        notes.parent.mkdir(parents=True,exist_ok=True)
                        with notes.open('a',encoding='utf-8') as f:
                            f.write(json.dumps(dict(time=datetime.datetime.now().isoformat(),id=ident,note=note,session=str(last) if last else None),ensure_ascii=False)+'\n')
                        print('Observación guardada localmente. Comunica tu aprobación o corrección en la conversación.')
                elif option=='8':print('\n'+data['status_es'])
                elif option=='9':language='en' if language=='es' else 'es'
                elif option=='10':
                    row=choose([r for r in actions.values() if r.get('group')=='beta'],'Beta independiente')
                    if row:open_action(row)
            except (Exception,KeyboardInterrupt) as error:
                print('No se completó esa acción: '+str(error))
                print('Los archivos y guardados anteriores se conservaron.')
    finally:
        ctypes.windll.kernel32.SetThreadExecutionState(0x80000000)
        write_json(state_path,dict(state,active=False,system_required=False,
                                  released=datetime.datetime.now().isoformat()))

if __name__=='__main__':
    main()
