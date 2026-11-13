"""Reproduce the old javelin lookup defect and verify all seven native stacks."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import sys
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('baseline','runtime','output'):parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--reverse-only',action='store_true',help='Check the opposite acquisition order without repeating completed save tests.')
    args=parser.parse_args();baseline=args.baseline.resolve(strict=True);runtime=args.runtime.resolve(strict=True)
    active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'])
    if b'"gzdoom.exe"' in active.lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    source=Path(__file__).with_name('ammunition_lookup.zs').read_bytes()
    fixture=out/'fixture.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,blob in {'ZSCRIPT':b'version "4.14.2"\n'+source,'maps/CA455V.wad':wad(),
                          'MAPINFO':b'gameinfo { AddEventHandlers="CA650AmmoEvents" }\nmap CA455V "Native ammunition identity" { sky1="CABASKY",0 nointermission }\n'}.items():
            archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    (out/'fixture.zs').write_bytes(source)
    (out/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
    fresh='screenblocks 12; crosshair 0; con_notifytime 0; wait 140; '
    load='screenblocks 12; crosshair 0; con_notifytime 0; wait 35; '
    runs=[
        ('baseline-regression',baseline,['+map','CA455V'],fresh+'netevent ca650_prepare 0; wait 35; netevent ca650_verify 1; screenshot baseline-regression.png; wait 5; quit\n',True),
        ('baseline-typed-save',baseline,['+map','CA455V'],fresh+'netevent ca650_prepare 1; wait 35; netevent ca650_verify 0; save ammo-old; wait 20; quit\n',False),
        ('candidate-old-load',runtime,['-loadgame','ammo-old.zds'],load+'netevent ca650_verify 1; netevent ca650_pickup; wait 20; quit\n',False),
        ('candidate-fresh',runtime,['+map','CA455V'],fresh+'netevent ca650_prepare 0; wait 35; netevent ca650_verify 1; screenshot candidate.png; wait 5; save ammo-new; wait 20; quit\n',False),
        ('candidate-reload',runtime,['-loadgame','ammo-new.zds'],load+'netevent ca650_verify 1; netevent ca650_pickup; wait 20; quit\n',False),
        ('rollback-typed-load',baseline,['-loadgame','ammo-new.zds'],load+'netevent ca650_verify 0; wait 20; quit\n',False),
        ('candidate-reverse-order',runtime,['+map','CA455V'],fresh+'netevent ca650_prepare 2; wait 35; netevent ca650_verify 1; netevent ca650_pickup; wait 20; quit\n',False),
    ]
    if args.reverse_only:runs=[runs[-1]]
    report={'issue':650,'baseline_sha256':digest(baseline),'runtime_sha256':digest(runtime),
            'fixture_sha256':digest(fixture),'engine_sha256':digest(ENGINE),'runs':[],
            'qualification':'Old-runtime seed directly attaches correctly typed stacks to preserve a load fixture despite its broken pickup. Rollback verifies retained state only; old acquisition remains defective. No historical merged rounds are inferred or redistributed.'}
    expected_failures={'CA650 FAIL ammunition 3 owned quantity','CA650 FAIL ammunition 4 owned quantity',
                       'CA650 FAIL ammunition 5 owned quantity','CA650 FAIL all seven ammunition types retained',
                       'CA650 FAIL ammunition 0 split quantities','CA650 FAIL ammunition 0 split provenance units'}
    for label,package,entry,commands,regression in runs:
        cfg=out/(label+'.cfg');cfg.write_text(commands)
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(package),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/(label+'.log')),*entry,'+exec',str(cfg)]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (out/(label+'-process.log')).open('wb') as stream:
            process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup)
            deadline=time.monotonic()+120
            while process.poll() is None and time.monotonic()<deadline:
                logpath=out/(label+'.log');text=logpath.read_text(errors='replace') if logpath.exists() else ''
                if any(token in text for token in ('Script error','Execution could not continue','VM execution aborted')):break
                time.sleep(.2)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        logpath=out/(label+'.log');log=logpath.read_text(errors='replace') if logpath.exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ('Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model'))]
        failed={line for line in log.splitlines() if line.startswith('CA650 FAIL')}
        passed=code==0 and not errors and (failed==expected_failures if regression else not failed and 'CA650 COMPLETE failures=0' in log)
        result={'phase':label,'exit_code':code,'passed':passed,'expected_regression':regression,'engine_errors':errors,
                'failed_assertions':sorted(failed),'passed_assertions':sum(line.startswith('CA650 PASS') for line in log.splitlines())}
        report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(result),flush=True)
        if not passed:raise SystemExit(1)


if __name__=='__main__':main()
