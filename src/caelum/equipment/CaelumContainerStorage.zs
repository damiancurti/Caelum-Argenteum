// #381: datos aprobados; los objetos siguen perteneciendo al Actor.Inv del cofre.
class CaelumContainerRules : Object play
{
    const REVISION = 1;
    const SMALL = 0;
    const MEDIUM = 1;
    const LARGE = 2;
    const EMPTY_WEIGHT_FRACTION = 0.1;

    static clearscope int Slots(int tier)
    {
        switch(Clamp(tier,SMALL,LARGE))
        {
            case SMALL:return 10;
            case LARGE:return 100;
            default:return 25;
        }
    }
    static clearscope double Capacity(int tier)
    {
        switch(Clamp(tier,SMALL,LARGE))
        {
            case SMALL:return 100.0;
            case LARGE:return 10000.0;
            default:return 1000.0;
        }
    }
    static clearscope double ScaleFor(int tier)
    {
        switch(Clamp(tier,SMALL,LARGE))
        {
            case SMALL:return 0.5;
            case LARGE:return 2.0;
            default:return 1.0;
        }
    }
    static clearscope String NameKey(int tier)
    {
        switch(Clamp(tier,SMALL,LARGE))
        {
            case SMALL:return "CA_CONTAINER_SMALL";
            case LARGE:return "CA_CONTAINER_LARGE";
            default:return "CA_CONTAINER_MEDIUM";
        }
    }
    static bool Boxed(Inventory item)
    {
        let special=CaelumSpecialInventoryItem(item);
        return special!=null ? special.InMagicBox : CaelumCityTradeSession.Boxed(item);
    }
    static void SetBoxed(Inventory item,bool boxed)
    {
        let special=CaelumSpecialInventoryItem(item);
        if(special!=null)special.InMagicBox=boxed;
        else CaelumCityTradeSession.SetBoxed(item,boxed);
    }
    static bool CanBox(Inventory item)
    {
        if(item is "CaelumArrowAmmo" || item is "CaelumBoltAmmo")return false;
        return item is "CaelumEquipmentItem" || item is "CaelumSpecialInventoryItem"
            || item is "CaelumConsumableItem" || item is "CaelumCarbineAmmo";
    }
    static bool Allowed(CaelumPlayer user,Inventory item,bool depositing)
    {
        if(item==null || item.Amount<=0 || CaelumWaterBoiling.Locked(item) || item is "CaelumChestCargo"
            || item is "CaelumMagicBox" || item is "CaelumTarotDeck"
            || user.GetFormalInventoryEntryKind(item)<0)return false;
        if(depositing && !CaelumPropertyRules.ResidenceAllowed(user))return false;
        let equipment=CaelumEquipmentItem(item);
        if(depositing && equipment!=null
            && (equipment.Equipped || equipment.IsLimboTemporary() || equipment.IsLimboFirstWeapon()
                || user.IsEquipmentItemCraftingLocked(equipment.ItemId)))return false;
        let special=CaelumSpecialInventoryItem(item);
        if(depositing && special!=null && special.LimboQuestUnits>0)return false;
        if(!depositing && equipment==null && !CaelumCampData.IsItem(item) && !(item is "CaelumLockItem") && item.MaxAmount<=1
            && user.FindInventory(item.GetClassName())!=null)return false;
        if(depositing && special!=null && special.GetSpecialCategory()==CaelumConstants.EQUIPMENT_KIND_MATERIAL
            && user.GetReservedCraftingMaterialUnits(special.GetSpecialType(),special.GetSpecialTier())>0)return false;
        return true;
    }
    static bool Stackable(Inventory item)
    {
        if(item.MaxAmount<=1)return false;
        let special=CaelumSpecialInventoryItem(item);
        return item is "CaelumConsumableItem" || item is "CaelumCarbineAmmo"
            || item is "CaelumArrowAmmo" || item is "CaelumBoltAmmo"
            || (special!=null && (special.GetSpecialCategory()==CaelumConstants.EQUIPMENT_KIND_MATERIAL
                || special.GetSpecialCategory()==CaelumConstants.EQUIPMENT_KIND_CURRENCY));
    }
    static Inventory MatchingStack(Actor owner,Inventory item)
    {
        if(!Stackable(item))return null;
        let special=CaelumSpecialInventoryItem(item);
        for(Inventory candidate=owner.Inv;candidate!=null;candidate=candidate.Inv)
        {
            if(candidate.GetClass()!=item.GetClass())continue;
            let other=CaelumSpecialInventoryItem(candidate);
            if(special!=null && (other.GetSpecialType()!=special.GetSpecialType()
                || other.GetSpecialTier()!=special.GetSpecialTier()
                || other.LimboQuotaReserved!=special.LimboQuotaReserved
                || (special.LimboQuotaReserved && other.LimboQuotaPlayer!=special.LimboQuotaPlayer)))continue;
            return candidate;
        }
        return null;
    }
    static double Weight(CaelumPlayer user,Inventory item)
    {
        let equipment=CaelumEquipmentItem(item);
        return equipment!=null && !equipment.AcquisitionResolved
            ? equipment.PreviewUnitWeight(user) : user.GetFormalInventoryEntryWeight(item);
    }
}

