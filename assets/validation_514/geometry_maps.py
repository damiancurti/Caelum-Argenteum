"""Pure deterministic map constructors copied from validation_510/prepare.py (#130).
No runtime assets, IWADs or generated test packages are distributed.
"""
import math
import struct

text='namespace="ZDoom";\nsector { heightfloor=0; heightceiling=512; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; }\n'
for i,(x,y) in enumerate([(-2048,-2048),(-2048,2048),(2048,2048),(2048,-2048)]):
    text+=f'vertex {{ x={x}; y={y}; }}\nsidedef {{ sector=0; texturemiddle="CMST01"; }}\nlinedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}\n'
text+='thing { x=0; y=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }\n'
body=bytearray();directory=bytearray()
for key,data in [('QA130A',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')]:
    directory+=struct.pack('<ii8s',12+len(body),len(data),key.encode().ljust(8,b'\0'));body+=data
wad=struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory

geo=['namespace="ZDoom";','sector { heightfloor=0; heightceiling=512; texturefloor="CMGR03"; textureceiling="F_SKY1"; lightlevel=208; user_ca_water_temperature_defined=1; user_ca_water_temperature_c=7.0; }']
vertex=side=0
def polygon(points,front,back=None):
    global vertex,side
    first=vertex
    for x,y in points:
        geo.append(f'vertex {{ x={x:.6f}; y={y:.6f}; }}');vertex+=1
    for i in range(len(points)):
        geo.append(f'sidedef {{ sector={front}; texturemiddle="CMST01"; texturetop="CMST01"; texturebottom="CMST01"; }}')
        sf=side;side+=1
        sb=''
        if back is not None:
            geo.append(f'sidedef {{ sector={back}; texturemiddle="-"; texturetop="CMST01"; texturebottom="CMST01"; }}')
            sb=f'sideback={side}; twosided=true;';side+=1
        geo.append(f'linedef {{ v1={first+i}; v2={first+(i+1)%len(points)}; sidefront={sf}; {sb} }}')
polygon([(-16000,-8000),(-16000,8000),(16000,8000),(16000,-8000)],0)
u=[(-128,-128),(-128,128),(128,128),(128,-128),(112,-128),(112,112),(-112,112),(-112,-128)]
ell=[(-128,-128),(-128,128),(128,128),(128,112),(-112,112),(-112,-128)]
for index,(cx,shape,rotation,scale,ceiling) in enumerate([
    (-8000,u,0,1,0),(-4000,ell,0,1,0),(0,u,math.pi/4,1,0),
    (5000,u,0,20,0),(11000,[(-128,-128),(-128,128),(128,128),(128,-128)],0,1,128)],1):
    geo.append(f'sector {{ heightfloor=0; heightceiling={ceiling}; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; }}')
    points=[(cx+scale*(x*math.cos(rotation)-y*math.sin(rotation)),scale*(x*math.sin(rotation)+y*math.cos(rotation))) for x,y in shape]
    polygon(points,index,None if ceiling else 0)
# Two vertically separated water temperatures, including water above dry feet.
geo.append('sector { heightfloor=0; heightceiling=512; texturefloor="CMGR03"; textureceiling="F_SKY1"; lightlevel=208; id=1302; }')
polygon([(13872,-128),(13872,128),(14128,128),(14128,-128)],6,0)
for index,(bottom,top,temperature) in enumerate([(32,96,7),(96,128,15)],7):
    geo.append(f'sector {{ heightfloor={bottom}; heightceiling={top}; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; user_ca_water_temperature_defined=1; user_ca_water_temperature_c={temperature}; }}')
    previous=len(geo);x=-15000+(index-7)*256
    polygon([(x,6000),(x,6128),(x+128,6128),(x+128,6000)],index)
    for line in range(previous,len(geo)):
        if geo[line].startswith('linedef'):
            geo[line]=geo[line].replace('}', 'special=160; arg0=1302; arg1=2; arg2=0; arg3=160; }')
            break
geo.append('thing { x=-14000; y=-4000; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }')
body=bytearray();directory=bytearray()
for key,data in [('QA130G',b''),('TEXTMAP','\n'.join(geo).encode()),('ENDMAP',b'')]:
    directory+=struct.pack('<ii8s',12+len(body),len(data),key.encode().ljust(8,b'\0'));body+=data
geo_wad=struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory
