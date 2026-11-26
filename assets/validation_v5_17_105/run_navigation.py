"""Run a bounded native visual-memory regression using retained room tooling."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
helper=Path(__file__).resolve().parent
original=ROOT/'assets/validation_v5_17_96/run_reach_edges.py';source=original.read_text(encoding='utf-8')
start=source.index("    source=(ROOT/'assets/validation_v5_16_2/vision_edge_checks.zs')");end=source.index("    files={'ZSCRIPT':",start)
fixture=(helper/'navigation_evidence853.zs').read_text(encoding='utf-8')
source=source[:start]+'    source='+repr(fixture)+'\n'+source[end:]
source=source.replace('AddEventHandlers="CA836VisionEdges"','AddEventHandlers="CA853NavigationProbe"')
start=source.index("    commands=out/'commands.cfg';");end=source.index('\n',start)
source=source[:start]+"    commands=out/'commands.cfg';commands.write_text('wait 100; netevent ca853seed; wait 90; quit\\n',encoding='utf-8')"+source[end:]
source=source.replace("'issue':836","'issue':853")
source=source.replace('Frozen fixture bodies; force high-density query only during each synchronous check, restore population flag immediately. Original CanSee predicate is the independent reference for actual Candidate selection. Not campaign acceptance.','Frozen native Mandinga; real elapsed one/two-second observations. Checks whether a breath-excluded route marker erases private visual recognition. An expected baseline regression is a failed assertion, not a native compile/runtime error. No production mutation or author acceptance.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
