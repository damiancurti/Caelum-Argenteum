"""Ownership and refusal checks against a real native checkpoint (#434)."""
from pathlib import Path
import copy
import hashlib
import json
import sys
import unittest

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_profile_graph import NativeSchema,PersonalGraph,native_archive
from caelum_profiles import ProfileError

RUNTIME=Path(sys.argv[1]).resolve()
SOURCE=Path(sys.argv[2]).resolve()
SCHEMA=NativeSchema(Path('C:/Program Files (x86)/GZDoom/gzdoom.pk3'),RUNTIME)
ADAPTER=PersonalGraph(SCHEMA)
_,_,LEVEL=native_archive(SOURCE)
ORIGINAL=SOURCE.read_bytes()
sys.argv[1:]=[]


def record(level,slot):
    owner=level['players'][slot]['mo']
    return next(o['class:CaelumPersistentCharacterState'] for o in level['objects']
                if o['classtype']=='CaelumPersistentCharacterState' and o['class:Inventory']['Owner']==owner)


class GraphTests(unittest.TestCase):
    def setUp(self):
        self.level=copy.deepcopy(LEVEL)
        self.graph=ADAPTER.capture(self.level,0)

    def tearDown(self):
        self.assertEqual(SOURCE.read_bytes(),ORIGINAL)
        self.assertEqual(LEVEL,native_archive(SOURCE)[2])

    def test_materials_are_not_world_controllers(self):
        types={o['classtype'] for o in self.graph['objects']}
        self.assertNotIn('CaelumWorldClock',types)
        self.assertNotIn('CaelumCardDuel',types)
        self.assertNotIn('CaelumArrivalHousehold',types)
        self.assertIn('CaelumPortableSmallTable',types)
        self.assertIn('CaelumFoodRation',types)
        for obj in self.graph['objects']:
            for _,target in SCHEMA.references(obj):
                self.assertTrue(target==-1 or 0<=target<len(self.graph['objects']))

    def test_refuses_to_replace_another_committed_character(self):
        before=copy.deepcopy(self.level)
        with self.assertRaises(ProfileError):
            ADAPTER.install(self.level,self.graph,1,'new-owner',0)
        self.assertEqual(self.level,before)

    def test_destination_world_unchanged_and_current_money_exact(self):
        record(self.level,1)['ProfileCommitted']=False
        before=copy.deepcopy(self.level)
        result=ADAPTER.install(self.level,self.graph,1,'new-owner',0)
        self.assertEqual(self.level,before)
        self.assertEqual(record(result,1)['PalomoMerchantStock'][0],91)
        self.assertFalse(record(result,1)['HouseRestitutionConfirmed'])
        self.assertEqual(result['checksum'],before['checksum'])
        for key in ('sectors','linedefs','sidedefs','zones','musicname'):
            self.assertEqual(result[key],before[key])
        money=[o for o in result['objects'] if o['classtype']=='CaelumCopperCoin'
               and o['class:Inventory']['Owner']==result['players'][1]['mo']]
        self.assertEqual(len(money),1)
        self.assertEqual(money[0]['class:Inventory']['Amount'],321)
        self.assertEqual(record(result,1)['IdentityAllocation'],result['objects'][result['players'][1]['mo']]['class:CaelumPlayer']['CharacterAllocation'])

    def test_foreign_owner_and_cycle_fail_closed(self):
        body=self.level['objects'][self.level['players'][0]['mo']]
        item=self.level['objects'][body['inventory']]
        item['class:Inventory']['Owner']=self.level['players'][1]['mo']
        with self.assertRaises(ProfileError):ADAPTER.capture(self.level,0)
        item['class:Inventory']['Owner']=self.level['players'][0]['mo']
        item['inventory']=body['inventory']
        with self.assertRaises(ProfileError):ADAPTER.capture(self.level,0)

    def test_unknown_field_is_not_guessed_as_a_number(self):
        record(self.level,0)['FutureOwnedReference']=321
        with self.assertRaisesRegex(ProfileError,'Unknown saved field'):
            ADAPTER.capture(self.level,0)

    def test_unknown_runtime_and_reference_refuse_without_mutation(self):
        record(self.level,1)['ProfileCommitted']=False
        before=copy.deepcopy(self.level)
        self.graph['packages']['runtime']='mismatch'
        with self.assertRaises(ProfileError):ADAPTER.install(self.level,self.graph,1,'new-owner',0)
        self.assertEqual(self.level,before)
        self.graph['packages']=SCHEMA.packages.copy()
        self.graph['objects'][self.graph['record']]['class:Inventory']['Owner']=999999
        with self.assertRaisesRegex(ProfileError,'unresolved object reference'):
            ADAPTER.install(self.level,self.graph,1,'new-owner',0)
        self.assertEqual(self.level,before)

    def test_nested_siblings_belong_to_container_not_to_each_other(self):
        table_index=next(i for i,o in enumerate(self.level['objects']) if o['classtype']=='CaelumPortableSmallTable')
        table=self.level['objects'][table_index]
        first_index=table['inventory']
        first=self.level['objects'][first_index]
        sibling=copy.deepcopy(first)
        sibling['inventory']=None
        sibling['class:Inventory']['Owner']=table_index
        self.level['objects'].append(sibling)
        first['inventory']=len(self.level['objects'])-1
        graph=ADAPTER.capture(self.level,0)
        owners=[o['class:Inventory']['Owner'] for o in graph['objects'] if o['classtype']==sibling['classtype']]
        self.assertGreaterEqual(len(owners),2)
        self.assertEqual(owners[-1],owners[-2])


if __name__=='__main__':unittest.main()
