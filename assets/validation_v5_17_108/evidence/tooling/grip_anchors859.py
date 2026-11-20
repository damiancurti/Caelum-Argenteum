"""Record fitted native-sample grip centers for diagnostic close-up cameras."""
import bpy,json
from pathlib import Path
from mathutils import Vector
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');art=root/'assets/source/art/grips_859'
author=json.loads((art/'AUTHORING.json').read_text());cfg=json.loads((art/'DESIGN.json').read_text());design=json.loads((root/cfg['rig_design']).read_text())
bpy.ops.wm.open_mainfile(filepath=str(art/'grips.blend'));rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='POSE';rows=[]
for action,options in design['export_actions'].items():
 for frame in options['frames']:
  rig.animation_data.action=bpy.data.actions[action];bpy.context.scene.frame_set(frame);row={'action':action,'source_frame':frame}
  for side,letter in [('Left','L'),('Right','R')]:
   matrix=rig.pose.bones['hand.'+letter].matrix@rig.data.bones['hand.'+letter].matrix_local.inverted();row[side]=list(matrix@Vector(author['hands'][side]['fitted_center']))
  rows.append(row)
(root/'assets/validation_v5_17_108/grip_anchors.json').write_text(json.dumps(rows,indent=2)+'\n');print(len(rows))
