from pathlib import Path
import bpy,json
from mathutils import Vector
R=Path(__file__).resolve().parents[1];S=R/'build/issue829-source20'
bpy.ops.wm.open_mainfile(filepath=str(S/'wardrobe.blend'))
scene=bpy.context.scene;rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='POSE'
manifest=json.loads((R/'build/issue829-export17-preview/manifest.json').read_text())
author=json.loads((S/'AUTHORING.json').read_text());names={r['object'] for r in author['modules']['F']+author['modules']['pants_F_formal']}
for obj in scene.objects:
 obj.hide_render=obj.name not in names
 if obj.name not in names:continue
 name=obj.name.split(' ',2)[2]
 color=(.4,.22,.09,1)
 if name.startswith('shirt') or '_shirt_' in name:color=(.9,.9,.9,1)
 if name.startswith('waistcoat'):color=(1,.01,.01,1)
 if name=='silk_tie':color=(.1,.1,.9,1)
 if 'tailored trousers' in name:color=(.01,.7,.01,1)
 if '_pocket' in name:color=(1,.8,0,1)
 if '_lapel' in name:color=(0,.5,1,1)
 obj.color=color;obj.hide_set(False)
camera=bpy.data.cameras.new('Layer inspection camera');obj=bpy.data.objects.new('Layer inspection camera',camera);scene.collection.objects.link(obj)
obj.location=(220,-220,80);direction=Vector((0,0,80))-obj.location;obj.rotation_euler=direction.to_track_quat('-Z','Y').to_euler();camera.type='ORTHO';camera.ortho_scale=310;scene.camera=obj
scene.render.engine='BLENDER_WORKBENCH';scene.render.resolution_x=1280;scene.render.resolution_y=720;scene.render.resolution_percentage=100
shade=scene.display.shading;shade.light='STUDIO';shade.color_type='OBJECT';shade.show_shadows=False;shade.show_cavity=True;shade.show_specular_highlight=False;shade.background_type='WORLD';scene.world.color=(.12,.12,.12)
for index in [129,150]:
 pose=manifest['pose_bounds'][index];rig.animation_data.action=bpy.data.actions[pose['action']];scene.frame_set(pose['source_frame']);scene.render.filepath=str(R/f'build/issue829-layers20-whole-{index}.png');bpy.ops.render.render(write_still=True)
