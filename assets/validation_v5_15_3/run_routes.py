"""Native walking on the packaged city, with no mass army fixture."""
from pathlib import Path
import sys

if __name__ == '__main__':
    here=Path(__file__).resolve().parent
    source=(here.parent/'validation_v5_15_0/run_native.py').read_text(encoding='utf-8')
    source=source.replace('issue447','issue450').replace('CA447','CA450').replace('ca447','ca450').replace('issue=447','issue=450')
    source=source.replace("(HERE/'checks.zs').read_bytes()","(HERE/'route_checks.zs').read_bytes()")
    source=source.replace('    members = native_sync.instrument(members)',
        "    with zipfile.ZipFile(ROUTE_RUNTIME) as packaged:\n        member=next(n for n in packaged.namelist() if n.lower()=='maps/map03.wad')\n        members['maps/MAP03.wad']=packaged.read(member)\n    members = native_sync.instrument(members)")
    source=source.replace("wait 5; save checkpoint; ","wait 5; +forward; wait 1800; -forward; screenshot stairs.png; netevent ca450_west; wait 5; +forward; wait 650; -forward; screenshot west.png; netevent ca450_report; wait 5; save checkpoint; ")
    source=source.replace("duration=(500 if args.suite=='travel' else 210)+(args.players-i)*35","duration=(60 if i==0 else 2700)+(args.players-i)*35")
    source=source.replace('time.monotonic()+110','time.monotonic()+240')
    source=source.replace("else 'CA450 CHECKPOINT READY failures=0'","else 'CA450 ROUTES PASS'")
    runtime=Path(sys.argv[sys.argv.index('--runtime')+1]).resolve()
    namespace=dict(__file__=__file__,__name__='ca450_routes',ROUTE_RUNTIME=runtime)
    exec(compile(source,__file__,'exec'),namespace)
    namespace['main']()
