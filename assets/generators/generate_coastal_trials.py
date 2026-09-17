#!/usr/bin/env python3
"""Genera MAP06/07: puerto y costa ribereña de Buenos Aires, sin tocar MAP01–05.

Geometría UDMF propia; recursos entregados por el autor. Techos y agua usan
volúmenes nativos. Las áreas son de ensayo, no reconstrucciones históricas.
"""
from pathlib import Path
import argparse
import struct


class CoastalMap:
    CELL = 64

    def __init__(self, name):
        self.name, self.cells, self.volumes = name, {}, {}
        self.things = []

    def room(self, x1, y1, x2, y2, floor=0, flat='CMST02', wall='CVPO03', light=208, volume=0):
        assert all(v % self.CELL == 0 for v in (x1, y1, x2, y2))
        for x in range(x1, x2, self.CELL):
            for y in range(y1, y2, self.CELL):
                self.cells[x, y] = (floor, flat, wall, light, volume)

    def volume(self, tag, bottom, top, flat, wall, water=False):
        self.volumes[tag] = (bottom, top, flat, wall, water)

    def prop(self, kind, x, y, angle=0):
        self.things.append(dict(type=kind, x=x, y=y, angle=angle, skill1=True, skill2=True,
                               skill3=True, skill4=True, skill5=True, single=True, coop=True))

    def building(self, x1, y1, x2, y2, door_y, tag, plaster, flat):
        # Muros con volumen físico y cubierta de 24 MU; puerta oriental de 128 MU.
        self.volume(tag, 160, 184, 'CMTB04', 'CVCI04')
        self.room(x1, y1, x2, y2, floor=184, flat='CMTB04', wall=plaster)
        self.room(x1+64, y1+64, x2-64, y2-64, flat=flat, wall=plaster, light=168, volume=tag)
        self.room(x2-64, door_y, x2, door_y+128, flat=flat, wall=plaster, light=184, volume=tag)

    def write(self, folder):
        vertices, vertex_ids, sides, lines, sectors, sector_ids, edges = [], {}, [], [], [], {}, {}

        def vertex(point):
            if point not in vertex_ids:
                vertex_ids[point] = len(vertices)
                vertices.append(dict(x=point[0], y=point[1]))
            return vertex_ids[point]

        def polygon(x, y, size, sector, wall, horizon=False, control=None):
            corners = [(x,y), (x,y+size), (x+size,y+size), (x+size,y)]
            for a,b in zip(corners,corners[1:]+corners[:1]):
                side = len(sides)
                sides.append(dict(sector=sector, texturetop=wall, texturebottom=wall, texturemiddle=wall))
                key = tuple(sorted((a,b)))
                if key in edges:
                    line = lines[edges[key]]
                    front = sides[line['sidefront']]
                    front_floor = sectors[front['sector']]['heightfloor']
                    back_floor = sectors[sector]['heightfloor']
                    # La cara visible del escalón pertenece al volumen alto.
                    if back_floor > front_floor:
                        front['texturebottom'] = wall
                    elif front_floor > back_floor:
                        sides[side]['texturebottom'] = front['texturemiddle']
                    line['sideback'], line['twosided'] = side, True
                    line.pop('blocking',None)
                    line.pop('special',None)
                    sides[line['sidefront']]['texturemiddle'] = '-'
                    sides[side]['texturemiddle'] = '-'
                else:
                    line = dict(v1=vertex(a),v2=vertex(b),sidefront=side,blocking=True)
                    if horizon: line['special'] = 9  # Line_Horizon, borde lejano del agua.
                    if control and a == corners[0]:
                        tag,water = control
                        line.update(special=160,arg0=tag,arg1=2 if water else 1,arg2=0,arg3=192 if water else 255,arg4=0)
                    edges[key]=len(lines)
                    lines.append(line)

        for (x,y), cell in sorted(self.cells.items()):
            floor, flat, wall, light, tag = cell
            if cell not in sector_ids:
                sector_ids[cell]=len(sectors)
                sectors.append(dict(heightfloor=floor,heightceiling=1024,texturefloor=flat,
                    textureceiling='F_SKY1',lightlevel=light,id=tag))
            polygon(x,y,self.CELL,sector_ids[cell],wall,horizon=True)
        # Sectores de control separados; nunca accesibles ni compartidos con el mapa.
        for i,(tag,(bottom,top,flat,wall,water)) in enumerate(sorted(self.volumes.items())):
            sector=len(sectors)
            sectors.append(dict(heightfloor=bottom,heightceiling=top,texturefloor=flat,
                textureceiling=flat,lightlevel=176 if water else 176))
            polygon(-4096+i*128,-4096,64,sector,wall,control=(tag,water))

        self.prop(1,0,320,90)
        self.prop(30950,0,352)  # Marcador regional explícito, Buenos Aires, superficie.
        self.things[-1].update(arg0=1,arg1=0)
        def value(v):
            if isinstance(v,bool): return str(v).lower()
            if isinstance(v,str): return '"'+v+'"'
            return str(v)
        chunks=['namespace = "ZDoom";\n// Caelum 4.35.0m: entorno de ensayo ribereño.\n']
        for kind,entries in [('vertex',vertices),('sector',sectors),('sidedef',sides),('linedef',lines),('thing',self.things)]:
            for entry in entries:
                chunks.append(kind+'\n{\n'+''.join('    '+k+' = '+value(v)+';\n' for k,v in entry.items())+'}\n')
        lumps=[(self.name,b''),('TEXTMAP','\n'.join(chunks).encode()),('ENDMAP',b'')]
        body,directory=bytearray(),bytearray()
        for name,data in lumps:
            directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode().ljust(8,b'\0'))
            body+=data
        (folder/(self.name+'.wad')).write_bytes(struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory)
        print(f'{self.name}: {len(sectors)} sectores, {len(lines)} líneas, {len(self.things)} actores')


