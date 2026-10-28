"""Build portable historical table envelopes and complete-set material bills."""
from pathlib import Path
import hashlib,json,math,sys
sys.dont_write_bytecode=True
from generate_luxury_furniture import Construction,WOOD,METAL
ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/art_source/dining_sets'
DATA=json.loads((ART/'DATA.json').read_text(encoding='utf-8'))
U=DATA['units_per_meter']
def make(row):
    c=Construction();w,d,h=(row[n] for n in ('width','depth','height'));t=DATA['top_thickness']
    if row['round']:
        # Exact32-sided polygon volume, unlike an unrecorded smooth cylinder.
        n=32;r=w/2
        c.volume[WOOD]+=n*math.sin(2*math.pi/n)*r*r/2*t
        for i in range(n):
            a,b=(2*math.pi*j/n for j in (i,i+1))
            x,z=r*math.cos(a),r*math.sin(a);xx,zz=r*math.cos(b),r*math.sin(b)
            c.mesh.add_triangle(WOOD,[(v[0]*U,v[1]*U,v[2]*U) for v in ((0,h,0),(x,h,z),(xx,h,zz))])
            c.mesh.add_triangle(WOOD,[(v[0]*U,v[1]*U,v[2]*U) for v in ((0,h-t,0),(xx,h-t,zz),(x,h-t,z))])
            c.mesh.add_quad(WOOD,[(v[0]*U,v[1]*U,v[2]*U) for v in ((x,h-t,z),(xx,h-t,zz),(xx,h,zz),(x,h,z))])
        p=DATA['round_pedestal_width'];f=DATA['round_foot_height'];length=DATA['round_foot_length']
        c.box(WOOD,(0,(h-t)/2,0),(p,h-t,p));c.box(WOOD,(0,f/2,0),(length,f,p));c.box(WOOD,(0,f/2,0),(p,f,length))
    else:
        c.box(WOOD,(0,h-t/2,0),(w,t,d));leg=DATA['leg_width'];inset=DATA['leg_inset']
        for x in (-w/2+inset,w/2-inset):
            for z in (-d/2+inset,d/2-inset):
                c.box(WOOD,(x,(h-t)/2,z),(leg,h-t,leg))
                # Two distinct vertical joint pins per corner.
                for shift in (-leg/4,leg/4):c.turned(x+shift,z,[(h-t-DATA['pin_length'],DATA['pin_radius']),(h-t,DATA['pin_radius'])],METAL)
        a=DATA['apron_thickness'];ah=DATA['apron_height'];y=h-t-ah/2
        for x in (-w/2+inset,w/2-inset):c.box(WOOD,(x,y,0),(a,ah,d-2*inset))
        for z in (-d/2+inset,d/2-inset):c.box(WOOD,(0,y,z),(w-2*inset,ah,a))
    # Native AngleOffset -90 maps OBJ depth to game longitudinal axis.
    c.mesh.vertices=[(z,y,-x) for x,y,z in c.mesh.vertices]
    return c
