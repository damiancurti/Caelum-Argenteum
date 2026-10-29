"""Build original ornamental meshes, register painted sprites and record masses."""
from pathlib import Path
import hashlib
import json
import math
import sys
from PIL import Image
sys.dont_write_bytecode = True
from generate_stash_models import Mesh, WOOD, METAL

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'assets/art_source/ornamental_decor'
DATA = json.loads((ART / 'DATA.json').read_text(encoding='utf-8'))
OUT = ROOT / 'src/models/caelum/props/ornamental'
OUT.mkdir(parents=True, exist_ok=True)
SPRITES = ROOT / 'src/sprites/caelum/ornamental'
SPRITES.mkdir(parents=True, exist_ok=True)
U = DATA['units_per_meter']
TEXTURE = 'models/caelum/props/ornamental/river_landscape.png'
CARVED = 'models/caelum/props/ornamental/carved_wood.png'

def box(mesh, material, center, size):
    mesh.add_box(material, tuple(v*U for v in center), tuple(v*U for v in size))

def lathe(mesh, profile, sides=32):
    for (y0, r0), (y1, r1) in zip(profile, profile[1:]):
        for i in range(sides):
            a, b = math.tau*i/sides, math.tau*(i+1)/sides
            mesh.add_polygon(CARVED, [(r0*math.cos(a)*U,y0*U,r0*math.sin(a)*U),
                (r1*math.cos(a)*U,y1*U,r1*math.sin(a)*U),
                (r1*math.cos(b)*U,y1*U,r1*math.sin(b)*U),
                (r0*math.cos(b)*U,y0*U,r0*math.sin(b)*U)],
                [(i/sides,y0/.85),(i/sides,y1/.85),((i+1)/sides,y1/.85),((i+1)/sides,y0/.85)])
    return sum(math.pi*(b-a)*(r*r+r*s+s*s)/3 for (a,r),(b,s) in zip(profile,profile[1:]))

def leaf(mesh, center_y, radial, width, height, depth, angle):
    # Closed faceted leaf; the point and ridge remain visible at world scale.
    center=(radial*math.cos(angle),center_y,radial*math.sin(angle))
    points=[]
    for k in range(7):
        phi=math.pi*k/6
        ring=[]
        for j in range(12):
            theta=math.tau*j/12
            tang=width*math.sin(phi)*math.cos(theta)
            outward=depth*math.sin(phi)*math.sin(theta)
            ring.append(((center[0]+outward*math.cos(angle)-tang*math.sin(angle))*U,
                (center_y+height*math.cos(phi))*U,
                (center[2]+outward*math.sin(angle)+tang*math.cos(angle))*U))
        points.append(ring)
    for k in range(6):
        for j in range(12):
            n=(j+1)%12
            mesh.add_polygon(CARVED,[points[k][j],points[k+1][j],points[k+1][n],points[k][n]],
                [(j/12,1-k/6),(j/12,1-(k+1)/6),((j+1)/12,1-(k+1)/6),((j+1)/12,1-k/6)])
    return 4*math.pi*width*height*depth/3

def save(mesh,name):
    path=OUT/('ca_'+name+'.obj')
    mesh.write(path)
    path.write_text(path.read_text(encoding='utf-8').replace('o CaelumStashChest','o CaelumOrnament'),encoding='utf-8',newline='\n')

p=DATA['painting'];w=p['width'];h=p['height'];cw=p['canvas_width'];ch=p['canvas_height'];d=p['frame_depth']
frame=Mesh()
box(frame,WOOD,(0,(h-ch)/4,0),(w,(h-ch)/2,d))
box(frame,WOOD,(0,h-(h-ch)/4,0),(w,(h-ch)/2,d))
for side in [-1,1]:
    box(frame,WOOD,(side*(w+cw)/4,h/2,0),((w-cw)/2,ch,d))
    box(frame,WOOD,(side*(cw+p['stretcher_section'])/2,h/2,-d/2), (p['stretcher_section'],ch,p['stretcher_section']))
for y in [(h-ch)/2-p['stretcher_section']/2,(h+ch)/2+p['stretcher_section']/2]:
    box(frame,WOOD,(0,y,-d/2),(cw,p['stretcher_section'],p['stretcher_section']))
for inset in [.008,.02]:
    for side in [-1,1]:
        box(frame,WOOD,(side*(w/2-inset),h/2,d/2),(.008,h-inset*2,.008))
    for y in [inset,h-inset]:box(frame,WOOD,(0,y,d/2),(w-inset*2,.008,.008))
# Carved corner leaves stay inside the existing frame stock allowance.
for sx in [-1,1]:
    for sy in [-1,1]:
        cx=sx*(w/2-.036);cy=h/2+sy*(h/2-.036)
        for axis in [0,1]:
            dx,dy=(-sx*.032,0) if axis==0 else (0,-sy*.032)
            points=[((cx-dy*.35)*U,(cy+dx*.35)*U,(d/2+.004)*U),
                ((cx+dx)*U,(cy+dy)*U,(d/2+.008)*U),
                ((cx+dy*.35)*U,(cy-dx*.35)*U,(d/2+.004)*U)]
            frame.add_triangle(CARVED,points)
frame.add_quad(TEXTURE,[(-cw/2*U,(h-ch)/2*U,d/2*U), (cw/2*U,(h-ch)/2*U,d/2*U),
    (cw/2*U,(h+ch)/2*U,d/2*U),(-cw/2*U,(h+ch)/2*U,d/2*U)])
