"""Generate the approved #407 data and bilingual labels deterministically."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
DATA = json.loads(Path(__file__).with_name('marine_resources.json').read_text(encoding='utf-8'))


def main():
    rows = DATA['materials']
    recipe = DATA['recipe']
    imports = DATA['import']
    lines = ['// Generado desde assets/generators/marine_resources.json (#407).',
             'class CaelumMarineData : Object', '{',
             f'    const REVISION = {DATA["revision"]};',
             f'    const FIRST_MATERIAL = {rows[0]["id"]};',
             f'    const LAST_MATERIAL = {rows[-1]["id"]};',
             f'    const IODINE_RECIPE = {recipe["id"]};',
             f'    const INPUT_GRAMS = {recipe["input_grams"]};',
             f'    const OUTPUT_GRAMS = {recipe["theoretical_output_grams"]};',
             f'    const WORK_SECONDS = {recipe["base_work_seconds"]};',
             f'    const IMPORT_CATEGORY = {imports["category"]};',
             f'    const IMPORT_GRAMS = {imports["initial_grams"]};',
             f'    const IMPORT_RECOVERY_PER_DAY = {imports["recovery_per_day"]};']
    for name, typ, field, fallback in [('Price', 'double', 'copper_per_gram', '-1'),
                                       ('MaterialKey', 'String', 'key', '""'),
                                       ('MaterialIcon', 'String', 'icon', '""')]:
        lines += [f'    static {typ} {name}(int material)', '    {', '        switch(material)', '        {']
        for row in rows:
            value = row[field]
            if field == 'key': value = '"CA_MATERIAL_' + row['symbol'] + '"'
            elif field == 'icon': value = '"graphics/caelum/icons/materials/ca_material_' + value + '.png"'
            lines.append(f'            case {row["id"]}: return {value};')
        lines += ['        }', f'        return {fallback};', '    }']
    lines += ['}', '']
    (ROOT/'src/caelum/data/CaelumMarineData.zs').write_text('\n'.join(lines), encoding='utf-8', newline='\n')
    language = ROOT/'src/LANGUAGE'
    text = language.read_text(encoding='utf-8')
    marker = '// BEGIN MARINE RESOURCE LABELS #407'
    end_marker = '// END MARINE RESOURCE LABELS #407'
    block = [marker]
    for section, lang in [('enu default', 'en'), ('es', 'es')]:
        block += [f'[{section}]']
        block += [f'CA_MATERIAL_{r["symbol"]} = "{r[lang]}";' for r in rows]
        message = 'The batch yields less than one gram: increase batch size or efficiency' if lang=='en' else 'El lote rinde menos de un gramo: aumenta el lote o la eficiencia'
        block += [f'CA_CRAFTING_ACTION_FAILED_EMPTY_OUTPUT = "{message}";']
    block += [end_marker, '']
    if marker in text:
        start=text.index(marker); end=text.index(end_marker,start)+len(end_marker)
        text=text[:start]+'\n'.join(block).rstrip()+text[end:]
    else: text=text.rstrip()+'\n\n'+'\n'.join(block)
    language.write_text(text, encoding='utf-8', newline='\n')
    print('Generated #407 data and labels.')


if __name__ == '__main__':
    main()
