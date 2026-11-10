"""Load an untouched pre-449 native save and retain a tested original rollback."""
from pathlib import Path

if __name__ == '__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue449').replace('CA447','CA449').replace('ca447','ca449').replace('issue=447','issue=449')
    source=source.replace("(HERE/'checks.zs').read_bytes()","(HERE/'migration_checks.zs').read_bytes()")
    start=source.index('    if legacy:\n');end=source.index('    members = native_sync.instrument(members)',start)
    source=source[:start]+'''    if legacy:
        content=members['checks.zs'].decode('utf-8')
        begin=content.index('        // BEGIN CURRENT VERIFICATION')
        finish=content.index('        // END CURRENT VERIFICATION')
        content=content[:begin]+'        Check(Gun.Neutralized && Gun.Blocks[0]==SavedBlock && Ram.TarotDestroyed && Port.Victory,"original package and original save remain recoverable");\\n'+content[finish:]
        members['checks.zs']=content.encode('utf-8')
'''+source[end:]
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))
