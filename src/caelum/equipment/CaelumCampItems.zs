// #411: cada pieza conserva identidad propia; varias ollas no mezclan su agua.
class CaelumCampTent : CaelumSpecialInventoryItem
{
    Default { Tag "$CA_CAMP_TENT"; Inventory.Icon "graphics/caelum/icons/camp/tent.png"; }
    override int GetSpecialCategory(){return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;}
    override int GetSpecialType(){return CaelumCampData.TENT_KEY;}
    override double GetUnitWeight(){return CaelumCampData.TENT_KG;}
    override bool HandlePickup(Inventory item)
    {if(item is 'CaelumCampTent')return false;return Super.HandlePickup(item);}
    States { Spawn: CPTN A -1; Stop; }
}

class CaelumCampPot : CaelumWaterContainer
{
    double CampBoilSeconds;
    Default { Tag "$CA_CAMP_POT"; Inventory.Icon "graphics/caelum/icons/camp/iron_pot.png"; }
    override int GetConsumableType(){return CaelumCampData.POT_CONSUMABLE;}
    override double GetCapacityLiters(){return CaelumCampData.POT_LITERS;}
    override double GetUnitWeight(){return CaelumCampData.POT_KG+Max(0,WaterLiters);}
    override double CoolWater(double ambient,double wind,double seconds)
    {return CaelumCampPhysics.Cool(WaterTemperatureC,ambient,wind,seconds,WaterLiters);}
    override bool IndependentContainers(){return true;}
    States { Spawn: CPPT A -1; Stop; }
}

class CaelumCampInventory : Object play
{
    static void ToggleBox(CaelumPlayer user,Inventory item)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || item==null || item.Owner!=user
            || !CaelumCampData.IsItem(item) || CaelumWaterBoiling.Locked(item))return;
        user.SyncLiveMagicBoxOwnershipFromPersistentState();
        if(!user.MagicBoxOwned)return;
        user.RefreshCarriedInventorySummary();
        bool boxed=CaelumContainerRules.Boxed(item);
        double weight=user.GetFormalInventoryEntryWeight(item);
        if(boxed)
        {if(!user.CanMoveRawWeightFromMagicBoxToPersonal(weight))return;}
        else if(!user.HasNativeMagicBoxSlotAvailable() || !user.CanAddRawWeightToMagicBox(weight))return;
        CaelumContainerRules.SetBoxed(item,!boxed);
        user.LastEquipmentAction=boxed?CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX:
            CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX;
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
    }
    static void Drop(CaelumPlayer user,Inventory item)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || item==null || item.Owner!=user
            || !CaelumCampData.IsItem(item) || CaelumWaterBoiling.Locked(item))return;
        let dropped=item.CreateTossable(1);if(dropped==null)return;
        CaelumContainerRules.SetBoxed(dropped,false);
        dropped.SetOrigin(user.Pos+(Cos(user.Angle)*48,Sin(user.Angle)*48,8),false);
        dropped.TossItem();user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
    }
}
