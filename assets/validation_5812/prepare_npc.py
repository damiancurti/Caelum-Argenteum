"""Build deterministic NPC exposure fixtures; no production assets are generated."""
from pathlib import Path
import zipfile
here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
source=(here/'npc_checks.zs').read_bytes()
def package(name,code):
    members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n',
             'checks.zs':code,'MAPINFO':b'GameInfo { AddEventHandlers="CA502NPCChecks" }\n'}
    with zipfile.ZipFile(out/name,'w',zipfile.ZIP_STORED) as z:
        for key,value in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),value)
package('npc-checks.pk3',source)
legacy=source.split(b'class CA502NPCChecks')[0]+b'''class CA502NPCChecks : EventHandler {
CA502NPCSoldier Soldier;CA502NPCRat Rat;CaelumEquipmentItem Item;
override void NetworkProcess(ConsoleEvent e){
let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
if(e.Name=='ca502n_old_prepare'){
Soldier=CA502NPCSoldier(Actor.Spawn('CA502NPCSoldier',u.Pos+(64,0,0),NO_REPLACE));Soldier.ChangeTid(905032);
Rat=CA502NPCRat(Actor.Spawn('CA502NPCRat',u.Pos+(96,0,0),NO_REPLACE));Rat.ChangeTid(905033);
Item=CaelumEquipmentItem(Actor.Spawn('CaelumWeaponPickup',u.Pos,NO_REPLACE));
Item.ItemId=905031;Item.AcquisitionResolved=Item.PickupDataInitialized=true;Item.Amount=1;
Item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
Item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;Item.UnitWeight=1;Item.Tier=1;Item.Durability=1000;Item.AttachToOwner(Soldier);
}else if(e.Name=='ca502n_old_seed'){
CaelumContaminationStorage.Set(Soldier,26);CaelumContaminationStorage.Set(Item,34);
CaelumContaminationCombat.Exterior(Soldier,1).Set(40);CaelumContaminationCombat.WeaponPoint(Soldier.Sword).Set(50);
CaelumContaminationCombat.ShieldPoint(Soldier.Shield).Set(60);
let p=CA502NPCProof(u.GiveInventoryType('CA502NPCProof'));p.Soldier=Soldier;p.Rat=Rat;p.NativeItem=Item;
p.BodyC=26;p.ItemC=34;p.ArmorC=40;p.WeaponC=50;p.ShieldC=60;
Console.Printf("CA502N PASS previous runtime saved body and equipment");
}else if(e.Name=='ca502n_old_verify'){
let p=CA502NPCProof(u.FindInventory('CA502NPCProof'));
bool ok=p!=null && p.Soldier!=null && p.NativeItem!=null;
if(ok)ok=CaelumContaminationStorage.Value(p.Soldier)==26 && CaelumContaminationStorage.Value(p.NativeItem)==34
 && CaelumContaminationCombat.Exterior(p.Soldier,1).Value()==40
 && CaelumContaminationCombat.WeaponPoint(p.Soldier.Sword).Value()==50
 && CaelumContaminationCombat.ShieldPoint(p.Soldier.Shield).Value()==60;
Console.Printf("CA502N %s original save rollback preserves all concentrations",ok?"PASS":"FAIL");
}else return;Console.Printf("CA502N LEGACY");}}
'''
package('npc-legacy-checks.pk3',legacy)
scripts={
 'npc-core':'wait 70; netevent ca502n_prepare; wait 3; netevent ca502n_core; wait 3; quit',
 'npc-save':'wait 70; netevent ca502n_prepare; wait 3; netevent ca502n_save; save ca502n-current; wait 3; quit',
 'npc-load':'wait 1; netevent ca502n_load; wait 3; quit',
 'npc-hub':'wait 1; changemap CAH001; wait 35; changemap CAH000; wait 35; netevent ca502n_load; wait 3; quit',
 'npc-clock':'wait 70; netevent ca502n_prepare; wait 3; netevent ca502n_manual; wait 175; netevent ca502n_clock; wait 3; quit',
 'npc-manual':'wait 70; netevent ca502n_prepare; wait 3; netevent ca502n_manual; bind F1 "netevent ca502n_manual"; bind F2 "netevent ca502n_read"; bind F6 toggleconsole',
 'npc-old-save':'wait 70; netevent ca502n_old_prepare; wait 3; netevent ca502n_old_seed; save ca502n-old; wait 3; quit',
 'npc-old-verify':'wait 1; netevent ca502n_old_verify; wait 3; quit',
}
for name,text in scripts.items():(out/(name+'.cfg')).write_text(text+'\n',encoding='utf-8',newline='\n')
print('Prepared NPC exposure fixtures.')
