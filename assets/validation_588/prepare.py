"""Create a private placement geometry fixture without changing campaign maps."""
from pathlib import Path
import importlib.util
import json
import sys
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue411-placement'


def room():
    vertices=[];sides=[];lines=[];sectors=[];vertex_ids={};edges={}
    def vertex(p):
        if p not in vertex_ids:
            vertex_ids[p]=len(vertices);vertices.append(dict(x=p[0],y=p[1]))
        return vertex_ids[p]
    # Final narrow strip lies inside a footprint but between its nine samples.
    xs=[0,256,512,768,1024,1280,1536,1792,1800,1804,2048,2304,2560,2816]
    for i,(x,nx) in enumerate(zip(xs,xs[1:])):
        floor=16 if i==1 else -64 if i==11 else -96 if i==12 else 0
        sectors.append(dict(heightfloor=floor,heightceiling=32 if i==2 else 192,
            texturefloor='FWATER1' if i in (3,8,11,12) else 'CMST01',textureceiling='CMST02',lightlevel=208))
        if i>=10:sectors[-1]['id']=41101 if i==10 else 41102
        points=[(x,0),(x,256),(nx,256),(nx,0)]
        for a,b in zip(points,points[1:]+points[:1]):
            side=len(sides);sides.append(dict(sector=i,texturemiddle='CMST01',texturetop='CMST01',texturebottom='CMST01'))
            key=tuple(sorted((a,b)))
            if key in edges:
                line=lines[edges[key]];line.update(sideback=side,twosided=True,blocking=False)
                sides[line['sidefront']]['texturemiddle']='-';sides[side]['texturemiddle']='-'
                if a[0]==b[0]==1280:line.update(special=12,playeruse=True,arg0=0,arg1=16,arg2=150)
                if a[0]==b[0]==1536:line.update(special=74,playercross=True,arg0=1)
            else:
                edges[key]=len(lines);lines.append(dict(v1=vertex(a),v2=vertex(b),sidefront=side,blocking=True))
    for index,(tag,floor,ceiling,kind,texture) in enumerate(((41101,0,64,2,'FWATER1'),(41102,-4,0,1,'CMST01'))):
        sector=len(sectors);sectors.append(dict(heightfloor=floor,heightceiling=ceiling,
            texturefloor=texture,textureceiling=texture,lightlevel=208))
        x=-1024+index*128;points=[(x,0),(x,64),(x+64,64),(x+64,0)]
        for edge,(a,b) in enumerate(zip(points,points[1:]+points[:1])):
            side=len(sides);sides.append(dict(sector=sector,texturemiddle='CMST01'))
            line=dict(v1=vertex(a),v2=vertex(b),sidefront=side,blocking=True)
            if edge==0:line.update(special=160,arg0=tag,arg1=kind,arg2=0,arg3=255)
            lines.append(line)
    def block(kind,row):
        def value(v):
            return json.dumps(v) if isinstance(v,str) else str(v).lower() if isinstance(v,bool) else str(v)
        return kind+' { '+' '.join(f'{k}={value(v)};' for k,v in row.items())+' }'
    result=['namespace="ZDoom";']
    for kind,rows in [('vertex',vertices),('sidedef',sides),('linedef',lines),('sector',sectors)]:
        result.extend(block(kind,row) for row in rows)
    result.append('thing { x=64; y=128; type=1; angle=0; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
    return '\n'.join(result)+'\n'


def main():
    WORK.mkdir(parents=True,exist_ok=True)
    spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
        'checks.zs':(HERE/'checks.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA411PChecks" }\ncluster 8418 { hub }\nmap CPL411 "Placement checks" { cluster=8418 }\nmap CPL411B "Placement return" { cluster=8418 }\n',
        'TERRAIN':b'terrain CA411Wet { liquid }\nfloor FWATER1 CA411Wet\n',
        'maps/CPL411.wad':module.wad(room(),'CPL411'),
        'maps/CPL411B.wad':module.wad(room(),'CPL411B')}
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    for name,body in {
        'core':'wait 35; netevent ca411p_core; wait 5; quit',
        'storage':'wait 35; netevent ca411p_storage; wait 5; quit',
        'save':'wait 35; netevent ca411p_seed; save ca411p-final; wait 5; quit',
        'load':'wait 5; netevent ca411p_loaded; wait 5; quit',
        'hub':'wait 5; netevent ca411p_loaded; changemap CPL411B; wait 35; netevent ca411p_loaded; changemap CPL411; wait 35; netevent ca411p_loaded; wait 5; quit',
        'handoff':'wait 35; netevent ca411p_seed; netevent ca411p_step; netevent ca411p_place; netevent ca411p_water; netevent ca411p_place; netevent ca411p_door; netevent ca411p_place; netevent ca411p_dry; netevent ca411p_place; netevent ca411p_contents; wait 5; quit',
    }.items():
        (WORK/(name+'.cfg')).write_text(body+'\n',encoding='utf-8')
    legacy=(HERE/'legacy.zs').read_text(encoding='utf-8')
    seed='''u.SetOrigin((95,128,0),false);u.Angle=0;
        record=CA411PLegacyRecord(u.GiveInventoryType('CA411PLegacyRecord'));
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(0,48,0),NO_REPLACE));
        chest.EnsureStorage();chest.StorageTier=0;chest.ApplyStorageSize();
        record.Contents=Inventory(Actor.Spawn('CaelumLifePotion',u.Pos,NO_REPLACE));
        record.Contents.Amount=3;record.Contents.AttachToOwner(chest);
        CaelumInventoryService.CarryStorageChest(u,chest);record.Cargo=chest.Cargo;u.PersistCharacterState();'''
    verify='''if(ok){u.Angle=0;u.SetOrigin((223,128,0),false);
        ok=!record.Cargo.Chest.TryPlaceStorage(u) && record.Cargo.Owner==u && record.Contents.Owner==record.Cargo.Chest;}'''
    for mode in ('baseline','bridge','rollback'):
        target=WORK/mode;target.mkdir(parents=True,exist_ok=True)
        bridge=dict(members)
        bridge['checks.zs']=legacy.replace('// MODE',seed if mode=='baseline' else '').replace('// VERIFY',verify if mode=='bridge' else '').encode('utf-8')
        bridge['MAPINFO']=members['MAPINFO'].replace(b'CA411PChecks',b'CA411PLegacy')
        with zipfile.ZipFile(target/'legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
            for name,blob in sorted(bridge.items()):
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    (WORK/'legacy-seed.cfg').write_text('wait 35; netevent ca411p_legacy; save ca411p-legacy-final; wait 5; quit\n',encoding='utf-8')
    (WORK/'legacy-load.cfg').write_text('wait 5; netevent ca411p_legacy; wait 5; quit\n',encoding='utf-8')
    (WORK/'interactive.cfg').write_text('''exec ../../assets/playtest/default_controls.cfg
language es
bind F1 "netevent ca411p_dry"
bind F2 "netevent ca411p_step"
bind F3 "netevent ca411p_water"
bind F4 "netevent ca411p_door"
bind F5 "netevent ca411p_place"
bind F6 "netevent ca411p_contents; toggleconsole"
wait 35; netevent ca411p_seed
''',encoding='utf-8')
    if len(sys.argv)>1:
        package=WORK/sys.argv[1]/'caelum_argenteum_dev.pk3'
        package.parent.mkdir(parents=True,exist_ok=True)
        if package.exists():
            raise RuntimeError('Refusing to overwrite a recorded runtime package')
        with zipfile.ZipFile(package,'w',zipfile.ZIP_DEFLATED,compresslevel=1) as archive:
            for path in sorted((ROOT/'src').rglob('*')):
                if not path.is_file():continue
                info=zipfile.ZipInfo(path.relative_to(ROOT/'src').as_posix(),(2000,1,1,0,0,0))
                info.compress_type=zipfile.ZIP_DEFLATED
                archive.writestr(info,path.read_bytes(),compresslevel=1)
        print('Private full-source probe:',package)


if __name__=='__main__':
    main()
