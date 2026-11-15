"""Prevent the medium torso/potion sprite collision found in #775."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
def validate(root=ROOT):
    errors=[]
    try:
        spec=json.loads((root/'assets/validation_v5_17_66/ALIAS.json').read_text())
        definitions=(root/'src/TEXTURES').read_text(encoding='utf-8')
        for name,item in spec['aliases'].items():
            matches=re.findall(r'Sprite\s+"'+name+r'"\s*,[^\n]+',definitions)
            expected='Sprite "'+name+'", 128, 128 { Offset 64, 120 Patch "'+item['path']+'", 0, 0 }'
            if matches!=[expected]:errors.append('Ambiguous or incorrect armor/potion alias: '+name)
            if hashlib.sha256((root/'src'/item['path']).read_bytes()).hexdigest()!=item['sha256']:errors.append('Changed owned reference: '+item['path'])
        source=(root/'src/caelum/equipment/CaelumEquipmentPickups.zs').read_text(encoding='utf-8')
        armor=source.split('class CaelumArmorPickup : CaelumEquipmentItem',1)[1].split('class CaelumShieldPickup',1)[0]
        if 'else visual = "CMAR";' not in armor or '"CAMD"' in armor:errors.append('Medium armor still selects the potion sprite')
        registry=source.split('class CaelumWorldSpriteRegistry',1)[1].split('class CaelumEquipmentItem',1)[0]
        if 'CMAR A 1;' not in registry or 'CAMD A 1;' not in registry:errors.append('Missing registered armor/potion sprite')
        consumables=(root/'src/caelum/equipment/CaelumConsumables.zs').read_text(encoding='utf-8').split('class CaelumAnimaPotionMedium',1)[1].split('class CaelumEnergyDrinkMedium',1)[0]
        if 'Spawn: CAMD A -1 Bright;' not in consumables:errors.append('Anima potion world state changed')
    except (OSError,ValueError,KeyError,IndexError) as exc:errors.append(str(exc))
    return errors
if __name__=='__main__':
    errors=validate();print(json.dumps(dict(errors=errors)));raise SystemExit(bool(errors))
