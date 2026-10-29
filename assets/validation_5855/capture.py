"""Measure one visible native scenario, including ETW presentation timings."""
from pathlib import Path
import subprocess,sys,json
R=Path(__file__).resolve().parents[2];W=R/'build/issue417-incidents';label=sys.argv[1];runtime=sys.argv[2]
tool=R.parent.parent/'build/tools/PresentMon-2.6.0-x64.exe'
with (W/f'{label}-presentmon.txt').open('wb') as out:
 monitor=subprocess.Popen([str(tool),'--process_name','gzdoom.exe','--output_file',str(W/f'{label}-present.csv'),
  '--session_name',label,'--no_console_stats','--timed','90','--terminate_after_timed','--terminate_on_proc_exit'],
  stdout=out,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
 result=subprocess.run(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',str(R/'assets/validation_5853/run_native.ps1'),
  '-Label',label,'-Runtime',runtime,'-Script','review-perf','-Checks','-Addon','review-perf.pk3','-StartMap','MAP01',
  '-Visible','-TimeoutSeconds','100','-FinishMarker','CA415P RESULT profile complete'],cwd=R)
 try:monitor.wait(timeout=5)
 except subprocess.TimeoutExpired:monitor.terminate();monitor.wait()
 print('Native exit',result.returncode,'PresentMon exit',monitor.returncode)
sys.exit(result.returncode)
