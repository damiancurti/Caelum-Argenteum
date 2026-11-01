"""Render bounded native coordinates/indices for the authored Tarot apparatus."""
from pathlib import Path
import argparse
import json

ROOT = Path(__file__).resolve().parents[2]


def render(root=ROOT):
    data = root/'assets/tarot_examples'
    room = json.loads((data/'ROOM.json').read_text(encoding='utf-8'))
    geometry = json.loads((data/'GEOMETRY.json').read_text(encoding='utf-8'))
    apparatus = json.loads((data/'APPARATUS.json').read_text(encoding='utf-8'))
    ox, oy = room['origin']

    def vector(point):
        return '('+','.join(str(value) for value in point)+')'

    def offset(point):
        return [ox+point[0], oy+point[1], point[2]]

    lines = ['// #440: generado desde assets/tarot_examples; sin búsquedas geométricas por tic.',
             'class CaelumTarotExampleData : Object', '{',
             f'    const REVISION={apparatus["revision"]};',
             f'    const ROOM={geometry["sectors"][4]};',
             f'    const THRESHOLD={geometry["thresholds"][3]};',
             f'    const WATER={geometry["water_control"]};',
             f'    const DEPTH={room["water_depth_mu"]};',
             f'    const LIGHT_DRY={room["dry_light"]};',
             f'    const LIGHT_WET={room["wet_light"]};',
             f'    const DOOR_VISUAL_ANGLE={apparatus["door_visual_angle"]};',
             f'    static vector3 Living(){{return {vector(offset(apparatus["living_obstacle_offset"]))};}}',
             f'    static vector3 Spirit(){{return {vector(offset(apparatus["spirit_offset"]))};}}',
             f'    static vector3 HotRock(){{return {vector(offset(apparatus["hot_rock_offset"]))};}}',
             f'    static vector3 Automaton(){{return {vector(offset(apparatus["automaton_offset"]))};}}',
             f'    static vector3 Controller(){{return {vector(offset(apparatus["controller_offset"]))};}}',
             '    static vector3 Door(int index) {']
    for i, point in enumerate(apparatus['door_offsets']):
        lines.append(f'        if(index=={i})return {vector(offset(point))};')
    lines += ['        return (0,0,0);}', '    static int Slide(int index){']
    for i, direction in enumerate(apparatus['slide_direction']):
        lines.append(f'        if(index=={i})return {direction};')
    lines += ['        return 0;}', '    static vector3 Portal(int index){',
              f'        return index==0?{vector(apparatus["mansion_portal"])}:{vector(offset(apparatus["lab_portal_offset"]))};'+'}',
              '    static vector3 Arrival(int index){',
              f'        return index==0?{vector(offset(apparatus["lab_arrival_offset"]))}:{vector(apparatus["mansion_arrival"])};'+'}',
              '    static double Facing(int index){',
              f'        return index==0?{apparatus["arrival_angles"][0]}:{apparatus["arrival_angles"][1]};'+'}',
              '    static bool Present(){return level.MapName=="MAP01" && level.Sectors.Size()>WATER',
              '        && level.Sectors[ROOM].GetUDMFInt("user_ca_tarot_room")==1;}','}']
    return ('\n'.join(lines)+'\n').encode('utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    path = ROOT/'src/caelum/data/CaelumTarotExampleData.zs'
    expected = render()
    if args.check:
        assert path.read_bytes() == expected, 'Stale Tarot example apparatus data'
    else:
        path.write_bytes(expected)


if __name__ == '__main__':
    main()
