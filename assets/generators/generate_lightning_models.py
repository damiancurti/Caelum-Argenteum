"""A shared travelling lightning ray for staff/other weapons and NPCs (#137)."""
from pathlib import Path
import struct,math,json
ROOT=Path(__file__).resolve().parents[2]
BEGIN='// BEGIN GENERATED LIGHTNING RAYS'
END='// END GENERATED LIGHTNING RAYS'

def main():
    out=ROOT/'src/models/caelum/projectiles'
    atlas=ROOT/'src/graphics/caelum/vfx/projectiles.png'
    w,h=struct.unpack('>II',atlas.read_bytes()[16:24])
    data=json.loads((ROOT/'assets/source/art/elemental_518/DESIGN.json').read_text())
    blocks=[BEGIN]
    for phase in range(4):
        verts=[];uv=[];faces=[]
        for plane in range(3):
            a=plane*math.pi/3
            face=[]
            # The luminous ray extends behind the collision origin, not ahead.
            for along,side in [(0,-1),(0,1),(1,1),(1,-1)]:
                verts.append((-48+48*along,side*5*math.cos(a),side*5*math.sin(a)))
                x1,x2=data['projectiles_columns'][phase:phase+2]
                y1,y2=data['projectiles_rows'][7:9]
                uv.append(((x1+(x2-x1)*(.08+.84*along))/w,1-(y1+(y2-y1)*(.08 if side>0 else .92))/h))
                face.append(len(verts))
            faces.append(face)
        lines=['# Original #137 flight-aligned lightning ray. Collision origin is the leading tip.']
        lines += [f'v {x:.9f} {y:.9f} {z:.9f}' for x,y,z in verts]
        lines += [f'vt {u:.9f} {v:.9f}' for u,v in uv]
        lines += ['usemtl graphics/caelum/vfx/projectiles.png']
        lines += ['f '+' '.join(f'{i}/{i}' for i in face) for face in faces]
        name=f'lightning_{phase}.obj';(out/name).write_text('\n'.join(lines)+'\n',encoding='utf-8')
        for actor in ['CaelumPlayerMagicProjectile','CaelumHomingMagicProjectile','CaelumExplosiveMagicProjectile','CaelumChargedPlayerMagicProjectile','CaelumChargedHomingMagicProjectile','CaelumChargedExplosiveMagicProjectile','CaelumActorSimpleElementalProjectile','CaelumActorExplosiveElementalProjectile']:
            blocks.append(f'Model {actor}\n{{\n Path "models/caelum/projectiles"\n Model 0 "{name}"\n Scale 1 1 1\n PitchFromMomentum\n CorrectPixelStretch\n DontCullBackFaces\n FrameIndex VFLI {chr(65+phase)} 0 0\n}}')
    blocks.append(END);block='\n'.join(blocks)
    path=ROOT/'src/MODELDEF';text=path.read_text(encoding='utf-8')
    if BEGIN in text:text=text[:text.index(BEGIN)]+block+text[text.index(END)+len(END):]
    else:text+='\n'+block+'\n'
    path.write_text(text,encoding='utf-8')
    print('Registered the same animated lightning ray for every player/NPC projectile variant.')

if __name__=='__main__':main()
