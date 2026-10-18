"""Derive a deterministic escort itinerary from MAP02's maintained upper layout."""
from collections import deque
import json
import math
from pathlib import Path
import re

def source(root):
    manifest=json.loads((root/'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    grid=manifest['layout']['grid']
    cells={(c[0]//grid,c[1]//grid):c for c in manifest['upper_cells'] if c[2]>=-16 and c[3]-c[2]>=80}
    safe={p for p in cells if all((p[0]+dx,p[1]+dy) in cells for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)])}
    def nearest(point):
        return min(safe,key=lambda p:((p[0]*grid+grid/2-point[0])**2+(p[1]*grid+grid/2-point[1])**2,p))
    stops=[p['cell_center'] for p in manifest['prisoners']]+[manifest['extraction']]
    points=[]; releases=[]
    for leg,(a,b) in enumerate(zip(stops,stops[1:])):
        start,end=nearest(a),nearest(b)
        queue=deque([start]); previous={start:None}
        while queue and end not in previous:
            p=queue.popleft()
            for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)]:
                q=p[0]+dx,p[1]+dy
                if q in safe and q not in previous: previous[q]=p;queue.append(q)
        if end not in previous: raise RuntimeError(f'No route between cells {a} and {b}')
        path=[];p=end
        while p is not None: path.append(p);p=previous[p]
        path.reverse()
        for i,p in enumerate(path):
            if i and i<len(path)-1 and tuple(p[k]-path[i-1][k] for k in (0,1))==tuple(path[i+1][k]-p[k] for k in (0,1)):
                continue
            point=(p[0]*grid+grid//2,p[1]*grid+grid//2,cells[p][2])
            if points and points[-1]==point: continue
            points.append(point);releases.append(leg if i==0 else leg+1 if i==len(path)-1 and leg<3 else -1)
    # Walk beyond the extraction marker so the last follower can enter it
    # before stopping at the authored follow radius behind the player.
    constants=(root/'src/caelum/core/CaelumConstants.zs').read_text(encoding='utf-8')
    follow=float(re.search(r'const PRISONER_FOLLOW_DISTANCE = ([0-9.]+);',constants).group(1))
    dx,dy=(points[-1][i]-points[-2][i] for i in (0,1))
    length=math.hypot(dx,dy)
    extraction=manifest['extraction']
    tail=nearest((extraction[0]+dx/length*follow,extraction[1]+dy/length*follow))
    points.append((tail[0]*grid+grid//2,tail[1]*grid+grid//2,cells[tail][2]))
    releases.append(-1)
    result='// Generated from the maintained MAP02 manifest; diagnostic coordinates only.\nclass CA322RouteData : Object {\n'
    result+=f'const COUNT={len(points)};\nstatic vector3 Point(int i) {{ switch(i) {{\n'
    result+=''.join(f'case {i}:return ({x},{y},{z});\n' for i,(x,y,z) in enumerate(points))
    result+='}return (0,0,0);}\nstatic int ReleaseAt(int i) {switch(i) {\n'
    result+=''.join(f'case {i}:return {release};\n' for i,release in enumerate(releases) if release>=0)
    result+='}return -1;}\n}\n'
    return result.encode(), {'points':points,'release_at':releases,'source':'assets/map02_maze/MAP02_MANIFEST.json'}
