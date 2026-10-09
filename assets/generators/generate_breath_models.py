"""Map the untouched directional breath atlas to four cosmetic cone segments."""
from pathlib import Path
import math, shutil, json, struct
ROOT=Path(__file__).resolve().parents[2]
BEGIN='// BEGIN GENERATED DEMON FLAME PLANES'
END='// END GENERATED DEMON FLAME PLANES'

def main():
    out=ROOT/'src/models/caelum/projectiles';out.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(ROOT/'assets/source/art/elemental_518/breath.png',out/'breath.png')
    data=json.loads((ROOT/'assets/source/art/elemental_518/DESIGN.json').read_text())
    width,height=struct.unpack('>II',(out/'breath.png').read_bytes()[16:24])
    blocks=[BEGIN]
    for segment in range(4):
        for phase in range(4):
            vertices=[];uvs=[];faces=[]
            # Unit total length. Runtime scales from the authoritative breath range.
            for plane in range(3):
                angle=plane*math.pi/3
                points=[]
                for end,side in [(0,-1),(0,1),(1,1),(1,-1)]:
                    along=(segment+end)/4
                    radius=max(.001,along*math.tan(math.pi/6))
                    vertices.append((side*radius*math.cos(angle),side*radius*math.sin(angle),(end-.5)/4))
                    y1,y2=data['breath_rows'][phase:phase+2]
                    uvs.append((.20+.72*along,1-(y1+(y2-y1)*(0 if side==1 else 1))/height))
                    points.append(len(vertices))
                faces.append(points)
            name=f'flame_{segment}_{phase}.obj'
            lines=['# Original #137 crossed cone planes; length normalized to the existing breath range.', 'o flame_segment']
            lines += [f'v {z:.9f} {y:.9f} {x:.9f}' for x,y,z in vertices]
            lines += [f'vt {u:.9f} {v:.9f}' for u,v in uvs]
            lines += ['usemtl models/caelum/projectiles/breath.png']
            lines += ['f '+' '.join(f'{i}/{i}' for i in face) for face in faces]
            (out/name).write_text('\n'.join(lines)+'\n',encoding='utf-8')
            frame=chr(65+segment*4+phase)
            blocks.append(f'Model CaelumDemonFlameVisual\n{{\n Path "models/caelum/projectiles"\n Model 0 "{name}"\n Scale 1 1 1\n UseActorPitch\n CorrectPixelStretch\n DontCullBackFaces\n FrameIndex VFBR {frame} 0 0\n}}')
    blocks.append(END);block='\n'.join(blocks)
    path=ROOT/'src/MODELDEF';text=path.read_text(encoding='utf-8')
    if BEGIN in text:text=text[:text.index(BEGIN)]+block+text[text.index(END)+len(END):]
    else:text+='\n'+block+'\n'
    path.write_text(text,encoding='utf-8')
    # Native sprite registration supplies a fallback when model rendering is disabled.
    text='\n'.join(f'Sprite "VFBR{chr(65+i)}0", 256, 170 {{ XScale 4 YScale 2.65625 Offset 128, 85 Patch "graphics/caelum/vfx/projectiles.png", {-256*(i%4)}, 0 }}' for i in range(16))
    (ROOT/'src/graphics/caelum/vfx/breath.textures').write_text(text+'\n',encoding='utf-8')
    print('Generated sixteen flame-plane frames; no gameplay cone or power changes.')

if __name__=='__main__':main()
