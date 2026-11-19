"""Export an isolated IQM comparison from the unchanged accepted Domingo rig.

Run with pinned Blender4.5.3 --background --python this_file -- --output PATH.
Numeric native states retain the original action timing; this tool does not
install or migrate production resources. The manifest measures source-pipeline
and encoding differences separately, including post-armature thickness.
"""
from pathlib import Path
import argparse,hashlib,json,math,struct,sys,zipfile
import bpy
import numpy as np
from mathutils import Matrix,Quaternion,Vector

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/iqm_assessment_834'
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def f32(value):return struct.unpack('<f',struct.pack('<f',value))[0]

def trs(matrix):
    location,rotation,scale=matrix.decompose();rotation.normalize()
    return list(location)+[rotation.x,rotation.y,rotation.z,rotation.w]+list(scale)

def matrix(row):
    q=Quaternion((row[6],row[3],row[4],row[5]));q.normalize()
    return Matrix.LocRotScale(Vector(row[:3]),q,Vector(row[7:10]))

def global_matrices(rows,parents):
    result=[]
    for index,row in enumerate(rows):
        local=matrix(row);result.append(result[parents[index]]@local if parents[index]>=0 else local)
    return np.asarray([list(m) for m in result],dtype=np.float64)

def encode_animation(samples,parents):
    frames=np.asarray(samples,dtype=np.float64)
    offsets=np.min(frames,axis=0).astype(np.float32)
    spans=np.max(frames,axis=0)-np.min(frames,axis=0)
    scales=(spans/65535).astype(np.float32);active=spans!=0
    poses=[];packed=[];decoded=np.empty_like(frames)
    for bone,parent in enumerate(parents):
        mask=sum(1<<channel for channel in range(10) if active[bone,channel])
        poses.append(struct.pack('<iI20f',parent,mask,*offsets[bone],*scales[bone]))
    for frame in range(len(samples)):
        for bone in range(len(parents)):
            for channel in range(10):
                value=0
                if active[bone,channel]:
                    value=max(0,min(65535,round((frames[frame,bone,channel]-float(offsets[bone,channel]))/float(scales[bone,channel]))))
                    packed.append(value)
                decoded[frame,bone,channel]=f32(float(offsets[bone,channel])+f32(value*float(scales[bone,channel])))
    return b''.join(poses),np.asarray(packed,dtype='<u2').tobytes(),decoded,int(np.sum(active))

def quantized_weights(rows,bone_ids):
    indices=[];encoded=[];source=[]
    for row in rows:
        usable=sorted((bone_ids[name],weight) for name,weight in row.items() if weight>0)
        if not 1<=len(usable)<=4:raise ValueError('IQM requires one to four actual deform influences.')
        total=sum(weight for _,weight in usable)
        normalized=[weight/total for _,weight in usable]
        scaled=[weight*255 for weight in normalized];values=[math.floor(v) for v in scaled]
        order=sorted(range(len(values)),key=lambda i:(-(scaled[i]-values[i]),usable[i][0]))
        for i in order[:255-sum(values)]:values[i]+=1
        assert sum(values)==255
        indices.append([bone for bone,_ in usable]+[0]*(4-len(usable)))
        encoded.append(values+[0]*(4-len(values)));source.append(normalized+[0]*(4-len(normalized)))
    return np.asarray(indices,dtype=np.uint8),np.asarray(encoded,dtype=np.uint8),np.asarray(source,dtype=np.float64)

def skin(points,indices,weights,transforms):
    result=np.zeros((len(points),3),dtype=np.float64)
    for slot in range(4):
        selected=transforms[indices[:,slot]]
        transformed=np.einsum('nij,nj->ni',selected[:,:3,:3],points)+selected[:,:3,3]
        result+=transformed*weights[:,slot,None]
    return result

def adjacency(triangles):
    result=np.full((len(triangles),3),0xffffffff,dtype='<u4');edges={}
    for number,triangle in enumerate(triangles):
        for side in range(3):
            edge=tuple(sorted((int(triangle[side]),int(triangle[(side+1)%3]))))
            edges.setdefault(edge,[]).append((number,side))
    for entries in edges.values():
        if len(entries)==2:
            (a,ia),(b,ib)=entries;result[a,ia]=b;result[b,ib]=a
    return result.tobytes()

