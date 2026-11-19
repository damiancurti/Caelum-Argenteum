"""Read the accepted source without saving or editing it."""
from pathlib import Path
import bpy,hashlib,json
R=Path(__file__).resolve().parents[1]
cfg=json.loads((R/'assets/source/art/character_modules_458/MODULES.json').read_text(encoding='utf-8'))
source=R/cfg['source_blend'];assert hashlib.sha256(source.read_bytes()).hexdigest()==cfg['source_sha256']
bpy.ops.wm.open_mainfile(filepath=str(source));rig=bpy.data.objects['Domingo_Rig'];rig.data.pose_position='REST'
report={'source_sha256':cfg['source_sha256'],'blender':bpy.app.version_string,'rig_matrix':[list(row) for row in rig.matrix_world],
 'bones':[{'name':b.name,'parent':b.parent.name if b.parent else None,'deform':b.use_deform,'length':b.length} for b in rig.data.bones],'objects':[]}
for obj in sorted((o for o in bpy.context.scene.objects if o.type=='MESH'),key=lambda o:o.name):
    groups={g.index:g.name for g in obj.vertex_groups};hist={}
    for v in obj.data.vertices:
        weights=[g.weight for g in v.groups if g.weight>0];hist[len(weights)]=hist.get(len(weights),0)+1
    report['objects'].append({'name':obj.name,'vertices':len(obj.data.vertices),'parent':obj.parent.name if obj.parent else None,'parent_type':obj.parent_type,
      'modifiers':[{'name':m.name,'type':m.type,'preserve_volume':getattr(m,'use_deform_preserve_volume',None)} for m in obj.modifiers],
      'shape_keys':len(obj.data.shape_keys.key_blocks) if obj.data.shape_keys else 0,'weight_histogram':hist,'groups':groups,
      'matrix':[list(row) for row in obj.matrix_world]})
(R/'build/issue834-rig-inspection.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'bones':len(report['bones']),'objects':len(report['objects']),'max_influences':max(int(k) for o in report['objects'] for k in o['weight_histogram']),
 'modifier_types':sorted({m['type'] for o in report['objects'] for m in o['modifiers']}),'shape_key_objects':sum(bool(o['shape_keys']) for o in report['objects'])}),flush=True)
assert hashlib.sha256(source.read_bytes()).hexdigest()==cfg['source_sha256']
