"""Observe a real fresh launch, then verify controls/preferences on restart.

The first native window is closed through normal Windows app input. Only this
runner's owned process tree may be stopped on timeout. All profiles are disposable.
"""
from pathlib import Path
import argparse,json,os,re,shutil,subprocess,sys,time,zipfile

ROOT=Path(__file__).resolve().parents[2]

def write_ini_value(text,section,key,value):
    pattern=re.compile(r'(?im)^\['+re.escape(section)+r'\]\s*$')
    match=pattern.search(text)
    if not match:return text+'\n['+section+']\n'+key+'='+value+'\n'
    following=re.search(r'(?m)^\[',text[match.end():]);end=match.end()+following.start() if following else len(text)
    block=text[match.end():end];field=re.compile(r'(?im)^'+re.escape(key)+r'=[^\r\n]*$')
    block=field.sub(lambda m:key+'='+value,block) if field.search(block) else '\n'+key+'='+value+block
    return text[:match.end()]+block+text[end:]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--mode',choices=['Play','Multiplayer'],default='Play');a=p.parse_args()
    directory=a.directory.resolve(strict=True);out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace')
    if '"gzdoom.exe"' in active.lower():raise RuntimeError('Existing game preserved; close it before this test.')
    profile=out/'profile';command=['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(directory/'run_release.ps1'),
        '-Mode',a.mode,'-ProfileDirectory',str(profile),'-Python',sys.executable]
    env=os.environ.copy();env.pop('PYTHONPATH',None);env['PYTHONDONTWRITEBYTECODE']='1'
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    with (out/'first-process.txt').open('xb') as stream:
        process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,env=env,startupinfo=startup)
        (out/'process.json').write_text(json.dumps(dict(pid=process.pid,command=command,owned=True),indent=2)+'\n')
        print(json.dumps(dict(mode=a.mode,pid=process.pid,profile=str(profile),action='Inspect and close the fresh native GZDoom window through normal app input.')),flush=True)
        try:code=process.wait(timeout=240)
        finally:
            if process.poll() is None:subprocess.run(['taskkill','/PID',str(process.pid),'/T','/F'],capture_output=True)
    assert code==0,code
    ini=profile/'gzdoom.ini';fresh=ini.read_text(encoding='utf8');(out/'first-profile.ini').write_text(fresh,encoding='utf8')
    with zipfile.ZipFile(directory/'caelum_argenteum.ipk3') as z:
        preset=re.search(r'^alias ca_controls_defaults "([^"]+)"',z.read('KEYCONF').decode('utf8'),re.M)[1]
    bindings=re.findall(r'(?:^|;\s*)bind (\S+) ([^;]+)',preset)
    for key,value in bindings:assert re.search(r'(?im)^'+re.escape(key)+'='+re.escape(value)+r'\s*$',fresh),(key,value)
    assert re.search(r'(?im)^snd_mastervolume=0\.05\s*$',fresh)
    logs=[profile/'latest.log'] if a.mode=='Play' else list((profile/'matches').glob('*/menu.log'))
    assert len(logs)==1
    log=logs[0].read_text(errors='replace');shutil.copyfile(logs[0],out/'first-native.log')
    assert not re.search(r'adding .*[/\\](?:DOOM2?\.WAD|id24res\.wad)',log,re.I)
    assert not any(t in log for t in ['Script error','Execution could not continue','VM execution aborted','Unknown command'])
    cfg=out/'restart.cfg';cfg.write_text('wait 105; echo CA469_PREFERENCES; screenshot preferences.png; wait 3; quit\n')
    changed=write_ini_value(fresh,'CaelumArgenteum.Bindings','Tab','togglemap')
    changed=write_ini_value(changed,'GlobalSettings','language','en')
    changed=write_ini_value(changed,'GlobalSettings','snd_musicvolume','0.25')
    changed=write_ini_value(changed,'CaelumArgenteum.AutoExec','Path',cfg.as_posix())
    ini.write_text(changed,encoding='utf8')
    restart=command[:];restart[restart.index('-Mode')+1]='Play'
    with (out/'restart-process.txt').open('xb') as stream:
        result=subprocess.run(restart,cwd=out,stdout=stream,stderr=stream,env=env,startupinfo=startup,timeout=180)
    assert result.returncode==0 and 'CA469_PREFERENCES' in (profile/'latest.log').read_text(errors='replace')
    stored=ini.read_text(encoding='utf8')
    for field,value in [('Tab','togglemap'),('language','en'),('snd_musicvolume','0.25')]:
        assert re.search(r'(?im)^'+field+'='+re.escape(value)+r'\s*$',stored),(field,value)
    assert (profile/'preferences.png').exists()
    invalid=subprocess.run(restart+['-LoadSave','C:/invalid.zds'],cwd=out,capture_output=True,env=env,startupinfo=startup,timeout=30)
    (out/'invalid-path.txt').write_bytes(invalid.stdout+invalid.stderr)
    assert invalid.returncode!=0 and b'LoadSave must be a filename' in invalid.stderr
    report=dict(issue=469,passed=True,mode=a.mode,fresh_controls_verified=len(bindings),initial_master_volume=0.05,
        subsequent_bindings_language_music_volume_preserved=True,absolute_load_refused=True,
        original_command=command,restart_command=restart,commercial_iwad_loaded=False,author_acceptance=False)
    (out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report),flush=True)

if __name__=='__main__':main()
