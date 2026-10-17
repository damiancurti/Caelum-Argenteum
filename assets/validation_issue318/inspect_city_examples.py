"""Read local reference-city topology and a bounded set of nearby door records.

Never modify or distribute the supplied WAD/PK3. Coordinates are diagnostic.
UDMF comments are stripped without stripping quoted texture/text values.
"""
from pathlib import Path
from collections import Counter
import argparse
import hashlib
import json
import math
import re
import zipfile
from geometry_probe import read_wad,parse

def read_map(path):
    text=dict(read_wad(path))['TEXTMAP'].decode()
    text=re.sub(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*.*?\*/',
                lambda m:'' if m[0].startswith('/') else m[0],text,flags=re.S)
    return parse(text)

def inspect(path):
    g=read_map(path)
    return {'map_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'counts':{k:len(v) for k,v in g.items()},
        'one_sided_lines':sum('sideback' not in l for l in g['linedef']),
        'line_specials':dict(Counter(l.get('special','0') for l in g['linedef'])),
        '3d_floor_controls':sum(l.get('special')=='160' for l in g['linedef']),
        'common_thing_types':Counter(t['type'] for t in g['thing']).most_common(20)}

def near_door(g,x,y,radius):
    found=[]
    for i,line in enumerate(g['linedef']):
        a,b=[g['vertex'][int(line[k])] for k in ('v1','v2')]
        ax,ay,bx,by=[float(v) for v in (a['x'],a['y'],b['x'],b['y'])]
        dx,dy=bx-ax,by-ay
        t=max(0,min(1,((x-ax)*dx+(y-ay)*dy)/(dx*dx+dy*dy))) if dx or dy else 0
        if math.hypot(ax+t*dx-x,ay+t*dy-y)>radius:continue
        faces=[]
        for key in ('sidefront','sideback'):
            if key in line:
                face=g['sidedef'][int(line[key])]
                faces.append({'side':face,'sector':g['sector'][int(face['sector'])]})
        found.append({'index':i,'a':[ax,ay],'b':[bx,by],'line':line,'faces':faces})
    return {'origin':[x,y],'radius':radius,'lines':found,'things':[dict(index=i,**t)
        for i,t in enumerate(g['thing']) if math.hypot(float(t['x'])-x,float(t['y'])-y)<=radius]}

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('map',type=Path)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--door',nargs=3,type=float,metavar=('X','Y','RADIUS'))
    a=p.parse_args();result=inspect(a.map)
    if a.door:result['near_door']=near_door(read_map(a.map),*a.door)
    a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='near_door'},indent=2))
