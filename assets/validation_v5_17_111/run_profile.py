"""Reuse the shared observer, viewing the actual MAP02 stone consumer for #866."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[2]
previous = root / 'assets/validation_v5_16_2/run_barracas_presentation.py'
source = previous.read_text(encoding='utf-8')
point = json.loads((root/'assets/source/art/environment_remasters_866/VIEWS.json').read_text())['MAP02'][0]
x, y = point['point']
marker = '            user.Pitch=GROUND ? 75 : 0;user.Vel=(0,0,0);'
replacement = f'''            if(level.MapName=="MAP02")
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
