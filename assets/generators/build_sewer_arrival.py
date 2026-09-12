#!/usr/bin/env python3
"""Genera únicamente la llegada narrativa de MAP02, con recursos existentes."""
from pathlib import Path
import argparse
import struct


def build(root):
    vertices=[]; vertex_ids={}; sectors=[]; sides=[]; lines=[]; edges={}
    def vertex(x,y):
        key=(x,y)
        if key not in vertex_ids:
            vertex_ids[key]=len(vertices);vertices.append({'x':float(x),'y':float(y)})
        return vertex_ids[key]
    def cell(x1,y1,x2,y2, floor,ceiling,light,water=False):
        sector=len(sectors)
        sectors.append({'heightfloor':floor,'heightceiling':ceiling,'texturefloor':'CAPOOL01' if water else 'CASWRFLR',
            'textureceiling':'CASWRFLR','lightlevel':light,'lightcolor':0x8E9366 if water else 0xD6C5AB})
        # Perímetro horario: el lado frontal mira al interior de cada celda.
        points=[(x1,y1),(x1,y2),(x2,y2),(x2,y1)]
        for a,b in zip(points,points[1:]+points[:1]):
            a=vertex(*a);b=vertex(*b);side=len(sides)
            sides.append({'sector':sector,'texturetop':'CASWRWAL','texturebottom':'CASWRWAL','texturemiddle':'-'})
            opposite=(b,a)
            if opposite in edges:
                line=lines[edges[opposite]];line['sideback']=side;line['twosided']=True;line['blocking']=False
                sides[line['sidefront']]['texturemiddle']='-'
            else:
                sides[side]['texturemiddle']='CASWRWAL'
                edges[(a,b)]=len(lines);lines.append({'v1':a,'v2':b,'sidefront':side,'blocking':True,'dontpegbottom':True})
    xs=[-384,-288,-192,-96,96,192,288,384]
    ys=[-128,0,176,192,368,384,560,576,752,768,944,960,1152]
    for ix,(x1,x2) in enumerate(zip(xs,xs[1:])):
        for iy,(y1,y2) in enumerate(zip(ys,ys[1:])):
            central=x1==-96
            bridge=y1 in (-128,368,944)
            ceiling=208 if ix in (0,6) else 240 if ix in (1,5) else 264 if ix in (2,4) else 280
            rib=y2-y1==16
            light=216 if y1<176 else 192 if y1<560 else 176
            if rib:ceiling-=12;light-=20
            cell(x1,y1,x2,y2, -12 if central and not bridge else 0,ceiling,light,central and not bridge)
    # Reja final sólo visual: el recorrido posterior aún no tiene contenido.
    for line in lines:
        if 'sideback' not in line:
            a=vertices[line['v1']];b=vertices[line['v2']]
            if a['y']==b['y']==1152 and min(a['x'],b['x'])==-96:
                sides[line['sidefront']]['texturemiddle']='CMGT02'
    things=[{'x':-236.0,'y':32.0,'height':0.0,'angle':90,'type':1,'skill1':True,'skill2':True,'skill3':True,
        'skill4':True,'skill5':True,'single':True,'coop':True,'dm':False}]
    def value(v):
        if isinstance(v,bool):return 'true' if v else 'false'
        if isinstance(v,str):return '"'+v+'"'
        return str(v)
    text='namespace = "ZDoom";\n// 4.33.0v: llegada jugable; recorrido completo pendiente.\n\n'
    for kind,items in [('vertex',vertices),('sector',sectors),('sidedef',sides),('linedef',lines),('thing',things)]:
        for i,item in enumerate(items):
            text+=f'// {kind} {i}\n{kind}\n{{\n'+''.join(f'    {k} = {value(v)};\n' for k,v in item.items())+'}\n\n'
    payload=text.encode();lumps=[('MAP02',b''),('TEXTMAP',payload),('ENDMAP',b'')]
    data=bytearray(b'PWAD'+struct.pack('<II',len(lumps),12+len(payload)));directory=bytearray();off=12
    for name,blob in lumps:
        directory+=struct.pack('<II8s',off,len(blob),name.encode().ljust(8,b'\0'));data+=blob;off+=len(blob)
    data+=directory
    path=root/'src/maps/MAP02.wad';path.write_bytes(data)
    print(f'{path.name}: {len(sectors)} sectores, {len(lines)} líneas, llegada sin actores de diagnóstico.')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('root',nargs='?',type=Path,default=Path(__file__).resolve().parents[2])
    build(parser.parse_args().root)
