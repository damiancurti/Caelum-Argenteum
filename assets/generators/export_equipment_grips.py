"""Export finite closed grip modules with retained native action sampling."""
from pathlib import Path
import argparse,hashlib,json,math,struct,sys,zipfile
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/grips_859'
sys.path.insert(0,str(Path(__file__).parent))
from export_character_modules import write_md3

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def quantize(point):return tuple(round(c*64) for c in point)

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--source',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--install',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);source=args.source.resolve(strict=True);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    assert bpy.app.version==(4,5,3)
    cfg=json.loads((ART/'DESIGN.json').read_text());author=json.loads((source.parent/'AUTHORING.json').read_text());assert digest(source)==author['editable_sha256']
    assert digest(ART/'DESIGN.json')==author['config_sha256']
    for name,expected in cfg['source_sha256'].items():assert digest(ROOT/name)==expected,name
    design=json.loads((ROOT/cfg['rig_design']).read_text());frames=[(a,f) for a,row in design['export_actions'].items() for f in row['frames']];assert len(frames)==375
    bpy.ops.wm.open_mainfile(filepath=str(source));scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='POSE'
    rig.animation_data.action=bpy.data.actions[frames[0][0]];scene.frame_set(frames[0][1]);initial_graph=bpy.context.evaluated_depsgraph_get()
    modules={k:{'uv':[],'triangles':[],'poses':[],'headers':[]} for k in author['modules']};mappings={};triangles={}
    for key,names in author['modules'].items():
        module=modules[key]
        for name in names:
            evaluated=bpy.data.objects[name].evaluated_get(initial_graph);mesh=evaluated.to_mesh();mesh.calc_loop_triangles();lookup={};vertices=[]
            triangles[name]=[tuple(t.vertices) for t in mesh.loop_triangles]
            for tri in mesh.loop_triangles:
                indices=[]
                for loop in tri.loops:
                    vertex=mesh.loops[loop].vertex_index;uv=tuple(mesh.uv_layers.active.data[loop].uv);pair=(vertex,uv)
                    if pair not in lookup:lookup[pair]=len(module['uv']);module['uv'].append((uv[0],1-uv[1]));vertices.append(vertex)
                    indices.append(lookup[pair])
                module['triangles'].append(indices)
            mappings[name]=vertices;evaluated.to_mesh_clear()
    body=(ROOT/'src/models/caelum/characters/domingo/underbody.md3').read_bytes();header=struct.unpack_from('<4sI64s9I',body);surface=struct.unpack_from('<4s64s10I',body,header[10]);body_offset=header[10]+surface[10];body_vertices=surface[5]
    seam_checks=0;rigid_grip_checks=0;frame_bounds=[];max_center_error=0
    for number,(action,frame) in enumerate(frames):
        rig.animation_data.action=bpy.data.actions[action];scene.frame_set(frame);graph=bpy.context.evaluated_depsgraph_get();transforms={}
        for side,letter,equipment in [('Left','L','shield'),('Right','R','sword')]:
            hand=rig.pose.bones['hand.'+letter].matrix@rig.data.bones['hand.'+letter].matrix_local.inverted()
            item=rig.pose.bones[equipment].matrix@rig.data.bones[equipment].matrix_local.inverted()
            center=Vector(author['hands'][side]['fitted_center']);offset=hand@center-item@center
            error=(item@center+offset-hand@center).length;max_center_error=max(max_center_error,error);assert error<1e-4
            transforms[side]=(item,offset)
        bounds={}
        for key,names in author['modules'].items():
            packed=bytearray();all_points=[];module=modules[key]
            for name in names:
                obj=bpy.data.objects[name];side=obj['CA859Side'];item,offset=transforms[side];evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh()
                points=[evaluated.matrix_world@v.co for v in mesh.vertices];evaluated.to_mesh_clear()
                if obj['CA859Role']=='item':points=[p+offset for p in points]
                else:
                    weights=obj.data.attributes['CA859AttachWeight']
                    for i,p in enumerate(points):
                        weight=weights.data[i].value;attached=item@obj.data.vertices[i].co+offset
                        points[i]=p.lerp(attached,weight)
                        if weight==1:
                            assert quantize(points[i])==quantize(attached);rigid_grip_checks+=1
                    if key.endswith('_hand'):
                        for i,j in author['hands'][side]['seams'].items():
                            native=struct.unpack_from('<3h',body,body_offset+(number*body_vertices+j)*8)
                            assert quantize(points[int(i)])==native,f'{action}:{frame}:{name}:{i} wrist mismatch';seam_checks+=1
                normals=[Vector() for _ in points]
                for a,b,c in triangles[name]:
                    normal=(points[b]-points[a]).cross(points[c]-points[a])
                    for i in (a,b,c):normals[i]+=normal
                for i in mappings[name]:
                    point=points[i];normal=normals[i].normalized();xyz=quantize(point);assert all(-32768<=c<=32767 for c in xyz)
                    latitude=round(math.atan2(normal.y,normal.x)*128/math.pi)&255;longitude=round(math.acos(max(-1,min(1,normal.z)))*128/math.pi)&255
                    packed.extend(struct.pack('<3hH',*xyz,(latitude<<8)|longitude));all_points.append(point)
            minimum=[min(p[i] for p in all_points) for i in range(3)];maximum=[max(p[i] for p in all_points) for i in range(3)]
            module['poses'].append(bytes(packed));module['headers'].append(struct.pack('<10f16s',*minimum,*maximum,0,0,0,max(p.length for p in all_points),('f%04d'%number).encode().ljust(16,b'\0')));bounds[key]=[minimum,maximum]
        frame_bounds.append({'action':action,'source_frame':frame,'modules':bounds})
    files={cfg['native_path']+'/'+key+'.md3':write_md3(key,module,frames,key.lower()+'.png' if key in cfg['gloves'] else 'domingo_skin.png') for key,module in modules.items()}
    native_references={}
    for name,blob in files.items():
        key=Path(name).stem;reference=ROOT/'src/models/caelum/characters'/('worn' if key in cfg['gloves'] else 'domingo')/(key+'.md3');baseline=reference.read_bytes()
        h=struct.unpack_from('<4sI64s9I',blob);s=struct.unpack_from('<4s64s10I',blob,h[10]);old_h=struct.unpack_from('<4sI64s9I',baseline);old_s=struct.unpack_from('<4s64s10I',baseline,old_h[10])
        assert h[4:7]==old_h[4:7] and s[5:7]==old_s[5:7] and len(blob)==len(baseline),key+' evaluated topology/count changed'
        assert blob[h[10]+s[9]:h[10]+s[10]]==baseline[old_h[10]+old_s[9]:old_h[10]+old_s[10]],key+' UV changed'
        if not key.endswith('_hand'):
            assert blob[h[10]+s[7]:h[10]+s[8]]==baseline[old_h[10]+old_s[7]:old_h[10]+old_s[8]],key+' topology changed'
        native_references[reference.relative_to(ROOT).as_posix()]=digest(reference)
    report={'schema_revision':1,'issue':859,'source_sha256':digest(source),'config_sha256':digest(ART/'DESIGN.json'),'generator_sha256':digest(Path(__file__)),'frames':len(frames),'actions':len(design['export_actions']),'modules':{k:{'vertices':len(v['uv']),'triangles':len(v['triangles'])} for k,v in modules.items()},'native_reference_sha256':native_references,'evaluated_counts_bytes_and_uv_preserved':True,'quantized_wrist_checks':seam_checks,'rigid_grip_vertex_checks':rigid_grip_checks,'max_fitted_center_error':max_center_error,'pose_bounds':frame_bounds,'sha256':{n:hashlib.sha256(b).hexdigest() for n,b in files.items()}}
    for name,blob in files.items():
        path=out/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
        if args.install:
            path=ROOT/'src'/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(blob)
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    with zipfile.ZipFile(out/'preview.pk3','w') as archive:
        for name,blob in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),blob)
    if args.install:(ART/'EXPORT.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:report[k] for k in ['frames','actions','modules','quantized_wrist_checks','rigid_grip_vertex_checks','max_fitted_center_error']}))

if __name__=='__main__':main()
