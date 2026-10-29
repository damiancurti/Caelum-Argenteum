"""Derive native service placements from the authored Buenos Aires manifest."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]


def generate():
    data = json.loads((ROOT / "assets/buenos_aires/SERVICES.json").read_text())
    rows = data["actors"]
    lines = ["// #416: generado desde assets/buenos_aires/SERVICES.json.",
             "class CaelumBuenosAiresData : Object", "{",
             f"    const REVISION={data['revision']};",
             f"    const COUNT={len(rows)};",
             f"    const HOUSE_FIRST={data['house_first']};",
             f"    const HOUSE_COUNT={data['house_count']};",
             '    static clearscope bool IsMap(String map){return map=="CABAIRES";}',
             '    static clearscope bool IsHouse(int house){return house>=HOUSE_FIRST && house<HOUSE_FIRST+HOUSE_COUNT;}',
             '    static clearscope vector3 ControllerPosition(){return ('+', '.join(map(str,data['controller_position']))+');}']
    for method,kind,field,default in [('ActorClass','Name','actor','"None"'),
            ('Position','vector3','position','(0,0,0)'),('Facing','double','angle','0'),
            ('Merchant','int','merchant','-1'),('Category','int','category','-1'),
            ('Network','int','network','0'),('House','int','house','-1')]:
        lines.append(f"    static clearscope {kind} {method}(int slot){{switch(slot){{")
        for i,row in enumerate(rows):
            if field not in row:
                continue
            value=row[field]
            if kind=='Name': value=json.dumps(value)
            elif kind=='vector3': value='('+','.join(map(str,value))+')'
            lines.append(f"        case {i}:return {value};")
        lines.append(f"    }}return {default};}}")
    lines.append('}')
    (ROOT/'src/caelum/data/CaelumBuenosAiresData.zs').write_text('\n'.join(lines)+'\n')


if __name__ == '__main__':
    generate()
