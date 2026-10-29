// #415: selección y traslado físico. La ruta accesible y la hora vencida las
// aporta el planificador; esta transacción vuelve a comprobar dueño y cerradura.
class CaelumTheftTransfer : Object play
{
    static bool KeyAccess(CaelumStashChest chest,CaelumCombatActor thief)
    {
        if(chest==null || thief==null || chest.Cargo!=null)return false;
        int lock=chest.GetChestLockNumber();
        if(lock>0 && !chest.ChestUnlocked && !thief.CheckKeys(lock,false,true))return false;
        if(chest.InstalledPadlock==null || chest.PadlockReleased)return true;
        for(Inventory cursor=thief.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let key=CaelumLockItem(cursor);
            if(key!=null && key.Amount>0 && key.LockItemType==chest.InstalledPadlock.LockItemType+3
                && CaelumLockRules.SamePair(key.PairIdentity,chest.InstalledPadlock.PairIdentity))return true;
        }
        return false;
    }
    static bool Eligible(CaelumStashChest chest,Inventory item)
    {
        if(chest==null || !chest.IsStorageItem(item) || item is 'CaelumChestCargo'
            || item is 'CaelumMagicBox' || item is 'CaelumTarotDeck'
            || CaelumWaterBoiling.Locked(item))return false;
        let equipment=CaelumEquipmentItem(item);
        if(equipment!=null && (equipment.Equipped || equipment.IsLimboTemporary() || equipment.IsLimboFirstWeapon()))return false;
        let special=CaelumSpecialInventoryItem(item);
        if(special!=null && (special.LimboQuestUnits>0 || special.LimboQuotaReserved))return false;
        return CaelumInventoryService.GetFormalInventoryEntryKind(null,item)>=0;
    }
    static double EquipmentWeight(CaelumEquipmentItem item)
    {
        if(item.HasAcquiredIdentity())return item.GetTotalUnitWeight();
        int kind=item.PreviewEquipmentKind(),type=item.PreviewItemType(),tier=item.PreviewTier();
        // No adaptar el objeto al jugador observador ni cambiar su talla al robarlo.
        int size=item.PreviewEquipmentSize(null);
        double weight=item.UnitWeight;
        if(kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)weight=CaelumClothingData.Weight(type,size);
        else if(kind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {let model=new('CaelumWeaponModel');weight=model.GetWeightFor(type,tier,size);}
        else if(kind==CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {let model=new('CaelumArmorModel');weight=model.GetWeightFor(item.PreviewArmorSlot(),type,tier,size);}
        else if(kind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {let model=new('CaelumShieldModel');weight=model.GetWeightFor(type,tier,size);}
        return Max(0,weight)+Max(0,item.ThermalWaterKg);
    }
    static double Weight(Inventory item)
    {
        if(item==null)return 0;
        let equipment=CaelumEquipmentItem(item);
        return equipment!=null?EquipmentWeight(equipment)*Max(0,item.Amount)
            :CaelumInventoryService.GetFormalInventoryEntryWeight(null,item);
    }
    static double Value(Inventory item)
    {
        let equipment=CaelumEquipmentItem(item);
        if(equipment==null || equipment.HasAcquiredIdentity())return CaelumEconomyRules.GetInventoryStackBaseValue(item);
        return CaelumEconomyRules.GetEquipmentBaseValueFor(equipment.PreviewEquipmentKind(),equipment.PreviewItemType(),
            equipment.PreviewArmorSlot(),equipment.PreviewTier(),equipment.PreviewEssenceType(),
            Max(0,EquipmentWeight(equipment)-equipment.ThermalWaterKg))*Max(0,item.Amount);
    }
    static double Carried(CaelumCombatActor thief)
    {
        double weight=thief.CombatArmor==null?0:thief.CombatArmor.GetTotalWeight();
        for(Inventory item=thief.Inv;item!=null;item=item.Inv)
            if(!CaelumContainerRules.Boxed(item))weight+=Weight(item);
        return weight;
    }
    static double Capacity(CaelumCombatActor thief)
    {return Max(0,thief.Mass*thief.CalculateActorType4Percent(thief.CombatStrength)/100.0);}
    static void ResolveEquipment(CaelumEquipmentItem item)
    {
        if(item==null || item.HasAcquiredIdentity())return;
        int kind=item.PreviewEquipmentKind(),type=item.PreviewItemType(),tier=item.PreviewTier();
        int size=item.PreviewEquipmentSize(null),slot=item.PreviewArmorSlot(),essence=item.PreviewEssenceType();
        double weight=Max(0,EquipmentWeight(item)-item.ThermalWaterKg);int maximum=0;
        if(kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)maximum=100;
        else if(kind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {let model=new('CaelumWeaponModel');maximum=model.GetMaximumDurabilityFor(type,tier,size);}
        else if(kind==CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {let model=new('CaelumArmorModel');maximum=model.GetMaximumDurabilityFor(type,tier,size);}
        else if(kind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {let model=new('CaelumShieldModel');maximum=model.GetMaximumDurabilityFor(type,tier,size);}
        item.MigrateWeaponDurability();
        int encoded=item.args[kind==CaelumConstants.EQUIPMENT_KIND_ARMOR?4:3];
        item.EquipmentKind=kind;item.ItemType=type;item.Tier=tier;item.EquipmentSize=size;
        item.ArmorSlot=slot;item.EssenceType=essence;item.UnitWeight=weight;
        item.Durability=encoded>0?Min(maximum,encoded-1):maximum;
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;
        item.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
    }
    static Inventory Select(CaelumCombatActor thief,out Array<CaelumStashChest> accessible)
    {
        if(thief==null || thief.bDestroyed || thief.health<=0)return null;
        double room=Max(0,Capacity(thief)-Carried(thief)),bestValue=0;
        Inventory best;
        for(int i=0;i<accessible.Size();i++)
        {
            let chest=accessible[i];if(!KeyAccess(chest,thief))continue;
            for(Inventory item=chest.Inv;item!=null;item=item.Inv)
            {
                if(!Eligible(chest,item) || Weight(item)>room)continue;
                double value=Value(item);if(value<=bestValue)continue;
                best=item;bestValue=value;
            }
        }
        return best;
    }
    static bool Move(CaelumCombatActor thief,CaelumStashChest chest,Inventory item,bool historical=false)
    {
        if(thief==null || thief.bDestroyed || thief.health<=0 || !KeyAccess(chest,thief)
            || !Eligible(chest,item) || Weight(item)>Max(0,Capacity(thief)-Carried(thief)))return false;
        // Conservar la instancia completa conserva lotes, agua, temperatura,
        // suciedad, desgaste e identidad. No fusionar ni generar reemplazos.
        if(!historical)CaelumFoodInventory.Reconcile(item);
        ResolveEquipment(CaelumEquipmentItem(item));
        chest.RemoveInventory(item);item.AttachToOwner(thief);
        CaelumContainerRules.SetBoxed(item,false);
        if(!historical)CaelumFoodInventory.Relocate(item);
        let maintenance=thief.GetActorMaintenance();if(maintenance!=null)maintenance.WeightReady=false;
        return item.Owner==thief;
    }
}
