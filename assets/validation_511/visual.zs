class CA131Visual : StaticEventHandler
{
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(level.time==1)
        {user.InitializeDirectMapCharacter();user.PersistCharacterState();}
        if(level.time<44)return;
        if(level.time==44)
        {
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=CaelumConstants.WEAPON_TYPE_SWORD;
            item.ArmorSlot=-1;item.Tier=1;item.EquipmentSize=user.WeaponModel.Size;
            item.SizePolicy=CaelumEquipmentRules.CHARACTER_DEFAULT;
            item.UnitWeight=user.WeaponModel.GetWeightFor(item.ItemType,item.Tier,item.EquipmentSize);
            item.Durability=123;item.PickupDataInitialized=true;item.Equipped=true;item.AttachToOwner(user);
            user.EnsureEquipmentItemId(item);user.ActivateExactEquippedWeapon(item);user.EnsureWeaponFamilySelectors();
            CaelumNotifications.Notify(user,"CA131: HUD and notification visibility");
        }
        int index=CVar.GetCVar("ca131_case").GetInt();
        double values[12]={0,-12,-22,-40,12,22,40,-7,0,-21,-19,1e12};
        user.Attributes.Toughness=index>=9 ? 100 : 0;
        user.health=user.CaelumMaximumHealth;user.player.health=user.health;
        let thermal=CaelumThermalBody.Get(user,true);
        thermal.Exposure=values[Clamp(index,0,11)];CaelumThermalBody.Refresh(user,thermal);
        thermal.Severity=CaelumThermalRules.Severity(thermal.Exposure,thermal.Toughness);
        if(level.time==60)Console.Printf("CA131 VISUAL READY");
    }
    override void RenderOverlay(RenderEvent e)
    {
        int index=CVar.GetCVar("ca131_case").GetInt();
        if(index!=12)return;
        let journal=CaelumJournalOverlay(EventHandler.Find("CaelumJournalOverlay"));
        if(journal!=null)journal.ThermalDetailsOpen=true;
    }
}
