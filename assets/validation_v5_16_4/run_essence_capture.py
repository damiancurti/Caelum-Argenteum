"""Exercise all75 generic IDs with native Use and full timed capture.

An owned flat room and three prepared opening acquisitions isolate transactions.
There are no campaign placements, NPC-death alternate routes or new rules here.
Dialogue response selection is invoked by the fixture after actual native Use.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad

ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--gate-only',action='store_true',help='Run the approved World prerequisite boundary checks only')
    parser.add_argument('--checkpoint-root',type=Path,help='Load retained mid/completed saves from an earlier runtime run')
    parser.add_argument('--legacy-world-from',type=Path,help='Capture early World with this older runtime, then verify retention with --runtime')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    checkpoints=args.checkpoint_root.resolve(strict=True) if args.checkpoint_root else None
    legacy=args.legacy_world_from.resolve(strict=True) if args.legacy_world_from else None
    if legacy and (args.gate_only or checkpoints):parser.error('Legacy World is a separate two-runtime save test.')
    active=subprocess.run(['powershell','-NoProfile','-Command','@(Get-Process gzdoom -ErrorAction SilentlyContinue).Count'],capture_output=True,text=True,check=True)
    if int(active.stdout.strip()):parser.error('Close the existing GZDoom process before this isolated run.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    fixture=out/'capture-probe.pk3'
    with zipfile.ZipFile(fixture,'w') as package:
        for name,data in {'maps/CA455V.wad':wad(),
                          'ZSCRIPT':b'version "4.14.2"\n'+Path(__file__).with_name('essence_capture_probe.zs').read_bytes(),
                          'MAPINFO':b'gameinfo { AddEventHandlers="CA456CaptureProbe" }\nmap CA455V "Essence transaction diagnostic" { sky1="CABASKY",0 nointermission }\n'}.items():
            package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),data)
    cards=[card for card in range(1,78) if card not in (21,36,60)]+[21]
    use='wait 3; +use; wait 3; -use; netevent ca456_begin; '
    finish='netevent ca456_result; screenshot completed.png; save completed; wait 5; quit\n'
    fresh='wait 140; netevent ca456_prepare; wait 5; netevent ca456_gate; netevent ca456_place 1; '+use
    fresh+='wait 5; netevent ca456_leave; wait 5; netevent ca456_retry; '+use
    fresh+='wait 5; save midcapture; wait 40; netevent ca456_check; exec card-02.cfg\n'
    resume='wait 3; netevent ca456_midload; wait 40; netevent ca456_check; exec card-02.cfg\n'
    completed='wait 10; netevent ca456_result; screenshot reloaded.png; wait 5; quit\n'
    report={'issue':456,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'engine_sha256':digest(ENGINE),'fixture_sha256':digest(fixture),'card_order':cards,'runs':[]}
    plans=[('fresh',fresh,None),('mid-reload',resume,'fresh/midcapture.zds'),('complete-reload',completed,'fresh/completed.zds')]
    if args.gate_only:plans=[('gate','wait 140; netevent ca456_prepare; wait 5; netevent ca456_gate; netevent ca456_gate_result; wait 5; quit\n',None)]
    if legacy:
        plans=[('legacy-world','wait 140; netevent ca456_prepare; wait 5; netevent ca456_place 21 1; '+use+'wait 40; netevent ca456_check; netevent ca456_legacy_result; save legacy-world; wait 5; quit\n',None),
               ('legacy-world-reload','wait 10; netevent ca456_legacy_result; wait 5; quit\n','legacy-world/legacy-world.zds')]
    for phase,commands,seed in plans:
        folder=out/phase;folder.mkdir()
        # Keep native command-buffer input bounded instead of one giant line.
        for number,card in enumerate(cards[1:],start=2):
            continuation=f'exec card-{number+1:02d}.cfg\n' if number<len(cards) else finish
            (folder/f'card-{number:02d}.cfg').write_text(f'netevent ca456_place {card}; '+use+'wait 40; netevent ca456_check; '+continuation)
        (folder/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        (folder/'commands.cfg').write_text(commands)
        entry=['+map','CA455V']
        if seed:
            save=(checkpoints if checkpoints else out)/seed
            shutil.copyfile(save,folder/'input.zds');entry=['-loadgame','input.zds']
        package=legacy if phase=='legacy-world' else runtime
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(package),str(fixture),'-config',str(folder/'session.ini'),'-savedir',str(folder),'-window','-width','960','-height','720','+logfile',str(folder/'engine.log'),*entry,'+exec',str(folder/'commands.cfg')]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        timed_out=False
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,stdout=stream,stderr=stream,startupinfo=startup)
            try:code=process.wait(timeout=240)
            except subprocess.TimeoutExpired:
                timed_out=True;process.terminate();process.wait(timeout=10);code=process.returncode
        log=(folder/'engine.log').read_text(errors='replace') if (folder/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(mark in line for mark in ('Script error','Execution could not continue','VM execution aborted','CA456 CAPTURE FAIL','Unknown command'))]
        captures=[line for line in log.splitlines() if line.startswith('CA456 CAPTURE ')]
        marker='CA456 GATE COMPLETE failures=0' if args.gate_only else 'CA456 CAPTURE COMPLETE captured=75 failures=0'
        if legacy:marker='CA456 LEGACY COMPLETE failures=0'
        checks=log.count('full timed capture grants exactly one essence')
        required=0 if args.gate_only or phase=='complete-reload' else 75
        if legacy:required=1 if phase=='legacy-world' else 0
        if checks!=required:errors.append(f'Expected{required} timed capture checks, found{checks}.')
        if phase=='fresh':
            for name in ['midcapture.zds','completed.zds']:
                if not (folder/name).is_file():errors.append('Missing checkpoint: '+name)
        if phase=='legacy-world' and not (folder/'legacy-world.zds').is_file():errors.append('Missing legacy-world checkpoint.')
        passed=code==0 and not timed_out and not errors and marker in log
        if phase=='mid-reload':passed=passed and marker+' reload=1' in log
        row={'phase':phase,'runtime_sha256':digest(package),'exit_code':code,'timed_out':timed_out,'passed':passed,'errors':errors,'checks':captures,'command':command}
        if seed:row['input_save_sha256']=digest(save)
        report['runs'].append(row)
        (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
        print(json.dumps({'phase':phase,'passed':passed,'checks':len(captures),'errors':errors}),flush=True)
        if not passed:raise SystemExit(1)

if __name__=='__main__':main()
