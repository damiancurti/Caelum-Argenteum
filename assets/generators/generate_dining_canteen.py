"""Original deterministic table canteen mesh using the owned inventory texture.

Coordinates retain the existing 0.25 actor scale. No inventory or capacity rules
are encoded here. Pillow is not required; the original texture is unmodified.
"""
from pathlib import Path
from math import cos, sin, pi
from generate_stash_models import Mesh

ROOT=Path(__file__).resolve().parents[2]
TEXTURE='graphics/caelum/icons/water/canteen_large.png'

def generate():
    m=Mesh()
    # Rounded rectangular flask, beveled edges, real thickness on both sides.
    outline=[(-24,2),(-32,9),(-32,57),(-25,67),(25,67),(32,57),(32,9),(24,2)]
    layers=[(-13,.86),(-9,1),(9,1),(13,.86)]
    rings=[[(x*factor,34+(y-34)*factor,z) for x,y in outline] for z,factor in layers]
    def leather(points):
        m.add_polygon(TEXTURE,points,[(.48+x/320,.52+(y-34)/300) for x,y,z in points])
    # GZDoom's OBJ reader accepts triangles/quads, not arbitrary n-gons.
    for ring in (list(reversed(rings[0])),rings[-1]):
        center=tuple(sum(p[axis] for p in ring)/len(ring) for axis in range(3))
        for i in range(8):leather([center,ring[i],ring[(i+1)%8]])
    for a,b in zip(rings,rings[1:]):
        for i in range(8):leather([a[i],a[(i+1)%8],b[(i+1)%8],b[i]])
    # Brass screw cap uses only the opaque brass region of the existing icon.
    for i in range(16):
        a,b=2*pi*i/16,2*pi*(i+1)/16
        points=[(8*cos(a),67,8*sin(a)),(8*cos(b),67,8*sin(b)),(8*cos(b),80,8*sin(b)),(8*cos(a),80,8*sin(a))]
        m.add_polygon(TEXTURE,points,[(.43,.84),(.49,.84),(.49,.9),(.43,.9)])
        m.add_polygon(TEXTURE,[(0,80,0),points[3],points[2]],[(.46,.87)]*3)
    # Folded leather strap is solid geometry, not a camera-facing plane.
    for x in (-19,19):
        for i in range(8):
            y0,y1=40+i*5,45+i*5
            z0,z1=-15-5*sin(i*pi/8),-15-5*sin((i+1)*pi/8)
            start=len(m.uvs)
            m.add_box(TEXTURE,(x,(y0+y1)/2,(z0+z1)/2),(5,6,3))
            m.uvs[start:]=[(.38+u*.06,.52+v*.16) for u,v in m.uvs[start:]]
    start=len(m.uvs)
    m.add_box(TEXTURE,(0,80,-15),(42,5,3))
    m.uvs[start:]=[(.38+u*.06,.52+v*.16) for u,v in m.uvs[start:]]
    path=ROOT/'src/models/caelum/props/rest/ca_large_canteen.obj'
    m.write(path)
    path.write_text(path.read_text(encoding='utf-8').replace('o CaelumStashChest','o CaelumLargeCanteen'),encoding='utf-8')
    print(path.relative_to(ROOT))

if __name__=='__main__':generate()
