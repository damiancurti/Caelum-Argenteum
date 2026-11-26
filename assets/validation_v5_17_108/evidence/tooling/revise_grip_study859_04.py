from pathlib import Path
p=Path(__file__).with_name('skeleton_grips859_03.py');s=p.read_text().replace('study03','study04')
s=s.replace("rotation=Matrix.Identity(3) if side=='Left' else Vector((1,0,0)).rotation_difference(Vector((-6,14,75)).normalized()).to_matrix()","rotation=Matrix.Identity(3) if side=='Left' else Quaternion(Vector((0,-75,14)).normalized(),math.radians(65)).to_matrix()")
s=s.replace('for vert in equipment.data.vertices:vert.co+=fitcenter-nativecenter',"adjust=Matrix.Identity(3) if side=='Left' else Vector((-6,14,75)).normalized().rotation_difference(rotation@Vector((1,0,0))).to_matrix()\n   for vert in equipment.data.vertices:vert.co=fitcenter+adjust@(vert.co-nativecenter)")
s=s.replace("obj.name in ['CA827 '+side+' hand','CA827 Underbody'] or","obj.name=='CA827 '+side+' hand' or")
s=s.replace("target=Vector((5,y,88))","target=Vector((5,y,84)) if side=='Left' else Vector((10,y,88))")
p.with_name('skeleton_grips859_04.py').write_text(s)