def write_iqm(name,module,bones,parents,rest,pose_bytes,frame_bytes,channels,bounds,skin_name):
    text=bytearray(b'\0');strings={'':0}
    def string(value):
        if value not in strings:strings[value]=len(text);text.extend(value.encode('utf-8')+b'\0')
        return strings[value]
    mesh_name=string(name);material=string(skin_name)
    joints=b''.join(struct.pack('<Ii10f',string(bone),parent,*row) for bone,parent,row in zip(bones,parents,rest))
    blob=bytearray(124)
    def append(data):
        while len(blob)%4:blob.append(0)
        offset=len(blob);blob.extend(data);return offset
    ofs_text=append(text)
    ofs_meshes=append(struct.pack('<6I',mesh_name,material,0,len(module['positions']),0,len(module['triangles'])))
    descriptors=[]
    for kind,fmt,size,data in [(0,7,3,module['positions'].astype('<f4').tobytes()),(1,7,2,module['uv'].astype('<f4').tobytes()),
       (2,7,3,module['normals'].astype('<f4').tobytes()),(4,1,4,module['indices'].tobytes()),(5,1,4,module['weights'].tobytes())]:
        descriptors.append(struct.pack('<5I',kind,0,fmt,size,append(data)))
    ofs_arrays=append(b''.join(descriptors));ofs_triangles=append(module['triangles'].astype('<u4').tobytes())
    ofs_adjacency=append(adjacency(module['triangles']));ofs_joints=append(joints);ofs_poses=append(pose_bytes)
    ofs_frames=append(frame_bytes);ofs_bounds=append(np.asarray(bounds,dtype='<f4').tobytes())
    # GZDoom reads adjacency and bounds unconditionally; both sections are explicit.
    header=[2,len(blob),0,len(text),ofs_text,1,ofs_meshes,5,len(module['positions']),ofs_arrays,
      len(module['triangles']),ofs_triangles,ofs_adjacency,len(bones),ofs_joints,len(bones),ofs_poses,0,0,
      len(bounds),channels,ofs_frames,ofs_bounds,0,0,0,0]
    blob[:124]=struct.pack('<16s27I',b'INTERQUAKEMODEL\0',*header)
    return bytes(blob)

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    assert bpy.app.version==(4,5,3),'Use pinned Blender4.5.3.'
    cfg=json.loads((ART/'DESIGN.json').read_text(encoding='utf-8'))
    source=ROOT/cfg['source_blend'];assert digest(source)==cfg['source_sha256']
    module_cfg=ROOT/cfg['module_config'];assert digest(module_cfg)==cfg['module_config_sha256']
    original=json.loads(module_cfg.read_text(encoding='utf-8'));design=json.loads((ROOT/cfg['source_design']).read_text(encoding='utf-8'))
    frames=[(name,frame) for name,options in design['export_actions'].items() for frame in options['frames']]
    assert len(frames)==375
    bpy.ops.wm.open_mainfile(filepath=str(source));scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig']
    bones=list(rig.data.bones);names=[bone.name for bone in bones];ids={name:i for i,name in enumerate(names)}
    parents=[ids[b.parent.name] if b.parent else -1 for b in bones]
    assert len(names)<=256 and all(parent<i for i,parent in enumerate(parents))
    deform={b.name for b in bones if b.use_deform}
    rest_world=[rig.matrix_world@b.matrix_local for b in bones]
    rest=[trs(rest_world[parent].inverted()@world if parent>=0 else world) for world,parent in zip(rest_world,parents)]
    encoded_rest=[[f32(v) for v in row] for row in rest]
    inverse_rest=np.linalg.inv(np.asarray([list(m) for m in rest_world],dtype=np.float64))
    inverse_encoded_rest=np.linalg.inv(global_matrices(encoded_rest,parents))
    membership={name:key for key,group in original['groups'].items() for name in group}
    objects=sorted((obj for obj in scene.objects if obj.type=='MESH'),key=lambda obj:obj.name)
    assert set(membership)=={obj.name for obj in objects}
    modules={key:{'uv':[],'triangles':[],'positions':[],'normals':[],'weights_source':[],'objects':[]} for key in original['groups']}
    mappings={};rig.animation_data.action=bpy.data.actions[frames[0][0]];rig.data.pose_position='POSE';scene.frame_set(frames[0][1])
    graph=bpy.context.evaluated_depsgraph_get()
    for obj in objects:
        evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh();mesh.calc_loop_triangles();module=modules[membership[obj.name]]
        lookup={};vertices=[];start=len(module['uv'])
        for triangle in mesh.loop_triangles:
            indices=[]
            for loop in triangle.loops:
                vertex=mesh.loops[loop].vertex_index;uv=tuple(mesh.uv_layers.active.data[loop].uv);key=(vertex,uv)
                if key not in lookup:lookup[key]=len(module['uv']);module['uv'].append((uv[0],1-uv[1]));vertices.append(vertex)
                indices.append(lookup[key])
            module['triangles'].append(indices)
        mappings[obj.name]=np.asarray(vertices,dtype=np.int32)
        module['objects'].append({'name':obj.name,'vertex_start':start,'vertices':len(vertices),'modifiers':[m.type for m in obj.modifiers]})
        evaluated.to_mesh_clear()
    rig.data.pose_position='REST';bpy.context.view_layer.update();graph=bpy.context.evaluated_depsgraph_get()
    source_weight_error=0;max_deform_influences=0
    for obj in objects:
        evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh();module=modules[membership[obj.name]]
        groups={g.index:g.name for g in obj.vertex_groups};normal_matrix=evaluated.matrix_world.to_3x3().inverted().transposed()
        for vertex in mappings[obj.name]:
            v=mesh.vertices[int(vertex)];point=evaluated.matrix_world@v.co;normal=(normal_matrix@v.normal).normalized()
            row={groups[g.group]:g.weight for g in v.groups if groups[g.group] in deform and g.weight>0}
            assert row,'Missing actual deform weights: '+obj.name
            source_weight_error=max(source_weight_error,abs(sum(row.values())-1));max_deform_influences=max(max_deform_influences,len(row))
            module['positions'].append(tuple(point));module['normals'].append(tuple(normal));module['weights_source'].append(row)
        evaluated.to_mesh_clear()
    baseline={}
    for key,module in modules.items():
        for field in ['positions','normals','uv']:module[field]=np.asarray(module[field],dtype=np.float64)
        module['triangles']=np.asarray(module['triangles'],dtype=np.uint32)
        module['indices'],module['weights'],module['float_weights']=quantized_weights(module.pop('weights_source'),ids)
        path=ROOT/'src'/original['module_path']/(key+'.md3');blob=path.read_bytes();header=struct.unpack_from('<4sI64s9I',blob)
        surface=struct.unpack_from('<4s64s10I',blob,header[10]);assert (header[4],surface[5],surface[6])==(375,len(module['positions']),len(module['triangles']))
        assert module['triangles'].astype('<u4').tobytes()==blob[header[10]+surface[7]:header[10]+surface[7]+len(module['triangles'])*12],key+' topology'
        assert module['uv'].astype('<f4').tobytes()==blob[header[10]+surface[9]:header[10]+surface[9]+len(module['uv'])*8],key+' UV'
        baseline[key]={'sha256':digest(path),'bytes':len(blob),'positions':np.frombuffer(blob,dtype='<i2',count=375*len(module['positions'])*4,offset=header[10]+surface[10]).reshape(375,-1,4)[:,:,:3].astype(np.float64)/64}
    rig.data.pose_position='POSE';samples=[];worlds=[];source_positions={key:[] for key in modules};reconstruction_error=0
    for number,(action,frame) in enumerate(frames):
        rig.animation_data.action=bpy.data.actions[action];scene.frame_set(frame);graph=bpy.context.evaluated_depsgraph_get();posed=rig.evaluated_get(graph)
        world=[posed.matrix_world@posed.pose.bones[name].matrix for name in names];rows=[]
        for bone,parent in enumerate(parents):
            local=world[parent].inverted()@world[bone] if parent>=0 else world[bone];row=trs(local)
            if samples and sum(a*b for a,b in zip(row[3:7],samples[-1][bone][3:7]))<0:row[3:7]=[-v for v in row[3:7]]
            reconstructed=matrix(row);reconstruction_error=max(reconstruction_error,max(abs(local[i][j]-reconstructed[i][j]) for i in range(4) for j in range(4)));rows.append(row)
        samples.append(rows);worlds.append(np.asarray([list(m) for m in world],dtype=np.float64))
        points={key:[] for key in modules}
        for obj in objects:
            evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh();array=np.empty((len(mesh.vertices),3),dtype=np.float32);mesh.vertices.foreach_get('co',array.reshape(-1))
            m=np.asarray(evaluated.matrix_world,dtype=np.float64);points[membership[obj.name]].append(array[mappings[obj.name]]@m[:3,:3].T+m[:3,3]);evaluated.to_mesh_clear()
        for key in modules:source_positions[key].append(np.concatenate(points[key],axis=0))
        if number%75==0:print(f'CA834 sampled {number}/375',flush=True)
    pose_bytes,frame_bytes,decoded,channels=encode_animation(samples,parents)
    results={key:{'bounds':[],'max_pipeline_distance':0.0,'max_encoding_distance':0.0,'max_source_distance':0.0,'max_md3_distance':0.0,'squared_source_error':0.0,'worst_source':None} for key in modules}
    for frame in range(len(frames)):
        transforms=np.matmul(global_matrices(decoded[frame],parents),inverse_encoded_rest);unencoded=np.matmul(worlds[frame],inverse_rest)
        for key,module in modules.items():
            expected=source_positions[key][frame]
            floating=skin(module['positions'],module['indices'],module['float_weights'],unencoded)
            native=skin(module['positions'].astype(np.float32).astype(np.float64),module['indices'],module['weights'].astype(np.float64)/255,transforms)
            result=results[key];errors=np.linalg.norm(native-expected,axis=1);worst=int(np.argmax(errors))
            if float(errors[worst])>result['max_source_distance']:
                result['max_source_distance']=float(errors[worst]);result['worst_source']={'frame':frame,'action':frames[frame][0],'source_frame':frames[frame][1],'vertex':worst,'candidate':native[worst].tolist(),'source':expected[worst].tolist()}
            result['max_pipeline_distance']=max(result['max_pipeline_distance'],float(np.linalg.norm(floating-expected,axis=1).max()))
            result['max_encoding_distance']=max(result['max_encoding_distance'],float(np.linalg.norm(native-floating,axis=1).max()))
            result['max_md3_distance']=max(result['max_md3_distance'],float(np.linalg.norm(native-baseline[key]['positions'][frame],axis=1).max()))
            result['squared_source_error']+=float(np.sum(errors**2))
            result['bounds'].append([*native.min(axis=0),*native.max(axis=0),float(np.linalg.norm(native[:,:2],axis=1).max()),float(np.linalg.norm(native,axis=1).max())])
    files={};counts={}
    for key,module in modules.items():
        result=results[key];files[cfg['model_path']+'/'+key+'.iqm']=write_iqm(key,module,names,parents,encoded_rest,pose_bytes,frame_bytes,channels,result.pop('bounds'),cfg['skin'])
        result['rms_source_distance']=math.sqrt(result.pop('squared_source_error')/(375*len(module['positions'])))
        counts[key]={'vertices':len(module['positions']),'triangles':len(module['triangles']),'objects':module['objects'],'md3_sha256':baseline[key]['sha256'],'md3_bytes':baseline[key]['bytes'],'iqm_bytes':len(files[cfg['model_path']+'/'+key+'.iqm']),**result}
    definition=[];retained=set(cfg['hybrid_md3_modules']);assert retained<=set(modules)
    for actor,passthrough in [(cfg['fixture_class'],set()),(cfg['hybrid_fixture_class'],retained)]:
        definition.extend(['Model '+actor,'{',' Scale 1 1 1',' DontCullBackFaces'])
        for slot,key in enumerate(modules):
            resource=original['module_path']+'/'+key+'.md3' if key in passthrough else cfg['model_path']+'/'+key+'.iqm'
            definition.extend([f' Model {slot} "{resource}"',f' Skin {slot} "{cfg["skin"]}"'])
        for frame in range(375):
            for slot in range(7):definition.append(f' FrameIndex D3{frame//26:02X} {chr(65+frame%26)} {slot} {frame}')
        definition.append('}')
    files['MODELDEF']=('\n'.join(definition)+'\n').encode()
    report={'issue':834,'blender':bpy.app.version_string,'source_sha256':digest(source),'config_sha256':digest(ART/'DESIGN.json'),'module_config_sha256':digest(module_cfg),
      'generator_sha256':digest(Path(__file__)),'frames':375,'actions':24,'bones':names,'parents':parents,'frame_channels':channels,'max_actual_deform_influences':max_deform_influences,
      'source_weight_sum_error':source_weight_error,'max_local_trs_reconstruction_error':reconstruction_error,'sampled_vertex_checks':375*sum(len(m['positions']) for m in modules.values()),
      'modules':counts,'hybrid_md3_modules':sorted(retained),'hybrid_model_bytes':sum(v['md3_bytes'] if k in retained else v['iqm_bytes'] for k,v in counts.items()),
      'sha256':{name:hashlib.sha256(blob).hexdigest() for name,blob in files.items()},
      'qualifications':['Part.* groups are selection metadata and are excluded from deform weights.','Post-armature solidify is baked at rest for the skeletal candidate; pipeline error is measured separately from native encoding error.','CPU reconstruction predicts stored sample positions, not renderer/interpolation/normal equivalence; native comparison remains required.','Numeric existing state frames remain authoritative; no uniform-rate IQM named clips are invented.','No production binding, resource, equipment, collision or save schema is changed.']}
    for name,blob in files.items():path=out/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    with zipfile.ZipFile(out/'preview.pk3','w') as package:
        for name,blob in sorted(files.items()):package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),blob)
    assert digest(source)==cfg['source_sha256']
    print(json.dumps({'modules':len(modules),'frames':375,'vertices':sum(v['vertices'] for v in counts.values()),'md3_bytes':sum(v['md3_bytes'] for v in counts.values()),'iqm_bytes':sum(v['iqm_bytes'] for v in counts.values()),'max_source_distance':max(v['max_source_distance'] for v in counts.values())}),flush=True)

if __name__=='__main__':main()
