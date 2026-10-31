"""Bounded reproduction of a retained native-load failure, without publishing saves.

Alternate launcher defaults and an explicitly windowed diagnostic request.
If defaults already enforce a window, these are equivalent, not an A/B comparison.
This only produces separate copied inputs/checkpoints; it never updates custody.
"""
from pathlib import Path
import argparse,datetime,hashlib,json,sys

ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
import caelum_transfer_verify as verification
from caelum_profiles import ProfileError


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime',type=Path,required=True);parser.add_argument('--seed',type=Path,required=True)
    parser.add_argument('--map-fixture',type=Path,required=True);parser.add_argument('--campaign',required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);seed=args.seed.resolve(strict=True)
    fixture=args.map_fixture.resolve(strict=True);data=seed.read_bytes()
    engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
    iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
    out=ROOT/'build/issue435'/datetime.datetime.now().strftime('native-load-matrix-%Y%m%d-%H%M%S-%f');out.mkdir(parents=True)
    command=verification.command;reports=[]
    for run,windowed in enumerate((False,True,False,True,False,True)):
        def prepare(*positional,**keywords):
            cmd,peer=command(*positional,**keywords)
            if windowed:
                with (peer/'session.ini').open('a') as stream:stream.write('vid_fullscreen=false\n')
            return cmd,peer
        verification.command=prepare;directory=out/f'{run}-{int(windowed)}';start=datetime.datetime.now(datetime.timezone.utc).isoformat()
        try:
            checkpoint,report=verification.native_checkpoint(data,args.campaign,directory,engine,iwad,[runtime,fixture],31435)
        except (ProfileError,OSError) as exc:report=dict(passed=False,error=str(exc))
        finally:verification.command=command
        report.update(directory=str(directory),windowed_override=windowed,started_utc=start,ended_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
        reports.append(report);print(run,'windowed' if windowed else 'defaults','passed',report['passed'],flush=True)
        assert seed.read_bytes()==data,'The retained input changed'
        (out/'results.json').write_text(json.dumps(dict(seed=str(seed),seed_sha256=hashlib.sha256(data).hexdigest(),
            runtime_sha256=hashlib.sha256(runtime.read_bytes()).hexdigest(),fixture_sha256=hashlib.sha256(fixture.read_bytes()).hexdigest(),
            runs=reports,qualification='Six local load attempts are a bounded diagnostic, not proof of stability or a production mitigation. A windowed request may match current launcher defaults.'),indent=2)+'\n')
    print('Retained load matrix:',out,flush=True)


if __name__=='__main__':main()
