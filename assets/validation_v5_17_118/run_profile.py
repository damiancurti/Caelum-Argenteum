"""Reuse the shared observer at a retained residential approach for #879."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[2]
previous = root / 'assets/validation_v5_16_2/run_barracas_presentation.py'
source = previous.read_text(encoding='utf-8')
house = json.loads((root/'assets/barracas_redesign/RUNTIME.json').read_text())['houses'][0]
x, y = house['public_approach'][:2]
point = {'angle': (house['angle']+90)%360}
marker = '            user.Pitch=GROUND ? 75 : 0;user.Vel=(0,0,0);'
replacement = f'''            if(level.MapName=="MAP03" && !SIEGE)
            {{
                user.SetOrigin(({x},{y},0),false);user.FindFloorCeiling();
                user.SetOrigin((user.Pos.X,user.Pos.Y,user.FloorZ),false);
                user.Angle={point['angle']};
            }}
''' + marker
anchor = "    source = source.replace(anchor, injected).replace(\"'build/issue435'\", \"'build/v516'\")"
assert source.count(anchor) == 1
injection = f'    source=source.replace({marker!r},{replacement!r})\n'
source = source.replace(anchor, '    injected += '+repr(injection)+'\n'+anchor)
exec(compile(source,str(previous),'exec'), {'__file__':str(previous),'__name__':'__main__'})
