"""Check private ceiling save/reload, stored-city return and fresh default restoration."""
from pathlib import Path
import argparse, importlib.util, json, shutil, subprocess, sys, time, zipfile

ROOT=Path(__file__).resolve().parents[2]
FATAL=['Script error','Execution could not continue','Cannot find savegame','VM execution aborted','CA866 FAIL','CA883 SURFACE FAIL','CA454 HOUSE FAIL','CA454 HOUSE USE FAIL','CA454 HOUSE RETURN FAIL']


def run(folder,command,expected,uses,returns,checks,save_name):
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
    process_text=(folder/'process.log').read_text(encoding='utf-8',errors='replace')
    errors=[marker for marker in FATAL if marker in text or marker in process_text]
    row=dict(phase=folder.name,command=command,exit_code=process.returncode,timed_out=timed_out,errors=errors,
             surface_passes=text.count(f'CA883 SURFACE PASS candidate={expected} '),
             real_house_uses=text.count('CA454 HOUSE USE PASS'),exact_house_returns=text.count('CA454 HOUSE RETURN PASS'),
             checkpoint_exists=(folder/(save_name+'.zds')).is_file())
    row['passed']=process.returncode==0 and not timed_out and not errors and row['surface_passes']==checks and row['real_house_uses']==uses and row['exact_house_returns']==returns and row['checkpoint_exists'] and 'CA883_PERSISTENCE_COMPLETE' in text
    (folder/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:row[k] for k in ['phase','passed','surface_passes','errors']}),flush=True)
    return row


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','overlay-directory','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args()
    assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads((args.overlay_directory/'MANIFEST.json').read_text(encoding='utf-8'))
    spec=importlib.util.spec_from_file_location('ceiling_surface_checks',Path(__file__).with_name('run_views.py'))
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    city='\nclass CA883CityAudit : EventHandler {\n'+module.surface_probe(manifest,'MAP03')+'\n override void NetworkProcess(ConsoleEvent e) {if(e.Name=="ca883_citycheck"){if(level.MapName!="MAP03"){Console.Printf("CA883 SURFACE FAIL map");return;}CheckSurfaces();}}\n}\n'
    runs=[];fresh=None
    for phase in ['candidate_fresh','candidate_reload','default_restored']:
        folder=out/phase
        if phase!='candidate_reload':
            variant='control' if phase=='default_restored' else 'vaults'
            subprocess.run([sys.executable,str(Path(__file__).with_name('run_review.py')),'--runtime',str(args.runtime.resolve()),'--overlay-directory',str(args.overlay_directory.resolve()),'--scene','house','--variant',variant,'--output',str(folder),'--prepare-only'],cwd=ROOT,check=True)
            session=json.loads((folder/'review-session.json').read_text(encoding='utf-8'))
            original=folder/'review.pk3'
            with zipfile.ZipFile(original) as archive:members={n:archive.read(n) for n in archive.namelist()}
            source=members['probe.zs'].decode('utf-8');assert 'override void UiTick()' not in source
            members['probe.zs']=(source+city).encode('utf-8')
            old=b'"CA454HouseUseProbe"';assert members['MAPINFO'].count(old)==1
            members['MAPINFO']=members['MAPINFO'].replace(old,old+b',"CA883CityAudit"')
            fixture=folder/'persistence.pk3'
            with zipfile.ZipFile(fixture,'x') as archive:
                for name,value in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value)
            (folder/'probe.zs').write_bytes(members['probe.zs'])
            command=[str(fixture) if item==str(original) else item for item in session['command']]
            commands=[(folder/'start.cfg').read_text(encoding='utf-8').strip()]
            if phase=='candidate_fresh':
                fresh=(folder,command);save_name='inside';uses=1;returns=0;checks=1
            else:
                commands+=['wait 5','netevent ca454_house_inside 0','wait 140','netevent ca454_house_back 0','netevent ca883_citycheck']
                save_name='restored';uses=2;returns=1;checks=2
        else:
            folder.mkdir();source_folder,previous=fresh
            shutil.copyfile(source_folder/'review.ini',folder/'review.ini')
            # GZDoom resolves -loadgame against -savedir. Keep the exact save
            # bytes in this isolated phase and pass only its local filename.
            shutil.copyfile(source_folder/'inside.zds',folder/'inside.zds')
            assert (source_folder/'inside.zds').read_bytes()==(folder/'inside.zds').read_bytes()
            command=previous[:previous.index('+map')]
            for flag,value in [('-config',folder/'review.ini'),('-savedir',folder),('+logfile',folder/'engine.log')]:command[command.index(flag)+1]=str(value)
            command+=['-loadgame','inside.zds','+exec',str(folder/'start.cfg')]
            commands=['wait 140','netevent ca866_next','wait 5','netevent ca454_house_inside 0','wait 140','netevent ca454_house_back 0','netevent ca883_citycheck']
            save_name='returned';uses=1;returns=1;checks=2
        commands += ['save '+save_name,'wait 10','echo CA883_PERSISTENCE_COMPLETE','quit']
        (folder/'start.cfg').write_text('; '.join(commands)+'\n',encoding='utf-8',newline='\n')
        command+=['-nomouse','-rngseed','428']
        row=run(folder,command,int(phase!='default_restored'),uses,returns,checks,save_name);runs.append(row)
        if not row['passed']:break
    report=dict(issue=883,runs=runs,passed=len(runs)==3 and all(r['passed'] for r in runs),qualification=__doc__,author_acceptance=False,
                save_scope='Candidate reload uses the exact same fixture/runtime/overlay and retained map state. Default restoration starts fresh after removing the overlay; no candidate-save conversion or campaign-save import is attempted.')
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    raise SystemExit(not report['passed'])


if __name__=='__main__':main()
