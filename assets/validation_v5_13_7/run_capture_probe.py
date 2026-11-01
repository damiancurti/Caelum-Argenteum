"""Exercise standalone scoring, native respawn and rematch with four peers."""
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
    p.add_argument('--port',type=int,default=32546)
    p.add_argument('--scenario',choices=('match','overtime','drop'),default='match')
    p.add_argument('--venue',type=int,choices=(0,1),default=0)
    p.add_argument('--reload',type=Path)
    a=p.parse_args()
    a.runtime=a.runtime.resolve(strict=True);a.engine=a.engine.resolve(strict=True)
    out=ROOT/'build/issue600'/datetime.datetime.now().strftime(f'capture-{a.port}-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    iw=Path('C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base/doom2/DOOM2.WAD')
    addon=out/'checks.pk3'
    members=native_sync.instrument({'ZSCRIPT':b'version "4.14.2"\n#include "match_probe.zs"\n',
            'MAPINFO':b'gameinfo { AddEventHandlers="CA600MatchProbe" }\n',
            'match_probe.zs':Path(__file__).with_name(('drop_recovery_probe.zs' if a.scenario=='drop' else 'recovery_probe.zs') if a.reload else a.scenario+'_probe.zs').read_bytes()})
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
        for slot in range(4):
            selection=dict(role=min(slot,1),mode=2,preset=slot,players=4,port=a.port,venue=a.venue,
                           host='127.0.0.1',session=str(out/'peer0/session.json'))
            peer=out/f'peer{slot}';cmd,_=prepare(selection,peer,a.engine,iw,packages)
            if a.reload:
                (peer/'recovery.zds').write_bytes((a.reload/'peer0/midmatch.zds').read_bytes())
                if '+map' in cmd:at=cmd.index('+map');del cmd[at:at+2]
                # Native -loadgame resolves under -savedir; an absolute path
                # is prefixed again by this engine and cannot be recovered.
                cmd+=['-loadgame','recovery.zds']
                cmd[cmd.index('+ca_standalone_mode')+1]='0'
            with (peer/'game.ini').open('a') as f:f.write('vid_maxfps=60\nvid_defwidth=800\nvid_defheight=600\nlanguage='+('es' if slot==0 else 'enu')+'\n')
            with (peer/'controls.cfg').open('a') as f:
                f.write('wait 140; screenshot \"'+(peer/'objectives.png').as_posix()+'\"; wait 60; screenshot \"'+(peer/'death.png').as_posix()+'\"; ')
                if slot==0:f.write('save midmatch.zds \"CA600 in progress\"; ')
                f.write('wait '+('20' if a.scenario=='overtime' else '450')+'; screenshot \"'+(peer/'deathmatch.png').as_posix()+'\"; wait 10; ')
                if slot==0:f.write('save deathmatch.zds "CA600 persistence"; ')
                f.write(f'wait {100+(3-slot)*35}; quit\n')
            cmd+=['-window','-width','800','-height','600'];commands.append(cmd)
            stream=(peer/'process.log').open('wb');streams.append(stream)
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.4)
        print(out,flush=True);deadline=time.monotonic()+80
        while any(x.poll() is None for x in processes):
            if time.monotonic()>deadline:raise RuntimeError('Native match timeout')
            for slot in range(4):
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
        checks=[line for line in text.splitlines() if line.startswith('CA600 ')]
        errors=[line for line in text.splitlines() if any(mark in line for mark in (' FAIL ','Script error','VM execution aborted','Execution could not continue','out of sync','Out of sync'))]
        peers.append(dict(slot=slot,exit=process.returncode,checks=checks,errors=errors,synchronized=native_sync.clean(text),
                          passed=process.returncode==0 and not errors and native_sync.clean(text) and 'CA600 RESULT deathmatch' in text))
    report=dict(directory=str(out),runtime_sha256=digest(a.runtime),engine_sha256=digest(a.engine),commands=commands,
                scenario=a.scenario,venue=a.venue,reload=bool(a.reload),error=error,peers=peers,
                passed=not error and len(peers)==4 and all(x['passed'] for x in peers))
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ('directory','error','passed')},indent=2))
    for row in peers:print(row['slot'],row['exit'],row['errors'])
    return not report['passed']
if __name__=='__main__':raise SystemExit(main())
