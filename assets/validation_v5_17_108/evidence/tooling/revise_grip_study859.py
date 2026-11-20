from pathlib import Path
p=Path(__file__).with_name('skeleton_grips859.py');s=p.read_text().replace('study02','study03')
s=s.replace('for vert,point in zip(original.data.vertices,closed):','target=Vector((3,sign*29,90)); center=target.copy()\n for vert,point in zip(original.data.vertices,closed):')
s=s.replace('original.data.update();obj.hide_render=True;obj.hide_viewport=True','''original.data.update();obj.hide_render=True;obj.hide_viewport=True
 fitcenter=target+rotation@(Vector((5.5,sign*26.8,82.3))-center)
 nativecenter=Vector((5,29,87)) if side=='Left' else Vector((5.5,-28,89))
 for equipment in bpy.data.objects:
  if equipment.type=='MESH' and (('shield' in equipment.name.lower()) if side=='Left' else ('sword' in equipment.name.lower())):
   for vert in equipment.data.vertices:vert.co+=fitcenter-nativecenter
   equipment.data.update()''')
s=s.replace("obj.name=='CA827 '+side+' hand' or","obj.name in ['CA827 '+side+' hand','CA827 Underbody'] or")
p.with_name('skeleton_grips859_03.py').write_text(s)
