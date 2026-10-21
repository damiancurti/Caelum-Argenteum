// La ropa usa la misma identidad nativa, peso y transporte que el equipo.
class CaelumClothing : Object play
{
    static CaelumEquipmentItem Equipped(CaelumPlayer user,int region)
    {
        if(user==null)return null;
        let record=user.GetPersistentCharacterState(false);
        if(record==null)return null;
        let item=user.FindNativeEquipmentItemById(record.EquippedClothingItemId[region]);
        return item!=null && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING
            && item.ArmorSlot==region && item.Equipped && !item.InMagicBox ? item : null;
    }

    static CaelumEquipmentItem Create(CaelumPlayer user,int type,int size)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumClothingPickup",user.Pos,NO_REPLACE));
        if(item==null)return null;
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_CLOTHING;
        item.ItemType=type;item.ArmorSlot=CaelumClothingData.Region(type);
        item.Tier=1;item.EquipmentSize=size;item.Durability=100;
        item.UnitWeight=CaelumClothingData.Weight(type,size);
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        return item;
    }

    static void Migrate(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete || user.CharacterProfile==null)return;
        let record=user.GetPersistentCharacterState(true);
        if(record.ClothingRevision>=CaelumClothingData.MIGRATION_REVISION){user.ClothingMigrationReady=true;return;}
        CaelumEquipmentItem pieces[4];
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        // Preparar todas antes de adjuntar: un fallo no entrega medio conjunto.
        for(int slot=0;slot<4;slot++)
        {
            pieces[slot]=Create(user,CaelumClothingData.Initial(slot),size);
            if(pieces[slot]==null)
            {for(int i=0;i<slot;i++)pieces[i].Destroy();return;}
        }
        let thermal=CaelumThermalBody.Get(user,true);
        for(int slot=0;slot<4;slot++)
        {
            let item=pieces[slot];
            item.AttachToOwner(user);user.EnsureEquipmentItemId(item);
            item.Equipped=true;record.EquippedClothingItemId[slot]=item.ItemId;
            if(thermal!=null){item.ThermalWaterKg=thermal.BaseWaterKg[slot];thermal.BaseWaterKg[slot]=0;}
        }
        // Excepción de carga aprobada: nunca vender, reducir ni soltar ropa.
        record.ClothingRevision=CaelumClothingData.MIGRATION_REVISION;user.ClothingMigrationReady=true;
        user.OnNativeInventoryChanged();
    }

    static void Equip(CaelumPlayer user,CaelumEquipmentItem item,bool worn)
    {
        let record=user.GetPersistentCharacterState(true);
        let previous=Equipped(user,item.ArmorSlot);
        if(worn && previous!=null)previous.Equipped=false;
        item.Equipped=worn;
        record.EquippedClothingItemId[item.ArmorSlot]=worn ? item.ItemId : 0;
        ReconcileWater(user);
    }

    static bool Converted(CaelumPlayer user)
    {
        if(user==null)return false;
        let record=user.GetPersistentCharacterState(false);
        return record!=null && record.ClothingRevision>=CaelumClothingData.MIGRATION_REVISION;
    }

    static double Water(CaelumPlayer user,CaelumThermalState thermal,int slot)
    {
        let garment=Equipped(user,slot);let armor=CaelumThermalBody.EquippedPiece(user,slot);
        return (garment!=null ? garment.ThermalWaterKg : 0)
            +(armor!=null ? armor.ThermalWaterKg : 0)+thermal.BareWaterKg[slot];
    }

    static void SetWater(CaelumPlayer user,CaelumThermalState thermal,int slot,double kg)
    {
        let garment=Equipped(user,slot);let armor=CaelumThermalBody.EquippedPiece(user,slot);
        double total=CaelumThermalData.WaterCapacityKgPerArea(CaelumThermalBody.Material(user,slot));
        double inner=garment==null ? 0 : armor==null ? total
            : Min(total,CaelumThermalData.WaterCapacityKgPerArea(CaelumThermalData.LIGHT_CLOTH));
        double fraction=total>0 ? inner/total : 0;
        if(garment!=null)garment.ThermalWaterKg=kg*fraction;
        if(armor!=null)armor.ThermalWaterKg=kg*(1-fraction);
        thermal.BareWaterKg[slot]=garment==null && armor==null ? kg : 0;
        thermal.BaseWaterKg[slot]=0;
    }

    static void ReconcileWater(CaelumPlayer user)
    {
        if(!Converted(user))return;
        let thermal=CaelumThermalBody.Get(user,false);
        if(thermal==null || thermal.SurfaceArea<=0)return;
        for(int slot=0;slot<4;slot++)
        {
            double before=Water(user,thermal,slot);
            double capacity=thermal.SurfaceArea*thermal.Coverage[slot]
                *CaelumThermalData.WaterCapacityKgPerArea(CaelumThermalBody.Material(user,slot));
            double after=Min(before,capacity);
            thermal.ClothingRunoffKg+=before-after;
            SetWater(user,thermal,slot,after);
        }
    }

    static int ThirdMaterial(CaelumPlayer user)
    {return CaelumClothingData.IsRecipe(user.CraftingSelectionRecipe)
        ? CaelumClothingData.Material(user.CraftingSelectionRecipe-CaelumClothingData.FIRST_RECIPE,2) : CaelumConstants.MATERIAL_SILVER_INGOT;}
    static int ThirdTier(CaelumPlayer user)
    {return CaelumClothingData.IsRecipe(user.CraftingSelectionRecipe)
        ? CaelumClothingData.MaterialTier(user.CraftingSelectionRecipe-CaelumClothingData.FIRST_RECIPE,2) : 1;}

    static void Preview(CaelumPlayer user)
    {
        int type=user.CraftingSelectionRecipe-CaelumClothingData.FIRST_RECIPE;
        int size=user.CraftingSelectionSize;
        user.CraftingSelectionTier=1;user.CraftingFinalWeight=CaelumClothingData.Weight(type,size);
        user.CraftingBasicMaterialType=CaelumClothingData.Material(type,0);
        user.CraftingBasicMaterialTier=CaelumClothingData.MaterialTier(type,0);
        user.CraftingTierMaterialType=CaelumClothingData.Material(type,1);
        user.CraftingTierMaterialTier=CaelumClothingData.MaterialTier(type,1);
        user.CraftingBasicRequired=CaelumClothingData.Units(type,size,0);
        user.CraftingTierRequired=CaelumClothingData.Units(type,size,1);
        user.CraftingSilverRequired=CaelumClothingData.Units(type,size,2);
        user.CraftingGoldRequired=0;
        int capabilities=user.CraftingNetworkCapabilities;
        user.CraftingMissingStationType=!CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_WORKBENCH)
            ? CaelumConstants.CRAFTING_STATION_WORKBENCH
            : !CaelumCraftingRules.NetworkHasStation(capabilities,CaelumConstants.CRAFTING_STATION_SEWING_MACHINE)
            ? CaelumConstants.CRAFTING_STATION_SEWING_MACHINE : CaelumConstants.CRAFTING_STATION_NONE;
    }

    static void Complete(CaelumPlayer user)
    {
        if(!user.CraftingTaskCompleting || !user.CraftingSelectedInfrastructureAvailable
            || !user.ValidateCraftingTaskReservations())return;
        let item=Create(user,user.CraftingSelectionRecipe-CaelumClothingData.FIRST_RECIPE,user.CraftingSelectionSize);
        if(item==null)return;
        if(!user.ConsumeSelectedWeaponCraftingMaterials()){item.Destroy();return;}
        item.InMagicBox=!CaelumMainM00RonnieTrial.CanUsePersonalCraftingOutput(user);
        item.AttachToOwner(user);user.EnsureEquipmentItemId(item);
        CaelumNotifications.Acquired(user,item,1);
        user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_CREATED;
        user.OnNativeInventoryChanged();
    }
}

class CaelumClothingPickup : CaelumEquipmentItem
{
    Default {Tag "$CA_EQUIPMENT_CATEGORY_CLOTHING";Inventory.Icon "graphics/caelum/icons/materials/ca_material_fabric.png";}
    // Icono de tela existente; los modelos de cada prenda pertenecen a #387.
    States {Spawn: M018 A -1; Stop;}
    override bool TryPickup(in out Actor toucher){return TryEquipmentPickup(toucher);}
}
