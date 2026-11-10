"""Exercise the captured ram with real native guard movement and gate collisions."""
from pathlib import Path

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue449').replace('CA447','CA449').replace('ca447','ca449').replace('issue=447','issue=449')
    source=source.replace("(HERE/'checks.zs').read_bytes()","(HERE/'ram_checks.zs').read_bytes()")
    source=source.replace("duration=(500 if args.suite=='travel' else 210)+(args.players-i)*35","duration=1000+(args.players-i)*35")
    source=source.replace("else 'CA449 CHECKPOINT READY failures=0'","else 'CA449 RAM PASS'")
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))
