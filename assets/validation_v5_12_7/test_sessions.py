"""Custody, recovery and manifest boundaries using real native profile anchors."""
from pathlib import Path
import copy,datetime,json,sys,unittest
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT))
from caelum_profiles import ProfileStore,ProfileError
from caelum_profile_graph import NativeSchema,PersonalGraph
from caelum_campaigns import Campaigns,unpack,pack,personal_record
from caelum_sessions import Sessions,manifest,verify_manifest

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

    def test_source_identity_remains_unique_during_session(self):
        self.prepare();members,name,level=unpack(original);personal_record(level,1)['ProfileCommitted']=0
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


suite=unittest.defaultTestLoader.loadTestsFromTestCase(SessionTests)
result=unittest.TextTestRunner(verbosity=2).run(suite)
(out/'results.json').write_text(json.dumps(dict(issue=435,tests=result.testsRun,errors=[str(e) for e in result.errors],failures=[str(e) for e in result.failures],passed=result.wasSuccessful()),indent=2))
raise SystemExit(not result.wasSuccessful())
