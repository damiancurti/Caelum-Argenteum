"""Isolated native author sessions, explicit smoke checks and exact-option reload."""
from pathlib import Path
import datetime,hashlib,json,re,shutil,subprocess,sys,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
FATAL=('Script error','Execution could not continue','VM execution aborted','FATAL ERROR',
       'Cannot find savegame','Unexpected JIT error','Unknown command','Unknown texture','Unable to load model')
PROBE='''version "4.14.2"
class CA889AuthorSession : EventHandler
{
    override void WorldLoaded(WorldEvent e)
    { Console.Printf("CA889 LEVEL map=%s",level.MapName); }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca889_ready')
            Console.Printf("CA889 READY map=%s player=%d",level.MapName,players[0].mo!=null);
        if(e.Name=='ca889_close_setup' && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=='ca889_menu')
        {
            let menu=Menu.GetCurrentMenu();
            bool okay=menu!=null && menu.GetClassName()=='SaveMenu';
            Console.Printf("CA889 MENU %s class=%s",okay?"PASS":"FAIL",menu!=null?menu.GetClassName():'None');
            if(menu!=null)menu.Close();
        }
    }
}
class CA889AuthorTitle : StaticEventHandler
{
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=='ca889_newcharacter')Menu.SetMenu('CaelumNewCharacterMenu');
        if(e.Name=='ca889_title')
        {
            let menu=Menu.GetCurrentMenu();
            bool okay=menu!=null && menu.GetClassName()=='CaelumCharacterCreationMenu';
            Console.Printf("CA889 TITLE %s class=%s",okay?"PASS":"FAIL",menu!=null?menu.GetClassName():'None');
        }
    }
}
'''

def sha(path):
    with Path(path).open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()

def write_json(path,value):
    Path(path).write_text(json.dumps(value,indent=2,ensure_ascii=False)+'\n',encoding='utf-8',newline='\n')

def load_config(path):
    data=json.loads(Path(path).read_text(encoding='utf-8'))
    assert data['issue']==889
    return data

def no_engine():
    active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace')
    assert '"gzdoom.exe"' not in active.lower(),'Cierra la partida abierta antes de iniciar otra escena.'

