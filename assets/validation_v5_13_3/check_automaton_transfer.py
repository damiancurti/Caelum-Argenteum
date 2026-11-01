"""Check the profile boundary against an actual native controlled-automaton save."""
import argparse
import copy
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_profile_graph import NativeSchema,PersonalGraph,native_archive
from caelum_profiles import ProfileError

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--save',required=True,type=Path)
    parser.add_argument('--runtime',required=True,type=Path)
    parser.add_argument('--engine-package',required=True,type=Path)
    args=parser.parse_args()
    graph=PersonalGraph(NativeSchema(args.engine_package,args.runtime))
    _,_,level=native_archive(args.save)
    cargo=[o for o in level['objects'] if o.get('class:CaelumAutomatonLink',{}).get('Body') is not None]
    assert len(cargo)==1 and cargo[0]['class:CaelumAutomatonLink']['Body'] is not None
    for phase in ('active',):
        sample=copy.deepcopy(level)
        item=next(o['class:CaelumAutomatonLink'] for o in sample['objects'] if o.get('class:CaelumAutomatonLink',{}).get('Body') is not None)
        try:
            graph.transfer_ready(sample,0)
        except ProfileError as error:
            assert str(error)=='Release the campaign object before transfer: CaelumAutomatonLink',str(error)
        else:
            raise AssertionError('A controlled world actor must not leave its campaign in a profile')
    # A cleared reference is the native release state. Only a detached diagnostic
    # copy is modified; the original common save remains byte-for-byte unchanged.
    released=copy.deepcopy(level)
    next(o['class:CaelumAutomatonLink'] for o in released['objects'] if o.get('class:CaelumAutomatonLink',{}).get('Body') is not None).pop('Body')
    graph.transfer_ready(released,0)
    print(json.dumps({'passed':True,'checks':2,'original_save_modified':False}))

if __name__=='__main__':
    main()
