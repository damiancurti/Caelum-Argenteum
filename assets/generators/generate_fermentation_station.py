"""Generate the #487 station mesh, sprite and physical data deterministically."""
from pathlib import Path
import hashlib
import json
import math
import re
from generate_station_models import Mesh, material
from generate_alchemy_station import icon

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE/'fermentation_station.json').read_text(encoding='utf-8'))

def interior_liters():
    source=(ROOT/'src/caelum/core/CaelumPhysicsUnits.zs').read_text(encoding='utf-8')
    units=float(re.search(r'MAP_UNITS_PER_METER\s*=\s*([0-9.]+)',source).group(1))
    scale=DATA['model_scale']/units
    profile=[(y*scale,r*scale) for y,r in DATA['body_profile_y_radius']]
    wall=DATA['wall_and_lid_meters']
    lower,upper=profile[0][0]+wall,profile[-1][0]-wall
    def radius(y):
        for (a,ra),(b,rb) in zip(profile,profile[1:]):
            if a<=y<=b:return ra+(rb-ra)*(y-a)/(b-a)-wall
        raise ValueError('Profile coordinate outside the body')
    cuts=sorted({lower,upper,*[y for y,r in profile if lower<y<upper]})
    volume=sum(math.pi*(b-a)*(radius(a)**2+radius(a)*radius(b)+radius(b)**2)/3
               for a,b in zip(cuts,cuts[1:]))
    return volume*1000, units

def geometry():
    mesh=Mesh(DATA['actor'])
    profile=DATA['body_profile_y_radius']
    for i,((a,ra),(b,rb)) in enumerate(zip(profile,profile[1:])):
        mesh.add_frustum(material('wood'),(0,a,0),(0,b,0),ra,rb,DATA['segments'],
                         cap_start=i==0,cap_end=i==len(profile)-2)
    for y,r in DATA['hoops_y_radius']:
        mesh.ring('iron',(0,y,0),r,DATA['hoop_tube_radius'],plane='xz',segments=DATA['segments'])
    bung=DATA['bung'];tap=DATA['tap']
    mesh.rod('wood',bung['bottom'],bung['top'],bung['radius'],sides=DATA['segments'])
    mesh.rod('brass',tap['start'],tap['end'],tap['radius'])
    return mesh

def main():
    mesh=geometry()
    model=ROOT/'src/models/caelum/props/stations/ca_station_fermentation.obj'
    sprite=ROOT/'src/sprites/CFERA0.png'
    model.parent.mkdir(parents=True,exist_ok=True)
    mesh.write(model);icon(mesh,sprite)
    capacity,units=interior_liters()
    useful=math.floor(capacity*(1-DATA['fermentation_headspace_fraction']))
    lines=['// Generado por generate_fermentation_station.py; editar fermentation_station.json.',
           'class CaelumFermentationData : Object','{',f'    const REVISION = {DATA["revision"]};',
           f'    const INTERIOR_CAPACITY_LITERS = {capacity:.6f};',
           f'    const WORKING_CAPACITY_LITERS = {useful};']
    for name,kind,values,fallback in [
        ('Position','Vector3',[f'({",".join(map(str,p["position"]))})' for p in DATA['placements']], '(0,0,0)'),
        ('Group','int',[str(p['group']) for p in DATA['placements']], '0'),
        ('Angle','double',[str(p['angle']) for p in DATA['placements']], '0')]:
        lines += [f'    static {kind} {name}(String map)','    {']
        lines += [f'        if(map=="{p["map"]}")return {v};' for p,v in zip(DATA['placements'],values)]
        lines += [f'        return {fallback};','    }']
    lines += ['    static bool Supports(String map)','    {',
              '        return '+' || '.join(f'map=="{p["map"]}"' for p in DATA['placements'])+';', '    }','}']
    source=ROOT/'src/caelum/data/CaelumFermentationData.zs'
    source.write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    bounds=[[min(v[i] for v in mesh.vertices),max(v[i] for v in mesh.vertices)] for i in range(3)]
    manifest={'issue':487,'provenance':DATA['provenance'],'vertices':len(mesh.vertices),
              'faces':len(mesh.faces),'model_bounds_xyz_y_up':bounds,'actor_model_scale':DATA['model_scale'],
              'map_units_per_meter':units,'interior_liters':capacity,'working_liters':useful,
              'capacity_model':DATA['capacity_model'],
              'outputs':{p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in (model,sprite,source)}}
    (HERE/'fermentation_station_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(manifest,indent=2))

if __name__=='__main__':main()
