"""Register painted sprites and deterministic original low-poly bathroom meshes."""
import hashlib
import json
import math
from pathlib import Path
import sys
sys.dont_write_bytecode=True
from PIL import Image
from generate_stash_models import Mesh, WOOD, METAL, LOCK

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/art_source/bathrooms'
DATA=json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
CERAMIC='models/caelum/props/bathrooms/enamel.png'
SHADE='models/caelum/props/stations/ca_station_paper.png'
UNITS=DATA['map_units_per_meter']


def box(mesh, material, center, dimensions):
    mesh.add_box(material,tuple(v*UNITS for v in center),tuple(v*UNITS for v in dimensions))


def rings(mesh, material, profile, center=(0,0,0), sides=24):
    """Elliptical profile in metres, including rolled rim and hollow interior."""
    cx,cy,cz=center
    def point(row,index):
        rx,rz,y=row;a=2*math.pi*index/sides
        return ((cx+rx*math.cos(a))*UNITS,(cy+y)*UNITS,(cz+rz*math.sin(a))*UNITS)
    for first,second in zip(profile,profile[1:]):
        for index in range(sides):
            mesh.add_quad(material,(point(first,index),point(first,index+1),point(second,index+1),point(second,index)))


def tap(mesh,x,y,z):
    box(mesh,LOCK,(x,y,z),(.025,.12,.025))
    box(mesh,LOCK,(x,y+.045,z+.035),(.025,.025,.09))
    box(mesh,LOCK,(x,y+.08,z),(.09,.012,.012))


def bathtub():
    mesh=Mesh()
    rings(mesh,METAL,[(.6,.22,.14),(.72,.29,.24),(.9,.4,.60),(.9,.4,.64)])
    rings(mesh,CERAMIC,[(.9,.4,.64),(.89,.39,.66),(.84,.34,.64)])
    rings(mesh,SHADE,[(.84,.34,.64),(.76,.27,.38),(.6,.20,.22)])
    rings(mesh,CERAMIC,[(.6,.20,.22),(0,0,.22)])
    rings(mesh,METAL,[(.023,.023,.223),(0,0,.223)],center=(-.38,0,0))
    for x in [-.62,.62]:
        for z in [-.25,.25]:
            box(mesh,METAL,(x,.095,z),(.10,.19,.10))
            box(mesh,METAL,(x,.025,z+.025),(.14,.05,.16))
    for x in [-.18,.18]:tap(mesh,x,.65,-.30)
    return mesh


def sink():
    mesh=Mesh()
    # Hollow cabinet leaves room for the inset bowl without a floating counter.
    for x in [-.355,.355]:box(mesh,WOOD,(x,.435,0),(.03,.69,.51))
    for z in [-.24,.24]:box(mesh,WOOD,(0,.435,z),(.68,.69,.03))
    box(mesh,WOOD,(0,.105,0),(.74,.03,.51))
    for x in [-.34,.34]:
        for z in [-.23,.23]:box(mesh,WOOD,(x,.08,z),(.07,.16,.07))
    for x in [-.2,.2]:
        box(mesh,WOOD,(x,.40,.265),(.32,.46,.025))
        box(mesh,LOCK,(x/3,.43,.288),(.025,.025,.025))
    # Continuous rectangular counter with an elliptical opening, no corner gaps.
    for i in range(24):
        pts=[]
        for j,outer in [(i,True),(i+1,True),(i+1,False),(i,False)]:
            angle=2*math.pi*j/24;x,z=math.cos(angle),math.sin(angle)
            if outer:
                edge=min(.40/max(abs(x),1e-9),.285/max(abs(z),1e-9));x*=edge;z*=edge
            else:x*=.31;z*=.22
            pts.append((x*UNITS,.81*UNITS,z*UNITS))
        mesh.add_quad(CERAMIC,pts)
    rings(mesh,CERAMIC,[(.31,.22,.81),(.28,.19,.80)])
    rings(mesh,SHADE,[(.28,.19,.80),(.21,.13,.68)])
    rings(mesh,CERAMIC,[(.21,.13,.68),(0,0,.68)])
    rings(mesh,METAL,[(.02,.02,.683),(0,0,.683)])
    box(mesh,WOOD,(0,.89,-.265),(.80,.22,.04))
    tap(mesh,0,.87,-.18)
    return mesh


def toilet():
    mesh=Mesh()
    rings(mesh,CERAMIC,[(.13,.19,0),(.14,.20,.06),(.10,.14,.12),(.10,.14,.25),(.25,.31,.43),(.25,.31,.48),(.20,.25,.48)])
    rings(mesh,SHADE,[(.20,.25,.48),(.10,.13,.32),(0,0,.32)])
    rings(mesh,METAL,[(.04,.05,.323),(0,0,.323)])
    rings(mesh,WOOD,[(.26,.325,.48),(.26,.325,.52),(.20,.25,.52),(.20,.25,.48),(.26,.325,.48)])
    box(mesh,METAL,(0,1.04,-.25),(.045,1.08,.045))
    box(mesh,METAL,(0,1.72,-.23),(.48,.30,.22))
    box(mesh,METAL,(0,1.885,-.23),(.52,.03,.26))
    box(mesh,LOCK,(.25,1.57,-.22),(.01,.48,.01))
    box(mesh,LOCK,(.25,1.30,-.22),(.025,.07,.025))
    return mesh


