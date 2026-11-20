"""Author closed grip variants from retained anatomy and finger landmarks.

Pinned Blender 4.5.3; numeric visual fitting choices live in DESIGN.json.
The editable container is retained; deterministic exports are checked separately.
"""
from pathlib import Path
import argparse,hashlib,json,math,sys
import bpy,bmesh
from mathutils import Vector,Matrix,Quaternion
ROOT=Path(__file__).resolve().parents[2]
ART=ROOT/'assets/source/art/grips_859'
sys.path.insert(0,str(Path(__file__).parent))
from author_underbody import load_obj

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def smooth(value):
    value=max(0,min(1,value));return value*value*(3-2*value)
def key(point):return tuple(round(c,5) for c in point)

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]);out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    assert bpy.app.version==(4,5,3)
    cfg=json.loads((ART/'DESIGN.json').read_text());anatomy=json.loads((ROOT/cfg['underbody_design']).read_text())
    for name,expected in cfg['source_sha256'].items():assert digest(ROOT/name)==expected,name
    vertices,groups=load_obj(ROOT/anatomy['source'])
    def point(name):
        ids=sorted({i for f in groups[name] for i in f});return sum((vertices[i] for i in ids),Vector())/len(ids)
    bpy.ops.wm.open_mainfile(filepath=str(ROOT/cfg['source']));scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='REST'
    glove_names=['CA829 '+kind+' '+side for kind in cfg['gloves'] for side in ['Left','Right']]
    with bpy.data.libraries.load(str(ROOT/cfg['wardrobe_source']),link=False) as (source,target):
        assert set(glove_names)<=set(source.objects);target.objects=glove_names
    for obj in target.objects:
        scene.collection.objects.link(obj)
        for modifier in obj.modifiers:
            if modifier.type=='ARMATURE':modifier.object=rig
    wardrobe=json.loads((ROOT/'assets/source/art/worn_clothing_829/DESIGN.json').read_text())
    membership=json.loads((ROOT/cfg['equipment_modules']).read_text())['groups']
    axes=Matrix(((0,0,1),(1,0,0),(0,1,0)));body=bpy.data.objects['CA827 Underbody']
    body_points={key(v.co):v.index for v in body.data.vertices};report={'issue':859,'modules':{},'hands':{},'source_sha256':cfg['source_sha256'],'config_sha256':digest(ART/'DESIGN.json')}
    for side,sign,letter in [('Left',1,'L'),('Right',-1,'R')]:
        original=bpy.data.objects['CA827 '+side+' hand'];rest=[v.co.copy() for v in original.data.vertices]
        seams={v.index:body_points[key(v.co)] for v in original.data.vertices if key(v.co) in body_points};assert len(seams)>=3
        start=point('joint-'+letter.lower()+'-hand');end=point('joint-'+letter.lower()+'-finger-3-1');native=rig.data.bones['hand.'+letter]
        direction=axes@(end-start);unit=direction.normalized();scale=anatomy['segment_fit']['hand.'+letter]['cross_section_scale'];stretch=Matrix.Identity(3)*scale
        for i in range(3):
            for j in range(3):stretch[i][j]+=(native.length/(end-start).length-scale)*unit[i]*unit[j]
        rotation=direction.rotation_difference(native.tail_local-native.head_local).to_matrix()
        transform=Matrix.Translation(native.head_local)@(rotation@stretch).to_4x4()@Matrix.Translation(-(axes@start))@axes.to_4x4()
        landmarks={f'{f}.{n}':transform@point(f'joint-{letter.lower()}-finger-{f}-{n}') for f in range(1,6) for n in range(1,5)}
        obj=bpy.data.objects.new('CA859 construction '+side,original.data.copy());scene.collection.objects.link(obj)
        for group in original.vertex_groups:obj.vertex_groups.new(name=group.name)
        obj.vertex_groups.clear()
        data=bpy.data.armatures.new('CA859 finger controls '+side);helper=bpy.data.objects.new(data.name,data);scene.collection.objects.link(helper)
        bpy.ops.object.select_all(action='DESELECT');helper.select_set(True);bpy.context.view_layer.objects.active=helper;bpy.ops.object.mode_set(mode='EDIT')
        forearm=data.edit_bones.new('wrist');forearm.head=rig.data.bones['forearm.'+letter].head_local;forearm.tail=native.head_local
        palm=data.edit_bones.new('palm');palm.head=native.head_local;palm.tail=native.tail_local;palm.parent=forearm
        for finger in range(1,6):
            for segment in range(1,4):
                bone=data.edit_bones.new(f'f{finger}.{segment}');bone.head=landmarks[f'{finger}.{segment}'];bone.tail=landmarks[f'{finger}.{segment+1}'];bone.parent=data.edit_bones['palm' if segment==1 else f'f{finger}.{segment-1}']
        bpy.ops.object.mode_set(mode='OBJECT');obj.select_set(True);bpy.ops.object.parent_set(type='ARMATURE_AUTO')
        targets_report={}
        for finger in range(1,6):
            radius=cfg['finger_radii'][side];sourcepoints=[landmarks[f'{finger}.{n}'] for n in range(1,5)]
            if finger==1:
                targets=[sourcepoints[0]]+[Vector((x,sign*(cfg['construction_center'][1]-radius if y is None else y),z)) for x,y,z in cfg['thumb_targets']]
            else:
                angle=0;targets=[]
                for n,pt in enumerate(sourcepoints):
                    if n:angle+=(pt-sourcepoints[n-1]).length/radius
                    targets.append(Vector((sourcepoints[0].x,sign*(cfg['construction_center'][1]+radius*math.cos(angle)),cfg['construction_center'][2]-radius*math.sin(angle))))
            targets_report[str(finger)]=[list(p) for p in targets]
            for segment in range(1,4):
                bone=helper.pose.bones[f'f{finger}.{segment}'];start,end=sourcepoints[segment-1:segment+1];dest,tip=targets[segment-1:segment+1]
                rotation=(end-start).rotation_difference(tip-dest).to_matrix().to_4x4();scale=Matrix.Diagonal((1,(tip-dest).length/(end-start).length,1,1))
                bone.matrix=Matrix.Translation(dest)@rotation@Matrix.Translation(-start)@bone.bone.matrix_local@scale;bpy.context.view_layer.update()
        ev=obj.evaluated_get(bpy.context.evaluated_depsgraph_get());mesh=ev.to_mesh();closed=[v.co.copy() for v in mesh.vertices];ev.to_mesh_clear()
        wrist=Vector(cfg['wrist_origin']);wrist.y*=sign
        rotation=Matrix.Identity(3) if side=='Left' else Quaternion(Vector(cfg['right_axis']).normalized(),math.radians(cfg['right_angle_degrees'])).to_matrix()
        attribute=original.data.attributes.new('CA859AttachWeight','FLOAT','POINT')
        for vert,old,closed_point in zip(original.data.vertices,rest,closed):
            mix=0 if vert.index in seams else smooth((cfg['attachment_blend_height']-old.z-cfg['attachment_blend_start'])/cfg['attachment_blend_length'])
            vert.co=old if vert.index in seams else old.lerp(wrist+rotation@(closed_point-wrist),mix)
            attribute.data[vert.index].value=mix
        original.data.update();original['CA859Side']=side;original['CA859Role']='hand';obj.hide_render=True;obj.hide_viewport=True
        fitcenter=Vector(cfg['construction_center']);fitcenter.y*=sign;fitcenter=wrist+rotation@(fitcenter-wrist)
        nativecenter=Vector(cfg['native_centers'][side]);equipment='shield' if side=='Left' else 'weapon'
        adjust=Matrix.Identity(3) if side=='Left' else Vector(cfg['native_sword_up']).normalized().rotation_difference(rotation@Vector((1,0,0))).to_matrix()
        for name in membership[equipment]:
            item=bpy.data.objects[name]
            for vert in item.data.vertices:vert.co=fitcenter+adjust@(vert.co-nativecenter)
            item.data.update();item['CA859Side']=side;item['CA859Role']='item'
        report['modules'][side.lower()+'_hand']=[original.name]
        report['modules'][equipment]=membership[equipment]
        for kind in cfg['gloves']:
            glove=bpy.data.objects['CA829 '+kind+' '+side];assert len(glove.data.vertices)==len(rest)
            glove_attribute=glove.data.attributes.new('CA859AttachWeight','FLOAT','POINT')
            for vertex,hand in zip(glove.data.vertices,original.data.vertices):
                vertex.co=hand.co+hand.normal*wardrobe['gloves'][kind]['offset'];glove_attribute.data[vertex.index].value=attribute.data[vertex.index].value
            glove.data.update();glove['CA859Side']=side;glove['CA859Role']='hand';report['modules'].setdefault(kind,[]).append(glove.name)
        report['hands'][side]={'seams':seams,'landmarks':{n:list(p) for n,p in landmarks.items()},'finger_targets':targets_report,'fitted_center':list(fitcenter),'vertices':len(rest),'faces':len(original.data.polygons)}
        assert all(key(original.data.vertices[i].co)==key(body.data.vertices[j].co) for i,j in seams.items())
    report['topology']={}
    for names in report['modules'].values():
        for name in names:
            obj=bpy.data.objects[name];mesh=bmesh.new();mesh.from_mesh(obj.data)
            if obj.get('CA859Role')=='hand':
                assert all(e.is_manifold for e in mesh.edges),name
                volume=mesh.calc_volume(signed=True);assert volume>0,name
                report['topology'][name]={'vertices':len(mesh.verts),'faces':len(mesh.faces),'nonmanifold_edges':0,'signed_volume':volume}
            mesh.free()
    selected={name for names in report['modules'].values() for name in names}
    for obj in scene.objects:
        if obj.type=='MESH':obj.hide_render=obj.name not in selected
    rig.data.pose_position='POSE';rig.animation_data.action=bpy.data.actions['IdleBreathing'];scene.frame_set(0)
    bpy.ops.wm.save_as_mainfile(filepath=str(out/'grips.blend'),compress=True)
    report['editable_sha256']=digest(out/'grips.blend');report['generator_sha256']=digest(Path(__file__))
    (out/'AUTHORING.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'modules':len(report['modules']),'hands':{s:{k:v for k,v in r.items() if k in ['vertices','faces','fitted_center']} for s,r in report['hands'].items()},'editable_sha256':report['editable_sha256']}))

if __name__=='__main__':main()
