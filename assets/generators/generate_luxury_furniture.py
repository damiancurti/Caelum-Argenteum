"""Build original period furniture and its inspectable material bill."""
from pathlib import Path
import hashlib
import json
import math
import sys
sys.dont_write_bytecode=True
from generate_stash_models import Mesh, WOOD, METAL, INSIDE
from furniture_bedding import bedding, CLOTH

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/art_source/luxury_furniture'
DATA=json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
U=DATA['units_per_meter']

class Construction:
    def __init__(self):
        self.mesh=Mesh()
        self.volume={WOOD:0.0,METAL:0.0}
        self.cloth=0.0
    def box(self,material,center,size):
        if material in self.volume:self.volume[material]+=math.prod(size)
        self.mesh.add_box(material,tuple(x*U for x in center),tuple(x*U for x in size))
    def turned(self,x,z,profile,material=WOOD):
        """Closed twelve-sided lathe; exact polygonal-frustum solid volume."""
        sides=12
        for (y0,r0),(y1,r1) in zip(profile,profile[1:]):
            self.volume[material]+=(sides*math.sin(2*math.pi/sides)/2)*(y1-y0)*(r0*r0+r0*r1+r1*r1)/3
            for i in range(sides):
                a=2*math.pi*i/sides;b=2*math.pi*(i+1)/sides
                points=[(x+r0*math.cos(a),y0,z+r0*math.sin(a)),(x+r0*math.cos(b),y0,z+r0*math.sin(b)),
                        (x+r1*math.cos(b),y1,z+r1*math.sin(b)),(x+r1*math.cos(a),y1,z+r1*math.sin(a))]
                self.mesh.add_quad(material,[tuple(v*U for v in p) for p in points])
        for y,r in (profile[0],profile[-1]):
            for i in range(sides):
                a=2*math.pi*i/sides;b=2*math.pi*(i+1)/sides
                self.mesh.add_triangle(material,[(x*U,y*U,z*U),((x+r*math.cos(a))*U,y*U,(z+r*math.sin(a))*U),
                                                 ((x+r*math.cos(b))*U,y*U,(z+r*math.sin(b))*U)])
    def medallion(self,x,y,z,radius,depth):
        self.mesh.add_cylinder_z(WOOD,(x*U,y*U,z*U),radius*U,depth*U,12)
        self.volume[WOOD]+=6*math.sin(math.pi/6)*radius*radius*depth
        for i in range(8):
            a=math.pi*i/4
            self.box(WOOD,(x+math.cos(a)*radius*.67,y+math.sin(a)*radius*.67,z+depth*.6),(.012,.012,.009))
    def cover(self,center,size):
        self.box(INSIDE,center,size)
        # The thinnest axis is the fitted face, not a new filling material.
        dimensions=sorted(size)
        self.cloth+=dimensions[1]*dimensions[2]
    def bill(self):
        wood=self.volume[WOOD]*DATA['wood_density'];iron=self.volume[METAL]*DATA['iron_density']
        cloth=self.cloth*DATA['cloth_kg_m2']
        return {'wood_kg':wood,'iron_kg':iron,'cotton_cloth_kg':cloth,'empty_kg':wood+iron+cloth,
                'recipe_grams':{'wood':math.ceil(wood*1000),'iron':math.ceil(iron*1000),'cotton_cloth':math.ceil(cloth*1000)}}