def main():
    dest=ROOT/'src/models/caelum/props/dining_sets';dest.mkdir(parents=True,exist_ok=True)
    basic=json.loads((ROOT/'assets/art_source/basic_rest_furniture/GENERATED.json').read_text(encoding='utf-8'))
    luxury=json.loads((ROOT/'assets/art_source/luxury_furniture/GENERATED.json').read_text(encoding='utf-8'))
    basic_chair=next(r for r in basic['models'] if r['kind']=='chair')
    luxury_chair=next(r for r in luxury['models'] if r['kind']=='chair')
    rows=[]
    for v,source in enumerate(DATA['tables']):
        row=dict(source)
        if v<3:
            c=make(row);row.update(c.bill());p=dest/('ca_dining_'+row['kind']+'.obj');c.mesh.write(p)
            p.write_text(p.read_text(encoding='utf-8').replace('o CaelumStashChest','o CaelumPortableDining'),encoding='utf-8',newline='\n')
            row['sha256']=hashlib.sha256(p.read_bytes()).hexdigest();chair=basic_chair
        else:
            prior=next(r for r in luxury['models'] if r['kind']=='table');row.update(prior);row.update(kind='luxury',seats=6,capacity=18,round=False);chair=luxury_chair
        row['set_kg']=row['empty_kg']+row['seats']*chair['empty_kg']
        row['set_recipe_grams']={k:row['recipe_grams'][k]+row['seats']*chair['recipe_grams'].get(k,chair['recipe_grams'].get('cloth',0) if k=='cotton_cloth' else 0) for k in row['recipe_grams']}
        rows.append(row)
    (ART/'GENERATED.json').write_text(json.dumps({'issue':410,'models':rows,'textures_reused':[WOOD,METAL]},indent=2)+'\n',encoding='utf-8')
    code=['// #410: generado desde dining_sets/DATA.json y las sillas existentes.','class CaelumDiningSetData : Object','{','    const COUNT=4;']
    for method,key,scale in [('Width','width',U),('Depth','depth',U),('Height','height',U),('Mass','set_kg',1),('TableMass','empty_kg',1)]:
        code.append('    static clearscope double '+method+'(int v){return '+''.join(f'v=={i}?{r[key]*scale:.9f}:' for i,r in enumerate(rows[:-1]))+f'{rows[-1][key]*scale:.9f};'+'}')
    for method,key in [('Wood','wood'),('Iron','iron'),('Cloth','cotton_cloth')]:
        code.append('    static clearscope int '+method+'(int v){return '+''.join(f'v=={i}?{r["set_recipe_grams"][key]}:' for i,r in enumerate(rows[:-1]))+str(rows[-1]['set_recipe_grams'][key])+';}')
    for method,key in [('Seats','seats'),('Capacity','capacity')]:
        code.append('    static clearscope int '+method+'(int v){return '+''.join(f'v=={i}?{r[key]}:' for i,r in enumerate(rows[:-1]))+str(rows[-1][key])+';}')
    for method,prefix,suffix,typ in [('ItemClass','Caelum','DiningSetItem','Name'),('BodyClass','CaelumPortable','Table','Name'),('NameKey','CA_DINING_SET_','','String'),('Icon','sprites/caelum/rest_furniture/','A0.png','String')]:
        values=['CDS2','CDS6','CD12','CDLX'] if method=='Icon' else ['Small','Normal','Large','Luxury']
        if method=='NameKey':values=[v.upper() for v in values]
        terms=[json.dumps(prefix+v+suffix) for v in values]
        code.append('    static clearscope '+typ+' '+method+'(int v){return '+''.join(f'v=={i}?{t}:' for i,t in enumerate(terms[:-1]))+terms[-1]+';}')
    code += [
      '    static clearscope double ChairRadius(int v){return CaelumRestFurnitureData.Radius(v==3?0:2);}',
      '    static clearscope double FullHeight(int v){return Max(Height(v),CaelumRestFurnitureData.Height(v==3?0:2));}',
      '    static clearscope double SeatClearance(int v){return Max(ChairRadius(v),GetDefaultByType("CaelumPlayer").Radius)+1;}',
      '    static clearscope double SeatSpacing(int v){return GetDefaultByType("CaelumPlayer").Radius+ChairRadius(v)+1;}',
      '    static clearscope double Radius(int v){double w=Width(v)/2+SeatClearance(v)+ChairRadius(v),d=Depth(v)/2+SeatClearance(v)+ChairRadius(v);return Sqrt(w*w+d*d);}',
      '}', '']
    (ROOT/'src/caelum/data/CaelumDiningSetData.zs').write_text('\n'.join(code),encoding='utf-8',newline='\n')
    print(json.dumps([{k:r[k] for k in ('kind','set_kg','set_recipe_grams')} for r in rows]))
if __name__=='__main__':main()
