"""Verify native completion/identity flags from an isolated600-resident save.

This is a read-only end-state audit, not evidence of simultaneous stationary
posts. Production AdvanceDeployment/CrewPost own their physical arrival checks.
"""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('save', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    with zipfile.ZipFile(args.save) as archive:
        data = json.loads(archive.read('map03.map.json'))
    objects = data['objects']
    city = next(o for o in objects if o.get('classtype') == 'CA454CrowdCity')
    port = city['class:CaelumPortSiege']
    probe = next(o['class:CA454CrowdProbe'] for o in objects if o.get('classtype') == 'CA454CrowdProbe')
    population = next(o['class:CaelumPopulationState'] for o in objects if o.get('classtype') == 'CaelumPopulationState')
    refs = port['Defenders']; errors = []; rows = []
    if len(refs) != 600 or len(set(refs)) != 600:
        errors.append('Expected600 distinct defender references')
    for identity, ref in enumerate(refs):
        body = objects[ref]; route = body.get('class:CaelumPortDefender', {})
        residence_ref = route.get('Residence')
        residence = objects[residence_ref].get('class:CaelumHouseResident', {}) if isinstance(residence_ref, int) else {}
        row = {'identity': identity, 'saved_identity': route.get('HomeIdentity'), 'health': body.get('health'),
               'deployment_complete': bool(route.get('DeploymentComplete')), 'crew_route_pending': bool(route.get('FollowingCrewRoute')),
               'gun_operator': route.get('Gun') is not None, 'position': body.get('pos')}
        if body.get('classtype') != 'CaelumPortDefender' or row['saved_identity'] != identity or not row['health'] or row['health'] <= 0:
            errors.append(f'Invalid retained living defender{identity}')
        if not row['deployment_complete'] or row['crew_route_pending']:
            errors.append(f'Incomplete physical deployment{identity}')
        if residence.get('Body', residence.get('body')) != ref:
            errors.append(f'Resident reference mismatch{identity}')
        rows.append(row)
    operators = sum(row['gun_operator'] for row in rows)
    if operators != 72: errors.append(f'Expected72 operators, found{operators}')
    if not port.get('HighDensity') or not population.get('HighDensity') or population.get('LivingCombatants', 0) < 500:
        errors.append('Authoritative high-density mode not active')
    report = {'issue': 454, 'scope': __doc__.strip(), 'save_sha256': hashlib.sha256(args.save.read_bytes()).hexdigest(),
              'elapsed': probe['elapsed'], 'native_map_time': data['maptime'], 'defenders': len(refs), 'operators': operators,
              'living_census': population['LivingCombatants'], 'errors': errors, 'passed': not errors, 'bodies': rows}
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: v for k, v in report.items() if k != 'bodies'}))
    raise SystemExit(bool(errors))


if __name__ == '__main__':
    main()
