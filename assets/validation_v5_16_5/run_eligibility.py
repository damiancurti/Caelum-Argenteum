"""Run isolated finale eligibility queries with two native local peers.

The fixture prepares personal records; it does not play quests, vote on a trip,
enter a finale, grant rewards or test scene restoration.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import struct
import subprocess
import time
import zipfile

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def room():
    # Owned diagnostic rectangle, based on the #455 visual fixture; two starts.
    text = ['namespace="ZDoom";']
    points = [(1024,-1024),(-1024,-1024),(-1024,1024),(1024,1024)]
    for x,y in points: text.append(f'vertex {{ x={x}; y={y}; }}')
    text.append('sector { heightfloor=0; heightceiling=768; texturefloor="CMST01"; textureceiling="F_SKY1"; lightlevel=224; }')
    for i in range(4):
        text += ['sidedef { sector=0; texturemiddle="CMST01"; }',
                 f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}']
    for i,x in enumerate((-400,400)):
        text.append(f'thing {{ type={i+1}; x={x}; y=-480; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }}')
    lumps = [('CA457F',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]
    body = bytearray(); directory = bytearray()
    for name,data in lumps:
        directory.extend(struct.pack('<ii8s',12+len(body),len(data),name.encode().ljust(8,b'\0')));body.extend(data)
    return struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--port',type=int,default=31957)
    args = parser.parse_args();runtime=args.runtime.resolve(strict=True);out=args.output.resolve()
    out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
    addon=out/'eligibility-probe.pk3'
    with zipfile.ZipFile(addon,'w') as archive:
        for name,data in {'maps/CA457F.wad':room(),
                          'ZSCRIPT':b'version "4.14.2"\n'+Path(__file__).with_name('eligibility_probe.zs').read_bytes(),
                          'MAPINFO':b'gameinfo { AddEventHandlers="CA457EligibilityProbe" }\nmap CA457F "Finale eligibility diagnostic" { sky1="CABASKY",0 nointermission }\n'}.items():
            archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),data)
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    report={'issue':457,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'fixture_sha256':digest(addon),'engine_sha256':digest(ENGINE),'runs':[]}
    for phase in ('fresh','reload'):
        processes=[];streams=[];folders=[];commands=[];failure=None
        try:
            for slot in range(2):
                folder=out/phase/f'peer{slot}';folder.mkdir(parents=True);folders.append(folder)
                (folder/'session.ini').write_text('[GlobalSettings]\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nvid_maxfps=60\n',encoding='utf-8')
                commands_text='wait 280; quit\n'
                if slot==0:
                    commands_text='wait 140; netevent ca457_test; wait 35; netevent ca457_audit; save checkpoint; wait 125; netevent ca457_left; wait 15; quit\n' if phase=='fresh' else 'wait 140; netevent ca457_audit; wait 160; netevent ca457_left; wait 15; quit\n'
                (folder/'commands.cfg').write_text(commands_text,encoding='utf-8')
                entry=['+map','CA457F']
                if phase=='reload':
                    shutil.copyfile(out/'fresh'/f'peer{slot}'/'checkpoint.zds',folder/'checkpoint.zds');entry=['-loadgame','checkpoint.zds']
                network=['-host','2','-port',str(args.port),'-netmode','0'] if slot==0 else ['-join',f'127.0.0.1:{args.port}','-port',str(args.port+1)]
                command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(addon),'-config',str(folder/'session.ini'),'-savedir',str(folder),*network,'-window','-width','800','-height','600','+logfile',str(folder/'engine.log'),*entry,'+exec',str(folder/'commands.cfg')]
                commands.append(command);stream=(folder/'process.log').open('wb');streams.append(stream)
                startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
                processes.append(subprocess.Popen(command,cwd=folder,stdout=stream,stderr=stream,startupinfo=startup))
                time.sleep(0.5)
            deadline=time.monotonic()+120
            while any(process.poll() is None for process in processes):
                if time.monotonic()>deadline:raise TimeoutError('Native eligibility run timed out.')
                for folder in folders:
                    logfile=folder/'engine.log'
                    log=logfile.read_text(encoding='utf-8',errors='replace') if logfile.exists() else ''
                    if any(mark in log for mark in ('Script error','VM execution aborted','Execution could not continue')):
                        raise RuntimeError('Native fixture/engine error; see retained log.')
                time.sleep(0.2)
        except Exception as error:
            failure=str(error)
        finally:
            for process in processes:
                if process.poll() is None:process.terminate()
                process.wait(timeout=10)
            for stream in streams:stream.close()
        peers=[]
        for slot,folder in enumerate(folders):
            logfile=folder/'engine.log';log=logfile.read_text(encoding='utf-8',errors='replace') if logfile.exists() else ''
            errors=[line for line in log.splitlines() if any(mark in line.lower() for mark in ('ca457 fail','ca457 result fail','script error','vm execution aborted','consistency failure'))]
            peers.append({'slot':slot,'exit_code':processes[slot].returncode,'errors':errors,
                          'checks':[line for line in log.splitlines() if 'CA457 ' in line],
                          'passed':processes[slot].returncode==0 and not errors and 'CA457 RESULT PASS' in log and (slot!=0 or 'CA457 DISCONNECT PASS' in log) and (phase!='fresh' or (folder/'checkpoint.zds').exists())})
        result={'phase':phase,'commands':commands,'failure':failure,'peers':peers,'passed':not failure and len(peers)==2 and all(peer['passed'] for peer in peers)}
        report['runs'].append(result);(out/'results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
        print(json.dumps({'phase':phase,'passed':result['passed'],'failure':failure,'peer_errors':[peer['errors'] for peer in peers]}),flush=True)
        if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()
