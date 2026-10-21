// #385: la cantidad sigue en Actor.Inv. Cada registro describe un producto del
// catálogo y su próxima unidad, nunca una copia del inventario o de la moneda.
class CaelumShopProduct : Object play
{
    const SIMPLE=0;
    const EQUIPMENT=1;
    const MATERIAL=2;
    const LOCK=3;
    const BOOK=4;
    int Kind,ItemType,Tier,Size,Slot,Essence,EquipmentKind,Target,Recipe;
    Name NativeClass;
    double BaseValue,UnitTics,NextDue;
    Inventory Stock;

    static CaelumShopProduct Add(CaelumCityMerchant vendor,int kind,int target)
    {
        let product=new("CaelumShopProduct");product.Kind=kind;product.Target=target;
        product.Recipe=-1;product.Tier=1;product.Size=CaelumConstants.EQUIPMENT_SIZE_M;product.NextDue=-1;
        vendor.Products.Push(product);return product;
    }
    bool Matches(Inventory item)
    {
        if(Kind==SIMPLE)return item.GetClassName()==NativeClass;
        if(Kind==BOOK)
        {let book=CaelumRecipeOffer(item);return book!=null && book.Recipe==Recipe && book.Tier==Tier;}
        if(Kind==LOCK)
        {
            let lock=CaelumLockItem(item);
            return lock!=null && lock.LockItemType==ItemType
                && (ItemType>=3 || CaelumCityTradeSession.Companion(lock)!=null);
        }
        if(Kind==MATERIAL)
        {let material=CaelumMaterialPickup(item);return material!=null && material.GetSpecialType()==ItemType && material.GetSpecialTier()==Tier;}
        let equipment=CaelumEquipmentItem(item);
        return equipment!=null && equipment.EquipmentKind==EquipmentKind && equipment.ItemType==ItemType
            && equipment.Tier==Tier && equipment.EquipmentSize==Size
            && (EquipmentKind!=CaelumConstants.EQUIPMENT_KIND_ARMOR || equipment.ArmorSlot==Slot)
            && (EquipmentKind!=CaelumConstants.EQUIPMENT_KIND_WEAPON || equipment.EssenceType==Essence);
    }
    void FindStock(CaelumCityMerchant vendor)
    {
        if(Stock!=null && Stock.Owner==vendor)return;
        Stock=null;
        for(Inventory item=vendor.Inv;item!=null;item=item.Inv)
            if(Matches(item)){Stock=item;return;}
    }
    int FindRecipe()
    {
        if(Kind==BOOK)return Recipe;
        if(Kind==MATERIAL)return -1;
        if(Kind==LOCK)
        {for(int r=CaelumLockRules.FIRST_RECIPE;r<CaelumLockRules.FIRST_RECIPE+CaelumLockRules.RECIPE_COUNT;r++)if(CaelumLockRules.RecipeItem(r)==ItemType)return r;return -1;}
        if(Kind==SIMPLE)
        {
            if(NativeClass=='CaelumArrowAmmo')return CaelumConstants.CRAFTING_ARROW_RECIPE;
            if(NativeClass=='CaelumBoltAmmo')return CaelumConstants.CRAFTING_BOLT_RECIPE;
            if(NativeClass=='CaelumCarbineAmmo')return CaelumConstants.CRAFTING_CARBINE_CARTRIDGE_RECIPE;
            if(NativeClass=='CaelumShotgunAmmo')return CaelumConstants.CRAFTING_SHOTGUN_CARTRIDGE_RECIPE;
            return -1;
        }
        if(EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)return CaelumClothingData.FIRST_RECIPE+ItemType;
        for(int recipe=0;recipe<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;recipe++)
        {
            int kind=CaelumCraftingRules.GetUnifiedRecipeKind(recipe);
            if(EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
            {
                if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON)
                {
                    int catalogue=CaelumCraftingRules.GetStationRecipeWeapon(CaelumConstants.CRAFTING_STATION_WORKBENCH,CaelumCraftingRules.GetUnifiedPhysicalRecipeIndex(recipe));
                    if(CaelumCraftingRules.GetPlayableWeaponType(catalogue)==ItemType)return recipe;
                }
                if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON
                    && CaelumCraftingRules.GetUnifiedEssenceWeaponType(recipe)==ItemType && CaelumCraftingRules.GetUnifiedEssenceType(recipe)==Essence)return recipe;
            }
            if(EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR && kind==CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR
                && CaelumCraftingRules.GetUnifiedArmorType(recipe)==ItemType && CaelumCraftingRules.GetUnifiedArmorSlot(recipe)==Slot)return recipe;
            if(EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD && kind==CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD
                && CaelumCraftingRules.GetUnifiedShieldType(recipe)==ItemType)return recipe;
            if(EquipmentKind==CaelumConstants.EQUIPMENT_KIND_AMULET && kind==CaelumConstants.CRAFTING_RECIPE_KIND_AMULET
                && CaelumCraftingRules.GetUnifiedAmuletType(recipe)==ItemType)return recipe;
            if(EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL && kind==CaelumConstants.CRAFTING_RECIPE_KIND_SEAL
                && CaelumCraftingRules.GetUnifiedSealType(recipe)==ItemType)return recipe;
        }
        return -1;
    }
    bool Produce(CaelumCityMerchant vendor,CaelumPlayer user,int amount)
    {
        if(amount<=0)return false;
        if(Stock!=null && Stock.Owner==vendor)
        {Stock.Amount+=amount;return true;}
        Inventory item=null;
        if(Kind==EQUIPMENT)item=vendor.SeedEquipment(user,EquipmentKind,ItemType,Slot,Size,Essence);
        else if(Kind==BOOK)item=vendor.SeedBook(Recipe,Tier,BaseValue);
        else if(Kind==LOCK)item=vendor.SeedLock(ItemType);
        else if(Kind==SIMPLE)item=vendor.SeedSimple(NativeClass,amount);
        if(item==null)return false;
        item.Amount=amount;Stock=item;return true;
    }
}