def generate(folder):
    folder.mkdir(parents=True,exist_ok=True)
    port=CoastalMap('MAP06')
    port.volume(100,-128,-24,'CVPL06','CVPL06',water=True)
    port.room(-1280,-128,896,2304)
    port.room(896,-128,2304,2304,floor=-128,flat='CVPL02',volume=100)
    # Franja lejana al nivel del río: el horizonte prolonga la superficie,
    # no el fondo de arena del volumen sumergible.
    port.room(2240,-128,2304,2304,floor=-24,flat='CVPL06')
    port.room(896,-128,2240,-64,floor=-24,flat='CVPL06')
    port.room(896,2240,2240,2304,floor=-24,flat='CVPL06')
    port.room(-1280,-128,-1216,2304,floor=112,flat='CMST01')
    port.room(-1216,-128,896,-64,floor=112,flat='CMST01')
    port.room(-1216,2240,896,2304,floor=112,flat='CMST01')
    # Dique y paseo; dos muelles secos prolongan la explanada sobre el agua.
    port.room(384,-128,896,2304,flat='CMST01')
    port.room(896,448,2048,704,flat='CVPO01',wall='CVPO06')
    port.room(896,1536,1792,1728,flat='CVPO02',wall='CVPO06')
    port.building(-1216,384,-448,1152,704,201,'CVCI01','CVPO01')
    port.building(-1088,1280,-512,1984,1536,202,'CVCI02','CVCI03')
    # Alero abierto: lluvia excluida, ventilación lateral conservada.
    port.volume(203,160,184,'CVPO06','CVPO06')
    port.room(-128,1280,256,1664,flat='CVPO01',volume=203)
    for x in (-128,192):
        for y in (1280,1600): port.room(x,y,x+64,y+64,floor=160,flat='CVPO06',wall='CVPO06',volume=203)
    # Carga con volumen; la arpillera nunca se usa como un sprite de saco ficticio.
    for x,y,h,mat in [(512,832,48,'CVPO05'),(576,832,64,'CVPO05'),(640,960,64,'CVPO04'),(-1088,512,64,'CVPO06'),(-1024,512,96,'CVPO05')]:
        tag=201 if x<0 else 0
        port.room(x,y,x+64,y+64,floor=h,flat=mat,wall=mat,light=168 if tag else 208,volume=tag)
    port.room(-960,1344,-896,1408,floor=48,flat='CVCI06',wall='CVCI06',volume=202)
    port.prop(18063,-1056,192)
    port.write(folder)

    coast=CoastalMap('MAP07')
    coast.volume(100,-128,-24,'CVPL06','CVPL06',water=True)
    coast.room(-896,-128,320,2304,flat='CMGR02')
    coast.room(-128,-128,192,2304,flat='CMGR03')
    coast.room(320,-128,704,2304,floor=-8,flat='CVPL01',wall='CVPL05')
    coast.room(704,-128,896,2304,floor=-20,flat='CVPL02',wall='CVPL05')
    coast.room(896,-128,2304,2304,floor=-128,flat='CVPL02',wall='CVPL05',volume=100)
    coast.room(2240,-128,2304,2304,floor=-24,flat='CVPL06')
    coast.room(896,-128,2240,-64,floor=-24,flat='CVPL06')
    coast.room(896,2240,2240,2304,floor=-24,flat='CVPL06')
    coast.room(-896,-128,-832,2304,floor=64,flat='CMGR02',wall='CVPL05')
    for y in (128,640,1728):
        coast.room(448,y,640,y+192,floor=-8,flat='CVPL03',wall='CVPL05')
    coast.room(320,1920,512,2176,floor=-8,flat='CVPL04',wall='CVPL05')
    # Descenso seguro a la orilla y salida del agua por peldaños de 16 MU.
    for step in range(1,7):
        coast.room(896+(step-1)*64,320,960+(step-1)*64,576,floor=-20-step*16,
                   flat='CVPL02',wall='CVPL05',volume=100)
    coast.volume(201,160,184,'CVPO06','CVPO06')
    coast.room(-576,1024,64,1536,flat='CVPO01',volume=201)
    for x in (-576,0):
        for y in (1024,1472):coast.room(x,y,x+64,y+64,floor=160,flat='CVPO06',wall='CVPO06',volume=201)
    coast.prop(18066,-704,704)
    coast.prop(18065,-704,1792)
    coast.prop(18067,-480,2048)
    coast.write(folder)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,default=Path(__file__).resolve().parents[2]/'src/maps')
    generate(parser.parse_args().output)
