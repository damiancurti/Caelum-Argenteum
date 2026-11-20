from pathlib import Path
p=Path(__file__).with_name('skeleton_grips859_04.py');s=p.read_text().replace('study04','study05')
a=s.index(' for finger in range(1,6):',s.index("bpy.ops.object.mode_set(mode='OBJECT')"));b=s.index(' bpy.context.view_layer.update();ev=',a)
s=s[:a]+''' for finger in range(1,6):
  radius=2.2 if side=='Left' else 2.9
  sourcepoints=[Vector(landmarks[letter][f'joint-{letter.lower()}-finger-{finger}-{n}']) for n in range(1,5)]
  if finger==1:
   targets=[sourcepoints[0],Vector((7.5,sign*25,85.2)),Vector((7.5,sign*(26.8-radius),83.2)),Vector((5.4,sign*(26.8-radius),82))]
  else:
   angle=0;targets=[]
   for n,pt in enumerate(sourcepoints):
    if n:angle+=(pt-sourcepoints[n-1]).length/radius
    targets.append(Vector((sourcepoints[0].x,sign*(26.8+radius*math.cos(angle)),82.3-radius*math.sin(angle))))
  for segment in range(1,4):
   bone=helper.pose.bones[f'f{finger}.{segment}'];start,end=sourcepoints[segment-1:segment+1];dest,tip=targets[segment-1:segment+1]
   rotation=(end-start).rotation_difference(tip-dest).to_matrix().to_4x4()
   scale=Matrix.Diagonal((1,(tip-dest).length/(end-start).length,1,1))
   bone.matrix=Matrix.Translation(dest)@rotation@Matrix.Translation(-start)@bone.bone.matrix_local@scale
   bpy.context.view_layer.update()
''' + s[b:]
p.with_name('skeleton_grips859_05.py').write_text(s)
