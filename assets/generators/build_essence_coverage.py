"""Audit all campaign acquisition IDs without inventing unauthored placements.

Chapter allocation and World prerequisites come from #452's approved graph.
Existing card identities come from the canonical Tarot manifest. This authoring
audit does not place content or establish full geographic reachability. Only the
approved final-card acquisition prerequisite is exported for the capture service.
"""
from pathlib import Path
import argparse
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = 'assets/campaign/ESSENCE_COVERAGE.json'
NATIVE_OUTPUT = 'src/caelum/data/CaelumEssenceAcquisitionData.zs'
INPUTS = ('assets/manifests/tarot_78_v4369.json',
          'assets/campaign/PROGRESSION.json', 'assets/campaign/ESSENCE_POLICY.json')


def assemble(cards, plan, policy):
    errors = []

    def check(condition, message):
        if not condition: errors.append(message)

    ids = [row['card_id'] for row in cards]
    check(len(ids) == 78 and set(ids) == set(range(78)), 'Catalogue must cover each ID 0..77 exactly once.')
    check(sum(row['arcana'] == 'major' for row in cards) == 22, 'Expected 22 Major essences.')
    check(sum(row['arcana'] == 'minor' for row in cards) == 56, 'Expected 56 Minor essences.')
    check(policy['runtime_enabled'] is False, 'This coverage ledger cannot activate gameplay.')
    for field in ('permanent_loss_allowed', 'automatic_grant', 'duplicate_ownership'):
        check(policy[field] is False, f'Approved recovery contract changed: {field}.')
    check(not policy['placement_assignments'], 'New placement assignments require an explicit integration/audit revision.')
    nodes = plan['established_route']['nodes']
    opening = {row['essence_id']: row for row in nodes}
    check(len(nodes) == len(opening) == 3 and {key: row['map'] for key, row in opening.items()}
          == {0: 'MAP01', 36: 'MAP02', 60: 'MAP03'}, 'Protected opening sources changed.')
    chapters, anchors = {}, {}
    for chapter in plan['chapters']:
        for card in chapter['major_essence_ids']:
            check(card not in chapters, f'Duplicate Major allocation: {card}.')
            chapters[card] = chapter['id']
        anchors.update({int(key): value for key, value in chapter['major_story_anchors'].items()})
    check(set(chapters) == {row['card_id'] for row in cards if row['arcana'] == 'major'},
          'Major allocation must cover the canonical 22 identities.')
    world = plan['finale']['world_acquisition']
    requirements = world['requires_acquired_essence_ids']
    check(plan['progression_policy']['final_card_id'] == 21 and world['region'] == 'Moon',
          'World must remain the final lunar card.')
    check(len(requirements) == 77 and set(requirements) == set(range(78)) - {21},
          'World requires the other 77 identities, never itself.')
    check(world['grant_automatically'] is False, 'World still requires an acquisition.')
    rows = []
    for card in sorted(cards, key=lambda row: row['card_id']):
        card_id = card['card_id']; source = opening.get(card_id)
        rows.append({'card_id': card_id, 'arcana': card['arcana'],
                     'catalogue_rank': card['rank'], 'catalogue_suit': card['suit'],
                     'chapter': source['chapter'] if source else chapters.get(card_id),
                     'approved_story_anchor': anchors.get(card_id),
                     'approved_region': world['region'] if card_id == 21 else None,
                     'acquisition_status': 'existing_source_preserved' if source else 'exact_assignment_required',
                     'map': source['map'] if source else None,
                     'opening_route_node': source['id'] if source else None,
                     'requires_acquired_essence_ids': requirements if card_id == 21 else None,
                     'recovery_policy': 'preserve_existing' if source else 'recoverable_without_automatic_grant',
                     'authored_alternative_route': None})
    missing = [row['card_id'] for row in rows if row['acquisition_status'] == 'exact_assignment_required']
    report = {'issue': 456, 'errors': errors, 'covered_id_count': len(set(ids)),
              'major_count': sum(row['arcana'] == 'major' for row in cards),
              'minor_count': sum(row['arcana'] == 'minor' for row in cards),
              'preserved_source_ids': sorted(opening), 'unassigned_acquisition_ids': missing,
              'unassigned_chapter_ids': [row['card_id'] for row in rows if row['chapter'] is None],
              'world_prerequisite_ids': requirements,
              'full_campaign_reachability': 'not_established',
              'complete': not errors and not missing}
    return rows, report


def build(root=ROOT):
    root = Path(root)
    blobs = [(root / name).read_bytes() for name in INPUTS]
    manifest, plan, policy = [json.loads(blob.decode('utf-8-sig')) for blob in blobs]
    rows, report = assemble(manifest['cards'], plan, policy)
    return {'schema_revision': 1, 'issue': 456, 'runtime_enabled': False,
            'input_hash_format': 'SHA-256 of canonical-LF text bytes; any UTF-8 BOM is preserved.',
            'inputs': {name: hashlib.sha256(blob.replace(b'\r\n', b'\n')).hexdigest() for name, blob in zip(INPUTS, blobs)},
            'null_fields_mean': 'Unauthored or not specified here; never an absent gameplay requirement.',
            'scope': 'Canonical ID coverage and approved allocation only; existing source gates stay authoritative.',
            'entries': rows, 'audit': report}


def encoded(data):
    return (json.dumps(data, ensure_ascii=False, indent=2) + '\n').encode('utf-8')


def native_data(data):
    if data['audit']['errors']:
        raise ValueError('Cannot export an invalid essence contract.')
    final = [row for row in data['entries'] if row['requires_acquired_essence_ids'] is not None]
    if len(final) != 1:
        raise ValueError('Expected exactly one approved final-card prerequisite.')
    row = final[0]
    return ('''// #456: generado desde PROGRESSION.json y el catálogo; no coloca esencias.
class CaelumEssenceAcquisitionData : Object
{
    const FINAL_CARD = %d;
    const FINAL_PREREQUISITE_COUNT = %d;
}
''' % (row['card_id'], len(row['requires_acquired_essence_ids']))).encode('utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--require-complete', action='store_true')
    args = parser.parse_args(); data = build()
    for name, blob in ((OUTPUT, encoded(data)), (NATIVE_OUTPUT, native_data(data))):
        target = ROOT / name
        if args.check:
            if not target.is_file() or target.read_bytes() != blob: raise SystemExit('Stale essence output: ' + name)
        else: target.write_bytes(blob)
    print(json.dumps(data['audit'], indent=2))
    return int(bool(data['audit']['errors'] or (args.require_complete and not data['audit']['complete'])))


if __name__ == '__main__':
    raise SystemExit(main())
