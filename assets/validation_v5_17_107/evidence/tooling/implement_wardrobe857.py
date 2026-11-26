"""Integrate the opt-in wardrobe binding and advance current release markers."""
from pathlib import Path
import re,subprocess,zipfile
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
assert subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()=='issue857-equipment-wardrobe'
assert not subprocess.check_output(['git','status','--porcelain'],cwd=root).strip()
with zipfile.ZipFile(root/'build/issue857-prototype05/prototype.pk3') as package:
    for name in package.namelist():
        path=root/'src'/name
        if name in ('CVARINFO','MODELDEF'):
            original=path.read_bytes();nl=b'\r\n' if b'\r\n' in original else b'\n'
            addition=package.read(name).replace(b'\r\n',b'\n').replace(b'\n',nl)
            path.write_bytes(original+nl+addition)
        else:path.write_bytes(package.read(name))
for name in ['AGENTS.md']+['docs/'+n for n in ('ASSETS.md','CONTEXT.md','HISTORY.md','MAP01.txt','PROJECT.md','SPRITE_ART_DIRECTION.md','SYSTEMS.md','TASKS.md')]:
    path=root/name;source=path.read_text(encoding='utf-8');opening,tail=source[:1000],source[1000:]
    opening,count=re.subn(r'(Documentation version:\s*(?:\*\*)?)5\.17\.106',r'\g<1>5.17.107',opening,count=1);assert count==1,name
    path.write_text(opening+tail,encoding='utf-8',newline='\n')
path=root/'README.md';source=path.read_text(encoding='utf-8');assert source.count('Current release: 5.17.106.')==1
path.write_text(source.replace('Current release: 5.17.106.','Current release: 5.17.107.',1),encoding='utf-8',newline='\n')
for name in ('CaelumPhysicalHazards.zs','CaelumSewerMaze.zs'):
    path=root/'src/caelum/world'/name;data=path.read_bytes();assert data.count(b'[Caelum 5.17.106]')==1
    path.write_bytes(data.replace(b'[Caelum 5.17.106]',b'[Caelum 5.17.107]'))
path=root/'.gitattributes';source=path.read_text(encoding='utf-8')
source+='\n# Native first-body wardrobe binding and issue857 evidence.\nassets/validation_v5_17_107/** -text -diff\nassets/validation_v5_17_107/*.py text eol=lf diff\nassets/validation_v5_17_107/*.json text eol=lf diff\n'
path.write_text(source,encoding='utf-8',newline='\n')
print('Integrated tested prototype05 sources and 5.17.107 markers; final evidence/documentation pending.')
