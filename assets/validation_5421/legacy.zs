// Compatible con 5.4.20: crea un guardado auténtico anterior al acumulador.
class CA252Legacy : StaticEventHandler
{
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c252_legacy")return;
        let user=CaelumPlayer(players[e.Player].mo);
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();
        let equipment=new("CA259Session");equipment.Choice=0;equipment.Tier=1;equipment.Equip(user);
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
            if(item is "CaelumEquipmentItem" && CaelumEquipmentItem(item).EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)
                CaelumEquipmentItem(item).Equipped=false;
        let seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",user.Pos,NO_REPLACE));
        seal.PickupDataInitialized=seal.AcquisitionResolved=true;
        seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;seal.Tier=1;
        seal.ItemType=CaelumConstants.SEAL_FIRE;seal.Equipped=true;seal.AttachToOwner(user);
        user.CurrentAdrenaline=user.DerivedStats.MaximumAdrenaline;
        user.CombatChannelCooldownRemaining=0;user.RequestCombatChannelInput();
        let effect=CaelumChannelEffect(user.CombatChannelEffectActor);
        if(effect!=null)effect.PulseAccumulator=0.5;
        Console.Printf("CA252 DONE passes=%d failures=%d",effect!=null?1:0,effect==null?1:0);
    }
}
