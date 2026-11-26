"""Run focused native rest transitions using retained #283 fixture ownership."""
import argparse
import hashlib
import importlib.util
import json
import re
import shutil
import subprocess
import sys
import time
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENGINE = Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD = Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
BASE_REVISION='0953a15e056d02ea65e24b62c7b3be4909b1451c'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--baseline', type=Path, default=ROOT/'build/issue889-review01.pk3')
    parser.add_argument('--only', help='Comma-separated scenario names; prerequisites must be included')
    parser.add_argument('--legacy', action='store_true', help='Run the exact pre-patch runtime and legacy probe')
    parser.add_argument('--import-save', type=Path, help='External save copied intact into the import case')
    args = parser.parse_args()
    out = args.output.resolve(); out.relative_to(ROOT/'build'); out.mkdir(parents=True, exist_ok=False)
    assert not subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace').lower().startswith('"gzdoom.exe"')
    changed = subprocess.check_output(['git','diff','--name-only',BASE_REVISION,'--','src'],cwd=ROOT,text=True).splitlines()
    changed += subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines()
    runtime = out/'runtime.pk3'
    updates = {p[4:]: (ROOT/p).read_bytes() for p in changed}
    if args.legacy:updates={}
    with zipfile.ZipFile(args.baseline) as old, zipfile.ZipFile(runtime,'w',zipfile.ZIP_DEFLATED,compresslevel=1) as new:
        for name in old.namelist():
            new.writestr(zipfile.ZipInfo(name,(2026,11,26,0,0,0)),updates.pop(name,old.read(name)))
        for name,blob in sorted(updates.items()):
            new.writestr(zipfile.ZipInfo(name,(2026,11,26,0,0,0)),blob)
    spec = importlib.util.spec_from_file_location('room',ROOT/'assets/validation_5421/prepare.py')
    room = importlib.util.module_from_spec(spec); spec.loader.exec_module(room)
    fixture = out/'fixture.pk3'
    files = {'ZSCRIPT': b'version "4.14.2"\n#include "equipment.zs"\n#include "previous.zs"\n#include "probe.zs"\n',
             'equipment.zs':(ROOT/'assets/validation_541/session.zs').read_bytes(),
             'previous.zs':(ROOT/'assets/validation_5423/probe.zs').read_bytes(),
             'probe.zs':Path(__file__).with_name('legacy_probe.zs' if args.legacy else 'rest_motion_probe.zs').read_bytes(),
             'maps/MAP99.wad':room.wad(),'maps/MAP98.wad':room.wad(),
             'MAPINFO':b'gameinfo { PlayerClasses="CA283MotionPlayer" AddEventHandlers="CA460Probe" }\ncluster 99 { hub }\nmap MAP99 "Rest transitions" { cluster=99 nointermission sky1="CABASKY",0 }\nmap MAP98 "Rest transition return" { cluster=99 nointermission sky1="CABASKY",0 }\n'}
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,blob in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,26,0,0,0)),blob)
    prefix='wait 100; netevent ca460_setup; wait 10; con_notifytime 0; '
    plans=[
        ('chair',prefix+'netevent ca460_begin 0 0; wait 20; netevent ca460_check 1 1; screenshot entering.png; wait 55; netevent ca460_check 0 1; netevent ca460_cancel; wait 20; netevent ca460_check 2 1; screenshot leaving.png; wait 55; netevent ca460_check 0 0; ',None),
        ('bed',prefix+'netevent ca460_begin 1 0; wait 30; netevent ca460_check 3 1; screenshot lying.png; wait 80; netevent ca460_check 0 1; netevent ca460_cancel; wait 30; netevent ca460_check 4 1; wait 80; netevent ca460_check 0 0; ',None),
        ('floor',prefix+'netevent ca460_begin 1 1; wait 30; netevent ca460_check 3 1; wait 80; netevent ca460_cancel; wait 30; netevent ca460_check 4 1; wait 80; netevent ca460_check 0 0; ',None),
        ('damage',prefix+'netevent ca460_begin 0 0; wait 20; netevent ca460_damage; netevent ca460_check 0 0; ',None),
        ('support',prefix+'netevent ca460_begin 1 0; wait 20; netevent ca460_remove; wait 2; netevent ca460_check 0 0; ',None),
        ('save-entry',prefix+'netevent ca460_begin 1 0; wait 30; netevent ca460_check 3 1; save inside; wait 5; ',None),
        ('reload-entry','wait 1; netevent ca460_check 3 1; wait 85; netevent ca460_check 0 1; netevent ca460_cancel; wait 110; netevent ca460_check 0 0; ','save-entry/inside.zds'),
        ('input',prefix+'netevent ca460_begin 0 0; wait 15; +forward; +attack; wait 5; netevent ca460_input_check; -forward; -attack; wait 55; netevent ca460_check 2 1; wait 75; netevent ca460_check 0 0; ',None),
        ('eat',prefix+'netevent ca460_begin 0 0; wait 75; netevent ca460_meal 0; wait 65; netevent ca460_check 5 1; netevent ca460_meal_check 5; screenshot meal.png; save inside; wait 5; ',None),
        ('drink','ca_wardrobe_candidate true; '+prefix+'netevent ca460_begin 1 0; wait 110; netevent ca460_meal 1; wait 65; netevent ca460_check 6 1; netevent ca460_meal_check 6; screenshot meal.png; netevent ca460_cancel; wait 80; netevent ca460_check 4 1; wait 110; netevent ca460_check 0 0; netevent ca460_meal_check 0; ',None),
        ('reload-meal','wait 1; netevent ca460_check 5 1; netevent ca460_cancel; wait 80; netevent ca460_check 2 1; save inside; wait 5; ','eat/inside.zds'),
        ('reload-exit','wait 1; netevent ca460_check 2 1; wait 75; netevent ca460_check 0 0; ','reload-meal/inside.zds'),
        ('jump',prefix+'netevent c283_watch_jump; +jump; wait 3; -jump; netevent c283_preparing; wait 100; netevent c283_jump_result; ',None),
        ('legacy-save',prefix+'netevent c283_chair; wait 20; save inside; wait 5; ',None),
        ('presentation',prefix+'netevent ca460_begin 0 0; wait 75; netevent ca460_perf 1; wait 175; netevent ca460_perf 0; wait 5; netevent ca460_meal 0; wait 10; netevent ca460_perf 1; wait 175; netevent ca460_perf 0; wait 5; ',None),
        ('hub',prefix+'netevent ca460_begin 1 0; wait 30; changemap MAP98; wait 100; netevent c283_loaded; netevent ca460_check 0 0; changemap MAP99; wait 100; netevent c283_loaded; netevent ca460_check 0 0; ',None),
        ('exhaustion',prefix+'netevent ca460_begin 0 0; wait 20; netevent ca460_exhaustion; wait 5; netevent ca460_check 0 1; netevent ca460_cancel; wait 5; netevent ca460_check 0 1; netevent ca460_recovered; wait 110; netevent ca460_check 0 0; ',None),
        ('import','wait 1; '+('netevent ca460_legacy_check; ' if args.legacy else 'netevent ca460_check 0 1; netevent ca460_cancel; wait 75; netevent ca460_check 0 0; '),args.import_save.resolve() if args.import_save else None)]
    if args.only:
        selected=set(args.only.split(','));plans=[p for p in plans if p[0] in selected]
        assert len(plans)==len(selected),'Unknown scenario'
    report={'issue':460,'runtime_sha256':digest(runtime),'fixture_sha256':digest(fixture),'runs':[]}
    for label,commands,save in plans:
        case=out/label;case.mkdir()
        (case/'session.ini').write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
        (case/'commands.cfg').write_text(commands+'netevent ca460_done; wait 5; quit\n')
        entry=['+map','MAP99']
        if save:
            source=out/save;target=case/'inside.zds';shutil.copyfile(source,target);assert digest(source)==digest(target)
            entry=['-loadgame',target.name]
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(fixture),'-config',str(case/'session.ini'),'-savedir',str(case),'-window','-width','1280','-height','720','+logfile',str(case/'native.log'),*entry,'+exec',str(case/'commands.cfg')]
        start=subprocess.STARTUPINFO();start.dwFlags|=subprocess.STARTF_USESHOWWINDOW;start.wShowWindow=4
        (case/'command.json').write_text(json.dumps(command,indent=2))
        with (case/'stdout.txt').open('wb') as stream:
            run=subprocess.Popen(command,cwd=case,startupinfo=start,stdout=stream,stderr=stream)
            deadline=time.monotonic()+120
            while run.poll() is None:
                output=(case/'stdout.txt').read_text(errors='replace')
                if any(failure in output for failure in ['Script error','Execution could not continue','Object expected']) or time.monotonic()>deadline:
                    run.terminate();run.wait(timeout=10);break
                time.sleep(1)
        log=(case/'native.log').read_text(errors='replace')
        results=re.findall(r'CA460 RESULT passed=(\d+) failed=(\d+)',log)
        okay=run.returncode==0 and bool(results) and all(int(failed)==0 for _,failed in results) and not any(failure in log for failure in ['Script error','Invalid state','FindModel:','Object expected'])
        report['runs'].append({'name':label,'passed':okay,'counts':results,'exit':run.returncode})
        windows=[]
        for row in re.findall(r'CA460 FRAMES ([0-9. ]+)',log):
            values=sorted(map(float,row.split()));count=len(values)
            windows.append({'frames':count,'mean_ms':sum(values)/count,'p50_ms':values[int((count-1)*.50)],'p95_ms':values[int((count-1)*.95)],'p99_ms':values[int((count-1)*.99)],'max_ms':values[-1]})
        if windows:report['runs'][-1]['presentation_windows']=windows
        (out/'SUMMARY.json').write_text(json.dumps(report,indent=2))
        print(json.dumps(report['runs'][-1]),flush=True)
        if not okay:raise SystemExit('Inspect '+str(case/'native.log'))

if __name__=='__main__':main()
