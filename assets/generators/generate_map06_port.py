"""Deterministically extend the authored port and emit shared encounter data."""
import json
from pathlib import Path
from generate_coastal_trials import generate
from generate_port_city import expand_city
import generate_city_interiors as interiors

ROOT = Path(__file__).resolve().parents[2]
D = json.loads((ROOT/'assets/map06_port/LAYOUT.json').read_text(encoding='utf-8'))
S = json.loads((ROOT/'assets/map06_port/SOUTH.json').read_text(encoding='utf-8'))

def extend(port):
    port.compact = True
    port.room(*S['field_bounds'], flat='CMGR03', wall='CMST01')
    port.room(*S['field_boundary'],floor=D['wall_height'],flat='CMST01')
    expand_city(port)
    interiors.apply(port, json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8')))
    interiors.runtime(json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8')),port,S)
    port.prop(31050, *S['controller'][:2], tid=46000,args=(interiors.DATA['constants']['LAYOUT_REVISION'],))
    port.prop(30987, *D['resource_bed'][:2])
    port.prop(18004, *D['resource_workbench'][:2])
    port.prop(31051, *D['completion_position'][:2])

def runtime():
    values = {k.upper(): v for k, v in D.items() if isinstance(v, (int, float))}
    values['DEFENDER_HEIGHT'] = D['defender_height_m']*32
    code = '// Generado desde assets/map06_port/{LAYOUT,SOUTH,CITY}.json.\nclass CaelumPortData : Object play\n{\n'
    code += ''.join(f'    const {k} = {v:.12g};\n' for k, v in values.items())
    code += '    static bool IsSouth(){let p=CaelumPortSiege.Get();return p!=null && p.args[0]>=2;}\n'
    code += f'    static int MandingaCount(){{return IsSouth()?{S["mandingas"]}:MANDINGAS;}}\n'
    code += f'    static int DefenderCount(){{return IsSouth()?{S["defenders"]}:DEFENDERS;}}\n'
    code += f'    static int GunCount(){{return IsSouth()?{len(S["defending_guns"])+6}:18;}}\n'
    code += '    static bool ActiveGun(int i){return !IsSouth() || i<6'
    code += ''.join(f' || i=={i+6}' for i in S['active_defending_guns'])+';}\n'
    code += '    static vector3 OperatorOffset(int i,int slot){double side=(slot==0?-1:1)*OPERATOR_SIDE;\n'
    code += '        if(IsSouth() && ('+' || '.join(f'i=={i+6}' for i,a in enumerate(S['operator_axes']) if a=='y')+'))return (0,side,0);\n'
    code += '        return (side,0,0);}\n'
    code += '    static double GunAngle(int i){if(IsSouth()){\n'
    code += ''.join(f'        if(i=={i+6})return {a};\n' for i,a in enumerate(S['defending_angles']))
    code += '        }return i<6?AttackAngle():DefendAngle();}\n'
    for name,key,old in [('GateY','gate_y','GATE_Y'),('ExitY','exit_y','EXIT_Y'),('RamY','ram_start_y','RAM_START_Y'),('OutsideSign','outside_sign','1'),('AttackAngle','attack_angle','270'),('DefendAngle','defend_angle','90'),('LayoutRevision','revision','REVISION')]:
        code += f'    static double {name}(){{return IsSouth()?{S[key]}:{old};}}\n'
    code += '    static double GateX(int i)\n    {\n'
    code += '        if(IsSouth()){\n'+''.join(f'            if(i=={i})return {x};\n' for i,x in enumerate(S['gate_x']))+'        }\n'
    code += ''.join(f'        if(i=={i})return {x};\n' for i, x in enumerate(D['gate_x']))
    code += '        return 0;\n    }\n'
    for name, key in [('BossPosition','boss_position'), ('BedPosition','resource_bed'),
                      ('WorkbenchPosition','resource_workbench'), ('CompletionPosition','completion_position')]:
        south=f'if(IsSouth())return ({",".join(map(str,S[key]))});' if key in S else ''
        code += f'    static vector3 {name}(){{{south}return ({",".join(map(str,D[key]))});}}\n'
    code += '''    static vector3 GunPosition(int i)
    {
        if(IsSouth())
        {
'''
    code += ''.join(f'            if(i=={i})return ({",".join(map(str,p))});\n' for i,p in enumerate(S['attacking_guns']))
    code += ''.join(f'            if(i=={i+6})return ({",".join(map(str,p))});\n' for i,p in enumerate(S['defending_guns']))
    code += '''        }
        return i<6 ? (GateX(i),ATTACKING_GUN_Y,0) : (GateX((i-6)/2)+(i%2==0?-1:1)*DEFENDING_GUN_DX,DEFENDING_GUN_Y,DEFENDING_GUN_Z);
    }
    static vector3 FormationPosition(int i)
    {
'''
    code += f'        if(IsSouth())return ({S["formation_x"]}+(i%{S["formation_columns"]})*{S["formation_spacing_x"]},{S["formation_y"]}-(i/{S["formation_columns"]})*{S["formation_spacing_y"]},0);\n'
    code += '        return (FORMATION_X+(i%FORMATION_COLUMNS)*FORMATION_SPACING,FORMATION_Y+(i/FORMATION_COLUMNS)*FORMATION_SPACING,0);\n    }\n'
    code += '''    static vector3 GuardPosition(int i)
    {
        if(IsSouth()){
'''
    code += ''.join(f'            if(i=={i})return ({",".join(map(str,p))});\n' for i,p in enumerate(S['guard_positions']))
    code += '''        }
        return (GateX(i%6)+(i/6-6)*GUARD_SPACING,GUARD_Y,0);
    }
'''
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text())
    extra=[g for g in city['gates'] if 'actor' in g]
    code += '    static vector3 ExtraGate(int i){\n'+''.join(f'        if(i=={i})return ({",".join(map(str,g["actor"]))});\n' for i,g in enumerate(extra))+'        return (0,0,0);}\n'
    code += '    static double ExtraGateAngle(int i){\n'+''.join(f'        if(i=={i})return {g["angle"]};\n' for i,g in enumerate(extra))+'        return 0;}\n'
    code += '    static int CrewRouteCount(int i){\n'+''.join(f'        if(i=={i})return {len(r)};\n' for i,r in enumerate(S['crew_routes']))+'        return 0;}\n'
    code += '    static vector3 CrewRoutePoint(int i,int p){switch(i){\n'+''.join(f'        case {i}:return CrewRoute{i}(p);\n' for i in range(len(S['crew_routes'])))+'        }return (0,0,0);}\n'
    for i,r in enumerate(S['crew_routes']):
        code += f'    static vector3 CrewRoute{i}(int p){{\n'+''.join(f'        if(p=={n})return ({",".join(map(str,v))});\n' for n,v in enumerate(r))+'        return (0,0,0);}\n'
    code += '    static bool IsCurrent(){return level.MapName=="MAP06" && ActorIterator.Create(46000,"CaelumPortSiege").Next()!=null;}\n}\n'
    (ROOT/'src/caelum/world/CaelumPortData.zs').write_text(code, encoding='utf-8')

if __name__ == '__main__':
    generate(ROOT/'src/maps', port_extension=extend, include_coast=False)
    runtime()
    interiors.runtime(json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8')))
