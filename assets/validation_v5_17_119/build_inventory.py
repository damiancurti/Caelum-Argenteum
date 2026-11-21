"""Audit owned environmental resources and source-backed review coverage."""
from pathlib import Path
from collections import Counter
import argparse,hashlib,json,re,struct,sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
import generate_city_interiors as interior
import generate_barracas_preview as city_preview
SHA=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def read(name):return json.loads((ROOT/name).read_text(encoding='utf-8'))
def textmap(path):
    data=path.read_bytes();magic,count,offset=struct.unpack_from('<4sii',data);assert magic==b'PWAD'
    for i in range(count):
        pos,size,name=struct.unpack_from('<ii8s',data,offset+i*16)
        if name.rstrip(b'\0')==b'TEXTMAP':return data[pos:pos+size].decode('utf-8')
    raise ValueError('Expected UDMF map: '+str(path))
def obj(path):
    lines=path.read_text(encoding='utf-8').splitlines()
    faces=[line.split()[1:] for line in lines if line.startswith('f ')]
    sections=[line.split(maxsplit=1)[1] for line in lines if line.startswith('usemtl ')]
    return dict(path=path.relative_to(ROOT).as_posix(),sha256=SHA(path),bytes=path.stat().st_size,
                vertices=sum(line.startswith('v ') for line in lines),faces=len(faces),
                triangles=sum(len(face)-2 for face in faces),material_sections=len(sections),materials=sorted(set(sections)))
