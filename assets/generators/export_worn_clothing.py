"""Export independently selectable worn modules through the retained native poses."""
from pathlib import Path
import argparse,hashlib,json,math,struct,sys,zipfile
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/worn_clothing_829'
sys.path.insert(0,str(Path(__file__).parent))
from export_character_modules import write_md3


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true')
    parser.add_argument('--preview-reference',type=Path,help='Reuse other modules only in a provisional fitting overlay; never install this mixed export.')
    parser.add_argument('--preview-modules',help='Comma-separated modules to resample for the provisional overlay.')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);source=args.source.resolve(strict=True);out=args.output.resolve()
    if bool(args.preview_reference)!=bool(args.preview_modules) or (args.install and args.preview_reference):
        parser.error('A provisional preview requires both options and cannot be installed.')
    out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    cfg=json.loads((ART/'DESIGN.json').read_text());author=json.loads(source.with_name('AUTHORING.json').read_text())
    assert author['editable_sha256']==digest(source) and author['config_sha256']==digest(ART/'DESIGN.json')
    assert all(r['nonmanifold_edges']==0 and r['rest_signed_volume']>0 for rows in author['modules'].values() for r in rows)
    design=json.loads((ROOT/cfg['accepted_design']).read_text())
    frames=[(name,frame) for name,options in design['export_actions'].items() for frame in options['frames']]
    assert len(frames)==375
    reference=None;reused_files={}
    if args.preview_reference:
        reference=json.loads((args.preview_reference/'manifest.json').read_text())
        assert reference['frames']==375 and reference['actions']==len(design['export_actions'])
        selected=set(args.preview_modules.split(','));assert selected and selected<=set(author['modules'])
        assert set(reference['modules'])==set(author['modules'])
        for name,expected in reference['sha256'].items():
            blob=(args.preview_reference/name).read_bytes();assert hashlib.sha256(blob).hexdigest()==expected,name
            reused_files[name]=blob
    else:selected=set(author['modules'])
    bpy.ops.wm.open_mainfile(filepath=str(source));scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='POSE'
    modules={key:{'uv':[],'triangles':[],'poses':[],'headers':[]} for key in author['modules'] if key in selected}
    objects={key:[bpy.data.objects[r['object']] for r in rows] for key,rows in author['modules'].items() if key in selected}
    textures={key:bpy.data.objects[rows[0]['object']]['texture'] for key,rows in author['modules'].items()}
    assert all(all(o['texture']==textures[key] for o in rows) for key,rows in objects.items())
    mappings={};skin_sources={}
    for key,rows in objects.items():
        module=modules[key]
        for obj in rows:
            mesh=obj.data;mesh.calc_loop_triangles();lookup={};vertices=[]
            for triangle in mesh.loop_triangles:
                indices=[]
                for loop in triangle.loops:
                    vertex=mesh.loops[loop].vertex_index;uv=tuple(mesh.uv_layers.active.data[loop].uv);pair=(vertex,uv)
                    if pair not in lookup:
                        lookup[pair]=len(module['uv']);module['uv'].append((uv[0],1-uv[1]));vertices.append(vertex)
                    indices.append(lookup[pair])
                module['triangles'].append(indices)
            mappings[obj.name]=vertices
            if key.startswith('base_'):
                skin_sources[obj.name]=[(tuple(mesh.attributes['CA829Source'+n].data[i].value for n in ['A','B','C']),
                                         tuple(mesh.attributes['CA829SourceBary'].data[i].vector)) for i in range(len(mesh.vertices))]
    body_path=ROOT/'src/models/caelum/characters/domingo/underbody.md3';body=body_path.read_bytes()
    header=struct.unpack_from('<4sI64s9I',body);surface=struct.unpack_from('<4s64s10I',body,header[10]);pose_offset=header[10]+surface[10];body_vertices=surface[5]
    assert header[4]==375
    sampled_bounds=[]
    for number,(action,frame) in enumerate(frames):
        rig.animation_data.action=bpy.data.actions[action];scene.frame_set(frame);graph=bpy.context.evaluated_depsgraph_get()
        native_points=[];native_normals=[]
        for vertex in range(body_vertices if any(k.startswith('base_') for k in modules) else 0):
            x,y,z,normal=struct.unpack_from('<3hH',body,pose_offset+(number*body_vertices+vertex)*8)
            native_points.append(Vector((x/64,y/64,z/64)));lat=(normal>>8)*math.pi/128;lng=(normal&255)*math.pi/128
            native_normals.append(Vector((math.cos(lat)*math.sin(lng),math.sin(lat)*math.sin(lng),math.cos(lng))))
        bounds=dict(reference['pose_bounds'][number]['modules']) if reference else {}
        if reference:assert (reference['pose_bounds'][number]['action'],reference['pose_bounds'][number]['source_frame'])==(action,frame)
        for key,rows in objects.items():
            module=modules[key];points=[];packed=bytearray()
            for obj in rows:
                evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh();normal_matrix=evaluated.matrix_world.to_3x3().inverted().transposed()
                for vertex in mappings[obj.name]:
                    if key.startswith('base_'):
                        indices,weights=skin_sources[obj.name][vertex]
                        point=sum((native_points[i]*w for i,w in zip(indices,weights)),Vector())
                        normal=sum((native_normals[i]*w for i,w in zip(indices,weights)),Vector()).normalized()
                    else:
                        point=evaluated.matrix_world@mesh.vertices[vertex].co
                        normal=(normal_matrix@mesh.vertices[vertex].normal).normalized()
                    xyz=[round(c*64) for c in point];assert all(-32768<=c<=32767 for c in xyz)
                    lat=round(math.atan2(normal.y,normal.x)*128/math.pi)&255;lng=round(math.acos(max(-1,min(1,normal.z)))*128/math.pi)&255
                    packed.extend(struct.pack('<3hH',*xyz,(lat<<8)|lng));points.append(point)
                evaluated.to_mesh_clear()
            minimum=[min(v[i] for v in points) for i in range(3)];maximum=[max(v[i] for v in points) for i in range(3)];radius=max(v.length for v in points)
            module['poses'].append(bytes(packed));module['headers'].append(struct.pack('<10f16s',*minimum,*maximum,0,0,0,radius,('f%04d'%number).encode().ljust(16,b'\0')))
            bounds[key]=[minimum,maximum]
        sampled_bounds.append(dict(action=action,source_frame=frame,modules=bounds))
        if number%50==0:print(f'CA829 sampled {number}/{len(frames)}',flush=True)
    model_path=cfg['native_model_path']
    files={**reused_files,**{model_path+'/'+key+'.md3':write_md3('CA829 '+key,module,frames,textures[key]) for key,module in modules.items()}}
    old='models/caelum/characters/domingo'
    slots=[('face',old+'/face.md3',old+'/domingo_skin.png'),('hair',old+'/hair.md3',old+'/domingo_skin.png'),
           *[(k,model_path+'/'+k+'.md3',textures[k]) for k in ['hair_lower','base_core','base_arms','base_neck','base_feet']],
           ('left_hand',old+'/left_hand.md3',old+'/domingo_skin.png'),('right_hand',old+'/right_hand.md3',old+'/domingo_skin.png'),
           *[(k,model_path+'/'+k+'.md3',textures[k]) for k in ['CS','HC','GC','BS','base_forearms','pants_CS_low']]]
    definition=[f'Model {cfg["fixture_class"]}','{',' Scale 1 1 1',' DontCullBackFaces']
    for slot,(key,model,skin) in enumerate(slots):definition.extend([f' Model {slot} "{model}"',f' Skin {slot} "{skin}"'])
    for number in range(len(frames)):
        for slot in range(len(slots)):definition.append(f' FrameIndex D3{number//26:02X} {chr(65+number%26)} {slot} {number}')
    definition.append('}');files['MODELDEF']=('\n'.join(definition)+'\n').encode()
    report=dict(issue=829,source_sha256=digest(source),config_sha256=digest(ART/'DESIGN.json'),generator_sha256=digest(Path(__file__)),
                authoring_generator_sha256=digest(Path(__file__).with_name('author_worn_clothing.py')),body_source_sha256=digest(body_path),frames=len(frames),actions=len(design['export_actions']),
                modules={**(reference['modules'] if reference else {}),**{k:dict(vertices=len(v['uv']),triangles=len(v['triangles']),parts=len(objects[k]),texture=textures[k]) for k,v in modules.items()}},
                slots=[k for k,_,_ in slots],pose_bounds=sampled_bounds,sha256={name:hashlib.sha256(blob).hexdigest() for name,blob in files.items()})
    if reference:report.update(preview_only=True,preview_modules=sorted(selected),preview_reference_sha256=digest(args.preview_reference/'manifest.json'))
    for name,blob in files.items():
        path=out/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
        if args.install and name!='MODELDEF':
            path=ROOT/'src'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    with zipfile.ZipFile(out/'preview.pk3','w') as archive:
        for name,blob in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,18,0,0,0)),blob)
    if args.install:(ART/'EXPORT.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'modules':len(modules),'frames':len(frames),'triangles':sum(len(v['triangles']) for v in modules.values()),'native_bytes':sum(len(v) for k,v in files.items() if k.endswith('.md3'))}),flush=True)


if __name__=='__main__':main()
