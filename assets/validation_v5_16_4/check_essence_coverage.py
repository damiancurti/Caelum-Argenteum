"""Exercise authored-contract failures without altering project or runtime data."""
from copy import deepcopy
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from assets.generators.build_essence_coverage import assemble, build, encoded, INPUTS


def main():
    manifest, plan, policy = [json.loads((ROOT / name).read_text(encoding='utf-8-sig')) for name in INPUTS]
    cards = manifest['cards']
    rows, result = assemble(cards, plan, policy)
    assert not result['errors'] and not result['complete']
    assert result['preserved_source_ids'] == [0, 36, 60]
    assert len(result['unassigned_acquisition_ids']) == 75
    assert len(result['unassigned_chapter_ids']) == 54
    assert len(rows) == 78 and encoded(build()) == encoded(build())
    cases = []

    def rejected(name, changed_cards, changed_plan, changed_policy):
        _, report = assemble(changed_cards, changed_plan, changed_policy)
        assert report['errors'], name
        cases.append({'case': name, 'rejected': True, 'errors': report['errors']})

    changed = deepcopy(cards); changed[-1]['card_id'] = 0
    rejected('Duplicate and missing canonical identity', changed, plan, policy)
    changed = deepcopy(plan); changed['finale']['world_acquisition']['requires_acquired_essence_ids'][-1] = 21
    rejected('World locked behind itself', cards, changed, policy)
    changed = deepcopy(plan); changed['established_route']['nodes'][0]['map'] = 'UNAUTHORED'
    rejected('Protected opening source moved', cards, changed, policy)
    changed = deepcopy(policy); changed['permanent_loss_allowed'] = True
    rejected('Required essence permanently lost', cards, plan, changed)
    changed = deepcopy(policy); changed['runtime_enabled'] = True
    rejected('Coverage ledger activates gameplay', cards, plan, changed)
    print(json.dumps({'positive': '78 IDs; 22/56 split; 3 preserved; 75 pending; 54 unassigned chapters',
                      'determinism': True, 'negative_cases': cases}, indent=2))


if __name__ == '__main__':
    main()