def main():
    folder=ROOT/'src/models/caelum/props/bathrooms';folder.mkdir(parents=True,exist_ok=True)
    icons=ROOT/'src/graphics/caelum/icons/bathrooms';icons.mkdir(parents=True,exist_ok=True)
    inputs=[Path(__file__),ART/'DATA.json',ART/'PROMPTS.json',ROOT/'assets/generators/generate_stash_models.py',*[ROOT/'src'/p for p in [WOOD,METAL,LOCK,SHADE]]]
    outputs=[];models=[];textures=[];records={}
    enamel=ART/'enamel-source-v1.png';inputs.append(enamel)
    enamel_out=folder/'enamel.png'
    Image.open(enamel).convert('RGB').resize((64,64),Image.Resampling.LANCZOS).save(enamel_out)
    outputs.append(enamel_out)
    for key,builder in [('sink',sink),('bathtub',bathtub),('toilet',toilet)]:
        row=DATA['fixtures'][key];mesh=builder();model=folder/(key+'.obj');mesh.write(model);outputs.append(model)
        source=ART/row['source'];inputs.append(source)
        image=Image.open(source).convert('RGBA');bounds=image.getbbox();assert bounds and image.getchannel('A').getextrema()[0]==0
        cutout=image.crop(bounds);cutout.thumbnail(tuple(DATA['registration']['fit']),Image.Resampling.LANCZOS)
        icon=Image.new('RGBA',tuple(DATA['registration']['canvas']))
        icon.alpha_composite(cutout,((128-cutout.width)//2,DATA['registration']['bottom']-cutout.height))
        output=icons/(key+'.png');icon.save(output);outputs.append(output)
        registered=icon.getbbox()
        sprite_scale=max((registered[2]-registered[0])/(max(row['dimensions_m'][:2])*UNITS),(registered[3]-registered[1])/(row['dimensions_m'][2]*UNITS))
        textures.append(f'Sprite {row["sprite"]}A0,128,128 {{ XScale {sprite_scale:.6f} YScale {sprite_scale:.6f} Offset 64,122 Patch "graphics/caelum/icons/bathrooms/{key}.png",0,0 }}')
        models.append(f'Model {row["class"]} {{ Path "models/caelum/props/bathrooms" Model 0 "{key}.obj" Scale 1 1 1 AngleOffset -90 CorrectPixelStretch DontCullBackFaces FrameIndex {row["sprite"]} A 0 0 }}')
        records[key]={'vertices':len(mesh.vertices),'sprite_scale':sprite_scale,'source_alpha_bounds':bounds,'registered_alpha_bounds':registered,
            'mesh_bounds_mu':[[min(p[i] for p in mesh.vertices),max(p[i] for p in mesh.vertices)] for i in range(3)]}
    for name,lines in [('domestic_bathrooms.textures',textures),('domestic_bathrooms.modeldef',models)]:
        path=ROOT/'src/caelum/data'/name;path.write_text('\n'.join(lines)+'\n',encoding='utf-8');outputs.append(path)
    # Geometry and placements are generated from one author-delegated table.
    code=['// #410: generado desde assets/art_source/bathrooms/DATA.json.','class CaelumDomesticFixtureData : Object play','{','    const REVISION=1;','    const COUNT=3;']
    for method,calculate,kind in [('Radius',lambda row:max(row['dimensions_m'][:2])*UNITS/2,'double'),('Height',lambda row:row['dimensions_m'][2]*UNITS,'double'),('Facing',lambda row:row['facing'],'double')]:
        code.append(f'    static {kind} {method}(int kind){{switch(kind){{')
        for row in DATA['fixtures'].values():code.append(f'        case {row["id"]}:return {calculate(row):.6f};')
        code.append('        }return 0;}')
    code.append('    static vector3 Offset(int kind){switch(kind){')
    for row in DATA['fixtures'].values():code.append(f'        case {row["id"]}:return ({",".join(map(str,row["offset_mu"]))});')
    code.append('        }return (0,0,0);}')
    code.append('    static Name ActorClass(int kind){switch(kind){')
    for row in DATA['fixtures'].values():code.append(f'        case {row["id"]}:return "{row["class"]}";')
    code += ['        }return "None";}','}']
    path=ROOT/'src/caelum/data/CaelumDomesticFixtureData.zs';path.write_text('\n'.join(code)+'\n',encoding='utf-8');outputs.append(path)
    water='''// #410: reservas domésticas aprobadas; cada vivienda conserva la suya.
class CaelumDomesticWaterData : Object
{
    const REVISION=1;
    const CAPACITY_LITERS=%.1f;
    const REFILL_LITERS_PER_WORLD_MINUTE=%.1f;
}
''' % (DATA['reserve_liters'],DATA['refill_liters_per_world_minute'])
    path=ROOT/'src/caelum/data/CaelumDomesticWaterData.zs';path.write_text(water,encoding='utf-8');outputs.append(path)
    # Explicit LF keeps the registered byte hashes stable after a Git checkout.
    for path in outputs:
        if path.suffix!='.png':path.write_text(path.read_text(encoding='utf-8'),encoding='utf-8',newline='\n')
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    manifest={'issue':410,'exporter':'Pillow '+Image.__version__,'inputs':{p.relative_to(ROOT).as_posix():digest(p) for p in inputs},'outputs':{p.relative_to(ROOT).as_posix():digest(p) for p in outputs},'assets':records}
    (ART/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Registered three bathroom sprites, models and authoritative placement data.')


if __name__=='__main__':main()
