"""Private skeleton-based grip study using retained CC0 finger landmarks."""
import bpy,json,math,sys,runpy
from pathlib import Path
from mathutils import Vector,Quaternion,Matrix
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue859-grip-study02';out.mkdir(exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(root/'assets/source/art/underbody_827/underbody.blend'))
rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='REST'
landmarks=json.loads((root/'build/issue859-inspect01/landmarks.json').read_text())
def smooth(t):
 t=max(0,min(1,t));return t*t*(3-2*t)
for side,sign,letter in [('Left',1,'L'),('Right',-1,'R')]:
 original=bpy.data.objects['CA827 '+side+' hand'];obj=bpy.data.objects.new('CA859 deformation '+side,original.data.copy());bpy.context.scene.collection.objects.link(obj)
 data=bpy.data.armatures.new('CA859 fingers '+side);helper=bpy.data.objects.new(data.name,data);bpy.context.scene.collection.objects.link(helper)
 bpy.ops.object.select_all(action='DESELECT');helper.select_set(True);bpy.context.view_layer.objects.active=helper;bpy.ops.object.mode_set(mode='EDIT')
 forearm=data.edit_bones.new('wrist');forearm.head=(1,sign*27,111);forearm.tail=(3,sign*29,90)
 palm=data.edit_bones.new('palm');palm.head=forearm.tail;palm.tail=(6,sign*29,82);palm.parent=forearm
 for finger in range(1,6):
  for segment in range(1,4):
   bone=data.edit_bones.new(f'f{finger}.{segment}');bone.head=landmarks[letter][f'joint-{letter.lower()}-finger-{finger}-{segment}'];bone.tail=landmarks[letter][f'joint-{letter.lower()}-finger-{finger}-{segment+1}'];bone.parent=data.edit_bones['palm' if segment==1 else f'f{finger}.{segment-1}']
 bpy.ops.object.mode_set(mode='OBJECT');obj.select_set(True);bpy.ops.object.parent_set(type='ARMATURE_AUTO')
 for finger in range(1,6):
  for segment in range(1,4):
   bone=helper.pose.bones[f'f{finger}.{segment}'];axis=bone.bone.matrix_local.to_3x3().inverted()@Vector((1,0,0));angle=([55,70,55] if finger>1 else [-45,-15,0])[segment-1]*(-sign)
   bone.rotation_mode='QUATERNION';bone.rotation_quaternion=Quaternion(axis,math.radians(angle))
 bpy.context.view_layer.update();ev=obj.evaluated_get(bpy.context.evaluated_depsgraph_get());mesh=ev.to_mesh();closed=[v.co.copy() for v in mesh.vertices];ev.to_mesh_clear()
 # Native handle centers/orientation; preserve the exact original wrist seam.
 center=Vector((5.5,sign*26.8,82.3));target=Vector((5,29,87)) if side=='Left' else Vector((5.5,-28,89))
 rotation=Matrix.Identity(3) if side=='Left' else Vector((1,0,0)).rotation_difference(Vector((-6,14,75)).normalized()).to_matrix()
 for vert,point in zip(original.data.vertices,closed):
  before=vert.co.copy();fit=target+rotation@(point-center);mix=smooth((90-before.z-.8)/3.5);vert.co=before.lerp(fit,mix)
 original.data.update();obj.hide_render=True;obj.hide_viewport=True
 # Save the diagnostic helper, but disable its renderable construction copy.
for obj in bpy.data.objects:
 if obj.type!='MESH':continue
 obj.hide_render=True
 for slot in obj.material_slots:
  if slot.material:
   slot.material=slot.material.copy();slot.material.use_nodes=True;bs=slot.material.node_tree.nodes.get('Principled BSDF')
   if bs:
    for link in list(slot.material.node_tree.links):
     if link.to_node==bs:slot.material.node_tree.links.remove(link)
    bs.inputs['Base Color'].default_value=(.55,.3,.18,1) if obj.name.startswith('CA827') else (.15,.2,.25,1)
scene=bpy.context.scene;scene.render.engine='BLENDER_EEVEE_NEXT';scene.render.resolution_x=768;scene.render.resolution_y=768;scene.render.resolution_percentage=100
scene.world.color=(.3,.3,.3);scene.render.image_settings.file_format='PNG';scene.render.film_transparent=False
for o in scene.objects:
 if o.type=='LIGHT':o.hide_render=True
for pos in [(40,-30,140),(0,60,120),(-30,0,110)]:
 data=bpy.data.lights.new('CA859 inspection light','AREA');data.energy=35000;data.shape='DISK';data.size=40
 o=bpy.data.objects.new(data.name,data);scene.collection.objects.link(o);o.location=pos;o.rotation_euler=(Vector((5,0,88))-o.location).to_track_quat('-Z','Y').to_euler()
data=bpy.data.cameras.new('CA859 inspection camera');camera=bpy.data.objects.new(data.name,data);scene.collection.objects.link(camera);scene.camera=camera;data.type='ORTHO';data.ortho_scale=22
for side,y in [('Right',-29),('Left',29)]:
 for obj in scene.objects:
  if obj.type=='MESH':obj.hide_render=not (obj.name=='CA827 '+side+' hand' or (('sword' in obj.name.lower()) if side=='Right' else ('shield' in obj.name.lower())))
 target=Vector((5,y,88))
 for label,delta in [('front',(70,0,10)),('rear',(-70,0,10)),('inside',(0,70 if side=='Right' else -70,10))]:
  camera.location=target+Vector(delta);camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler();scene.render.filepath=str(out/(side.lower()+'-'+label+'.png'));bpy.ops.render.render(write_still=True)
bpy.ops.wm.save_as_mainfile(filepath=str(out/'study.blend'),compress=True)
