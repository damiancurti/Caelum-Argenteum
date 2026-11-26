"""Generate the approved finale eligibility constants, without scene activation."""
from pathlib import Path
import argparse
import json

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = 'src/caelum/data/CaelumCampaignFinaleData.zs'
FACTIONS = {'unitarians': 'FACTION_UNITARIOS', 'federals': 'FACTION_FEDERALS',
            'free_peoples': 'FACTION_PUEBLOS_LIBRES', 'sun_warriors': 'FACTION_SUN_WARRIORS'}


def render(root=ROOT):
    plan = json.loads((root / 'assets/campaign/PROGRESSION.json').read_text(encoding='utf-8'))
    finale = plan['finale']; cooperative = finale['cooperative_eligibility']
    cards = json.loads((root / 'assets/manifests/tarot_78_v4369.json').read_text(encoding='utf-8-sig'))['cards']
    ids = {card['card_id'] for card in cards}
    if (finale['condition_operator'] != 'AND' or finale['reputation_track_operator'] != 'ANY'
            or finale['faction_membership_required'] or set(finale['reputation_track']) != set(FACTIONS)
            or len(finale['reputation_track']) != len(FACTIONS)
            or finale['acquired_essence_minimum'] != len(ids) or set(finale['mandatory_essence_ids']) != ids
            or cooperative['operator'] != 'ANY_PARTICIPANT'
            or not cooperative['same_participant_must_meet_both_requirements']
            or not cooperative['group_travel_consent_required']
            or cooperative['copy_personal_essences_or_reputation']
            or finale['requirement_checkpoint'] != 'before_selene_combat_on_moon'
            or finale['lunar_travel_requires_finale_eligibility']):
        raise ValueError('Finale eligibility contract changed; review its implementation.')
    minimum = finale['reputation_minimum']
    if type(minimum) is not int: raise ValueError('Reputation threshold must be an authored integer.')
    lines = ['// Generado desde PROGRESSION.json; no activa escenas ni viajes.',
             'class CaelumCampaignFinaleData : Object', '{',
             f'    const REQUIRED_ESSENCES={finale["acquired_essence_minimum"]};',
             f'    const MINIMUM_REPUTATION={minimum};',
             f'    const FACTION_COUNT={len(FACTIONS)};',
             '    static clearscope int Faction(int index)', '    {', '        switch(index)', '        {']
    lines += [f'        case {i}:return CaelumConstants.{FACTIONS[name]};' for i,name in enumerate(finale['reputation_track'])]
    lines += ['        }', '        return -1;', '    }', '}']
    return ('\n'.join(lines) + '\n').encode('utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--check', action='store_true')
    args = parser.parse_args(); data = render(); path = ROOT / OUTPUT
    if args.check:
        if path.read_bytes() != data: raise SystemExit('Stale finale eligibility data; regenerate.')
    else: path.write_bytes(data)
    print('Verified approved acquired-essence/reputation eligibility data; no scene activation.')


if __name__ == '__main__':
    main()
