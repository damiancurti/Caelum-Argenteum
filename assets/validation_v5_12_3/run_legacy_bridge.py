"""Reload retained lifecycle saves with and without the old per-level registration."""
from pathlib import Path
import argparse, datetime, hashlib, json, subprocess, time, zipfile
import run_lifecycle_probe as fixture


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--source',type=Path,required=True)
    parser.add_argument('--without-handler',action='store_true')
    parser.add_argument('--port',type=int,default=30360)
    args=parser.parse_args()
    out=fixture.ROOT/'build/issue437'/datetime.datetime.now().strftime('bridge-%Y%m%d-%H%M%S-%f');out.mkdir()
    original=args.source.resolve(strict=True).read_bytes()
    with zipfile.ZipFile(args.source) as z: members={n:z.read(n) for n in z.namelist()}
    if args.without_handler:
        # A copied, deliberately unregistered handler reproduces pre-addition
        # dispatch. Keep all object indices, native field types and original bytes.
        for name,data in list(members.items()):
            if not name.endswith('.map.json'):continue
            level=json.loads(data)
            for index,obj in enumerate(level['objects']):
                if obj.get('classtype')!='CaelumSessionLifecycle':continue
                before,after=obj.get('prev'),obj.get('next')
                if before is not None:level['objects'][before]['next']=after
                if after is not None:level['objects'][after]['prev']=before
                if level.get('firstevent')==index:level['firstevent']=after
                if level.get('lastevent')==index:level['lastevent']=before
                obj['prev']=obj['next']=None
            members[name]=json.dumps(level,separators=(',',':')).encode()
    fixture.fixture(out/'geometry.pk3',2)
    with zipfile.ZipFile(out/'geometry.pk3') as z,zipfile.ZipFile(out/'checks.pk3','w') as target:
        for n in z.namelist():
            data=z.read(n)
            if n=='MAPINFO':data=b'gameinfo { AddEventHandlers="CA437LegacyBridgeProbe" }\n'
            if n=='ZSCRIPT':data+=b'#include "bridge.zs"\n'
            target.writestr(n,data)
        target.writestr('bridge.zs',(Path(__file__).parent/'legacy_bridge_probe.zs').read_bytes())
    processes=[];streams=[];commands=[]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    try:
        for i in range(2):
            peer=out/f'peer{i}';peer.mkdir()
            with zipfile.ZipFile(peer/'recovery.zds','w',compression=zipfile.ZIP_DEFLATED) as z:
                for n,data in members.items():z.writestr(n,data)
            (peer/'isolated.ini').write_text('[GlobalSettings]\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\nvid_maxfps=60\n')
            (peer/'test.cfg').write_text('wait 105; +use; wait 105; -use; wait 105; quit\n' if i else 'wait 385; quit\n')
            network=['-host','2','-port',str(args.port),'-netmode','0'] if not i else ['-join',f'127.0.0.1:{args.port}','-port',str(args.port+1)]
            cmd=[str(fixture.ENGINE),'-noautoload','-iwad',str(fixture.IWAD),'-file',str(args.runtime.resolve()),str(out/'checks.pk3'),'-config',str(peer/'isolated.ini'),'-savedir',str(peer),'-window','-width','640','-height','480',*network,'+logfile',str(peer/'engine.log'),'-loadgame','recovery.zds','+exec',str(peer/'test.cfg')]
            commands.append(cmd);stream=(peer/'process.log').open('wb');streams.append(stream)
            processes.append(subprocess.Popen(cmd,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream));time.sleep(.3)
        print('Started native legacy bridge:',out,flush=True)
        deadline=time.monotonic()+60
        while any(p.poll() is None for p in processes) and time.monotonic()<deadline:time.sleep(.2)
    finally:
        for p in processes:
            if p.poll() is None:p.terminate();p.wait(timeout=10)
        for s in streams:s.close()
    reports=[]
    for i,p in enumerate(processes):
        log=(out/f'peer{i}/engine.log').read_text(errors='replace')
        errors=[l for l in log.splitlines() if any(x in l for x in (' FAIL ','Execution could not continue','VM execution aborted','errors parsing JSON','Script error','out of sync','desync'))]
        reports.append(dict(peer=i,exit=p.returncode,errors=errors,passed=p.returncode==0 and not errors and log.count('CA437BRIDGE PASS')==5 and log.count('CA437BRIDGE RESULT')==1))
    assert args.source.read_bytes()==original
    result=dict(issue=437,source=str(args.source),source_sha256=hashlib.sha256(original).hexdigest(),without_handler=args.without_handler,runtime_sha256=fixture.digest(args.runtime),commands=commands,peers=reports,passed=all(r['passed'] for r in reports))
    (out/'results.json').write_text(json.dumps(result,indent=2))
    print(json.dumps(dict(directory=str(out),peers=reports),indent=2))
    if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()
