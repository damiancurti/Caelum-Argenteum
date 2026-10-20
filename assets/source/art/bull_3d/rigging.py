"""Blender 4.5.3 quadruped rig/animation authoring transcript for issue #369.

The frozen editable .blend is the runtime export input. This transcript records
the artistic construction, not byte-identical Blender serialization.
"""
import argparse
import json
import math
import sys
from pathlib import Path
import bpy
from mathutils import Vector, Quaternion

HERE=Path(__file__).resolve().parent

def clamp(value):return max(0,min(1,value))

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args(sys.argv[sys.argv.index('--')+1:])
    if bpy.app.version!=(4,5,3):raise RuntimeError('Use Blender 4.5.3.')
    out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    config=json.loads((HERE/'DESIGN.json').read_text(encoding='utf-8'));data=config['rig'];motion=config['motion']
    bpy.ops.wm.open_mainfile(filepath=str(args.source.resolve()))
    scene=bpy.context.scene;mesh=bpy.data.objects['Bull_surface']
    mesh.vertex_groups.clear()
    armature=bpy.data.armatures.new('Bull quadruped skeleton');rig=bpy.data.objects.new('Bull_Rig',armature);scene.collection.objects.link(rig)
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);bpy.context.view_layer.objects.active=rig;bpy.ops.object.mode_set(mode='EDIT')
    def bone(name,head,tail,parent=None,deform=True):
        b=armature.edit_bones.new(name);b.head=head;b.tail=tail;b.use_deform=deform
        if parent:b.parent=armature.edit_bones[parent]
        return b
    bone('Root',data['root'],Vector(data['root'])+Vector((.12,0,0)),deform=False)
    bone('Pelvis',data['pelvis'],(-.08,0,.37),'Root')
    bone('Chest',(-.08,0,.37),data['chest'],'Root')
    bone('Neck',data['neck'],data['head'],'Chest')
    bone('Head',data['head'],data['muzzle'],'Neck')
    bone('Tail_base',data['tail_base'],data['tail_mid'],'Pelvis')
    bone('Tail_tip',data['tail_mid'],data['tail_tip'],'Tail_base')
    for name,leg in data['legs'].items():
        parent='Chest' if name.startswith('Front') else 'Pelvis'
        bone(name+'_upper',leg['hip'],leg['knee'],parent)
        bone(name+'_lower',leg['knee'],leg['foot'],name+'_upper')
        end=Vector(leg['foot'])+Vector((.05,0,0))
        bone(name+'_hoof',leg['foot'],end,name+'_lower')
        bone(name+'_target',leg['foot'],end,deform=False)
    bpy.ops.object.mode_set(mode='OBJECT');rig.show_in_front=True
    for name,leg in data['legs'].items():
        lower=rig.pose.bones[name+'_lower'];ik=lower.constraints.new('IK');ik.target=rig;ik.subtarget=name+'_target';ik.chain_count=2;ik.use_stretch=False;ik.iterations=64
        rig.pose.bones[name+'_upper'].ik_stretch=0;lower.ik_stretch=0
        lock=rig.pose.bones[name+'_hoof'].constraints.new('COPY_ROTATION');lock.target=rig;lock.subtarget=name+'_target';lock.owner_space='WORLD';lock.target_space='WORLD'
    for b in armature.bones:
        if b.use_deform:mesh.vertex_groups.new(name=b.name)
    regions=mesh.data.attributes['bake_region']
    detail_vertices=set()
    for face in mesh.data.polygons:
        if regions.data[face.index].value:detail_vertices.update(face.vertices)
    for vertex in mesh.data.vertices:
        x,y,z=vertex.co;chest=clamp((x+.23)/.35)
        weights={'Pelvis':1-chest,'Chest':chest}
        if x<-.34 and z<.36:
            tail=clamp((-.34-x)/.06);tip=clamp((.29-z)/.15)
            weights={k:v*(1-tail) for k,v in weights.items()};weights.update(Tail_base=tail*(1-tip),Tail_tip=tail*tip)
        elif z<.31 and (x<-.04 or .065<x<.30):
            group='Front' if x>0 else 'Hind'
            name=min((n for n in data['legs'] if n.startswith(group)),key=lambda n:abs(y-data['legs'][n]['foot'][1]))
            leg=data['legs'][name];influence=clamp((leg['hip'][2]-z)/.10)
            if abs(y-leg['foot'][1])>.10:influence*=clamp((.16-abs(y-leg['foot'][1]))/.06)
            middle=sum(data['legs'][n]['foot'][1] for n in data['legs'] if n.startswith(group))/2
            central=clamp((abs(y-middle)-.025)/.045);blend=clamp((z-.07)/.04)
            influence*=1-blend+blend*central
            weights={k:v*(1-influence) for k,v in weights.items()}
            upper=clamp((z-.12)/.10);hoof=clamp((.075-z)/.045)*(1-upper)
            weights[name+'_upper']=influence*upper;weights[name+'_hoof']=influence*hoof;weights[name+'_lower']=influence*(1-upper-hoof)
        head=clamp((x-.13)/.15)*clamp((z-.20)/.10)
        if vertex.index in detail_vertices:head=1
        weights={k:v*(1-head) for k,v in weights.items()};weights['Head']=head
        weights={k:v for k,v in weights.items() if v>.00001}
        total=sum(weights.values())
        for name,value in weights.items():mesh.vertex_groups[name].add([vertex.index],value/total,'REPLACE')
    modifier=mesh.modifiers.new('Quadruped skin','ARMATURE');modifier.object=rig;modifier.use_deform_preserve_volume=True
    mesh.parent=rig
    # Smooth painted weights along mesh edges, keeping rigid details and the
    # distal hoof cores. Automatic bone-heat skinning fails on this source.
    neighbors=[set() for vertex in mesh.data.vertices]
    for edge in mesh.data.edges:
        a,b=edge.vertices;neighbors[a].add(b);neighbors[b].add(a)
    painted=[{group.group:group.weight for group in vertex.groups} for vertex in mesh.data.vertices]
    for iteration in range(12):
        refined=[]
        for index,weights in enumerate(painted):
            if index in detail_vertices or mesh.data.vertices[index].co.z<.065 or not neighbors[index]:refined.append(weights);continue
            result={key:value*.5 for key,value in weights.items()}
            for other in neighbors[index]:
                for key,value in painted[other].items():result[key]=result.get(key,0)+value*.5/len(neighbors[index])
            refined.append(result)
        painted=refined
    for vertex,weights in zip(mesh.data.vertices,painted):
        for group in mesh.vertex_groups:group.remove([vertex.index])
        weights=dict(sorted(weights.items(),key=lambda item:-item[1])[:4]);total=sum(weights.values())
        for group,weight in weights.items():mesh.vertex_groups[group].add([vertex.index],weight/total,'REPLACE')
    for pb in rig.pose.bones:pb.rotation_mode='QUATERNION'
    def translate(name,delta):
        pb=rig.pose.bones[name];pb.location=armature.bones[name].matrix_local.to_3x3().inverted()@Vector(delta)
    def rotate(name,axis,angle):
        local=armature.bones[name].matrix_local.to_3x3().inverted()@Vector(axis)
        rig.pose.bones[name].rotation_quaternion=Quaternion(local,angle)
    def key(frame):
        for pb in rig.pose.bones:
            pb.keyframe_insert(data_path='location',frame=frame);pb.keyframe_insert(data_path='rotation_quaternion',frame=frame);pb.keyframe_insert(data_path='scale',frame=frame)
    export_actions={};summary={}
    # The native cylinder remains authoritative. Only the art is scaled once.
    floor=min(v.co.z for v in mesh.data.vertices);height=max(v.co.z for v in mesh.data.vertices)-floor
    scale=config['orientation']['height_mu']/height
    for action_name,options in config['actions'].items():
        action=bpy.data.actions.new(action_name);action.use_fake_user=True;rig.animation_data_create();rig.animation_data.action=action
        duration=options['tics'];count=options['samples'];loop=options['loop']
        sample_tics=[round(i*duration/count) for i in range(count)] if loop else [round(i*(duration-1)/max(1,count-1)) for i in range(count)]
        export_actions[action_name]=dict(options,frames=sample_tics,sample_tics=sample_tics)
        for frame in range(duration+1):
            phase=frame/max(1,duration);a=math.tau*phase
            for pb in rig.pose.bones:pb.location=(0,0,0);pb.rotation_quaternion=(1,0,0,0);pb.scale=(1,1,1)
            # The original rear hooves sit slightly above the front pair.
            for name in data['legs']:translate(name+'_target',(0,0,-.018 if name.startswith('Hind') else -floor))
            translate('Root',(0,0,-floor))
            rotate('Tail_base',(0,0,1),.055*math.sin(a));rotate('Tail_tip',(0,1,0),.045*math.sin(a+.5))
            if action_name in ('Idle','Stun'):
                rig.pose.bones['Chest'].scale=(1,1+motion['body_breath']*math.sin(a),1+motion['body_breath']*math.sin(a))
                rotate('Head',(0,1,0),.012*math.sin(a))
                if action_name=='Stun':rotate('Head',(0,0,1),.07*math.sin(a*2))
            if action_name in ('Walk','Run','Charge'):
                running=action_name!='Walk';stride=motion['run_stride_mu' if running else 'walk_stride_mu']/scale
                stance=motion['run_stance' if running else 'walk_stance'];lift=motion['run_lift' if running else 'walk_lift']
                offsets={'Front_L':.25,'Hind_R':.5,'Front_R':.75,'Hind_L':0} if not running else {'Hind_L':0,'Hind_R':.08,'Front_L':.48,'Front_R':.56}
                bob=(.012 if running else .004)*math.sin(2*a)
                translate('Root',(0,0,-floor+bob-(.045 if running else .025)))
                rotate('Chest',(0,1,0),(.026 if running else .007)*math.sin(a))
                for name in data['legs']:
                    p=(phase+offsets[name])%1
                    if p<stance:dx=stride*stance*(.5-p/stance);dz=0
                    else:
                        t=(p-stance)/(1-stance);dx=stride*stance*(-.5+t);dz=lift*math.sin(math.pi*t)
                    translate(name+'_target',(dx,0,dz-(.018 if name.startswith('Hind') else floor)))
                rotate('Head',(0,1,0),.18 if action_name=='Charge' else .02*math.sin(a))
            if action_name.startswith('Prepare'):
                t=min(1,phase*1.25);rotate('Head',(0,1,0),.20*t);rotate('Neck',(0,1,0),.04*t)
                translate('Root',(-.014*t,0,-floor-.015*t))
            if action_name=='Gore':rotate('Head',(0,1,0),.22-.42*math.sin(math.pi*min(1,phase)))
            if action_name=='Pain':
                recoil=math.sin(math.pi*min(1,phase));translate('Root',(-.025*recoil,0,-floor));rotate('Head',(0,0,1),-.09*recoil)
            if action_name=='Rest':
                translate('Root',(0,0,-.18-floor));rotate('Head',(0,1,0),.10)
                for name in data['legs']:translate(name+'_target',(-.045 if name.startswith('Front') else .045,0,-.018))
                rig.pose.bones['Chest'].scale=(1,1+motion['body_breath']*math.sin(a),1)
            if action_name in ('Death','Corpse'):
                t=1 if action_name=='Corpse' else min(1,frame/max(1,duration-1));ease=t*t*(3-2*t)
                rotate('Root',(1,0,0),math.radians(motion['death_roll_degrees'])*ease)
                translate('Root',(0,0,-floor-motion['death_drop']*ease))
                rotate('Head',(0,1,0),-.12*ease)
                # Follow the roll rather than leaving IK feet pinned upright.
                for name,leg in data['legs'].items():
                    point=Vector(leg['foot']);pivot=Vector(data['root']);rolled=Quaternion(Vector((1,0,0)),math.radians(motion['death_roll_degrees'])*ease)@(point-pivot)+pivot
                    delta=rolled-point+Vector((0,0,-floor-motion['death_drop']*ease));translate(name+'_target',delta)
                    rotate(name+'_target',(1,0,0),math.radians(motion['death_roll_degrees'])*ease)
            if action_name in ('Death','Corpse','Rest'):
                bpy.context.view_layer.update()
                evaluated=mesh.evaluated_get(bpy.context.evaluated_depsgraph_get());sample=evaluated.to_mesh();bottom=min(v.co.z for v in sample.vertices);evaluated.to_mesh_clear()
                for name in ['Root']+[leg+'_target' for leg in data['legs']]:
                    pb=rig.pose.bones[name];pb.location+=armature.bones[name].matrix_local.to_3x3().inverted()@Vector((0,0,-bottom))
            key(frame)
        summary[action_name]={'keyframes':duration+1,'samples':len(sample_tics)}
    config['export_actions']=export_actions
    config['export_transform']={'scale':scale,'floor':floor}
    # Floor correction is baked into art poses, never actor collision.
    rig.animation_data.action=bpy.data.actions['Idle'];scene.frame_set(0)
    mesh.hide_set(False);mesh.hide_render=False
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);bpy.context.view_layer.objects.active=rig
    bpy.ops.wm.save_as_mainfile(filepath=str(out/'bull.blend'))
    (out/'DESIGN.json').write_text(json.dumps(config,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    (out/'rig-report.json').write_text(json.dumps({'bones':len(armature.bones),'vertices':len(mesh.data.vertices),'actions':summary,'scale':scale},indent=2)+'\n')
    camera=scene.camera;center=Vector((0,0,.28));camera.location=center+Vector((2,-3,1.1));camera.rotation_euler=(center-camera.location).to_track_quat('-Z','Y').to_euler()
    for name,frame in [('Idle',0),('Walk',8),('Run',4),('Charge',4),('Death',25),('Rest',20)]:
        rig.animation_data.action=bpy.data.actions[name];scene.frame_set(frame);scene.render.filepath=str(out/(name+'.png'));bpy.ops.render.render(write_still=True)
    print('CA369 RIG',json.dumps(summary))

if __name__=='__main__':main()
