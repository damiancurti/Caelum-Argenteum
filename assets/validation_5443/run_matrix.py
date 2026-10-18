"""Bracket normal-runtime variants with same-save controls, sequentially."""
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
    p.add_argument('--control',default='baseline.pk3')
    p.add_argument('--variant',default='current/baseline.pk3')
    p.add_argument('--sites',default='0,1')
    p.add_argument('--rounds',type=int,default=3)
    a=p.parse_args()
    assert re.fullmatch(r'issue35[34]-[a-z0-9-]+',a.directory)
    assert re.fullmatch(r'[a-z0-9-]+',a.prefix)
    folder=ROOT/'build'/a.directory
    manifest=json.loads((folder/'manifest.json').read_text())
    for name in (a.control,a.variant,'city.pk3','front/city.pk3'):
        assert hashlib.sha256((folder/name).read_bytes()).hexdigest()==manifest['hashes'][name]
    seed=folder/'cache-battle.zds';seedhash=hashlib.sha256(seed.read_bytes()).hexdigest()
    plan=folder/(a.prefix+'-plan.json');assert not plan.exists()
    plan.write_text(json.dumps(dict(vars(a),seed_sha256=seedhash),indent=2)+'\n')
    order=[];starts={};start_tic=None
    for repeat in range(a.rounds):
        for site in [int(x) for x in a.sites.split(',')]:
            for index,mode in enumerate((0,1,0)):
                label=f'{a.prefix}-s{site}-r{repeat}-n{index}-m{mode}'
                runtime=a.variant if mode else a.control
                fixture='front/city.pk3' if site else 'city.pk3'
                assert not (folder/(label+'.ini')).exists()
                output=folder/(label+'-runner.txt');markers={}
                print('RUN',label,flush=True)
                with output.open('w') as stream:
                    proc=subprocess.Popen(['powershell','-NoProfile','-ExecutionPolicy','Bypass','-File',
                        str(folder/'run_perf.ps1'),'-Directory',a.directory,'-Label',label,
                        '-Runtime',runtime,'-Fixture',fixture,'-Script','measure.cfg',
                        '-LoadGame','cache-battle.zds','-Map','MAP03'],cwd=ROOT,stdout=stream,stderr=subprocess.STDOUT)
                    deadline=time.monotonic()+240
                    while proc.poll() is None:
                        log=folder/(label+'.txt')
                        if log.exists():
                            text=log.read_text(encoding='utf-8',errors='replace')
                            for marker in ['CACHE BEGIN','CACHE FPS_BEGIN','CACHE END']:
                                if marker not in markers and marker in text:
                                    line=next(x for x in text.splitlines() if x.startswith(marker))
                                    markers[marker]={'qpc_seen_ms':time.perf_counter()*1000,'line':line}
                        if time.monotonic()>deadline:
                            subprocess.run(['powershell','-NoProfile','-Command',
                                f"Get-CimInstance Win32_Process -Filter \"Name='gzdoom.exe'\" | Where-Object {{$_.CommandLine -like '*{label}.ini*'}} | ForEach-Object {{Stop-Process -Id $_.ProcessId}}"],check=True)
                            proc.wait(timeout=20)
                            raise RuntimeError('Timed out: '+label)
                        time.sleep(.05)
                assert proc.returncode==0,(label,output.read_text())
                text=(folder/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
                assert 'CA282 DONE passes=1 failures=0' in text and 'CA282 FAIL' not in text,label
                assert len(markers)==3 and 'CACHE FRAMES_END' in text,label
                tic=int(re.search(r'\btic=(\d+)',markers['CACHE BEGIN']['line'])[1])
                if start_tic is None:start_tic=tic
                assert tic==start_tic,(label,tic,start_tic)
                start=next(x for x in text.splitlines() if x.startswith('CACHE CENSUS label=start '))
                if site not in starts:starts[site]=start
                assert start==starts[site],(label,'Initial aggregate state differs')
                record=dict(label=label,site=site,repeat=repeat,mode=mode,runtime=runtime,fixture=fixture,
                    seed_sha256=seedhash,markers=markers)
                order.append(record)
                (folder/(a.prefix+'-order.json')).write_text(json.dumps(order,indent=2)+'\n')
                print('PASS',label,flush=True)
    assert hashlib.sha256(seed.read_bytes()).hexdigest()==seedhash

if __name__=='__main__':main()
