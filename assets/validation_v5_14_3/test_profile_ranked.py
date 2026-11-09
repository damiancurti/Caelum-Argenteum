"""Verify ranking and tournament ownership against actual native checkpoints."""
from pathlib import Path
import copy, hashlib, sys, unittest
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_profile_graph import NativeSchema,PersonalGraph,native_archive
from caelum_profiles import ProfileError
RUNTIME,ACTIVE,RESULT,BRACKET=map(lambda s:Path(s).resolve(),sys.argv[1:5]);sys.argv[1:]=[]
ADAPTER=PersonalGraph(NativeSchema(Path('C:/Program Files (x86)/GZDoom/gzdoom.pk3'),RUNTIME))
LEVELS={p:native_archive(p)[2] for p in (ACTIVE,RESULT,BRACKET)}
ORIGINAL={p:hashlib.sha256(p.read_bytes()).hexdigest() for p in LEVELS}

def owned(level,slot,kind):
 body=level['players'][slot]['mo']
 return next(o for o in level['objects'] if o['classtype']==kind and o.get('class:Inventory',{}).get('Owner')==body)

def release_other_guards(level,slot):
 body=level['players'][slot]['mo']
 for obj in level['objects']:
  if obj.get('class:Inventory',{}).get('Owner')!=body:continue
  for kind,fields in ADAPTER.policy['transfer_blocked_inventory_fields'].items():
   for field in fields:obj.get('class:'+kind,{}).pop(field,None)

class RankedBoundaryTests(unittest.TestCase):
 def tearDown(self):
  for path,digest in ORIGINAL.items():self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(),digest)
 def test_active_ranked_match_blocks_transfer(self):
  level=copy.deepcopy(LEVELS[ACTIVE]);release_other_guards(level,0)
  with self.assertRaisesRegex(ProfileError,'CaelumCardSeat|CaelumTrucazoClaims'):ADAPTER.transfer_ready(level,0)
 def test_between_rounds_bracket_blocks_transfer_without_a_duel(self):
  level=copy.deepcopy(LEVELS[BRACKET]);release_other_guards(level,0)
  seat=owned(level,0,'CaelumCardSeat')['class:CaelumCardSeat']
  self.assertIsNone(seat.get('Duel'));self.assertIsNotNone(seat.get('Tournament'))
  with self.assertRaisesRegex(ProfileError,'CaelumCardSeat'):ADAPTER.transfer_ready(level,0)
 def test_personal_graph_carries_rating_and_choices_without_shared_match(self):
  graph=ADAPTER.capture(LEVELS[RESULT],0);types={o['classtype'] for o in graph['objects']}
  self.assertIn('CaelumTrucazoChoice',types)
  for kind in ('CaelumCardDuel','CaelumTrucazoCompetitive','CaelumTrucazoTournament'):self.assertNotIn(kind,types)
  record=graph['objects'][graph['record']]['class:CaelumPersistentCharacterState']
  self.assertEqual(record['TrucazoRatingRevision'],1);self.assertEqual(record['TrucazoRating'],1016)
 def test_rating_install_preserves_destination_world_and_other_player(self):
  graph=ADAPTER.capture(LEVELS[RESULT],0);destination=copy.deepcopy(LEVELS[RESULT])
  owned(destination,1,'CaelumPersistentCharacterState')['class:CaelumPersistentCharacterState']['ProfileCommitted']=False
  before=copy.deepcopy(destination);result=ADAPTER.install(destination,graph,1,'ranked-import',0)
  self.assertEqual(destination,before)
  for key in ('checksum','sectors','linedefs','sidedefs','zones','musicname'):self.assertEqual(result[key],before[key])
  self.assertEqual(owned(result,1,'CaelumPersistentCharacterState')['class:CaelumPersistentCharacterState']['TrucazoRating'],1016)
  self.assertEqual(owned(result,0,'CaelumPersistentCharacterState'),owned(before,0,'CaelumPersistentCharacterState'))

if __name__=='__main__':unittest.main()
