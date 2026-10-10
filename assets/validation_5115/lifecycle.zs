class CA162Lifecycle : EventHandler
{
    int Passed,Failed,StaffId;
    CaelumEquipmentItem Dropped;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA162 %s %s",ok?"PASS":"FAIL",label);}
    void SelectItem(CaelumPlayer u,CaelumEquipmentItem item)
    {
        u.EquipmentSelectionItemId=item.ItemId;u.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        u.EquipmentSelectionWeaponType=21;u.EquipmentSelectionTier=1;u.EquipmentSelectionSize=2;
        u.RefreshEquipmentSelectionPreview();
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1)u.InitializeDirectMapCharacter();
        if(level.time==20)
        {
            u.GrantMagicBoxFromPalomo(false);
            let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos+(64,0,0),NO_REPLACE));
            item.args[0]=21;item.args[1]=3;item.args[2]=3;
            Dropped=item;
        }
        if(level.time==25)
        {
            Check("world tool can be collected",Dropped.CallTryPickup(u));
            let item=u.GetSelectedNativeEquipmentItem();
            for(Inventory i=u.Inv;i!=null;i=i.Inv)
            {let w=CaelumEquipmentItem(i);if(w!=null && w.EquipmentKind==2 && w.ItemType==21)item=w;}
            Check("fresh pickup normalizes to single tier",item!=null && item.Tier==1 && item.Durability==10000);
            if(item==null)return;
            StaffId=item.ItemId;item.Durability=8765;item.UtilityStaffContactTics=23;
            if(u.ActiveWeaponItemId==StaffId)u.WeaponModel.Durability=item.Durability;
            SelectItem(u,item);
            u.ToggleSelectedMagicBox();
            Console.Printf("CA162 BOX stored=%d action=%d durability=%d wear=%d",item.InMagicBox,u.LastEquipmentAction,item.Durability,item.UtilityStaffContactTics);
            Check("Box stores tool without changing identity or wear",item.InMagicBox && item.ItemId==StaffId && item.UtilityStaffContactTics==23 && item.Durability==8765);
            u.ToggleSelectedMagicBox();
            Check("Box retrieves same tool",!item.InMagicBox && item.UtilityStaffContactTics==23);
            u.DropSelectedEquipment();
            Dropped=null;let it=ThinkerIterator.Create("CaelumWeaponPickup");Thinker entry;
            while((entry=it.Next())!=null){let w=CaelumEquipmentItem(entry);if(w.Owner==null && w.ItemId==StaffId)Dropped=w;}
            Check("drop keeps exact identity durability partial wear",Dropped!=null && Dropped.ItemId==StaffId && Dropped.Durability==8765 && Dropped.UtilityStaffContactTics==23);
        }
        if(level.time==90)
        {
            bool picked=Dropped!=null && Dropped.CallTryPickup(u);
            let item=u.FindNativeEquipmentItemById(StaffId);
            Check("re-pickup retains wear and identity",picked && item!=null && item.Durability==8765 && item.UtilityStaffContactTics==23);
            int copies=0;for(Inventory i=u.Inv;i!=null;i=i.Inv){let w=CaelumEquipmentItem(i);if(w!=null && w.ItemId==StaffId)copies++;}
            Check("lifecycle never duplicates native item",copies==1);
            Console.Printf("CA162 RESULT passed=%d failed=%d",Passed,Failed);
        }
    }
}
