"""Custody, recovery and manifest boundaries using real native profile anchors."""
from pathlib import Path
import contextlib,copy,datetime,io,json,sys,unittest
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore,ProfileError
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns,unpack,pack,personal_record
from caelum_sessions import Sessions,manifest,verify_manifest
from caelum_transfer_verify import verify_transfer
import caelum_session_menu
sys.path.insert(0,str(ROOT/"assets/validation_v5_12_6"))
from campaign_fixture import independent_world

runtime=Path(sys.argv[1]).resolve();source=Path(sys.argv[2]).resolve();original=source.read_bytes()
adapter=PersonalGraph(NativeSchema(Path('C:/Program Files (x86)/GZDoom/gzdoom.pk3'),runtime))
out=ROOT/'build/issue435'/datetime.datetime.now().strftime('transactions-%Y%m%d-%H%M%S-%f');out.mkdir()
sys.argv[1:]=[]
FILES={'revision':1,'files':[],'explicit_packages':1}


class SessionTests(unittest.TestCase):
    def setUp(self):
        self.path=out/self._testMethodName;self.path.mkdir()
        self.store=ProfileStore(self.path/'profiles.sqlite3',create=True)
        self.worlds=Campaigns(self.store,adapter);self.head=self.worlds.register('world',original)
        self.sessions=Sessions(self.worlds)

    def tearDown(self):
        self.store.close();self.assertEqual(source.read_bytes(),original)

    def prepare(self):return self.sessions.prepare('world',FILES,'one')

    def modified(self):
        members,name,level=unpack(self.store.anchor(self.head['snapshot']))
        coin=next(o for o in level['objects'] if o.get('classtype')=='CaelumCopperCoin');coin['class:Inventory']['Amount']+=12
        return pack(members,name,level)

    def test_prepare_is_idempotent_and_reserves_campaign(self):
        first=self.prepare();self.assertEqual(first,self.prepare())
        with self.assertRaises(ProfileError):self.sessions.prepare('world',FILES,'second')
        with self.assertRaises(ProfileError):self.worlds.checkpoint('world',self.modified(),0)
        self.assertEqual(self.worlds.head('world'),self.head)

    def test_publish_closed_token_cannot_overwrite_new_session(self):
        self.prepare();published=self.sessions.publish('one',self.modified(),0)
        self.assertEqual(published['revision'],1)
        result=self.sessions.close('one');self.assertEqual(result['recovery'],published)
        self.sessions.prepare('world',FILES,'two')
        with self.assertRaises(ProfileError):self.sessions.publish('one',self.store.anchor(self.head['snapshot']),1)
        self.assertEqual(self.worlds.head('world'),published)

    def test_corrupt_or_wrong_owner_cannot_replace_recovery(self):
        self.prepare()
        with self.assertRaises(ProfileError):self.sessions.publish('one',b'broken',0)
        members,name,level=unpack(self.store.anchor(self.head['snapshot']))
        personal_record(level,1)['ExternalProfileId']=personal_record(level,0)['ExternalProfileId']
        with self.assertRaises(ProfileError):self.sessions.publish('one',pack(members,name,level),0)
        self.assertEqual(self.worlds.head('world'),self.head)

    def test_native_desync_cannot_replace_valid_recovery(self):
        self.prepare()
        members,name,level=unpack(self.store.anchor(self.head['snapshot']))
        for slot in range(len(level['players'])):
            bad=copy.deepcopy(level);bad['players'][slot]['inconsistant']=72
            with self.assertRaisesRegex(ProfileError,'desynchronization'):
                self.sessions.publish('one',pack(members,name,bad),0)
            self.assertEqual(self.worlds.head('world'),self.head)
        self.assertEqual(self.sessions.close('one')['recovery'],self.head)

    def test_native_desync_seed_cannot_start_session(self):
        members,name,level=unpack(original)
        level['players'][1]['inconsistant']=72
        path=self.path/'rejected.sqlite3'
        store=ProfileStore(path,create=True)
        try:
            worlds=Campaigns(store,adapter);head=worlds.register('bad',pack(members,name,level))
            with self.assertRaisesRegex(ProfileError,'desynchronization'):
                Sessions(worlds).prepare('bad',FILES,'bad-session')
            self.assertEqual(worlds.head('bad'),head)
            self.assertEqual(store.connection.execute('SELECT COUNT(*) FROM campaign_locks').fetchone()[0],0)
        finally:store.close()

    def test_source_identity_remains_unique_during_session(self):
        self.prepare();members,name,level=unpack(independent_world(original,'session-destination'));personal_record(level,1)['ProfileCommitted']=0
        self.worlds.register('destination',pack(members,name,level))
        identity=personal_record(unpack(self.store.anchor(self.head['snapshot']))[2],0)['ExternalProfileId']
        with self.assertRaises(ProfileError):self.worlds.stage(identity,'destination',1,'transfer')
        self.assertEqual(self.store.get(identity).campaign,'world')

    def test_live_process_blocks_close_and_repeated_slot_claim(self):
        self.prepare();self.sessions.claim('one',0)
        with self.assertRaises(ProfileError):self.sessions.close('one')
        with self.assertRaises(ProfileError):self.sessions.claim('one',0)
        self.sessions.finished('one',0);self.sessions.close('one')
        with self.assertRaises(ProfileError):self.sessions.claim('one',1)

    def test_checkpoint_cas_and_identical_save_are_idempotent(self):
        self.prepare();data=self.modified();first=self.sessions.publish('one',data,0)
        self.assertEqual(first,self.sessions.publish('one',data,1))
        with self.assertRaises(ProfileError):self.sessions.publish('one',self.store.anchor(self.head['snapshot']),0)
        self.assertEqual(self.worlds.head('world'),first)

    def test_export_never_overwrites_original_or_closed_session(self):
        request=self.prepare();target=self.path/'bundle';self.sessions.export('one',target)
        self.assertEqual((target/'recovery.zds').read_bytes(),self.store.anchor(request['request']['head']['snapshot']))
        with self.assertRaises(FileExistsError):self.sessions.export('one',target)
        self.sessions.close('one')
        with self.assertRaises(ProfileError):self.sessions.export('one',self.path/'later')

    def test_unknown_session_schema_is_not_reset(self):
        self.store.connection.execute('UPDATE network_session_schema SET revision=99')
        with self.assertRaises(ProfileError):Sessions(self.worlds)
        self.assertEqual(self.store.connection.execute('SELECT revision FROM network_session_schema').fetchone()[0],99)

    def test_manifest_checks_order_and_exact_bytes_not_paths(self):
        directory=self.path/'engine';directory.mkdir()
        names=['gzdoom.exe','gzdoom.pk3','game_support.pk3','game_widescreen_gfx.pk3','doom.wad','a.pk3','b.pk3']
        for name in names:(directory/name).write_bytes(name.encode())
        engine=directory/'gzdoom.exe';iwad=directory/'doom.wad';packages=[directory/'a.pk3',directory/'b.pk3']
        recorded=manifest(engine,iwad,packages);verify_manifest(recorded,engine,iwad,packages)
        with self.assertRaises(ProfileError):verify_manifest(recorded,engine,iwad,list(reversed(packages)))
        packages[0].write_bytes(b'changed')
        with self.assertRaises(ProfileError):verify_manifest(recorded,engine,iwad,packages)

    def test_failed_native_transfer_remains_reserved_and_can_retry(self):
        members,name,level=unpack(independent_world(original,'retry-destination'))
        personal_record(level,1)['ProfileCommitted']=0
        target=self.worlds.register('destination',pack(members,name,level))
        identity=self.store.connection.execute("SELECT identity FROM campaign_slots WHERE campaign='world' AND player=0").fetchone()[0]
        staged=self.worlds.stage(identity,'destination',1,'retry')
        source_data=self.store.anchor(staged['source_draft'])
        with patch('caelum_transfer_verify.native_checkpoint',side_effect=[(source_data,{'passed':True}),ProfileError('injected peer failure')]):
            with self.assertRaisesRegex(ProfileError,'injected peer failure'):
                verify_transfer(self.worlds,'retry',self.path/'failed',Path('unused'),Path('unused'),[runtime])
        self.assertEqual(self.worlds.head('world'),self.head)
        self.assertEqual(self.worlds.head('destination'),target)
        self.assertEqual(self.store.get(identity).campaign,'world')
        self.assertIsNone(self.store.connection.execute("SELECT result FROM transfers WHERE token='retry'").fetchone()[0])
        self.assertEqual(self.store.connection.execute("SELECT COUNT(*) FROM campaign_locks WHERE token='retry'").fetchone()[0],2)
        members,name,level=unpack(self.store.anchor(staged['destination_draft']))
        record=personal_record(level,1);record['ProfileImportApplied']=record['ProfileImportSerial']
        destination_data=pack(members,name,level)
        arguments=['menu','--store',str(self.path/'profiles.sqlite3'),
            '--engine','C:/Program Files (x86)/GZDoom/gzdoom.exe',
            '--iwad','C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD',
            '--package',str(runtime),'--language','en']
        output=io.StringIO()
        with patch('caelum_transfer_verify.native_checkpoint',side_effect=[(source_data,{'passed':True}),(destination_data,{'passed':True})]), \
             patch.object(sys,'argv',arguments),patch('builtins.input',side_effect=['12','1','0']),contextlib.redirect_stdout(output):
            caelum_session_menu.main()
        self.assertIn('Transfer verified and published in both campaigns.',output.getvalue())
        self.assertEqual(self.store.get(identity).campaign,'destination')
        with self.assertRaisesRegex(ProfileError,'Fill every native slot'):
            self.sessions.prepare('world',FILES,'empty-source')
        with self.assertRaises(ProfileError):
            verify_transfer(self.worlds,'retry',self.path/'duplicate',Path('unused'),Path('unused'),[runtime])
        self.assertEqual(self.store.get(identity).revision,1)
        self.assertEqual(self.store.connection.execute('SELECT COUNT(*) FROM campaign_locks').fetchone()[0],0)


suite=unittest.defaultTestLoader.loadTestsFromTestCase(SessionTests)
result=unittest.TextTestRunner(verbosity=2).run(suite)
(out/'results.json').write_text(json.dumps(dict(issue=435,tests=result.testsRun,errors=[str(e) for e in result.errors],failures=[str(e) for e in result.failures],passed=result.wasSuccessful()),indent=2))
raise SystemExit(not result.wasSuccessful())
