"""Check actual evaluated hand contact and preserve unrelated accepted geometry."""
from pathlib import Path
import hashlib
import json
import struct
import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT/'assets/source/art/domingo_3d_pilot'
CONFIG = json.loads((ART/'DESIGN.json').read_text(encoding='utf-8'))


def inspect(source, contacts=False):
    bpy.ops.wm.open_mainfile(filepath=str(source))
    rig, scene = bpy.data.objects['Domingo_Rig'], bpy.context.scene
    rows, errors = {}, []
    palm = Vector(CONFIG['shield_grip_revision']['palm_center'])
    for action, options in CONFIG['export_actions'].items():
        rig.animation_data.action = bpy.data.actions[action]
        for frame in options['frames']:
            scene.frame_set(frame)
            graph = bpy.context.evaluated_depsgraph_get()
            for obj in scene.objects:
                if obj.type != 'MESH' or obj.name.startswith('Shield '):
                    continue
                evaluated = obj.evaluated_get(graph)
                mesh = evaluated.to_mesh()
                values = [round(c*64) for v in mesh.vertices for c in evaluated.matrix_world@v.co]
                rows[action,frame,obj.name] = hashlib.sha256(struct.pack('<'+'i'*len(values),*values)).hexdigest()
                evaluated.to_mesh_clear()
            if contacts:
                assert rig.data.bones['shield'].parent.name == 'hand.L'
                hand = rig.pose.bones['hand.L']
                held = (hand.matrix@hand.bone.matrix_local.inverted())@palm
                grip = bpy.data.objects['Shield grip'].evaluated_get(graph)
                mesh = grip.to_mesh()
                center = sum((grip.matrix_world@v.co for v in mesh.vertices),Vector())/len(mesh.vertices)
                error = (center-held).length
                assert error < .001, (action,frame,error)
                errors.append(error)
                grip.to_mesh_clear()
                shield = rig.pose.bones['shield']
                normal = (shield.matrix@shield.bone.matrix_local.inverted()).to_3x3()@Vector((0,1,0))
                if action == 'IdleBreathing':
                    assert normal.normalized().dot(Vector((0,1,0))) > .999
                if action.startswith('Guard'):
                    chest = rig.pose.bones['chest']
                    forward = (chest.matrix@chest.bone.matrix_local.inverted()).to_3x3()@Vector((1,0,0))
                    assert normal.normalized().dot(forward.normalized()) > .999
    return rows, errors


def main():
    baseline = ROOT/'build/issue283-reference/candidate-15-guard-jump.blend'
    source = ART/'domingo.blend'
    previous,_ = inspect(baseline)
    current,errors = inspect(source,True)
    assert current == previous, [key for key in previous if current.get(key) != previous[key]][:10]
    for name in ['JumpPrepare','GuardJumpPrepare']:
        options = CONFIG['export_actions'][name]
        assert options['tics'] == 10 and options['sample_tics'][0] == 0 and options['sample_tics'][-1] == 10
        assert len(options['frames']) == len(options['sample_tics']) == 36
    assert CONFIG['export_actions']['Landing']['tics'] == CONFIG['export_actions']['GuardLanding']['tics'] == 35
    report = {'issue':283,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
              'baseline_sha256':hashlib.sha256(baseline.read_bytes()).hexdigest(),
              'unchanged_non_shield_object_poses':len(current),'grip_contact_samples':len(errors),
              'maximum_contact_error_units':max(errors),'jump_prepare_tics':10,'landing_tics':35,
              'frame_identity_count':sum(len(a['frames']) for a in CONFIG['export_actions'].values()),
              'scope':'Evaluated handle center stays in the hand for all poses; resting shield lies in the forward/back plane, guard faces forward. All non-shield posed geometry remains unchanged. Native timing and author review are separate.'}
    (ROOT/'assets/validation_5423/shield-grip-geometry.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