def new_output(label):
    assert re.fullmatch(r'[a-zA-Z0-9_-]+',label)
    parent=ROOT/'build/author-889';parent.mkdir(parents=True,exist_ok=True)
    return parent/(datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')+'-'+label)

def packages(command):
    i=command.index('-file')+1;result=[]
    while i<len(command) and not command[i].startswith(('-','+')):
        result.append(Path(command[i]).resolve(strict=True));i+=1
    return result

def replace_value(command,key,value):
    command[command.index(key)+1]=str(value)

def console_commands(text):
    """Split only outside quoted alias/bind bodies."""
    result=[];part=[];quoted=False;escaped=False
    for char in text:
        if char=='"' and not escaped:quoted=not quoted
        if char in ';\n' and not quoted:
            if ''.join(part).strip():result.append(''.join(part).strip())
            part=[]
        else:part.append(char)
        escaped=char=='\\' and not escaped
    assert not quoted
    if ''.join(part).strip():result.append(''.join(part).strip())
    return result

def expand_config(path,out,seen=None):
    path=Path(path).resolve(strict=True);path.relative_to(out)
    seen=set() if seen is None else seen
    assert path not in seen,'Recursive console chain'
    seen.add(path);result=[]
    for command in console_commands(path.read_text(encoding='utf-8')):
        if command.lower().startswith('exec '):
            child=Path(command[5:].strip().strip('"'))
            result+=expand_config(child if child.is_absolute() else out/child,out,seen)
        else:result.append(command)
    return result

def write_chain(out,name,commands):
    chunks=['']
    for command in commands:
        assert len(command)<1400,'Oversized single console command'
        if len(chunks[-1])+len(command)>1400:chunks.append('')
        chunks[-1]+=command+'; '
    paths=[out/(name+('' if i==0 else '-'+str(i))+'.cfg') for i in range(len(chunks))]
    for i,(path,chunk) in enumerate(zip(paths,chunks)):
        tail=f'exec "{paths[i+1].as_posix()}";' if i+1<len(paths) else ''
        path.write_text(chunk+tail+'\n',encoding='utf-8',newline='\n')
    return paths[0]

def prepare(action,config,out,language='es',smoke=False):
    no_engine();out=Path(out).resolve();out.relative_to(ROOT/'build');assert not out.exists()
    out.parent.mkdir(parents=True,exist_ok=True)
    runtime=Path(config['runtime']).resolve(strict=True)
    if action['kind']=='campaign':
        out.mkdir(parents=True)
        ini=out/'session.ini';ini.write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\n',encoding='utf-8')
        cfg=out/'original.cfg';cfg.write_text('',encoding='utf-8')
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),'-config',str(ini),
                 '-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),
                 '+exec',str(cfg)]
        original=dict(command=command,cwd=str(out),script=None)
    else:
        assert action['kind']=='runner'
        arguments=[str(v).format(**config) for v in action['arguments']]
        arguments+=['--runtime',str(runtime),'--output',str(out)]
        record=out.parent/(out.name+'-prepared.json')
        cmd=[sys.executable,str(HERE/'prepare_runner.py'),'--script',str(ROOT/action['script']),
             '--record',str(record),'--',*arguments]
        log=out.parent/(out.name+'-prepare.log')
        with log.open('xb') as stream:subprocess.run(cmd,cwd=ROOT,stdout=stream,stderr=stream,check=True)
        original=json.loads(record.read_text(encoding='utf-8'));command=original['command']
        original['controls_help']=[line for line in log.read_text(encoding='utf-8',errors='replace').splitlines()
                                   if line.startswith('F') or line.startswith('Walk normally')]
        Path(original['cwd']).resolve().relative_to(out)
        # Some established creature runners put their interactive phase in a
        # visual/ child. Keep their absolute inputs, but unify the terminal's
        # log/screenshot/save directory so reload always refers to one folder.
        replace_value(command,'-savedir',out)
    command=list(map(str,command))
    if '-nomouse' in command:command.remove('-nomouse')
    with zipfile.ZipFile(runtime) as z:
        controls=re.search(r'^alias ca_controls_defaults "([^"]+)"',z.read('KEYCONF').decode('utf-8'),re.M)[1]
    original_cfg=Path(command[command.index('+exec')+1])
    probe=out/'terminal-observer.pk3'
    with zipfile.ZipFile(probe,'x') as z:
        for name,value in [('ZSCRIPT',PROBE),('MAPINFO','gameinfo { AddEventHandlers="CA889AuthorSession","CA889AuthorTitle" }\n')]:
            z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value.encode())
    index=command.index('-file')+1+len(packages(command));command.insert(index,str(probe))
    # Existing fixture bindings override ordinary F-keys after common controls.
    initial=console_commands(controls)+expand_config(original_cfg,out)
    title_only=action['kind']=='campaign'
    if title_only:
        setup='wait 10; event ca889_newcharacter; wait 10; event ca889_title; '
        if smoke:setup+='screenshot terminal.png; wait 5; quit; '
    else:
        setup='wait 70; '
        if action.get('close_setup_menu'):setup+='event ca889_close_setup; wait 5; '
        setup+='event ca889_ready; '
        if smoke:
            setup+=action.get('smoke_commands','')
            setup+='menu_save; wait 10; event ca889_menu; wait 5; save terminal-smoke; wait 20; screenshot terminal.png; wait 5; quit; '
    cfg=write_chain(out,'terminal-start',initial+console_commands(setup))
    replace_value(command,'+exec',cfg);replace_value(command,'+logfile',out/'engine.log')
    command+=['+language',language,'+snd_mastervolume','0.05','+vid_maxfps','60',
              '+vid_activeinbackground','true','+i_pauseinbackground','false',
              '+vid_lowerinbackground','false','+i_soundinbackground','true']
    record=dict(issue=889,action=action['id'],command=command,cwd=str(out),language=language,
                smoke=smoke,title_only=title_only,author_acceptance=False,source_runner=original.get('script'),
                reload_setup=action.get('reload_setup',[]),
                controls_help=original.get('controls_help',[]),
                packages={str(p):sha(p) for p in packages(command)},engine_sha256=sha(command[0]),
                iwad_sha256=sha(command[command.index('-iwad')+1]),
                save_scope='Only saves made in this exact disposable session/options; no campaign import.')
    write_json(out/'session.json',record)
    return record

