"""Read the untouched #450 native save using its original fixture classes."""
from pathlib import Path

if __name__=='__main__':
    previous=Path(__file__).resolve().parents[1]/'validation_v5_15_0/run_native.py'
    source=previous.read_text(encoding='utf-8')
    source=source.replace('issue447','issue451').replace('CA447','CA451').replace('ca447','ca451').replace('issue=447','issue=451')
    source=source.replace("(HERE/'checks.zs').read_bytes()","(HERE.parent/'validation_v5_15_3/checks.zs').read_bytes()")
    source=source.replace('AddEventHandlers="CA451Checks"','AddEventHandlers="CA450Checks"')
    source=source.replace('netevent ca451_restored','netevent ca450_restored')
    start=source.index('    if legacy:\n');end=source.index('    members = native_sync.instrument(members)',start)
    source=source[:start]+"    content=members['checks.zs'].decode('utf-8')\n    a=content.index('    void Restored()');b=content.index('    void LegacyRestored()',a)\n    content=content[:a]+(HERE/'migration_body.zs').read_text(encoding='utf-8')+content[b:]\n    members['checks.zs']=content.encode('utf-8')\n"+source[end:]
    exec(compile(source,str(previous),'exec'),dict(__file__=__file__,__name__='__main__'))
