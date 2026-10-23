"""Capture matched peaceful station views with PresentMon; no stress populations."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue470'


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('label')
    parser.add_argument('--runtime',choices=['baseline','current'],required=True)
    parser.add_argument('--map',choices=['MAP01','MAP03'],required=True)
    args=parser.parse_args()
    common=Path(subprocess.check_output(['git','rev-parse','--path-format=absolute','--git-common-dir'],cwd=ROOT,text=True).strip()).parent
    pm=common/'build/tools/PresentMon-2.6.0-x64.exe'
    csv=OUT/f'{args.label}.csv'
    if csv.exists():raise RuntimeError('Use a new immutable capture label.')
    command=[str(pm),'--process_name','gzdoom.exe','--output_file',str(csv),
             '--no_console_stats','--qpc_time_ms','--session_name','CaelumIssue470',
             '--timed','75','--terminate_after_timed','--terminate_on_proc_exit']
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW
    denied=any('access denied' in p.read_text(encoding='utf-8',errors='replace') for p in OUT.glob('perf-*-presentmon.txt'))
    with (OUT/f'{args.label}-presentmon.txt').open('w',encoding='utf-8') as log:
        monitor=None if denied else subprocess.Popen(command,cwd=OUT,startupinfo=startup,stdout=log,stderr=subprocess.STDOUT)
        if denied:log.write('PresentMon unavailable: prior attempt was denied by Windows; no repeated elevation attempt.\n')
        try:
            time.sleep(.3)
            subprocess.run(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(HERE/'run_native.ps1'),
                '-Label',args.label,'-Runtime',args.runtime,'-Script','performance',
                '-Checks','-Addon','performance.pk3','-StartMap',args.map,'-Visible'],cwd=ROOT,check=True)
            if monitor is not None:monitor.wait(timeout=12)
        finally:
            if monitor is not None and monitor.poll() is None:
                monitor.terminate();monitor.wait(timeout=5)
    record={'command':command,'sha256':hashlib.file_digest(pm.open('rb'),'sha256').hexdigest(),
            'exit':monitor.returncode if monitor is not None else None,
            'csv_sha256':hashlib.file_digest(csv.open('rb'),'sha256').hexdigest() if csv.exists() else None,
            'limitation':'PresentMon unavailable under current Windows privileges; render callbacks are not display presentation.' if not csv.exists() else None}
    (OUT/f'{args.label}-presentmon.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(record))


if __name__=='__main__':main()
