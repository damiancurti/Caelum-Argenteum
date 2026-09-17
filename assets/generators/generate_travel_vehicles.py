#!/usr/bin/env python3
"""Carreta, mercante, rancho y muelle originales; materiales existentes."""
from pathlib import Path
import math
import sys
sys.dont_write_bytecode = True
from generate_station_models import Mesh, material
from generate_stash_models import WOOD

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'src/models/caelum/vehicles'


def cart():
    m = Mesh('CaelumCoveredTradeCart')
    # MU: 32 por metro. Caja 3,6 x 1,7 m; cubierta a 3 m del suelo.
    for x in (-22, 22):
        m.box('wood', (x, 33, 0), (5, 8, 116))
    for z in range(-54, 58, 8):
        m.box('wood', (0, 38, z), (55, 4, 7.5))
    for x in (-29, 29):
        for y in (44, 52, 60):
            m.box('wood', (x, y, 0), (3, 7.5, 116))
        for z in (-54, -18, 18, 54):
            m.box('iron', (x*1.04, 52, z), (1, 25, 2))
    m.box('wood', (0, 48, -56), (56, 20, 3))
    m.box('wood', (0, 53, 42), (54, 4, 17))
    m.rod('iron', (-40, 29, -12), (40, 29, -12), 3)
    for x in (-38, 38):
        m.ring('wood', (x, 29, -12), 27, 2.2, 'yz', 24)
        m.ring('iron', (x, 29, -12), 28.2, 0.8, 'yz', 24)
        m.rod('wood', (x-3, 29, -12), (x+3, 29, -12), 5)
        for i in range(12):
            a = math.tau*i/12
            m.rod('wood', (x,29,-12), (x,29+26*math.cos(a),-12+26*math.sin(a)), 1.2, sides=4)
    m.box('wood', (0, 32, 85), (5, 5, 78))
    m.rod('wood', (-28,32,119), (28,32,119), 2.4, sides=8)
    # Lona arqueada, costuras, aros de soporte y sogas en ambos laterales.
    for i in range(16):
        a, b = math.pi*i/16, math.pi*(i+1)/16
        p, q = (29*math.cos(a),64+32*math.sin(a)), (29*math.cos(b),64+32*math.sin(b))
        m.add_quad(material('paper'), [(p[0],p[1],-58),(q[0],q[1],-58),(q[0],q[1],58),(p[0],p[1],58)])
        for z in (-58, -29, 0, 29, 58):
            m.rod('wood', (p[0],p[1]-0.5,z), (q[0],q[1]-0.5,z), 0.6, sides=4)
    for x in (-29,29):
        for z in (-52,-26,0,26,52):
            m.rod('leather', (x,64,z), (x,52,z+3), 0.4, sides=4)
    for x,z in ((-12,-34),(13,-26),(-10,-3)):
        m.box('wood',(x,49,z),(20,18,23))
        for dz in (-8,8):m.box('iron',(x,58.2,z+dz),(20.4,0.6,1.2))
    return m


def ship():
    m = Mesh('CaelumCoastalMerchant')
    # Eslora 12 m, manga 3,5 m; casco de quilla a borda 2 m.
    stations = [(-192,4),(-168,29),(-128,45),(-64,54),(0,56),(64,53),(128,40),(168,22),(192,0.5)]
    for (z,w),(nz,nw) in zip(stations,stations[1:]):
        for side in (-1,1):
            for row in range(8):
                t,nt=row/8,(row+1)/8
                y,ny=-32+64*t,-32+64*nt
                width=lambda value,tier:side*value*(0.13+0.87*math.sin(tier*math.pi/2))
                m.add_quad(material('wood'),[(width(w,t),y,z),(width(nw,t),y,nz),(width(nw,nt),ny,nz),(width(w,nt),ny,z)])
                m.rod('leather',(width(w,nt),ny+0.1,z),(width(nw,nt),ny+0.1,nz),0.28,sides=4)
            m.rod('wood',(side*w,33,z),(side*nw,33,nz),2.0)
        # Cubierta entablonada en cada tramo; no una caja rectangular sobre agua.
        for i in range(10):
            a,b=-1+2*i/10,-1+2*(i+1)/10-0.009
            m.add_quad(material('wood'),[(w*a,30,z),(w*b,30,z),(nw*b,30,nz),(nw*a,30,nz)])
    m.box('wood',(0,32,-202),(3,24,25))  # timón
    m.rod('wood',(0,46,-209),(0,48,-160),1.3)
    m.rod('wood',(0,-28,-185),(0,-28,188),3)
    m.rod('wood',(0,30,35),(0,288,35),3.3,1.4,12)
    m.rod('wood',(0,70,25),(0,244,-121),1.4,1,8)
    m.rod('wood',(0,68,28),(0,65,-138),1.8,1,8)
    # Vela cangreja y foque; curvatura discreta entre paños.
    def sail(corners):
        a,b,c,d=corners
        for i in range(12):
            t,nt=i/12,(i+1)/12
            def p(u,v):
                top=tuple(a[j]*(1-u)+b[j]*u for j in range(3))
                bottom=tuple(d[j]*(1-u)+c[j]*u for j in range(3))
                q=tuple(top[j]*(1-v)+bottom[j]*v for j in range(3))
                return (q[0]+10*math.sin(math.pi*u)*math.sin(math.pi*v),q[1],q[2])
            for k in range(6):
                v,nv=k/6,(k+1)/6
                m.add_quad(material('paper'),[p(t,v),p(nt,v),p(nt,nv),p(t,nv)])
            m.rod('leather',p(t,0),p(t,1),0.16,sides=4)
    sail(((0,267,32),(0,243,-117),(0,69,-136),(0,72,31)))
    m.add_triangle(material('paper'),[(1,276,39),(1,56,185),(1,69,43)])
    for x,z in ((-51,-50),(51,-50),(-47,105),(47,105),(0,-176),(0,190)):
        m.rod('leather',(x,33,z),(0,272,35),0.42,sides=4)
    # Escotilla de bodega, toldilla, bultos y cuatro remos largos amarrados.
    m.box('iron',(0,32,-48),(49,4,58))
    m.box('wood',(0,35,-48),(44,4,54))
    for x in (-18,18):m.box('iron',(x,37.2,-48),(2,0.8,54))
    m.box('wood',(0,44,-132),(47,25,40))
    m.box('cloth',(0,58,-132),(51,2,44))
    for side in (-1,1):
        for i in range(2):
            x=side*(43+4*i)
            m.rod('wood',(x,38,-58),(x,39,102),0.8)
            m.box('wood',(x,39,109),(5,1.5,26))
        for z in (-84,84):
            m.box('wood',(side*28,40,z),(22,18,26))
            m.box('iron',(side*28,49.1,z),(22.3,0.6,2))
    # Cartel de embarque sobre el muelle: su volumen Usar queda a la altura
    # de la mirada, sin obligar a apuntar al casco junto al agua.
    m.box('wood',(72,61,0),(5,74,5))
    m.box('wood',(72,90,0),(4,20,24))
    m.add_triangle(material('paper'),[(74.2,96,0),(74.2,82,0),(74.2,82,8)])
    m.rod('iron',(74.2,80,0),(74.2,99,0),0.5,sides=4)
    return m


