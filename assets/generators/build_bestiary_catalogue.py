"""Build/check the verified #453 authoring catalogue without creating actors.

Original author attachments stay immutable under assets/source/bestiary_453.
AUTHORING.json owns later project decisions; CATALOGUE.json is generated.
Unknown measurement axes and campaign regions stay explicitly unspecified.
"""
from pathlib import Path, PurePosixPath
from collections import Counter
import argparse
import hashlib
import json
import sys
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
RACES = {'Humano': 'human', 'Hombre bestia': 'beast_man',
         'Duende / demonio': 'duende_demon', 'Aparición': 'apparition',
         'Bestia mágica': 'magical_beast'}
PRESENCE = {'Múltiples': ('repeatable', False), 'Único': ('unique', False),
            'Grupo limitado': ('limited_group', False),
            'Múltiples, poco frecuentes': ('repeatable', True)}


def assemble(root=ROOT):
    root = Path(root).resolve()
    decisions = json.loads((root / 'assets/bestiary/AUTHORING.json').read_text(encoding='utf-8'))
    behavior_path = root / 'assets/bestiary/BEHAVIOR.json'
    behavior = json.loads(behavior_path.read_text(encoding='utf-8')) if behavior_path.is_file() else {}
    combat_ids = set(behavior.get('new_creature_reference_ids', [])) if behavior.get('runtime_enabled') else set()
    source = root / decisions['source_catalogue']
    original = json.loads(source.read_text(encoding='utf-8-sig'))
    source_root = source.parent.resolve()
    for line in (source_root / 'SHA256SUMS.txt').read_text(encoding='utf-8-sig').splitlines():
        expected_hash, name = line.split(None, 1)
        target = (source_root / name).resolve()
        if not target.is_relative_to(source_root) or hashlib.sha256(target.read_bytes()).hexdigest() != expected_hash:
            raise ValueError(f'Original source checksum mismatch: {name}')
    entries = original['entries']
    ids = [entry['id'] for entry in entries]
    expected = [f'CA-FOLK-{index:03}' for index in range(1, 59)]
    if ids != expected or original['reference_count'] != 58:
        raise ValueError('Source must preserve all 58 ordered package IDs')
    if set(decisions['campaign_regions']) - set(ids):
        raise ValueError('Region assignments contain unknown package IDs')
    if combat_ids - set(ids) or combat_ids & {'CA-FOLK-018', 'CA-FOLK-019'}:
        raise ValueError('Provisional actors contain unknown or protected reference IDs')
    pilots=decisions.get('model_pilots',{})
    if set(pilots)-set(ids):
        raise ValueError('Model pilots contain unknown package IDs')
    rows = []
    for entry in entries:
        relative = PurePosixPath(entry['imagen'])
        image = (source_root / relative).resolve()
        if relative.is_absolute() or '..' in relative.parts or not image.is_relative_to(source_root):
            raise ValueError(f"Unsafe source image path: {entry['id']}")
        raw = image.read_bytes()
        if len(raw) != entry['bytes'] or hashlib.sha256(raw).hexdigest() != entry['sha256']:
            raise ValueError(f"Source image checksum mismatch: {entry['id']}")
        with Image.open(image) as picture:
            if picture.size != (entry['ancho_px'], entry['alto_px']) or picture.mode != entry['modo_imagen']:
                raise ValueError(f"Source image dimensions/mode differ: {entry['id']}")
            picture.verify()
        population, rare = PRESENCE[entry['presencia']]
        regions = decisions['campaign_regions'].get(entry['id'])
        if regions is not None and (not isinstance(regions, list) or not regions or not all(isinstance(value, str) and value for value in regions)):
            raise ValueError(f"Invalid authored regions: {entry['id']}")
        rows.append({
            'id': entry['id'], 'reference_name': entry['nombre'], 'race': RACES[entry['raza']],
            'population': population, 'rare_reference': rare,
            'population_limit': None,
            'size_reference': {'source_text': entry['tamano_aproximado'], 'measurement_axes': 'As explicitly stated in source text only; otherwise unspecified',
                               'runtime_scale_authorized': False},
            'campaign_regions': regions, 'region_status': 'authored' if regions else 'unassigned',
            'reference': {'path': image.relative_to(root).as_posix(), 'sha256': entry['sha256'],
                          'original_filename': entry['archivo_original'], 'source_date': entry['fecha_imagen'],
                          'association_status': 'reconstructed_from_names_anatomy_and_sequence',
                          'width': entry['ancho_px'], 'height': entry['alto_px']},
            'source_notes': entry['notas'],
            'protected_existing_identity': decisions['protected_existing_identities'].get(entry['id']),
            'production_status': 'concept_reference_only', 'engine_id': None,
            'mesh': None, 'rig': None, 'animations': [],
        })
        if entry['id'] in pilots:
            pilot=pilots[entry['id']]
            for key in ('mesh','source','manifest','generator'):
                target=(root/pilot[key]).resolve()
                if not target.is_relative_to(root) or not target.is_file():
                    raise ValueError(f"Missing/unsafe model pilot {key}: {entry['id']}")
            manifest=json.loads((root/pilot['manifest']).read_text(encoding='utf-8'))
            if manifest['catalogue_id']!=entry['id']:
                raise ValueError(f"Model pilot identity mismatch: {entry['id']}")
            if hashlib.sha256((root/pilot['generator']).read_bytes()).hexdigest()!=manifest['generator_sha256']:
                raise ValueError(f"Stale model pilot generator: {entry['id']}")
            source_folder=(root/pilot['source']).parent.resolve()
            for name,expected_hash in manifest['source_sha256'].items():
                target=(source_folder/name).resolve()
                if not target.is_relative_to(source_folder) or hashlib.sha256(target.read_bytes()).hexdigest()!=expected_hash:
                    raise ValueError(f'Model pilot source checksum mismatch: {name}')
            folder=(root/pilot['manifest']).parent.resolve()
            for name,expected_hash in manifest['sha256'].items():
                target=(folder/name).resolve()
                if not target.is_relative_to(folder) or hashlib.sha256(target.read_bytes()).hexdigest()!=expected_hash:
                    raise ValueError(f'Model pilot output checksum mismatch: {name}')
            rows[-1].update(production_status='unintegrated_model_pilot',mesh=pilot['mesh'],
                            rig=pilot['rig'],animations=pilot['animations'],visual_pilot=pilot)
        if entry['id'] in combat_ids:
            rows[-1].update(production_status='provisional_combat_unplaced',
                            actor_class=behavior['class_prefix']+entry['id'].rsplit('-',1)[1],
                            combat_template=behavior['template']['class'],
                            combat_art='inherited_Mandinga_placeholder',campaign_spawning=False)
    result = {'schema_revision': 1, 'issue': 453, 'source_status': original['catalog_status'],
              'source_catalogue': decisions['source_catalogue'], 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
              'missing_original_material': original['missing_original_material'],
              'ids_are_engine_ids': False, 'caelith_new_references': 0,
              'presentation_preference': decisions['presentation_preference'], 'entries': rows}
    audit = {'issue': 453, 'verified_entries': len(rows), 'race_counts': dict(sorted(Counter(row['race'] for row in rows).items())),
             'population_counts': dict(sorted(Counter(row['population'] for row in rows).items())),
             'rare_repeatable_references': sum(row['rare_reference'] for row in rows),
             'unassigned_regions': sum(row['campaign_regions'] is None for row in rows),
             'runtime_actors_added': len(combat_ids), 'meshes_delivered': len(pilots),
             'unintegrated_visual_pilots': len(pilots)}
    return result, audit


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--require-regions', action='store_true')
    args = parser.parse_args()
    try:
        result, audit = assemble()
        encoded = (json.dumps(result, ensure_ascii=False, indent=2) + '\n').encode('utf-8')
        path = ROOT / 'assets/bestiary/CATALOGUE.json'
        if args.check:
            if not path.is_file() or path.read_bytes() != encoded:
                raise ValueError('Generated bestiary catalogue is stale; run the builder')
        else:
            path.write_bytes(encoded)
        print(json.dumps(audit, indent=2))
        return int(args.require_regions and audit['unassigned_regions'] > 0)
    except (OSError, KeyError, ValueError) as exc:
        print(f'Bestiary validation failed: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
