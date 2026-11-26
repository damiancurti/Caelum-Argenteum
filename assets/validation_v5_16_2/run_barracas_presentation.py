"""Reuse the accepted campaign observer at corresponding Barracas viewpoints.

Run one scenario at a time, without concurrent engine tests. The existing Vulkan
presentation analyzer reports native queue-present intervals separately from
simulation. The entry view rotates with the preserved quay; the revised siege
view stands two existing route radii inside the southern gate. No actor, weather,
clock or battle rule is replaced here.
"""
from pathlib import Path
import sys


if __name__ == '__main__':
    previous = Path(__file__).resolve().parents[1] / 'validation_v5_12_7/run_campaign_profile.py'
    source = previous.read_text(encoding='utf-8')
    parse = '    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)'
    if source.count(parse) != 1:
        raise SystemExit('The shared argument parser changed; review the adapter.')
    source = source.replace(parse, "    parser.add_argument('--settled-siege',action='store_true',help='Observe the original siege after5000 native tics, allowing its slower admissions to reach the existing cap')\n" + parse + "\n    if args.settled_siege and (not args.siege or args.direct_deployment):parser.error('Settled siege requires normal siege deployment.')")
    anchor = "    source=(ROOT/'assets/validation_5103/performance.zs').read_text(encoding='utf-8')\n"
    if source.count(anchor) != 1:
        raise SystemExit('The shared observer loader changed; review the adapter.')
    original_point = 'vector3 point=SIEGE ? (-14464,-14000,0) : (0,320,0);'
    revised_point = original_point + '''
                if(CaelumBarracasData.IsCurrent())
                {
                    if(SIEGE)
                    {
                        int gate=CaelumBarracasFrontData.GateForLane(0);
                        double outward=CaelumBarracasFrontData.GateOutward(gate);
                        point=CaelumBarracasFrontData.GatePoint(gate)-(Cos(outward),Sin(outward),0)*CaelumPortData.ROUTE_RADIUS*2;
                    }
                    else point=CaelumBarracasData.CurrentPortPoint(point);
                }'''
    original_angle = 'user.Angle=SIEGE ? 270 : 180;'
    revised_angle = 'user.Angle=SIEGE ? 270 : CaelumBarracasData.CurrentPortAngle(180);'
    injected = anchor + f'    assert source.count({original_point!r})==1 and source.count({original_angle!r})==1\n'
    injected += f'    source=source.replace({original_point!r},{revised_point!r}).replace({original_angle!r},{revised_angle!r})\n'
    injected += "    if args.settled_siege:source=source.replace('SIEGE ? 3600 : 350','SIEGE ? 5000 : 350')\n"
    source = source.replace(anchor, injected).replace("'build/issue435'", "'build/v516'")
    source = source.replace('campaign-profile-%Y', 'barracas-profile-%Y').replace('issue=435,', 'issue=454,')
    source = source.replace('duration=(4350 if args.siege else 1100)', 'duration=((5750 if args.settled_siege else 4350) if args.siege else 1100)')
    source = source.replace('map=args.map,siege=args.siege,', 'map=args.map,siege=args.siege,settled_siege=args.settled_siege,')
    capture = 'event ca510_frames; wait 3; quit'
    if source.count(capture) != 1:
        raise SystemExit('The shared observer completion changed; review the adapter.')
    source = source.replace(capture, 'event ca510_frames; screenshot scene.png; wait 3; quit')
    sys.path.insert(0, str(previous.parent))
    exec(compile(source, str(previous), 'exec'), {'__file__': str(previous), '__name__': '__main__'})
