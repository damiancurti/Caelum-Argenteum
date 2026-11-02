"""Exercise Major loadout and sequence through native clients and common save recovery."""
from pathlib import Path
import argparse, datetime, json, subprocess, sys, time, zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path[:0]=[str(ROOT),str(ROOT/'assets/validation_v5_12_7')]
import run_author_suite as author
from caelum_profiles import ProfileStore
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns
from caelum_sessions import Sessions,manifest,command,watch,digest


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--anchor',type=Path,required=True)
    p.add_argument('--engine',type=Path,required=True);p.add_argument('--reload',type=Path)
    p.add_argument('--port',type=int,default=32258);args=p.parse_args()
    for key in ('runtime','anchor','engine'):setattr(args,key,getattr(args,key).resolve(strict=True))
    out=ROOT/'build/issue440'/datetime.datetime.now().strftime(f'native-{args.port}-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    addon=out/'checks.pk3'
    if args.reload:
        previous=args.reload.resolve(strict=True);addon.write_bytes((previous/'checks.pk3').read_bytes())
        matching=[]
        for candidate in (previous/'bundle/peer0').glob('*.zds'):
            with zipfile.ZipFile(candidate) as saved:
                if json.loads(saved.read('info.json'))['Title']=='CA440 Temperance native lifecycle':matching.append(candidate)
        if len(matching)!=1:raise RuntimeError(f'Expected one completed-sequence save, found {len(matching)}')
        seed=matching[0]
    else:
        author.fixture(addon,args.anchor,-1)
        with zipfile.ZipFile(addon) as z:members={n:z.read(n) for n in z.namelist()}
        members.setdefault('ZSCRIPT',b'version "4.14.2"\n')
        members['ZSCRIPT']+=b'\n#include "temperance.zs"\n'
        members['MAPINFO']=members.get('MAPINFO',b'')+b'\ngameinfo { AddEventHandlers="CA440Probe" }\n'
        members['temperance.zs']=Path(__file__).with_name('temperance.zs').read_bytes()
        with zipfile.ZipFile(addon,'w') as z:
            for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
        seed=args.anchor
    packages=[args.runtime,addon]
    store=ProfileStore(previous/'profiles.sqlite3') if args.reload else ProfileStore(out/'profiles.sqlite3',create=True)
    schema=NativeSchema(args.engine.parent/'gzdoom.pk3',args.runtime)
    fixture_schema=NativeSchema(args.engine.parent/'gzdoom.pk3',addon)
    for key,value in fixture_schema.types.items():
        if key not in schema.types:schema.types[key]=value
    campaigns=Campaigns(store,PersonalGraph(schema))
    if not args.reload:campaigns.register('major-sequence',seed.read_bytes())
    sessions=Sessions(campaigns);token=out.name
    sessions.prepare('major-sequence',manifest(args.engine,author.IWAD,packages),token);sessions.export(token,out/'bundle')
    processes=[];streams=[];peers=[];commands=[];error=None
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    try:
        for slot in range(2):
            cmd,peer=command(out/'bundle',slot,args.engine,author.IWAD,packages,args.port,'127.0.0.1');peers.append(peer)
            with (peer/'session.ini').open('a') as f:f.write('vid_fullscreen=false\nvid_defwidth=800\nvid_defheight=600\nwin_w=816\nwin_h=639\nvid_maxfps=60\nvid_vsync=false\nlanguage=es\n')
            with (peer/'start.cfg').open('a') as f:
                # Keep both clients unpaused while the probe uses the native menu.
                # The probe saves after order, capacity, duration and lethal-payment checks.
                f.write(f'wait 150; screenshot sequence.png; wait {350+(2-slot)*35}; quit\n')
            cmd+=['-window','-width','800','-height','600'];commands.append(cmd)
            stream=(peer/'process.log').open('wb');streams.append(stream);sessions.claim(token,slot)
            process=subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream)
            processes.append(process);sessions.attach(token,slot,process.pid);time.sleep(.4)
        print(out,flush=True);deadline=time.monotonic()+100
        while any(x.poll() is None for x in processes):
            if time.monotonic()>deadline:raise RuntimeError('Bounded native UI timeout')
            if any(any(mark in (peer/'engine.log').read_text(errors='replace') for mark in ('Execution could not continue','Script error,')) for peer in peers if (peer/'engine.log').exists()):raise RuntimeError('Native error; full logs retained')
            time.sleep(.25)
    except (OSError,RuntimeError) as exc:error=str(exc)
    finally:
        for process in processes:
            if process.poll() is None:process.terminate()
        for process in processes:process.wait(timeout=15)
        for stream in streams:stream.close()
    reports=[]
    for slot,(process,peer) in enumerate(zip(processes,peers)):
        log=(peer/'engine.log').read_text(errors='replace') if (peer/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(mark in line for mark in (' FAIL ','Execution could not continue','VM execution aborted','Script error','CA_SESSION REJECT','out of sync'))]
        marker='CA440T RESULT reload' if args.reload else 'CA440T RESULT capture'
        reports.append(dict(slot=slot,exit=process.returncode,errors=errors,checks=[l for l in log.splitlines() if l.startswith('CA440T ')],passed=process.returncode==0 and not errors and author.native_sync.clean(log) and 'CA_SESSION READY' in log and marker in log))
        sessions.finished(token,slot)
    watch(processes[0],peers[0],sessions,token,0);sessions.close(token);store.close()
    result=dict(directory=str(out),runtime_sha256=digest(args.runtime),engine_sha256=digest(args.engine),commands=commands,error=error,peers=reports,passed=not error and all(r['passed'] for r in reports))
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(directory=str(out),error=error,passed=result['passed'],peers=[dict(slot=r['slot'],exit=r['exit'],checks=len(r['checks']),errors=r['errors'],passed=r['passed']) for r in reports]),indent=2));raise SystemExit(not result['passed'])

if __name__=='__main__':main()
