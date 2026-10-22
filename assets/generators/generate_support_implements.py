"""Build original #479 implement meshes and matching native world/HUD projections."""
from pathlib import Path
import hashlib,json,math,random
from PIL import Image,ImageDraw
from generate_environment_models import Mesh
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
DATA=json.loads((HERE/'support_implements.json').read_text(encoding='utf-8'))
DIRECTORY='models/caelum/equipment/support_implements'
OUT=ROOT/'src'/DIRECTORY
ICONS=ROOT/'src/graphics/caelum/icons/support_implements'
FP=ROOT/'src/graphics/caelum/first_person/support_implements'

def textures():
    for index,(name,rgb) in enumerate(DATA['palette'].items()):
        rng=random.Random(47900+index)
        pixels=[]
        for y in range(64):
            for x in range(64):
                grain=rng.randint(-7,7)+(round(6*math.sin(x*.7+math.sin(y*.15))) if name=='wood' else 0)
                pixels.append(tuple(max(0,min(255,c+grain)) for c in rgb))
        for shade in range(5):
            image=Image.new('RGB',(64,64));image.putdata([tuple(round(c*(.55+shade*.12)) for c in pixel) for pixel in pixels]);image.save(OUT/f'{name}_{shade}.png')

def geometry(spec,tier):
    mesh=Mesh(spec['key'])
    for number,p in enumerate(spec['parts']):
        if tier<p['min_tier']:continue
        material=f"{DIRECTORY}/{p['material']}_4.png"
        first=len(mesh.faces)
        if p['shape']=='rod':
            mesh.add_frustum(material,p['start'],p['end'],p['radius'],p['end_radius'],12)
        elif p['shape']=='ellipsoid':
            mesh.add_ellipsoid(material,p['center'],p['radii'],47900+number,8,12,0.01)
        else:
            c=p['center'];r=p['radii']
            vertices=[tuple(c[k]+r[k]*sign[k] for k in range(3)) for sign in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
            for ids in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5)]:mesh.add_quad(material,[vertices[i] for i in ids])
        center=p.get('center',tuple((p['start'][i]+p['end'][i])/2 for i in range(3)) if p['shape']=='rod' else (0,0,0))
        for face in range(first,len(mesh.faces)):
            texture,indices=mesh.faces[face];points=[mesh.vertices[i-1] for i in indices]
            a=[points[1][i]-points[0][i] for i in range(3)];b=[points[2][i]-points[0][i] for i in range(3)]
            normal=(a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
            length=math.sqrt(sum(v*v for v in normal)) or 1
            sign=1 if sum(normal[i]*(sum(v[i] for v in points)/len(points)-center[i]) for i in range(3))>=0 else -1
            light=(-.4,.8,-.6);shade=min(4,max(0,round(4*max(0,sign*sum(normal[i]*light[i] for i in range(3))/length))))
            mesh.faces[face]=(texture.replace('_4.png',f'_{shade}.png'),indices)
    mesh.faces.sort(key=lambda f:f[0])
    assert len({f[0] for f in mesh.faces})<=32
    return mesh

def render(mesh, target, spec=None):
    """Orthographic textured triangle rasterizer; depth resolves overlapping parts."""
    size = 640 if spec else 256
    height = 400 if spec else 256
    def dot(a, b):
        return sum(x*y for x, y in zip(a, b))
    def cross(a, b):
        return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])
    def normalize(v):
        length = math.sqrt(dot(v, v)) or 1
        return tuple(x/length for x in v)
    vertices = mesh.vertices
    # Keep front faces and the tops visible in the shared orthographic views.
    camera = normalize((-.18, .12, -1) if spec else (-.35, .48, -.805))
    right = normalize(cross(camera, (0, 1, 0)))
    up = normalize(cross(right, camera))
    projected = [(dot(v, right), -dot(v, up)) for v in vertices]
    low = [min(v[i] for v in projected) for i in range(2)]
    high = [max(v[i] for v in projected) for i in range(2)]
    scale = (size-28)/max(high[i]-low[i] for i in range(2))
    screen = [tuple((v[i]-(low[i]+high[i])/2)*scale+size/2 for i in range(2)) for v in projected]
    if spec:
        grip=(dot(spec['grip'],right),-dot(spec['grip'],up))
        screen=[((v[0]-grip[0])*spec['first_person_scale']*2+470,(v[1]-grip[1])*spec['first_person_scale']*2+316) for v in projected]
    depths = [dot(v, camera) for v in vertices]
    canvas = Image.new('RGBA', (size, height))
    rgba = canvas.load()
    zbuffer = [-math.inf]*(size*height)
    textures_by_path = {}
    light = normalize((-.4, .8, -.6))
    for texture, indices in mesh.faces:
        if texture not in textures_by_path:
            textures_by_path[texture] = Image.open(ROOT/'src'/texture).convert('RGB')
        texture_image = textures_by_path[texture]
        pixels = texture_image.load()
        for n in range(1, len(indices)-1):
            ids = [indices[0]-1, indices[n]-1, indices[n+1]-1]
            p = [screen[i] for i in ids]
            x0, y0 = [max(0, math.floor(min(v[i] for v in p))) for i in range(2)]
            x1, y1 = [min((size if i==0 else height)-1, math.ceil(max(v[i] for v in p))) for i in range(2)]
            denominator = (p[1][1]-p[2][1])*(p[0][0]-p[2][0])+(p[2][0]-p[1][0])*(p[0][1]-p[2][1])
            if abs(denominator) < 1e-8:
                continue
            normal = normalize(cross(tuple(vertices[ids[1]][i]-vertices[ids[0]][i] for i in range(3)),
                                     tuple(vertices[ids[2]][i]-vertices[ids[0]][i] for i in range(3))))
            if dot(normal, camera) < 0:
                normal = tuple(-v for v in normal)
            shade = .58 + .42*max(0, dot(normal, light))
            for y in range(y0, y1+1):
                for x in range(x0, x1+1):
                    a = ((p[1][1]-p[2][1])*(x+.5-p[2][0])+(p[2][0]-p[1][0])*(y+.5-p[2][1]))/denominator
                    b = ((p[2][1]-p[0][1])*(x+.5-p[2][0])+(p[0][0]-p[2][0])*(y+.5-p[2][1]))/denominator
                    weights = (a, b, 1-a-b)
                    if min(weights) < -1e-8:
                        continue
                    depth = sum(weights[i]*depths[ids[i]] for i in range(3))
                    offset = y*size+x
                    if depth <= zbuffer[offset]:
                        continue
                    uv = [sum(weights[i]*mesh.uvs[ids[i]][j] for i in range(3)) for j in range(2)]
                    tx = max(0, min(texture_image.width-1, round(uv[0]*(texture_image.width-1))))
                    ty = max(0, min(texture_image.height-1, round((1-uv[1])*(texture_image.height-1))))
                    rgba[x, y] = tuple(round(c*shade) for c in pixels[tx, ty])+(255,)
                    zbuffer[offset] = depth
    canvas.resize((320,200) if spec else (128,128),Image.Resampling.LANCZOS).save(target)


