"""Prepare/run isolated #327 functional checks. No ETW or performance claim."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import subprocess
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue327-native'
ENGINE=Path(r'C:\Program Files (x86)\GZDoom\gzdoom.exe')
IWAD=Path(r'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD')


def prepare():
    WORK.mkdir(exist_ok=True)
    members={'ZSCRIPT':b'version "4.14"\n#include "houses.zs"\n#include "ceilings.zs"\n#include "checks.zs"\n',
             'MAPINFO':b'GameInfo { AddEventHandlers="CA327Checks" }\n',
             'houses.zs':(ROOT/'assets/validation_issue318/house_checks.zs').read_bytes().replace(b'MAP06',b'MAP03'),
             'ceilings.zs':(HERE/'ceilings.zs').read_bytes(), 'checks.zs':(HERE/'checks.zs').read_bytes()}
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_DEFLATED) as z:
        for name,raw in sorted(members.items()):
            info=zipfile.ZipInfo(name,(1980,1,1,0,0,0));z.writestr(info,raw)
    scripts={}
    scripts['geometry']='wait 70; netevent maps_check 6; netevent houses_city; netevent ceilings_check; netevent ceilings_fly; wait 1; netevent ceilings_fly_checked; '
    scripts['geometry']+=''.join(f'netevent ceilings_view {i}; wait 10; screenshot geometry-{i}.png; ' for i in range(4))
    scripts['maps']='wait 35; netevent maps_check 6; '
    # TACTORS preserves a historical 16,508-thing stress fixture: verify its
    # identity statically, never launch it as a routine smoke test.
    for name,location in [('TRESERV',3),('TTAROT',4),('TMAINT',5),('TCOAST',7),('THAZARD',8),('MAP02',2),('MAP01',1)]:
        scripts['maps']+=f'map {name}; wait 35; netevent maps_check {location}; '
    scripts['siege']='wait 70; netevent siege_start; wait 35; netevent siege_before_due; netevent siege_cap; netevent siege_block; storesavepic false; save siege-state.zds; wait 5; '
    scripts['siege-reload']='wait 35; netevent siege_saved; changemap CAH158; wait 70; changemap MAP03; wait 70; netevent siege_saved; netevent siege_unblock; netevent siege_victory; '
    scripts['budget']='wait 70; netevent siege_start; netevent siege_budget; wait 160; '
    scripts['policy']='wait 70; netevent siege_start; wait 2; netevent siege_cap; netevent siege_policy; '
    scripts['route']='wait 70; netevent route_depart; wait 105; netevent route_arrived; netevent houses_position 158; wait 2; +use; wait 10; -use; wait 70; netevent houses_arrived 158; netevent houses_position 158; wait 2; +use; wait 10; -use; wait 70; netevent houses_returned 158; '
    for name in ('portals','deploy','save','reload','return'):
        scripts[name]=(HERE/f'{name}.cfg').read_text().split('netevent houses_done')[0]
    for name,commands in scripts.items():
        (WORK/f'{name}.cfg').write_text(commands+'netevent houses_done; wait 5; quit\n',encoding='utf-8')
    print('Prepared isolated fixtures and scripts.')


def run(label,script,load='',map_name='MAP03',timeout=300):
    running=subprocess.run(['powershell','-NoProfile','-Command','(Get-Process gzdoom -ErrorAction SilentlyContinue).Id'],capture_output=True,text=True)
    if running.stdout.strip():raise RuntimeError('An existing engine is still open; refusing overlap')
    prefix=WORK/label
    if prefix.with_suffix('.ini').exists():raise FileExistsError(label)
    run_dir=WORK/label;run_dir.mkdir(exist_ok=False)
    fixture=run_dir/'checks.pk3'
    fixture.write_bytes((WORK/'checks.pk3').read_bytes())
    script_path=run_dir/'commands.cfg'
    script_path.write_bytes((WORK/f'{script}.cfg').read_bytes())
    fixture_hash=hashlib.sha256(fixture.read_bytes()).hexdigest()
    runtime_hash=hashlib.sha256((ROOT/'build/caelum_argenteum_dev.pk3').read_bytes()).hexdigest()
    runtime_dir=WORK/'runtimes'/runtime_hash;runtime_dir.mkdir(parents=True,exist_ok=True)
    runtime=runtime_dir/'caelum_argenteum_dev.pk3'
    if not runtime.exists():os.link(ROOT/'build/caelum_argenteum_dev.pk3',runtime)
    assert hashlib.sha256(runtime.read_bytes()).hexdigest()==runtime_hash
    settings={'vid_preferbackend':'1','vid_vsync':'false','vid_maxfps':'0','cl_capfps':'false',
              'vid_activeinbackground':'true','i_pauseinbackground':'false','vid_lowerinbackground':'false',
              'i_soundinbackground':'true','snd_mastervolume':'0.05','vid_fullscreen':'false','use_mouse':'false',
              'language':'enu','vid_defwidth':'1280','vid_defheight':'720','win_maximized':'false'}
    prefix.with_suffix('.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\n'+'\n'.join(k+'='+v for k,v in settings.items())+'\n')
    args=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),str(fixture),
          '-config',str(prefix.with_suffix('.ini')),'-savedir',str(WORK),'-window','-width','1280','-height','720',
          '+logfile',str(prefix.with_suffix('.txt')),'+ca_test_siege_reinforcements','false']
    args+=['-loadgame',load] if load else ['+map',map_name]
    args+=['+exec',str(script_path)]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    start=time.monotonic();proc=subprocess.Popen(args,cwd=WORK,startupinfo=startup,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    print(f'RUN {label} PID {proc.pid}',flush=True)
    error=None
    try:
        while proc.poll() is None:
            text=prefix.with_suffix('.txt').read_text(encoding='utf-8',errors='replace') if prefix.with_suffix('.txt').exists() else ''
            if any(s in text for s in ('Script error','VM execution aborted','errors while parsing','Unknown identifier','DIED WITH FATAL ERROR','CA318 FAIL')):
                error='Native failure; complete log retained';break
            if time.monotonic()-start>timeout:error='Watchdog timeout';break
            time.sleep(.2)
    finally:
        if proc.poll() is None:proc.terminate();proc.wait(timeout=20)
    text=prefix.with_suffix('.txt').read_text(encoding='utf-8',errors='replace')
    result={'label':label,'script':script,'exit_code':proc.returncode,'seconds':time.monotonic()-start,
            'runtime_sha256':runtime_hash,
            'fixture_sha256':fixture_hash,
            'commands_sha256':hashlib.sha256(script_path.read_bytes()).hexdigest(),
            'passes':text.count('CA318 PASS '),'failures':text.count('CA318 FAIL '),'error':error,
            'done':'CA318 DONE failures=0' in text,'kind':'isolated native functionality; no FPS measurement'}
    if script=='budget':result['complete_budget']='CA327 BUDGET success=6600 remaining=0' in text
    prefix.with_suffix('.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result),flush=True)
    if error or result['exit_code']!=0 or result['failures'] or not result['done'] or result.get('complete_budget',True) is False:
        relevant=[line for line in text.splitlines() if any(x in line for x in ('CA318 FAIL','CA327','Script error','VM execution','Called from','Cannot find','FATAL ERROR'))]
        print('\n'.join(relevant));raise RuntimeError('Native check incomplete; complete log retained')


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--prepare',action='store_true');p.add_argument('--label');p.add_argument('--script');p.add_argument('--load',default='');p.add_argument('--map',default='MAP03');p.add_argument('--timeout',type=int,default=300)
    a=p.parse_args()
    if a.prepare:prepare()
    if a.label:run(a.label,a.script,a.load,a.map,a.timeout)
