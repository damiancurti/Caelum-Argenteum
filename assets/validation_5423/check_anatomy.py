"""Check evaluated Domingo joints in Blender, without modifying the source art."""
from pathlib import Path
import argparse
import hashlib
import json
import math
import sys

import bpy

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--baseline', type=Path, help='Compare hand movement against a preserved earlier Blender source.')
    args = parser.parse_args(sys.argv[sys.argv.index('--') + 1:])
    source = ROOT / 'assets/source/art/domingo_3d_pilot/domingo.blend'
    bpy.ops.wm.open_mainfile(filepath=str(source))
    rig = bpy.data.objects['Domingo_Rig']
    rows = []
    ranges = {}
    hands = {}
    for action in ('Walk', 'Run', 'Seated'):
        rig.animation_data.action = bpy.data.actions[action]
        duration = int(rig.animation_data.action['native_tics'])
        for frame in range(duration + 1):
            bpy.context.scene.frame_set(frame)
            bpy.context.view_layer.update()
            for side in ('L', 'R'):
                hip = rig.pose.bones['thigh.' + side].head
                knee = rig.pose.bones['shin.' + side].head
                ankle = rig.pose.bones['foot.' + side].head
                line = ankle - hip
                closest = hip + line * ((knee - hip).dot(line) / line.length_squared)
                bend = knee - closest
                assert abs(bend.y) < 1.5, (action, frame, side, 'sideways knee')
                assert bend.x >= -0.05, (action, frame, side, 'backwards knee')
                upper = rig.pose.bones['upper_arm.' + side]
                lower = rig.pose.bones['forearm.' + side]
                angle = math.degrees((upper.tail - upper.head).angle(lower.tail - lower.head))
                if action != 'Seated':
                    assert 15 < angle < 95, (action, frame, side, 'rigid or overfolded elbow')
                    ranges.setdefault(action + '.' + side, []).append(angle)
                    hand = rig.pose.bones['hand.' + side].head - upper.head
                    hands.setdefault(action + '.' + side, []).append(hand.copy())
                rows.append((action, frame, side, bend.y, bend.x, angle))
    for name, values in ranges.items():
        assert max(values) - min(values) > 1, (name, 'rigid elbow cycle')
    spans = {key: max((a - b).length for a in points for b in points) for key, points in hands.items()}
    for side in ('L', 'R'):
        assert spans['Walk.' + side] < spans['Run.' + side], (side, 'walking hands sway as much as running')
        assert max(ranges['Walk.' + side]) < min(ranges['Run.' + side]), (side, 'run posture not distinct')
    report = {
        'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'joint_samples': len(rows),
        'maximum_lateral_knee_units': max(abs(row[3]) for row in rows),
        'minimum_forward_knee_units': min(row[4] for row in rows),
        'elbow_degrees': {key: {'min': min(values), 'max': max(values)} for key, values in ranges.items()},
        'hand_excursion_units_relative_to_shoulder': spans,
        'scope': 'Evaluated walk/run/seated anatomy; author visual acceptance remains separate.',
    }
    if args.baseline:
        bpy.ops.wm.open_mainfile(filepath=str(args.baseline.resolve()))
        previous = bpy.data.objects['Domingo_Rig']
        old_hands = {}
        for action in ('Walk', 'Run'):
            previous.animation_data.action = bpy.data.actions[action]
            for frame in range(int(previous.animation_data.action['native_tics']) + 1):
                bpy.context.scene.frame_set(frame)
                bpy.context.view_layer.update()
                for side in ('L', 'R'):
                    position = previous.pose.bones['hand.' + side].head - previous.pose.bones['upper_arm.' + side].head
                    old_hands.setdefault(action + '.' + side, []).append(position.copy())
        old_spans = {key: max((a - b).length for a in points for b in points) for key, points in old_hands.items()}
        for side in ('L', 'R'):
            assert spans['Walk.' + side] < old_spans['Walk.' + side] * 0.5, (side, 'walking motion not sufficiently reduced')
        report['comparison'] = {
            'baseline_sha256': hashlib.sha256(args.baseline.read_bytes()).hexdigest(),
            'baseline_hand_excursion_units': old_spans,
            'current_to_previous_walk_ratio': {side: spans['Walk.' + side] / old_spans['Walk.' + side] for side in ('L', 'R')},
        }
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8', newline='\n')
    print('CA283 ANATOMY PASS', len(rows))


if __name__ == '__main__':
    main()