def reload_session(previous,save,out,smoke=False,original_iwad_sha256=None):
    no_engine();previous=Path(previous).resolve(strict=True);previous.relative_to(ROOT/'build/author-889')
    data=json.loads((previous/'session.json').read_text(encoding='utf-8'))
    if data.get('issue')!=889:
        raise ValueError('Invalid author session.')
    command=data['command'].copy()
    expected_iwad=data.get('iwad_sha256') or original_iwad_sha256
    if not expected_iwad:
        raise ValueError('This older session needs --original-iwad-sha256 from the original installation.')
    if sha(command[0])!=data['engine_sha256'] or sha(command[command.index('-iwad')+1])!=expected_iwad.lower():
        raise ValueError('Engine or IWAD changed since the original author session.')
    for path,expected in data['packages'].items():
        if sha(path)!=expected:
            raise ValueError('A package changed since the original author session.')
    save=Path(save).resolve(strict=True);assert save.parent==previous and save.suffix.lower()=='.zds'
    out=Path(out).resolve();out.relative_to(ROOT/'build/author-889');out.mkdir(parents=True,exist_ok=False)
    copied=out/'restore.zds';shutil.copyfile(save,copied);assert sha(save)==sha(copied)
    for flag in ['+map','-loadgame']:
        if flag in command:
            i=command.index(flag);del command[i:i+2]
    command+=['-loadgame','restore.zds']
    config=out/'session.ini';shutil.copyfile(command[command.index('-config')+1],config)
    replace_value(command,'-config',config);replace_value(command,'-savedir',out);replace_value(command,'+logfile',out/'engine.log')
    cfg=out/'reload.cfg'
    setup=''.join(command+'; ' for command in data.get('reload_setup',[]))
    setup+='wait 70; event ca889_ready; '
    if smoke:setup+='menu_save; wait 10; event ca889_menu; wait 5; save terminal-smoke; wait 20; screenshot terminal.png; wait 5; quit; '
    cfg.write_text(setup+'\n',encoding='utf-8',newline='\n');replace_value(command,'+exec',cfg)
    record=dict(data,command=command,cwd=str(out),smoke=smoke,title_only=False,reloaded_from=str(save),
                iwad_sha256=expected_iwad.lower(),
                original_save_sha256=sha(save),copied_save_sha256=sha(copied))
    write_json(out/'session.json',record);return record

def run(record,hidden=False,timeout=180):
    no_engine();out=Path(record['cwd']);start=subprocess.STARTUPINFO()
    start.dwFlags|=subprocess.STARTF_USESHOWWINDOW;start.wShowWindow=0 if hidden else 1
    with (out/'process.log').open('wb') as stream:
        process=subprocess.Popen(record['command'],cwd=out,startupinfo=start,stdout=stream,stderr=stream)
        write_json(out/'process.json',dict(pid=process.pid,owned_by_terminal=True))
        deadline=time.monotonic()+timeout if hidden else None;stopped=None
        try:
            while process.poll() is None:
                log=(out/'engine.log').read_text(encoding='utf-8',errors='replace') if (out/'engine.log').exists() else ''
                raw=(out/'process.log').read_text(encoding='utf-8',errors='replace')
                if any(token in log+raw for token in FATAL):stopped='Native error';break
                if deadline and time.monotonic()>deadline:stopped='Timeout';break
                time.sleep(.25)
        except KeyboardInterrupt:
            stopped='Interrupted by author'
        finally:
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
    text='\n'.join(p.read_text(encoding='utf-8',errors='replace') for p in [out/'engine.log',out/'process.log'] if p.exists())
    errors=[line for line in text.splitlines() if any(t in line for t in FATAL)]
    errors += [line for line in text.splitlines() if re.match(r'^CA\d+\b.*(?:\bFAIL\b|failures=[1-9]|result=FAIL)',line)]
    if stopped:errors.append(stopped)
    ready='CA889 TITLE PASS' in text if record.get('title_only') else 'CA889 READY' in text
    menu='CA889 MENU PASS' in text and 'CA889 MENU FAIL' not in text
    save=(out/'terminal-smoke.zds').exists()
    checks_ok=not record['smoke'] or record.get('title_only') or menu and save
    if code!=0 and not errors:errors.append(f'Engine exit code {code}')
    if not ready:errors.append('Expected scene/title marker missing')
    if not checks_ok:errors.append('Native save menu or checkpoint smoke check failed')
    passed=code==0 and not errors and ready and checks_ok
    result=dict(issue=889,action=record['action'],passed=passed,exit_code=code,errors=errors,
                ready=ready,menu_available=menu if record['smoke'] else None,smoke_save_exists=save,
                reloaded=bool(record.get('reloaded_from')),author_acceptance=False)
    write_json(out/'RESULTS.json',result)
    return result
