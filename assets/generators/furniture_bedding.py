"""Shared deterministic sewn bedding geometry; existing owned cotton texture."""
import math

CLOTH = 'models/caelum/world/alchemy_ingredients/cloth.png'

def cushion(mesh, center, size, units, rounded=False):
    """Padded envelope with bevelled edges and a raised, softly curved top."""
    w,h,d=size; cx,cy,cz=center
    rings=[]
    for y,scale in [(-.5,.82),(-.30,1),(.22,1),(.5,.82)]:
        ring=[]
        for i in range(16):
            a=math.tau*i/16
            # Superellipse: mattress corners are rounded, pillows softer.
            power=.8 if rounded else .28
            x=math.copysign(abs(math.cos(a))**power,math.cos(a))*w*.5*scale
            z=math.copysign(abs(math.sin(a))**power,math.sin(a))*d*.5*scale
            ring.append(((cx+x)*units,(cy+y*h)*units,(cz+z)*units))
        rings.append(ring)
    for row,(lo,hi) in enumerate(zip(rings,rings[1:])):
        for i in range(16):
            j=(i+1)%16
            shade=(3 if row==1 else 5) if rounded else (1 if row==1 else 4)
            texture=f'models/caelum/world/alchemy_ingredients/cloth_shade{shade}.png'
            mesh.add_quad(texture,[lo[i],lo[j],hi[j],hi[i]])
    for ring,y in [(rings[0],-.5),(rings[-1],.5)]:
        for i in range(16):
            mesh.add_triangle(CLOTH,[(cx*units,(cy+y*h)*units,cz*units),ring[i],ring[(i+1)%16]])

def bedding(mesh, width, depth, surface, spec, units, cloth_kg_m2):
    w,d=width-.13,depth-.13; t=spec['mattress_thickness_m']
    cushion(mesh,(0,surface-t/2,0),(w,t,d),units)
    pw,ph,pd=spec['pillow_m']; count=spec['pillows']
    mass=(2*w*d+2*t*(w+d))*cloth_kg_m2+w*d*t*spec['cotton_fill_kg_m3']
    for i in range(count):
        x=(i-(count-1)/2)*(pw+.04)
        cushion(mesh,(x,surface+ph/2,-d/2+pd*.65),(pw,ph,pd),units,True)
        mass+=(2*pw*pd+2*ph*(pw+pd))*cloth_kg_m2+pw*ph*pd*spec['cotton_fill_kg_m3']
    return mass
