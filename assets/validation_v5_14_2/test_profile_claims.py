"""Check #444 profile boundaries against native active and pending-award saves."""
from pathlib import Path
import copy, hashlib, json, sys, unittest
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from caelum_profile_graph import NativeSchema,PersonalGraph,native_archive
from caelum_profiles import ProfileError
RUNTIME,ACTIVE,PENDING=map(lambda s:Path(s).resolve(),sys.argv[1:4]);sys.argv[1:]=[]
SCHEMA=NativeSchema(Path('C:/Program Files (x86)/GZDoom/gzdoom.pk3'),RUNTIME)
ADAPTER=PersonalGraph(SCHEMA)
ACTIVE_LEVEL=native_archive(ACTIVE)[2];PENDING_LEVEL=native_archive(PENDING)[2]
ORIGINAL={p:hashlib.sha256(p.read_bytes()).hexdigest() for p in (ACTIVE,PENDING)}

def owned(level,slot,kind):
 body=level['players'][slot]['mo']
 return next(o for o in level['objects'] if o['classtype']==kind and o.get('class:Inventory',{}).get('Owner')==body)

def quiesce(level,slot):
 """Isolate the reservation guard from other already-tested activity guards."""
 body=level['players'][slot]['mo']
 for obj in level['objects']:
  if obj.get('class:Inventory',{}).get('Owner')!=body:continue
  for kind,fields in ADAPTER.policy['transfer_blocked_inventory_fields'].items():
   for field in fields:obj.get('class:'+kind,{}).pop(field,None)
  obj.get('class:CaelumCardSeat',{}).pop('Duel',None)

class ClaimBoundaryTests(unittest.TestCase):
 def tearDown(self):
  for p,digest in ORIGINAL.items():self.assertEqual(hashlib.sha256(p.read_bytes()).hexdigest(),digest)
 def test_active_reservation_blocks_even_without_seat(self):
  level=copy.deepcopy(ACTIVE_LEVEL);quiesce(level,0)
  with self.assertRaisesRegex(ProfileError,'CaelumTrucazoClaims'):ADAPTER.transfer_ready(level,0)
 def test_finished_prizes_capture_actual_vault_and_equipment(self):
  level=copy.deepcopy(PENDING_LEVEL);quiesce(level,0);ADAPTER.transfer_ready(level,0)
  graph=ADAPTER.capture(level,0);types={o['classtype'] for o in graph['objects']}
  self.assertIn('CaelumTrucazoVault',types);self.assertNotIn('CaelumCardDuel',types)
  claim=next(o['class:CaelumTrucazoClaims'] for o in graph['objects'] if o['classtype']=='CaelumTrucazoClaims')
  self.assertGreater(claim['Copper'],0);self.assertIsNone(claim.get('Reservation'))
  vault=claim['Vault'];item=graph['objects'][graph['objects'][vault]['inventory']]
  self.assertEqual(item['class:Inventory']['Owner'],vault)
  self.assertEqual(item['class:CaelumEquipmentItem']['Durability'],345)
  self.assertEqual(item['class:CaelumEquipmentItem']['EquipmentSize'],1)
  record=graph['objects'][graph['record']]['class:CaelumPersistentCharacterState']
  self.assertEqual(record['TrucazoReputation'],5)
 def test_food_award_preserves_nested_lots_in_personal_graph(self):
  graph=ADAPTER.capture(PENDING_LEVEL,2)
  claim=next(o['class:CaelumTrucazoClaims'] for o in graph['objects'] if o['classtype']=='CaelumTrucazoClaims')
  vault=graph['objects'][claim['Vault']];food=graph['objects'][vault['inventory']]
  self.assertEqual(food['classtype'],'CaelumFoodRation');self.assertEqual(food['class:Inventory']['Amount'],2)
  lots=food['class:CaelumConsumableItem']['FoodLots'];self.assertEqual(graph['objects'][lots]['classtype'],'CaelumFoodLots')
 def test_install_preserves_prizes_and_world(self):
  graph=ADAPTER.capture(PENDING_LEVEL,0);destination=copy.deepcopy(PENDING_LEVEL)
  owned(destination,1,'CaelumPersistentCharacterState')['class:CaelumPersistentCharacterState']['ProfileCommitted']=False
  before=copy.deepcopy(destination);result=ADAPTER.install(destination,graph,1,'trucazo-claim-import',0)
  self.assertEqual(destination,before)
  for key in ('checksum','sectors','linedefs','sidedefs','zones','musicname'):self.assertEqual(result[key],before[key])
  claim=owned(result,1,'CaelumTrucazoClaims')['class:CaelumTrucazoClaims'];vault=result['objects'][claim['Vault']]
  item=result['objects'][vault['inventory']];self.assertEqual(item['class:Inventory']['Owner'],claim['Vault'])
  self.assertEqual(item['class:CaelumEquipmentItem']['Durability'],345)
  self.assertEqual(owned(result,1,'CaelumPersistentCharacterState')['class:CaelumPersistentCharacterState']['TrucazoReputation'],5)

if __name__=='__main__':unittest.main()
