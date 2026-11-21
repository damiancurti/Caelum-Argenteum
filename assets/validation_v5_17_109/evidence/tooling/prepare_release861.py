"""Advance only current version markers for the focused hand-selector patch."""
from pathlib import Path
import re
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
for name in ['AGENTS.md']+['docs/'+n for n in ['ASSETS.md','CONTEXT.md','HISTORY.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md']]:
 p=root/name;s=p.read_text(encoding='utf-8');head=s[:1000];assert head.count('Documentation version: **5.17.108**')==1
 s=head.replace('Documentation version: **5.17.108**','Documentation version: **5.17.109**')+s[1000:];p.write_text(s,encoding='utf-8',newline='\n')
p=root/'README.md';s=p.read_text(encoding='utf-8');assert s.count('Current release: 5.17.108.')==1;p.write_text(s.replace('Current release: 5.17.108.','Current release: 5.17.109.',1),encoding='utf-8',newline='\n')
for name in ['src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']:
 p=root/name;s=p.read_text(encoding='utf-8');assert s.count('5.17.108')==1;p.write_text(s.replace('5.17.108','5.17.109'),encoding='utf-8',newline='\n')
print('Current109 markers prepared; canonical new status/evidence follows final tests.')
