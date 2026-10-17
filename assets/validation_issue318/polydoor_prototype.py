"""Build an isolated finite-height native PolyObject fixture from owned assets."""
from pathlib import Path
import argparse
import shutil
from geometry_probe import pack_wad
from geometry_verify import package

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
a=p.parse_args();work=ROOT/'build'/a.directory/'current';work.mkdir(parents=True,exist_ok=False)
shutil.copyfile(ROOT/'build/issue318-geometry-04/current/runtime.pk3',work/'runtime.pk3')
g={k:[] for k in ('vertex','sector','sidedef','linedef','thing')}
def sector():
    g['sector'].append(dict(heightfloor=0,heightceiling=256,texturefloor='CMST02',textureceiling='CMTB04',lightlevel=208))
    return len(g['sector'])-1
def polygon(points,front,back=None,poly=False):
    vi=len(g['vertex']);g['vertex'] += [dict(x=x,y=y) for x,y in points]
    for i in range(len(points)):
        si=len(g['sidedef']);g['sidedef'].append(dict(sector=front,texturemiddle='CA318DR' if poly else 'CMST01'))
        line=dict(v1=vi+i,v2=vi+(i+1)%len(points),sidefront=si)
        if back is not None:
            line.update(sideback=si+1,twosided=True,midtex3d=True,dontpegbottom=True)
            g['sidedef'].append(dict(sector=back,texturemiddle='CA318DR'))
        else:line['blocking']=True
        if poly:
            line['id']=10001
            if i==0:line.update(special=1,arg0=1)
        g['linedef'].append(line)
main,store,inside=sector(),sector(),sector()
polygon([(-512,-512),(-512,512),(512,512),(512,-512)],main)
polygon([(2048,-128),(2048,128),(2304,128),(2304,-128)],store)
polygon([(2112,-4),(2112,4),(2176,4),(2176,-4)],inside,store,True)
for kind,x,y,angle in [(1,0,-200,90),(9300,2176,0,1),(9301,32,0,1)]:
    g['thing'].append(dict(type=kind,x=x,y=y,angle=angle,skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True))
def value(v):return str(v).lower() if isinstance(v,bool) else '"'+v+'"' if isinstance(v,str) else str(v)
text='namespace="ZDoom";\n'+''.join(k+'\n{\n'+''.join(f'{n}={value(v)};\n' for n,v in row.items())+'}\n' for k,rows in g.items() for row in rows)
wad=pack_wad([('MAP98',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')])
package(work/'probe.pk3',{'maps/MAP98.wad':wad,'ZSCRIPT':b'version "4.14"\n#include "probe.zs"\n',
    'probe.zs':(HERE/'polydoor_probe.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA318PolyDoorProbe" }\nmap MAP98 "Native door probe" { next="MAP98" }\n',
    'TEXTURES':b'WallTexture "CA318DR", 64, 120 { Patch "graphics/caelum/textures/mansion/CMDR03.png",0,0 }\n'})
(work/'manifest.json').write_text('{}\n')
(work/'test.cfg').write_text('wait 70; netevent poly_begin; wait 100; screenshot native-poly.png; wait 5; netevent poly_done; wait 5; quit\n')
print(work)
