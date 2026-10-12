// Native visual fixture: all equipment is local test inventory.
class CA148Visual : StaticEventHandler
{
    int Failures;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label);}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca148_look" || e.Name=="ca148_weapon" || e.Name=="ca148_gloves"
            || e.Name=="ca148_shield" || e.Name=="ca148_corpse")
            EventHandler.SendNetworkEvent(e.Name,e.Args[0],e.Args[1],e.Args[2]);
        if(e.Name=="ca148_done")Console.Printf("CA148 DONE failures=%d",Failures);
    }
    CaelumEquipmentItem Item(CaelumPlayer user,int kind,int type,int slot=0)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
        item.EquipmentKind=kind;item.ItemType=type;item.ArmorSlot=slot;
        item.Tier=1;item.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        item.Durability=100000;item.ItemId=user.GetPersistentCharacterState(false).NextEquipmentItemId++;
        item.AcquisitionResolved=true;item.PickupDataInitialized=true;user.AddInventory(item);
        user.ApplyFormalInventorySelection(item);user.EquipSelectedNativeEquipment();
        Check(item.Equipped,"native owned equipment successfully equipped");
        return item;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);
        let profile=CaelumCharacterIdentity.Profile(user);
        if(e.Name=="ca148_look")
        {
            profile.Race=e.Args[0];profile.Sex=1;profile.BeastForm=e.Args[1];profile.SkinTone=e.Args[2];
            user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
        }
        if(e.Name=="ca148_weapon")
        {
            let item=Item(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,e.Args[0]);
            user.ActivateExactEquippedWeapon(item);
        }
        if(e.Name=="ca148_gloves")
        {
            if(e.Args[0]!=0)Item(user,CaelumConstants.EQUIPMENT_KIND_ARMOR,
                CaelumConstants.ARMOR_TYPE_LIGHT,CaelumConstants.ARMOR_SLOT_HANDS);
            else
            {
                let item=user.FindNativeEquipmentItemById(user.EquippedArmorItemId[2]);
                if(item!=null){user.ApplyFormalInventorySelection(item);user.UnequipSelectedNativeEquipment();}
            }
            Check(CaelumAppearanceHands.HasGloves(user)==(e.Args[0]!=0),"glove appearance follows actual equipment action");
        }
        if(e.Name=="ca148_shield")Item(user,CaelumConstants.EQUIPMENT_KIND_SHIELD,CaelumConstants.SHIELD_TYPE_KITE);
        if(e.Name=="ca148_corpse")
        {
            int tone=profile.SkinTone,form=profile.BeastForm;
            user.health=0;user.Die(null,null);
            profile.SkinTone=(tone+1)%3;profile.BeastForm=(form+1)%4;
            user.UpdateWorldCarbineVisual();
            Check(user.AppearanceDeathProfile!=profile && user.AppearanceDeathProfile.SkinTone==tone
                && user.AppearanceDeathProfile.BeastForm==form,"corpse retains independent death appearance after profile changes");
        }
    }
}
