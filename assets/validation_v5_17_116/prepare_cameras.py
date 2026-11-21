"""Select review cameras and short collision runs from actual vaulted dry cells."""
from pathlib import Path
import argparse,json,math
ROOT=Path(__file__).resolve().parents[2]
manifest=json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
layout=manifest['layout'];grid=layout['grid'];radius=layout['largest_player_radius']
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--planes',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
geometry=json.loads(args.planes.read_text(encoding='utf-8'))
vaulted={tuple(p) for row in geometry['planes'] for p in row['cells']}
cells={(r[0],r[1]):r[2:] for r in manifest['cells']}
rows=[]
def dry_footprint(point):
    x,y=point
    for xx in range(math.floor((x-radius)/grid)*grid,math.floor((x+radius)/grid)*grid+grid,grid):
        for yy in range(math.floor((y-radius)/grid)*grid,math.floor((y+radius)/grid)*grid+grid,grid):
            dx=max(xx-x,x-(xx+grid),0);dy=max(yy-y,y-(yy+grid),0)
            if dx*dx+dy*dy>=radius*radius:continue
            cell=cells.get((xx,yy))
            if cell is None or cell[0]!=0 or cell[1]<layout['largest_supported_height']:return False
    return True
for label,width,axis in [('main_horizontal',layout['passage_width'],0),('main_vertical',layout['passage_width'],1),('service',layout['service_width'],1),('maintenance',layout['shortcut_width'],1)]:
    candidates=[]
    for profile in geometry['profiles']:
        if profile['axis']!=axis or profile['width']!=width:continue
        cross=1-axis
        center=profile['cross']-layout['channel_width']/2 if width==layout['passage_width'] else profile['cross']
        cross_cell=math.floor(center/grid)*grid
        along=sorted(p[axis] for p in vaulted if p[cross]==cross_cell and cells[p][0]==0 and profile['low']<=p[axis]<profile['high'])
        if not along:continue
        runs=[];run=[along[0]]
        for value in along[1:]:
            if value!=run[-1]+grid:runs.append(run);run=[]
            run.append(value)
        runs.append(run)
        for run in runs:
            trim=math.ceil(radius/grid)*grid
            low=run[0]+trim+grid/2;high=run[-1]-trim+grid/2
            if high-low<width:continue
            start=[0,0,0];end=[0,0,0];point=[0,0]
            start[axis]=low;end[axis]=high;point[axis]=(low+high)/2
            start[cross]=end[cross]=point[cross]=center
            dry_width=layout['dry_width'] if width==layout['passage_width'] else width
            count=2 if dry_width>=4*radius else 1
            lanes=[-dry_width/4,dry_width/4] if count==2 else [0]
            valid=True
            for offset in lanes:
                for step in range(int((high-low)/(grid/4))+1):
                    position=list(start[:2]);position[axis]+=step*grid/4;position[cross]+=offset
                    if not dry_footprint(position):valid=False;break
                if not valid:break
            if not valid:continue
            candidates.append(dict(name=label,point=point,angle=0 if axis==0 else 90,axis=axis,
                span_mu=width,dry_width_mu=dry_width,start=start,end=end,bodies=count,
                lane_offsets=lanes,
                segment=profile,clear_run_mu=high-low))
    assert candidates,label
    # Preserve source order; prefer the longest continuous dry run in the first matching section.
    first_label=candidates[0]['segment']['label']
    own=[r for r in candidates if r['segment']['label']==first_label]
    rows.append(max(own,key=lambda r:r['clear_run_mu']))
result=dict(issue=875,source='Existing LAYOUT dimensions and actual vaulted dry cells; diagnostic viewpoints, not new game coordinates.',
    radius=radius,height=layout['largest_supported_height'],step_mu=grid/4,rows=rows)
out=args.output.resolve();out.relative_to(ROOT/'build');assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(dict(cases=len(rows),output=str(out))))
