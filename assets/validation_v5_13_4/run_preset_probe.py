"""Start two real native peers through the match launcher and check presets."""
import argparse,datetime,json,subprocess,sys,time,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
sys.path.insert(0,str(ROOT/'assets/validation_v5_12_7'))
import native_sync
from caelum_standalone import prepare
from caelum_sessions import digest

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--engine',type=Path,required=True)
    p.add_argument('--first',type=int,choices=(0,2),default=0);p.add_argument('--port',type=int,default=32480)
    p.add_argument('--reload',type=Path)
    p.add_argument('--campaign-control',action='store_true',help='Omit match activation and check the ordinary campaign profile.')
    a=p.parse_args()
    a.runtime=a.runtime.resolve(strict=True);a.engine=a.engine.resolve(strict=True)
    out=ROOT/'build/issue597'/datetime.datetime.now().strftime(f'presets-{a.port}-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    iw=Path('C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base/doom2/DOOM2.WAD')
    addon=out/'checks.pk3'
    members=native_sync.instrument({'ZSCRIPT':b'version "4.14.2"\n#include "preset_probe.zs"\n',
            'MAPINFO':b'gameinfo { AddEventHandlers="CA597PresetProbe" }\n',
            'preset_probe.zs':Path(__file__).with_name('campaign_probe.zs' if a.campaign_control else 'preset_probe.zs').read_bytes()})
    with zipfile.ZipFile(addon,'w') as z:
        for name,data in members.items():
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    packages=[a.runtime,addon]
    base=[str(a.engine),'-noautoload','-iwad',str(iw),'-file',*map(str,packages)]
    r=subprocess.run(base+['-norun','-nosound','-errorlog',str(out/'compile.log'),'-config',str(out/'compile.ini')],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
    (out/'compile-process.log').write_bytes(r.stdout)
    if r.returncode!=1337:
        print(out)
        lines=(out/'compile.log').read_text(errors='replace').splitlines()
        start=next((i for i,line in enumerate(lines) if 'LoadActors:' in line),0)
        print('\n'.join(line for line in lines[start:] if not line.startswith('Vulkan extensions:')))
        return 1
    processes=[];streams=[];commands=[];error=None
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    try:
        for slot in range(2):
            selection=dict(role=slot,mode=0,preset=a.first+slot,players=2,port=a.port,venue=0,
                           host='127.0.0.1',session=str(out/'peer0/session.json'))
            peer=out/f'peer{slot}';cmd,_=prepare(selection,peer,a.engine,iw,packages)
            if a.campaign_control:
                cmd.remove(str(peer/'standalone.pk3'))
                cmd[cmd.index('+ca_standalone_mode')+1]='0'
            if a.reload:
                (peer/'recovery.zds').write_bytes((a.reload/'peer0/presets.zds').read_bytes())
                if '+map' in cmd:at=cmd.index('+map');del cmd[at:at+2]
                # Native -loadgame resolves under -savedir; an absolute path
                # is prefixed again by this engine and cannot be recovered.
                cmd+=['-loadgame','recovery.zds']
            with (peer/'game.ini').open('a') as f:f.write('vid_maxfps=60\nvid_defwidth=800\nvid_defheight=600\nlanguage=es\n')
            with (peer/'controls.cfg').open('a') as f:
                f.write('wait 250; screenshot presets.png; wait 80; ')
                if slot==0:f.write('save presets.zds "CA597 preset persistence"; ')
                f.write(f'wait {100+(1-slot)*35}; quit\n')
            cmd+=['-window','-width','800','-height','600'];commands.append(cmd)
            stream=(peer/'process.log').open('wb');streams.append(stream)
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.4)
        print(out,flush=True);deadline=time.monotonic()+80
        while any(x.poll() is None for x in processes):
            if time.monotonic()>deadline:raise RuntimeError('Native match timeout')
            for slot in range(2):
                path=out/f'peer{slot}/engine.log'
                text=path.read_text(errors='replace') if path.exists() else ''
                if 'Execution could not continue' in text or 'VM execution aborted' in text:raise RuntimeError('Native error; logs retained')
            time.sleep(.3)
    except (OSError,RuntimeError) as exc:error=str(exc)
    finally:
        for process in processes:
            if process.poll() is None:process.terminate()
        for process in processes:process.wait(timeout=15)
        for stream in streams:stream.close()
    peers=[]
    for slot,process in enumerate(processes):
        path=out/f'peer{slot}/engine.log';text=path.read_text(errors='replace') if path.exists() else ''
        checks=[line for line in text.splitlines() if line.startswith('CA597P ')]
        errors=[line for line in text.splitlines() if any(mark in line for mark in (' FAIL ','Script error','VM execution aborted','Execution could not continue','out of sync','Out of sync'))]
        peers.append(dict(slot=slot,exit=process.returncode,checks=checks,errors=errors,synchronized=native_sync.clean(text),
                          passed=process.returncode==0 and not errors and native_sync.clean(text) and 'CA597P RESULT presets' in text))
    report=dict(directory=str(out),runtime_sha256=digest(a.runtime),engine_sha256=digest(a.engine),commands=commands,
                first=a.first,reload=bool(a.reload),campaign_control=a.campaign_control,error=error,peers=peers,
                passed=not error and len(peers)==2 and all(x['passed'] for x in peers))
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ('directory','error','passed')},indent=2))
    for row in peers:print(row['slot'],row['exit'],row['errors'])
    return not report['passed']
if __name__=='__main__':raise SystemExit(main())
