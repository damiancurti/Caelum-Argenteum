"""Compile and exercise the candidate in a native private room."""
from pathlib import Path
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');helper=Path(__file__).resolve().parent
original=ROOT/'assets/validation_v5_17_96/run_reach_edges.py';source=original.read_text(encoding='utf-8')
start=source.index("    source=(ROOT/'assets/validation_v5_16_2/vision_edge_checks.zs')");end=source.index("    files={'ZSCRIPT':",start)
fixture=(helper/'wardrobe_probe857.zs').read_text(encoding='utf-8');source=source[:start]+'    source='+repr(fixture)+'\n'+source[end:]
source=source.replace('AddEventHandlers="CA836VisionEdges"','PlayerClasses="CaelumDomingoPilotPlayer" AddEventHandlers="CA857WardrobeProbe"')
start=source.index("    commands=out/'commands.cfg';");end=source.index('\n',start)
source=source[:start]+"    commands=out/'commands.cfg';commands.write_text('wait 100; netevent ca857check; wait 10; save reach.zds; wait 10; quit\\n',encoding='utf-8')"+source[end:]
source=source.replace("'issue':836","'issue':857").replace("'Script error','VM execution aborted'","'Script error','Bad type for constant','already exists','VM execution aborted'")
source=source.replace('Frozen fixture bodies; force high-density query only during each synchronous check, restore population flag immediately. Original CanSee predicate is the independent reference for actual Candidate selection. Not campaign acceptance.','Initial native compilation and JIT smoke only: instantiate the existing opt-in player, candidate body and native model-binding path. This does not establish actual equip behavior, save compatibility, performance or visual acceptance.')
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