def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    maps=[]
    for name in ['MAP01','MAP02','MAP03','CAH000']:
        p=ROOT/'src/maps'/(name+'.wad');s=textmap(p)
        counts=Counter(re.findall(r'(?im)\btexture(?:floor|ceiling|top|middle|bottom)\s*=\s*"([^\"]+)"',s))
        things=[]
        for body in re.findall(r'\bthing\s*\{([^}]+)\}',s):
            row=dict(re.findall(r'\b(\w+)\s*=\s*([^;]+);',body));things.append(row)
        maps.append(dict(map=name,sha256=SHA(p),bytes=p.stat().st_size,
                         sectors=len(re.findall(r'\bsector\s*\{',s)),linedefs=len(re.findall(r'\blinedef\s*\{',s)),
                         static_things=len(things),static_thing_types=dict(sorted(Counter(row.get('type') for row in things).items())),
                         material_references=dict(sorted(counts.items())),
                         qualification='Static UDMF references only; dynamic residents, furniture, services and effects require their native setup. Reference counts are not texture area or resident GPU cost.'))
    furniture=read('assets/source/art/inventory_models_647/furniture/DESIGN.json');variants=[]
    for key,row in furniture['variants'].items():
        paths=[row[k] for k in row if k.endswith('_obj') and isinstance(row[k],str)]
        variants.append(dict(key=key,item_class=row.get('class'),body_class=row.get('body_class'),
                             source_models=[obj(ROOT/p) for p in paths],source=row))
    layout=read('assets/barracas_redesign/LAYOUT.json');city=read('assets/map06_port/CITY.json');private=read('assets/map06_port/INTERIORS.json')
    house=interior.houses(city)[0];hx,hy=house['bounds'][:2]
    def facing(point,target):
        import math
        return round(math.degrees(math.atan2(target[1]-point[1],target[0]-point[0]))%360,6)
    door=[hx+private['door_inside'][0],hy+private['door_inside'][1]]
    table=[hx+private['table'][0],hy+private['table'][1]]
    living=private['rooms']['living'];bedroom=private['rooms']['bedroom'];bathroom=private['rooms']['bathroom']
    living_centre=[hx+(living[0]+living[2])/2,hy+(living[1]+living[3])/2]
    bed_door=private['doorways'][0];bed_point=[hx+bed_door[0]-private['door_inset'],hy+(bed_door[1]+bed_door[3])/2]
    bath_door=private['doorways'][1];bath_point=[hx+(bath_door[0]+bath_door[2])/2,hy+bath_door[3]+private['door_inset']]
    cameras={'CAH000':[
        dict(name='house_entrance',point=door,angle=facing(door,table),basis='Original private house0 bounds + INTERIORS.door_inside, looking toward the existing table'),
        dict(name='house_living',point=living_centre,angle=facing(living_centre,table),basis='Center of authored living room, looking toward the existing table'),
        dict(name='house_bedroom',point=bed_point,angle=facing(bed_point,[hx+private['bed'][0],hy+private['bed'][1]]),basis='Bedroom doorway inner side, offset by existing door_inset'),
        dict(name='house_bathroom',point=bath_point,angle=facing(bath_point,[hx+(bathroom[0]+bathroom[2])/2,hy+(bathroom[1]+bathroom[3])/2]),basis='Bathroom doorway inner side, offset by existing door_inset')], 'MAP03':[]}
    for name,b in [('municipality',next(b for b in layout['buildings'] if b.get('civic'))),('workshop',next(b for b in layout['buildings'] if b['kind']=='factory'))]:
        profile=city['profiles'][b['kind']];cell=layout['grid'];width,height=profile['size']
        if b.get('civic'):width,height=b['bounds'][2]-b['bounds'][0],b['bounds'][3]-b['bounds'][1]
        door_y=(height//(cell*2))*cell
        for label,x in [('entrance',width+cell),('inside',width-cell*2)]:
            point=city_preview.local_point(b,x,door_y)
            target=city_preview.local_point(b,width/2,door_y)
            cameras['MAP03'].append(dict(name=name+'_'+label,point=point,angle=facing(point,target),basis='Existing generated door center and authored grid; no gameplay placement'))
    sources=['assets/map06_port/INTERIORS.json','assets/map06_port/CITY.json','assets/barracas_redesign/LAYOUT.json',
             'assets/source/art/inventory_models_647/furniture/DESIGN.json','src/caelum/world/CaelumHouseHub.zs',
             'assets/generators/generate_house_hubs.py','assets/generators/generate_barracas_map.py',
             'assets/generators/generate_barracas_preview.py']
    owned_props={}
    for family in ['bathrooms','dining_sets','kitchen','kitchen_fixtures','luxury','ornamental','reading','rest','sofas','stash','stations','study','wardrobe','water_furniture']:
        folder=ROOT/'src/models/caelum/props'/family
        owned_props[family]=[obj(p) for p in sorted(folder.glob('*.obj'))]
    provenance={}
    for family in ['bathrooms','basic_rest_furniture','dining_sets','kitchen_fixtures','kitchen_stations','luxury_furniture','ornamental_decor','sofas','study_furniture','wardrobe','water_furniture']:
        for name in ['DATA.json','MANIFEST.json','GENERATED.json']:
            p=ROOT/'assets/art_source'/family/name
            if p.is_file():provenance[p.relative_to(ROOT).as_posix()]=SHA(p)
    report=dict(issue=881,status='source_inventory_native_evidence_separate',author_acceptance=False,
                sources={p:SHA(ROOT/p) for p in sources},maps=maps,furniture=variants,owned_prop_models=owned_props,provenance=provenance,
                facade=obj(ROOT/'src/models/caelum/architecture/barracas/house-960-1216.obj'),
                city_counts=dict(Counter(b['kind'] for b in layout['buildings'])),cameras=cameras,
                scope='Read-only source inventory. Existing household source prepares table/chairs, bed, chest and bathroom fixtures; item models are not evidence that every map is fully furnished. Camera positions are review-only and require native clearance checks. No src/map/resource mutations.')
    (out/'INVENTORY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(maps=[{k:r[k] for k in ['map','sectors','linedefs','static_things']} for r in maps],furniture_variants=len(variants),city_counts=report['city_counts'],cameras=cameras)))
if __name__=='__main__':main()
