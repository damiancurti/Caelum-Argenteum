#!/usr/bin/env python3
"""Generate the owned rest furniture; ordinary dimensions use the current bill."""
from pathlib import Path
import sys
sys.dont_write_bytecode = True
from generate_stash_models import Mesh, WOOD, METAL, INSIDE


def chair():
    from generate_basic_rest_furniture import construction
    return construction('chair')[0]


def bed():
    from generate_basic_rest_furniture import construction
    return construction('bed')[0]


def bag_roll():
    m = Mesh()
    # Rollo de lona con dos correas; comparte los materiales originales.
    m.add_cylinder_z(INSIDE, (0,8,0), 8, 32, 16)
    for z in (-10,10): m.add_cylinder_z(WOOD, (0,8,z), 8.4, 3, 16)
    return m


def bag_open():
    m = Mesh()
    m.add_box(INSIDE, (0,2,0), (40,4,88))
    m.add_box(INSIDE, (0,5,-33), (30,6,17))
    # Pliegues laterales de la bolsa, sin superficie rígida ni patas.
    for x in (-19,19): m.add_box(INSIDE, (x,4,5), (2,3,74))
    m.add_box(WOOD, (20.1,2,5), (0.6,1,72))
    return m


def generate():
    root = Path(__file__).resolve().parents[2]
    folder = root/'src/models/caelum/props/rest'
    folder.mkdir(parents=True, exist_ok=True)
    for name, mesh in [('chair',chair()),('bed',bed()),('bag_roll',bag_roll()),('bag_open',bag_open())]:
        p=folder/f'ca_rest_{name}.obj'
        mesh.write(p)
        p.write_text(p.read_text().replace('o CaelumStashChest','o CaelumRest'+name.title()))
        print(p.relative_to(root))

if __name__ == '__main__':
    generate()
