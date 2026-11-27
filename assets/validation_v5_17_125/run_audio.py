"""Verify retained beta music/cues in the native engine with disposable profiles."""
import argparse
import hashlib
import json
import re
import shutil
import subprocess
import time
import zipfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,default=ROOT/'build/issue460-review02.pk3')
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--only',help='Comma-separated phase names')
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    assert not subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace').lower().startswith('"gzdoom.exe"')
    fixture=out/'audio.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,blob in {'ZSCRIPT':b'version "4.14.2"\n#include "probe.zs"\n',
                          'probe.zs':Path(__file__).with_name('audio_probe.zs').read_bytes(),
                          'MAPINFO':b'gameinfo { AddEventHandlers="CA464Probe" }\n'}.items():
            archive.writestr(zipfile.ZipInfo(name,(2026,11,26,0,0,0)),blob)
    setup='wait 105; event ca464_close; netevent ca464_setup; wait 5; '
    cue_checks=''.join(f'netevent ca464_cue {i}; wait 5; ' for i in range(9))+'netevent ca464_stop; '
    plans=[
        ('title',None,'wait 140; event ca464_music -1 1000; ',None),
        ('maps','MAP01',setup+'event ca464_music 0 1000; snd_musicvolume .37; wait 5; event ca464_music 0 370; '+cue_checks+
            'netevent ca464_dialogue; wait 10; event ca464_dialogue_check 1; event ca464_music 0 370; screenshot dialogue.png; wait 1; event ca464_close; wait 10; event ca464_dialogue_check 0; event ca464_music 0 370; '+
            'changemap MAP02; wait 105; event ca464_music 1 370; netevent ca464_breath 1; wait 5; save music; wait 5; '+
            'changemap MAP03; wait 105; event ca464_music 2 370; changemap MAP01; wait 105; event ca464_music 0 370; ',None),
        ('reload',None,'wait 5; event ca464_music 1 370; netevent ca464_loaded_breath; netevent ca464_breath 0; wait 5; snd_musicvolume 0; event ca464_music 1 0; wait 5; snd_musicvolume .37; event ca464_music 1 370; ','maps/music.zds')]
    if args.only:plans=[p for p in plans if p[0] in args.only.split(',')]
    report={'issue':464,'runtime':str(args.runtime),'runtime_sha256':digest(args.runtime),'fixture_sha256':digest(fixture),'phases':[]}
    for label,map_name,script,save in plans:
        case=out/label;case.mkdir()
        (case/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nsnd_musicvolume='+('0.37' if save else '1')+'\nvid_maxfps=60\nlanguage=en\n',encoding='utf-8')
        (case/'commands.cfg').write_text(script+'wait 5; event ca464_done; wait 5; quit\n')
        entry=['+map',map_name] if map_name else []
        if save:
            source=out/save;target=case/'music.zds';shutil.copyfile(source,target);assert digest(source)==digest(target);entry=['-loadgame',target.name]
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(args.runtime.resolve()),str(fixture),'-config',str(case/'session.ini'),'-savedir',str(case),'-window','-width','1280','-height','720','+logfile',str(case/'native.log'),*entry,'+exec',str(case/'commands.cfg')]
        (case/'command.json').write_text(json.dumps(command,indent=2)+'\n')
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=4
        with (case/'stdout.txt').open('wb') as stream:
            process=subprocess.Popen(command,cwd=case,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+240
            while process.poll() is None:
                output=(case/'stdout.txt').read_text(errors='replace')
                if any(s in output for s in ['Script error','Execution could not continue','Object expected']) or time.monotonic()>deadline:
                    process.terminate();process.wait(timeout=10);break
                time.sleep(1)
        log=(case/'native.log').read_text(errors='replace')
        results=re.findall(r'CA464 RESULT passed=(\d+) failed=(\d+)',log)
        okay=process.returncode==0 and bool(results) and all(int(b)==0 for _,b in results)
        phase={'name':label,'passed':okay,'exit':process.returncode,'counts':results,'music':re.findall(r'CA464 MUSIC ([^\n]+)',log)}
        report['phases'].append(phase);(out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(phase),flush=True)
        if not okay:raise SystemExit('Inspect '+str(case/'native.log'))

if __name__=='__main__':main()
