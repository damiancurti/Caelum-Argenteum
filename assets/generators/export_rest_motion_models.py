"""Bake meal gestures from retained rigs; preserve source topology, UVs and owners.

Run with the pinned Blender 4.5.3. The original .blend files and runtime models
are read-only. New short clips occupy a separate model directory.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import sys
import bpy
from mathutils import Vector

ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/rest_motion_460'
sys.path.insert(0,str(Path(__file__).parent))
from export_character_modules import write_md3

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def quantize(p):return tuple(round(c*64) for c in p)
def pack_normal(n):
    return ((round(math.atan2(n.y,n.x)*128/math.pi)&255)<<8)|(round(math.acos(max(-1,min(1,n.z)))*128/math.pi)&255)
def unpack_normal(n):
    lat=(n>>8)*math.pi/128;lng=(n&255)*math.pi/128
    return Vector((math.cos(lat)*math.sin(lng),math.sin(lat)*math.sin(lng),math.cos(lng)))

def setup_pose(rig):
    target=bpy.data.objects.new('CA460 Wrist target',None)
    bpy.context.scene.collection.objects.link(target)
    ik=rig.pose.bones['forearm.R'].constraints.new('IK');ik.name='CA460 meal reach'
    ik.target=target;ik.chain_count=2;ik.use_stretch=False;ik.influence=0
    return target,ik

def pose(scene,rig,action,frame,sample,count,mode,config,driver):
    target,ik=driver;ik.influence=0
    rig.animation_data.action=bpy.data.actions[action];scene.frame_set(frame)
    bpy.context.view_layer.update()
    weight=math.sin(math.pi*sample/count)**2
    head=rig.pose.bones['head'];bone=rig.data.bones['head']
    local=bone.matrix_local.to_3x3().inverted()@Vector(config['wrist_target_from_head'][mode])
    target.location=rig.matrix_world@(head.head+head.matrix.to_3x3()@local)
    ik.influence=weight
    bpy.context.view_layer.update()
    return bpy.context.evaluated_depsgraph_get()

def load_family(family):
    if family=='base':
        cfg=read(ROOT/'assets/source/art/character_modules_458/MODULES.json')
        source=ROOT/cfg['source_blend'];groups=cfg['groups'];path='domingo';author=None
    elif family=='body':
        cfg=read(ROOT/'assets/source/art/underbody_827/DESIGN.json')
        source=ROOT/'assets/source/art/underbody_827/underbody.blend'
        groups={k:[v] for k,v in cfg['modules'].items()};path='domingo';author=None
    elif family=='worn':
        cfg=read(ROOT/'assets/source/art/worn_clothing_829/DESIGN.json')
        source=ROOT/'assets/source/art/worn_clothing_829/wardrobe.blend';author=read(source.with_name('AUTHORING.json'))
        assert digest(source)==author['editable_sha256']
        groups={k:[row['object'] for row in rows] for k,rows in author['modules'].items()};path='worn'
    else:
        cfg=read(ROOT/'assets/source/art/grips_859/DESIGN.json')
        source=ROOT/'assets/source/art/grips_859/grips.blend';author=read(source.with_name('AUTHORING.json'))
        assert digest(source)==author['editable_sha256']
        groups=author['modules'];path='grips'
    bpy.ops.wm.open_mainfile(filepath=str(source))
    return source,groups,path,author

def export_family(family,mode,out,config,frames,body_frames):
    source,groups,path,author=load_family(family)
    scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='POSE'
    driver=setup_pose(rig)
    modules={k:{'uv':[],'triangles':[],'poses':[],'headers':[]} for k in groups}
    mappings={};triangles={};skin_sources={};skins={};bounds=[];seam_checks=0
    base_graph=pose(scene,rig,*frames[0],0,config['samples_per_pose'],mode,config,driver)
    for key,names in groups.items():
        module=modules[key]
        skins[key]='domingo_skin.png'
        for name in names:
            obj=bpy.data.objects[name];evaluated=obj.evaluated_get(base_graph);mesh=evaluated.to_mesh();mesh.calc_loop_triangles()
            triangles[name]=[tuple(t.vertices) for t in mesh.loop_triangles]
            if family=='worn':skins[key]=obj['texture']
            if family=='grips' and key in ['GF','GC','GW','GP']:skins[key]=key.lower()+'.png'
            if family=='body':
                uv={}
                for poly in mesh.polygons:
                    for loop in poly.loop_indices:
                        u,v=mesh.uv_layers.active.data[loop].uv;uv[mesh.loops[loop].vertex_index]=(u,1-v)
                module['uv']=[uv[i] for i in range(len(mesh.vertices))]
                module['triangles']=[list(t.vertices) for t in mesh.loop_triangles]
                mappings[name]=list(range(len(mesh.vertices)))
            else:
                lookup={};indices=[]
                for tri in mesh.loop_triangles:
                    face=[]
                    for loop in tri.loops:
                        vertex=mesh.loops[loop].vertex_index;uv=tuple(mesh.uv_layers.active.data[loop].uv);pair=(vertex,uv)
                        if pair not in lookup:
                            lookup[pair]=len(module['uv']);module['uv'].append((uv[0],1-uv[1]));indices.append(vertex)
                        face.append(lookup[pair])
                    module['triangles'].append(face)
                mappings[name]=indices
            if family=='worn' and key.startswith('base_'):
                skin_sources[name]=[(tuple(obj.data.attributes['CA829Source'+n].data[i].value for n in ['A','B','C']),tuple(obj.data.attributes['CA829SourceBary'].data[i].vector)) for i in range(len(obj.data.vertices))]
            evaluated.to_mesh_clear()
    seam_pairs=[]
    if family=='body':
        rest={k:{tuple(round(c,5) for c in v.co):v.index for v in bpy.data.objects[names[0]].data.vertices} for k,names in groups.items()}
        for hand in ['left_hand','right_hand']:
            seam_pairs.extend((rest['underbody'][p],hand,rest[hand][p]) for p in sorted(set(rest['underbody'])&set(rest[hand])))
    for number,(action,frame) in enumerate(frames):
        sample=number%config['samples_per_pose']
        graph=pose(scene,rig,action,frame,sample,config['samples_per_pose'],mode,config,driver)
        native=body_frames[number] if family!='body' and body_frames else None
        transforms={}
        if family=='grips':
            for side,letter,equipment in [('Left','L','shield'),('Right','R','sword')]:
                hand=rig.pose.bones['hand.'+letter].matrix@rig.data.bones['hand.'+letter].matrix_local.inverted()
                item=rig.pose.bones[equipment].matrix@rig.data.bones[equipment].matrix_local.inverted()
                center=Vector(author['hands'][side]['fitted_center']);transforms[side]=(item,hand@center-item@center)
        posed={}
        for key,names in groups.items():
            points=[];normals=[]
            for name in names:
                obj=bpy.data.objects[name];evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh()
                matrix=evaluated.matrix_world;normal_matrix=matrix.to_3x3().inverted().transposed()
                full_points=[matrix@v.co for v in mesh.vertices]
                full_normals=[(normal_matrix@v.normal).normalized() for v in mesh.vertices]
                evaluated.to_mesh_clear()
                if family=='grips':
                    side=obj['CA859Side'];item,offset=transforms[side]
                    if obj['CA859Role']=='item':full_points=[p+offset for p in full_points]
                    else:
                        weights=obj.data.attributes['CA859AttachWeight']
                        full_points=[p.lerp(item@obj.data.vertices[i].co+offset,weights.data[i].value) for i,p in enumerate(full_points)]
                        if key.endswith('_hand'):
                            for i,j in author['hands'][side]['seams'].items():
                                assert quantize(full_points[int(i)])==quantize(native['points'][j]),f'{mode}:{action}:{frame}:{key} wrist'
                                seam_checks+=1
                    full_normals=[Vector() for p in full_points]
                    for a,b,c in triangles[name]:
                        normal=(full_points[b]-full_points[a]).cross(full_points[c]-full_points[a])
                        for i in [a,b,c]:full_normals[i]+=normal
                    full_normals=[n.normalized() for n in full_normals]
                for i in mappings[name]:
                    if name in skin_sources:
                        indices,weights=skin_sources[name][i]
                        point=sum((native['points'][j]*w for j,w in zip(indices,weights)),Vector())
                        normal=sum((native['normals'][j]*w for j,w in zip(indices,weights)),Vector()).normalized()
                    else:point,normal=full_points[i],full_normals[i]
                    points.append(point);normals.append(normal)
            posed[key]=(points,normals)
        if family=='body':
            for i,hand,j in seam_pairs:
                assert quantize(posed['underbody'][0][i])==quantize(posed[hand][0][j])
                normal=(posed['underbody'][1][i]+posed[hand][1][j]).normalized()
                posed['underbody'][1][i]=normal;posed[hand][1][j]=normal;seam_checks+=1
            points,normals=posed['underbody']
            body_frames.append({'points':[Vector(tuple(c/64 for c in quantize(p))) for p in points],
                                'normals':[unpack_normal(pack_normal(n)) for n in normals]})
        frame_bounds={}
        for key,module in modules.items():
            points,normals=posed[key];packed=bytearray()
            for point,normal in zip(points,normals):
                xyz=quantize(point);assert all(-32768<=c<=32767 for c in xyz)
                packed.extend(struct.pack('<3hH',*xyz,pack_normal(normal)))
            low=[min(p[a] for p in points) for a in range(3)];high=[max(p[a] for p in points) for a in range(3)]
            module['poses'].append(bytes(packed));module['headers'].append(struct.pack('<10f16s',*low,*high,0,0,0,max(p.length for p in points),('f%04d'%number).encode().ljust(16,b'\0')))
            frame_bounds[key]=[low,high]
        bounds.append({'action':action,'frame':frame,'modules':frame_bounds})
    hashes={}
    for key,module in modules.items():
        relative=f'models/caelum/characters/rest_motion/{mode}/{path}/{key}.md3'
        blob=write_md3(key,module,frames,skins[key]);target=out/relative;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(blob)
        hashes[relative]=hashlib.sha256(blob).hexdigest()
    return {'family':family,'mode':mode,'source':source.relative_to(ROOT).as_posix(),'source_sha256':digest(source),
            'frames':len(frames),'modules':{k:{'vertices':len(v['uv']),'triangles':len(v['triangles'])} for k,v in modules.items()},
            'wrist_checks':seam_checks,'bounds':bounds,'sha256':hashes}

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    assert bpy.app.version==(4,5,3)
    config=read(ART/'MEAL_POSES.json')
    frames=[(action,frame) for action in config['base_actions'] for frame in config['source_frames']]
    report={'issue':460,'config_sha256':digest(ART/'MEAL_POSES.json'),'generator_sha256':digest(Path(__file__)),'families':[]}
    for mode in ['eat','drink']:
        body=[]
        for family in ['body','base','worn','grips']:
            record=export_family(family,mode,out,config,frames,body)
            report['families'].append(record)
            (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
            print(json.dumps({'family':family,'mode':mode,'frames':record['frames'],'modules':len(record['modules']),'wrist_checks':record['wrist_checks']}),flush=True)

if __name__=='__main__':main()