save(frame,'river_painting')
large=Mesh();large.vertices=list(frame.vertices);large.uvs=list(frame.uvs);large.faces=frame.faces.copy()
ps=DATA['large_painting']['planar_scale'];ds=DATA['large_painting']['depth_scale']
large.vertices=[(x*ps,y*ps,z*ds) for x,y,z in large.vertices]
save(large,'large_river_painting')
wood=(w*h-cw*ch)*d+2*(cw+ch)*p['stretcher_section']**2
iron=p['nails']*math.pi*p['nail_radius']**2*p['nail_length']*DATA['iron_density_kg_m3']
painting_mass=[wood*DATA['wood_density_kg_m3'],iron,cw*ch*DATA['canvas_kg_m2']]

s=DATA['statue'];statue=Mesh()
box(statue,WOOD,(0,s['base_height']/2,0),(s['width'],s['base_height'],s['depth']))
volume=s['width']*s['base_height']*s['depth']+lathe(statue,s['profile'])
for row, values in enumerate(s['leaves']):
    for i in range(s['leaves_per_ring']):
        volume+=leaf(statue,*values,math.tau*(i+row*.5)/s['leaves_per_ring'])
save(statue,'botanical_statue')
statue_mass=[volume*DATA['wood_density_kg_m3'],0,0]

# Technical registration only: retain the painted alpha, no generated rendering.
for name,code in [('painting','COTP'),('statue','COTS')]:
    source=Image.open(ART/(name+'_sprite_source.png')).convert('RGBA')
    source.save(SPRITES/(code+'A0.png'))
Image.open(ART/'river_landscape_source.png').convert('RGB').resize((768,512),Image.Resampling.LANCZOS).save(OUT/'river_landscape.png')
Image.open(ART/'wood_texture_source.png').convert('RGB').resize((512,512),Image.Resampling.LANCZOS).save(OUT/'carved_wood.png')
for code in ['COAP','COAS','COAL']:
    Image.new('RGBA',(1,1)).save(SPRITES/(code+'A0.png'))
rows=[]
for name,masses in [('painting',painting_mass),('statue',statue_mass)]:
    row=DATA[name]
    rows.append({'name':name,'mass_kg':sum(masses),'materials_kg':masses,'recipe_grams':[math.ceil(v*1000) for v in masses],
        'width_units':row['width']*U,'height_units':row['height']*U,'radius_units':math.hypot(row['width'],row['depth'])*U/2})
large_mass=[painting_mass[0]*ps*ps*ds,painting_mass[1]*ds**3,painting_mass[2]*ps*ps]
rows.append({'name':'large_painting','mass_kg':sum(large_mass),'materials_kg':large_mass,'recipe_grams':[math.ceil(v*1000) for v in large_mass],
    'width_units':p['width']*ps*U,'height_units':p['height']*ps*U,'radius_units':math.hypot(p['width']*ps,p['depth']*ds)*U/2})
lines=['// #410: medidas y masas calculadas por generate_ornamental_decor.py.',
       'class CaelumDecorData : Object','{','    const COUNT=3;']
for k,name in enumerate(['PICTURE','STATUE','LARGE_PICTURE']):
    for key,field in [('RADIUS','radius_units'),('HEIGHT','height_units')]:
        lines.append(f"    const {name}_{key}={rows[k][field]:.9f};")
for method,key in [('Mass','mass_kg'),('Width','width_units'),('Height','height_units'),('Radius','radius_units')]:
    lines.append(f"    static clearscope double {method}(int k){{return k==0?{rows[0][key]:.9f}:k==1?{rows[1][key]:.9f}:{rows[2][key]:.9f};}}")
lines += ['    const PICTURE_DEPTH='+str(p['depth']*U)+';',
    f'    static clearscope double Depth(int k){{return PICTURE_DEPTH*(k==2?{ds}:1);}}',
    '    static clearscope bool WallMounted(int k){return k!=1;}',
    '    static clearscope Name ItemClass(int k){return k==0?\'CaelumPaintingItem\':k==1?\'CaelumStatueItem\':\'CaelumLargePaintingItem\';}',
    '    static clearscope Name BodyClass(int k){return k==0?\'CaelumLandscapePainting\':k==1?\'CaelumOrnamentalStatue\':\'CaelumLargeLandscapePainting\';}',
    '    static clearscope String NameKey(int k){return k==0?"CA_DECOR_PAINTING":k==1?"CA_DECOR_STATUE":"CA_DECOR_PAINTING_LARGE";}',
    '    static clearscope String Icon(int k){return k==1?"sprites/caelum/ornamental/COTSA0.png":"sprites/caelum/ornamental/COTPA0.png";}']
for slot,method in enumerate(['Wood','Iron','Cloth']):
    lines.append(f"    static clearscope int {method}(int k){{return k==0?{rows[0]['recipe_grams'][slot]}:k==1?{rows[1]['recipe_grams'][slot]}:{rows[2]['recipe_grams'][slot]};}}")
lines.append('}')
(ROOT/'src/caelum/data/CaelumDecorData.zs').write_text('\n'.join(lines)+'\n',encoding='utf-8')
paths=[*OUT.iterdir(),*SPRITES.iterdir(),ROOT/'src/caelum/data/CaelumDecorData.zs']
report={'issue':410,'variants':rows,'outputs':{p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
        'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in ART.glob('*.png')}}
(ART/'GENERATED.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(rows))
