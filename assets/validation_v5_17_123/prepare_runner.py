"""Capture an existing interactive runner's native command without launching it.

This executes trusted repository tooling in a separate Python process. Only the
known engine launch is intercepted; tasklist and other prerequisite commands
retain their normal behavior. Original fixture sources remain untouched.
"""
from pathlib import Path
import argparse,json,runpy,subprocess,sys

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe').resolve()

class Captured(BaseException):
    pass

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--script',type=Path,required=True)
    parser.add_argument('--record',type=Path,required=True)
    parser.add_argument('arguments',nargs=argparse.REMAINDER)
    args=parser.parse_args()
    script=args.script.resolve(strict=True);script.relative_to(ROOT/'assets')
    record=args.record.resolve();record.relative_to(ROOT/'build')
    assert not record.exists()
    original=subprocess.Popen
    def intercept(command,*pos,**kwargs):
        if isinstance(command,(list,tuple)) and Path(str(command[0])).resolve()==ENGINE:
            assert not pos and not kwargs.get('shell')
            command=list(map(str,command))
            assert '-noautoload' in command and '-savedir' in command and '-config' in command
            savedir=Path(command[command.index('-savedir')+1]).resolve()
            savedir.relative_to(ROOT/'build');assert savedir!=ROOT/'build'
            record.parent.mkdir(parents=True,exist_ok=True)
            record.write_text(json.dumps(dict(command=command,cwd=str(Path(kwargs.get('cwd',savedir)).resolve()),
                script=str(script.relative_to(ROOT)),arguments=args.arguments,author_acceptance=False),indent=2)+'\n',encoding='utf-8')
            raise Captured()
        return original(command,*pos,**kwargs)
    subprocess.Popen=intercept
    sys.path.insert(0,str(script.parent))
    sys.argv=[str(script)]+(args.arguments[1:] if args.arguments[:1]==['--'] else args.arguments)
    try:
        runpy.run_path(str(script),run_name='__main__')
    except Captured:
        print('Prepared native command: '+str(record))
    finally:
        subprocess.Popen=original
    assert record.exists(),'Interactive runner did not prepare a native launch'

if __name__=='__main__':
    main()
