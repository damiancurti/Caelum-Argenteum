"""Probe missing game resources without loading a commercial IWAD.

The grayscale palette and episode exist only in this disposable diagnostic.
They are not distributable artwork or a production standalone implementation.
"""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,default=ROOT/'build/issue465-review01.pk3')
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    with zipfile.ZipFile(runtime) as package:
        if package.testzip() is not None:raise SystemExit('Runtime package failed CRC validation')
    runtime_hash=hashlib.sha256(runtime.read_bytes()).hexdigest()
    out=args.output.resolve();out.relative_to(ROOT/'build')
    out.mkdir(parents=True,exist_ok=False)
    inventory=json.loads((ROOT/'assets/distribution/INVENTORY.json').read_text(encoding='utf8'))
    textures=sorted(set(inventory['map_texture_references'])|{'PUFFA0','PUFFB0','PUFFC0','PUFFD0','BLUDA0','BLUDB0','BLUDC0','M_EPISOD','M_NEWG','M_SKILL'})
    calls='\n'.join(f'ProbeTexture("{name}");' for name in textures)
    script='''class CA466Probe : StaticEventHandler
    {
        ui void ProbeTexture(String name)
        {Console.Printf("CA466 TEXTURE %s %d",name,TexMan.CheckForTexture(name,TexMan.Type_Any).isValid());}
        override void ConsoleProcess(ConsoleEvent e)
        {
            if(e.Name!='ca466_probe')return;
            CALLS
            let player=GetDefaultByType("CaelumPlayer");
            let npc=GetDefaultByType("CaelumCombatActor");
            Console.Printf("CA466 BLOOD player %s %s %s",player.BloodType,player.BloodType2,player.BloodType3);
            Console.Printf("CA466 BLOOD combat %s %s %s",npc.BloodType,npc.BloodType2,npc.BloodType3);
            Console.Printf("CA466 COMPLETE");
        }
    }
    '''.replace('CALLS',calls)
    bootstrap={'IWADINFO':b'IWAD { Name="Caelum Argenteum dependency audit" Game="Doom" Config="CaelumArgenteumAudit" }\n',
        'PLAYPAL':bytes(c for i in range(256) for c in (i,i,i)),
        'MAPINFO':b'episode MAP01 { name="Caelum Argenteum dependency probe" }\n'}
    fixture={'ZSCRIPT':b'version "4.14.2"\n#include "probe.zs"\n','probe.zs':script.encode(),
        'MAPINFO':b'gameinfo { AddEventHandlers="CA466Probe" }\n'}
    for filename,members in [('probe.ipk3',bootstrap),('checks.pk3',fixture)]:
        with zipfile.ZipFile(out/filename,'w') as z:
            for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,26,0,0,0)),blob)
    (out/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nwin_w=1296\nwin_h=759\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\n',encoding='utf8')
    (out/'commands.cfg').write_text('wait 105; event ca466_probe; wait 3; quit\n')
    command=[str(ENGINE),'-noautoload','-iwad',str(out/'probe.ipk3'),'-file',str(runtime),str(out/'checks.pk3'),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/'native.log'),'+exec',str(out/'commands.cfg')]
    (out/'command.json').write_text(json.dumps(command,indent=2)+'\n')
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=4
    with (out/'stdout.txt').open('wb') as stream:
        process=subprocess.Popen(command,cwd=out,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+90
        while process.poll() is None:
            log=(out/'stdout.txt').read_text(errors='replace')
            if any(s in log for s in ['errors while parsing scripts','Execution could not continue','VM execution aborted']) or time.monotonic()>deadline:
                process.terminate();process.wait(timeout=10);break
            time.sleep(1)
    log=(out/'native.log').read_text(errors='replace') if (out/'native.log').exists() else (out/'stdout.txt').read_text(errors='replace')
    found=dict((name,bool(int(valid))) for name,valid in re.findall(r'CA466 TEXTURE (\S+) ([01])',log))
    report={'issue':466,'runtime_sha256':runtime_hash,
        'runtime_unchanged':hashlib.sha256(runtime.read_bytes()).hexdigest()==runtime_hash,
        'exit':process.returncode,'completed':process.returncode==0 and 'CA466 COMPLETE' in log,
        'texture_results':found,'missing_textures':[name for name,valid in found.items() if not valid],
        'blood_defaults':re.findall(r'CA466 BLOOD (\S+) (\S+) (\S+) (\S+)',log),
        'commercial_iwad_loaded':bool(re.search(r'adding .*[/\\](?:DOOM2?\.WAD|id24res\.wad)',log,re.I)),
        'scope':'Diagnostic bootstrap only; missing resources are findings, not resolved production behavior.'}
    (out/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report),flush=True)
    if not report['completed'] or not report['runtime_unchanged'] or report['commercial_iwad_loaded'] or len(found)!=len(textures):raise SystemExit(1)


if __name__=='__main__':main()
