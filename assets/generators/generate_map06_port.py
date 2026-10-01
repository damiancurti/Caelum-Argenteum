"""Deterministically extend the authored port and emit shared encounter data."""
import json
from pathlib import Path
from generate_coastal_trials import generate

ROOT = Path(__file__).resolve().parents[2]
D = json.loads((ROOT/'assets/map06_port/LAYOUT.json').read_text(encoding='utf-8'))

def extend(port):
    port.compact = True
    port.room(*D['field_bounds'], flat='CMGR03', wall='CMST01')
    port.room(-256, 2240, 384, 2304, flat='CMST01')
    port.room(-3072, 2304, 3072, 3520, flat='CMST01')
    port.room(-3072, D['wall_south_y'], 3072, D['gate_y'], floor=D['wall_height'], flat='CMST01')
    for x in D['gate_x']:
        port.room(x-64, D['wall_south_y'], x+64, D['gate_y'], flat='CMST01')
        for side in (-1, 1):
            gx = x+side*D['defending_gun_dx']
            port.room(gx-128, 3200, gx+128, 3456, floor=128, flat='CMST01')
            for step in range(8):
                port.room(gx-64, 2688+step*64, gx+64, 2752+step*64,
                          floor=(step+1)*16, flat='CMST01')
    # Authored northern boundary; no automatic removal before the exit zone.
    port.room(-3072, 11712, 3072, 11776, floor=128, flat='CMST01')
    port.prop(31050, 0, 2496, tid=46000)
    port.prop(30987, *D['resource_bed'][:2])
    port.prop(18004, *D['resource_workbench'][:2])
    port.prop(31051, *D['completion_position'][:2])

def runtime():
    values = {k.upper(): v for k, v in D.items() if isinstance(v, (int, float))}
    values['DEFENDER_HEIGHT'] = D['defender_height_m']*32
    code = '// Generado desde assets/map06_port/LAYOUT.json.\nclass CaelumPortData : Object play\n{\n'
    code += ''.join(f'    const {k} = {v:.12g};\n' for k, v in values.items())
    code += '    static double GateX(int i)\n    {\n'
    code += ''.join(f'        if(i=={i})return {x};\n' for i, x in enumerate(D['gate_x']))
    code += '        return 0;\n    }\n'
    for name, key in [('BossPosition','boss_position'), ('BedPosition','resource_bed'),
                      ('WorkbenchPosition','resource_workbench'), ('CompletionPosition','completion_position')]:
        code += f'    static vector3 {name}(){{return ({",".join(map(str,D[key]))});}}\n'
    code += '    static bool IsCurrent(){return level.MapName=="MAP06" && ActorIterator.Create(46000,"CaelumPortSiege").Next()!=null;}\n}\n'
    (ROOT/'src/caelum/world/CaelumPortData.zs').write_text(code, encoding='utf-8')

if __name__ == '__main__':
    generate(ROOT/'src/maps', port_extension=extend, include_coast=False)
    runtime()
