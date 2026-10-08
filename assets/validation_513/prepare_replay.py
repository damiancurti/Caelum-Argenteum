"""Generate a source-bound collision reproduction from the original failed route."""
import re
from pathlib import Path
from prepare import OUT, package

log=(OUT/'route-control-a.txt').read_text(encoding='utf-8')
rows=[m.groups() for m in re.finditer(r'ROUTE_PENDING id=(\d+) step=(\d+) complete=(\d+).*?pos=([-\d.]+),([-\d.]+),([-\d.]+)',log)]
code='class CA133ReplayData : Object play {\nstatic vector3 Position(int i,vector3 fallback){switch(i){\n'
for i,step,done,x,y,z in rows:
    code+=f'case {i}:return ({x},{y},{z});\n'
code+='}return fallback;}\nstatic int Step(int i){switch(i){\n'
for i,step,done,*pos in rows:code+=f'case {i}:return {step};\n'
code+='}return 0;}\nstatic bool Complete(int i){switch(i){\n'
for i,step,done,*pos in rows:code+=f'case {i}:return {done};\n'
code+='}return true;}\n}\n'
source=Path(__file__).with_name('replay.zs').read_text(encoding='utf-8')
package('replay.pk3',{'ZSCRIPT':('version "4.14"\n'+code+source).encode(),'MAPINFO':b'GameInfo { AddEventHandlers = "CA133Replay" }\n'})
(OUT/'replay.cfg').write_text('wait 470; quit\n',encoding='utf-8')
