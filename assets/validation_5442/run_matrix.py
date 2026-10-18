"""Sequential same-save native matrix with external QPC marker observations."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import time

ROOT=Path(__file__).resolve().parents[2]


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--directory',required=True)
    p.add_argument('--prefix',default='matrix')
    p.add_argument('--modes',default='0,1,2,4,7,15,23,31,39,103,127')
    p.add_argument('--sites',default='0,1')
    p.add_argument('--rounds',type=int,default=3)
    p.add_argument('--audit',action='store_true')
    a=p.parse_args()
    assert re.fullmatch(r'issue318-stagger[a-z0-9-]+',a.directory)
    assert re.fullmatch(r'[a-z0-9-]+',a.prefix)
    folder=ROOT/'build'/a.directory
    manifest=json.loads((folder/'manifest.json').read_text())
    seed=folder/'stagger-seed.zds'
    seedhash=hashlib.sha256(seed.read_bytes()).hexdigest()
    plan=folder/(a.prefix+'-plan.json');assert not plan.exists()
    plan.write_text(json.dumps(dict(vars(a),seed_sha256=seedhash),indent=2)+'\n')
    modes=[int(x) for x in a.modes.split(',')]
    order=[]
    starts={}
    for repeat in range(a.rounds):
        active=[x for x in modes if x!=0]
        if repeat%2:active.reverse()
        selected=([0] if 0 in modes else [])+active+([0] if 0 in modes and active else [])
        for site in [int(x) for x in a.sites.split(',')]:
            for index,mode in enumerate(selected):
                label=f'{a.prefix}-s{site}-r{repeat}-n{index}-m{mode}'
                assert not (folder/(label+'.ini')).exists()
                script=(folder/f'mode{mode}.cfg').read_text()
                script=script.replace('ca318_stagger_start true',f'ca318_stagger_audit {str(a.audit).lower()}; ca318_stagger_site {site}; ca318_stagger_start true')
                (folder/(label+'.cfg')).write_text(script)
                bench=folder/'benchmarks.txt';before=bench.stat().st_size if bench.exists() else 0
                output=folder/(label+'-runner.txt')
                markers={}
                print('RUN',label,flush=True)
                with output.open('w') as stream:
                    proc=subprocess.Popen(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',
                        'assets/validation_5422/run_native.ps1','-Directory',a.directory,'-Label',label,
                        '-Script',label+'.cfg','-LoadGame','stagger-seed.zds','-Map','MAP03'],
                        cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT)
                    deadline=time.monotonic()+240
                    while proc.poll() is None:
                        log=folder/(label+'.txt')
                        if log.exists():
                            text=log.read_text(encoding='utf-8',errors='replace')
                            for marker in ['STAGGER BEGIN','STAGGER END']:
                                if marker not in markers and marker in text:
                                    line=next(x for x in text.splitlines() if x.startswith(marker))
                                    markers[marker]={'qpc_seen_ms':time.perf_counter()*1000,'line':line}
                        if time.monotonic()>deadline:
                            # Stop this wrapper's specific engine, never an unrelated process.
                            subprocess.run(['powershell','-NoProfile','-Command',
                                f"Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {{$_.CommandLine -like '*{label}.ini*'}} | ForEach-Object {{Stop-Process -Id $_.ProcessId}}"],check=True)
                            proc.wait(timeout=20)
                            raise RuntimeError('Timed out: '+label)
                        time.sleep(0.05)
                assert proc.returncode==0, (label,output.read_text())
                text=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
                assert 'CA282 DONE passes=1 failures=0' in text and 'CA282 FAIL' not in text,label
                assert len(markers)==2,label
                assert 'STAGGER FRAMES_END' in text,label
                begin=markers['STAGGER BEGIN']['line']
                assert int(re.search(r'\btic=(\d+)',begin)[1])==manifest['measurement_start_tic'],(label,begin)
                start=next(x for x in text.splitlines() if x.startswith('STAGGER CENSUS label=start '))
                if site not in starts:starts[site]=start
                assert start==starts[site],(label,'Initial aggregate state differs from same-site control')
                raw=bench.read_bytes();assert len(raw)>before
                (folder/(label+'-bench.txt')).write_bytes(raw[before:])
                record={'label':label,'site':site,'repeat':repeat,'mode':mode,'audit':a.audit,
                    'seed_sha256':seedhash,'markers':markers,'bench_start':before,'bench_end':len(raw)}
                order.append(record)
                (folder/(a.prefix+'-order.json')).write_text(json.dumps(order,indent=2)+'\n')
                print('PASS',label,flush=True)
    assert hashlib.sha256(seed.read_bytes()).hexdigest()==seedhash


if __name__=='__main__':main()