// Una ficha transportable referencia al dueño físico; no duplica sus objetos.
// El motor sólo traslada automáticamente el inventario DIRECTO del jugador.
class CaelumChestCargo : Inventory
{
    CaelumStashChest Chest;
    int TravelTID;
    Array<int> ContentTravelTIDs;

    double CarriedWeight(CaelumPlayer user)
    {
        return Chest!=null ? Chest.TotalStorageWeight(user) : 0.0;
    }
    override void PreTravelled()
    {
        Super.PreTravelled();
        if(Chest==null)return;
        // La tabla TID pertenece al mapa. Desvincular antes de cambiar de nivel.
        TravelTID=Chest.TID;Chest.ChangeTid(0);
        ContentTravelTIDs.Clear();
        Chest.UnlinkFromWorld();Chest.ChangeStatNum(STAT_TRAVELLING);
        for(Inventory item=Chest.Inv;item!=null;item=item.Inv)
        {
            ContentTravelTIDs.Push(item.TID);item.ChangeTid(0);
            item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);
        }
    }
    override void Travelled()
    {
        Super.Travelled();
        if(Chest==null || Owner==null)return;
        Chest.ChangeStatNum(STAT_DEFAULT);
        Chest.SetOrigin(Owner.Pos,false);Chest.LinkToWorld();
        Chest.ChangeTid(TravelTID);TravelTID=0;
        int index=0;
        for(Inventory item=Chest.Inv;item!=null;item=item.Inv)
        {
            item.ChangeStatNum(STAT_INVENTORY);item.LinkToWorld();
            if(index<ContentTravelTIDs.Size())item.ChangeTid(ContentTravelTIDs[index++]);
        }
        ContentTravelTIDs.Clear();
    }
    override void Tick()
    {
        Super.Tick();
        if(Chest!=null && Owner!=null)Chest.SetOrigin(Owner.Pos,false);
    }
    override void OnDestroy()
    {
        if(Chest!=null)
        {
            let body=Chest;Chest=null;
            body.Cargo=null;
            body.RestoreWorldStorage(Owner!=null ? Owner.Pos : body.Pos);
        }
        Super.OnDestroy();
    }
    override Inventory CreateTossable(int amount) { return null; }
    override bool TryPickup(in out Actor toucher) { return false; }
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
}

// Sólo proyección y comandos de la sesión; la mutación se confirma en InventoryService.
class CaelumContainerSession : Inventory
{
    CaelumStashChest Chest;
    Array<Inventory> Rows;
    Array<String> Labels;
    Array<int> Amounts;
    int Selection, QuantityIndex;
    bool Depositing;
    int UsedSlots, MaximumSlots;
    double UsedWeight, MaximumWeight, TotalWeight;
    String Status;

