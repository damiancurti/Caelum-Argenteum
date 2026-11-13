"""Fit retained ram crew counts to collision-safe local posts for revision4.

Positions are geometry, not new combat statistics. Derive clearance from the
accepted maximum human body and original machine constants. Choose the smallest
even column count that fits the existing guard radius and stops outside the gate.
"""
from pathlib import Path
import argparse
import json
import math
import re

ROOT=Path(__file__).resolve().parents[2]


def generate():
    ram={k:float(v) for k,v in re.findall(r'const (\w+)\s*=\s*([-\d.]+);',(ROOT/'src/caelum/world/CaelumRamData.zs').read_text(encoding='utf-8'))}
    body=json.loads((ROOT/'assets/map02_maze/LAYOUT.json').read_text(encoding='utf-8'))
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8'))
    layout=json.loads((ROOT/'assets/barracas_redesign/LAYOUT.json').read_text(encoding='utf-8'))
    radius=body['largest_player_radius'];profiles=[]
    for large in (False,True):
        scale=ram['LARGE_SCALE'] if large else 1
        count=int(ram['LARGE_CREW' if large else 'SMALL_CREW'])
        # Native actor collision uses axis-aligned XY boxes. At45 degrees a
        # rotated row needs sqrt(2) times the body diameter, not just its radius.
        spacing=math.ceil(max(ram['TRIAL_CREW_STEP']*scale,2*radius*math.sqrt(2)))
        for columns in range(2,count+1,2):
            rows=math.ceil(count/columns)
            front=min((rows-1)*spacing/2,ram['TRIAL_CONTACT_DISTANCE']*scale-2*radius)
            posts=[]
            for slot in range(count):
                column=slot%columns;row=slot//columns
                side=(1 if column%2 else -1)*(ram['TRIAL_CREW_SIDE']*scale+(column//2)*spacing)
                posts.append([round(front-row*spacing,9),round(side,9),0])
            if max(math.hypot(*p[:2])+radius for p in posts)<=ram['GUARD_RADIUS']*scale:break
        else:raise AssertionError('No layout fits the original crew/guard radius')
        minimum=min(math.dist(a,b) for i,a in enumerate(posts) for b in posts[i+1:])
        assert minimum/math.sqrt(2)>=2*radius
        profiles.append({'large':large,'count':count,'scale':scale,'columns':columns,'spacing':spacing,'minimum_separation':minimum,'posts':posts})
    half=math.ceil(max(abs(p[1])+radius for row in profiles for p in row['posts'])/layout['grid'])*layout['grid']
    data={'issue':454,'revision':1,'runtime_enabled':False,'scope':__doc__.strip(),
          'body_source':'assets/map02_maze/LAYOUT.json','clearance_radius':radius,'clearance_height':body['largest_supported_height'],
          'forecourt_width':max(city['walk_width'],half*2),'forecourt_depth':city['walk_width'],'profiles':profiles}
    source=['// Generado por generate_barracas_ram_crews.py; solo puestos, sin cambios de atributos.',
            'class CaelumBarracasRamCrewData : Object { const REVISION=1;',
            f'const CLEARANCE_RADIUS={radius};',
            f'static double Spacing(bool large){{return large?{profiles[1]["spacing"]}:{profiles[0]["spacing"]};}}',
            'static vector3 Offset(bool large,int slot){return large?LargePost(slot):SmallPost(slot);}']
    for row in profiles:
        source.append('static vector3 '+('LargePost' if row['large'] else 'SmallPost')+'(int slot){switch(slot){')
        source.extend(f'case {i}:return ({",".join(map(str,p))});' for i,p in enumerate(row['posts']))
        source.append('}return (0,0,0);}')
    source.append('}')
    return data,'\n'.join(source)+'\n'


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    data,source=generate()
    for path,text in [(ROOT/'assets/barracas_redesign/RAM_CREWS.json',json.dumps(data,indent=2)+'\n'),(ROOT/'src/caelum/world/CaelumBarracasRamCrewData.zs',source)]:
        if args.check:assert path.read_text(encoding='utf-8')==text,path
        else:path.write_text(text,encoding='utf-8',newline='\n')
    print(json.dumps({'forecourt_width':data['forecourt_width'],'profiles':[{k:r[k] for k in ('large','count','columns','spacing','minimum_separation')} for r in data['profiles']]}))


if __name__=='__main__':main()
