from pathlib import Path
import bpy,json
from mathutils.bvhtree import BVHTree
R=Path(__file__).resolve().parents[1];S=R/'build/issue829-source18'
bpy.ops.wm.open_mainfile(filepath=str(S/'wardrobe.blend'))
rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='POSE'
manifest=json.loads((R/'build/issue829-export17-preview/manifest.json').read_text())
author=json.loads((S/'AUTHORING.json').read_text());result=[]
for index in [0,28,129,150]:
 pose=manifest['pose_bounds'][index];rig.animation_data.action=bpy.data.actions[pose['action']];bpy.context.scene.frame_set(pose['source_frame']);graph=bpy.context.evaluated_depsgraph_get()
 meshes={}
 for row in author['modules']['F']+author['modules']['pants_F_formal']:
  obj=bpy.data.objects[row['object']];evaluated=obj.evaluated_get(graph);mesh=evaluated.to_mesh();mesh.calc_loop_triangles()
  points=[evaluated.matrix_world@v.co for v in mesh.vertices];triangles=[tuple(t.vertices) for t in mesh.loop_triangles]
  meshes[obj.name]=(points,triangles,BVHTree.FromPolygons(points,triangles,all_triangles=True));evaluated.to_mesh_clear()
 name='CA829 F outer_coat';points,triangles,tree=meshes[name];collisions=[]
 for other,(vertices,faces,bvh) in meshes.items():
  overlap=tree.overlap(bvh)
  if other==name:overlap=[(a,b) for a,b in overlap if a<b and not set(triangles[a])&set(triangles[b])]
  if overlap:
   vertices_hit=[points[v] for a,b in overlap for v in triangles[a]]
   collisions.append({'other':other,'pairs':len(overlap),'coat_bounds':[[min(v[a] for v in vertices_hit) for a in range(3)],[max(v[a] for v in vertices_hit) for a in range(3)]]})
 result.append({'sample':index,'action':pose['action'],'frame':pose['source_frame'],'intersections':collisions})
(R/'build/issue829-collisions18.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps([{'sample':r['sample'],'intersections':[(v['other'],v['pairs']) for v in r['intersections']]} for r in result]))
