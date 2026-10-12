// Same native input sequence runs on the accepted baseline and changed build.
class CA150Combat : StaticEventHandler
{
    int StartTic, Phase, Shots;
    bool Recording;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c150_close")
        {CaelumLiveMenu.Journal().SetJournalOpen(false);while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
        if(e.Name=="c150_done")Console.Printf("CA150 DONE failures=0");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="c150_ready")
        {
            if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
            user.player.ConversationNPC=null;user.Angle=180;user.Pitch=0;StartTic=level.Time;Recording=true;
        }
        if(e.Name=="c150_weapon")
        {
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=e.Args[0];
            item.Tier=1;item.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
            item.Durability=100000;item.ItemId=user.GetPersistentCharacterState(false).NextEquipmentItemId++;
            item.AcquisitionResolved=true;item.PickupDataInitialized=true;user.AddInventory(item);
            user.ApplyFormalInventorySelection(item);user.EquipSelectedNativeEquipment();user.ActivateExactEquippedWeapon(item);Phase=e.Args[0];
        }
    }
    override void WorldThingSpawned(WorldEvent e)
    {
        if(Recording && e.Thing.bMISSILE)
        {
            Shots++;
            Console.Printf("CA150 PROJECTILE %d %s %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f",level.Time-StartTic,e.Thing.GetClassName(),e.Thing.Pos.X,e.Thing.Pos.Y,e.Thing.Pos.Z,e.Thing.Vel.X,e.Thing.Vel.Y,e.Thing.Vel.Z,e.Thing.Angle,e.Thing.Pitch);
        }
    }
    override void WorldTick()
    {
        if(!Recording)return;let user=CaelumPlayer(players[0].mo);
        Console.Printf("CA150 TRACE %d %d %.6f %.6f %.6f %.6f %.6f %d %.6f %.6f %.6f %d %.6f %d %d %d %.6f %d",level.Time-StartTic,Phase,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.Pitch,user.health,user.CurrentAir,user.CurrentAnima,user.CurrentAdrenaline,user.WeaponChargeActive,user.WeaponChargeRemainingSeconds,user.WeaponChargedStateActive,user.StaffCastPending,user.LastStaffCastCompleted,user.StaffCastCooldownRemaining,Shots);
    }
}