class CaelumShopRestock : Object play
{

    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user,double now)
    {
        if(vendor.RestockRevision>=CaelumShopCatalogue.RESTOCK_REVISION)return;
        vendor.Products.Clear();vendor.EnumeratingStock=true;
        vendor.SeedShotgunAmmo(user);vendor.PopulateBaseStock(user);vendor.EnsureCatalogue(user);
        vendor.EnumeratingStock=false;vendor.RestockRevision=CaelumShopCatalogue.RESTOCK_REVISION;vendor.RestockLastSeen=now;
        vendor.RestockNextDue=-1;
        // Las tiendas anteriores empiezan ahora: nunca reciben producción
        // retroactiva por tiempo durante el cual no existía este contrato.
        for(int i=0;i<vendor.Products.Size();i++)
        {let product=vendor.Products[i];product.Recipe=product.FindRecipe();product.FindStock(vendor);}
    }
    static double Duration(CaelumShopProduct product,CaelumPlayer user)
    {
        if(product.Recipe<0)return 0;
        let quote=new("CaelumRecipeQuote");quote.Build(user,product.Recipe,product.Tier,
            product.Kind==CaelumShopProduct.BOOK ? CaelumConstants.EQUIPMENT_SIZE_XL : product.Size);
        double seconds=CaelumShopCatalogue.RESTOCK_INCLUDE_COMPONENTS ? quote.CompleteManufactureSeconds : quote.ManufactureSeconds;
        int divisor=product.Kind==CaelumShopProduct.SIMPLE ? quote.OutputUnits : 1;
        return seconds*TICRATE/Max(1,divisor);
    }
    static void Sync(CaelumCityMerchant vendor,CaelumPlayer user,bool changed=false)
    {
        if(vendor==null || !CaelumPlayerAuthority.CanMutate(user) || vendor.EnumeratingStock)return;
        double now=CaelumScheduleState.Now(user);if(now<0)return;
        if(vendor.RestockRevision<CaelumShopCatalogue.RESTOCK_REVISION){Ensure(vendor,user,now);changed=true;}
        if(!changed && (vendor.RestockNextDue<0 || now<vendor.RestockNextDue))return;
        double earliest=-1;
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let product=vendor.Products[i];if(product.Recipe<0)continue;
            product.FindStock(vendor);int owned=product.Stock==null ? 0 : Max(0,product.Stock.Amount);
            int missing=Max(0,product.Target-owned);
            if(missing==0){product.NextDue=-1;continue;}
            if(product.UnitTics<=0)product.UnitTics=Duration(product,user);
            if(product.UnitTics<=0)continue;
            if(product.NextDue<0)product.NextDue=now+product.UnitTics;
            if(now<vendor.RestockLastSeen)
                product.NextDue=now+Max(0.0,product.NextDue-vendor.RestockLastSeen);
            if(now>=product.NextDue)
            {
                int produced=int(Min(double(missing),1+Floor((now-product.NextDue)/product.UnitTics)));
                if(product.Produce(vendor,user,produced))
                {
                    product.NextDue+=produced*product.UnitTics;
                    if(produced==missing)product.NextDue=-1;
                }
            }
            if(product.NextDue>=0 && (earliest<0 || product.NextDue<earliest))earliest=product.NextDue;
        }
        vendor.RestockLastSeen=now;vendor.RestockNextDue=earliest;
    }
    static void UpdateActive(CaelumPlayer user)
    {
        if(user.CityTrade==null || !user.PalomoMerchantMenuOpen || !user.IsActivePalomoMerchantSessionValid())return;
        let vendor=user.CityTrade.Vendor;if(vendor==null || vendor.RestockNextDue<0)return;
        double now=CaelumScheduleState.Now(user);if(now<vendor.RestockNextDue)return;
        Sync(vendor,user);user.CityTrade.Refresh(user);
    }
}
