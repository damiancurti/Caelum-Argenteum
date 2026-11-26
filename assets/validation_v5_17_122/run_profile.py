"""Place the shared campaign observer at a retained waterline review anchor.

Only the disposable MAP02 observer position and angle change. All actors,
weather, clock, profiling intervals and presentation collection remain native.
"""
from pathlib import Path
import json,sys

ROOT=Path(__file__).resolve().parents[2]
def take(name):
    index=sys.argv.index(name);value=sys.argv[index+1]
    del sys.argv[index:index+2]
    return value
camera=take('--camera')
rows=json.loads(Path(take('--cameras')).read_text(encoding='utf-8'))['rows']
row=next(r for r in rows if r['name']==camera)
previous=ROOT/'assets/validation_v5_12_7/run_campaign_profile.py'
source=previous.read_text(encoding='utf-8')
anchor="    source=(ROOT/'assets/validation_5103/performance.zs').read_text(encoding='utf-8')\n"
point=f'''if(level.MapName=="MAP02")
            {{
                vector3 point=({row['point'][0]},{row['point'][1]},0);
                user.SetOrigin(point,false);user.FindFloorCeiling();
                user.SetOrigin((point.X,point.Y,user.FloorZ),false);
                user.Angle={row['angle']};
            }}
            '''
aim=''
if 'target' in row:
    target=','.join(map(str,row['target']))
    aim=f'if(level.MapName=="MAP02"){{vector3 aimPoint=({target});user.Angle=VectorAngle(aimPoint.X-user.Pos.X,aimPoint.Y-user.Pos.Y);user.Pitch=VectorAngle((aimPoint.XY-user.Pos.XY).Length(),user.Pos.Z+user.ViewHeight-aimPoint.Z);}}'
old='user.Pitch=GROUND ? 75 : 0;user.Vel=(0,0,0);'
changes=[
    (anchor,anchor+f'    assert source.count({old!r})==1\n    source=source.replace({old!r},{(point+old+aim)!r})\n'),
    ("'build/issue435'","'build/v516'"),
    ('campaign-profile-%Y','waterline-profile-%Y'),
    ('issue=435,','issue=887,'),
    ('event ca510_frames; wait 3; quit','event ca510_frames; screenshot scene.png; wait 3; quit')]
for old,new in changes:
    assert source.count(old)==1,old
    source=source.replace(old,new,1)
sys.path.insert(0,str(previous.parent))
exec(compile(source,str(previous),'exec'),{'__file__':str(previous),'__name__':'__main__'})