def main():
    for path in (OUT,ICONS,FP):path.mkdir(parents=True,exist_ok=True)
    textures();records=[];textures_text=[];modeldefs=[]
    states=['// Generado desde support_implements.json; no modifica estados antiguos.','class CaelumSupportImplementFrames : Actor { States (Actor, Weapon, Overlay) {','Spawn: S479 ABCDEFGHIJKLMNOPQR 1; M089 A 1; M090 A 1; M091 A 1; Stop;']
    for spec in DATA['assets']:
        for tier in range(1,4):
            key=f"{spec['key']}_t{tier}";frame=chr(65+spec['first_frame']+tier-1)
            mesh=geometry(spec,tier);model=OUT/f'{key}.obj';mesh.write(model)
            icon=ICONS/f'{key}.png';first=FP/f'{key}.png';render(mesh,icon);render(mesh,first,spec)
            icon_name=icon.relative_to(ROOT/'src').as_posix();fp_name=first.relative_to(ROOT/'src').as_posix()
            textures_text += [f'Sprite "S479{frame}0", 128, 128 {{ Offset 64, 120 Patch "{icon_name}", 0, 0 }}',f'Sprite "H479{frame}0", 320, 200 {{ NoTrim Offset 235, 158 Patch "{fp_name}", 0, 0 }}']
            states += [f"View{spec['weapon_type']}T{tier}: H479 {frame} -1; Stop;"]
            modeldefs += [f'Model CaelumWeaponPickup {{ Path "{DIRECTORY}" Model 0 "{key}.obj" Scale 4 4 4 CorrectPixelStretch DontCullBackFaces FrameIndex S479 {frame} 0 0 }}']
            records.append({'key':key,'weapon_type':spec['weapon_type'],'tier':tier,'vertices':len(mesh.vertices),'faces':len(mesh.faces),'surfaces':len({face[0] for face in mesh.faces}),'model':model.relative_to(ROOT/'src').as_posix(),'icon':icon_name,'first_person':fp_name})
    for material,key in [(89,'censer'),(90,'scepter'),(91,'orb')]:
        textures_text += [f'Sprite "M{material:03d}A0", 128, 128 {{ Offset 64, 120 Patch "graphics/caelum/icons/support_implements/{key}_t1.png", 0, 0 }}']
        modeldefs += [f'Model CaelumMaterialPickup {{ Path "{DIRECTORY}" Model 0 "{key}_t1.obj" Scale 4 4 4 CorrectPixelStretch DontCullBackFaces FrameIndex M{material:03d} A 0 0 }}']
    states+=['} }']
    (ROOT/'src/caelum/data/support_implements.textures').write_text('\n'.join(textures_text)+'\n',encoding='utf-8',newline='\n')
    (ROOT/'src/caelum/data/support_implements.modeldef').write_text('\n'.join(modeldefs)+'\n',encoding='utf-8',newline='\n')
    (ROOT/'src/caelum/equipment/CaelumSupportImplementFrames.zs').write_text('\n'.join(states)+'\n',encoding='utf-8',newline='\n')
    generated=[*OUT.glob('*'),*ICONS.glob('*'),*FP.glob('*'),ROOT/'src/caelum/data/support_implements.textures',ROOT/'src/caelum/data/support_implements.modeldef',ROOT/'src/caelum/equipment/CaelumSupportImplementFrames.zs']
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    manifest={'issue':479,'provenance':DATA['provenance'],'assets':records,'inputs':{p.relative_to(ROOT).as_posix():digest(p) for p in [Path(__file__),HERE/'support_implements.json',HERE/'generate_environment_models.py']},'outputs':{p.relative_to(ROOT).as_posix():digest(p) for p in sorted(generated)}}
    (HERE/'support_implements_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
    sheet=Image.new('RGB',(6*180,3*166),(36,33,30));draw=ImageDraw.Draw(sheet)
    for index,record in enumerate(records):
        x=(index//3)*180;y=(index%3)*166
        icon=Image.open(ROOT/'src'/record['icon']);sheet.paste(icon,(x+26,y+8),icon);draw.text((x+8,y+143),record['key'],fill=(225,217,201))
    review=ROOT/'assets/art_source/support_implements';review.mkdir(parents=True,exist_ok=True)
    sheet.save(review/'contact_sheet.png')
    print(f'Generated {len(records)} implement variants; {len(generated)} runtime files.')

if __name__=='__main__':main()
