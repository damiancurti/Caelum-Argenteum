"""Emit the authored normal siege deployment policy (#327)."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def render(root=ROOT):
    data = json.loads((root/'assets/map06_port/REINFORCEMENTS.json').read_text(encoding='utf-8'))
    assert data['total'] % data['group_size'] == 0
    assert 0 < data['group_size'] <= data['living_cap'] <= data['total']
    lines = ['// Generado desde assets/map06_port/REINFORCEMENTS.json.',
             'class CaelumReinforcementData : Object', '{']
    lines += [f'    const {key.upper()} = {data[key]};' for key in
              ('revision','group_size','living_cap','total','interval','formation_slots')]
    return ('\n'.join(lines)+'\n}\n').encode('utf-8')


if __name__ == '__main__':
    (ROOT/'src/caelum/data/CaelumReinforcementData.zs').write_bytes(render())
