"""Run one isolated GZDoom process with PresentMon and immutable evidence labels."""
from pathlib import Path
import argparse
import ctypes
import hashlib
import json
import subprocess
import time
from datetime import datetime, timezone

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path(r'C:\Program Files (x86)\GZDoom\gzdoom.exe')
IWAD=Path(r'C:\Program Files (x86)\Steam\steamapps\common\ultimate doom\base\doom2\DOOM2.WAD')

def digest(p):
    return hashlib.file_digest(p.open('rb'),'sha256').hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',default='issue318-audit-02');p.add_argument('--variant',default='base')
    p.add_argument('--label',required=True);p.add_argument('--phase',type=int,default=0)
    p.add_argument('--site',type=int,default=1);p.add_argument('--pitch',type=int,default=0)
    p.add_argument('--map',choices=['MAP01','MAP02','MAP06','MAP98','MAP99','OPENCITY'],default='MAP06')
    p.add_argument('--window',type=int,default=350);p.add_argument('--warmup',type=int,default=140)
    p.add_argument('--width',type=int,default=1280);p.add_argument('--height',type=int,default=720)
    p.add_argument('--timeout',type=int,default=240);p.add_argument('--freeze',action='store_true')
    p.add_argument('--commands',default='');p.add_argument('--load',default='')
    p.add_argument('--user-config',action='store_true')
    p.add_argument('--global-presentmon',action='store_true')
    p.add_argument('--addon',default='')
    p.add_argument('--addon2',default='')
    p.add_argument('--postwait',type=int,default=5)
    p.add_argument('--fixture',default='observer.pk3')
    p.add_argument('--script',default='',help='Isolated functional commands instead of the performance scenario')
    a=p.parse_args();assert all(c.isalnum() or c in '-_' for c in a.label)
    stop=ROOT/'build'/a.directory/'stop-after-current.signal'
    if stop.exists() and stop.read_text().strip()=='stop':
        print('Run deferred by stop-after-current.signal:',a.label,flush=True)
        return
    running=subprocess.run(['powershell','-NoProfile','-Command',"(Get-Process gzdoom -ErrorAction SilentlyContinue).Id"],capture_output=True,text=True)
    if running.stdout.strip():raise RuntimeError('Existing engine retained; refusing overlapping measurements')
    work=ROOT/'build'/a.directory/a.variant;prefix=work/a.label
    if prefix.with_suffix('.ini').exists():raise FileExistsError(prefix)
    settings={'vid_preferbackend':'1','vid_vsync':'false','vid_maxfps':'0','cl_capfps':'false',
              'vid_activeinbackground':'true','i_pauseinbackground':'false','vid_lowerinbackground':'false',
              'i_soundinbackground':'true','vid_fullscreen':'false','use_mouse':'false','snd_mastervolume':'0.05',
              'language':'enu','vid_defwidth':str(a.width),'vid_defheight':str(a.height),
              'con_notifylines':'0','vid_fps':'true',
              'win_w':str(a.width+16),'win_h':str(a.height+39),'win_maximized':'false'}
    initial='[LastRun]\nVersion=225\n[GlobalSettings]\n'+'\n'.join(k+'='+v for k,v in settings.items())+'\n'
    if a.user_config:
        initial=(ROOT/'build/gzdoom.ini').read_text(encoding='utf-8-sig')
        for k,v in settings.items():
            import re
            pattern=r'^'+re.escape(k)+r'=.*$'
            if re.search(pattern,initial,flags=re.M):
                initial=re.sub(pattern,k+'='+v,initial,flags=re.M)
            else:
                assert '[GlobalSettings]' in initial
                initial=initial.replace('[GlobalSettings]','[GlobalSettings]\n'+k+'='+v,1)
    prefix.with_suffix('.ini').write_text(initial,encoding='utf-8')
    commands=(f'ca_test_siege_reinforcements {str(a.phase==2).lower()}; ca318_phase {a.phase}; ca318_site {a.site}; ca318_pitch {a.pitch}; '
              f'ca318_window {a.window}; ca318_warmup {a.warmup}; ca318_freeze {str(a.freeze).lower()}; '
              f'{a.commands}; wait 70; netevent ca318_begin; wait {a.warmup+a.window+3}; screenshot {a.label}.png; '
              f'wait 3; bench; wait {a.postwait}; profilethinkers -t; wait 5; quit\n')
    if a.script:commands=(ROOT/a.script).read_text(encoding='utf-8')
    prefix.with_suffix('.cfg').write_text(commands,encoding='utf-8')
    fixture=(work/a.fixture) if not Path(a.fixture).is_absolute() else Path(a.fixture)
    args=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(work/'runtime.pk3'),str(fixture),
          '-config',str(prefix.with_suffix('.ini')),'-savedir',str(work),'-width',str(a.width),'-height',str(a.height),
          '-window','-rngseed','116','-skill','2','+logfile',str(prefix.with_suffix('.txt'))]
    for extra in (a.addon,a.addon2):
        if extra:args[args.index('-config'):args.index('-config')]=[str((ROOT/extra).resolve())]
    if a.load:
        save=Path(a.load)
        if save.is_absolute():assert save.parent.resolve()==work.resolve(), 'Load save must belong to isolated savedir'
        assert (work/save.name).is_file(), 'Missing isolated save'
        args+=['-loadgame',save.name]
    else:args+=['+map',a.map]
    args+=['+exec',str(prefix.with_suffix('.cfg'))]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    rec={'args':args,'options':vars(a),'initial_config':initial,'started_utc':datetime.now(timezone.utc).isoformat(),
         'engine_sha256':digest(ENGINE),'runtime_sha256':digest(work/'runtime.pk3'),'fixture_sha256':digest(fixture)}
    if a.addon:rec['addon_sha256']=digest(ROOT/a.addon)
    if a.addon2:rec['addon2_sha256']=digest(ROOT/a.addon2)
    bench=work/'benchmarks.txt';bench_start=bench.stat().st_size if bench.exists() else 0
    pm=ROOT/'build/tools/PresentMon-2.6.0-x64.exe'
    pmout=prefix.with_name(a.label+'-presentmon.txt').open('w',encoding='utf-8')
    pmargs=[str(pm),'--process_name','gzdoom.exe','--output_file',str(prefix.with_suffix('.csv')),'--no_console_stats',
            '--qpc_time_ms','--session_name','CaelumIssue318','--timed',str(a.timeout+15),'--terminate_after_timed','--terminate_on_proc_exit']
    monitor=None if a.global_presentmon else subprocess.Popen(pmargs,cwd=work,startupinfo=startup,stdout=pmout,stderr=subprocess.STDOUT)
    time.sleep(0.3)
    record_path=prefix.with_name(a.label+'-run.json')
    def record():record_path.write_text(json.dumps(rec,indent=2)+'\n',encoding='utf-8')
    rec['presentmon_args']=pmargs;rec['presentmon_sha256']=digest(pm)
    rec['qpc_launch_ms']=time.perf_counter()*1000
    ctypes.windll.kernel32.SetThreadExecutionState(0x80000003)
    proc=subprocess.Popen(args,cwd=work,startupinfo=startup,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
    rec['pid']=proc.pid;record();deadline=time.monotonic()+a.timeout;seen=set()
    cpu_samples=[];next_sample=0
    print('RUN',a.label,'PID',proc.pid,flush=True)
    try:
        while proc.poll() is None:
            if time.monotonic()>=next_sample:
                stamps=[ctypes.c_ulonglong() for _ in range(4)]
                if ctypes.windll.kernel32.GetProcessTimes(ctypes.c_void_p(int(proc._handle)),*[ctypes.byref(stamp) for stamp in stamps]):
                    cpu_samples.append({'qpc_ms':time.perf_counter()*1000,'kernel_ms':stamps[2].value/10000,'user_ms':stamps[3].value/10000})
                next_sample=time.monotonic()+2
            log=prefix.with_suffix('.txt')
            if log.exists():
                text=log.read_text(encoding='utf-8',errors='replace')
                for marker in ('CA318 START','CA318 TRIGGER','CA318 WINDOW','CA318 DONE'):
                    if marker in text and marker not in seen:
                        seen.add(marker);rec[marker]={'qpc_seen_ms':time.perf_counter()*1000,'utc':datetime.now(timezone.utc).isoformat()}
                        print(a.label,next(line for line in text.splitlines() if line.startswith(marker)),flush=True)
                if any(error in text for error in ('Script error','VM execution aborted','errors while parsing','DIED WITH FATAL ERROR','Unable to resolve','Unknown identifier','has no front sector')):
                    rec['engine_error']=True;proc.terminate();break
            if time.monotonic()>deadline:
                rec['watchdog_timeout']=True;proc.terminate();break
            time.sleep(0.2)
        proc.wait(timeout=20)
    finally:
        if proc.poll() is None:proc.terminate();proc.wait(timeout=20)
        rec['exit_code']=proc.returncode;rec['finished_utc']=datetime.now(timezone.utc).isoformat()
        rec['qpc_exit_ms']=time.perf_counter()*1000
        rec['cpu_samples']=cpu_samples
        if monitor is not None:
            try:monitor.wait(timeout=8)
            except subprocess.TimeoutExpired:
                subprocess.run([str(pm),'--session_name','CaelumIssue318','--terminate_existing_session'],capture_output=True,startupinfo=startup)
                try:monitor.wait(timeout=5)
                except subprocess.TimeoutExpired:monitor.terminate();monitor.wait()
        rec['presentmon_exit']=monitor.returncode if monitor is not None else 'global collector';pmout.close()
        rec['keep_awake_released']=bool(ctypes.windll.kernel32.SetThreadExecutionState(0x80000000));record()
        if bench.exists():prefix.with_name(a.label+'-bench.txt').write_bytes(bench.read_bytes()[bench_start:])
    logtext=prefix.with_suffix('.txt').read_text(encoding='utf-8',errors='replace') if prefix.with_suffix('.txt').exists() else ''
    if proc.returncode!=0 or 'CA318 DONE failures=0' not in logtext or 'CA318 FAIL' in logtext:
        relevant=[line for line in logtext.splitlines() if line.startswith(('CA318 FAIL','CA318 PASS','CA318 DONE','CA318 SKIP','Script error','VM execution','Called from','Cannot find savegame')) or 'error' in line.lower() and not line.startswith('Vulkan')]
        print('\n'.join(relevant[-60:]));raise RuntimeError('Native run incomplete; full log retained')
    print('COMPLETE',a.label,'PresentMon',rec['presentmon_exit'],flush=True)

if __name__=='__main__':main()
