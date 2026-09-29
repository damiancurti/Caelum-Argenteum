"""Generate MAP01 practice coordinates from the authored room placement."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
data = json.loads((ROOT/'assets/map01_mansion/PRACTICE.json').read_text(encoding='utf-8'))
x,y,z = data['position']
x0,y0,x1,y1 = data['bounds']
assert x0<x<x1 and y0<y<y1
code = '// Datos generados desde assets/map01_mansion/PRACTICE.json.\n'
code += 'class CaelumMansionPracticeData : Object\n{\n'
code += f'    static vector3 Position() {{ return ({x},{y},{z}); }}\n'
code += '    static bool Contains(vector3 position)\n    {\n'
code += f'        return position.X > {x0} && position.X < {x1}\n'
code += f'            && position.Y > {y0} && position.Y < {y1}\n'
code += f"            && Abs(position.Z - {z}) < {data['vertical_tolerance']};\n"
code += '    }\n}\n'
(ROOT/'src/caelum/world/CaelumMansionPracticeData.zs').write_text(code,encoding='utf-8',newline='\n')
print('Generated mansion practice placement:',data['position'])
