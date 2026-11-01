"""Build the owned articulated automaton mesh, native MD3 frames and registrations.

No renderer, Blender or external assets are required. Materials are unchanged
owned textures, including the built-in image_gen swatch recorded in PROMPT.json.
DESIGN.json is the editable art source;
the neutral OBJ is included for conventional mesh editors. --check is read-only.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct

from generate_environment_models import Mesh
from generate_siege_models import add_box

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/source/art/tarot_automaton"
RUNTIME = "src/models/caelum/tarot/automaton"


def rotate(point, pivot, degrees, axis=0):
    value = [point[i] - pivot[i] for i in range(3)]
    a, b = ((1, 2), (2, 0), (0, 1))[axis]
    c, s = math.cos(math.radians(degrees)), math.sin(math.radians(degrees))
    value[a], value[b] = value[a] * c - value[b] * s, value[a] * s + value[b] * c
    return tuple(value[i] + pivot[i] for i in range(3))


def shell(mesh, material, rows, center=(0, 0, 0), segments=12):
    """Elliptical forged plate rings, with consistent outward winding."""
    rings = [[(center[0] + rx * math.cos(math.tau * i / segments),
               center[1] + y, center[2] + rz * math.sin(math.tau * i / segments))
              for i in range(segments)] for y, rx, rz in rows]
    for i in range(segments):
        j = (i + 1) % segments
        for low, high in zip(rings, rings[1:]):
            mesh.add_quad(material, (low[j], low[i], high[i], high[j]))
        mesh.add_triangle(material, ((center[0], rings[0][i][1], center[2]), rings[0][i], rings[0][j]))
        mesh.add_triangle(material, ((center[0], rings[-1][i][1], center[2]), rings[-1][j], rings[-1][i]))


def create_parts(design):
    g = design['geometry']; parts = {}
    def part(name):
        mesh = Mesh(name); parts[name] = mesh; return mesh
    def joint(mesh, center, radii, material='dark'):
        mesh.add_ellipsoid(material, center, radii, seed=0, rings=g['joint_rings'], segments=g['joint_segments'], irregularity=0)
    def rod(mesh, start, end, radius, material='brass'):
        mesh.add_frustum(material, start, end, radius, radius, sides=8)
    torso = part('torso')
    shell(torso, 'iron', g['torso_rings'], segments=g['segments'])
    # Rolled rims, a recessed breastplate and a restrained ornamental spine.
    for y, rx, rz in (g['torso_rings'][0], g['torso_rings'][-1]):
        shell(torso, 'brass', [(y-.5, rx+.35, rz+.35), (y+.5, rx+.35, rz+.35)], segments=g['segments'])
    for y in (54, 60, 66):
        joint(torso, (0, y, 9.1), (1.3, 1.3, .7), 'brass')
    for x in (-6, 6):
        rod(torso, (x, 50, -7.2), (x, 70, -8.2), 1.2)
    joint(torso, (0, 45, 0), (10, 6, 6))
    shell(torso, 'iron', [(40, 12, 7), (45, 11, 7), (48, 9, 6)], segments=g['segments'])
    rod(torso, (0, 74, 0), (0, 80, 0), 4)
    head = part('head')
    shell(head, 'iron', g['helmet_rings'], segments=g['segments'])
    # The slit and nasal bar convey a closed mechanical helmet, not a face.
    add_box(head, 'dark', (0, 86, 6.6), (12, 2.2, .7))
    add_box(head, 'brass', (0, 84, 7.1), (1.1, 9, .8))
    for x in (-4, -2, 2, 4):
        add_box(head, 'dark', (x, 81, 6.2), (.65, 2.5, .6))
    for side in (-1, 1):
        name = 'left' if side == 1 else 'right'; x = side * g['leg_x']
        upper = part(name+'_thigh')
        joint(upper, (x, g['hip_y'], 0), (4.8, 4.8, 4.8))
        shell(upper, 'iron', [(27, 4.2, 5.0), (34, 5.7, 6), (43, 6.5, 6)], (x, 0, 0), g['segments'])
        rod(upper, (x+side*5.2, 29, 0), (x+side*6.2, 43, 0), 1.1)
        lower = part(name+'_shin')
        joint(lower, (x, g['knee_y'], 0), (5.2, 5.2, 5.2), 'brass')
        shell(lower, 'iron', [(7, 4.5, 4.0), (13, 5, 5.5), (24, 5.8, 5.5)], (x, 0, 0), g['segments'])
        joint(lower, (x, 25, 4), (5, 5.8, 2.8), 'iron')
        shell(lower, 'iron', [(0, 5.5, 8), (3, 6, 9), (7, 4.5, 5)], (x, 0, 3), g['segments'])
        shell(lower, 'brass', [(0, 5.5, 8), (.8, 5.7, 8.2)], (x, 0, 3), g['segments'])
        x = side*g['shoulder_x']
        upper = part(name+'_arm')
        joint(upper, (x, g['shoulder_y'], 0), (7, 7, 7), 'iron')
        shell(upper, 'iron', [(55, 4.2, 4.2), (63, 5.2, 5.2), (70, 7, 6)], (x, 0, 0), g['segments'])
        rod(upper, (x+side*4.7, 55, 0), (x+side*5.4, 67, 0), 1)
        lower = part(name+'_forearm')
        joint(lower, (x, g['elbow_y'], 0), (4.3, 4.3, 4.3), 'brass')
        shell(lower, 'iron', [(40, 4, 4), (46, 5, 5), (52, 4, 4)], (x, 0, 2), g['segments'])
        joint(lower, (x, g['hand_y'], 4), (4.4, 4.8, 4), 'iron')
        for y in (37, 39, 41, 43):
            rod(lower, (x-3, y, 6.5), (x+3, y, 6.5), .5, 'brass')
    shield = part('shield'); cx, cy, cz = g['shield_center']
    w, h = g['shield_width']/2, g['shield_height']/2
    # Curved, chamfered tower shield. Its front is crowned and visibly thick.
    outline = [(-w*.65, -h), (w*.65, -h), (w, -h*.75), (w, h*.75),
               (w*.65, h), (-w*.65, h), (-w, h*.75), (-w, -h*.75)]
    for i, (x, y) in enumerate(outline):
        xx, yy = outline[(i+1)%len(outline)]
        front = (cx+x, cy+y, cz+1)
        next_front = (cx+xx, cy+yy, cz+1)
        back = (cx+x, cy+y, cz-1.2)
        next_back = (cx+xx, cy+yy, cz-1.2)
        shield.add_triangle('iron', ((cx,cy,cz+4),front,next_front))
        shield.add_triangle('wood', ((cx,cy,cz-1.2),next_back,back))
        shield.add_quad('brass', (front,back,next_back,next_front))
        rod(shield, front, next_front, .65)
        joint(shield, (cx+x*.88,cy+y*.93,cz+1.5), (.65,.65,.6), 'brass')
    rod(shield,(cx,cy-h*.88,cz+4),(cx,cy+h*.88,cz+4),.75)
    joint(shield, (cx,cy,cz+4), (4,4,1.5), 'brass')
    mace = part('mace'); a, b = g['mace_bottom'], g['mace_top']
    rod(mace, a, b, 1.5, 'iron')
    for y in range(33,44,2):
        rod(mace,(a[0],y,a[2]),(a[0],y+.65,a[2]),1.8,'dark')
    joint(mace,(a[0],a[1],a[2]),(2.8,2.8,2.8),'brass')
    rod(mace,(b[0],b[1]-10,b[2]),b,3)
    for i in range(6):
        phase = math.tau*i/6; dx, dz = math.cos(phase), math.sin(phase)
        tx, tz = -dz*.65, dx*.65; r = g['mace_head_radius']
        shape=[(2,-11),(r,-7),(r,-1),(2,2)]
        left=[(b[0]+dx*x+tx,b[1]+y,b[2]+dz*x+tz) for x,y in shape]
        right=[(b[0]+dx*x-tx,b[1]+y,b[2]+dz*x-tz) for x,y in shape]
        mace.add_quad('iron',left);mace.add_quad('iron',list(reversed(right)))
        for j in range(4):mace.add_quad('iron',(left[j],right[j],right[(j+1)%4],left[(j+1)%4]))
    # The native sector's flat ambient light must not erase the plate shapes.
    # Sample the painted value ramp per neutral-pose face; never edit its pixels.
    shade=design['painted_shading'];light=shade['light_vector']
    length=math.sqrt(sum(x*x for x in light));light=[x/length for x in light]
    for mesh in parts.values():
        for mat,face in mesh.faces:
            if mat!='iron':continue
            n=unit_normal([mesh.vertices[i-1] for i in face[:3]])
            center=shade['center_u']+shade['normal_span']*sum(n[i]*light[i] for i in range(3))
            for i in face:
                u,v=mesh.uvs[i-1]
                mesh.uvs[i-1]=(center+(u-.5)*shade['face_span'],v)
    return parts


def poses(parts, design):
    g = design['geometry']; output=[]; labels=[]
    for action, options in design['motion'].items():
        for sample in range(options['frames']):
            pose={}; phase=math.tau*sample/options['frames']
            for name, mesh in parts.items():
                points=list(mesh.vertices)
                side=1 if name.startswith('left') or name=='shield' else -1
                if action=='walk':
                    angle=math.sin(phase)*options['hip_degrees']*side
                    if name.endswith(('_thigh','_shin')):
                        if name.endswith('_shin'):
                            points=[rotate(v,(side*g['leg_x'],g['knee_y'],0),max(0,math.sin(phase)*side)*options['knee_degrees']) for v in points]
                        points=[rotate(v,(side*g['leg_x'],g['hip_y'],0),angle) for v in points]
                    elif name.endswith(('_arm','_forearm')) or name in ('shield','mace'):
                        points=[rotate(v,(side*g['shoulder_x'],g['shoulder_y'],0),-angle*.5) for v in points]
                    points=[(x,y+options['bob_mu']*(1-math.cos(2*phase)),z) for x,y,z in points]
                if action=='attack' and name in ('right_arm','right_forearm','mace'):
                    points=[rotate(v,(-g['shoulder_x'],g['shoulder_y'],0),options['arm_degrees'][sample]) for v in points]
                if action=='guard' and name in ('left_arm','left_forearm','shield'):
                    points=[rotate(v,(g['shoulder_x'],g['shoulder_y'],0),-25) for v in points]
                if action=='inactive' and name=='head':points=[rotate(v,(0,78,0),18) for v in points]
                if action=='fallen':points=[rotate(v,(0,0,0),options['degrees'][sample]) for v in points]
                pose[name]=points
            floor=min(v[1] for points in pose.values() for v in points)
            pose={name:[(z,x,y-floor) for x,y,z in points] for name,points in pose.items()}
            output.append(pose);labels.append((action,sample))
    return output,labels


def fixed(text,length):
    value=text.encode('ascii')
    if len(value)>=length:raise ValueError(f'Text exceeds MD3 field: {text}')
    return value+b'\0'*(length-len(value))


def unit_normal(vertices):
    a,b,c=vertices;u=[b[i]-a[i] for i in range(3)];v=[c[i]-a[i] for i in range(3)]
    n=(u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0])
    length=math.sqrt(sum(x*x for x in n))
    return tuple(x/length for x in n) if length else (0,0,1)


def normal(vertices):
    n=unit_normal(vertices)
    lat=round(math.atan2(n[1],n[0])*128/math.pi)&255
    lng=round(math.acos(max(-1,min(1,n[2])))*128/math.pi)&255
    return (lat<<8)|lng


def export_md3(parts, frames, design):
    surfaces=[];stats=[]
    # Batch by material, bounded by MD3 vertex limits, rather than one draw per
    # mechanical joint. Editable source modules and rigid articulation remain.
    batches=[]
    for material,path in design['materials'].items():
        indices=[];triangles=[]
        for name,mesh in parts.items():
            for mat,face in mesh.faces:
                if mat!=material:continue
                if len(indices)+len(face)>4096:
                    batches.append((material,path,indices,triangles));indices=[];triangles=[]
                base=len(indices)
                indices.extend((name,i-1,tuple(j-1 for j in face[:3])) for i in face)
                triangles.extend((base,base+i,base+i+1) for i in range(1,len(face)-1))
        if indices:batches.append((material,path,indices,triangles))
    for number,(material,path,indices,triangles) in enumerate(batches):
            tri=b''.join(struct.pack('<3I',*t) for t in triangles)
            skin=struct.pack('<64sI',fixed(path,64),0)
            uv=b''.join(struct.pack('<2f',parts[name].uvs[i][0],1-parts[name].uvs[i][1]) for name,i,face in indices)
            vertex=bytearray()
            for frame in frames:
                for name,i,face in indices:
                    xyz=[round(x*64) for x in frame[name][i]]
                    if any(not -32768<=x<=32767 for x in xyz):raise ValueError('MD3 coordinate overflow')
                    vertex.extend(struct.pack('<3hH',*xyz,normal([frame[name][j] for j in face])))
            a=108;b=a+len(tri);c=b+len(skin);d=c+len(uv);end=d+len(vertex)
            header=struct.pack('<4s64s10I',b'IDP3',fixed(f'{material}_{number}',64),0,len(frames),1,len(indices),len(triangles),a,b,c,d,end)
            surfaces.append(header+tri+skin+uv+vertex)
            stats.append(dict(modules=sorted(set(name for name,i,face in indices)),material=material,vertices=len(indices),triangles=len(triangles)))
    frame_headers=bytearray();bounds=[]
    for i,frame in enumerate(frames):
        points=[v for values in frame.values() for v in values]
        lo=[min(v[j] for v in points) for j in range(3)];hi=[max(v[j] for v in points) for j in range(3)]
        radius=max(math.sqrt(sum(x*x for x in v)) for v in points)
        frame_headers.extend(struct.pack('<10f16s',*lo,*hi,0,0,0,radius,fixed(f'pose{i:02}',16)))
        bounds.append(dict(min=lo,max=hi))
    start=108+len(frame_headers);end=start+sum(map(len,surfaces))
    header=struct.pack('<4sI64s9I',b'IDP3',15,fixed('Caelum automaton #440',64),0,len(frames),0,len(surfaces),0,108,start,start,end)
    return header+frame_headers+b''.join(surfaces),stats,bounds


def generated():
    raw=(SOURCE/'DESIGN.json').read_bytes();design=json.loads(raw)
    parts=create_parts(design);frames,labels=poses(parts,design)
    md3,stats,bounds=export_md3(parts,frames,design)
    model=['// Autómata original; generado desde DESIGN.json.', 'Model CaelumAutomatonModelBody','{',
           '    Path "models/caelum/tarot/automaton"','    Model 0 "automaton.md3"','    Scale 1 1 1',
           '    CorrectPixelStretch','    DontCullBackFaces']
    textures=[];states=['// Apariencia mecánica; el control de combate se integra por separado.',
        'class CaelumAutomatonModelBody : Actor','{',
        f'    Default {{ Radius {design["radius"]}; Height {design["height"]}; RenderRadius 112; +NOINTERACTION +NOGRAVITY }}',
        '    States','    {','    Spawn:','        Goto Inactive;']
    for index,(action,sample) in enumerate(labels):
        letter=chr(65+index);options=design['motion'][action]
        model.append(f'    FrameIndex TAM0 {letter} 0 {index}')
        textures.append(f'Sprite "TAM0{letter}0", 1, 1 {{ Patch "graphics/caelum/bull_invisible.png", 0, 0 }}')
        if sample==0:states.append(f'    {action.title()}:')
        states.append(f'    F{index}:')
        last=sample==options['frames']-1
        states.append(f'        TAM0 {letter} {options["sample_tics"] if not last or options["loop"] else -1};')
        if last:states.append(f'        Goto {action.title()};' if options['loop'] else '        Stop;')
    model.append('}');states.extend(['    }','}'])
    output={RUNTIME+'/automaton.md3':md3,
        RUNTIME+'/iron-painted-ramp.png':(SOURCE/'iron-painted-ramp.png').read_bytes(),
        'src/caelum/data/tarot_automaton.modeldef':('\n'.join(model)+'\n').encode(),
        'src/caelum/data/tarot_automaton.textures':('\n'.join(textures)+'\n').encode(),
        'src/caelum/core/CaelumAutomatonModelBody.zs':('\n'.join(states)+'\n').encode()}
    obj=['# Original Caelum Argenteum automaton; editable neutral pose. OBJ Y is up.']
    offset=0
    for name,mesh in parts.items():
        obj.append('o '+name)
        obj.extend('v '+' '.join(f'{x:.6f}' for x in v) for v in mesh.vertices)
        obj.extend('vt '+' '.join(f'{x:.6f}' for x in uv) for uv in mesh.uvs)
        material=None
        for mat,face in mesh.faces:
            if material!=mat:obj.append('usemtl '+design['materials'][mat]);material=mat
            obj.append('f '+' '.join(f'{i+offset}/{i+offset}' for i in face))
        offset+=len(mesh.vertices)
    output['assets/source/art/tarot_automaton/automaton.obj']=('\n'.join(obj)+'\n').encode()
    manifest=dict(issue=440,author=design['author'],provenance='Original project geometry. Unmodified owned station/stash textures and built-in image_gen iron swatch recorded in PROMPT.json. No third-party or development-IWAD art.',
        design_sha256=hashlib.sha256(raw).hexdigest(),frames=[dict(action=a,sample=s,**b) for (a,s),b in zip(labels,bounds)],surfaces=stats,
        materials={path:hashlib.sha256(output.get('src/'+path) or (ROOT/'src'/path).read_bytes()).hexdigest() for path in design['materials'].values()},
        outputs={path:hashlib.sha256(blob).hexdigest() for path,blob in output.items()})
    output['assets/source/art/tarot_automaton/manifest.json']=(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n').encode()
    return output


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--check',action='store_true');args=parser.parse_args()
    outputs=generated();stale=[]
    for name,blob in outputs.items():
        path=ROOT/name
        if args.check:
            if not path.exists() or path.read_bytes()!=blob:stale.append(name)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if stale:raise SystemExit('Stale automaton outputs: '+', '.join(stale))
    print(f'Automaton: {len(outputs)} deterministic outputs {"verified" if args.check else "written"}.')


if __name__=='__main__':main()
