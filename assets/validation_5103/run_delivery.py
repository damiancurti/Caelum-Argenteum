"""Run only final integration and representative campaign windows, sequentially."""
from pathlib import Path
import subprocess
import sys
import argparse
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue428'
PACKAGE='build/issue428/final/caelum_argenteum_dev.pk3'
BASELINE='build/issue425/legacy/caelum_argenteum_dev.pk3'
jobs=[]
parser=argparse.ArgumentParser()
parser.add_argument('--after',help='Resume after this completed job, preserving its evidence.')
args=parser.parse_args()
subprocess.run([sys.executable,str(HERE/'prepare_integration.py')],cwd=ROOT,check=True)
for issue,wait in ((425,240),(426,100),(427,1320)):
    name='integrated-'+str(issue)+('-memory' if issue==425 else '-expiry' if issue==427 else '')
    checks='build/issue428/integration/checks425.pk3' if issue==425 else f'build/issue{issue}/current/checks.pk3'
    jobs.append((name,[sys.executable,str(HERE/'run_native.py'),name,
        '--full','--package',PACKAGE,'--checks',checks,
        '--map',f'CA{issue}A','--prefix',f'CA{issue}','--commands',f'netevent ca{issue}_seed; wait {wait}']))
for label,mapname,extra in (
    ('mansion','MAP01',[]),('sewers','MAP02',[]),('city','MAP03',[]),('ground','MAP03',['--ground']),('siege','MAP03',['--siege'])):
    for version,pkg in (('baseline',BASELINE),('final',PACKAGE)):
        # Existing immutable baseline city/siege evidence is reused.
        if version=='baseline' and label in ('city','siege'):continue
        name=f'{version}-{label}'
        jobs.append((name,[sys.executable,str(HERE/'run_performance.py'),name,'--package',pkg,'--map',mapname,*extra]))
if args.after:
    names=[name for name,_ in jobs]
    if args.after not in names:raise SystemExit('Unknown resume point.')
    jobs=jobs[names.index(args.after)+1:]
for name,command in jobs:
    transcript=OUT/(name+'-transcript.txt')
    if transcript.exists():raise SystemExit(f'Preserve existing evidence and resume explicitly after {name}.')
    with transcript.open('w',encoding='utf-8') as log:
        result=subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
    print(f'{name}: exit {result.returncode}',flush=True)
    if result.returncode:
        print('\n'.join(transcript.read_text(encoding='utf-8').splitlines()[-35:]))
        raise SystemExit(result.returncode)
print('Final regression and campaign sequence completed.')
