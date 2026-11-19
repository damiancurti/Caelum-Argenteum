"""Generate first-body selection data from the existing clothing and fit sources."""
from pathlib import Path
import argparse,hashlib,json,re
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')

def generate():
    art=ROOT/'assets/source/art/worn_clothing_829';cfg=json.loads((art/'DESIGN.json').read_text());visibility=json.loads((art/'VISIBILITY.json').read_text())
    catalogue=(ROOT/'src/caelum/data/CaelumClothingData.zs').read_text(encoding='utf-8')
    region_source=catalogue[catalogue.index('static clearscope int Region'):catalogue.index('static clearscope String NameKey')]
    regions={int(n):int(r) for n,r in re.findall(r'case (\d+): return (\d+);',region_source)}
    constants={name:int(value) for name,value in re.findall(r'const ([A-Z_]+)=(\d+);',catalogue)}
    worn=ROOT/'src/models/caelum/characters/worn'
    pieces={value:name for name,value in constants.items() if value in regions and (worn/(name+'.md3')).is_file()}
    assert set(pieces)==set(range(25)) and set(regions)==set(pieces)
    groups={r:[pieces[n] for n in sorted(pieces) if regions[n]==r] for r in range(4)}
    assert [row[0] for row in cfg['combinations']]==groups[1]
    assert cfg['trouser_hems']['foot_order']==groups[3]
    source='// #857: generado desde el catalogo aprobado y las reglas de ajuste #829.\nclass CaelumWornClothingModelData : Object\n{\n    const MODEL_SLOTS=17;\n'
    kind_values=[groups[regions[n]].index(pieces[n]) for n in range(25)]
    source+='    static clearscope int Kind(int type,int region)\n    {\n'
    source+='        if(type<0 || type>=CaelumClothingData.COUNT || CaelumClothingData.Region(type)!=region)return -1;\n'
    source+='        static const int values[]={'+','.join(map(str,kind_values))+'};\n        return values[type];\n    }\n'
    slots=visibility['fixture_slots'];assert len(slots)==15
    mask=lambda names:sum(1<<slots.index(n) for n in names)
    masks=[mask(visibility['body_items_hidden'][n]) for n in groups[1]]
    source+='    static clearscope int Hidden(int body,int head,int hands,int feet)\n    {\n'
    source+='        static const int bodies[]={'+','.join(map(str,masks))+'};\n'
    source+=f'        int hidden=body<0?{mask(visibility["body_absent_hidden"])}:bodies[Clamp(body,0,{len(masks)-1})];\n'
    for region,rule in visibility['other_regions'].items():
        source+=f'        hidden|={region}<0?{mask(rule["absent_hidden"])}:{mask(rule["present_hidden"])};\n'
    source+='        return hidden;\n    }\n'
    hems=cfg['trouser_hems'];variants=list(hems['variants'])
    pants=['pants_'+key+'_'+variant+'.md3' for key in groups[1] for variant in variants]
    foot_variants=[variants.index(hems['foot_items'][key]) for key in groups[3]]
    source+='    static clearscope name PantsFile(int body,int feet)\n    {\n'
    source+='        static const name files[]={'+','.join("'"+n+"'" for n in pants)+'};\n'
    source+='        static const int foot[]={'+','.join(map(str,foot_variants))+'};\n'
    source+=f'        int variant=feet<0?{variants.index("bare")}:foot[Clamp(feet,0,{len(groups[3])-1})];\n'
    source+=f'        return files[Clamp(body,0,{len(groups[1])-1})*{len(variants)}+variant];\n    }}\n'
    fixed=['face.md3','hair.md3','hair_lower.md3','base_core.md3','base_arms.md3','base_neck.md3','base_feet.md3','left_hand.md3','right_hand.md3','None','None','None','None','base_forearms.md3','None','weapon.md3','shield.md3']
    selectors={1:'body',0:'head',2:'hands',3:'feet'};dynamic={9:1,10:0,11:2,12:3}
    for method,extension in [('File','.md3'),('Skin','.png')]:
        source+=f'    static clearscope name {method}(int slot,int body,int head,int hands,int feet)\n    {{\n'
        for region,keys in groups.items():
            names=[(key if method=='File' else key.lower())+extension for key in keys]
            source+='        static const name '+selectors[region]+'Files[]={'+','.join("'"+n+"'" for n in names)+'};\n'
        for slot,region in dynamic.items():source+=f'        if(slot=={slot})return {selectors[region]}Files[Clamp({selectors[region]},0,{len(groups[region])-1})];\n'
        if method=='File':
            source+='        if(slot==14)return PantsFile(body,feet);\n'
            source+='        static const name fixedFiles[]={'+','.join("'"+n+"'" for n in fixed)+'};\n        return fixedFiles[Clamp(slot,0,MODEL_SLOTS-1)];\n'
        else:source+='        if(slot==14)return bodyFiles[Clamp(body,0,10)];\n        return \'domingo_skin.png\';\n'
        source+='    }\n'
    original='models/caelum/characters/domingo';model_paths=[original if i in (0,1,7,8,15,16) else 'models/caelum/characters/worn' for i in range(17)]
    skin_paths=[original]*17
    for slot,category in {9:'clothing',10:'headwear',11:'gloves',12:'footwear',14:'clothing'}.items():skin_paths[slot]='models/caelum/inventory/'+category
    for method,paths in [('ModelPath',model_paths),('SkinPath',skin_paths)]:
        source+=f'    static clearscope String {method}(int slot)\n    {{\n        switch(slot)\n        {{\n'
        for i,path in enumerate(paths):source+=f'            case {i}:return "{path}";\n'
        source+='        }\n        return "";\n    }\n'
    source+='}\n'
    definition=(art/'worn_preview.modeldef').read_text().replace('Model CA829WardrobePreview','Model CaelumWardrobePilotBody',1)
    at=definition.index(' FrameIndex ')
    definition=definition[:at]+f' Model 15 "{original}/weapon.md3"\n Skin 15 "{original}/domingo_skin.png"\n Model 16 "{original}/shield.md3"\n Skin 16 "{original}/domingo_skin.png"\n'+definition[at:]
    frames=re.findall(r'^ FrameIndex (\S+) (\S+) 0 (\d+)$',definition,re.M);assert frames
    # GZDoom snapshots the full model-frame array at every FrameIndex line.
    # Keep all slots for each sprite/frame contiguous; appending accessories
    # later would overwrite that state's body slots with the last body frame.
    at=definition.index(' FrameIndex ')
    definition=definition[:at]+''.join(f' FrameIndex {sprite} {letter} {slot} {frame}\n' for sprite,letter,frame in frames for slot in range(17))+'}\n'
    assert len(re.findall(r'^ FrameIndex ',definition,re.M))==len(frames)*17
    current=[0]*17;resolved={}
    for sprite,letter,slot,frame in re.findall(r'^ FrameIndex (\S+) (\S+) (\d+) (\d+)$',definition,re.M):
        current[int(slot)]=int(frame);resolved[sprite,letter]=tuple(current)
    assert all(resolved[sprite,letter]==(int(frame),)*17 for sprite,letter,frame in frames)
    for region,keys in groups.items():
        category={0:'headwear',1:'clothing',2:'gloves',3:'footwear'}[region]
        for key in keys:assert (ROOT/'src/models/caelum/inventory'/category/(key.lower()+'.png')).is_file()
    for name in pants:assert (worn/name).is_file()
    evidence=dict(issue=857,pieces=pieces,regions=regions,groups=groups,model_slots=17,frames=len(frames),new_geometry=False,new_textures=False,source_hashes={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in (art/'DESIGN.json',art/'VISIBILITY.json',art/'worn_preview.modeldef',ROOT/'src/caelum/data/CaelumClothingData.zs')})
    return source,definition,evidence

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
    source,definition,evidence=generate()
    (out/'CaelumWornClothingModelData.zs').write_text(source,encoding='utf-8',newline='\n');(out/'wardrobe_candidate.modeldef').write_text(definition,encoding='utf-8',newline='\n')
    (out/'manifest.json').write_text(json.dumps(evidence,indent=2)+'\n',encoding='utf-8');print(json.dumps(dict(output=str(out),models=evidence['model_slots'],frames=evidence['frames'],pieces=len(evidence['pieces']))))