def chair():
    c=Construction();r=DATA['chair'];w=r['width'];d=r['depth'];h=r['height'];s=r['surface']
    for x in (-w/2+.05,w/2-.05):
        for z in (-d/2+.05,d/2-.05):
            c.turned(x,z,[(0,.028),(.035,.038),(.07,.027),(.13,.035),(.21,.022),(s-.05,.03),(s,.03)])
            c.box(METAL,(x,s-.045,z),(.035,.008,.035))
        c.box(WOOD,(x,s-.055,0),(.045,.08,d-.1))
        c.box(WOOD,(x,.60,0),(.07,.045,d))
        for z in (-d/2+.06,d/2-.06):c.turned(x,z,[(s,.018),(.51,.025),(.58,.018)])
    for z in (-d/2+.05,d/2-.05):c.box(WOOD,(0,s-.055,z),(w-.1,.08,.045))
    c.box(WOOD,(0,s-.01,0),(w-.09,.02,d-.09))
    c.cover((0,s+.001,0),(w-.10,.002,d-.10))
    c.box(WOOD,(0,(s+h-.06)/2,-d/2+.024),(w-.10,h-.06-s,.028))
    c.cover((0,(s+h-.08)/2,-d/2+.040),(w-.17,.002+h-.12-s,.002))
    for x in (-w/2+.035,w/2-.035):c.turned(x,-d/2+.035,[(s,.03),(.70,.025),(h-.08,.035),(h-.04,.022)])
    c.box(WOOD,(0,h-.08,-d/2+.035),(w,.045,.05))
    c.medallion(0,h-.045,-d/2+.07,.044,.025)
    for x in (-w*.30,w*.30):c.medallion(x,s-.055,d/2-.02,.026,.018)
    return c

def bed():
    c=Construction();r=DATA['bed'];w=r['width'];d=r['depth'];h=r['height'];s=r['surface']
    for x in (-w/2+.055,w/2-.055):
        for z in (-d/2+.055,d/2-.055):
            c.turned(x,z,[(0,.04),(.06,.055),(.14,.038),(s,.045),(.60,.05),(.72,.033),
                          (1.30,.026),(1.52,.042),(h-.16,.028),(h-.12,.045),(h-.06,.05),(h,.003)])
            c.box(METAL,(x,s-.05,z),(.055,.012,.055))
        c.box(WOOD,(x,s-.065,0),(.045,.13,d-.11))
    for z in (-d/2+.055,d/2-.055):c.box(WOOD,(0,s-.065,z),(w-.11,.13,.05))
    count=16
    for i in range(count):c.box(WOOD,(0,s-.012,-d/2+.12+i*(d-.24)/(count-1)),(w-.11,.024,(d-.24)/count-.009))
    # Keep the accepted sleeping plane; move the support below the mattress.
    t=DATA['bedding']['mattress_thickness_m']
    c.mesh.vertices=[(x,y-t*U if (s-.14)*U<=y<=(s+.005)*U else y,z) for x,y,z in c.mesh.vertices]
    c.cloth+=bedding(c.mesh,w,d,s,DATA['bedding'],U,DATA['cloth_kg_m2'])/DATA['cloth_kg_m2']
    canopy=DATA['canopy'];rw,rh=canopy['rail_m'];drop=canopy['valance_m']
    for z in (-d/2+.055,d/2-.055):
        c.box(WOOD,(0,h-rh/2,z),(w,rh,rw))
        c.mesh.add_box(CLOTH,(0,(h-drop/2)*U,z*U),(w*U,drop*U,.006*U));c.cloth+=w*drop
    for x in (-w/2+.055,w/2-.055):
        c.box(WOOD,(x,h-rh/2,0),(rw,rh,d))
        c.mesh.add_box(CLOTH,(x*U,(h-drop/2)*U,0),(.006*U,drop*U,d*U));c.cloth+=d*drop
        for z in (-d/2+.07,d/2-.07):
            cw=canopy['curtain_width_m'];ch=canopy['curtain_drop_m']
            c.mesh.add_box(CLOTH,(x*U,(h-ch/2)*U,z*U),(cw*U,ch*U,.012*U));c.cloth+=cw*ch
    c.mesh.add_box(CLOTH,(0,(h-.006)*U,0),(w*U,.006*U,d*U));c.cloth+=w*d
    for z,top in ((-d/2+.055,.99),(d/2-.055,.70)):
        c.box(WOOD,(0,(s+top)/2,z),(w-.11,top-s,.025))
        c.box(WOOD,(0,top,z),(w-.10,.05,.05))
        c.medallion(0,top-.12,z+.025,.075,.018)
        for x in (-w*.28,w*.28):c.box(WOOD,(x,(s+top)/2,z+.022),(.035,top-s-.04,.018))
    return c

