"""Export original clothing ensembles with closed thin-walled garment shells."""
from pathlib import Path
import argparse
import json
import math
import zipfile
from collections import defaultdict
try:
    from .generate_inventory_ammunition_models import ROOT,digest,output_files as shared_output
    from .generate_inventory_consumable_models import geometry as shared_geometry
    from .generate_nahuelito_model import Mesh
except ImportError:
    from generate_inventory_ammunition_models import ROOT,digest,output_files as shared_output
    from generate_inventory_consumable_models import geometry as shared_geometry
    from generate_nahuelito_model import Mesh

SOURCE=ROOT/'assets/source/art/inventory_models_647/clothing'


def garment_shell(shape):
    """Join inner/outer cloth walls and rims, including open-front arc ends."""
    mesh=Mesh();rows=shape['rows'];segments=shape['segments']
    start,stop=shape.get('arc_degrees',(0,360));full=abs(stop-start-360)<1e-9
    thickness=shape['thickness'];rings=[]
    low=min(r[0] for r in rows);high=max(r[0] for r in rows)
    for side in (0,1):
        side_rings=[]
        for index,(z,x,y,rx,ry) in enumerate(rows):
            ring=[]
            for step in range(segments+1):
                angle=math.radians(start+(stop-start)*step/segments)
                c,s=math.cos(angle),math.sin(angle)
                if abs(c)<1e-12:c=0
                if abs(s)<1e-12:s=0
                exponent=shape.get('exponent',1)
                c=math.copysign(abs(c)**exponent,c);s=math.copysign(abs(s)**exponent,s)
                radius_x=rx-side*thickness;radius_y=ry-side*thickness
                if min(radius_x,radius_y)<=0:raise ValueError('Shell thickness closes its opening')
                wave=shape.get('fold_amplitude',0)*math.cos(shape.get('fold_count',8)*angle)
                lift=shape.get('row_lift',[0]*len(rows))[index]*abs(s)
                point=(x+(radius_x+wave)*c,y+(radius_y+wave)*s,z+lift)
                ring.append(mesh.vertex(point,(step/segments,1-(z-low)/(high-low)),shape['part']))
            side_rings.append(ring)
        rings.append(side_rings)
    material=shape['material']
    def quad(indices,reverse=False):mesh.quad(tuple(reversed(indices)) if reverse else tuple(indices),material)
    for side in (0,1):
        for row in range(len(rows)-1):
            for step in range(segments):
                quad((rings[side][row][step],rings[side][row][step+1],rings[side][row+1][step+1],rings[side][row+1][step]),side==1)
    for row,reverse in ((0,True),(len(rows)-1,False)):
        for step in range(segments):
            quad((rings[0][row][step],rings[0][row][step+1],rings[1][row][step+1],rings[1][row][step]),reverse)
    if not full:
        for step,reverse in ((0,False),(segments,True)):
            for row in range(len(rows)-1):
                quad((rings[0][row][step],rings[0][row+1][step],rings[1][row+1][step],rings[1][row][step]),reverse)
    edges=defaultdict(int);directions=defaultdict(int);volume=0
    for _,triangle in mesh.faces:
        points=[tuple(round(v,7) for v in mesh.vertices[i]) for i in triangle]
        for a,b in zip(points,points[1:]+points[:1]):
            edge=tuple(sorted((a,b)));edges[edge]+=1;directions[edge]+=1 if a<b else -1
        a,b,c=points;volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
    if any(v!=2 for v in edges.values()) or any(directions.values()) or volume<=0:
        raise ValueError('Invalid garment shell: '+shape['part']+' volume='+str(volume))
    return mesh,{shape['part']:volume}


def front_samples(x,z,triangles):
    """Intersect actual triangles along Y using barycentrics in the XZ plane."""
    values=[]
    for a,b,c in triangles:
        ux,uz=b[0]-a[0],b[2]-a[2];vx,vz=c[0]-a[0],c[2]-a[2]
        determinant=ux*vz-uz*vx
        if abs(determinant)<1e-10:continue
        dx,dz=x-a[0],z-a[2];u=(dx*vz-dz*vx)/determinant;v=(ux*dz-uz*dx)/determinant
        if u>=-1e-7 and v>=-1e-7 and u+v<=1+1e-7:
            values.append(a[1]+u*(b[1]-a[1])+v*(c[1]-a[1]))
    return values


