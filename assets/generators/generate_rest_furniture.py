#!/usr/bin/env python3
"""Genera la silla y el catre originales de la prueba de descanso."""
from pathlib import Path
import sys
sys.dont_write_bytecode = True
from generate_stash_models import Mesh, WOOD, METAL, INSIDE


def chair():
    m = Mesh()
    # Asiento, patas, travesaños y respaldo de madera; no incluye al personaje.
    m.add_box(WOOD, (0,18,0), (38,4,34))
    for x in (-17,17):
        for z in (-14,14): m.add_box(WOOD, (x,8,z), (5,16,5))
        m.add_box(WOOD, (x,35,-15), (5,34,5))
        m.add_box(WOOD, (x,8,0), (3,3,28))
    for y in (28,39,49): m.add_box(WOOD, (0,y,-15), (35,5,3))
    m.add_box(WOOD, (0,8,-14), (35,3,3))
    return m


def bed():
    m = Mesh()
    # Catre bajo: marco de madera, herrajes y lona del material propio existente.
    for x in (-24,24):
        m.add_box(WOOD, (x,6,0), (4,8,104))
        for z in (-48,48):
            m.add_box(WOOD, (x,5,z), (6,10,6))
            m.add_box(METAL, (x,8,z), (6.5,2,6.5))
    for z in (-50,50): m.add_box(WOOD, (0,6,z), (48,8,4))
    m.add_box(INSIDE, (0,10,0), (46,4,98))
    m.add_box(INSIDE, (0,15,-36), (32,6,15))
    m.add_box(WOOD, (0,19,-51), (48,8,3))
    return m


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