def table():
    c=Construction();r=DATA['table'];w=r['width'];d=r['depth'];h=r['height']
    c.box(WOOD,(0,h-.015,0),(w,.030,d))
    for z in (-d/2+.08,d/2-.08):
        c.box(WOOD,(0,h-.085,z),(w-.16,.11,.028))
        for x in (-w*.30,0,w*.30):
            c.turned(x,z,[(0,.03),(.04,.045),(.08,.028),(.20,.046),(.30,.028),(h-.16,.04),(h-.03,.05)])
            c.box(METAL,(x,h-.075,z),(.045,.012,.045))
            c.medallion(x,h-.085,z+(.018 if z>0 else -.018),.037,.012)
    for x in (-w/2+.08,0,w/2-.08):c.box(WOOD,(x,h-.085,0),(.028,.11,d-.16))
    # Narrow edging and alternating relief blocks make the apron readable.
    for z in (-d/2+.03,d/2-.03):c.box(WOOD,(0,h-.035,z),(w,.018,.025))
    for i in range(20):
        x=-w/2+.16+i*(w-.32)/19
        for z in (-d/2+.06,d/2-.06):c.box(WOOD,(x,h-.10,z),(.035,.045,.016))
    return c

def generate():
    output=ROOT/'src/models/caelum/props/luxury';output.mkdir(parents=True,exist_ok=True)
    rows=[]
    for name,make in [('chair',chair),('bed',bed),('table',table)]:
        c=make()
        if name=='table':c.mesh.vertices=[(z,y,-x) for x,y,z in c.mesh.vertices]
        path=output/f'ca_luxury_{name}.obj';c.mesh.write(path)
        path.write_text(path.read_text(encoding='utf-8').replace('o CaelumStashChest',f'o CaelumLuxury{name.title()}'),encoding='utf-8',newline='\n')
        rows.append(dict(kind=name,**DATA[name],**c.bill(),sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
    (ART/'GENERATED.json').write_text(json.dumps({'issue':410,'models':rows,'textures_reused':[WOOD,METAL,INSIDE]},indent=2)+'\n',encoding='utf-8')
    lines=['// #410: generado desde assets/art_source/luxury_furniture/DATA.json.','class CaelumLuxuryData : Object','{','    const LAYOUT_REVISION=1;']
    lines += [f"    const SERVING_DIAMETER={DATA['serving_diameter_mu']};",f"    const COLLISION_CELL={DATA['collision_cell_mu']};"]
    for index,row in enumerate(rows):lines.append(f"    const {row['kind'].upper()}={index};")
    for method,key,scale in [('Width','width',U),('Depth','depth',U),('Height','height',U),('Surface','surface',U),('Weight','empty_kg',1)]:
        lines.append(f'    static clearscope double {method}(int kind){{return kind==0?{rows[0][key]*scale:.9f}:kind==1?{rows[1][key]*scale:.9f}:{rows[2][key]*scale:.9f};}}')
    for method,key in [('Wood','wood'),('Iron','iron'),('Cloth','cotton_cloth')]:
        values=[r['recipe_grams'][key] for r in rows]
        lines.append(f'    static clearscope int {method}(int kind){{return kind==0?{values[0]}:kind==1?{values[1]}:{values[2]};}}')
    lines+=['}',''];(ROOT/'src/caelum/data/CaelumLuxuryData.zs').write_text('\n'.join(lines),encoding='utf-8',newline='\n')
    print(json.dumps([{k:r[k] for k in ('kind','empty_kg','recipe_grams')} for r in rows]))

if __name__=='__main__':generate()
