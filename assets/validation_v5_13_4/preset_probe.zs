class CA597PresetLedger : Inventory
{
    int EquipmentCount;
    Default {Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA597PresetProbe : StaticEventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA597P %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Done || level.time<175)return;
        if(players[0].mo==null || players[1].mo==null)return;
        Done=true;
        for(int i=0;i<2;i++)
        {
            let user=CaelumStandalonePlayer(players[i].mo);
            Check(user!=null,"fresh native network uses standalone player class");if(user==null)continue;
            let record=user.GetPersistentCharacterState(false);
            int selected=user.ReadNewCharacterDraft('ca_standalone_preset',-1);
            Check(user.StandaloneRevision==1 && user.StandalonePreset==selected,"native player retains own selected resident");
            let profile=user.CharacterProfile.Standalone;
            Check(profile!=null && profile.Revision==1,"saved resident snapshot initialized once");if(profile==null)continue;
            double mass=selected==0?200:selected==1?140:selected==2?120:80;
            Check(Abs(user.DerivedStats.BaseMass-mass)<0.01,"body mass matches original resident");
            Check(profile.Base[0]==(selected<2?20:9) && profile.Base[9]==(selected==0?3:selected==1?7:18),"base attributes match accepted resident profile");
            Check(record!=null && record.ProfileCommitted && record.ExternalProfileCampaign.Length()==0
                && record.ExternalProfileId.Length()==0,"match owns no external campaign identity");
            Check(record.IdentityProfile.Standalone==profile,"persistent identity retains the match snapshot");
            int equipment=0,clothes=0;bool duplicate=false,validClothes=true;
            for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
            {
                let item=CaelumEquipmentItem(cursor);if(item==null)continue;equipment++;
                if(item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)
                {
                    clothes++;
                    if(item.ItemType!=CaelumClothingData.Initial(item.ArmorSlot) || !item.Equipped)validClothes=false;
                }
                for(Inventory next=cursor.Inv;next!=null;next=next.Inv)
                {let other=CaelumEquipmentItem(next);if(other!=null && item.ItemId==other.ItemId)duplicate=true;}
            }
            Check(equipment-clothes==(selected<2?8:7) && !duplicate,"original armor and finite tools have unique identities");
            Check(clothes==4 && validClothes,"ordinary player underclothing migration is retained once");
            Check(user.WeaponModel.SourceItem!=null && user.WeaponModel.SourceItem.Owner==user
                && user.WeaponModel.SourceItem.Equipped,"native selected weapon points to real owned preset item");
            Check(user.player.ReadyWeapon!=null && !(user.player.ReadyWeapon is 'CaelumUnarmedWeapon'),
                "selected preset item has a usable native weapon selector");
            int owned=0;for(int card=0;card<78;card++)if(record.TarotOwned[card])owned++;
            Check(owned==0,"fresh match inherits no campaign Tarot collection");
            let ledger=CA597PresetLedger(user.FindInventory('CA597PresetLedger'));
            if(ledger==null){ledger=CA597PresetLedger(user.GiveInventoryType('CA597PresetLedger'));ledger.EquipmentCount=equipment;}
            else Check(ledger.EquipmentCount==equipment,"reload does not duplicate preset equipment");
            user.ApplyCharacterProfile();
            Check(user.CharacterProfile.Standalone==profile && user.DerivedStats.BaseMass==mass,"normal profile recalculation preserves preset body");
            Console.Printf("CA597P DIAG slot=%d selected=%d hp=%d/%d equipment=%d mass=%.3f",i,selected,user.health,user.CaelumMaximumHealth,equipment,user.DerivedStats.BaseMass);
        }
        Console.Printf("CA597P RESULT presets");
    }
}
