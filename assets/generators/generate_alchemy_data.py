"""Generate approved #470 placement data from its single JSON authority."""
from pathlib import Path
import json
ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
DATA = json.loads((HERE / 'alchemy_station.json').read_text(encoding='utf-8'))

def main():
    placements = DATA['placements']
    lines = ['// Generado por generate_alchemy_data.py; editar alchemy_station.json.',
             'class CaelumAlchemyData : Object', '{', f'    const REVISION = {DATA["revision"]};']
    for function, return_type, expressions, default in [
        ('Position', 'Vector3', [f'({",".join(map(str, p["position"]))})' for p in placements], '(0,0,0)'),
        ('Group', 'int', [str(p['group']) for p in placements], '0'),
        ('Angle', 'double', [str(p['angle']) for p in placements], '0')]:
        lines += [f'    static {return_type} {function}(String map)', '    {']
        lines += [f'        if(map == "{p["map"]}") return {value};' for p, value in zip(placements, expressions)]
        lines += [f'        return {default};', '    }']
    lines += ['    static bool Supports(String map)', '    {',
              '        return ' + ' || '.join(f'map == "{p["map"]}"' for p in placements) + ';', '    }', '}']
    source = ROOT / 'src/caelum/data/CaelumAlchemyData.zs'
    source.write_text('\n'.join(lines)+'\n', encoding='utf-8', newline='\n')
    print('Generated CaelumAlchemyData.zs from alchemy_station.json.')

if __name__ == '__main__':
    main()
