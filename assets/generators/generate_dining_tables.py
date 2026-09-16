#!/usr/bin/env python3
"""Mesas originales para 2/6/12 sillas; madera ya utilizada por el proyecto."""
from pathlib import Path
import math,sys
sys.dont_write_bytecode=True
from generate_stash_models import Mesh,WOOD,METAL

def rectangular(length,width):
    m=Mesh()
    # Con AngleOffset -90, la profundidad OBJ sigue el eje longitudinal del juego.
    m.add_box(WOOD,(0,32,0),(width,4,length))
    for x in (-width/2+8,width/2-8):
        m.add_box(WOOD,(x,26,0),(4,9,length-10))
        for z in (-length/2+10,length/2-10):
            m.add_box(WOOD,(x,14,z),(8,28,8))
            m.add_box(METAL,(x,3,z),(8.3,2,8.3))
    for z in (-length/2+8,length/2-8):m.add_box(WOOD,(0,26,z),(width-10,9,4))
    # Juntas discretas entre tablones, usando el metal oscuro original.
    for x in range(int(-width/2+16),int(width/2),16):m.add_box(METAL,(x,34.02,0),(0.3,0.08,length-1))
    return m

def round_table():
    m=Mesh();n=32;radius=40
    for i in range(n):
        a,b=2*math.pi*i/n,2*math.pi*(i+1)/n
        x1,z1=radius*math.cos(a),radius*math.sin(a);x2,z2=radius*math.cos(b),radius*math.sin(b)
        m.add_triangle(WOOD,((0,34,0),(x1,34,z1),(x2,34,z2)))
        m.add_triangle(WOOD,((0,30,0),(x2,30,z2),(x1,30,z1)))
        m.add_quad(WOOD,((x1,30,z1),(x2,30,z2),(x2,34,z2),(x1,34,z1)))
    m.add_box(WOOD,(0,15,0),(12,30,12))
    m.add_box(WOOD,(0,3,0),(60,6,10));m.add_box(WOOD,(0,3,0),(10,6,60))
    return m

def generate():
    root=Path(__file__).resolve().parents[2];dest=root/'src/models/caelum/props/rest'
    for name,mesh in [('table_small',round_table()),('table_normal',rectangular(192,96)),('table_large',rectangular(384,192))]:
        p=dest/('ca_'+name+'.obj');mesh.write(p)
        p.write_text(p.read_text().replace('o CaelumStashChest','o CaelumDiningTable'))
        print(p.relative_to(root))
if __name__=='__main__':generate()
