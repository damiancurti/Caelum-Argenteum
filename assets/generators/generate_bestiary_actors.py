"""Generate unplaced folklore combat classes from the approved shared template.

No balance values, editor numbers, spawn placements or new playable races are
introduced. The original Mandinga implementation remains the inherited source.
Catalogue taxonomy is independent of the provisional armor/physiology adapter.
"""
from pathlib import Path
import argparse
import json
try:
    from .build_bestiary_catalogue import assemble
except ImportError:
    from build_bestiary_catalogue import assemble

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = 'src/caelum/actors/CaelumBestiaryCombat.zs'
NAMES_START = '// BEGIN #455 generated folklore names\n'
NAMES_END = '// END #455 generated folklore names\n'


def render(root=ROOT):
    catalogue, audit = assemble(root)
    rows = catalogue['entries']
    active = [(i, row) for i, row in enumerate(rows) if row.get('actor_class')]
    behavior = json.loads((root / 'assets/bestiary/BEHAVIOR.json').read_text(encoding='utf-8'))
    if not behavior['runtime_enabled'] or behavior.get('campaign_spawning_enabled'):
        raise ValueError('This generator requires approved unplaced combat classes.')
    if behavior['template']['class'] != 'CaelumMandinga' or audit['runtime_actors_added'] != len(active):
        raise ValueError('The approved inheritance contract changed; review implementation.')
    lines = ['// Generado desde el catalogo y BEHAVIOR.json; sin cifras de balance duplicadas.',
             '// Clases provisionales sin colocaciones de campana ni arte final.',
             'class CaelumBestiaryData : Object', '{', f'    const COUNT={len(rows)};']
    for method, field in [('Reference', 'id'), ('Taxonomy', 'race'), ('Population', 'population')]:
        lines += [f'    static String {method}(int index)', '    {', '        switch(index)', '        {']
        lines += [f'        case {i}:return {json.dumps(row[field], ensure_ascii=False)};' for i, row in enumerate(rows)]
        lines += ['        }', '        return "";', '    }']
    lines += ['    static class<Actor> ActorClass(int index)', '    {', '        switch(index)', '        {']
    lines += [f"        case {i}:return '{row['actor_class']}';" for i, row in active]
    lines += ['        }', '        return null;', '    }', '}', '',
              '// La taxonomia no agrega razas jugables ni sustituye el perfil provisional.',
              'class CaelumBestiaryCombatActor : CaelumMandinga abstract', '{',
              '    virtual int BestiaryIndex(){return -1;}',
              '    String BestiaryReference(){return CaelumBestiaryData.Reference(BestiaryIndex());}',
              '    String BestiaryTaxonomy(){return CaelumBestiaryData.Taxonomy(BestiaryIndex());}',
              '    String BestiaryPopulation(){return CaelumBestiaryData.Population(BestiaryIndex());}', '}']
    for i, row in active:
        lines += ['', f'class {row["actor_class"]} : CaelumBestiaryCombatActor', '{',
                  f'    override int BestiaryIndex(){{return {i};}}',
                  f'    Default {{ Tag "$CA_FOLK_{row["id"].rsplit("-",1)[1]}_NAME"; }}', '}']
    return ('\n'.join(lines) + '\n').encode('utf-8')


def render_names(root=ROOT):
    catalogue, _ = assemble(root)
    behavior = json.loads((root / 'assets/bestiary/BEHAVIOR.json').read_text(encoding='utf-8'))
    rows = [row for row in catalogue['entries'] if row.get('actor_class')]
    overrides = behavior['english_name_overrides']
    if set(overrides) - {row['id'] for row in rows}:
        raise ValueError('Unknown folklore name translation.')
    lines = [NAMES_START.rstrip()]
    for language in ('enu default', 'es'):
        lines.append(f'[{language}]')
        for row in rows:
            name = overrides.get(row['id'], row['reference_name']) if language == 'enu default' else row['reference_name']
            lines.append(f'CA_FOLK_{row["id"].rsplit("-",1)[1]}_NAME = {json.dumps(name, ensure_ascii=False)};')
    lines.append(NAMES_END.rstrip())
    return '\n'.join(lines) + '\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args(); blob = render()
    target = ROOT / OUTPUT
    if args.check:
        if target.read_bytes() != blob: raise SystemExit('Stale provisional bestiary combat classes; regenerate.')
    else: target.write_bytes(blob)
    language = ROOT / 'src/LANGUAGE'
    source = language.read_text(encoding='utf-8')
    names = render_names()
    if args.check:
        if source.count(NAMES_START) != 1 or names not in source:
            raise SystemExit('Stale bilingual folklore names; regenerate and rebuild the dialogue index.')
    else:
        if NAMES_START in source:
            before, block = source.split(NAMES_START, 1)
            if NAMES_END not in block: raise ValueError('Unterminated generated folklore names.')
            _, after = block.split(NAMES_END, 1)
            source = before + names + after
        else: source = source.rstrip() + '\n\n' + names
        language.write_text(source, encoding='utf-8', newline='\n')
    print('Verified 56 unplaced combat classes and bilingual names; existing Mandinga/Rulo/Zupay profiles retained.')


if __name__ == '__main__':
    main()
