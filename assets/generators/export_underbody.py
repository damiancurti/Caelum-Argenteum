"""Export three independent anatomy MD3 modules using accepted action samples."""
from pathlib import Path
import argparse,hashlib,json,math,struct,sys,zipfile
import bpy
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/underbody_827'
sys.path.insert(0,str(Path(__file__).parent))
from export_character_modules import write_md3

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,required=True);parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--install',action='store_true')
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);source=args.source.resolve(strict=True);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    cfg=json.loads((ART/'DESIGN.json').read_text());design=json.loads((ROOT/cfg['design']).read_text())
    assert digest(ROOT/cfg['accepted_rig'])==cfg['accepted_rig_sha256'] and digest(ROOT/cfg['skin'])==cfg['skin_sha256']
    bpy.ops.wm.open_mainfile(filepath=str(source));scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='POSE'
    modules={key:{'uv':[],'triangles':[],'poses':[],'headers':[]} for key in cfg['modules']}
    objects={key:bpy.data.objects[name] for key,name in cfg['modules'].items()}
    lookup={};rest={};closure={}
    for key,obj in objects.items():
        mesh=obj.data;mesh.calc_loop_triangles();edges={};volume=0
        for tri in mesh.loop_triangles:
            modules[key]['triangles'].append(list(tri.vertices))
            p=[mesh.vertices[i].co for i in tri.vertices];volume+=p[0].dot(p[1].cross(p[2]))/6
            for a,b in zip(tri.vertices,(*tri.vertices[1:],tri.vertices[0])):edges.setdefault(tuple(sorted((a,b))),[]).append((a,b))
        assert all(len(v)==2 and v[0]==v[1][::-1] for v in edges.values()),key+' closure/winding'
        assert volume>0,key+' inverted volume'
        neighbors={i:set() for i in range(len(mesh.vertices))}
        for a,b in edges:neighbors[a].add(b);neighbors[b].add(a)
        visited=set();pending=[0]
        while pending:
            vertex=pending.pop()
            if vertex in visited:continue
            visited.add(vertex);pending.extend(neighbors[vertex]-visited)
        assert len(visited)==len(mesh.vertices),key+' disconnected components'
        closure[key]={'closed_edges':len(edges),'rest_signed_volume':volume,'connected_components':1}
        uv={}
        for poly in mesh.polygons:
            for loop in poly.loop_indices:
                u,v=mesh.uv_layers.active.data[loop].uv;uv[mesh.loops[loop].vertex_index]=(u,1-v)
        modules[key]['uv']=[uv[v.index] for v in mesh.vertices]
        rest[key]={tuple(round(c,5) for c in v.co):v.index for v in mesh.vertices}
    seam_pairs=[]
    for hand in ['left_hand','right_hand']:
        common=sorted(set(rest['underbody'])&set(rest[hand]));assert len(common)>=3,hand+' absent wrist join'
        seam_pairs.extend((rest['underbody'][co],hand,rest[hand][co]) for co in common)
    frames=[(action,frame) for action,options in design['export_actions'].items() for frame in options['frames']]
    seam_checks=0;pose_bounds=[]
    for index,(action,frame) in enumerate(frames):
        rig.animation_data.action=bpy.data.actions[action];scene.frame_set(frame);graph=bpy.context.evaluated_depsgraph_get();posed={}
        for key,obj in objects.items():
            evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh();normal_matrix=evaluated.matrix_world.to_3x3().inverted().transposed()
            posed[key]={'points':[evaluated.matrix_world@v.co for v in mesh.vertices],
                        'normals':[(normal_matrix@v.normal).normalized() for v in mesh.vertices]}
            evaluated.to_mesh_clear()
        for body,hand,index_hand in seam_pairs:
            a=posed['underbody'];b=posed[hand]
            assert tuple(round(c*64) for c in a['points'][body])==tuple(round(c*64) for c in b['points'][index_hand]),f'Wrist split {action}:{frame}'
            normal=(a['normals'][body]+b['normals'][index_hand]).normalized();a['normals'][body]=normal;b['normals'][index_hand]=normal;seam_checks+=1
        bounds={}
        for key,module in modules.items():
            points=posed[key]['points'];packed=bytearray()
            for point,normal in zip(points,posed[key]['normals']):
                xyz=[round(c*64) for c in point];assert all(-32768<=c<=32767 for c in xyz)
                lat=round(math.atan2(normal.y,normal.x)*128/math.pi)&255;lng=round(math.acos(max(-1,min(1,normal.z)))*128/math.pi)&255
                packed.extend(struct.pack('<3hH',*xyz,(lat<<8)|lng))
            minimum=[min(p[i] for p in points) for i in range(3)];maximum=[max(p[i] for p in points) for i in range(3)]
            radius=max(p.length for p in points)
            module['headers'].append(struct.pack('<10f16s',*minimum,*maximum,0,0,0,radius,('f%04d'%index).encode().ljust(16,b'\0')));module['poses'].append(bytes(packed))
            bounds[key]=[minimum,maximum]
        pose_bounds.append({'action':action,'source_frame':frame,'bounds':bounds})
    path=cfg['module_path'];skin='domingo_skin.png'
    files={path+'/'+key+'.md3':write_md3(key,module,frames,skin) for key,module in modules.items()}
    definition=(ROOT/'src/caelum/data/domingo_modules.modeldef').read_text().replace('CaelumDomingoPilotBody',cfg['fixture_class'])
    # MODELDEF captures every current slot at each FrameIndex directive.
    # Declare all slots first, then complete every pose before advancing.
    definition=definition[:definition.index('    FrameIndex')]
    for slot,key in enumerate(modules,7):
        definition+=f'    Model {slot} "{key}.md3"\n    Skin {slot} "{skin}"\n'
    for number in range(len(frames)):
        for slot in range(7+len(modules)):
            definition+=f'    FrameIndex D3{number//26:02X} {chr(65+number%26)} {slot} {number}\n'
    files['MODELDEF']=(definition+'}\n').encode()
    report={'schema_revision':1,'issue':827,'source_sha256':digest(source),'config_sha256':digest(ART/'DESIGN.json'),'generator_sha256':digest(Path(__file__)),
     'authoring_generator_sha256':digest(Path(__file__).with_name('author_underbody.py')),
     'accepted_rig_sha256':digest(ROOT/cfg['accepted_rig']),'skin_sha256':digest(ROOT/cfg['skin']),'frames':len(frames),'actions':len(design['export_actions']),
     'modules':{key:{'vertices':len(v['uv']),'triangles':len(v['triangles']),**closure[key]} for key,v in modules.items()},
     'wrist_pairs':len(seam_pairs),'quantized_wrist_checks':seam_checks,'geometry_pose_bounds':pose_bounds,'sha256':{n:hashlib.sha256(b).hexdigest() for n,b in files.items()}}
    for name,blob in files.items():
        p=out/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(blob)
        if args.install and name!='MODELDEF':
            dest=ROOT/'src'/name;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(blob)
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    with zipfile.ZipFile(out/'preview.pk3','w') as archive:
        for n,b in sorted(files.items()):archive.writestr(zipfile.ZipInfo(n,(2026,11,16,0,0,0)),b)
    if args.install:
        (ART/'EXPORT.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:report[k] for k in ['frames','actions','modules','wrist_pairs','quantized_wrist_checks']}))

if __name__=='__main__':main()
