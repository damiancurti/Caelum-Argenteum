"""Compose a private municipal furniture review from owned models and source geometry."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,math,re,struct,zipfile

ROOT=Path(__file__).resolve().parents[2]
CONFIG=ROOT/'assets/source/art/municipal_review_886/CONFIG.json'
SHA=lambda b:hashlib.sha256(b).hexdigest()

def read(path):return json.loads((ROOT/path).read_text(encoding='utf-8'))

def wad_with_text(blob,text):
    magic,count,directory=struct.unpack_from('<4sii',blob);assert magic==b'PWAD'
    entries=[struct.unpack_from('<ii8s',blob,directory+i*16) for i in range(count)]
    assert [n.rstrip(b'\0') for _,_,n in entries]==[b'MAP03',b'TEXTMAP',b'ENDMAP']
    data=bytearray(b'\0'*12);rows=[]
    for offset,size,name in entries:
        body=text if name.rstrip(b'\0')==b'TEXTMAP' else blob[offset:offset+size]
        rows.append((len(data),len(body),name));data+=body
    directory=len(data)
    for row in rows:data+=struct.pack('<ii8s',*row)
    struct.pack_into('<4sii',data,0,b'PWAD',count,directory)
    return bytes(data)

def model_metrics(path):
    lines=path.read_text(encoding='utf-8').splitlines()
    vertices=[tuple(map(float,l.split()[1:4])) for l in lines if l.startswith('v ')]
    return dict(sha256=SHA(path.read_bytes()),bytes=path.stat().st_size,vertices=len(vertices),
                triangles=sum(len(l.split())-3 for l in lines if l.startswith('f ')),
                material_sections=sum(l.startswith('usemtl ') for l in lines),
                render_radius=math.ceil(max(math.hypot(x,z) for x,y,z in vertices)),
                bounds=[[min(v[i] for v in vertices),max(v[i] for v in vertices)] for i in range(3)])

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','composition','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    cfg=read(CONFIG);layout=read(cfg['layout']);city=read(cfg['city']);interior=read(cfg['interiors'])
    study=read(cfg['study']);rest=read(cfg['rest']);reading=read(cfg['reading'])
    building=next(r for r in layout['buildings'] if r.get('civic'));assert building['kind']=='shop' and building['angle']==0
    a,b,c,d=building['bounds'];grid=layout['grid'];width=c-a;height=d-b
    courtyard=[a+width//4//grid*grid,b+height//4//grid*grid,a+width*3//4//grid*grid,b+height*3//4//grid*grid]
    desk=next(r for r in study['variants'] if r['name']=='desk');unit=study['units_per_meter'];assert unit==rest['units_per_meter']
    dimensions={
        'desk':dict(width=desk['width']*unit,depth=desk['depth']*unit,height=desk['height']*unit),
        'chair':{k:rest['chair'][k]*unit for k in ['width','depth','height']},
        'shelf':{k:reading[k] for k in ['width','depth','height']}}
    for kind,row in dimensions.items():row['radius']=reading['radius'] if kind=='shelf' else math.hypot(row['width'],row['depth'])/2
    # All placements derive from retained civic/house/furniture data. The bay
    # division is a private composition choice, not an approved permanent budget.
    bedroom=interior['rooms']['bedroom'];bay_max=bedroom[3]-bedroom[1]
    inner_left=a+grid;inner_right=c-grid;bay_count=math.ceil((inner_right-inner_left)/bay_max)
    boundaries=[inner_left+round((inner_right-inner_left)*i/bay_count/grid)*grid for i in range(bay_count+1)]
    step=city['detail']['window_step'];positions=[];bays=[]
    north_shelf_y=d-grid-dimensions['shelf']['radius']
    desk_y=d-grid-grid-dimensions['desk']['radius']
    chair_y=desk_y-dimensions['desk']['depth']/2-dimensions['chair']['depth']/2-grid/2
    north_angle=(reading['angle']+180)%360
    def add(kind,x,y,angle,zone):positions.append(dict(kind=kind,point=[x,y,0],angle=angle,zone=zone))
    for i,(left,right) in enumerate(zip(boundaries,boundaries[1:])):
        zone=f'office_{i+1}';bays.append(dict(name=zone,bounds=[left,courtyard[3],right,d-grid]))
        for x in range(left+step,right-step+1,step):
            add('shelf',x,north_shelf_y,north_angle,zone)
            add('desk',x,desk_y,north_angle,zone)
            add('chair',x,chair_y,reading['angle'],zone)
    shelf_step=math.ceil(dimensions['shelf']['width']/grid)*grid
    archive_x=a+grid+dimensions['shelf']['radius']
    for y in range(courtyard[1]+grid//2,courtyard[3],shelf_step):
        add('shelf',archive_x,y,(reading['angle']-90)%360,'archive')
    assert positions and all(b+grid+p['point'][2] < p['point'][1] < d-grid for p in positions)
    for p in positions:
        x,y,z=p['point'];r=dimensions[p['kind']]['radius']
        assert a+grid<=x-r and x+r<=c-grid and b+grid<=y-r and y+r<=d-grid
        assert y-r>=courtyard[3] or x+r<=courtyard[0],p
    for i,p in enumerate(positions):
        for q in positions[i+1:]:assert math.dist(p['point'][:2],q['point'][:2])>=dimensions[p['kind']]['radius']+dimensions[q['kind']]['radius'],(p,q)
    manifest=json.loads((args.composition/'MANIFEST.json').read_text())
    assert manifest['issue']==cfg['inherited_issue'] and manifest['runtime_sha256']==SHA(args.runtime.read_bytes())
    variant=next(r for r in manifest['variants'] if r['name']==cfg['inherited_variant'])
    package=args.composition/(variant['name']+'.pk3');assert SHA(package.read_bytes())==variant['sha256']
    with zipfile.ZipFile(package) as archive:members={n:archive.read(n) for n in archive.namelist()}
    assert {n:SHA(v) for n,v in members.items()}==variant['members']
    with zipfile.ZipFile(args.runtime) as archive:
        base_modeldef=archive.read('MODELDEF').decode('utf-8')
        base_city=archive.read('maps/MAP03.wad')
        editor_values=[int(v) for n in archive.namelist() if n.lower()=='mapinfo' or n.lower().endswith('.mapinfo')
                       for block in re.findall(rb'\bdoomednums\s*\{([^}]+)\}',archive.read(n),re.I)
                       for v in re.findall(rb'\b(\d+)\s*=',block)]
    next_editor=max(editor_values)+1;assert next_editor+len(dimensions)<65536
    assert not {'ZSCRIPT','MAPINFO','MODELDEF','LANGUAGE'} & members.keys()
    source=[];bindings=[];editor_rows=[];metrics={}
    for i,(kind,dim) in enumerate(dimensions.items()):
        row=cfg['models'][kind];name='CA886Scene'+kind.title();editor=next_editor+i;dim['class']=name;dim['editor']=editor
        metrics[kind]=model_metrics(ROOT/row['model'])
        definition=re.search(r'\bModel\s+'+row['source_class']+r'\s*\{[^}]+\}',base_modeldef)
        assert definition and Path(row['model']).name in definition.group(0)
        bindings.append(definition.group(0).replace(row['source_class'],name,1))
        source.append(f'class {name} : Actor {{ Default {{ Tag "$CA886_SCENE_{kind.upper()}"; Radius {dim["radius"]:.9f}; Height {dim["height"]:.9f}; RenderRadius {metrics[kind]["render_radius"]}; +SOLID +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE }} States {{ Spawn: {row["sprite"]} A -1; Stop; }} }}')
        editor_rows.append(f'{editor}={name}')
    spec=importlib.util.spec_from_file_location('ceiling_reader',Path(__file__).with_name('build_interior_ceiling_review.py'))
    reader=importlib.util.module_from_spec(spec);spec.loader.exec_module(reader)
    original=members['maps/MAP03.wad'];_,text=reader.textmap(original)
    append='\n'
    for p in positions:
        x,y,z=p['point'];editor=dimensions[p['kind']]['editor']
        append+=f'thing\n{{\n    x = {x:.9f};\n    y = {y:.9f};\n    height = {z};\n    angle = {p["angle"]};\n    type = {editor};\n    skill1 = true;\n    skill2 = true;\n    skill3 = true;\n    skill4 = true;\n    skill5 = true;\n    single = true;\n    coop = true;\n    dm = true;\n}}\n'
    changed=text+append;assert changed[:len(text)]==text
    members['maps/MAP03.wad']=wad_with_text(original,changed.encode('utf-8'))
    language=''
    for locale,key in [('enu default','label_en'),('es','label_es')]:
        language+='['+locale+']\n'+''.join(f'CA886_SCENE_{kind.upper()} = {json.dumps(row[key],ensure_ascii=False)};\n' for kind,row in cfg['models'].items())
    members.update(ZSCRIPT=('version "4.14.2"\n'+'\n'.join(source)+'\n').encode(),
                   MAPINFO=('doomednums {\n'+'\n'.join(editor_rows)+'\n}\n').encode(),
                   MODELDEF=('\n'.join(bindings)+'\n').encode(),LANGUAGE=language.encode('utf-8'))
    path=out/'municipal.pk3'
    with zipfile.ZipFile(path,'x',compression=zipfile.ZIP_STORED) as archive:
        for name,body in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),body)
    report=dict(issue=886,author_acceptance=False,runtime_sha256=manifest['runtime_sha256'],inherited_sha256=variant['sha256'],
                builder_sha256=SHA(Path(__file__).read_bytes()),config_sha256=SHA(CONFIG.read_bytes()),
                sources={cfg[k]:SHA((ROOT/cfg[k]).read_bytes()) for k in ['layout','city','interiors','study','rest','reading','reference']},
                source_map_sha256=SHA(original),candidate_map_sha256=SHA(members['maps/MAP03.wad']),
                source_checksum=hashlib.md5(text.encode()).hexdigest(),candidate_checksum=hashlib.md5(changed.encode()).hexdigest(),
                default_checksum=hashlib.md5(reader.textmap(base_city)[1].encode()).hexdigest(),
                original_textmap_prefix_unchanged=True,original_things=len(reader.blocks(text,'thing')),added_things=len(positions),
                geometry_counts={kind:len(reader.blocks(text,kind)) for kind in ['vertex','linedef','sidedef','sector']},
                civic=building,courtyard=courtyard,office_bays=bays,dimensions=dimensions,positions=positions,models=metrics,
                total_instance_triangles=sum(metrics[p['kind']]['triangles'] for p in positions),
                package_sha256=SHA(path.read_bytes()),package_bytes=path.stat().st_size,members={n:SHA(v) for n,v in sorted(members.items())},
                qualification=cfg['scope'])
    (out/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:report[k] for k in ['issue','added_things','total_instance_triangles','package_sha256','package_bytes']}))

if __name__=='__main__':main()
