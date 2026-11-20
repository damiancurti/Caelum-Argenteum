"""Check package equivalence, unchanged source authority and bounded geometry."""
from pathlib import Path
import hashlib,json,re,struct,zipfile
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');cfg=json.loads((root/'assets/source/art/grips_859/DESIGN.json').read_text())
runtime=root/'build/issue859-grips02.pk3';baseline=root/'build/issue857-wardrobe02.pk3';prototype=root/'build/issue859-prototype02/prototype.pk3'
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
a=json.loads((root/'build/issue859-export05/manifest.json').read_text());b=json.loads((root/'build/issue859-export04/manifest.json').read_text());assert a['sha256']==b['sha256']
for name,expected in cfg['source_sha256'].items():assert digest(root/name)==expected,name
changed_expected={'caelum/data/CaelumWornClothingModelData.zs','caelum/data/wardrobe_candidate.modeldef','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
with zipfile.ZipFile(runtime) as final,zipfile.ZipFile(baseline) as old,zipfile.ZipFile(prototype) as preview:
    names=set(final.namelist());previous=set(old.namelist());assert not previous-names
    new=names-previous;assert new==set(a['sha256'])|{'licenses/GRIPS_859.txt'}
    changed=[];equal=0
    for name in sorted(names):
        data=final.read(name);assert data==(root/'src'/name).read_bytes(),name
        if name in previous:
            if data!=old.read(name):changed.append(name)
            else:equal+=1
    assert set(changed)==changed_expected,changed
    assert all(final.read(name)==preview.read(name) for name in preview.namelist())
    source=final.read('caelum/data/wardrobe_candidate.modeldef').decode();old_source=old.read('caelum/data/wardrobe_candidate.modeldef').decode()
    assert source[source.index(' FrameIndex '):]==old_source[old_source.index(' FrameIndex '):]
    resolved={};current=[0]*17
    for sprite,letter,slot,frame in re.findall(r'^ FrameIndex (\S+) (\S+) (\d+) (\d+)$',source,re.M):current[int(slot)]=int(frame);resolved[sprite,letter]=tuple(current)
    assert len(resolved)==375 and all(len(set(row))==1 for row in resolved.values())
    models={}
    for name in a['sha256']:
        key=Path(name).stem;before='models/caelum/characters/'+('worn/' if key in cfg['gloves'] else 'domingo/')+key+'.md3'
        def info(data):
            h=struct.unpack_from('<4sI64s9I',data);s=struct.unpack_from('<4s64s10I',data,h[10]);return {'frames':h[4],'surfaces':h[6],'vertices':s[5],'triangles':s[6],'bytes':len(data)}
        now,was=info(final.read(name)),info(old.read(before));assert now==was,(key,now,was)
        models[key]=now
    report={'issue':859,'runtime_sha256':digest(runtime),'prototype_sha256':digest(prototype),'members':len(names),'new':sorted(new),'changed':changed,'unchanged_members':equal,'all_runtime_bytes_match_src':True,'all_prototype_members_match_final':True,'independent_rebuild_md3_identical':True,'original_sources_unchanged':True,'resolved_frames':375,'slots':17,'frame_directives_unchanged':True,'same_geometry_counts_and_model_bytes':models,'quantized_wrist_checks':a['quantized_wrist_checks'],'rigid_grip_vertex_checks':a['rigid_grip_vertex_checks']}
(root/'build/issue859-source-check.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items() if k!='same_geometry_counts_and_model_bytes'}))