def ranch():
    m=Mesh('CaelumRoadsideRanch')
    for x in (-92,92):
        for z in (-124,0,124):
            m.box('wood',(x,64,z),(7,128,7))
    for z in range(-120,125,12):
        for x in (-94,94):m.box('wood',(x,52,z),(3,100,11.5))
    for x in range(-84,85,12):m.box('wood',(x,52,-126),(11.5,100,3))
    for x in (-94,94):m.box('wood',(x,119,0),(7,9,256))
    for z in range(-136,137,16):
        for side in (-1,1):
            m.add_quad(material('wood'),[(0,152,z),(side*105,123,z),(side*105,123,z+15.5),(0,152,z+15.5)])
    m.rod('wood',(0,152,-136),(0,152,152),2)
    # Cartel: una rueda tallada identifica la parada sin usar un menú adicional.
    m.box('wood',(0,111,130),(48,23,3))
    m.ring('iron',(0,111,132),8,1,'xy',16)
    for a in range(0,360,45):
        m.rod('iron',(0,111,132),(7*math.cos(math.radians(a)),111+7*math.sin(math.radians(a)),132),0.6,sides=4)
    return m


def dock():
    m=Mesh('CaelumBeachDock')
    # 18 x 4 m, tope en Z=0 del juego. Pilotes hasta el fondo a -128 MU.
    for z in range(-280,289,8):m.box('wood',(0,-2,z),(128,4,7.7))
    for x in (-46,46):
        m.box('wood',(x,-10,0),(8,12,576))
        for z in range(-256,257,128):
            m.rod('wood',(x,-128,z),(x,16,z),4,3,8)
    # Bitas y sogas laterales; extremo del muelle abierto para embarcar.
    for side in (-1,1):
        m.rod('leather',(side*46,15,-256),(side*46,15,128),0.6,sides=4)
    return m


def main():
    DEST.mkdir(parents=True,exist_ok=True)
    models=[('covered_cart','CaelumCoveredCart',cart()),('merchant_ship','CaelumMerchantShip',ship()),
            ('ranch','CaelumVehicleRanch',ranch()),('dock','CaelumVehicleDock',dock())]
    entries=[]
    for name,actor,mesh in models:
        # CorrectPixelStretch divide por 1,2 en estos mapas. La altura física
        # vuelve a coincidir con metros y colisiones, sin agrandar la planta.
        mesh.vertices=[(x,y*1.2,z) for x,y,z in mesh.vertices]
        # OBJ del motor requiere pocas superficies: agrupar cada material una
        # sola vez evita cientos de cambios de superficie y skins incorrectas.
        mesh.faces=[(WOOD if kind==material('wood') else kind,face) for kind,face in mesh.faces]
        mesh.faces.sort(key=lambda entry:entry[0])
        mesh.write(DEST/f'ca_{name}.obj')
        entries.append(f'Model {actor}\n{{\n    Path "models/caelum/vehicles"\n    Model 0 "ca_{name}.obj"\n'
                       '    Scale 1.0 1.0 1.0\n    AngleOffset 90\n    CorrectPixelStretch\n'
                       '    DontCullBackFaces\n    FrameIndex CAHC A 0 0\n}\n')
        print(name,len(mesh.vertices),'vertices',len(mesh.faces),'faces')
    modeldef=ROOT/'src/MODELDEF'
    begin='// BEGIN CAELUM TRAVEL VEHICLES\n';end='// END CAELUM TRAVEL VEHICLES\n'
    text=modeldef.read_text(encoding='utf-8')
    if begin in text:text=text[:text.index(begin)]+text[text.index(end)+len(end):]
    modeldef.write_text(text.rstrip()+'\n\n'+begin+'\n'.join(entries)+end,encoding='utf-8')

if __name__=='__main__':main()