    static CaelumContainerSession Get(CaelumPlayer user,bool create=false)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return null;
        let session=CaelumContainerSession(user.FindInventory("CaelumContainerSession"));
        if(session==null && create)
        {
            session=CaelumContainerSession(Actor.Spawn("CaelumContainerSession",user.Pos,NO_REPLACE));
            if(session!=null)session.AttachToOwner(user);
        }
        return session;
    }
    static void Open(CaelumPlayer user,CaelumStashChest chest)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || chest==null || !chest.CanReachStorage(user)
            || (chest.GetChestLockNumber()>0 && !chest.ChestUnlocked))return;
        if(chest.InstalledPadlock!=null && !chest.PadlockReleased && !CaelumLockRules.HasAccess(user,chest.InstalledPadlock))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_LOCK_NEEDS_KEY",false));return;}
        let session=Get(user,true);if(session==null)return;
        if(session.Chest==chest && chest.ChestOpen)return;
        user.EquipmentMenuOpen=false;user.ClosePalomoMerchant();
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);
        let old=CaelumChestPreviewState.Get(user);if(old!=null)old.Close();
        session.Close();session.Chest=chest;session.Selection=0;session.Depositing=false;
        session.QuantityIndex=0;session.Status="";
        bool opening=!chest.ChestOpen;
        chest.PadlockReleased=true;chest.ChestOpen=true;chest.RefreshChestVisual();session.Refresh();
        if(opening && chest.InstalledPadlock!=null)chest.CommitTheft(user);
    }
    void Close()
    {
        if(Chest!=null)
        {Chest.ChestOpen=false;Chest.PadlockReleased=false;Chest.RefreshChestVisual();}
        Chest=null;Rows.Clear();Labels.Clear();Amounts.Clear();
    }
    clearscope int Quantity()
    {
        if(Selection<0 || Selection>=Rows.Size() || Rows[Selection]==null)return 0;
        int available=Amounts[Selection];
        switch(QuantityIndex)
        {
            case 1:return Min(available,1);
            case 2:return Min(available,5);
            case 3:return Min(available,10);
            default:return available;
        }
    }
    void Refresh()
    {
        let user=CaelumPlayer(Owner);
        if(Chest==null)return;
        if(!Chest.CanStore(user)){Close();return;}
        Inventory selected=Selection>=0 && Selection<Rows.Size() ? Rows[Selection] : null;
        Rows.Clear();Labels.Clear();Amounts.Clear();
        Actor source=Depositing ? Actor(user) : Actor(Chest);
        for(Inventory item=source.Inv;item!=null;item=item.Inv)
        {
            if(!CaelumContainerRules.Allowed(user,item,Depositing)
                || (!Depositing && !Chest.IsStorageItem(item)))continue;
            Rows.Push(item);Amounts.Push(item.Amount);
            Labels.Push(CaelumNotifications.Describe(user,item,item.Amount,true));
            if(item==selected)Selection=Rows.Size()-1;
        }
        Selection=Clamp(Selection,0,Max(0,Rows.Size()-1));
        UsedSlots=Chest.StorageSlots();MaximumSlots=CaelumContainerRules.Slots(Chest.StorageTier);
        UsedWeight=Chest.StorageWeight(user);MaximumWeight=CaelumContainerRules.Capacity(Chest.StorageTier);
        TotalWeight=Chest.TotalStorageWeight(user);
    }
    void Execute()
    {
        if(Selection<0 || Selection>=Rows.Size() || Chest==null)return;
        let user=CaelumPlayer(Owner);
        Inventory item=Rows[Selection];int quantity=Quantity();int amount=Amounts[Selection];
        Refresh();
        if(Chest==null || Selection>=Rows.Size() || Rows[Selection]!=item
            || Amounts[Selection]!=amount || Quantity()!=quantity){Status="CA_CONTAINER_CHANGED";return;}
        bool ok=CaelumInventoryService.TransferContainerItem(user,Chest,item,quantity,Depositing);
        Status=ok ? "CA_CONTAINER_TRANSFERRED" : "CA_CONTAINER_REJECTED";
        Refresh();
    }
    override void Tick()
    {
        Super.Tick();
        let user=CaelumPlayer(Owner);
        if(Chest!=null && (user==null || !Chest.CanStore(user) || user.EquipmentMenuOpen
            || user.PalomoMerchantMenuOpen || user.CraftingMenuOpen))Close();
    }
    override void PreTravelled(){Close();Super.PreTravelled();}
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
}
