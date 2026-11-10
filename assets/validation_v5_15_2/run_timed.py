"""Measure native sabotage/capture timers without manually advancing task work."""
from pathlib import Path

if __name__ == '__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue449').replace('CA447','CA449').replace('ca447','ca449').replace('issue=447','issue=449')
    source=source.replace("(HERE/'checks.zs').read_bytes()","(HERE/'timed_checks.zs').read_bytes()")
    source=source.replace("wait 5; save checkpoint; ","wait 2140; +attack; wait 2; -attack; wait 760; +altattack; wait 2; -altattack; save checkpoint; ")
    source=source.replace("duration=(500 if args.suite=='travel' else 210)+(args.players-i)*35","duration=(300 if i==0 else 3300)+(args.players-i)*35")
    source=source.replace('time.monotonic()+110','time.monotonic()+180')
    source=source.replace("else 'CA449 CHECKPOINT READY failures=0'","else 'CA449 TIMED PASS'")
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))
