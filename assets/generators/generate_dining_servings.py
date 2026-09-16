#!/usr/bin/env python3
"""Generate original low-poly table servings using existing project materials."""
from pathlib import Path
import math
import sys
sys.dont_write_bytecode=True
from generate_stash_models import Mesh

MATERIAL_ROOT='models/caelum/props/stations/ca_station_'
PAPER=MATERIAL_ROOT+'paper.png'
BREAD=MATERIAL_ROOT+'wax.png'
CRUST=MATERIAL_ROOT+'wood.png'
FOOD=MATERIAL_ROOT+'leather.png'
DARK=MATERIAL_ROOT+'iron.png'


def lathe(mesh,material,profile,center=(0,0,0),segments=20,stretch=(1,1)):
    # Perfil de revolución: radio/altura. Se conserva escala MU de los tableros.
    for i in range(segments):
        a,b=2*math.pi*i/segments,2*math.pi*(i+1)/segments
        for (r1,h1),(r2,h2) in zip(profile,profile[1:]):
            pts=[]
            for rad,height,angle in [(r1,h1,a),(r1,h1,b),(r2,h2,b),(r2,h2,a)]:
                pts.append((center[0]+rad*math.cos(angle)*stretch[0],center[1]+height,center[2]+rad*math.sin(angle)*stretch[1]))
            mesh.add_quad(material,pts)


def food_plate():
    mesh=Mesh()
    lathe(mesh,PAPER,[(0,0.7),(5,0.7),(8,1.2),(10.1,2),(10.5,1.4),(8,0),(0,0)])
    # Pan dorado y porciones de guiso: geometría original, sin nuevos PNG.
    lathe(mesh,CRUST,[(0,0),(3,0),(3.4,1.7),(2.8,3.3),(1.4,4),(0,4.1)],(-3,0.8,-1),12,(1.1,1.5))
    for z in (-2.4,0,2.4):mesh.add_box(BREAD,(-3,4.8,z),(4,0.3,0.6))
    for x,z in [(3,-3),(5,-1),(3,1),(4,3)]:
        lathe(mesh,FOOD,[(0,0),(1.5,0),(1.8,1),(1.1,2.4),(0,2.6)],(x,1,z),8)
    return mesh


def water_cup():
    mesh=Mesh()
    lathe(mesh,PAPER,[(0,0),(3.4,0),(4.2,7),(3.4,7.2),(2.9,1),(0,1)])
    lathe(mesh,DARK,[(0,1.3),(2.9,1.3)],segments=20)
    # Asa con abertura real.
    for y in (2,6):mesh.add_box(PAPER,(5,y,0),(3.5,1,1.3))
    mesh.add_box(PAPER,(6.5,4,0),(1,4,1.3))
    return mesh


def generate():
    root=Path(__file__).resolve().parents[2]
    folder=root/'src/models/caelum/props/rest'
    for name,mesh in [('food_plate',food_plate()),('water_cup',water_cup())]:
        p=folder/f'ca_{name}.obj';mesh.write(p)
        p.write_text(p.read_text().replace('o CaelumStashChest','o CaelumDiningServing'))
        print(p.relative_to(root))

if __name__=='__main__':generate()
