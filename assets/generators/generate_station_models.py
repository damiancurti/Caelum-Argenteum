#!/usr/bin/env python3
"""Genera las doce estaciones sencillas, basadas en los sprites del proyecto."""

from __future__ import annotations

import argparse
import json
import math
import random
from pathlib import Path

from PIL import Image
from generate_environment_models import Mesh as EnvironmentMesh
from generate_stash_models import Mesh as StashMesh

DIRECTORY = "models/caelum/props/stations"
MATERIALS = {
    "wood": (103, 66, 39), "iron": (83, 88, 94),
    "brass": (161, 119, 56), "stone": (100, 89, 81),
    "leather": (114, 57, 35), "cloth": (39, 66, 111),
    "paper": (182, 154, 104), "gem": (137, 66, 186),
    "ember": (222, 92, 20), "wax": (214, 183, 113),
    "map": (162, 139, 94),
}
STATIONS = (
    ("workbench", "CaelumWorkbenchStation", "CWBK", "Banco de trabajo"),
    ("forge", "CaelumForgeStation", "CFRG", "Forja"),
    ("anvil", "CaelumAnvilStation", "CANV", "Yunque"),
    ("ranged", "CaelumRangedWorkshopStation", "CRNG", "Taller de distancia"),
    ("sawmill", "CaelumSawmillStation", "CSAW", "Aserradero"),
    ("armor", "CaelumArmorWorkshopStation", "CARM", "Taller de armaduras"),
    ("sewing", "CaelumSewingMachineStation", "CSEW", "Máquina de coser"),
    ("altar", "CaelumEssenceAltarStation", "CESA", "Altar de esencias"),
    ("globe", "CaelumGlobeStation", "CGLB", "Globo terráqueo"),
    ("jeweler", "CaelumJewelerBenchStation", "CJWL", "Banco joyero"),
    ("fine_tools", "CaelumFineToolsBenchStation", "CFIN", "Herramientas finas"),
    ("master", "CaelumMasterBenchStation", "CMST", "Banco maestro"),
)


def material(name):
    return f"{DIRECTORY}/ca_station_{name}.png"


class Mesh(EnvironmentMesh):
    def box(self, kind, center, size):
        # Ambas bibliotecas comparten vértices/UV; se conserva la malla ambiental.
        source = StashMesh()
        source.add_box(material(kind), center, size)
        for name, faces in source.faces.items():
            for face in faces:
                self.add_polygon(name, [source.vertices[i-1] for i in face],
                                 [source.uvs[i-1] for i in face])

    def rod(self, kind, start, end, radius=0.6, end_radius=None, sides=6):
        self.add_frustum(material(kind), start, end, radius,
                         radius if end_radius is None else end_radius, sides)

    def ball(self, kind, center, radii, rings=4, segments=8):
        self.add_ellipsoid(material(kind), center, radii, seed=43310,
                           rings=rings, segments=segments, irregularity=0)

    def ring(self, kind, center, radius, tube=0.5, plane="xy", segments=16):
        cx, cy, cz = center
        for i in range(segments):
            a, b = math.tau*i/segments, math.tau*(i+1)/segments
            if plane == "xy":
                p = (cx+radius*math.cos(a), cy+radius*math.sin(a), cz)
                q = (cx+radius*math.cos(b), cy+radius*math.sin(b), cz)
            elif plane == "yz":
                p = (cx, cy+radius*math.cos(a), cz+radius*math.sin(a))
                q = (cx, cy+radius*math.cos(b), cz+radius*math.sin(b))
            else:
                p = (cx+radius*math.cos(a), cy, cz+radius*math.sin(a))
                q = (cx+radius*math.cos(b), cy, cz+radius*math.sin(b))
            self.rod(kind, p, q, tube, sides=4)

    def hammer(self, x, y, z, small=False):
        k = 0.6 if small else 1
        self.rod("wood", (x, y, z-3*k), (x, y, z+4*k), 0.45*k)
        self.box("iron", (x, y+0.7*k, z+3*k), (4.2*k, 1.8*k, 2.2*k))

    def chisel(self, x, y, z):
        self.rod("wood", (x, y, z-2), (x, y, z+0.5), 0.55)
        self.rod("iron", (x, y, z+0.5), (x, y, z+3.5), 0.35, 0.12, sides=4)

    def book(self, x, y, z, width=6, depth=5):
        self.box("leather", (x, y, z), (width, 1.0, depth))
        self.box("paper", (x, y+0.7, z), (width-0.4, 0.6, depth-0.4))

    def candle(self, x, y, z):
        self.rod("brass", (x, y, z), (x, y+0.6, z), 1.2)
        self.rod("wax", (x, y+0.6, z), (x, y+4, z), 0.65)
        self.ball("ember", (x, y+4.7, z), (0.5, 0.85, 0.5), rings=2, segments=4)

    def table(self, back=False, drawers=False):
        for x in (-13.5, 13.5):
            for z in (-7, 7):
                self.box("wood", (x, 12, z), (3, 24, 3))
                self.box("iron", (x, 2, z), (3.2, 1.8, 3.2))
        for z in (-7, 7):
            self.box("wood", (0, 7, z), (27, 2.1, 2.1))
        for z in (-6, 0, 6):
            self.box("wood", (0, 25, z), (34, 3, 5.9))
        if drawers:
            self.box("wood", (7, 19.5, 0), (14, 7, 15))
            for x in (3, 11):
                self.box("wood", (x, 19.5, 7.7), (6.5, 5.6, 0.7))
                self.rod("brass", (x-0.8, 19.5, 8.3), (x+0.8, 19.5, 8.3), 0.3)
        if back:
            for x in (-14, 14):
                self.box("wood", (x, 31.5, -7), (2, 13, 2))
            self.box("wood", (0, 36.5, -7), (30, 2, 2))


