"""Package focused combat-contact diagnostics without production assets."""
from pathlib import Path
import zipfile
here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n','checks.zs':(here/'combat_checks.zs').read_bytes(),'MAPINFO':b'GameInfo { AddEventHandlers="CA502CombatChecks" }\n'}
with zipfile.ZipFile(out/'combat-checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={'combat-trace':'wait 70; netevent ca502m_prepare; wait 3; netevent ca502m_trace; wait 5; quit','combat-core':'wait 70; netevent ca502m_prepare; wait 3; netevent ca502m_core; wait 5; quit','combat-models':'wait 70; netevent ca502m_prepare_models; wait 3; netevent ca502m_models; wait 5; quit','combat-save':'wait 70; netevent ca502m_prepare_models; wait 3; netevent ca502m_models; save ca502m-combat; wait 5; quit','combat-load':'wait 1; netevent ca502m_load; wait 5; quit'}
for name,script in scripts.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')
print('Prepared combat-contact checks.')

common=(here/'combat_checks.zs').read_text().split('class CA502CombatChecks')[0]
legacy=common+"""class CA502CombatChecks : EventHandler {
CaelumPortDefender Enemy;CaelumEquipmentItem Weapon;
void Check(bool ok,String name){Console.Printf("CA502M %s %s",ok?"PASS":"FAIL",name);}
override void NetworkProcess(ConsoleEvent e){
if(e.Player<0 || players[e.Player].mo==null)return;let u=CaelumPlayer(players[e.Player].mo);
if(e.Name=='ca502m_old_prepare'){
Enemy=CaelumPortDefender(Actor.Spawn('CA502CombatSoldier',u.Pos+(64,0,0),NO_REPLACE));
Weapon=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',u.Pos,NO_REPLACE));
Weapon.ItemId=905021;Weapon.AcquisitionResolved=true;Weapon.PickupDataInitialized=true;Weapon.Amount=1;
Weapon.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Weapon.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
Weapon.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;Weapon.Tier=1;Weapon.Durability=100;Weapon.UnitWeight=1;Weapon.AttachToOwner(u);
}else if(e.Name=='ca502m_old_seed'){
CaelumContaminationStorage.Set(Weapon,34);CaelumContaminationStorage.Set(Enemy,26);
let proof=CA502CombatProof(u.GiveInventoryType('CA502CombatProof'));proof.Enemy=Enemy;proof.Weapon=Weapon;
Check(Enemy.Shield!=null && Enemy.Sword!=null,"old runtime native loadout initialized");
}else if(e.Name=='ca502m_old_verify'){
let proof=CA502CombatProof(u.FindInventory('CA502CombatProof'));
Check(proof!=null && proof.Enemy!=null && proof.Weapon!=null,"original save rollback identities");
if(proof!=null){Check(CaelumContaminationStorage.Value(proof.Weapon)==34,"original save rollback weapon");Check(CaelumContaminationStorage.Value(proof.Enemy)==26,"original save rollback body");}
}else return;Console.Printf("CA502M LEGACY");}}
"""
with zipfile.ZipFile(out/'combat-legacy-checks.pk3','w',zipfile.ZIP_STORED) as z:
    members['checks.zs']=legacy.encode();members['MAPINFO']=b'GameInfo { AddEventHandlers="CA502CombatChecks" }\n'
    for name,blob in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
extra={'combat-old-save':'wait 70; netevent ca502m_old_prepare; wait 3; netevent ca502m_old_seed; save ca502m-old; wait 5; quit','combat-old-verify':'wait 1; netevent ca502m_old_verify; wait 5; quit','combat-legacy':'wait 1; netevent ca502m_legacy; wait 5; quit','combat-hub':'wait 1; changemap CAH001; wait 35; changemap CAH000; wait 35; netevent ca502m_load; wait 5; quit'}
for name,script in extra.items():(out/(name+'.cfg')).write_text(script+'\n',encoding='utf-8',newline='\n')

(out/'combat-manual.cfg').write_text('wait 70; netevent ca502m_prepare; wait 3; netevent ca502m_manual; bind F1 "netevent ca502m_manual"; bind F2 "netevent ca502m_hit"; bind F3 "netevent ca502m_reverse"; bind F4 "netevent ca502m_bite"; bind F5 "netevent ca502m_shield"; bind F6 toggleconsole; bind F7 "netevent ca502m_evade"\n',encoding='utf-8',newline='\n')

(out/'combat-live.cfg').write_text('wait 70; netevent ca502m_prepare; wait 3; netevent ca502m_manual; netevent ca502m_hit; wait 3; netevent ca502m_reverse; netevent ca502m_hit; wait 3; netevent ca502m_bite; netevent ca502m_hit; wait 3; netevent ca502m_shield; netevent ca502m_hit; wait 3; netevent ca502m_evade; netevent ca502m_hit; wait 5; quit\n',encoding='utf-8',newline='\n')
