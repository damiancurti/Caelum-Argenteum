class CA164Safety : EventHandler
{
    bool Done;
    void Check(bool ok,String label){Console.Printf("CA164 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Done || level.time<100)return;let u=CaelumPlayer(players[0].mo);
        if(u==null || !u.CharacterCreationComplete)return;Done=true;
        let r=u.GetPersistentCharacterState(true);
        r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED);
        let ballast=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        ballast.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;ballast.ItemType=0;
        ballast.Tier=1;ballast.UnitWeight=1000000;ballast.PickupDataInitialized=true;ballast.AcquisitionResolved=true;ballast.AttachToOwner(u);u.EnsureEquipmentItemId(ballast);u.OnNativeInventoryChanged();
        Check(!CaelumMainM00Gifts.EnsureTool(u,false) && !CaelumMainM00Gifts.EnsureTool(u,true) && r.MainM00UtilityStaffId==0 && r.MainM00BolasId==0,"full inventory postpones unclaimed gifts");
        u.RemoveInventory(ballast);ballast.SetOrigin(u.Pos+(128,0,0),false);u.OnNativeInventoryChanged();
        Check(CaelumMainM00Gifts.EnsureTool(u,false) && CaelumMainM00Gifts.EnsureTool(u,true),"capacity recovery delivers postponed gifts");
        int staffId=r.MainM00UtilityStaffId;int bolasId=r.MainM00BolasId;
        let staff=u.FindNativeEquipmentItemById(staffId);let bolas=u.FindNativeEquipmentItemById(bolasId);
        Check(staff!=null && bolas!=null && staff.EquipmentSize==CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier()),"gifts use native character size");
        staff.Durability=123;CaelumMainM00Gifts.EnsureTool(u,false);
        Check(staff.Durability==123 && r.MainM00UtilityStaffId==staffId,"revisiting never repairs worn gift");
        u.RemoveInventory(staff);staff.SetOrigin(u.Pos+(160,0,0),false);
        u.RemoveInventory(bolas);bolas.SetOrigin(u.Pos+(192,0,0),false);u.OnNativeInventoryChanged();
        Check(CaelumMainM00Gifts.EnsureTool(u,false) && CaelumMainM00Gifts.EnsureTool(u,true) && u.FindNativeEquipmentItemById(staffId)==null && u.FindNativeEquipmentItemById(bolasId)==null,"lost gifts are never recreated");
        Check(r.MainM00UtilityStaffId==staffId && r.MainM00BolasId==bolasId && staff.Owner==null && bolas.Owner==null,"claim IDs and actual dropped instances persist");
        Console.Printf("CA164 SAFETY_DONE");
    }
}
