"""Freeze a single-sector, simultaneous army benchmark and visual-only model addon."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil
import struct
import zipfile
from geometry_probe import pack_wad

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent

def package(path,members):
    with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as z:
        for name,raw in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),raw)

def create(directory,smoke=False,mandingas=None,soldiers=None):
    data=json.loads((HERE/'flat_army.json').read_text())
    if smoke:data.update(mandingas=60,soldiers=10,columns=10)
    if mandingas is not None:data['mandingas']=mandingas
    if soldiers is not None:data['soldiers']=soldiers
    assert data['mandingas']>=data['columns'] and data['soldiers']>=data['columns']
    work=ROOT/'build'/directory/'current';work.mkdir(parents=True,exist_ok=False)
    shutil.copyfile(ROOT/'build/caelum_argenteum_dev.pk3',work/'runtime.pk3')
    constants='class CA318FlatData : Object {\n'
    for name in ('mandingas','soldiers','columns','spacing','front_x','yaw','pitch'):
        constants+=f'const {name.upper()}={data[name]};\n'
    constants+='static vector3 Camera(){return ('+','.join(map(str,data['camera']))+');}\n'
    constants+='static vector3 Position(int side,int i){return ((side==0?-1:1)*(FRONT_X+(i/COLUMNS)*SPACING),(i%COLUMNS-(COLUMNS-1)/2.0)*SPACING,0);}\n}\n'
    extent=data['map_extent'];text='namespace="ZDoom";\n'
    for x,y in [(-extent,-extent),(-extent,extent),(extent,extent),(extent,-extent)]:
        text+=f'vertex {{x={x};y={y};}}\n'
    text+=f'sector {{heightfloor=0;heightceiling={data["ceiling"]};texturefloor="CMST02";textureceiling="F_SKY1";lightlevel=208;}}\n'
    for i in range(4):
        text+='sidedef {sector=0;texturemiddle="CMST01";}\n'
        text+=f'linedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}\n'
    text+=f'thing {{x={data["camera"][0]};y={data["camera"][1]};angle={data["yaw"]};type=1;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;}}\n'
    wad=pack_wad([('MAP98',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')])
    members={'maps/MAP98.wad':wad,'ZSCRIPT':b'version "4.14"\n#include "data.zs"\n#include "flat_army.zs"\n',
             'data.zs':constants.encode(),'flat_army.zs':(HERE/'flat_army.zs').read_bytes(),
             'MAPINFO':b'GameInfo { AddEventHandlers="CA318FlatArmy" }\nmap MAP98 "Flat army diagnostic" { next="MAP98" }\n',
             'CVARINFO':b'server int ca318_warmup=35;\nserver int ca318_window=175;\n'}
    package(work/'observer.pk3',members)
    # Map the native sprite states directly to authored Domingo poses. No extra
    # actor, per-tic model controller or altered gameplay state is introduced.
    mapping={
      'CaelumMandinga':{'MIID':[0,7],'MIRN':[22,25,28,31],'MIWK':[14,18],
        'MDBR':[48,52,56,60],'SLMD':[136],
        'MNDG':[64,65,66,34,41,64,72,76,80,84,92,100]},
      'CaelumPortDefender':{'DOID':[0],'DOWK':[14,18],
        'DOMI':[64,65,48,49,50,51,52,53,54,55,34,35,36,37,38,39,41,47,72,76,80,84,88,92,96,100]}}
    model='// Diagnostic visual substitution approved by the author.\n'
    for cls,sprites in mapping.items():
        model+=f'Model {cls}\n{{\nPath "models/caelum/domingo"\nModel 0 "domingo.md3"\nSkin 0 "domingo_skin.png"\nScale 1 1 1\nDontCullBackFaces\n'
        for sprite,frames in sprites.items():
            for i,frame in enumerate(frames):model+=f'FrameIndex {sprite} {chr(65+i)} 0 {frame}\n'
        model+='}\n'
    package(work/'domingo.pk3',{'MODELDEF':model.encode()})
    raw=(ROOT/'src/models/caelum/domingo/domingo.md3').read_bytes()
    header=struct.unpack_from('<4si64s9i',raw);surfaces=[];at=header[10]
    for _ in range(header[6]):
        h=struct.unpack_from('<4s64s10i',raw,at)
        surfaces.append({'name':h[1].split(b'\0')[0].decode(),'frames':h[3],'vertices':h[5],'triangles':h[6]})
        at+=h[11]
    manifest={'scope':data,'methods':[],'geometry':{'sectors':1,'lines':4,'vertices':4,'placed_things':1},
              'model_mapping':mapping,'model_sha256':hashlib.sha256(raw).hexdigest(),'model_bytes':len(raw),
              'model_surfaces':surfaces,'model_substitution':'Native MODELDEF only; actor code/states/scale/collision unchanged; sparse pose mapping follows existing sprite frame timing, not a final Mandinga model.'}
    (work/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (work/'domingo.modeldef').write_text(model)
    print(work)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True);p.add_argument('--smoke',action='store_true')
    p.add_argument('--mandingas',type=int);p.add_argument('--soldiers',type=int)
    a=p.parse_args();create(a.directory,a.smoke,a.mandingas,a.soldiers)
