"""Reuse retained native fixtures and original art; prepare only review corrections."""
from pathlib import Path
import zipfile,struct
R=Path(__file__).resolve().parents[2];W=R/'build/issue417-incidents';W.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(R.parent/'issue417-incidents-work/build/issue417-incidents/author-5844.pk3') as z:
    files={n:z.read(n) for n in z.namelist()}
files['ZSCRIPT']+=b'\n#include "water.zs"\n#include "review.zs"\n'
files['water.zs']=(R/'assets/validation_5825/checks.zs').read_bytes()
files['review.zs']=(R/'assets/validation_5854/checks.zs').read_bytes()
text='namespace="ZDoom";\n'
for x,y in [(-512,-512),(-512,512),(512,512),(512,-512)]:text+=f'vertex {{ x={x}; y={y}; }}\n'
for i in range(4):text+=f'sidedef {{sector=0;texturemiddle="CMST01";}}\nlinedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}\n'
text+='sector {heightfloor=0;heightceiling=256;texturefloor="CMST01";textureceiling="CMST01";lightlevel=224;}\nthing {x=0;y=-256;type=1;angle=90;}\n'
lumps=[('CRVW410',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')];payload=b'';directory=b''
for n,b in lumps:directory+=struct.pack('<ii8s',12+len(payload),len(b),n.encode());payload+=b
files['maps/CRVW410.wad']=b'PWAD'+struct.pack('<ii',3,12+len(payload))+payload+directory
files['MAPINFO']=b'GameInfo {AddEventHandlers="CA410ReviewChecks"}\nmap CRVW410 "Furniture corrections" {cluster=434}\n'
with zipfile.ZipFile(W/'review410.pk3','w') as z:
    for n,b in sorted(files.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),b)
for case in ['water','decor']:(W/f'review410-{case}.cfg').write_text(f'wait 210; netevent ca410review_{case}; wait 10; quit\n')
for page in [0,1]:(W/f'review410-gallery{page}.cfg').write_text(f'wait 140; netevent ca410review_gallery {page}; wait 35; screenshot review410-gallery{page}.png; wait 10; quit\n')
