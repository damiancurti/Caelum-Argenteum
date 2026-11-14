"""Package reference-based parrot and canine serpent anatomy using the shared rig."""
from pathlib import Path
import json,re
try:
    from .generate_serpent_models import ROOT,geometry,pose,digest,Mesh,md3,fixed,shared_main
except ImportError:
    from generate_serpent_models import ROOT,geometry,pose,digest,Mesh,md3,fixed,shared_main
SOURCE=ROOT/'assets/source/art/hybrid_serpents_727'
MODEL_PATH='models/caelum/folklore/hybrid_serpents'
DEFINITION='caelum/data/hybrid_serpent_combat.modeldef'


def output_files():
    config=json.loads((SOURCE/'ANIMATION.json').read_text(encoding='utf-8'));files={};records={};definitions=[]
    for name,h in config['source_sha256'].items():
        if digest((ROOT/name).read_bytes())!=h:raise ValueError('Changed source '+name)
    profile=(ROOT/config['profile_source']).read_text(encoding='utf-8').split('class '+config['profile_class']+' :',1)[1].split('class ',1)[0]
    defaults={k:float(re.search(r'\b'+k+r'\s+([\d.]+)\s*;',profile)[1]) for k in ['Height','Radius','Scale']}
    for kind,item in config['species'].items():
        design=json.loads((ROOT/item['design']).read_text());mesh,weights,rows,basis=geometry(design)
        frames=[];floors=[]
        for frame in config['frames']:
            p,floor=pose(design,mesh,weights,rows,basis,frame['control']);frames.append(p);floors.append(floor)
        shaders={k:MODEL_PATH+'/'+Path(p).name for k,p in item['textures'].items()}
        native=Mesh();native.vertices=mesh.vertices;native.uv=mesh.uv;native.parts=mesh.parts
        native.faces=[(design['materials'][m]['native_batch'],tri) for m,tri in mesh.faces]
        binary,surfaces,bounds=md3(native,frames,shaders);factor=defaults['Height']/(max(p[2] for p in frames[0])-min(p[2] for p in frames[0]))/defaults['Scale']
        files[MODEL_PATH+'/'+kind+'.md3']=binary[:8]+fixed(item['catalogue_id']+' inherited combat',64)+binary[72:]
        for k,p in item['textures'].items():files[shaders[k]]=(ROOT/p).read_bytes()
        definitions+=['Model '+item['actor'],'{',f' Path "{MODEL_PATH}"',f' Model 0 "{kind}.md3"',f' Scale {factor:.12g} {factor:.12g} {factor:.12g}',' CorrectPixelStretch']
        definitions += [f' FrameIndex {f["sprite"]} {f["letter"]} 0 {i}' for i,f in enumerate(config['frames'])];definitions+=['}','']
        lines=['# Original continuous serpent; OBJ Y up. Editable rig and poses in JSON.','mtllib '+kind+'.mtl']
        lines += [f'v {x:.6f} {z:.6f} {-y:.6f}' for x,y,z in frames[0]]
        lines += [f'vt {u:.8f} {1-v:.8f}' for u,v in mesh.uv];previous=None
        for material,tri in mesh.faces:
            group=mesh.parts[tri[0]];batch=design['materials'][material]['native_batch']
            if previous!=(group,batch):lines+=['g '+group,'usemtl '+batch];previous=(group,batch)
            lines.append('f '+' '.join(f'{i+1}/{i+1}' for i in tri))
        files['editable/'+kind+'.obj']=('\n'.join(lines)+'\n').encode()
        files['editable/'+kind+'.mtl']=''.join(f'newmtl {k}\nKd 1 1 1\nmap_Kd src/{p}\n' for k,p in shaders.items()).encode()
        records[kind]=dict(actor=item['actor'],catalogue_id=item['catalogue_id'],vertices=len(mesh.vertices),triangles=len(mesh.faces),hierarchical_parts=len(design['shapes']),surfaces=surfaces,native_bounds=bounds,modeldef_scale=factor,native_profile=defaults,source_sha256=digest((ROOT/item['reference']).read_bytes()),pose_floors=floors)
    files[DEFINITION]='\n'.join(definitions).encode()
    sources=dict(config['source_sha256'])
    paths=[SOURCE/'ANIMATION.json',SOURCE/'PROVENANCE.json',*[ROOT/i['design'] for i in config['species'].values()],*[SOURCE/n for n in ['MATERIALS_PROMPT.json']],*[Path(__file__).with_name(n) for n in ['generate_hybrid_serpent_models.py','generate_serpent_models.py','generate_nahuelito_model.py','generate_peuchen_model.py','generate_duende_models.py','generate_pombero_model.py']]]
    sources.update({p.relative_to(ROOT).as_posix():digest(p.read_bytes()) for p in paths})
    files['manifest.json']=(json.dumps(dict(schema_revision=1,issue=727,parent_issue=461,status=config['status'],frames=config['frames'],species=records,source_sha256=sources,sha256={n:digest(b) for n,b in files.items()}),indent=2)+'\n').encode()
    return files


if __name__=='__main__':shared_main(SOURCE,DEFINITION,output_files)
