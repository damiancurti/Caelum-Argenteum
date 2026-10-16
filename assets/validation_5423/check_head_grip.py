"""Check held contact and unaffected evaluated geometry against the prior art."""
from pathlib import Path
import hashlib
import json
import math
import struct

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / 'assets/source/art/domingo_3d_pilot'
CONFIG = json.loads((ART / 'DESIGN.json').read_text(encoding='utf-8'))


def snapshot(source):
    bpy.ops.wm.open_mainfile(filepath=str(source))
    rig = bpy.data.objects['Domingo_Rig']
    scene = bpy.context.scene
    objects = sorted((o for o in scene.objects if o.type == 'MESH'), key=lambda o: o.name)
    changed = {'Head', 'Hair crown', 'Long hair L', 'Long hair R'}
    rows = {}
    for action, options in CONFIG['export_actions'].items():
        rig.animation_data.action = bpy.data.actions[action]
        for frame in options['frames']:
            scene.frame_set(frame)
            graph = bpy.context.evaluated_depsgraph_get()
            for obj in objects:
                if obj.name in changed or obj.name.startswith(('Eye ', 'Pupil ')):
                    continue
                if action == 'Run' and 'sword' in obj.name.lower():
                    continue
                evaluated = obj.evaluated_get(graph)
                data = evaluated.to_mesh()
                values = [component for v in data.vertices for component in evaluated.matrix_world @ v.co]
                # MD3 stores coordinates at 1/64 unit; inspect the actual baked positions.
                packed = struct.pack('<' + 'i' * len(values), *(round(v * 64) for v in values))
                rows[(action, frame, obj.name)] = hashlib.sha256(packed).hexdigest()
                evaluated.to_mesh_clear()
    return rows


def main():
    baseline = ROOT / 'build/issue283-reference/candidate-08-arm-motion.blend'
    source = ART / 'domingo.blend'
    previous = snapshot(baseline)
    current = snapshot(source)
    assert current == previous, [key for key in previous if previous[key] != current.get(key)][:10]
    rig = bpy.data.objects['Domingo_Rig']
    rig.animation_data.action = bpy.data.actions['Run']
    definition = CONFIG['head_grip_revision']['run_sword']
    pivot = Vector(definition['fixed_grip_point'])
    blade = Vector(definition['blade_axis']).normalized()
    hand_axis = Vector(definition['hand_axis']).normalized()
    samples = []
    for frame in range(int(rig.animation_data.action['native_tics']) + 1):
        bpy.context.scene.frame_set(frame)
        hand = rig.pose.bones['hand.R']
        sword = rig.pose.bones['sword']
        hand_matrix = hand.matrix @ hand.bone.matrix_local.inverted()
        sword_matrix = sword.matrix @ sword.bone.matrix_local.inverted()
        error = (hand_matrix @ pivot - sword_matrix @ pivot).length
        angle = math.degrees((hand_matrix.to_3x3() @ hand_axis).angle(sword_matrix.to_3x3() @ blade))
        assert error < .001, (frame, 'grip detached', error)
        assert abs(angle - 90) < .01, (frame, 'not perpendicular', angle)
        samples.append({'frame': frame, 'grip_error_units': error, 'hand_blade_degrees': angle})
    report = {'issue': 283, 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
              'baseline_sha256': hashlib.sha256(baseline.read_bytes()).hexdigest(),
              'unchanged_object_pose_checks': len(current), 'run_grip_samples': samples,
              'scope': 'All exported frames; excludes changed head/hair/eyes and Run sword geometry. Visual acceptance remains pending.'}
    path = ROOT / 'assets/validation_5423/head-grip-geometry.json'
    path.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps({'unchanged_object_pose_checks': len(current), 'grip_samples': len(samples)}))


if __name__ == '__main__':
    main()
