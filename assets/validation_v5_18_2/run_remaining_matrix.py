"""Run existing independent-beta scenarios serially, with their original assertions.

Each scenario retains separate profiles, saves, commands and logs. Only the
explicit multiplayer peers within one scenario run concurrently. No acceptance
is inferred from the automatic results.
"""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--capture-source',type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    common=['--runtime',str(runtime),'--iwad',str(runtime)]
    pvp=['--engine',str(ENGINE)]
    cases=[
        ('capture_reload','validation_v5_13_7/run_capture_probe.py',pvp+['--port','32946','--reload',str(args.capture_source.resolve(strict=True))]),
        ('hunt','validation_v5_13_8/run_hunt_probe.py',pvp+['--port','32960']),
        ('hunt_reload','validation_v5_13_8/run_hunt_probe.py',pvp+['--port','32960','--reload',str(out/'hunt')]),
        ('human_hunt','validation_v5_13_11/run_probe.py',pvp+['--port','32980']),
        ('human_hunt_reload','validation_v5_13_11/run_probe.py',pvp+['--port','32980','--reload',str(out/'human_hunt')]),
        ('audio_routes','validation_v5_17_125/run_audio.py',[]),
        ('finale_predicate','validation_v5_16_5/run_eligibility.py',['--port','32957']),
        ('coop','validation_v5_12_3/run_lifecycle_probe.py',['--port','32910','--persistence']),
        ('coop_reload','validation_v5_12_3/run_lifecycle_probe.py',['--port','32910','--persistence','--load-directory',str(out/'coop')]),
        ('coop_travel','validation_v5_12_3/run_lifecycle_probe.py',['--port','32910','--travel']),
        ('trucazo_ranked','validation_v5_14_3/run_native.py',['--port','32943']),
        ('trucazo_reload','validation_v5_14_3/run_native.py',['--port','32943','--load-directory',str(out/'trucazo_ranked')]),
        ('trucazo_tournament','validation_v5_14_3/run_native.py',['--port','32943','--suite','tournament','--players','4'])]
    record={'issue':468,'runtime':str(runtime),'runtime_sha256':hashlib.sha256(runtime.read_bytes()).hexdigest(),'cases':[],'author_acceptance':False}
    for label,relative,options in cases:
        active=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace')
        if '"gzdoom.exe"' in active.lower():raise RuntimeError('An existing game is running; it was not closed by this matrix.')
        command=[sys.executable,'-X','utf8',str(ROOT/'assets'/relative),*common,'--output',str(out/label),*options]
        print('Starting '+label,flush=True)
        with (out/(label+'-runner.txt')).open('xb') as stream:
            result=subprocess.run(command,cwd=ROOT,stdout=stream,stderr=stream)
        candidate=next((out/label/name for name in ['results.json','SUMMARY.json'] if (out/label/name).exists()),None)
        report=json.loads(candidate.read_text(encoding='utf8')) if candidate else {}
        passed=report.get('passed') if 'passed' in report else bool(report.get('phases') or report.get('runs')) and all(row['passed'] for row in report.get('phases',report.get('runs',[])))
        row={'case':label,'origin_runner':'assets/'+relative,'runner_sha256':hashlib.sha256((ROOT/'assets'/relative).read_bytes()).hexdigest(),
            'command':command,'exit':result.returncode,'report':str(candidate) if candidate else None,'passed':result.returncode==0 and passed}
        record['cases'].append(row);(out/'MATRIX.json').write_text(json.dumps(record,indent=2)+'\n')
        print(json.dumps({'case':label,'exit':result.returncode,'passed':row['passed']}),flush=True)
        if not row['passed']:raise SystemExit('Inspect retained '+str(out/(label+'-runner.txt')))


if __name__=='__main__':main()
