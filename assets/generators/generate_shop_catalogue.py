"""Generate #383 category overrides and sign anchors from the authored city data."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2]
DATA=json.loads((ROOT/'assets/map06_port/SHOP_CATALOGUE.json').read_text(encoding='utf-8'))

def category(identity, original_count=6):
    return next((r['category'] for r in DATA['replacements'] if r['shop_identity']==identity),identity%original_count)

def main():
    city=json.loads((ROOT/'assets/map06_port/CITY.json').read_text(encoding='utf-8'))
    doors=json.loads((ROOT/'assets/map06_port/NATIVE_DOORS.json').read_text(encoding='utf-8'))
    shops=[b for b in city['buildings'] if b['kind']=='shop']
    code=['// Generado desde SHOP_CATALOGUE.json, CITY.json y NATIVE_DOORS.json.',
          'class CaelumShopCatalogue : Object', '{',
          f'    const REVISION={DATA["revision"]};',f'    const LIBRARY={DATA["library_category"]};',
          f'    const CLOTHING={DATA["clothing_category"]};',f'    const BOOK_STOCK={DATA["book_stock"]};',
          '    static int Category(int identity)', '    {']
    for row in DATA['replacements']:
        code.append(f'        if(identity=={row["shop_identity"]})return {row["category"]};')
    code+=['        return identity%CaelumCityData.SHOP_CATEGORIES;', '    }',
           '    static int SignCategory(vector3 position,int original)', '    {']
    for row in DATA['replacements']:
        b=shops[row['shop_identity']]
        x=b['bounds'][2]+city['detail']['awning_depth']+doors['half_thickness']
        y=b['door_y']+city['profiles']['shop']['door_width']//2
        code.append(f'        if(position.X=={x} && position.Y=={y})return {row["category"]};')
    code+=['        return original;', '    }', '}']
    out=ROOT/'src/caelum/data/CaelumShopCatalogue.zs'
    out.write_text('\n'.join(code)+'\n',encoding='utf-8',newline='\n')
    print('Generated city shop category and sign overrides.')

if __name__=='__main__':main()
