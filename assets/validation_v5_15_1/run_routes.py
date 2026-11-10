"""Exercise native return routes against the actual packaged MAP03 geometry."""
from pathlib import Path
import sys

if __name__=='__main__':
    here=Path(__file__).resolve().parent
    source=(here.parent/'validation_v5_15_0/run_native.py').read_text(encoding='utf-8')
    source=source.replace('issue447','issue448').replace('CA447','CA448').replace('ca447','ca448').replace('issue=447','issue=448')
    source=source.replace("(HERE/'checks.zs').read_bytes()","(HERE/'route_checks.zs').read_bytes()")
    source=source.replace('    members = native_sync.instrument(members)',
        "    with zipfile.ZipFile(ROUTE_RUNTIME) as packaged:\n        member=next(n for n in packaged.namelist() if n.lower()=='maps/map03.wad')\n        members['maps/MAP03.wad']=packaged.read(member)\n    members = native_sync.instrument(members)")
    source=source.replace("duration=(500 if args.suite=='travel' else 210)+(args.players-i)*35","duration=2800+(args.players-i)*35")
    source=source.replace('time.monotonic()+110','time.monotonic()+180')
    source=source.replace("else 'CA448 CHECKPOINT READY failures=0'","else 'CA448 ROUTES PASS'")
    source=source.replace('save checkpoint; ','save checkpoint; wait 5; screenshot route-start.png; ')
    runtime=Path(sys.argv[sys.argv.index('--runtime')+1]).resolve()
    namespace=dict(__file__=__file__,__name__='ca448_routes',ROUTE_RUNTIME=runtime)
    exec(compile(source,__file__,'exec'),namespace)
    namespace['main']()