def add_vise(m, x, y, z):
    m.box("iron", (x, y, z), (4, 3, 4))
    m.box("iron", (x, y+2.3, z-1.6), (4.5, 2, 1.2))
    m.box("iron", (x, y+2.3, z+1.6), (4.5, 2, 1.2))
    m.rod("iron", (x, y, z+1), (x, y, z+5), 0.5)
    m.rod("iron", (x, y-2, z+5), (x, y+2, z+5), 0.3)


def add_tool_rail(m):
    for x in (-10, -5, 0, 5, 10):
        m.rod("wood", (x, 30, -6), (x, 35, -6), 0.45)
        m.box("iron", (x, 35, -6), (2.8, 1.2, 1.1))


def add_bow(m, center, vertical=True):
    x, y, z = center
    points = []
    for i in range(7):
        a = -math.pi/2 + math.pi*i/6
        points.append((x+3.8*math.cos(a), y+6*math.sin(a), z)
                      if vertical else (x+6*math.sin(a), y, z+3.8*math.cos(a)))
    for p, q in zip(points, points[1:]): m.rod("wood", p, q, 0.5)
    m.rod("wax", points[0], points[-1], 0.13, sides=4)


def make_station(name):
    m = Mesh("CaelumStation_"+name)
    if name == "workbench":
        m.table(drawers=True)
        add_vise(m, 11, 28, 2)
        m.hammer(-8, 27.2, 1)
        m.chisel(-2, 27.1, 2)
        m.box("wood", (-7, 27, -5), (12, 1, 2))
        m.candle(-13, 26.5, -6)
    elif name == "anvil":
        m.rod("wood", (0, 0, 0), (0, 13, 0), 11.5, 10, sides=10)
        m.ring("iron", (0, 3, 0), 11.3, 0.5, plane="xz", segments=10)
        m.box("iron", (0, 14, 0), (18, 3, 10))
        m.box("iron", (0, 18, 0), (9, 5, 6))
        m.box("iron", (0, 22, 0), (18, 4, 10))
        m.rod("iron", (9, 22, 0), (17, 22.5, 0), 3.8, 0.45, sides=6)
        m.box("iron", (-11, 22, 0), (5, 3.5, 7))
        m.hammer(-2, 24.5, 0)
    elif name == "forge":
        m.box("stone", (0, 3, 0), (30, 6, 23))
        # Hogar hueco: los bloques laterales dejan visible el carbón encendido.
        for y in (8, 13, 18):
            for x in (-10.5, 10.5):
                m.box("stone", (x, y, 0), (8, 4.7, 18))
            m.box("stone", (0, y, -6), (13, 4.7, 6))
        m.box("iron", (0, 7, 1), (14, 1.2, 13))
        for x, z in ((-4, 1), (0, 4), (4, 1), (0, -2)):
            m.ball("ember", (x, 8.5, z), (2, 1.7, 2), rings=2, segments=5)
        m.box("stone", (0, 21, -0.8), (27, 3.5, 16))
        m.box("stone", (0, 25.5, -4), (19, 6, 10))
        m.rod("iron", (0, 28.5, -4), (0, 42, -4), 4.0, sides=8)
        m.ring("iron", (0, 40.5, -4), 4.3, 0.6, plane="xz", segments=8)
        m.rod("wood", (-13, 10, 9), (-13, 27, 9), 0.55)
        m.box("iron", (-13, 9, 9), (3.8, 4, 1))
    elif name == "ranged":
        m.table(back=True, drawers=True)
        add_bow(m, (0, 29, 0), vertical=False)
        add_bow(m, (6, 33, -6))
        m.rod("leather", (-11, 26.5, -4), (-11, 29, -4), 2.6)
        for x in (-12, -11, -10):
            m.rod("wood", (x, 28, -4), (x, 37, -4), 0.18, sides=4)
            m.box("wax", (x, 35, -4), (0.7, 2, 0.45))
        m.chisel(-7, 27, 2)
        m.box("paper", (-4, 33, -6), (5, 6, 0.2))
    elif name == "sawmill":
        m.table()
        # Sierra circular manual: rueda, eje y manivela, sin maquinaria moderna.
        m.rod("iron", (-10, 30, -1), (10, 30, -1), 0.6)
        for i in range(16):
            a, b = math.tau*i/16, math.tau*(i+1)/16
            tip = (0, 30+9*math.sin(a+0.12), -1+9*math.cos(a+0.12))
            p = (0, 30+7.9*math.sin(a), -1+7.9*math.cos(a))
            q = (0, 30+7.9*math.sin(b), -1+7.9*math.cos(b))
            # El disco está en YZ y gira sobre el eje X.
            m.add_triangle(material("iron"), (p, q, tip))
        # Disco perpendicular al eje real.
        m.rod("iron", (-0.45, 30, -1), (0.45, 30, -1), 7.9, sides=16)
        for x in (-10, 10): m.box("wood", (x, 29, -1), (2.5, 7, 3))
        m.rod("iron", (-10, 30, -1), (-10, 33, -1), 0.5)
        m.rod("wood", (-10, 33, -1), (-13, 33, -1), 0.6)
        m.rod("wood", (-13, 29, 5), (13, 29, 5), 2.5, sides=8)
        for x in (-9, -4, 1, 6): m.box("wood", (x, 6, 0), (3.6, 2, 12))
    elif name == "armor":
        m.table(drawers=True)
        m.rod("wood", (7, 26.5, -3), (7, 33, -3), 0.8)
        m.ball("leather", (7, 34, -3), (4, 5, 2.8), rings=3, segments=6)
        m.box("iron", (7, 34, 0), (6, 6.5, 0.65))
        m.rod("leather", (7, 39, -3), (7, 41, -3), 1.5)
        for x in (-11, -6): m.rod("leather", (x, 28, -5), (x, 28, 3), 1.4)
        m.hammer(-2, 27.1, 3, small=True)
        m.box("leather", (-6, 26.9, 5), (10, 0.5, 4))
    elif name == "sewing":
        m.table()
        m.box("leather", (-6, 26.7, 5), (11, 0.35, 7))
        m.box("leather", (-6, 21, 8.6), (11, 11, 0.3))
        m.box("iron", (0, 27.3, 0), (19, 1.4, 8))
        m.box("iron", (6, 32, 0), (3.5, 8, 4))
        m.box("iron", (-1, 35.5, 0), (14, 3, 4))
        m.box("iron", (-7, 33.5, 0), (2, 4, 3))
        m.rod("iron", (-7, 32, 0), (-7, 27.8, 0), 0.18, sides=4)
        m.ring("brass", (9, 32, 0), 4, 0.7, plane="yz", segments=12)
        m.rod("brass", (9, 32, -4), (9, 32, 4), 0.35)
        m.rod("leather", (2, 37, 0), (2, 40, 0), 1.1)
        m.rod("wax", (2, 39, 0), (-7, 35, 0), 0.1, sides=4)
        m.box("iron", (0, 7, 1), (11, 1, 5))
    elif name == "altar":
        m.rod("stone", (0, 0, 0), (0, 4, 0), 14.5, sides=8)
        m.rod("stone", (0, 4, 0), (0, 22, 0), 11, 12, sides=8)
        m.rod("brass", (0, 22, 0), (0, 24, 0), 13, sides=8)
        for a in (0, math.pi/2, math.pi, math.pi*1.5):
            x, z = 9*math.cos(a), 9*math.sin(a)
            m.box("brass", (x, 14, z), (1.1, 14, 1.1))
        m.rod("gem", (0, 26, 0), (0, 37, 0), 4.5, 0, sides=6)
        m.rod("gem", (0, 22.5, 0), (0, 26, 0), 0, 4.5, sides=6)
        m.ring("brass", (0, 30, -1), 8, 0.45, segments=12)
        for x in (-9, 9): m.candle(x, 24, 3)
        m.book(0, 4.5, 12, 6, 4)
    elif name == "globe":
        m.rod("wood", (0, 0, 0), (0, 3, 0), 11, sides=10)
        m.rod("wood", (0, 3, 0), (0, 14, 0), 3, 2.2, sides=8)
        for x in (-10, 10):
            m.rod("wood", (x, 1, 0), (x, 21, 0), 1.7, 1.2)
        m.ring("brass", (0, 21, 0), 12, 0.7, plane="xz", segments=16)
        m.ring("brass", (0, 28, 0), 10.8, 0.55, segments=16)
        # Coordenadas UV esféricas continuas para un mapa esquemático propio.
        sphere(m, (0, 28, 0), 9.5)
        m.rod("brass", (0, 37.4, 0), (0, 40, 0), 0.8)
    elif name == "jeweler":
        m.table(back=True, drawers=True)
        m.box("leather", (-1, 26.7, 1), (17, 0.35, 10))
        m.box("wood", (0, 26, 11), (3.6, 2, 5))
        for x, z, kind in ((-5, 0, "gem"), (-1, 3, "brass"), (4, 0, "gem")):
            m.ball(kind, (x, 27.5, z), (1.3, 1, 1.3), rings=2, segments=5)
        m.rod("brass", (9, 27, -4), (9, 33, -4), 0.5)
        m.ring("brass", (5.5, 33, -4), 3.2, 0.5, segments=12)
        add_tool_rail(m)
        m.hammer(-9, 27, 3, small=True)
        m.candle(-13, 26.5, -5)
    elif name == "fine_tools":
        m.table()
        m.box("cloth", (0, 26.7, 0), (28, 0.3, 15))
        m.box("wood", (3, 27.5, -4), (18, 1.3, 7))
        m.box("wood", (3, 31.5, -7), (18, 8, 0.9))
        for x in (-3, 0, 3, 6, 9):
            m.rod("iron", (x, 29, -6.3), (x, 34, -6.3), 0.25, sides=4)
            m.rod("wood", (x, 28, -6.3), (x, 30, -6.3), 0.55)
        m.ring("brass", (-9, 27.5, 2), 2.6, 0.45, plane="xz", segments=10)
        m.rod("wood", (-9, 27.5, 4), (-9, 27.5, 7), 0.6)
        m.chisel(1, 27.3, 3)
        m.rod("brass", (7, 27, 0), (7, 30, 0), 1.2)
        m.rod("brass", (7, 30, 0), (7, 31.3, 0), 0.5)
    else:
        m.table(back=True, drawers=True)
        m.box("cloth", (0, 26.7, 0), (14, 0.3, 11))
        m.box("paper", (0, 27, 1), (9, 0.15, 7))
        add_tool_rail(m)
        add_vise(m, 11, 28, 2)
        m.book(-11, 27, 2, 6, 5)
        m.candle(-13, 26.5, -5)
        m.hammer(-4, 27.7, 0, small=True)
        for x in (-13.5, 13.5):
            m.box("brass", (x, 22, 7.2), (3.2, 1.1, 3.2))
    # Una estación mantiene Radius 20 / Height 48 y Scale 0.5. Los modelos
    # caben dentro de esa envolvente; MODELDEF compensa la escala visual.
    radius = max(math.hypot(x, z) for x, _, z in m.vertices)
    k = min(1.0, 19.5/radius)
    m.vertices = [(x*k, max(0.0, y), z*k) for x, y, z in m.vertices]
    return m


