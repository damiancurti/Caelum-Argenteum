// Isolated presentation fixture; never included in the production PK3.
class CA255Probe : StaticEventHandler
{
    int Failures;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c255_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);
        if(user==null)return;
        if(e.Name=="c255_prepare")
        {
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;user.player.ConversationPC=null;
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
            user.ApplyCharacterProfile();
            user.RecordMainM00UnknownVoiceHeard();
            let record=user.GetPersistentCharacterState(true);
            record.ProfileCommitted=true;
            let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup"));
            Actor toucher=user;
            seal.TryEquipmentPickup(toucher);
            for(Inventory item=user.Inv;item!=null;item=item.Inv)
            {
                let owned=CaelumEquipmentItem(item);
                if(owned!=null && owned.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)
                {owned.Equipped=true;user.EquippedSealItemId=owned.ItemId;}
            }
            record.TarotSelected[0]=true;
            record.TarotOwned[0]=true;
            CaelumTarotDeckRules.Grant(user);
            let weapon=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
            weapon.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            weapon.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;weapon.Tier=1;
            weapon.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
            weapon.Durability=100000;weapon.ItemId=record.NextEquipmentItemId++;
            weapon.AcquisitionResolved=true;weapon.PickupDataInitialized=true;user.AddInventory(weapon);
            user.ApplyFormalInventorySelection(weapon);user.EquipSelectedNativeEquipment();user.ActivateExactEquippedWeapon(weapon);
            user.RefreshCarriedInventorySummary();
            user.PersistCharacterState();
        }
        if(e.Name=="c255_state")
        {
            let record=user.GetPersistentCharacterState(true);
            record.TarotEffectTics=e.Args[0]==2?120*TICRATE:0;
            record.TarotCooldownTics=e.Args[0]==2 || e.Args[0]==3?240*TICRATE:0;
            record.TarotSelected[0]=e.Args[0]!=0;
            user.CurrentAnima=e.Args[0]==4?0:user.DerivedStats.MaximumAnima;
            user.CurrentAdrenaline=e.Args[0]==4?0:user.DerivedStats.MaximumAdrenaline;
            user.CombatChannelCooldownRemaining=e.Args[0]==2 || e.Args[0]==3?120:0;
            for(Inventory item=user.Inv;item!=null;item=item.Inv)
            {
                let owned=CaelumEquipmentItem(item);
                if(owned!=null && owned.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)
                {owned.Equipped=e.Args[0]!=0;user.EquippedSealItemId=owned.Equipped?owned.ItemId:0;}
            }
            user.RefreshCarriedInventorySummary();
            CaelumPlayerPresentation.SyncHUDActiveWeaponState(user);
            if(user.HUDHasEquippedSeal!=(e.Args[0]!=0))Failures++;
            Console.Printf("CA255 STATE %d seal=%d ready=%d weapon=%d tarot=%d duration=%d cooldown=%d",e.Args[0],
                user.HUDHasEquippedSeal,user.HUDSealChannelAvailable,user.ActiveWeaponItemId,
                record.TarotSelected[0],record.TarotEffectTics,record.TarotCooldownTics);
        }
        if(e.Name=="c255_snapshot")
        {
            let record=user.GetPersistentCharacterState(false);
            Console.Printf("CA255 SNAPSHOT seal=%d weapon=%d tarot=%d duration=%d cooldown=%d channel=%.3f",
                user.EquippedSealItemId,user.ActiveWeaponItemId,record.TarotSelected[0],
                record.TarotEffectTics,record.TarotCooldownTics,user.CombatChannelCooldownRemaining);
            if(user.GetEquippedSeal()==null || user.ActiveWeaponItemId<=0 || !record.TarotSelected[0])Failures++;
        }
        if(e.Name=="c255_done")Console.Printf("CA255 DONE failures=%d",Failures);
    }
}
