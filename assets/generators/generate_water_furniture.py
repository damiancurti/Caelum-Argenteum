"""Build original iron fountain/cistern meshes and register painted source icons."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode = True
from PIL import Image
from generate_stash_models import Mesh, LOCK
METAL = 'models/caelum/props/kitchen/iron-painted-v1.png'

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT/'assets/art_source/water_furniture'
D = json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
U = D['map_units_per_meter']


class Construction:
    def __init__(self):
        self.mesh = Mesh()
        self.volume = 0.0

    def box(self, center, size, material=METAL):
        self.mesh.add_box(material, tuple(x*U for x in center), tuple(x*U for x in size))
        self.volume += math.prod(size)

    def tube(self, a, b, radius, material=LOCK, sides=12):
        delta = tuple(b[i]-a[i] for i in range(3))
        length = math.sqrt(sum(x*x for x in delta))
        if length < 1e-12:
            return
        axis = tuple(x/length for x in delta)
        helper = (0, 1, 0) if abs(axis[1]) < .9 else (1, 0, 0)
        cross = lambda v,w:(v[1]*w[2]-v[2]*w[1],v[2]*w[0]-v[0]*w[2],v[0]*w[1]-v[1]*w[0])
        first = cross(axis, helper)
        norm = math.sqrt(sum(x*x for x in first))
        first = tuple(x/norm for x in first)
        second = cross(axis, first)
        def ring(point, index):
            angle = index*2*math.pi/sides
            return tuple((point[i]+radius*(first[i]*math.cos(angle)+second[i]*math.sin(angle)))*U for i in range(3))
        for i in range(sides):
            self.mesh.add_quad(material,(ring(a,i),ring(a,i+1),ring(b,i+1),ring(b,i)))
            self.mesh.add_triangle(material,(tuple(x*U for x in a),ring(a,i+1),ring(a,i)))
            self.mesh.add_triangle(material,(tuple(x*U for x in b),ring(b,i),ring(b,i+1)))
        self.volume += sides*.5*math.sin(2*math.pi/sides)*radius*radius*length

    def lathe(self, center, profile, material=METAL, sides=32):
        # Closed radial profile; signed revolution area gives the modeled volume.
        cx, cy, cz = center
        volume = 0
        for i in range(len(profile)):
            r0,y0 = profile[i];r1,y1 = profile[(i+1)%len(profile)]
            volume += (y1-y0)*(r0*r0+r0*r1+r1*r1)/3
            for j in range(sides):
                a,b = j*2*math.pi/sides,(j+1)*2*math.pi/sides
                p = [(cx+r0*math.cos(a),cy+y0,cz+r0*math.sin(a)),
                     (cx+r0*math.cos(b),cy+y0,cz+r0*math.sin(b)),
                     (cx+r1*math.cos(b),cy+y1,cz+r1*math.sin(b)),
                     (cx+r1*math.cos(a),cy+y1,cz+r1*math.sin(a))]
                self.mesh.add_quad(material,[tuple(v*U for v in point) for point in p])
        self.volume += abs(volume)*sides*.5*math.sin(2*math.pi/sides)

    def tap(self, y, z, reach=.10):
        self.tube((0,y,z),(0,y,z+reach*.8),.014)
        self.tube((0,y,z+reach*.8),(0,y-.045,z+reach),.014)
        self.tube((0,y,z+.045),(0,y+.055,z+.045),.009)
        self.tube((-.04,y+.055,z+.045),(.04,y+.055,z+.045),.009)


def build(kind):
    spec = D[kind]
    w,d = spec['inner_width_m'],spec['inner_depth_m']
    h = spec['liters']/1000/(w*d)
    t,lid = D['wall_m'],D['lid_m']
    foot = .08 if kind=='cistern' else .04
    c = Construction()
    c.box((0,foot+t/2,0),(w+2*t,t,d+2*t))
    for sign in (-1,1):
        c.box((sign*(w+t)/2,foot+t+h/2,0),(t,h,d+2*t))
        c.box((0,foot+t+h/2,sign*(d+t)/2),(w,h,t))
    top = foot+t+h
    c.box((0,top+lid/2,0),(w+2*t,lid,d+2*t))
    for x in (-w/2,w/2):
        for z in (-d/2,d/2):
            c.box((x,foot/2,z),(.055,foot,.055))
            c.box((x,top/2+foot/2,z),(.035,top-foot,.025),LOCK)
            for y in (foot+.06,top-.06):c.tube((x,y,z),(x,y,z+.012),.012)
    for y in (foot+.025,top-.02):
        c.box((0,y,(d+t)/2), (w+.04,.025,.018),LOCK)
        c.box((0,y,-(d+t)/2),(w+.04,.025,.018),LOCK)
        for x in (-(w+t)/2,(w+t)/2):c.box((x,y,0),(.018,.025,d+.04),LOCK)
    # Raised front panel with clipped corners; no borrowed historic motifs.
    x=w*.39;lower=foot+.09;upper=top-.09;bevel=.045;z=d/2+t+.008
    frame=[(-x+bevel,lower),(x-bevel,lower),(x,lower+bevel),(x,upper-bevel),
           (x-bevel,upper),(-x+bevel,upper),(-x,upper-bevel),(-x,lower+bevel)]
    for i,(xx,y) in enumerate(frame):
        nx,ny=frame[(i+1)%len(frame)];c.tube((xx,y,z),(nx,ny,z),.008)
    if kind=='cistern':
        c.lathe((0,top+lid,0),[(0,0),(.18,0),(.18,.012),(0,.012)],LOCK)
        c.box((0,top+.04,0),(.08,.02,.016),LOCK)
        c.tap(foot+.15,d/2+t)
    else:
        back_z = -.2
        c.box((0,top+.24,back_z),(.50,.48,.014))
        # An arched plate and raised bead; every vertex belongs to our mesh.
        c.lathe((0,top+.47,back_z),[(0,0),(.03,0),(.025,.055),(0,.075)],LOCK)
        points=[(-.25,top),(-.25,top+.43)]
        points += [(.25*math.cos(a),top+.43+.25*math.sin(a)) for a in [math.pi-i*math.pi/16 for i in range(17)]]
        points +=[(.25,top)]
        for i in range(len(points)-1):
            x,y=points[i];xx,yy=points[i+1]
            c.tube((x,y,back_z+.015),(xx,yy,back_z+.015),.015)
        # Fill the arch with triangles; account its plate separately.
        for i in range(16):
            a=math.pi-i*math.pi/16;b=math.pi-(i+1)*math.pi/16
            for z in (back_z-.007,back_z+.007):
                c.mesh.add_triangle(METAL,[(0,(top+.43)*U,z*U),(.25*math.cos(a)*U,(top+.43+.25*math.sin(a))*U,z*U),(.25*math.cos(b)*U,(top+.43+.25*math.sin(b))*U,z*U)])
        c.volume += .5*math.pi*.25**2*.014
        c.lathe((0,top+.03,.25),[(0,0),(.13,0),(.28,.115),(.28,.14),(.26,.14),(.12,.02),(0,.02)])
        c.tap(top+.34,back_z+.02,.20)
        for sign in (-1,1):
            for y in (top+.44,top+.52):
                c.tube((0,y-.025,back_z+.02),(sign*.075,y+.025,back_z+.02),.01)
    vertices = c.mesh.vertices
    radius=max(math.hypot(p[0],p[2]) for p in vertices)
    height=max(p[1] for p in vertices)
    return c, {'empty_kg':c.volume*D['iron_density_kg_m3'],'iron_grams':math.ceil(c.volume*D['iron_density_kg_m3']*1000),
               'radius_mu':radius,'height_mu':height,'inner_height_m':h,
               'thermal_area_m2':2*(w*d+w*h+d*h),'thermal_wall_m':t}


def main():
    folder=ROOT/'src/models/caelum/props/water_furniture';folder.mkdir(parents=True,exist_ok=True)
    icons=ROOT/'src/graphics/caelum/icons/furniture';icons.mkdir(parents=True,exist_ok=True)
    source=Image.open(ART/'source-v1.png').convert('RGBA')
    outputs=[];rows=[];models=[];textures=[]
    for index,kind in enumerate(('fountain','cistern')):
        c,row=build(kind);rows.append(row)
        path=folder/(kind+'.obj');c.mesh.write(path);outputs.append(path)
        im=source.crop((source.width*index//2,0,source.width*(index+1)//2,source.height))
        im.putalpha(im.getchannel('A').point(lambda a:255 if a>=128 else 0))
        im=im.crop(im.getbbox());im.thumbnail((116,116),Image.Resampling.LANCZOS)
        out=Image.new('RGBA',(128,128));out.alpha_composite(im,((128-im.width)//2,122-im.height))
        out.putalpha(out.getchannel('A').point(lambda a:255 if a>=128 else 0))
        path=icons/(kind+'.png');out.save(path);outputs.append(path)
        sprite='CWFN' if index==0 else 'CWCT'
        bounds=out.getbbox();scale=(bounds[3]-bounds[1])/row['height_mu']
        textures.append(f'Sprite {sprite}A0,128,128 {{ XScale {scale:.9f} YScale {scale:.9f} Offset 64,122 Patch "graphics/caelum/icons/furniture/{kind}.png",0,0 }}')
        models.append(f'Model Caelum{kind.title()} {{ Path "models/caelum/props/water_furniture" Model 0 "{kind}.obj" Scale 1 1 1 AngleOffset -90 CorrectPixelStretch DontCullBackFaces FrameIndex {sprite} A 0 0 }}')
    code=['// #410: geometría delegada y reservas aprobadas; fuente DATA.json.','class CaelumWaterFurnitureData : Object','{','    const REVISION=1;']
    fields={'EmptyKg':'empty_kg','Radius':'radius_mu','Height':'height_mu','ThermalArea':'thermal_area_m2','IronGrams':'iron_grams'}
    for method,key in fields.items():
        code.append(f'    static clearscope double {method}(int kind){{return kind==0?{rows[0][key]:.9f}:{rows[1][key]:.9f};}}')
    code.append(f'    const WALL_M={D["wall_m"]};')
    for method,key in [('Capacity','liters'),('Refill','refill_liters_minute'),('Facing','facing')]:
        code.append(f'    static clearscope double {method}(int kind){{return kind==0?{D["fountain"][key]}:{D["cistern"][key]};}}')
    a=','.join(map(str,D['fountain']['position']));b=','.join(map(str,D['cistern']['position']))
    code += ['    static clearscope double InitialLiters(int kind){return kind==0?Capacity(kind):0;}',
             f'    static clearscope vector3 Position(int kind){{return kind==0?({a}):({b});}}','}']
    for name,lines in [('water_furniture.modeldef',models),('water_furniture.textures',textures),('CaelumWaterFurnitureData.zs',code)]:
        path=ROOT/'src/caelum/data'/name;path.write_text('\n'.join(lines)+'\n',encoding='utf-8');outputs.append(path)
    report={'issue':410,'calculations':dict(zip(('fountain','cistern'),rows)),
            'note':'Iron stock volume includes small overlaps at decorative fittings; body panel joints are non-overlapping. No source image pixels reused as model textures.',
            'sha256':{p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in outputs}}
    (ART/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report['calculations']))


if __name__=='__main__':main()
