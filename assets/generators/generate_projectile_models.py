"""Build original low-poly projectiles from editable dimensions, without raster edits."""
from pathlib import Path
import json, math

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/elemental_518/MODELS.json'
OUT=ROOT/'src/models/caelum/projectiles'
BEGIN='// BEGIN GENERATED PHYSICAL PROJECTILES'
END='// END GENERATED PHYSICAL PROJECTILES'

def main():
    data=json.loads(SOURCE.read_text());OUT.mkdir(parents=True,exist_ok=True)
    blocks=[BEGIN]
    for model in data['models']:
        vertices=[];uvs=[];faces=[]
        def face(points,wood=False):
            indexes=[]
            for i,p in enumerate(points):
                vertices.append(p);indexes.append(len(vertices))
                # Inset UVs stay in the owned wood or iron tile at every mip.
                x,y,w,h=(8,8,240,240) if wood else (264,136,112,112)
                uvs.append(((x+(i%2)*w)/512,1-(y+(i//2%2)*h)/256))
            faces.append(indexes)
        def tube(z1,z2,r1,r2,wood):
            for i in range(8):
                a,b=math.tau*i/8,math.tau*(i+1)/8
                lo=(r1*math.cos(a),r1*math.sin(a),z1);hi=(r2*math.cos(a),r2*math.sin(a),z2)
                ln=(r1*math.cos(b),r1*math.sin(b),z1);hn=(r2*math.cos(b),r2*math.sin(b),z2)
                face([lo,ln,hn,hi],wood)
                face([(0,0,z1),ln,lo],wood);face([(0,0,z2),hi,hn],wood)
        length=model['length'];radius=model['radius'];tip=model['tip'];shaft=model['name'] in ['arrow','bolt','javelin']
        if model['name']=='pellet':
            for j in range(4):
                a=-math.pi/2+math.pi*j/4;b=a+math.pi/4
                tube(radius*math.sin(a),radius*math.sin(b),radius*math.cos(a),radius*math.cos(b),False)
        else:
            tube(-length/2,length/2-tip,radius,radius,shaft)
            tube(length/2-tip,length/2,radius*(2 if shaft else 1),0,False)
        if model['fletching']:
            for i in range(3):
                angle=i*math.tau/3
                # Thin solid vanes, visible from both faces and end-on.
                a=(1.6*math.cos(angle),1.6*math.sin(angle),-length/2+1)
                b=(1.6*math.cos(angle),1.6*math.sin(angle),-length/2+4)
                face([(0,0,-length/2),a,b,(0,0,-length/2+5)],True)
        lines=['# Original Caelum Argenteum #137. Source: assets/source/art/elemental_518/MODELS.json',f'o ca_{model["name"]}']
        # Native model pitch rotates the +X forward axis. OBJ Y remains up.
        lines += [f'v {z:.6f} {y:.6f} {x:.6f}' for x,y,z in vertices]
        lines += [f'vt {u:.6f} {v:.6f}' for u,v in uvs]
        lines += ['s 1','usemtl '+data['material']]
        lines += ['f '+' '.join(f'{i}/{i}' for i in face) for face in faces]
        (OUT/f'ca_{model["name"]}.obj').write_text('\n'.join(lines)+'\n',encoding='utf-8')
        s=model['scale']
        blocks.append(f'Model {model["actor"]}\n{{\n Path "models/caelum/projectiles"\n Model 0 "ca_{model["name"]}.obj"\n Scale {s} {s} {s}\n CorrectPixelStretch\n PitchFromMomentum\n DontCullBackFaces\n FrameIndex {model["sprite"]} A 0 0\n}}')
    blocks.append(END)
    path=ROOT/'src/MODELDEF';text=path.read_text(encoding='utf-8')
    block='\n'.join(blocks)
    if BEGIN in text:text=text[:text.index(BEGIN)]+block+text[text.index(END)+len(END):]
    else:text+='\n'+block+'\n'
    path.write_text(text,encoding='utf-8')
    print('Generated five original projectile models and native momentum bindings.')

if __name__=='__main__':main()
