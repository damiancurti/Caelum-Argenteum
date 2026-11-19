"""Extend the retained native reach/save harness with relationship fallbacks."""
from pathlib import Path
import sys,zipfile
helper=Path(__file__).resolve().parent
root=helper.parents[1]/'build/v517/work-713'
index=sys.argv.index('--baseline');baseline=Path(sys.argv[index+1]);del sys.argv[index:index+2]
with zipfile.ZipFile(baseline) as z:reference=z.read('caelum/actors/CaelumVisualPerception.zs').decode('utf-8').replace('\r\n','\n')
reference=reference.replace('class CaelumVisualPerception : Object play','class CA838BaselinePerception : Object play',1)
extra=reference+'\n'+(helper/'relation_edges838.zs').read_text(encoding='utf-8')
original=root/'assets/validation_v5_17_96/run_reach_edges.py'
source=original.read_text(encoding='utf-8')
anchor="    files={'ZSCRIPT':"
assert source.count(anchor)==1
source=source.replace(anchor,'    source += '+repr('\n'+extra)+'\n'+anchor,1)
source=source.replace('AddEventHandlers="CA836VisionEdges"','AddEventHandlers="CA836VisionEdges", "CA838RelationEdges"')
assert 'AddEventHandlers="CA836VisionEdges", "CA838RelationEdges"' in source
source=source.replace("'issue':836","'issue':838")
exec(compile(source,str(original),'exec'),{'__name__':'__main__','__file__':str(original)})
