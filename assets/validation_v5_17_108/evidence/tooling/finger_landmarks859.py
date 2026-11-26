import bpy,json,sys
from pathlib import Path
from mathutils import Vector,Matrix
root=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713');sys.path.insert(0,str(root/'assets/generators'))
from author_underbody import load_obj
vertices,groups=load_obj(root/'assets/source/art/domingo_3d_pilot/makehuman/base.obj')
def point(name):
 ids=sorted({i for f in groups[name] for i in f});return sum((vertices[i] for i in ids),Vector())/len(ids)
bpy.ops.wm.open_mainfile(filepath=str(root/'assets/source/art/underbody_827/underbody.blend'));rig=bpy.data.objects['Domingo_Rig']
axes=Matrix(((0,0,1),(1,0,0),(0,1,0)));report={}
for side in ['L','R']:
 start=point('joint-'+side.lower()+'-hand');end=point('joint-'+side.lower()+'-finger-3-1');target=rig.data.bones['hand.'+side]
 origin=axes@start;direction=axes@(end-start);unit=direction.normalized();stretch=Matrix.Identity(3)*10
 for i in range(3):
  for j in range(3):stretch[i][j]+=(target.length/(end-start).length-10)*unit[i]*unit[j]
 rotation=direction.rotation_difference(target.tail_local-target.head_local).to_matrix();transform=Matrix.Translation(target.head_local)@(rotation@stretch).to_4x4()@Matrix.Translation(-origin)@axes.to_4x4()
 report[side]={name:[round(c,6) for c in transform@point(name)] for name in groups if name.startswith('joint-'+side.lower()+'-finger')}
(root/'build/issue859-inspect01/landmarks.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
