"""Freeze current sources and an isolated paired-door fixture for native tests."""
from pathlib import Path
import argparse
import json
import zipfile
from geometry_probe import pack_wad
from geometry_verify import package

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent

def create(directory):
    work=ROOT/'build'/directory/'current';work.mkdir(parents=True,exist_ok=False)
    with zipfile.ZipFile(work/'runtime.pk3','w',zipfile.ZIP_STORED) as z:
        for p in sorted((ROOT/'src').rglob('*')):
            if p.is_file():z.writestr(zipfile.ZipInfo(p.relative_to(ROOT/'src').as_posix(),(2000,1,1,0,0,0)),p.read_bytes())
    g={k:[] for k in ('vertex','sector','sidedef','linedef','thing')}
    def sector():
        g['sector'].append(dict(heightfloor=0,heightceiling=256,texturefloor='CMST02',textureceiling='CMTB04',lightlevel=208))
        return len(g['sector'])-1
    def polygon(points,front,back=None,identity=0):
        vi=len(g['vertex']);g['vertex'] += [dict(x=x,y=y) for x,y in points]
        for i in range(4):
            si=len(g['sidedef']);g['sidedef'].append(dict(sector=front,texturemiddle='CAPODR' if identity else 'CMST01'))
            line=dict(v1=vi+i,v2=vi+(i+1)%4,sidefront=si)
            if back is not None:
                line.update(sideback=si+1,twosided=True,midtex3d=True,dontpegbottom=True,alpha=0.0,
                    id=30000+identity,playeruse=True,playeruseback=True,monsterpush=True,repeatspecial=True)
                g['sidedef'].append(dict(sector=back,texturemiddle='CAPODR'))
            else:line['blocking']=True
            if identity:line.update(special=1 if i==0 else 7,arg0=identity,arg2=63 if i==0 else 0)
            g['linedef'].append(line)
    def thing(kind,x,y,angle=0,**fields):
        g['thing'].append(dict(type=kind,x=x,y=y,angle=angle,skill1=True,skill2=True,skill3=True,skill4=True,skill5=True,single=True,coop=True,**fields))
    main,storage,inside=sector(),sector(),sector()
    polygon([(-512,-512),(-512,512),(2048,512),(2048,-512)],main)
    polygon([(2304,-512),(2304,512),(3584,512),(3584,-512)],storage)
    thing(1,0,-200,90)
    for pair in range(4):
        axis=pair%2
        for side in (-1,1):
            identity=pair*2+(1 if side==-1 else 2);x=2432+identity*128;y=0
            offsets=[(-32,-4),(-32,4),(32,4),(32,-4)]
            polygon([(x+(a if axis==0 else -b),y+(b if axis==0 else a)) for a,b in offsets],inside,storage,identity)
            thing(9300,x+(side*32 if axis==0 else 0),y+(side*32 if axis==1 else 0),identity)
            cx=pair*512+(side*32 if axis==0 else 0);cy=side*32 if axis==1 else 0
            thing(9301,cx+(side*32 if axis==0 else 0),cy+(side*32 if axis==1 else 0),identity)
            thing(18099,cx,cy,arg0=100+pair,arg1=side,arg2=axis,arg4=identity)
    def value(v):return str(v).lower() if isinstance(v,bool) else '"'+v+'"' if isinstance(v,str) else str(v)
    text='namespace="ZDoom";\n'+''.join(k+'\n{\n'+''.join(f'{n}={value(v)};\n' for n,v in row.items())+'}\n' for k,rows in g.items() for row in rows)
    wad=pack_wad([('MAP98',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')])
    package(work/'probe.pk3',{'maps/MAP98.wad':wad,'ZSCRIPT':b'version "4.14"\n#include "native_doors_checks.zs"\n',
        'native_doors_checks.zs':(HERE/'native_doors_checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA318NativeDoorChecks" }\nmap MAP98 "Native paired doors" { next="MAP98" }\n'})
    package(work/'map-checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "native_doors_checks.zs"\n#include "native_map_checks.zs"\n#include "geometry_saves.zs"\n',
        'native_doors_checks.zs':(HERE/'native_doors_checks.zs').read_bytes(),
        'native_map_checks.zs':(HERE/'native_map_checks.zs').read_bytes(),
        'geometry_saves.zs':(HERE/'geometry_saves.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA318NativeMapChecks", "CA318GeometrySaveProbe" }\n'})
    package(work/'npc-checks.pk3',{'ZSCRIPT':b'version "4.14"\n#include "npc.zs"\n',
        'npc.zs':(HERE/'native_door_npc.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA318NativeDoorNPC" }\n'})
    (work/'manifest.json').write_text(json.dumps({'scope':'Owned diagnostic fixture; current production runtime frozen separately.'})+'\n')
    (work/'test.cfg').write_text('wait 70; netevent doors_begin; wait 800; netevent doors_touch; +use; wait 2; -use; wait 25; netevent doors_touch_check; wait 150; netevent doors_touch_back; +use; wait 2; -use; wait 25; netevent doors_touch_check; screenshot native-doors.png; wait 5; netevent doors_done; wait 5; quit\n')
    (work/'save.cfg').write_text('wait 70; netevent doors_begin; wait 8; save issue318-native-motion; netevent doors_saved; wait 5; quit\n')
    (work/'load.cfg').write_text('wait 800; netevent doors_done; wait 5; quit\n')
    (work/'map.cfg').write_text('wait 140; netevent mapdoors_begin; wait 25; netevent mapdoors_open; screenshot native-map06-door.png; wait 140; netevent mapdoors_done; wait 5; quit\n')
    (work/'catalogue.cfg').write_text('wait 140; netevent c318_seed; netevent c318_catalogue; netevent c318_done; wait 5; quit\n')
    (work/'npc.cfg').write_text('wait 140; netevent npcdoor_begin; wait 25; netevent npcdoor_done; wait 5; quit\n')
    print(work)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--directory',required=True)
    create(p.parse_args().directory)
