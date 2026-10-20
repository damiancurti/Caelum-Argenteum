"""Capture isolated #314 application presentation and simulation evidence."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import time

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True);p.add_argument('--label',required=True)
    p.add_argument('--map',default='TTSNONE');p.add_argument('--reference',action='store_true')
    p.add_argument('--skip-etw',action='store_true',help='Retain the known permission limitation without retrying ETW.')
    a=p.parse_args()
    assert all(c.isalnum() or c in '-_' for c in a.label)
    work=ROOT/'build'/a.directory;prefix=work/a.label
    assert not prefix.with_suffix('.csv').exists()
    pm=ROOT/'build/tools/PresentMon-2.6.0-x64.exe'
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    args=[str(pm),'--process_name','gzdoom.exe','--output_file',str(prefix.with_suffix('.csv')),
          '--no_console_stats','--qpc_time_ms','--session_name','CaelumIssue314',
          '--timed','180','--terminate_after_timed','--terminate_on_proc_exit']
    meta={'presentmon_sha256':hashlib.sha256(pm.read_bytes()).hexdigest(),'args':args,'markers':{}}
    with prefix.with_name(a.label+'-presentmon.txt').open('w') as output:
        monitor=None if a.skip_etw else subprocess.Popen(args,cwd=work,startupinfo=startup,stdout=output,stderr=subprocess.STDOUT)
        command=['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(HERE/'run_native.ps1'),
                 '-Directory',a.directory,'-Label',a.label,'-Script','reference.cfg' if a.reference else 'perf.cfg','-Map',a.map]
        process=subprocess.Popen(command,cwd=ROOT,startupinfo=startup,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
        try:
            while process.poll() is None:
                log=prefix.with_suffix('.txt')
                if log.exists():
                    text=log.read_text(encoding='utf-8',errors='replace')
                    for marker in ('CA314 PERF BEGIN','CA314 PERF END'):
                        if marker in text and marker not in meta['markers']:
                            meta['markers'][marker]=time.perf_counter()*1000
                time.sleep(.2)
            out=process.communicate()[0];print(out)
        finally:
            if monitor is not None:
                subprocess.run([str(pm),'--session_name','CaelumIssue314','--terminate_existing_session'],startupinfo=startup,capture_output=True)
                try:monitor.wait(timeout=10)
                except subprocess.TimeoutExpired:monitor.terminate();monitor.wait()
            meta['collector_exit']=monitor.returncode if monitor is not None else 'not retried after access denied'
            prefix.with_name(a.label+'-presentation.json').write_text(json.dumps(meta,indent=2)+'\n')
        if process.returncode:raise RuntimeError('Native performance fixture failed; raw evidence retained.')

if __name__=='__main__':main()
