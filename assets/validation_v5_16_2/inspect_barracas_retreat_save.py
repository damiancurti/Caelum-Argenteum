"""Audit static exit basins and native saved withdrawal caches without mutation.

The optional preceding save verifies retained identities/assault lanes and the
initial closest-exit decision. This does not establish completed army movement.
"""
from pathlib import Path
import argparse
import collections
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[2]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def saved(path):
    with zipfile.ZipFile(path) as archive:
        data = json.loads(archive.read('map03.map.json'))
    objects = data['objects']
    city = next(o for o in objects if 'class:CaelumPortSiege' in o)
    entries = {}
    for ref in city['class:CaelumSiegeEncounter']['Attackers']:
        entry = objects[ref]['class:CaelumSiegeCombatant']
        body = objects[entry['Body']] if isinstance(entry.get('Body'), int) else {}
        identity = entry['StableIdentity']
        if identity in entries:
            raise ValueError('Duplicate native combatant identity')
        entries[identity] = entry, body
    return objects, city, entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--save', type=Path)
    parser.add_argument('--previous-save', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.previous_save and not args.save:
        parser.error('--previous-save requires --save')
    source = ROOT / 'assets/barracas_redesign/RETREAT.json'
    data = json.loads(source.read_text(encoding='utf-8'))
    digits = data['distance_digits']; unreachable = data['distance_unreachable']
    depths = [[[int(row[i:i + digits], 16) for i in range(0, len(row), digits)]
               for row in field['distance_rows']] for field in data['fields']]
    height, width = len(depths[0]), len(depths[0][0])

    def depth(front, point):
        if isinstance(point, dict):
            point = point['X'], point['Y']
        x = int((point[0] - data['bounds'][0]) // data['cell'])
        y = int((point[1] - data['bounds'][1]) // data['cell'])
        if not (0 <= x < width and 0 <= y < height):
            return -1
        value = depths[front][y][x]
        return -1 if value == unreachable else value

    def nearest(point):
        options = [(depth(front, point), front) for front in range(len(depths))]
        options = [pair for pair in options if pair[0] >= 0]
        return min(options)[1] * 2 if options else None

    errors = []; edges = 0; cells = 0
    offsets = {'N': (0, 1), 'S': (0, -1), 'E': (1, 0), 'W': (-1, 0)}
    choices = [[min(range(len(depths)), key=lambda f: (depths[f][y][x], f))
                for x in range(width)] for y in range(height)]
    for front, field in enumerate(data['fields']):
        for y, row in enumerate(field['rows']):
            for x, letter in enumerate(row):
                value = depths[front][y][x]
                if letter == '.':
                    if value != unreachable: errors.append(f'Non-ground cost {front}/{x}/{y}')
                    continue
                cells += 1
                if letter == 'G':
                    if value != 0: errors.append(f'Nonzero exit cost {front}')
                    continue
                dx, dy = offsets[letter]
                if value != depths[front][y + dy][x + dx] + 1:
                    errors.append(f'Nondecreasing edge {front}/{x}/{y}')
                if choices[y][x] == front:
                    edges += 1
                    if choices[y + dy][x + dx] != front:
                        errors.append(f'Contradictory exit basin {front}/{x}/{y}')
    report = {'issue': 454, 'data_sha256': digest(source), 'revision': data['schema_revision'],
              'reachable_costs_checked': cells, 'nearest_exit_edges_checked': edges}
    if args.save:
        _, city, entries = saved(args.save)
        previous = saved(args.previous_save)[2] if args.previous_save else None
        if previous is not None and entries.keys() != previous.keys():
            errors.append('Saved combatant identity set changed')
        retained = 0; assignments = collections.Counter()
        for identity, (entry, body) in entries.items():
            before, old_body = previous.get(identity, ({}, {})) if previous is not None else ({}, {})
            if before and entry['Lane'] != before['Lane']:
                errors.append(f'Assault lane changed for {identity}')
            if entry.get('Exited') or entry.get('ConfirmedDead') or body.get('health', 0) <= 0:
                continue
            retained += 1
            lane = entry['RetreatLane']; assignments[f"{entry['Lane']}->{lane}"] += 1
            if entry.get('RetreatRevision') != data['schema_revision'] or not entry.get('RetreatExitChosen'):
                errors.append(f'Incomplete ground migration {identity}')
            if lane not in range(0, len(depths) * 2, 2) or entry['ExitNode'] != city['class:CaelumPortSiege']['Exits'][lane]:
                errors.append(f'Foreign exit reference {identity}')
                continue
            for point_key, cost_key in [('RetreatCell', 'RetreatCellDistance'), ('RetreatPoint', 'RetreatDistance')]:
                actual = entry[cost_key]
                if actual >= 2 ** 31: actual -= 2 ** 32
                if actual != depth(lane // 2, entry[point_key]):
                    errors.append(f'Native cached cost differs {identity}/{cost_key}')
            if old_body and nearest(old_body['pos']) != lane:
                errors.append(f'Initial closest exit differs {identity}')
        report.update(save_sha256=digest(args.save), retained_living=retained,
                      total_identities=len(entries), assault_to_retreat_lanes=dict(assignments))
        if args.previous_save: report['previous_save_sha256'] = digest(args.previous_save)
    report.update(errors=errors, passed=not errors)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=2))
    raise SystemExit(bool(errors))


if __name__ == '__main__':
    main()