def geometry(config,family,tier):
    if len(family['parts'])!=1:raise ValueError('Inventory writer must supply one component')
    shape=family['parts'][0]
    if shape['kind']=='garment_shell':return garment_shell(shape)
    mesh,volumes=shared_geometry(config,family,tier)
    if 'attachment_target' not in shape:return mesh,volumes
    target=next(p for p in family['all_parts'] if p['part']==shape['attachment_target'])
    parent,_=geometry(config,{'parts':[target], 'all_parts':family['all_parts']},tier)
    matrix=target['rotation'];offset=target['offset']
    points=[tuple(sum(a*b for a,b in zip(row,point))+offset[i] for i,row in enumerate(matrix)) for point in parent.vertices]
    triangles=[[points[i] for i in tri] for _,tri in parent.faces]
    profile=shape['surface_profile'];offset=shape['offset'];fitted=[]
    for x,y,z in mesh.vertices:
        rx,ry,cy=profile[0][1:] if z<=profile[0][0] else profile[-1][1:]
        for before,after in zip(profile,profile[1:]):
            if before[0]<=z<=after[0]:
                fraction=(z-before[0])/(after[0]-before[0]);rx,ry,cy=(a+(b-a)*fraction for a,b in zip(before[1:],after[1:]));break
        old=cy-ry*math.sqrt(max(0,1-(x/rx)**2))-shape['surface_offset']
        candidates=[value for value in front_samples(x+offset[0],z+offset[2],triangles) if abs(value-old-offset[1])<=shape['surface_fit_limit']]
        if not candidates:
            if not shape.get('allow_free_edge',False):raise ValueError('Surface detail misses garment: '+shape['part'])
            fitted.append((x,y,z))
        else:fitted.append((x,min(candidates)-offset[1]+y-old,z))
    mesh.vertices=fitted
    volume=0
    for _,tri in mesh.faces:
        a,b,c=(mesh.vertices[i] for i in tri)
        volume+=(a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0]))/6
    if volume<=0:raise ValueError('Surface fitting inverted detail: '+shape['part'])
    return mesh,{shape['part']:volume}


def output_files():
    files=shared_output(SOURCE,'inventory_clothing.modeldef',('DESIGN.json','PROVENANCE.json'),Path(__file__).name,geometry)
    config=json.loads((SOURCE/'DESIGN.json').read_text())
    for native,original in config['texture_sources'].items():files[native]=(ROOT/original).read_bytes()
    report=json.loads(files['manifest.json']);report['sha256']={name:digest(blob) for name,blob in files.items() if name!='manifest.json'}
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode();return files


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true');parser.add_argument('--check',action='store_true');args=parser.parse_args()
    files=output_files()
    for name,blob in files.items():
        destinations=[args.output/name]
        if args.install:destinations.append(SOURCE/'EXPORT.json' if name=='manifest.json' else SOURCE/name if name.startswith('editable/') else ROOT/'src'/name)
        for path in destinations:
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale clothing export: '+str(path))
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if not args.check:
        with zipfile.ZipFile(args.output/'preview.pk3','w') as archive:
            for name,blob in sorted(files.items()):
                if name=='manifest.json' or name.startswith('editable/'):continue
                archive.writestr(zipfile.ZipInfo('MODELDEF' if name.endswith('.modeldef') else name,(2026,11,14,0,0,0)),blob)
        if args.install:
            config=json.loads((SOURCE/'DESIGN.json').read_text())
            for name in config['texture_sources']:
                path=SOURCE/'editable/src'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(files[name])
    print(json.dumps({name:item['triangles'] for name,item in json.loads(files['manifest.json'])['variants'].items()}))


if __name__=='__main__':main()
