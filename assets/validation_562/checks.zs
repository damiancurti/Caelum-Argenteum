// #381: fixtures aislados; no añaden existencias al juego.
class CA381Checkpoint : Inventory
{
    CaelumStashChest Chest;
    CaelumEquipmentItem Equipment;
    Inventory Material;
    int Identity, Wear, Units;
    double Total;
    Default { +INVENTORY.UNDROPPABLE Inventory.MaxAmount 1; }
}
class CA381Checks : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok,String name)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA381 %s %s",ok ? "PASS" : "FAIL",name);
    }
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.ClosePalomoMerchant();u.CloseCraftingStationSession();
        u.CreationWizardOpen=false;u.GrantMagicBoxFromPalomo(false);
    }
    CaelumStashChest Chest(CaelumPlayer u,int tier=1)
    {
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",u.Pos+(48,0,0),NO_REPLACE));
        chest.EnsureStorage();chest.StorageTier=tier;chest.ApplyStorageSize();
        return chest;
    }
    CaelumEquipmentItem Weapon(CaelumPlayer u)
    {
        let e=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        e.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        e.ItemType=CaelumConstants.WEAPON_TYPE_LONGBOW;
        e.Tier=1;e.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        e.PickupDataInitialized=true;e.bDropped=false;e.Amount=1;e.Durability=17;
        e.UnitWeight=e.PreviewUnitWeight(u);e.AcquisitionResolved=true;
        e.AttachToOwner(u);u.EnsureEquipmentItemId(e);return e;
    }
    CaelumMaterialPickup Material(CaelumPlayer u,Actor owner,int units,int kind=0)
    {
        let m=CaelumMaterialPickup(Actor.Spawn("CaelumMaterialPickup",u.Pos,NO_REPLACE));
        m.args[0]=kind;m.args[1]=1;m.Amount=units;m.AttachToOwner(owner);return m;
    }
    bool Transfer(CaelumPlayer u,CaelumStashChest chest,Inventory item,int quantity,bool deposit)
    {
        return CaelumInventoryService.TransferContainerItem(u,chest,item,quantity,deposit);
    }
    void Suite(CaelumPlayer u)
    {
        Prepare(u);
        let chest=Chest(u);
        Check(chest.StorageTier==1 && chest.StorageSlots()==0
            && chest.TotalStorageWeight(u)==100,"legacy default is empty medium");
        Check(CaelumContainerRules.Slots(0)==10 && CaelumContainerRules.Slots(1)==25
            && CaelumContainerRules.Slots(2)==100,"approved slot tiers");
        Check(CaelumContainerRules.Capacity(0)==100 && CaelumContainerRules.Capacity(1)==1000
            && CaelumContainerRules.Capacity(2)==10000,"approved mass tiers");
        chest.StorageTier=0;chest.ApplyStorageSize();
        Check(chest.Radius==16 && chest.Height==30 && chest.TotalStorageWeight(u)==10,"small dimensions and empty mass");
        chest.StorageTier=2;chest.ApplyStorageSize();
        Check(chest.Radius==64 && chest.Height==120 && chest.TotalStorageWeight(u)==1000,"large dimensions and empty mass");
        chest.StorageTier=1;chest.ApplyStorageSize();
        CaelumContainerSession.Open(u,chest);
        let e=Weapon(u);int id=e.ItemId;
        Check(Transfer(u,chest,e,1,true),"equipment deposit succeeds");
        Check(e.Owner==chest && e.ItemId==id && e.Durability==17 && chest.StorageSlots()==1,"deposited exact identity and wear");
        Check(!Transfer(u,chest,e,1,true) && e.Owner==chest,"repeated deposit cannot duplicate");
        Check(Transfer(u,chest,e,1,false) && e.Owner==u && e.ItemId==id && e.Durability==17,"equipment withdrawal intact");
        let draft=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        draft.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        draft.ItemType=CaelumConstants.WEAPON_TYPE_LONGBOW;draft.Tier=1;
        draft.PickupDataInitialized=true;draft.bDropped=false;draft.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_XS;
        draft.AttachToOwner(chest);
        int expectedSize=draft.PreviewEquipmentSize(u),expectedWear=draft.PreviewDurability(u);
        double expectedWeight=draft.PreviewUnitWeight(u);
        CaelumContainerSession.Get(u).Refresh();
        Check(!draft.AcquisitionResolved && draft.ItemId==0 && draft.UnitWeight==0,
            "preview does not bind unclaimed equipment to recipient");
        double savedCarry=u.DerivedStats.CarryCapacity;int savedBox=u.DerivedStats.MagicBoxCapacity;
        u.DerivedStats.CarryCapacity=0;u.DerivedStats.MagicBoxCapacity=0;
        Check(!Transfer(u,chest,draft,1,false) && !draft.AcquisitionResolved && draft.ItemId==0,
            "failed capacity does not resolve unclaimed equipment");
        u.DerivedStats.CarryCapacity=savedCarry;u.DerivedStats.MagicBoxCapacity=savedBox;
        Check(Transfer(u,chest,draft,1,false) && draft.AcquisitionResolved && draft.ItemId>0
            && draft.EquipmentSize==expectedSize && draft.Durability==expectedWear
            && Abs(draft.UnitWeight-expectedWeight)<0.001,"successful unclaimed withdrawal resolves actual recipient once");
        draft.Destroy();
        e.Equipped=true;
        Check(!Transfer(u,chest,e,1,true) && e.Owner==u,"equipped deposit rejected");e.Equipped=false;
        u.CraftingTaskActive=true;u.CraftingTaskTargetItemId=id;
        Check(!Transfer(u,chest,e,1,true) && e.Owner==u,"reserved equipment rejected");
        u.CraftingTaskActive=false;u.CraftingTaskTargetItemId=0;
        e.ItemFlags|=CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
        Check(!Transfer(u,chest,e,1,true),"temporary equipment deposit rejected");
        e.ItemFlags&=~CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
        let water=CaelumWaterContainer(Actor.Spawn("CaelumBottleSmall",u.Pos,NO_REPLACE));
        water.WaterLiters=0.25;water.AttachToOwner(u);
        Check(Transfer(u,chest,water,1,true),"first individual water container deposited");
        let water2=CaelumWaterContainer(Actor.Spawn("CaelumBottleSmall",u.Pos,NO_REPLACE));
        water2.WaterLiters=0.75;water2.AttachToOwner(u);
        Check(Transfer(u,chest,water2,1,true) && chest.StorageSlots()==2,
            "second same-class water container occupies separate slot");
        Check(Transfer(u,chest,water,1,false) && water.WaterLiters==0.25,
            "withdrawal preserves individual liquid volume");
        Check(!Transfer(u,chest,water2,1,false) && water2.WaterLiters==0.75,
            "duplicate personal water container remains rejected");
        water.Destroy();water2.Destroy();
        let deck=Inventory(Actor.Spawn("CaelumTarotDeck",u.Pos,NO_REPLACE));deck.AttachToOwner(u);
        Check(!Transfer(u,chest,deck,1,true) && deck.Owner==u,"Tarot remains non-discardable");
        deck.Destroy();
        u.GetPersistentCharacterState(true).KnownCraftingRecipe[CaelumCraftingRules.GetProcessingRecipeStart()]=false;
        let manual=Inventory(Actor.Spawn("CaelumProcessingManual",u.Pos,NO_REPLACE));manual.AttachToOwner(chest);
        Check(Transfer(u,chest,manual,1,false)
            && u.DirectCraftingRecipeKnown(CaelumCraftingRules.GetProcessingRecipeStart()),
            "processing manual withdrawal teaches existing recipes");
        manual.Destroy();
        let arrows=Inventory(Actor.Spawn("CaelumArrowAmmo",u.Pos,NO_REPLACE));
        let bolts=Inventory(Actor.Spawn("CaelumBoltAmmo",u.Pos,NO_REPLACE));
        Check(!CaelumContainerRules.CanBox(arrows) && !CaelumContainerRules.CanBox(bolts),
            "arrows and bolts retain personal-only routing");
        arrows.AttachToOwner(u);CaelumContainerRules.SetBoxed(arrows,true);
        let extraArrows=Inventory(Actor.Spawn("CaelumArrowAmmo",u.Pos,NO_REPLACE));extraArrows.AttachToOwner(chest);
        Check(!Transfer(u,chest,extraArrows,1,false) && extraArrows.Owner==chest,
            "legacy boxed arrows cannot receive another boxed transfer");
        extraArrows.Destroy();
        arrows.Destroy();bolts.Destroy();
        let m=Material(u,u,30,CaelumConstants.MATERIAL_WOOD);
        m.LimboSupplyUnits=7;m.LimboQuestUnits=4;
        Check(!Transfer(u,chest,m,10,true) && m.Amount==30,"temporary quest material cannot bypass cleanup");
        m.LimboQuestUnits=0;
        Check(Transfer(u,chest,m,10,true),"material partial deposit");
        let stored=CaelumMaterialPickup(chest.Inv);
        Check(stored!=null && stored.Amount==10 && m.Amount==20 && stored.args[0]==m.args[0]
            && stored.args[1]==m.args[1],"split retains material type and tier");
        Check(stored.LimboSupplyUnits+m.LimboSupplyUnits==7
            && stored.LimboQuestUnits+m.LimboQuestUnits==0,"split conserves supply provenance");
        Check(Transfer(u,chest,m,5,true) && stored.Amount==15 && chest.StorageSlots()==1,"compatible deposits merge one slot");
        Check(Transfer(u,chest,stored,5,false) && stored.Amount==10 && m.Amount==20,"withdrawal merges native stack");
        u.CraftingTaskActive=true;u.CraftingTaskReservedType[0]=CaelumConstants.MATERIAL_WOOD;
        u.CraftingTaskReservedTier[0]=1;u.CraftingTaskReservedUnits[0]=1;
        Check(!Transfer(u,chest,m,1,true) && m.Amount==20,"reserved material stack rejected");
        u.CraftingTaskActive=false;u.CraftingTaskReservedUnits[0]=0;
        Check(!Transfer(u,chest,m,999,true) && m.Amount==20,"missing requested quantity rejects whole transfer");
        let other=Chest(u);
        CaelumContainerSession.Open(u,other);
        Check(!Transfer(u,chest,m,1,true) && m.Owner==u,"foreign current container rejected");
        CaelumContainerSession.Open(u,chest);
        u.RefreshCarriedInventorySummary();double carry=u.DerivedStats.CarryCapacity;
        int box=u.DerivedStats.MagicBoxCapacity;
        u.DerivedStats.CarryCapacity=0;u.DerivedStats.MagicBoxCapacity=0;
        Check(!Transfer(u,chest,stored,1,false) && stored.Amount==10,"full recipient load and Box reject");
        u.DerivedStats.CarryCapacity=carry;u.DerivedStats.MagicBoxCapacity=box;
        chest.StorageTier=0;chest.ApplyStorageSize();
        let heavy=Material(u,chest,100000,CaelumConstants.MATERIAL_RAW_COPPER);
        Check(!Transfer(u,chest,m,1,true) && m.Amount==20,"mass capacity rejects without partial transfer");
        heavy.Destroy();
        while(chest.StorageSlots()<10)
        {
            let spare=Weapon(u);u.RemoveInventory(spare);spare.AttachToOwner(chest);
        }
        Check(!Transfer(u,chest,e,1,true) && e.Owner==u && chest.StorageSlots()==10,"slot limit rejects exact extra object");
        Check(Transfer(u,chest,m,1,true) && chest.StorageSlots()==10,"same-stack deposit needs no extra slot");
        let session=CaelumContainerSession.Get(u);
        session.Depositing=true;session.Refresh();
        for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i]==e)session.Selection=i;
        let foreign=Actor.Spawn("MapSpot",u.Pos,NO_REPLACE);
        u.RemoveInventory(e);e.AttachToOwner(foreign);session.Execute();
        Check(e.Owner==foreign && chest.StorageSlots()==10,"stale selected item cannot transfer another entry");
        foreign.RemoveInventory(e);e.AttachToOwner(u);
        session.Refresh();
        for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i]==m)session.Selection=i;
        int previous=stored.Amount;m.Amount--;session.Execute();
        Check(stored.Amount==previous && session.Status=="CA_CONTAINER_CHANGED",
            "changed displayed quantity rejected");
        session.Close();
        Check(!Transfer(u,chest,m,1,true) && m.Owner==u,"closed session cannot transfer");
        let otherPawn=CaelumPlayer(Actor.Spawn("CaelumPlayer",u.Pos+(0,96,0),NO_REPLACE));
        Check(!Transfer(otherPawn,chest,m,1,true) && m.Owner==u,
            "unbound requesting pawn cannot alter shared container");
        CaelumContainerSession.Open(u,chest);
        let claim=Weapon(u);u.RemoveInventory(claim);claim.AttachToOwner(chest);
        Check(Transfer(u,chest,claim,1,false) && claim.Owner==u,"first requesting pawn claims exact shared entry");
        // Dos cuerpos secuenciales en un slot de prueba; no simula una red.
        otherPawn.SetOrigin(u.Pos,false);otherPawn.player=u.player;u.player.mo=otherPawn;
        otherPawn.CharacterCreationComplete=true;otherPawn.CreationWizardOpen=false;
        CaelumContainerSession.Open(otherPawn,chest);
        Check(CaelumPlayerAuthority.CanMutate(otherPawn)
            && !Transfer(otherPawn,chest,claim,1,false) && claim.Owner==u,
            "second authoritative requesting pawn cannot duplicate claimed entry");
        u.player.mo=u;otherPawn.player=null;
        otherPawn.Destroy();
        // El cofre de transporte tiene sitio libre frente al jugador.
        let portable=Chest(u,0);u.Angle=180;CaelumContainerSession.Open(u,portable);
        Check(Transfer(u,portable,e,1,true),"portable chest stores equipment");
        u.RefreshCarriedInventorySummary();double before=u.DerivedStats.CarriedWeight;
        double total=portable.TotalStorageWeight(u);
        Check(CaelumInventoryService.CarryStorageChest(u,portable),"carry chest succeeds");
        Check(portable.Cargo!=null && portable.Cargo.Owner==u && e.Owner==portable,"cargo retains native owner");
        Console.Printf("CA381 LOAD before=%.6f after=%.6f total=%.6f personal=%.6f",
            before,u.DerivedStats.CarriedWeight,total,u.DerivedStats.InventoryWeight);
        Check(Abs(u.DerivedStats.CarriedWeight-before-total)<0.001,"carry includes empty and contents mass without compression");
        CaelumContainerSession.Open(u,other);
        Check(!Transfer(u,other,portable.Cargo,1,true),"nested chest rejected");
        bool placed=false;
        for(int direction=0;direction<16 && !placed;direction++)
        {u.Angle=direction*22.5;placed=portable.TryPlaceStorage(u);}
        Check(placed && portable.Cargo==null && e.Owner==portable,"place retains contents and releases personal load");
        portable.Destroy();
        Check(e.Owner==null && e.Amount==1 && e.ItemId==id && e.Durability==17,"destroyed chest spills exact equipment");
        // Un cofre legado conserva su llave y su estado serializado.
        let locked=CaelumStashChest(Actor.Spawn("CaelumLockedStashChest",u.Pos+(48,0,0),NO_REPLACE));
        Check(locked.IsChestLocked() && !locked.CanStore(u),"legacy lock still blocks storage");
        locked.ChestUnlocked=true;
        Check(locked.CanStore(u),"legacy unlocked state permits storage");
        Console.Printf("CA381 RESULT passed=%d failed=%d",Passed,Failed);
    }
    void Save(CaelumPlayer u)
    {
        Prepare(u);
        let chest=Chest(u,0);let e=Weapon(u);
        chest.ChangeTid(1381);
        let m=Material(u,u,23,CaelumConstants.MATERIAL_WOOD);
        CaelumContainerSession.Open(u,chest);
        Check(Transfer(u,chest,e,1,true) && Transfer(u,chest,m,23,true),"save fixture filled");
        Check(CaelumInventoryService.CarryStorageChest(u,chest),"save fixture carried");
        CaelumContainerSession.Open(u,chest);
        let mark=CA381Checkpoint(Actor.Spawn("CA381Checkpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
        mark.Chest=chest;mark.Equipment=e;mark.Material=m;
        mark.Identity=e.ItemId;mark.Wear=e.Durability;mark.Units=m.Amount;
        mark.Total=chest.TotalStorageWeight(u);u.PersistCharacterState();
        Console.Printf("CA381 PERSIST prepared passed=%d failed=%d",Passed,Failed);
    }
    void Verify(CaelumPlayer u)
    {
        let mark=CA381Checkpoint(u.FindInventory("CA381Checkpoint"));
        Check(mark!=null,"checkpoint survives");if(mark==null)return;
        let chest=mark.Chest;
        Check(chest!=null && chest.Cargo!=null && chest.Cargo.Owner==u,"carried chest survives");
        if(chest==null)return;
        Check(mark.Equipment!=null && mark.Equipment.Owner==chest && mark.Equipment.ItemId==mark.Identity
            && mark.Equipment.Durability==mark.Wear,"equipment exact owner and state survive");
        Check(mark.Material!=null && mark.Material.Owner==chest && mark.Material.Amount==mark.Units,"material native quantity survives");
        Check(chest.StorageSlots()==2 && Abs(chest.TotalStorageWeight(u)-mark.Total)<0.001,"saved slots and total mass survive");
        Check(chest.TID==1381 && ActorIterator.Create(1381,"CaelumStashChest").Next()==chest,
            "nonzero chest TID remains discoverable");
        Console.Printf("CA381 PERSIST passed=%d failed=%d map=%s",Passed,Failed,level.MapName);
    }
    void Upgrade(CaelumPlayer u)
    {
        let mark=CA381LegacyCheckpoint(u.FindInventory("CA381LegacyCheckpoint"));
        if(mark==null){Check(false,"legacy checkpoint required");return;}
        mark.Prototype.EnsureStorage();mark.Maze.EnsureStorage();
        mark.Prototype.EnsureStorage();mark.Maze.EnsureStorage();
        Check(mark.Prototype.StorageRevision==1 && mark.Prototype.StorageTier==1
            && mark.Maze.StorageRevision==1 && mark.Maze.StorageTier==1,
            "legacy storage migration is numbered and idempotent");
        CaelumContainerSession.Open(u,mark.Prototype);
        Check(CaelumContainerSession.Get(u).Chest==mark.Prototype,"upgraded prototype opens native storage");
    }
    void Cardinal(CaelumPlayer u)
    {
        Prepare(u);
        let chest=CaelumMazeChest(Actor.Spawn("CaelumMazeChest",u.Pos+(48,0,0),NO_REPLACE));
        chest.EnsureStorage();chest.EnsureLoot();chest.ChangeTid(1384);
        Check(chest.UsesMaterialStoragePolicy() && !chest.Stocked,"cardinal origin captured before transport");
        chest.MaterialAllocated=true;chest.MaterialRemaining[CaelumConstants.MATERIAL_WOOD]=7;
        let mark=CA381Checkpoint(Actor.Spawn("CA381Checkpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
        mark.Chest=chest;mark.Units=7;
        Check(CaelumInventoryService.CarryStorageChest(u,chest),"partly depleted cardinal chest carried");
        CardinalVerify(u);
    }
    void CardinalVerify(CaelumPlayer u)
    {
        let mark=CA381Checkpoint(u.FindInventory("CA381Checkpoint"));
        let chest=mark!=null ? CaelumMazeChest(mark.Chest) : null;
        Check(chest!=null && chest.Cargo!=null && chest.Cargo.Owner==u,"cardinal chest owner survives");
        if(chest==null)return;
        Check(chest.UsesMaterialStoragePolicy() && !chest.Stocked && chest.Seeded==0,
            "cardinal transport never seeds retired equipment");
        Check(chest.MaterialAllocated && chest.MaterialRemaining[CaelumConstants.MATERIAL_WOOD]==mark.Units,
            "cardinal partial allocation survives");
        Check(chest.StorageSlots()==0,"cardinal quota is not duplicated as physical loot");
        Check(ActorIterator.Create(1384,"CaelumMazeChest").Next()==chest,
            "cardinal carried TID remains registered");
        Console.Printf("CA381 CARDINAL passed=%d failed=%d map=%s",Passed,Failed,level.MapName);
    }
    void Supply(CaelumPlayer u)
    {
        Prepare(u);
        let chest=Chest(u,0);let m=Material(u,chest,5,CaelumConstants.MATERIAL_WOOD);
        CaelumContainerSession.Open(u,chest);
        Check(CaelumMainM00SupplyRules.IsLimited(u),"supply fixture uses actual MAP01 restriction");
        Check(!Transfer(u,chest,m,5,false) && m.Owner==chest && m.Amount==5,
            "container withdrawal cannot bypass MAP01 raw-material quota");
        m.LimboQuotaReserved=true;m.LimboQuotaPlayer=u.PlayerNumber()+1;
        Check(!Transfer(u,chest,m,5,false) && m.Owner==chest,"foreign prepaid quota remains protected");
        m.LimboQuotaPlayer=u.PlayerNumber();m.LimboQuestUnits=5;
        Check(Transfer(u,chest,m,5,false) && m.Owner==u && m.LimboQuestUnits==5 && !m.InMagicBox,
            "own prepaid quota transfers once without multiplying temporary units");
        Check(!Transfer(u,chest,m,5,true),"withdrawn temporary quota cannot be hidden from cleanup");
        Console.Printf("CA381 SUPPLY passed=%d failed=%d",Passed,Failed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca381_suite")Suite(u);
        if(e.Name=="ca381_save")Save(u);
        if(e.Name=="ca381_verify")Verify(u);
        if(e.Name=="ca381_openverify")
            Check(CaelumContainerSession.Get(u)!=null && CaelumContainerSession.Get(u).Chest!=null,
                "filled carried storage session reloads open");
        if(e.Name=="ca381_upgrade")Upgrade(u);
        if(e.Name=="ca381_upgrade_verify")
        {
            let mark=CA381LegacyCheckpoint(u.FindInventory("CA381LegacyCheckpoint"));
            Check(mark!=null && CaelumContainerSession.Get(u)!=null
                && CaelumContainerSession.Get(u).Chest==mark.Prototype,"storage session saved open survives");
            Upgrade(u);
        }
        if(e.Name=="ca381_downgrade")
        {
            let mark=CA381LegacyCheckpoint(u.FindInventory("CA381LegacyCheckpoint"));
            let session=CaelumContainerSession.Get(u);
            if(session!=null){session.Close();session.Destroy();}
            mark.Prototype.StorageRevision=0;mark.Prototype.StorageTier=0;
            mark.Prototype.ChestOpen=true;mark.Prototype.RefreshChestVisual();
            mark.Maze.StorageRevision=0;mark.Maze.StorageTier=0;
            mark.Maze.StorageLootPolicyRevision=0;mark.Maze.StorageMaterialPolicy=false;
            Check(mark.Maze.Loot[0]==null,"migration reversal preserves looted gap");
        }
        if(e.Name=="ca381_cardinal")Cardinal(u);
        if(e.Name=="ca381_cardinal_verify")CardinalVerify(u);
        if(e.Name=="ca381_supply")Supply(u);
    }
}
