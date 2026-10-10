class CA162Travel : StaticEventHandler
{
    int Age,Visits,Passed,Failed,StaffId,ContactTics,Durability;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA162 %s visit=%d %s",ok?"PASS":"FAIL",Visits,label);}
    override void WorldLoaded(WorldEvent e){Age=0;Visits++;}
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(Visits==1 && Age==5)u.InitializeDirectMapCharacter();
        if(Visits==1 && Age==20)
        {
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=21;item.Tier=1;
            item.EquipmentSize=2;item.Durability=9999;item.UtilityStaffContactTics=17;
            item.UnitWeight=8;item.PickupDataInitialized=true;
            item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
            item.Equipped=true;item.AttachToOwner(u);u.EnsureEquipmentItemId(item);StaffId=item.ItemId;
            u.ActivateExactEquippedWeapon(item);u.EnsureWeaponFamilySelectors();u.SelectNativeWeaponConfiguration(21,0,1);
            u.CurrentAnima=u.DerivedStats.MaximumAnima;
        }
        if(Visits>1 && Age==1)
        {
            Check("old emitter and request cleared at hub boundary",u.UtilityStaffStream==null && u.UtilityStaffRequestedMode==0);
            let item=u.FindNativeEquipmentItemById(StaffId);
            Check("hub retains exact durability and partial wear",item!=null && item.Durability==Durability && item.UtilityStaffContactTics==ContactTics);
        }
        if(Age==150 && Visits<3)
        {
            let stream=CaelumUtilityStaffStream(u.UtilityStaffStream);
            Check("held input emits before travel",stream!=null && stream.SourceMap==level.MapName);
            let item=u.FindNativeEquipmentItemById(StaffId);Durability=item.Durability;ContactTics=item.UtilityStaffContactTics;
            u.PersistCharacterState();Level.ChangeLevel(Visits==1 ? "CA162B" : "CA162",0,CHANGELEVEL_NOINTERMISSION);
        }
        if(Visits==3 && Age==50)
        {
            int sources=0,visuals=0;let it=ThinkerIterator.Create("CaelumUtilityStaffStream");
            while(it.Next()!=null)sources++;
            it=ThinkerIterator.Create("CaelumUtilityStreamVisual");while(it.Next()!=null)visuals++;
            Check("hub return has at most one current source",sources<=1);
            Check("hub return has no orphan visuals",visuals<=4);
            Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
