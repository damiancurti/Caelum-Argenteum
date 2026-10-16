"""Verify preserved MD3 frames, reversible flexion and grounded feet in Blender."""
from pathlib import Path
import hashlib
import json
import struct
import bpy

ROOT = Path(__file__).resolve().parents[2]


def md3(path):
    data = path.read_bytes()
    header = struct.unpack_from('<4sI64s9I', data)
    surface_start = header[-2]
    surface = struct.unpack_from('<4s64s10I', data, surface_start)
    vertices = surface[5]
    vertex_start = surface_start + surface[-2]
    frame_bytes = vertices * 8
    return data, header[4], vertex_start, frame_bytes


def main():
    prior = ROOT / 'build/issue283-export-14/domingo.md3'
    current = ROOT / 'src/models/caelum/domingo/domingo.md3'
    old, frames, start, stride = md3(prior)
    new, new_frames, new_start, new_stride = md3(current)
    assert stride == new_stride
    for frame in range(frames):
        assert old[start+frame*stride:start+(frame+1)*stride] == new[new_start+frame*stride:new_start+(frame+1)*stride], frame

    source = ROOT / 'assets/source/art/domingo_3d_pilot/domingo.blend'
    bpy.ops.wm.open_mainfile(filepath=str(source))
    scene = bpy.context.scene
    rig = bpy.data.objects['Domingo_Rig']
    poses = {}
    feet = []
    for action in ['JumpPrepare', 'Landing']:
        rig.animation_data.action = bpy.data.actions[action]
        assert int(rig.animation_data.action['native_tics']) == 35
        for frame in range(36):
            scene.frame_set(frame)
            poses[action, frame] = {bone.name: tuple(v for row in bone.matrix for v in row) for bone in rig.pose.bones}
            for side in ['L', 'R']:
                foot = rig.pose.bones['foot.'+side]
                rest = foot.bone.head_local
                error = (foot.head-rest).length
                assert error < .01, (action, frame, side, error)
                feet.append(error)
    for frame in range(36):
        for bone, matrix in poses['JumpPrepare', frame].items():
            reverse = poses['Landing', 35-frame][bone]
            assert max(abs(a-b) for a,b in zip(matrix,reverse)) < .0001, (frame, bone)
    rig.animation_data.action = bpy.data.actions['JumpPrepare']
    scene.frame_set(35)
    root = rig.pose.bones['root']
    lowering = root.bone.head_local.z-root.head.z
    assert lowering > 18.9
    knees = {}
    for side in ['L','R']:
        knee = rig.pose.bones['shin.'+side]
        offset = knee.head-knee.bone.head_local
        # The anatomical rest chain has a slight lateral splay; flexion must
        # remain predominantly forward instead of reproducing the old side bend.
        assert offset.x > 10 and abs(offset.y) < offset.x*.05, (side, tuple(offset))
        knees[side] = tuple(offset)
    report = {'issue':283, 'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
              'md3_sha256':hashlib.sha256(new).hexdigest(), 'preserved_frame_count':frames,
              'current_frame_count':new_frames, 'reverse_pose_samples':36,
              'foot_samples':len(feet), 'maximum_foot_error_units':max(feet),
              'root_lowering_units':lowering, 'knee_displacements':knees,
              'scope':'Prior accepted MD3 frame coordinates/normals unchanged; jump/landing reverse each other, bend knees forward and retain foot contact. Native input checks and author review are separate.'}
    (ROOT/'assets/validation_5423/guard-jump-geometry.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(report))


if __name__ == '__main__':
    main()
