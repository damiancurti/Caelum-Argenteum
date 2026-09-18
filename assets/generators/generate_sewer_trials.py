#!/usr/bin/env python3
"""Genera MAP03–05 y MAP08 como UDMF nativo; no reescribe MAP01 ni MAP02.

Módulos sobre una cuadrícula: galería, depósito, cámara y escalera. Sólo usa
texturas propias ya incluidas. No coloca población masiva ni concede Tarot.
Ejecutar desde cualquier directorio; --output permite comparar otra salida.
"""
from pathlib import Path
import argparse
import struct


class SewerMap:
    def __init__(self, name, cell=128):
        self.name, self.cell = name, cell
        self.cells = {}
        self.things = []

    def room(self, x1, y1, x2, y2, floor=0, ceiling=256, water=False):
        assert all(v % self.cell == 0 for v in (x1, y1, x2, y2))
        for x in range(x1, x2, self.cell):
            for y in range(y1, y2, self.cell):
                self.cells[x, y] = (floor, ceiling, water)

    def write(self, folder):
        vertices, vertex_ids, sides, lines, edges, sectors = [], {}, [], [], {}, []

        def vertex(point):
            if point not in vertex_ids:
                vertex_ids[point] = len(vertices)
                vertices.append(dict(x=point[0], y=point[1]))
            return vertex_ids[point]

        for (x, y), (floor, ceiling, water) in sorted(self.cells.items()):
            index = len(sectors)
            # Franjas de bóveda y luz cálida; los pasos secos quedan legibles.
            arch = (y // self.cell) % 4 == 0
            sectors.append(dict(heightfloor=floor, heightceiling=ceiling-(12 if arch else 0),
                texturefloor='CAPOOL01' if water else 'CASWRFLR', textureceiling='CASWRWAL',
                lightlevel=184 if arch else 208, lightcolor=0xABC5BD if water else 0xDED3B5))
            corners = [(x, y), (x, y+self.cell), (x+self.cell, y+self.cell), (x+self.cell, y)]
            for a, b in zip(corners, corners[1:]+corners[:1]):
                side = len(sides)
                sides.append(dict(sector=index, texturetop='CASWRWAL', texturebottom='CASWRWAL', texturemiddle='CASWRWAL'))
                key = tuple(sorted((a, b)))
                if key in edges:
                    line = lines[edges[key]]
                    line['sideback'], line['twosided'] = side, True
                    line.pop('blocking')
                    sides[line['sidefront']]['texturemiddle'] = '-'
                    sides[side]['texturemiddle'] = '-'
                else:
                    edges[key] = len(lines)
                    lines.append(dict(v1=vertex(a), v2=vertex(b), sidefront=side, blocking=True))

        def value(v):
            if isinstance(v, bool): return str(v).lower()
            if isinstance(v, str): return '"'+v+'"'
            return str(v)

        chunks = ['namespace = "ZDoom";\n// 4.34.0c: alcantarilla modular de pruebas, sin encuentros automáticos.\n']
        thing = dict(x=0, y=320, angle=90, type=1, skill1=True, skill2=True, skill3=True, skill4=True, skill5=True, single=True, coop=True)
        for kind, entries in [('vertex', vertices), ('sector', sectors), ('sidedef', sides), ('linedef', lines), ('thing', [thing] + self.things)]:
            for entry in entries:
                chunks.append(kind+'\n{\n'+''.join('    '+key+' = '+value(v)+';\n' for key, v in entry.items())+'}\n')
        lumps = [(self.name, b''), ('TEXTMAP', '\n'.join(chunks).encode('utf-8')), ('ENDMAP', b'')]
        body, directory = bytearray(), bytearray()
        for name, data in lumps:
            directory += struct.pack('<ii8s', 12+len(body), len(data), name.encode().ljust(8,b'\0'))
            body += data
        result = struct.pack('<4sii', b'PWAD', len(lumps), 12+len(body))+body+directory
        (folder/(self.name+'.wad')).write_bytes(result)
        print(f'{self.name}: {len(sectors)} sectores, {len(lines)} líneas, {len(result)} bytes')


def generate(folder):
    folder.mkdir(parents=True, exist_ok=True)
    reservoir = SewerMap('MAP03')
    reservoir.room(-256, 0, 256, 512)
    reservoir.room(-2048, 512, 2048, 3584, ceiling=512)
    # Dos canales laterales con cruces secos y un depósito central despejado.
    for x1 in (-1792, 1536):
        reservoir.room(x1, 768, x1+256, 3328, floor=-12, ceiling=512, water=True)
        reservoir.room(x1, 1920, x1+256, 2176, ceiling=512)
    # Pilares de mampostería, fuera de la superficie central de pruebas.
    for x in (-1920, 1792):
        for y in (1024, 1792, 2560, 3200):
            reservoir.cells.pop((x, y))
    reservoir.write(folder)

    tarot = SewerMap('MAP04')
    tarot.room(-256, 0, 256, 512)
    tarot.room(-512, 512, 512, 1536, ceiling=384)
    tarot.room(-1280, 896, 1280, 1152, ceiling=256)
    tarot.room(-1536, 640, -768, 1408, ceiling=288)
    tarot.room(768, 640, 1536, 1408, ceiling=288)
    tarot.room(-256, 1536, 256, 1792)
    tarot.room(-512, 1792, 512, 2560, ceiling=320)
    # Canales cortos laterales; el eje de entrada y las cámaras son secos.
    tarot.room(-512, 640, -384, 1408, floor=-12, ceiling=384, water=True)
    tarot.room(384, 640, 512, 1408, floor=-12, ceiling=384, water=True)
    tarot.room(-512, 896, 512, 1152, ceiling=384)
    tarot.write(folder)

    maintenance = SewerMap('MAP05', cell=64)
    maintenance.room(-256, 0, 256, 512)
    maintenance.room(-768, 512, 768, 1024, ceiling=320)
    # Dos escaleras paralelas de ocho peldaños: 12 MU de alto, 64 de huella.
    # Se puede subir caminando; no se requiere salto ni ascensor simulado.
    for step in range(8):
        for x1 in (-768, 512):
            maintenance.room(x1, 1024+step*64, x1+256, 1088+step*64,
                floor=(step+1)*12, ceiling=416)
    maintenance.room(-768, 1536, 768, 2048, floor=96, ceiling=416)
    maintenance.room(-256, 768, 256, 1024, floor=-12, ceiling=320, water=True)
    maintenance.write(folder)
    # Un mapa nuevo conserva el checksum de MAP05 y sus partidas guardadas.
    maintenance.name = 'MAP08'
    # 4.36.0a: galería oriental de ensayos en un anexo independiente.
    # El foso tiene geometría permanente; un puente-actor retira solamente la tapa.
    maintenance.room(768, 640, 1024, 896, ceiling=320)
    maintenance.room(1024, 512, 2432, 1792, ceiling=384)
    maintenance.room(1280, 768, 1536, 1024, floor=-192, ceiling=384)
    # Salida física de 12 peldaños; no teletransporta ni repone recursos.
    for step in range(12):
        maintenance.room(1536+step*64, 832, 1600+step*64, 960,
                         floor=-192+(step+1)*16, ceiling=384)
    def hazard(kind, x, y, height=0, angle=0, tid=0, argument=0):
        return dict(x=x, y=y, height=height, angle=angle, type=kind, id=tid,
                    arg0=argument, skill1=True, skill2=True, skill3=True,
                    skill4=True, skill5=True, single=True, coop=True)
    maintenance.things.extend([
        hazard(30960, 1408, 896, height=184, tid=43601),
        hazard(30961, 1280, 1344, tid=43602, argument=32),
        hazard(30962, 1152, 1344, argument=43602),
        hazard(30961, 2048, 1600, height=256, tid=43603),
        hazard(30962, 2048, 1536, angle=90, argument=43603),
    ])
    maintenance.write(folder)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parents[2]/'src/maps')
    generate(parser.parse_args().output)
