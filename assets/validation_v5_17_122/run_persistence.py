"""Check same-option waterline saves and fresh default restoration.

Only disposable saves created here are read. The reload receives a local save
basename after an exact byte copy; no visited campaign map is converted.
"""
from pathlib import Path
import argparse, hashlib, json, re, shutil, subprocess, sys, time, zipfile

ROOT=Path(__file__).resolve().parents[2]
FATAL=['Script error','Execution could not continue','Cannot find savegame','VM execution aborted','CA866 FAIL','CA887 SURFACE FAIL','Unexpected JIT error']
SHA=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()


def run(folder,command,candidate,expected_views,save_name):
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    timed_out=False
    with (folder/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=folder,startupinfo=startup,stdout=stream,stderr=stream)
        deadline=time.monotonic()+180
        while process.poll() is None:
            path=folder/'engine.log';text=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''
            if any(marker in text for marker in FATAL):break
            if time.monotonic()>deadline:timed_out=True;break
            time.sleep(.25)
        if process.poll() is None:process.terminate();process.wait(timeout=10)
    log=folder/'engine.log'
    text=log.read_text(encoding='utf-8',errors='replace') if log.exists() else ''
    diagnostic=text+(folder/'process.log').read_text(encoding='utf-8',errors='replace')
    errors=[marker for marker in FATAL if marker in diagnostic]
    views=list(map(int,re.findall(r'CA866 VIEW (\d+) ',text)))
    row=dict(phase=folder.name,command=command,exit_code=process.returncode,timed_out=timed_out,errors=errors,
        surface_passes=text.count(f'CA887 SURFACE PASS candidate={int(candidate)} default={int(not candidate)} '),
        views=views,checkpoint_exists=(folder/(save_name+'.zds')).is_file())
    row['passed']=(process.returncode==0 and not timed_out and not errors and row['surface_passes']==len(expected_views)
        and views==expected_views and row['checkpoint_exists'] and 'CA887_PERSISTENCE_COMPLETE' in text)
    (folder/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:row[k] for k in ['phase','passed','surface_passes','views','errors']}),flush=True)
    return row


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','control-overlay','overlay','manifest','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args()
    active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace')
    assert 'gzdoom.exe' not in active.lower()
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    runs=[];fresh=None;copy_record=None
    for phase in ['candidate_fresh','candidate_reload','default_restored']:
        folder=out/phase
        if phase!='candidate_reload':
            prepare=[sys.executable,str(Path(__file__).with_name('run_review.py'))]
            for name in ['runtime','control_overlay','overlay','manifest']:
                prepare+=['--'+name.replace('_','-'),str(getattr(args,name).resolve())]
            prepare+=['--variant','default' if phase=='default_restored' else 'candidate','--output',str(folder),'--prepare-only']
            subprocess.run(prepare,cwd=ROOT,check=True)
            session=json.loads((folder/'review-session.json').read_text(encoding='utf-8'))
            command=session['command'];commands=[(folder/'start.cfg').read_text(encoding='utf-8').strip()]
            view=next(i for i,r in enumerate(session['cameras']) if r['name']=='waterline_horizontal')
            commands+=['wait 5; netevent ca866_next']*view
            expected_views=list(range(view+1));save_name='inside' if phase=='candidate_fresh' else 'restored'
            with zipfile.ZipFile(folder/'review.pk3') as archive:
                (folder/'probe.zs').write_bytes(archive.read('probe.zs'))
            if phase=='candidate_fresh':fresh=(folder,command,view+1)
        else:
            folder.mkdir();source,previous,next_view=fresh
            shutil.copyfile(source/'review.ini',folder/'review.ini')
            shutil.copyfile(source/'inside.zds',folder/'inside.zds')
            assert (source/'inside.zds').read_bytes()==(folder/'inside.zds').read_bytes()
            copy_record=dict(original_sha256=SHA(source/'inside.zds'),copy_sha256=SHA(folder/'inside.zds'),byte_identical=True)
            command=previous[:previous.index('+map')]
            for flag,value in [('-config',folder/'review.ini'),('-savedir',folder),('+logfile',folder/'engine.log')]:
                command[command.index(flag)+1]=str(value)
            command+=['-loadgame','inside.zds','+exec',str(folder/'start.cfg')]
            commands=['wait 140','netevent ca866_next'];expected_views=[next_view];save_name='reloaded'
        commands+=['save '+save_name,'wait 10','echo CA887_PERSISTENCE_COMPLETE','quit']
        (folder/'start.cfg').write_text('; '.join(commands)+'\n',encoding='utf-8',newline='\n')
        command=[*command,'-nomouse','-rngseed','428']
        row=run(folder,command,phase!='default_restored',expected_views,save_name);runs.append(row)
        if not row['passed']:break
    report=dict(issue=887,runs=runs,passed=len(runs)==3 and all(r['passed'] for r in runs),
        save_copy=copy_record,qualification=__doc__,author_acceptance=False,
        save_scope='Exact same fixture/runtime/overlay on reload. Default restoration is a new session without overlays; no campaign-save import or conversion.')
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    raise SystemExit(not report['passed'])


if __name__=='__main__':main()
