"""Run isolated director saves and real peers; retain logs and exact package hashes."""
from pathlib import Path
import argparse
import hashlib
import json
import struct
import subprocess
import sys
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
sys.path.insert(0, str(ROOT / 'assets/validation_v5_12_7'))
import native_sync


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fixture(path, peers, legacy=False, travel=False):
    # A private open floor covers the authored entry coordinates without spawning an army.
    text = 'namespace="ZDoom";\n'
    for x, y in [(-32000,-24000),(2000,-24000),(2000,18000),(-32000,18000)]:
        text += f'vertex{{x={x};y={y};}}\n'
    text += 'sector{heightfloor=0;heightceiling=1024;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=192;}\n'
    text += 'sidedef{sector=0;texturemiddle="STARTAN3";}\n'
    for i in range(4):
        text += f'linedef{{v1={(i+1)%4};v2={i};sidefront=0;blocking=true;}}\n'
    for i in range(peers):
        kind = i+1 if i<4 else 4001+i-4
        text += f'thing{{x={-448+i*128};y=0;type={kind};skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;}}\n'
    lumps = [('MAP03',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]
    body = b''.join(data for _,data in lumps)
    directory, offset = b'',12
    for name,data in lumps:
        directory += struct.pack('<ii8s',offset,len(data),name.encode());offset += len(data)
    members = {
        'maps/MAP03.wad':struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory,
        'MAPINFO':b'gameinfo { AddEventHandlers="CA447Checks" }\n',
        'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n',
        'checks.zs':(HERE/'checks.zs').read_bytes(),
    }
    if travel:
        members['maps/T447.wad']=members['maps/MAP03.wad']
        members['MAPINFO']+=b'cluster 447 { hub }\nmap MAP03 "Director fixture" { levelnum=447 cluster=447 }\nmap T447 "Director hub return" { levelnum=448 cluster=447 }\n'
    if legacy:
        source=members['checks.zs'].decode('utf-8')
        start=source.index('    void Initial()')
        end=source.index('    override void NetworkProcess',start)
        source=source[:start]+'''    void Initial()
    {
        Stage=2;
        Console.Printf("CA447 CHECKPOINT READY failures=0");
    }
    void Restored()
    {
        Check(Stage==2 && Port!=null && First!=null && Second!=null,"original save still loads under original runtime");
        Check(Port.Reinforcements.Remaining==1 && Port.Defenders[0]==First && Port.Defenders[1]==Second,"rollback preserves original roster and finite reserve");
        Console.Printf("CA447 RESULT %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    void LegacyRestored() {}
    void Catchup() {}
    void VerifyTravel() {}
\n'''+source[end:]
        members['checks.zs']=source.encode('utf-8')
    members = native_sync.instrument(members)
    with zipfile.ZipFile(path,'w',compression=zipfile.ZIP_STORED) as archive:
        for name,data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,9,0,0,0)),data)


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('label')
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--players',type=int,choices=range(1,9),default=1)
    parser.add_argument('--port',type=int,default=16047)
    parser.add_argument('--load-directory',type=Path)
    parser.add_argument('--suite',choices=('standard','legacy','catchup','travel'),default='standard')
    parser.add_argument('--legacy-fixture',action='store_true')
    parser.add_argument('--runtime-name',help='Keep the original saved package basename for native migration.')
    args=parser.parse_args()
    active=subprocess.check_output(['powershell','-NoProfile','-Command',
        "Get-Process | Where-Object ProcessName -eq 'gzdoom' | Select-Object -ExpandProperty Id"],text=True)
    if active.strip():raise SystemExit('Preserve the already running engine before starting a test.')
    out=ROOT/'build/v515/issue447'/args.label
    out.mkdir(parents=True,exist_ok=False)
    package=out/'checks.pk3';fixture(package,args.players,args.legacy_fixture,args.suite=='travel')
    runtime=args.runtime.resolve()
    if args.runtime_name:
        if Path(args.runtime_name).name!=args.runtime_name:raise SystemExit('Runtime alias must be a basename.')
        runtime=out/args.runtime_name
        runtime.write_bytes(args.runtime.read_bytes())
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    processes=[];streams=[];commands=[];timed_out=False
    fatal=('Script error','Execution could not continue','VM execution aborted','compile errors',
        'Unable to resolve','Attempt to redefine','Internal script compiler','DIED WITH FATAL ERROR')
    try:
        for i in range(args.players):
            peer=out/f'peer{i}';peer.mkdir()
            config=peer/'isolated.ini';cfg=peer/'commands.cfg'
            config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\n'
                'vid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\n'
                'i_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n',encoding='utf-8')
            entry=['+map','MAP03']
            host='wait 90; netevent ca447_seed; wait 15; netevent ca447_initial; wait 5; save checkpoint; '
            if args.load_directory:
                source=args.load_directory/'peer0/checkpoint.zds'
                (peer/'restore.zds').write_bytes(source.read_bytes());entry=['-loadgame','restore.zds']
                host='wait 100; netevent ca_session_recover; wait 5; netevent ca447_restored; '
                if args.suite=='legacy':host=host.replace('ca447_restored','ca447_legacy')
            if args.suite=='catchup':host=host.replace('save checkpoint;','netevent ca447_catchup;')
            if args.suite=='travel':host=host.replace('save checkpoint;','netevent ca447_travel; wait 70; netevent ca447_return; wait 70; netevent ca447_verifytravel;')
            duration=(500 if args.suite=='travel' else 210)+(args.players-i)*35
            cfg.write_text((host if i==0 else '')+f'wait {duration}; quit\n',encoding='utf-8')
            net=[] if args.players==1 else ['-host',str(args.players),'-port',str(args.port),'-netmode','0'] if i==0 else ['-join',f'127.0.0.1:{args.port}','-port',str(args.port+i)]
            command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(package),
                '-config',str(config),'-savedir',str(peer),'-window','-width','960','-height','720',
                *net,'+logfile',str(peer/'engine.log'),*entry,'+exec',str(cfg)]
            stream=(peer/'process.log').open('wb');streams.append(stream);commands.append(command)
            processes.append(subprocess.Popen(command,cwd=peer,startupinfo=startup,stdout=stream,stderr=stream))
            time.sleep(.3)
        print(str(out),flush=True);deadline=time.monotonic()+110
        while any(p.poll() is None for p in processes) and time.monotonic()<deadline:
            if any(any(token in log.read_text(errors='replace') for token in fatal) for log in out.glob('peer*/engine.log')):break
            time.sleep(.2)
        timed_out=any(p.poll() is None for p in processes)
    finally:
        for process in processes:
            if process.poll() is None:process.terminate();process.wait(timeout=10)
        for stream in streams:stream.close()
    peers=[]
    for i,process in enumerate(processes):
        log_path=out/f'peer{i}/engine.log'
        log=log_path.read_text(errors='replace') if log_path.exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in (' FAIL',*fatal))]
        checks=[line for line in log.splitlines() if line.startswith('CA447 ')]
        marker='CA447 RESULT PASS' if args.load_directory else 'CA447 CHECKPOINT READY failures=0'
        if args.suite=='legacy':marker='CA447 LEGACY PASS'
        if args.suite=='catchup':marker='CA447 CATCHUP PASS'
        if args.suite=='travel':marker='CA447 TRAVEL PASS'
        okay=process.returncode==0 and not errors and marker in log and native_sync.clean(log)
        peers.append(dict(peer=i,exit=process.returncode,passed=okay,checks=checks,errors=errors,native_sync=native_sync.clean(log)))
    result=dict(issue=447,restored=bool(args.load_directory),runtime_sha256=digest(args.runtime),
        engine_sha256=digest(ENGINE),fixture_sha256=digest(package),commands=commands,
        peers=peers,timed_out=timed_out,passed=all(p['passed'] for p in peers))
    (out/'results.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps(dict(directory=str(out),passed=result['passed'],peers=peers),indent=2),flush=True)
    if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()
