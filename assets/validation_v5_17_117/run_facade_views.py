"""Inspect model-only house joinery from authored entrances in four orientations.

Camera placement, invulnerability/notarget and menu dismissal are diagnostic.
Native collisions and actors remain live. This is not a full city walkthrough.
"""
from pathlib import Path
import argparse,importlib.util,json,math,zipfile

ROOT=Path(__file__).resolve().parents[2]
def data(name):return json.loads((ROOT/name).read_text(encoding='utf-8'))
def cameras():
    runtime=data('assets/barracas_redesign/RUNTIME.json');layout=data('assets/barracas_redesign/LAYOUT.json')
    city=data('assets/map06_port/CITY.json');interior=data('assets/map06_port/INTERIORS.json')
    by_id={row['id']:row for row in layout['buildings']};rows=[]
    first=runtime['houses'][0]
    rows.append(dict(name='residential_street',point=first['public_approach'][:2],angle=(first['angle']+90)%360,
                     basis='Existing first-house public approach, looking along its facade'))
    for angle in [0,90,180,270]:
        house=next(h for h in runtime['houses'] if h['angle']==angle);building=by_id[house['building_id']]
        start=house['door_outside'];target=house['portal'];direction=math.radians(angle)
        rows.append(dict(name=f'door_{angle}',point=start[:2],angle=(angle+180)%360,
                         target=[target[0],target[1],city['profiles']['house']['headroom']/2],house=house['identity']))
        # The first original window lies one retained step below the entrance.
        # Derive its center from the existing facade generator's grid, not a new
        # city coordinate or added opening.
        along=city['detail']['window_step']-interior['house_size'][1]/2
        center=[(building['bounds'][0]+building['bounds'][2])/2,(building['bounds'][1]+building['bounds'][3])/2]
        normal=[math.cos(direction),math.sin(direction)];side=[-normal[1],normal[0]]
        setback=(sum((start[i]-target[i])**2 for i in range(2)))**.5
        face=interior['house_size'][0]/2
        point=[center[i]+normal[i]*(face+setback)+side[i]*along for i in range(2)]
        target=[center[i]+normal[i]*face+side[i]*along for i in range(2)]+[(city['profiles']['house']['window_sill']+city['profiles']['house']['window_head'])/2]
        rows.append(dict(name=f'window_{angle}',point=[round(v,6) for v in point],angle=(angle+180)%360,
                         target=[round(v,6) for v in target],house=house['identity']))
    return rows

p=argparse.ArgumentParser(description=__doc__)
for name in ['runtime','overlay','output']:p.add_argument('--'+name,type=Path,required=True)
p.add_argument('--render-radius-preview',action='store_true',help='Apply the same private #879 visibility hypothesis to both models; not a production fix')
a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
previous=ROOT/'assets/validation_v5_17_111/run_material_views.py'
spec=importlib.util.spec_from_file_location('retained_world_views',previous);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
points=cameras();base=module.fixture(out,points,['CMEX01'],['CMEX01'])
with zipfile.ZipFile(base) as z:members={n:z.read(n) for n in z.namelist()}
source=members['probe.zs'].decode();source=source.replace('if(View==0)Sizes();','')
begin=source.index('    void Sizes()');end=source.index('    void Place(',begin);source=source[:begin]+source[end:]
lines=[]
for i,row in enumerate(points):
    if 'target' in row:
        target='('+','.join(map(str,row['target']))+')'
        lines.append(f'case {i}: target={target};aim=true;break;')
aim='''user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);
        vector3 target;bool aim=false;
        switch(index){CASES default:break;}
        if(aim)user.Pitch=-atan2(target.Z-(user.Pos.Z+user.ViewHeight),(target.XY-user.Pos.XY).Length());
        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera %d",index);
        // Diagnostico acotado: una consulta de las 160 fachadas por camara.
        let it=ThinkerIterator.Create("CA454Facade31800");Actor item,nearest;double best=1e30;int count=0;
        while((item=Actor(it.Next()))!=null)
        {
            count++;double distance=(item.Pos.XY-user.Pos.XY).Length();
            if(distance<best){best=distance;nearest=item;}
        }
        if(nearest!=null)Console.Printf("CA866 FACADE index=%d count=%d pos=%.3f,%.3f,%.3f floor=%.3f angle=%.3f distance=%.3f",index,count,nearest.Pos.X,nearest.Pos.Y,nearest.Pos.Z,nearest.FloorZ,nearest.Angle,best);

'''.replace('CASES','\n'.join(lines))
anchor='user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);';assert source.count(anchor)==1;source=source.replace(anchor,aim)
radius_preview=None
if a.render_radius_preview:
    model=ROOT/'src/models/caelum/architecture/barracas/house-960-1216.obj'
    vertices=[tuple(map(float,line.split()[1:])) for line in model.read_text().splitlines() if line.startswith('v ')]
    radius=math.ceil(max(math.hypot(v[0],v[2]) for v in vertices))
    radius_preview=dict(issue=879,render_radius=radius,basis='Ceiling of maximum original vertex horizontal radius; identical diagnostic subclass in both runs',production_fix=False)
    members['ZSCRIPT'] += f'class CA879FacadeRadius : CA454Facade31800 {{ Default {{ RenderRadius {radius}; }} }}\n'.encode()
    members['MAPINFO'] += b'\ndoomednums { 31800=CA879FacadeRadius }\n'
    members['MODELDEF']=(ROOT/'src/caelum/data/barracas_facades.modeldef').read_bytes().replace(b'CA454Facade31800',b'CA879FacadeRadius')
members['probe.zs']=source.encode();(out/'probe.zs').write_text(source,encoding='utf-8',newline='\n')
probe=out/'facade-views.pk3'
with zipfile.ZipFile(probe,'x') as z:
    for name,value in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value)
results=[]
for label in ['control','candidate']:
    result=module.run(a.runtime.resolve(),a.overlay.resolve(),out,points,probe,label,'MAP03');results.append(result)
    if not result['passed']:break
report=dict(issue=878,runtime_sha256=module.SHA(a.runtime),overlay_sha256=module.SHA(a.overlay),engine_sha256=module.SHA(module.ENGINE),fixture_sha256=module.SHA(probe),cameras=points,render_radius_preview=radius_preview,runs=results,passed=len(results)==2 and all(r['passed'] for r in results),qualification=__doc__)
(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
raise SystemExit(not report['passed'])
