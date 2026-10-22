"""Generate #405 data adapters and source profiles from approved JSON data."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


def switch(result, name, values, default, argument="index"):
    lines = [f"    static clearscope {result} {name}(int {argument})", "    {", f"        switch({argument})", "        {"]
    lines += [f"            case {index}: return {value};" for index, value in values]
    return "\n".join(lines + [f"            default: return {default};", "        }", "    }"])


def main():
    data = json.loads((HERE/"land_resources.json").read_text(encoding="utf-8"))
    catalog = json.loads((HERE/data["catalogue"]).read_text(encoding="utf-8"))
    sources = catalog["sources"]
    indices = {row["key"]: i for i, row in enumerate(sources)}
    ids = dict(data["new_material_ids"], cotton=72)
    names = {row["key"]: "CaelumSource" + "".join(s.title() for s in row["key"].split("_")) for row in sources}
    q = lambda s: json.dumps(s, ensure_ascii=False)
    code = ["// Generado desde resource_catalog.json y land_resources.json (#405).",
            "class CaelumLandResourceData : Object", "{",
            f"    const REVISION={data['revision']};",
            f"    const FIRST_MATERIAL={min(data['new_material_ids'].values())};",
            f"    const LAST_MATERIAL={max(data['new_material_ids'].values())};",
            f"    const PROFILE_COUNT={len(sources)};",
            f"    const PLACEMENT_COUNT={len(data['placements'])};",
            f"    const IMPORT_COUNT={len(data['imports'])};",
            f"    const HARDNESS={catalog['plant_hardness']};",
            f"    const ABUNDANCE={catalog['plant_abundance']};",
            f"    const HONEY_PER_USE={next(r['harvest_g'] for r in sources if r['key']=='honey')};",
            f"    const IMPORT_RECOVERY_PER_DAY={data['import_recovery_fraction_per_game_day']};"]
    for result, name, values, default in [
        ("int", "Material", [(i, ids[r['key']]) for i,r in enumerate(sources)], -1),
        ("double", "Capacity", [(i, r['capacity_g']) for i,r in enumerate(sources)], 0),
        ("bool", "IsHive", [(i, "true") for i,r in enumerate(sources) if r['action']=='interaction'], "false"),
        ("double", "Price", [(ids[k], value) for k,value in data['base_copper_per_gram'].items()], -1),
        ("String", "MaterialKey", [(ids[k],q("CA_MATERIAL_"+k.upper())) for k in data['new_material_ids']], '""'),
        ("String", "MaterialIcon", [(ids[k],q("graphics/caelum/icons/materials/ca_material_"+('wood' if k=='sugarcane' else 'plant_fiber')+".png")) for k in data['new_material_ids']], '""'),
        ("String", "MaterialSprite", [(ids[k],q(f'M{ids[k]:03d}')) for k in data['new_material_ids']], '""'),
        ("int", "ImportMaterial", [(i,ids[r['key']]) for i,r in enumerate(data['imports'])], -1),
        ("int", "ImportTarget", [(i,r['stock_g']) for i,r in enumerate(data['imports'])], 0),
        ("int", "ImportCategory", [(i,r['category']) for i,r in enumerate(data['imports'])], -1),
        ("String", "Map", [(i,q(r['map'])) for i,r in enumerate(data['placements'])], '""'),
        ("int", "PlacementId", [(i,r['id']) for i,r in enumerate(data['placements'])], 0),
        ("Vector3", "Position", [(i,f"({r['xy'][0]},{r['xy'][1]},0)") for i,r in enumerate(data['placements'])], "(0,0,0)"),
        ("Name", "PlacementClass", [(i,"'"+names[r['key']]+('Decoration' if r['decorative'] else '')+"'") for i,r in enumerate(data['placements'])], "'None'"),
    ]:
        code.append(switch(result,name,values,default))
    code += ["}", ""]
    (ROOT/"src/caelum/data/CaelumLandResourceData.zs").write_text("\n".join(code),encoding="utf-8")
    visual = data['presentation']
    actors = ["// Perfiles generados desde el catálogo aprobado (#405)."]
    for i, row in enumerate(sources):
        name = names[row['key']]
        actors += [f"class {name} : CaelumLandSource", "{", f"    override int Profile() {{ return {i}; }}",
                   "    Default", "    {", f"        Tag \"$CA_SOURCE_{row['key'].upper()}\";",
                   f"        Radius {visual['radius']}; Height {visual['height']}; Mass {visual['mass_kg']};",
                   "        Activation THINGSPEC_Switch;", "    }", f"    States {{ Spawn: {visual['sprite']} A -1; Stop; }}", "}"]
        if any(r['key']==row['key'] and r['decorative'] for r in data['placements']):
            actors += [f"class {name}Decoration : {name}", "{",
                       "    override bool IsNaturalResource() { return false; }", "}"]
    (ROOT/"src/caelum/world/CaelumLandSourceProfiles.zs").write_text("\n".join(actors)+"\n",encoding="utf-8")
    path=ROOT/'src/LANGUAGE'
    text=path.read_text(encoding='utf-8')
    marker='// BEGIN #405 LAND RESOURCE LOCALIZATION'
    block=marker+'\n'
    for language,field in [('enu default','name_en'),('es','name_es')]:
        block+=f'[{language}]\n'
        for row in sources:
            key=row['key'];name=row[field]
            if key in data['new_material_ids']:block+=f'CA_MATERIAL_{key.upper()} = {q(name)};\n'
            source_name = ('Colmena' if language=='es' else 'Bee hive') if key=='honey' else name
            block+=f'CA_SOURCE_{key.upper()} = {q(source_name)};\n'
    block+='// END #405 LAND RESOURCE LOCALIZATION'
    if marker in text:
        text=re.sub(re.escape(marker)+r'.*?// END #405 LAND RESOURCE LOCALIZATION',lambda match:block,text,flags=re.S)
    else:text+='\n'+block+'\n'
    path.write_text(text,encoding='utf-8',newline='\n')
    print('Generated #405 data, source profiles and ES/EN labels.')


if __name__ == '__main__':
    main()
