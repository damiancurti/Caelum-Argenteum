"""Inspect retained geometry without modifying source files."""
import bpy,json,sys
from pathlib import Path
from mathutils import Vector
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
out=root/'build/issue859-inspect01';out.mkdir(exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(root/'assets/source/art/underbody_827/underbody.blend'))
rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='REST'
report={}
for obj in bpy.data.objects:
 if obj.type!='MESH':continue
 if any(x in obj.name.lower() for x in ['hand','grip','sword','shield','gauntlet']):
  points=[obj.matrix_world@v.co for v in obj.data.vertices]
  report[obj.name]={'vertices':len(points),'bounds':[[min(p[i] for p in points) for i in range(3)],[max(p[i] for p in points) for i in range(3)]],'groups':[g.name for g in obj.vertex_groups],'parent':obj.parent.name if obj.parent else None}
  if obj.name.startswith('CA827 '):report[obj.name]['geometry']={'points':[list(p) for p in points],'faces':[list(f.vertices) for f in obj.data.polygons]}
 for slot in obj.material_slots:
  if slot.material:
   slot.material=slot.material.copy();slot.material.use_nodes=True
   bs=slot.material.node_tree.nodes.get('Principled BSDF')
   if bs:
    for link in list(slot.material.node_tree.links):
     if link.to_node==bs:slot.material.node_tree.links.remove(link)
    bs.inputs['Base Color'].default_value=(.55,.3,.18,1) if obj.name.startswith('CA827') else (.15,.2,.25,1)
 obj.hide_render=not (obj.name.startswith('CA827 ') and 'hand' in obj.name or any(x in obj.name.lower() for x in ['grip','sword','shield']))
(out/'geometry.json').write_text(json.dumps(report,indent=2)+'\n')
scene=bpy.context.scene;scene.render.engine='BLENDER_EEVEE_NEXT';scene.render.resolution_x=768;scene.render.resolution_y=768;scene.render.resolution_percentage=100
scene.world.color=(.3,.3,.3);scene.render.image_settings.file_format='PNG';scene.render.film_transparent=False
for o in scene.objects:
 if o.type=='LIGHT':o.hide_render=True
for pos in [(40,-30,140),(0,60,120),(-30,0,110)]:
 data=bpy.data.lights.new('CA859 inspection light','AREA');data.energy=35000;data.shape='DISK';data.size=40
 o=bpy.data.objects.new(data.name,data);scene.collection.objects.link(o);o.location=pos;o.rotation_euler=(Vector((5,0,88))-o.location).to_track_quat('-Z','Y').to_euler()
data=bpy.data.cameras.new('CA859 inspection camera');camera=bpy.data.objects.new(data.name,data);scene.collection.objects.link(camera);scene.camera=camera;data.type='ORTHO';data.ortho_scale=32
for side,y in [('right',-29),('left',29)]:
 target=Vector((5,y,85))
 for label,delta in [('front',(70,0,10)),('rear',(-70,0,10)),('side',(0,-70 if side=='right' else 70,10))]:
  camera.location=target+Vector(delta);camera.rotation_euler=(target-camera.location).to_track_quat('-Z','Y').to_euler()
  scene.render.filepath=str(out/(side+'-'+label+'.png'));bpy.ops.render.render(write_still=True)
print(json.dumps({k:{a:b for a,b in v.items() if a!='geometry'} for k,v in report.items()}))
