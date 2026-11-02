"""Verify profile transfer refuses an unresolved native giant-furniture drop."""
import argparse
import copy
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from caelum_profile_graph import NativeSchema, PersonalGraph, native_archive
from caelum_profiles import ProfileError


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--save', required=True, type=Path)
    p.add_argument('--runtime', required=True, type=Path)
    p.add_argument('--engine-package', required=True, type=Path)
    args = p.parse_args()
    graph = PersonalGraph(NativeSchema(args.engine_package, args.runtime))
    _, _, level = native_archive(args.save)
    cargo = next(o['class:CaelumStarCargo'] for o in level['objects']
                 if 'class:CaelumStarCargo' in o and o['class:CaelumStarCargo'].get('PendingDrop'))
    assert next((v for k,v in cargo.items() if k.lower()=='pending'), None), 'Native pending drop must retain the original item reference'
    try:
        graph.transfer_ready(level, 0)
    except ProfileError as error:
        assert 'CaelumStarCargo' in str(error), str(error)
    else:
        raise AssertionError('Unresolved giant-furniture release allowed profile transfer')
    released = copy.deepcopy(level)
    for obj in released['objects']:
        if 'class:CaelumStarCargo' in obj:
            obj['class:CaelumStarCargo']['PendingDrop'] = False
    graph.transfer_ready(released, 0)
    print(json.dumps({'passed': True, 'checks': 2, 'original_save_modified': False}))


if __name__ == '__main__':
    main()
