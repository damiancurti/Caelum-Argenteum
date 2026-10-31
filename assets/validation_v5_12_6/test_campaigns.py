"""Transactional campaign custody checks using real native saves (#434)."""
from concurrent.futures import ThreadPoolExecutor
import copy
import datetime
import json
from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore,ProfileError
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns,unpack,pack,personal_record

RUNTIME=Path(sys.argv[1]).resolve();SOURCE=Path(sys.argv[2]).resolve();DATA=SOURCE.read_bytes()
ADAPTER=PersonalGraph(NativeSchema(Path('C:/Program Files (x86)/GZDoom/gzdoom.pk3'),RUNTIME))
RUN=ROOT/'build/issue434'/datetime.datetime.now().strftime('campaigns-%Y%m%d-%H%M%S-%f')
RUN.mkdir(parents=True);sys.argv[1:]=[]


class CampaignTests(unittest.TestCase):
    def setUp(self):
        self.directory=RUN/self._testMethodName;self.directory.mkdir()
        self.store=ProfileStore(self.directory/'profiles.sqlite3',create=True)
        self.campaigns=Campaigns(self.store,ADAPTER)
        self.a=self.campaigns.register('a',DATA)
        members,name,level=unpack(DATA);personal_record(level,1)['ProfileCommitted']=False
        self.b=self.campaigns.register('b',pack(members,name,level))
        self.identity=self.store.connection.execute("SELECT identity FROM campaign_slots WHERE campaign='a' AND player=0").fetchone()[0]

    def tearDown(self):
        self.store.close();self.assertEqual(SOURCE.read_bytes(),DATA)

    def stage(self,token='one'):return self.campaigns.stage(self.identity,'b',1,token)

    def verified(self,row):
        source=self.store.anchor(row['source_draft'])
        members,name,level=unpack(self.store.anchor(row['destination_draft']))
        record=personal_record(level,1);record['ProfileImportApplied']=record['ProfileImportSerial']
        return source,pack(members,name,level)

    def test_register_preserves_original_and_binds_all_slots(self):
        self.assertEqual(self.store.anchor(self.store._snapshot(DATA,0)),DATA)
        level=self.campaigns.validate('a',self.store.anchor(self.a['snapshot']),current=True)
        self.assertNotEqual(personal_record(level,0)['ExternalProfileId'],personal_record(level,1)['ExternalProfileId'])
        with self.assertRaises(ProfileError):self.campaigns.register('a',DATA)
        with self.assertRaises(ProfileError):self.campaigns.register('c',self.store.anchor(self.a['snapshot']))

    def test_staging_does_not_publish_or_change_custody(self):
        row=self.stage()
        self.assertEqual(row,self.stage())
        self.assertEqual(self.store.get(self.identity).campaign,'a')
        self.assertEqual(self.campaigns.head('a'),self.a);self.assertEqual(self.campaigns.head('b'),self.b)
        with self.assertRaises(ProfileError):self.campaigns.unlocked('a')
        with self.assertRaises(ProfileError):self.stage('two')
        with self.assertRaises(ProfileError):self.campaigns.checkpoint('a',self.store.anchor(self.a['snapshot']),0)

    def test_departure_removes_packed_contents_and_money(self):
        row=self.stage();_,_,level=unpack(self.store.anchor(row['source_draft']))
        owner=level['players'][0]['mo'];body=level['objects'][owner]
        self.assertTrue(body['class:CaelumPlayer']['ProfileDeparted'])
        record=personal_record(level,0)
        self.assertTrue(record['HouseRestitutionConfirmed']);self.assertEqual(record['PalomoMerchantStock'][0],23)
        active={i for group in level['thinkers'] for i in group}
        for i,obj in enumerate(level['objects']):
            if obj['classtype'] in ('CaelumPortableSmallTable','CaelumFoodRation'):
                self.assertNotIn(i,active)
        cursor=body.get('inventory')
        while cursor is not None:
            obj=level['objects'][cursor]
            self.assertFalse(ADAPTER.personal_item(obj) and obj['classtype']!='CaelumPersistentCharacterState')
            cursor=obj.get('inventory')

    def test_refuse_occupied_slot_and_unverified_import(self):
        with self.assertRaises(ProfileError):self.campaigns.stage(self.identity,'b',0,'occupied')
        row=self.stage()
        with self.assertRaisesRegex(ProfileError,'reconciliation'):
            self.campaigns.finish('one',self.store.anchor(row['source_draft']),self.store.anchor(row['destination_draft']))
        self.assertEqual(self.campaigns.head('a'),self.a)
        self.assertEqual(self.store.get(self.identity).revision,0)

    def test_atomic_commit_idempotence_and_old_checkpoint_refusal(self):
        row=self.stage();source,destination=self.verified(row)
        result=self.campaigns.finish('one',source,destination)
        self.assertEqual(result,self.campaigns.finish('one',source,destination))
        self.assertEqual((self.store.get(self.identity).campaign,self.store.get(self.identity).player),('b',1))
        self.campaigns.validate('a',source,current=True);self.campaigns.validate('b',destination,current=True)
        with self.assertRaises(ProfileError):self.campaigns.validate('a',self.store.anchor(self.a['snapshot']),current=True)
        with self.assertRaises(ProfileError):self.campaigns.checkpoint('a',self.store.anchor(self.a['snapshot']),1)
        self.assertEqual(self.campaigns.head('a')['revision'],1)

    def test_another_participant_cannot_disappear_on_commit(self):
        row=self.stage();source,destination=self.verified(row)
        members,name,level=unpack(destination)
        personal_record(level,0)['ExternalProfileId']='forged'
        with self.assertRaises(ProfileError):self.campaigns.finish('one',source,pack(members,name,level))
        self.assertEqual(self.campaigns.head('a'),self.a);self.assertEqual(self.campaigns.head('b'),self.b)
        self.assertEqual(self.store.get(self.identity).campaign,'a')

    def test_cancel_keeps_originals_and_releases_only_its_reservation(self):
        self.stage();self.campaigns.cancel('one')
        self.campaigns.unlocked('a');self.campaigns.unlocked('b')
        self.assertEqual(self.campaigns.head('a'),self.a)
        self.assertEqual(self.campaigns.head('b'),self.b)
        self.assertEqual(self.store.get(self.identity).campaign,'a')
        self.stage('new-attempt')

    def test_checkpoint_compare_and_swap_and_identity_refusal(self):
        data=self.store.anchor(self.a['snapshot'])
        changed=self.campaigns.checkpoint('a',data,0)
        self.assertEqual(changed['revision'],1)
        with self.assertRaises(ProfileError):self.campaigns.checkpoint('a',data,0)
        with self.assertRaises(ProfileError):self.campaigns.checkpoint('a',DATA,1)

    def test_native_results_cannot_restore_materials_in_departed_world(self):
        row=self.stage();source,destination=self.verified(row)
        members,name,level=unpack(self.store.anchor(self.a['snapshot']))
        personal_record(level,0)['ProfileDeparted']=True
        with self.assertRaisesRegex(ProfileError,'material inventory'):
            self.campaigns.finish('one',pack(members,name,level),destination)
        self.assertEqual(self.store.get(self.identity).campaign,'a')

    def test_reenroll_newer_bytes_does_not_create_another_identity(self):
        original=self.store.enroll(DATA,0,'legacy','one')
        members,name,level=unpack(DATA);level['time']=level.get('time',0)+1
        again=self.store.enroll(pack(members,name,level),0,'legacy','same owner')
        self.assertEqual(original.identity,again.identity)

    def test_active_crafting_can_save_but_cannot_transfer_reserved_items(self):
        members,name,level=unpack(self.store.anchor(self.a['snapshot']))
        body=level['objects'][level['players'][0]['mo']]
        body['class:CaelumPlayer']['CraftingTaskActive']=1
        data=pack(members,name,level)
        self.campaigns.checkpoint('a',data,0)
        with self.assertRaisesRegex(ProfileError,'active operation'):self.stage()
        self.assertEqual(self.store.get(self.identity).campaign,'a')

    def test_cancelled_transfer_cannot_be_published_later(self):
        row=self.stage();source,destination=self.verified(row);self.campaigns.cancel('one')
        with self.assertRaisesRegex(ProfileError,'Cancelled'):
            self.campaigns.finish('one',source,destination)
        self.assertEqual(self.campaigns.head('a'),self.a)

    def test_script_booleans_and_native_booleans_keep_distinct_formats(self):
        row=self.stage();_,_,level=unpack(self.store.anchor(row['source_draft']))
        self.assertIs(type(personal_record(level,0)['ProfileDeparted']),int)
        self.assertEqual(personal_record(level,0)['ProfileDeparted'],1)
        self.assertIs(type(level['multiplayer']),bool)


if __name__=='__main__':
    result=unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(CampaignTests))
    (RUN/'results.json').write_text(json.dumps(dict(issue=434,tests=result.testsRun,failures=len(result.failures),
        errors=len(result.errors),scope='Transaction checks; simulated native acknowledgement in unit tests'),indent=2),encoding='utf-8')
    raise SystemExit(not result.wasSuccessful())
