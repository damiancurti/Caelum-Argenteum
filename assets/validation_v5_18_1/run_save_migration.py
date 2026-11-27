"""Prove copy-only save migration, native reload/hub return and development rollback."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from migrate_standalone_save import migrate

ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
DEV_IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def native(folder,package,fixture,independent):
    (folder/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nwin_w=1296\nwin_h=759\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\n',encoding='utf8')
    mode=int(independent)
    (folder/'commands.cfg').write_text(f'wait 105; netevent ca467_save 2 {mode}; wait 3; save loaded; wait 8; changemap MAP01; wait 105; netevent ca467_save 1 {mode}; wait 3; save hub; wait 8; event ca467_save_done; wait 3; quit\n')
    command=[str(ENGINE),'-noautoload','-iwad',str(package if independent else DEV_IWAD),'-file']+([] if independent else [str(package)])+[str(fixture),'-config',str(folder/'session.ini'),'-savedir',str(folder),'-window','-loadgame','converted.zds','+logfile',str(folder/'native.log'),'+exec',str(folder/'commands.cfg')]
    (folder/'command.json').write_text(json.dumps(command,indent=2)+'\n')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=4
    with (folder/'stdout.txt').open('wb') as stream:
        process=subprocess.Popen(command,cwd=folder,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+240
        while process.poll() is None:
            log=(folder/'stdout.txt').read_text(errors='replace')
            if any(s in log for s in ['errors while parsing scripts','Execution could not continue','VM execution aborted','Failed to restore all objects in savegame','Failed to load savegame']) or time.monotonic()>deadline:
                process.terminate();process.wait(timeout=10);break
            time.sleep(1)
    log=(folder/'native.log').read_text(errors='replace') if (folder/'native.log').exists() else (folder/'stdout.txt').read_text(errors='replace')
    passed=len(re.findall(r'CA467SAVE PASS ',log));failures=re.findall(r'CA467SAVE FAIL (.*)',log)
    result={'exit':process.returncode,'passed_checks':passed,'failures':failures,'completed':'CA467SAVE COMPLETE' in log,
        'saved_after_load':(folder/'loaded.zds').exists(),'saved_after_hub_return':(folder/'hub.zds').exists(),
        'commercial_iwad_loaded':bool(re.search(r'adding .*[/\\]DOOM2\.WAD',log,re.I))}
    (folder/'SUMMARY.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
    if process.returncode or failures or passed!=10 or not result['completed'] or not result['saved_after_load'] or not result['saved_after_hub_return'] or result['commercial_iwad_loaded']==independent:raise RuntimeError('Native migration phase failed: '+str(folder))
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package',type=Path,required=True)
    parser.add_argument('--source-save',type=Path,default=ROOT/'build/issue464-native03/maps/music.zds')
    parser.add_argument('--source-package',type=Path,default=ROOT/'build/issue460-review02.pk3')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    package=args.package.resolve(strict=True);old=args.source_package.resolve(strict=True);saved=args.source_save.resolve(strict=True);original_hash=sha(saved)
    with zipfile.ZipFile(saved) as z:
        data=json.loads(z.read('map02.map.json'));body=data['objects'][data['players'][0]['mo']]
        profile=data['objects'][body['class:CaelumPlayer']['CharacterProfile']]['class:CaelumCharacterProfile']
        profile={k.lower():v for k,v in profile.items()}
    expression=' && '.join(f'profile.{field}=={int(profile.get(field.lower(),0))}' for field in ['Race','Sex','FirstClass','SecondClass','HeightChoice'])
    original_probe=(ROOT/'assets/validation_v5_17_125/audio_probe.zs').read_text(encoding='utf8')
    original_actor=original_probe[:original_probe.index('class CA464Probe')]
    script=original_actor+'''class CA467SaveProbe : StaticEventHandler
    {
        static clearscope void Check(bool okay,String label){Console.Printf("CA467SAVE %s %s",okay?"PASS":"FAIL",label);}
        override void ConsoleProcess(ConsoleEvent e){if(e.Name=='ca467_save_done')Console.Printf("CA467SAVE COMPLETE");}
        override void NetworkProcess(ConsoleEvent e)
        {
            if(e.Name!='ca467_save')return;
            let user=CaelumPlayer(players[e.Player].mo);Check(user!=null,"saved project player restored");if(user==null)return;
            let profile=CaelumCharacterIdentity.Profile(user);
            Check(profile!=null && EXPRESSION,"saved character identity retained");
            if(profile==null)return;
            Check(level.MapName~==(e.Args[0]==1?"MAP01":"MAP02"),"active map or stored hub restored");
            Name voice=e.Args[1]==1?(profile.Sex==CaelumConstants.SEX_FEMALE?'caelum_female':'caelum_male'):'player';
            Check(user.SoundClass==voice,"correct target native voice class");
            Check(user.FindInventory('Pistol')==null && user.FindInventory('Fist')==null,"owned starting inventory retained");
        }
    }
    '''.replace('EXPRESSION',expression)
    fixture=out/'checks.pk3'
    with zipfile.ZipFile(fixture,'x') as z:
        for name,blob in {'ZSCRIPT':b'version "4.14.2"\n#include "save_probe.zs"\n','save_probe.zs':script.encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA467SaveProbe" }\n'}.items():z.writestr(zipfile.ZipInfo(name,(2026,11,26,0,0,0)),blob)
    forward=out/'forward';forward.mkdir()
    first=migrate(saved,forward/'converted.zds',old,package)
    second=migrate(forward/'converted.zds',out/'idempotent.zds',package,package)
    assert sha(forward/'converted.zds')==sha(out/'idempotent.zds')
    with zipfile.ZipFile(saved) as before,zipfile.ZipFile(forward/'converted.zds') as after:
        assert all(before.read(n)==after.read(n) for n in before.namelist() if n!='info.json')
    forward_native=native(forward,package,fixture,True)
    reverse=out/'rollback';reverse.mkdir()
    rollback=migrate(forward/'loaded.zds',reverse/'converted.zds',package,old,'DOOM2.WAD')
    reverse_native=native(reverse,old,fixture,False)
    repeated=migrate(reverse/'converted.zds',out/'rollback-idempotent.zds',old,old,'DOOM2.WAD')
    assert sha(reverse/'converted.zds')==sha(out/'rollback-idempotent.zds')
    mismatched=out/'mismatched.pk3'
    with zipfile.ZipFile(package) as source,zipfile.ZipFile(mismatched,'x') as target:
        for name in ['maps/MAP01.wad','maps/MAP02.wad']:target.writestr(name,source.read(name)+(b'audit-only mismatch' if 'MAP02' in name else b''))
    try:migrate(saved,out/'must-not-exist.zds',old,mismatched)
    except ValueError as exc:assert 'Map layout differs' in str(exc)
    else:raise AssertionError('Mismatched layout was not rejected')
    assert not (out/'must-not-exist.zds').exists()
    try:migrate(saved,saved,old,package)
    except ValueError as exc:assert 'destination' in str(exc)
    else:raise AssertionError('Source overwrite was not rejected')
    assert sha(saved)==original_hash
    report={'issue':467,'migration_revision':1,'forward':first,'forward_native':forward_native,'rollback':rollback,'rollback_native':reverse_native,
        'forward_map_payloads_unchanged':True,'forward_idempotent_bytes':True,'rollback_idempotent_bytes':True,
        'mismatched_layout_rejected':True,'source_overwrite_rejected':True,'original_preserved':True,
        'limits':'This verifies identical MAP01/MAP02 geometry and prior #460 runtime rollback; other historical layouts require their matching compatibility packages.'}
    (out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n');print('Forward migration, stored hub, rollback and copy guards passed.',flush=True)


if __name__=='__main__':main()
