// La representación de inventario se transforma una sola vez en el dueño físico.
// Después se transporta con CaelumChestCargo: conserva contenido, llaves y suciedad.
class CaelumStorageFurnitureItem : CaelumSpecialInventoryItem abstract
{
    CaelumContaminationState ContaminationState;
    virtual clearscope int Variant(){return 0;}
    override int GetSpecialCategory(){return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;}
    override int GetSpecialType(){return CaelumStorageFurnitureData.FIRST_KEY+Variant();}
    override double GetUnitWeight(){return CaelumStorageFurnitureData.Mass(Variant());}
    override bool HandlePickup(Inventory item)
    {if(item is 'CaelumStorageFurnitureItem')return false;return Super.HandlePickup(item);}
    override Inventory CreateCopy(Actor other)
    {
        double dirt=CaelumContaminationStorage.Value(self);
        let copy=Super.CreateCopy(other);
        if(copy!=null && copy!=self)CaelumContaminationStorage.Set(copy,dirt);
        return copy;
    }
    override Inventory CreateTossable(int count)
    {
        double dirt=CaelumContaminationStorage.Value(self);
        let copy=Super.CreateTossable(count);
        if(copy!=null && copy!=self)CaelumContaminationStorage.Set(copy,dirt);
        if(copy!=null)CaelumContaminationObject.Register(copy);
        return copy;
    }
    virtual bool Place(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || Owner!=user || InMagicBox || Amount!=1)return false;
        let body=CaelumStashChest(Actor.Spawn(CaelumStorageFurnitureData.BodyClass(Variant()),user.Pos,NO_REPLACE));
        if(body==null)return false;
        // Spawn aún no ha ejecutado PostBeginPlay: comprobar las medidas y la
        // capacidad de esta pieza, no las del cofre base durante ese primer tic.
        body.args[4]=(Variant()==0?CaelumContainerRules.MEDIUM:CaelumContainerRules.SMALL)+1;
        body.EnsureStorage();
        body.A_SetSize(CaelumStorageFurnitureData.Radius(Variant()),CaelumStorageFurnitureData.Height(Variant()),false);
        let cargo=CaelumChestCargo(Actor.Spawn('CaelumChestCargo',user.Pos,NO_REPLACE));
        if(cargo==null){body.Destroy();return false;}
        body.Angle=user.Angle;cargo.Chest=body;body.Cargo=cargo;
        body.HideCarriedStorage();cargo.AttachToOwner(user);
        if(!body.TryPlaceStorage(user))
        {cargo.Chest=null;body.Cargo=null;cargo.Destroy();body.Destroy();return false;}
        body.GrantLawfulTitle(user);
        CaelumContaminationStorage.Set(body,CaelumContaminationStorage.Value(self));
        Destroy();user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
}
class CaelumWardrobeItem : CaelumStorageFurnitureItem
{
    Default {Tag "$CA_FURNITURE_WARDROBE";Inventory.Icon "graphics/caelum/icons/furniture/wardrobe.png";}
    States {Spawn:CWRD A -1;Stop;}
}
class CaelumCupboardItem : CaelumStorageFurnitureItem
{
    override int Variant(){return 1;}
    Default {Tag "$CA_KITCHEN_CUPBOARD";Inventory.Icon "graphics/caelum/icons/kitchen_stations/cupboard.png";}
    States {Spawn:CKCB A -1;Stop;}
}
class CaelumPortableCupboard : CaelumKitchenCupboard
{
    override bool CanCarryAsStorage(){return true;}
    override int StorageDisplayType(){return CaelumStorageFurnitureData.CUPBOARD_DISPLAY;}
    override bool CanReachStorage(CaelumPlayer user)
    {return Cargo!=null?CaelumPlayerAuthority.CanMutate(user) && Cargo.Owner==user:Super.CanReachStorage(user);}
}

class CaelumStorageFurnitureInventory : Object play
{
    static void ToggleBox(CaelumPlayer user,Inventory item)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || item==null || item.Owner!=user || !CaelumStorageFurnitureData.IsItem(item))return;
        user.SyncLiveMagicBoxOwnershipFromPersistentState();if(!user.MagicBoxOwned)return;
        user.RefreshCarriedInventorySummary();bool boxed=CaelumContainerRules.Boxed(item);
        double weight=user.GetFormalInventoryEntryWeight(item);
        if(boxed){if(!user.CanMoveRawWeightFromMagicBoxToPersonal(weight))return;}
        else if(!user.HasNativeMagicBoxSlotAvailable() || !user.CanAddRawWeightToMagicBox(weight))return;
        CaelumContainerRules.SetBoxed(item,!boxed);
        user.LastEquipmentAction=boxed?CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX:CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
    }
    static void Drop(CaelumPlayer user,Inventory item)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || item==null || item.Owner!=user || !CaelumStorageFurnitureData.IsItem(item))return;
        let dropped=item.CreateTossable(1);if(dropped==null)return;
        CaelumContainerRules.SetBoxed(dropped,false);
        dropped.SetOrigin(user.Pos+(Cos(user.Angle)*48,Sin(user.Angle)*48,8),false);dropped.TossItem();
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
    }
}
