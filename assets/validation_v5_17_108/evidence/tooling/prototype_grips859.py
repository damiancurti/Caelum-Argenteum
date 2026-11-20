"""Private geometric grip study; preserve all retained source files."""
import bpy,json,math,sys
from pathlib import Path
from mathutils import Vector
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');out=root/'build/issue859-grip-study01';out.mkdir(exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(root/'assets/source/art/underbody_827/underbody.blend'))
rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='REST'
report={}
def smooth(t):
 t=max(0,min(1,t));return t*t*(3-2*t)
for side,sign in [('Left',1),('Right',-1)]:
 obj=bpy.data.objects['CA827 '+side+' hand'];before=[v.co.copy() for v in obj.data.vertices]
 for vert in obj.data.vertices:
  p=vert.co.copy();u=p.x;v=sign*p.y;w=90-p.z
  center=31.5-.42*u;offset=v-center;thumb=smooth((26.5-v)/2.5)*smooth((u-6)/2)
  if w>8:
   theta=(w-8)/2.4;radius=2.7+offset
   vv=29+radius*math.cos(theta);ww=3+radius*math.sin(theta)
  else:
   t=smooth((w-2)/6);vv=v+(31.7+offset-v)*t;ww=w*.375
  tv=26.5+1.5*smooth((26.5-v)/5);tw=(w*.5)*(1-smooth((26.5-v)/5))+2.8*smooth((26.5-v)/5)
  vv=vv*(1-thumb)+tv*thumb;ww=ww*(1-thumb)+tw*thumb;uu=u-thumb
  if side=='Left':target=Vector((uu,vv,90-ww))
  else:
   a=Vector((6,-14,-75)).normalized();b=Vector((0,-1,0));b=(b-a*b.dot(a)).normalized();c=a.cross(b)
   target=Vector((5.5,-28,89))+a*(uu-5.5)+b*(vv-29)+c*(ww-3)
  mix=smooth((w-.8)/2.5);vert.co=p.lerp(target,mix)
 obj.data.update();report[side]={'changed':sum((v.co-p).length>1e-6 for v,p in zip(obj.data.vertices,before))}
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
  camera.location=target+Vector(delta);camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
  scene.render.filepath=str(out/(side.lower()+'-'+label+'.png'));bpy.ops.render.render(write_still=True)
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n');bpy.ops.wm.save_as_mainfile(filepath=str(out/'study.blend'),compress=True)
