"""Export independent MD3 modules from the accepted rig without changing its art.

Run with pinned Blender4.5.3 --background --python this_file -- --output PATH.
Source groups and identities live in MODULES.json; no complete outfit combinations
are baked. The source .blend is read-only and the original exporter is retained.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import sys
import zipfile
import bpy

ROOT=Path(__file__).resolve().parents[2]
CONFIG=ROOT/'assets/source/art/character_modules_458/MODULES.json'
sys.path.insert(0,str(Path(__file__).parent))
from export_domingo_pilot import fixed

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def write_md3(name,module,frames,skin):
    tri=b''.join(struct.pack('<3I',*face) for face in module['triangles'])
    skins=struct.pack('<64sI',fixed(skin,64),0)
    uv=b''.join(struct.pack('<2f',*pair) for pair in module['uv'])
    poses=b''.join(module['poses']);headers=b''.join(module['headers'])
    triangle_offset=108;skin_offset=triangle_offset+len(tri);uv_offset=skin_offset+len(skins);pose_offset=uv_offset+len(uv)
    surface_end=pose_offset+len(poses)
    surface=struct.pack('<4s64s10I',b'IDP3',fixed(name,64),0,len(frames),1,len(module['uv']),len(module['triangles']),triangle_offset,skin_offset,uv_offset,pose_offset,surface_end)
    surface_offset=108+len(headers)
    header=struct.pack('<4sI64s9I',b'IDP3',15,fixed('CA458 '+name,64),0,len(frames),0,1,1,108,surface_offset,surface_offset,surface_offset+surface_end)
    return header+headers+surface+tri+skins+uv+poses

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--check',action='store_true')
    parser.add_argument('--install',action='store_true',help='Install or check the generated runtime modules and their data bindings.')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);output=args.output.resolve()
    if bpy.app.version!=(4,5,3):raise RuntimeError('Use pinned Blender4.5.3.')
    config=json.loads(CONFIG.read_text(encoding='utf-8'));source=ROOT/config['source_blend']
    if digest(source)!=config['source_sha256']:raise ValueError('Accepted Blender source checksum changed.')
    design=json.loads((ROOT/config['source_design']).read_text(encoding='utf-8'))
    bpy.ops.wm.open_mainfile(filepath=str(source));scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig']
    names=[name for group in config['groups'].values() for name in group]
    objects=sorted((obj for obj in scene.objects if obj.type=='MESH'),key=lambda obj:obj.name)
    if len(set(names))!=len(names) or set(names)!={obj.name for obj in objects}:raise ValueError('Every source mesh must belong to exactly one module.')
    membership={name:group for group,names in config['groups'].items() for name in names}
    modules={name:{'uv':[],'triangles':[],'poses':[],'headers':[],'objects':[]} for name in config['groups']}
    frames=[(name,frame) for name,options in design['export_actions'].items() for frame in options['frames']]
    mappings={};global_count=0;baseline=(ROOT/config['baseline_model']).read_bytes()
    base_header=struct.unpack_from('<4sI64s9I',baseline);base_surface=base_header[10]
    base_info=struct.unpack_from('<4s64s10I',baseline,base_surface)
    assert base_info[3]==len(frames)
    base_pose=base_surface+base_info[10];base_uv=base_surface+base_info[9];base_tri=base_surface+base_info[7]
    mismatches=[];binary_vertex_checks=0;triangle_checks=0
    for frame_number,(action,frame) in enumerate(frames):
        rig.animation_data.action=bpy.data.actions[action];scene.frame_set(frame);graph=bpy.context.evaluated_depsgraph_get()
        positions={name:[] for name in modules};packed={name:bytearray() for name in modules}
        for obj in objects:
            module=modules[membership[obj.name]];evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh();mesh.calc_loop_triangles()
            if frame_number==0:
                lookup={};vertices=[];start=len(module['uv'])
                for triangle in mesh.loop_triangles:
                    indices=[]
                    for loop in triangle.loops:
                        vertex=mesh.loops[loop].vertex_index;uv=tuple(mesh.uv_layers.active.data[loop].uv);key=(vertex,uv)
                        if key not in lookup:
                            lookup[key]=len(module['uv']);module['uv'].append((uv[0],1-uv[1]));vertices.append(vertex)
                        indices.append(lookup[key])
                    module['triangles'].append(indices)
                    translated=[index-start+global_count for index in indices]
                    offset=base_tri+triangle_checks*12
                    if struct.pack('<3I',*translated)!=baseline[offset:offset+12] and len(mismatches)<20:mismatches.append('triangle:'+obj.name)
                    triangle_checks+=1
                mappings[obj.name]=(vertices,global_count)
                for index,uv in enumerate(module['uv'][start:]):
                    if struct.pack('<2f',*uv)!=baseline[base_uv+(global_count+index)*8:base_uv+(global_count+index+1)*8] and len(mismatches)<20:mismatches.append('UV:'+obj.name)
                module['objects'].append({'name':obj.name,'vertices':len(vertices),'module_vertex_start':start,'baseline_vertex_start':global_count})
                global_count+=len(vertices)
            vertices,base_start=mappings[obj.name];normal_matrix=evaluated.matrix_world.to_3x3().inverted().transposed()
            for index,vertex in enumerate(vertices):
                point=evaluated.matrix_world@mesh.vertices[vertex].co
                normal=(normal_matrix@mesh.vertices[vertex].normal).normalized()
                lat=round(math.atan2(normal.y,normal.x)*128/math.pi)&255;lng=round(math.acos(max(-1,min(1,normal.z)))*128/math.pi)&255
                xyz=[round(value*64) for value in point]
                if any(not -32768<=value<=32767 for value in xyz):raise ValueError('Native coordinate overflow: '+obj.name)
                value=struct.pack('<3hH',*xyz,(lat<<8)|lng);packed[membership[obj.name]].extend(value);positions[membership[obj.name]].append(tuple(point))
                offset=base_pose+(frame_number*base_info[5]+base_start+index)*8
                if value!=baseline[offset:offset+8] and len(mismatches)<20:mismatches.append(f'frame{frame_number}:{obj.name}:vertex{index}')
                binary_vertex_checks+=1
            evaluated.to_mesh_clear()
        for name,module in modules.items():
            points=positions[name];minimum=[min(point[axis] for point in points) for axis in range(3)];maximum=[max(point[axis] for point in points) for axis in range(3)]
            radius=max(math.sqrt(sum(value*value for value in point)) for point in points)
            module['headers'].append(struct.pack('<10f16s',*minimum,*maximum,0,0,0,radius,fixed('f%04d'%frame_number,16)))
            module['poses'].append(bytes(packed[name]))
        if frame_number%100==0:print(f'CA458 sampled{frame_number}/{len(frames)}',flush=True)
    assert global_count==base_info[5] and sum(len(module['triangles']) for module in modules.values())==base_info[6]
    assert not mismatches,mismatches
    files={};model_path=config['module_path'];skin='domingo_skin.png'
    definition=[f'Model {config["native_fixture_class"]}','{',f'    Path "{model_path}"','    Scale 1 1 1','    DontCullBackFaces']
    for slot,(name,module) in enumerate(modules.items()):
        files[f'{model_path}/{name}.md3']=write_md3(name,module,frames,skin)
        definition.extend([f'    Model {slot} "{name}.md3"',f'    Skin {slot} "{skin}"'])
    for number in range(len(frames)):
        sprite='D3%02X'%(number//26);letter=chr(65+number%26)
        for slot in range(len(modules)):definition.append(f'    FrameIndex {sprite} {letter} {slot} {number}')
    definition.append('}');files['MODELDEF']=('\n'.join(definition)+'\n').encode()
    files[model_path+'/'+skin]=(ROOT/config['skin']).read_bytes()
    files['caelum/data/domingo_modules.modeldef']=files['MODELDEF'].replace(config['native_fixture_class'].encode(),config['native_runtime_class'].encode())
    names=','.join("'%s.md3'"%name for name in modules)
    data='// Generado desde MODULES.json; no cambia identidad ni equipo del dueño.\nclass CaelumDomingoModules : Object\n{\n'
    data+=f'    const COUNT={len(modules)};\n'
    for slot,name in enumerate(modules):data+=f'    const {name.upper()}={slot};\n'
    data+='    static void SetVisible(Actor body,int slot,bool visible)\n    {\n'
    data+=f'        static const name files[]={{{names}}};\n'
    data+='        if(body==null || slot<0 || slot>=COUNT)return;\n'
    data+=f'        body.A_ChangeModel(\'None\',slot,"{model_path}",files[slot],slot,"{model_path}",\'{skin}\',visible?0:CMDL_HIDEMODEL);\n'
    data+='    }\n}\n'
    files['caelum/data/CaelumDomingoModules.zs']=data.encode()
    report={'schema_revision':1,'issue':458,'blender':bpy.app.version_string,'source':config['source_blend'],'source_sha256':digest(source),
        'config_sha256':digest(CONFIG),'design_sha256':digest(ROOT/config['source_design']),'generator_sha256':digest(Path(__file__)),
        'baseline_sha256':digest(ROOT/config['baseline_model']),'frames':len(frames),'binary_vertex_checks':binary_vertex_checks,'triangle_checks':triangle_checks,'baseline_mismatches':mismatches,
        'modules':{name:{'slot':slot,'vertices':len(module['uv']),'triangles':len(module['triangles']),'objects':module['objects']} for slot,(name,module) in enumerate(modules.items())},
        'sha256':{name:hashlib.sha256(blob).hexdigest() for name,blob in files.items()}}
    files['manifest.json']=(json.dumps(report,indent=2)+'\n').encode()
    for name,blob in files.items():
        path=output/name
        if args.check:
            if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale module output: '+name)
        else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    if args.install:
        for name,blob in files.items():
            if name in ('MODELDEF','manifest.json'):continue
            path=ROOT/'src'/name
            if args.check:
                if not path.is_file() or path.read_bytes()!=blob:raise ValueError('Stale installed module: '+name)
            else:path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
        manifest=ROOT/'assets/source/art/character_modules_458/EXPORT.json'
        if args.check:
            if not manifest.is_file() or manifest.read_bytes()!=files['manifest.json']:raise ValueError('Stale installed manifest.')
        else:manifest.write_bytes(files['manifest.json'])
    if not args.check:
        with zipfile.ZipFile(output/'preview.pk3','w') as package:
            for name,blob in sorted(files.items()):
                if name.endswith('.json') or name.startswith('caelum/'):continue
                package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    assert digest(source)==config['source_sha256']
    print(json.dumps({'modules':len(modules),'frames':len(frames),'binary_vertex_checks':binary_vertex_checks,'baseline_mismatches':mismatches,'output':str(output)}))

if __name__=='__main__':main()
