"""Build an isolated regional art map using preserved #455 visual pilots."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import zipfile

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'assets/source/art/regional_gallery_463'


def digest(blob):return hashlib.sha256(blob).hexdigest()


def wad(config):
    vertices=[];vertex_ids={};edges={};sectors=[]
    def vertex(point):
        if point not in vertex_ids:vertex_ids[point]=len(vertices);vertices.append(point)
        return vertex_ids[point]
    def rectangle(x1,y1,x2,y2,sector):
        points=[(x1,y1),(x1,y2),(x2,y2),(x2,y1)]
        for a,b in zip(points,points[1:]+points[:1]):
            key=tuple(sorted((a,b)))
            if key in edges:
                assert edges[key]['back'] is None
                edges[key]['back']=sector
            else:edges[key]={'a':vertex(a),'b':vertex(b),'front':sector,'back':None}
    sectors.append(config['walkway_flat'])
    for index,plot in enumerate(config['plots'],1):
        sectors.append(plot['floor']);x1,x2=plot['x']
        rectangle(x1,config['walkway_y'][0],x2,config['walkway_y'][1],0)
        rectangle(x1,config['plot_y'][0],x2,config['plot_y'][1],index)
    text=['namespace="ZDoom";']
    text += [f'vertex {{ x={x}; y={y}; }}' for x,y in vertices]
    for flat in sectors:
        text.append(f'sector {{ heightfloor=0; heightceiling={config["ceiling_height"]}; texturefloor="{flat}"; textureceiling="F_SKY1"; lightlevel={config["ambient"]}; }}')
    sidedef=0;line_count=0
    for edge in edges.values():
        front,back=edge['front'],edge['back']
        if back==front:continue
        text.append(f'sidedef {{ sector={front}; texturemiddle="{config["outer_wall"] if back is None else "-"}"; }}')
        line=f'linedef {{ v1={edge["a"]}; v2={edge["b"]}; sidefront={sidedef}; '
        sidedef+=1
        if back is None:line+='blocking=true; '
        else:
            text.append(f'sidedef {{ sector={back}; texturemiddle="-"; }}')
            line+=f'sideback={sidedef}; twosided=true; ';sidedef+=1
        text.append(line+'}');line_count+=1
    x,y,angle=config['player_start']
    text.append(f'thing {{ type=1; x={x}; y={y}; angle={angle}; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }}')
    source=('\n'.join(text)+'\n').encode();lumps=[(config['map'],b''),('TEXTMAP',source),('ENDMAP',b'')]
    body=bytearray();directory=bytearray()
    for name,blob in lumps:
        directory.extend(struct.pack('<ii8s',12+len(body),len(blob),name.encode().ljust(8,b'\0')));body.extend(blob)
    binary=struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory
    return binary,source,dict(sectors=len(sectors),vertices=len(vertices),linedefs=line_count)


def build(output, baseline_materials=False):
    output.mkdir(parents=True,exist_ok=True)
    config=json.loads((SOURCE/'GALLERY.json').read_text())
    if baseline_materials:
        for plot in config['plots']:plot['floor']=config['walkway_flat']
    regions=json.loads((ROOT/'assets/bestiary/REGION_PROPOSAL.json').read_text())
    allowed={row['id']:row['proposed_campaign_regions'] for row in regions['entries']}
    files={};includes=[];modeldefs=[];textures=[]
    source_hashes={path.relative_to(ROOT).as_posix():digest(path.read_bytes()) for path in
                   [SOURCE/'GALLERY.json',ROOT/'assets/bestiary/REGION_PROPOSAL.json',Path(__file__),Path(__file__).with_name('gallery.zs')]}
    for kind in sorted({item['kind'] for item in config['subjects']}):
        directory=ROOT/'assets/bestiary/models'/kind
        manifest=json.loads((directory/'manifest.json').read_text())
        for name,checksum in manifest['sha256'].items():
            if name.endswith(('.obj','.mtl')):continue
            blob=(directory/name).read_bytes()
            if digest(blob)!=checksum:raise ValueError('Changed original model source: '+kind+'/'+name)
            source_hashes['assets/bestiary/models/'+kind+'/'+name]=checksum
            if name in ['ZSCRIPT','MODELDEF','TEXTURES']:
                target='ca463/'+kind+'/'+name.lower()+'.txt'
                if name=='ZSCRIPT':blob=blob.split(b'\n',1)[1];includes.append(target)
                elif name=='MODELDEF':modeldefs.append(target)
                else:textures.append(target)
                files[target]=blob
            elif name.startswith('models/caelum/folklore/'):
                files[name]=blob
            elif (ROOT/'src'/name).read_bytes()!=blob:
                raise ValueError('Shared original material differs from runtime: '+name)
    template=Path(__file__).with_name('gallery.zs').read_text(encoding='utf-8')
    spawn=[];verify=[];views=[]
    for index,item in enumerate(config['subjects']):
        if item['region'] not in allowed[item['catalogue_id']]:raise ValueError('Unapproved region assignment')
        xyz=','.join(map(str,item['position']))
        spawn.append(f'{{let item=Actor.Spawn(\'{item["class"]}\',({xyz}),NO_REPLACE);item.Angle={item["angle"]};Subjects.Push(item);}}')
        verify.append(f'Check(Subjects[{index}] != null && Subjects[{index}].GetClass()==\'{item["class"]}\', "subject {index} original class");')
        verify.append(f'if(Subjects[{index}] != null) Check((Subjects[{index}].Pos-({xyz})).Length()<0.01, "subject {index} saved position");')
    player_view=None
    for index,item in enumerate(config['views']):
        if item.get('control'):player_view=index;continue
        p=item['position'];t=item['target'];delta=[b-a for a,b in zip(p,t)]
        angle=math.degrees(math.atan2(delta[1],delta[0]));pitch=-math.degrees(math.atan2(delta[2],math.hypot(*delta[:2])))
        xyz=','.join(map(str,p))
        views.append(f'if(index=={index}){{View.SetOrigin(({xyz}),false);View.Angle={angle:.8f};View.Pitch={pitch:.8f};}}')
    assert player_view is not None
    crossing=config['crossing_test']
    boundary=next(plot['x'][0] for plot in config['plots'] if plot['region']==crossing['destination_plot'])
    substitutions={'SPAWN_CASES':'\n'.join(spawn),'VERIFY_CASES':'\n'.join(verify),'VIEW_CASES':'\n'.join(views),'SUBJECT_COUNT':str(len(config['subjects'])),'PLAYER_VIEW':str(player_view),
                   'CROSS_START':'('+','.join(map(str,crossing['start']))+')','CROSS_ANGLE':str(crossing['angle']),'CROSS_BOUNDARY':str(boundary)}
    for key,value in substitutions.items():template=template.replace(key,value)
    files['ca463/gallery.zs']=template.encode();includes.append('ca463/gallery.zs')
    files['ZSCRIPT']=('version "4.14.2"\n'+''.join('#include "'+name+'"\n' for name in includes)).encode()
    files['MODELDEF']=''.join('#include "'+name+'"\n' for name in modeldefs).encode()
    files['TEXTURES']=''.join('#include "'+name+'"\n' for name in textures).encode()
    files['MAPINFO']=(f'map {config["map"]} "{config["title"]}" {{ sky1="CABASKY",0 nointermission }}\ngameinfo {{ AddEventHandlers="CA463GalleryEvents" }}\n').encode()
    binary,textmap,stats=wad(config);files['maps/'+config['map']+'.wad']=binary
    fixture=output/'gallery.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        for name,blob in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    (output/'gallery.zs').write_bytes(template.encode());(output/'TEXTMAP.txt').write_bytes(textmap)
    report=dict(issue=463,scope=config['status'],baseline_materials=baseline_materials,geometry=stats,subjects=config['subjects'],views=config['views'],
                source_sha256=source_hashes,fixture_sha256=digest(fixture.read_bytes()),
                sha256={name:digest(blob) for name,blob in files.items()})
    (output/'GALLERY_MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    return fixture,report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();fixture,report=build(args.output)
    print(json.dumps({'fixture':str(fixture),'geometry':report['geometry'],'subjects':len(report['subjects'])}))