def sphere(m, center, radius):
    cx, cy, cz = center
    rings, segments = 6, 12
    def point(i, j):
        latitude = -math.pi/2 + math.pi*i/rings
        longitude = math.tau*j/segments
        return (cx+radius*math.cos(latitude)*math.cos(longitude),
                cy+radius*math.sin(latitude),
                cz+radius*math.cos(latitude)*math.sin(longitude))
    for i in range(rings):
        for j in range(segments):
            corners = [(i,j), (i,j+1), (i+1,j+1), (i+1,j)]
            if i == 0: corners = [corners[0], corners[2], corners[3]]
            if i == rings-1: corners = [corners[0], corners[1], corners[2]]
            m.add_polygon(material("map"), [point(a,b) for a,b in corners],
                          [(b/segments, a/rings) for a,b in corners])


def write_textures(directory):
    for index, (kind, color) in enumerate(MATERIALS.items()):
        rng = random.Random(433100+index)
        image = Image.new("RGB", (128, 128))
        pixels = []
        for y in range(128):
            for x in range(128):
                n = rng.uniform(-5, 5)
                if kind == "wood":
                    n += 7*math.sin(x/3 + math.sin(y/16))
                    if y % 32 < 2: n -= 22
                elif kind == "stone":
                    if y % 32 < 2 or (x+(y//32%2)*32) % 64 < 2: n -= 28
                elif kind in ("iron", "brass"):
                    n += 6*math.sin(y/3) + 5*x/128
                elif kind == "cloth":
                    n += 4*((x+y)%2)
                elif kind == "map":
                    # Trazos geográficos ilustrativos, no cartografía de precisión.
                    islands = math.sin(x/11+math.sin(y/13))*math.cos(y/17) + 0.3*math.sin(x/4+y/12)
                    if islands > 0.2: n -= 39
                    if x%16 == 0 or y%16 == 0: n -= 12
                pixels.append(tuple(max(0, min(255, round(c+n))) for c in color))
        image.putdata(pixels)
        image.save(directory/f"ca_station_{kind}.png")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime-root", type=Path, default=Path(__file__).resolve().parents[2]/"src")
    args = parser.parse_args()
    root = args.runtime_root.resolve()
    output = root/DIRECTORY
    output.mkdir(parents=True, exist_ok=True)
    write_textures(output)
    records, definitions = [], []
    for name, actor, sprite, label in STATIONS:
        mesh = make_station(name)
        filename = f"ca_station_{name}.obj"
        mesh.write(output/filename)
        records.append({"name":name, "actor":actor, "sprite":sprite+"A0",
                        "triangles":sum(len(face)-2 for _,face in mesh.faces),
                        "height":round(max(y for _,y,_ in mesh.vertices), 3)})
        classes = [actor] + (["CaelumBowWorkshopStation"] if name=="ranged" else [])
        for classname in classes:
            definitions.append(f'Model {classname}\n{{\n    Path "{DIRECTORY}"\n'
                               f'    Model 0 "{filename}"\n    Scale 2.0 2.0 2.0\n'
                               f'    CorrectPixelStretch\n    DontCullBackFaces\n'
                               f'    FrameIndex {sprite} A 0 0\n}}\n')
    begin, end = "// --- BEGIN GENERATED CAELUM STATION MODELS ---", "// --- END GENERATED CAELUM STATION MODELS ---"
    modeldef = root/"MODELDEF"
    text = modeldef.read_text(encoding="utf-8")
    section = begin+"\n// Doce estaciones sencillas; fuentes y sprites de referencia en assets.\n"+"\n".join(definitions)+end
    if begin in text:
        first, tail = text.split(begin, 1)
        _, last = tail.split(end, 1)
        text = first+section+last
    else:
        text = text.rstrip()+"\n\n"+section+"\n"
    modeldef.write_text(text, encoding="utf-8")
    print(json.dumps(records, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
