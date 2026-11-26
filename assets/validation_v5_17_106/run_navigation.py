"""Run both demon families, warm/cold emission paths and saved-state checks."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[2];helper=Path(__file__).resolve().parent
boss='--boss' in sys.argv;cold='--cold' in sys.argv;abilities='--abilities' in sys.argv
for flag in ('--boss','--cold','--abilities'):
    if flag in sys.argv:sys.argv.remove(flag)
original=ROOT/'assets/validation_v5_17_96/run_reach_edges.py';source=original.read_text(encoding='utf-8')
start=source.index("    source=(ROOT/'assets/validation_v5_16_2/vision_edge_checks.zs')");end=source.index("    files={'ZSCRIPT':",start)
fixture=(helper/('ability_evidence855.zs' if abilities else 'navigation_evidence855.zs')).read_text(encoding='utf-8').replace('const BOSS=0;','const BOSS='+str(int(boss))+';').replace('const COLD=0;','const COLD='+str(int(cold))+';')
source=source[:start]+'    source='+repr(fixture)+'\n'+source[end:]
source=source.replace('AddEventHandlers="CA836VisionEdges"','AddEventHandlers="CA853NavigationProbe"')
start=source.index("    commands=out/'commands.cfg';");end=source.index('\n',start)
source=source[:start]+"    commands=out/'commands.cfg';commands.write_text(('wait 100; netevent ca855reload; wait 10;' if args.load else 'wait 100; netevent ca853seed; wait 90;')+' save reach.zds; wait 10; quit\\n',encoding='utf-8')"+source[end:]
source=source.replace("'issue':836","'issue':855")
source=source.replace("'Script error','VM execution aborted'","'Script error','Bad type for constant','VM execution aborted'")
source=source.replace('Frozen fixture bodies; force high-density query only during each synchronous check, restore population flag immediately. Original CanSee predicate is the independent reference for actual Candidate selection. Not campaign acceptance.','Frozen native demon family; real one/two-second visual observations. Warm path checks UpdateBreath exclusion; cold path also exercises real PaidTick, owned emission and one-tic cost. Reload checks serialized identity, evidence, Anima and paid duration before further fixture mutation. No performance/author acceptance claim.')
if abilities:
    source=source.replace('Frozen native demon family; real one/two-second visual observations. Warm path checks UpdateBreath exclusion; cold path also exercises real PaidTick, owned emission and one-tic cost. Reload checks serialized identity, evidence, Anima and paid duration before further fixture mutation. No performance/author acceptance claim.','Frozen native Mandinga and Zupay after deferred birth. Ability routing uses explicitly seeded known-target memory; separate navigation cases test real acquisition. Controls exercise combat, exact positive costs, independent cold, real bolas release and interruptions. No performance/author acceptance claim.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
