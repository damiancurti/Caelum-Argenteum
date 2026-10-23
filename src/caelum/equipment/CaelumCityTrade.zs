// Comercio de la ciudad: el vendedor es dueño del inventario y de su caja.
// La sesión sólo proyecta filas; nunca usa los stocks personales de Palomo.
class CaelumCityMerchant : Actor
{
    int ShopIdentity, Category, Revision, WalletCopper;
    int CatalogueRevision,CatalogueCursor;
    int LandImportRevision,LandImportCursor;
    int MarineCatalogueRevision;
    int SupportCatalogueRevision;
    bool StockInitialized;
    int RestockRevision;
    bool EnumeratingStock;
    double RestockLastSeen,RestockNextDue;
    Array<CaelumShopProduct> Products;
    // Capacidad explícita para #383; ningún comercio actual se convierte aquí.
    bool TradesClothing;

    static CaelumCityMerchant Find(int identity)
    {
        let it=ThinkerIterator.Create("CaelumCityMerchant");CaelumCityMerchant vendor;
        while((vendor=CaelumCityMerchant(it.Next()))!=null)
            if(vendor.ShopIdentity==identity)return vendor;
        return null;
    }

    static bool Prepare()
    {
        for(int i=0;i<CaelumCityData.SHOP_COUNT;i++)
        {
            let vendor=Find(i);
            if(vendor==null)
            {
                vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",CaelumCityData.ShopPosition(i),NO_REPLACE));
                if(vendor==null)return false;
                vendor.ShopIdentity=i;vendor.WalletCopper=CaelumCityData.MERCHANT_COPPER;vendor.Revision=1;
            }
            vendor.Category=CaelumShopCatalogue.Category(i);
            vendor.TradesClothing=vendor.Category==CaelumShopCatalogue.CLOTHING;
        }
        CaelumShopSign.RefreshAuthored();
        return true;
    }

    static void MigrateCatalogue()
    {
        // Una sola pasada tipada de los 64 comercios al actualizar este mapa.
        // Conserva dueño, dinero, mercancía vendida y agotamientos; no crea stock.
        let it=ThinkerIterator.Create("CaelumCityMerchant");CaelumCityMerchant vendor;
        while((vendor=CaelumCityMerchant(it.Next()))!=null)
            if(vendor.ShopIdentity>=0 && vendor.ShopIdentity<CaelumCityData.SHOP_COUNT)
            {
                vendor.Category=CaelumShopCatalogue.Category(vendor.ShopIdentity);
                vendor.TradesClothing=vendor.Category==CaelumShopCatalogue.CLOTHING;
            }
        CaelumShopSign.RefreshAuthored();
    }

    bool Accepts(Inventory item)
    {
        if(item==null)return false;
        let special=CaelumSpecialInventoryItem(item);if(special!=null && special.LimboQuestUnits>0)return false;
        let protectedEquipment=CaelumEquipmentItem(item);if(protectedEquipment!=null && protectedEquipment.ItemFlags!=0)return false;
        let lock=CaelumLockItem(item);
        if(lock!=null && lock.MerchantPairedSale && lock.LockItemType>=3 && lock.LockItemType<6)return false;
        // La conversión aprobada conserva la mercancía previa, incluso agotada
        // parcialmente. Nunca se vacía un inventario para imponer el rubro nuevo.
        if(item.Owner==self)return CaelumEconomyRules.GetInventoryUnitBaseValue(item)>0;
        if(item is "CaelumRecipeOffer")return false;
        if(lock!=null)return Category==1;
        let material=CaelumMaterialPickup(item);
        if(material!=null && CaelumLandImports.Accepts(Category,material.GetSpecialType())) return true;
        if(material!=null && Category==CaelumMarineData.IMPORT_CATEGORY
            && material.GetSpecialType()==CaelumConstants.MATERIAL_DRIED_KELP)return true;
        if(material!=null)return Category==2 && (material.GetSpecialType()==CaelumConstants.MATERIAL_CARBINE_KIT
            || material.GetSpecialType()==CaelumConstants.MATERIAL_SHOTGUN_KIT);
        let equipment=CaelumEquipmentItem(item);
        if(equipment!=null)
        {
            if(equipment.Tier!=CaelumCityData.SHOP_TIER || equipment.ItemFlags!=0)return false;
            int kind=equipment.EquipmentKind,type=equipment.ItemType;
            if(kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)return TradesClothing;
            if(kind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
                return Category==WeaponCategory(type);
            if(kind==CaelumConstants.EQUIPMENT_KIND_ARMOR)
                return Category==(type==CaelumConstants.ARMOR_TYPE_MAGIC ? 5 : 4);
            if(kind==CaelumConstants.EQUIPMENT_KIND_SHIELD)return Category==(type==CaelumConstants.SHIELD_TYPE_MAGIC ? 5 : 4);
            return Category==3 && (kind==CaelumConstants.EQUIPMENT_KIND_AMULET || kind==CaelumConstants.EQUIPMENT_KIND_SEAL);
        }
        let consumable=CaelumConsumableItem(item);
        if(consumable!=null)return Category==0 && CaelumPotionRules.Family(consumable.GetConsumableType())<=CaelumConstants.CONSUMABLE_WATER_RATION;
        let ammo=CaelumCarbineAmmo(item);
        if(item is "CaelumArrowAmmo" || item is "CaelumBoltAmmo")return Category==2;
        return Category==2 && ammo!=null && (ammo.GetAmmoType()<=CaelumConstants.AMMUNITION_BOLT || ammo.GetAmmoType()==CaelumConstants.AMMUNITION_SHOTGUN);
    }

    static int WeaponCategory(int type)
    {
        if(CaelumEconomyRules.IsEssenceWeaponType(type))return 5;
        if(type==CaelumConstants.WEAPON_TYPE_CARBINE || type==CaelumConstants.WEAPON_TYPE_SHOTGUN
            || type==CaelumConstants.WEAPON_TYPE_LONGBOW || type==CaelumConstants.WEAPON_TYPE_CROSSBOW)return 2;
        return 1;
    }

    CaelumEquipmentItem SeedEquipment(CaelumPlayer user,int kind,int type,int slot,int size,int essence)
    {
        if(kind==CaelumConstants.EQUIPMENT_KIND_WEAPON && !CaelumSupportImplementData.ValidEssence(type,essence))return null;
        if(EnumeratingStock)
        {
            let product=CaelumShopProduct.Add(self,CaelumShopProduct.EQUIPMENT,CaelumCityData.EQUIPMENT_STOCK);
            product.EquipmentKind=kind;product.ItemType=type;product.Slot=slot;product.Size=size;
            product.Essence=essence;product.Tier=CaelumCityData.SHOP_TIER;return null;
        }
        Name itemClass=kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING ? 'CaelumClothingPickup'
            : kind==CaelumConstants.EQUIPMENT_KIND_WEAPON ? 'CaelumWeaponPickup'
            : kind==CaelumConstants.EQUIPMENT_KIND_ARMOR ? 'CaelumArmorPickup'
            : kind==CaelumConstants.EQUIPMENT_KIND_SHIELD ? 'CaelumShieldPickup'
            : kind==CaelumConstants.EQUIPMENT_KIND_AMULET ? 'CaelumAmuletPickup' : 'CaelumSealPickup';
        let item=CaelumEquipmentItem(Actor.Spawn(itemClass,Pos,NO_REPLACE));
        if(item==null)return null;
        item.EquipmentKind=kind;item.ItemType=type;item.ArmorSlot=slot;
        item.Tier=CaelumCityData.SHOP_TIER;item.EquipmentSize=size;item.EssenceType=essence;
        item.PickupDataInitialized=true;item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        item.bDropped=false;
        item.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
        item.UnitWeight=item.PreviewUnitWeight(user);item.Durability=item.PreviewMaximumDurability(user);
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.ShotgunRevision=CaelumShotgunRules.REVISION;
        item.Amount=CaelumCityData.EQUIPMENT_STOCK;item.AttachToOwner(self);
        return item;
    }

    Inventory SeedSimple(Name itemClass,int amount)
    {
        if(EnumeratingStock)
        {let product=CaelumShopProduct.Add(self,CaelumShopProduct.SIMPLE,amount);product.NativeClass=itemClass;return null;}
        let item=Inventory(Actor.Spawn(itemClass,Pos,NO_REPLACE));
        if(item!=null){item.Amount=amount;item.AttachToOwner(self);}return item;
    }
    CaelumRecipeOffer SeedBook(int recipe,int tier,double value)
    {
        if(CaelumSupportImplementData.RetiredRecipe(recipe))return null;
        if(EnumeratingStock)
        {
            let product=CaelumShopProduct.Add(self,CaelumShopProduct.BOOK,CaelumShopCatalogue.BOOK_STOCK);
            product.Recipe=recipe;product.Tier=tier;product.BaseValue=value;return null;
        }
        let offer=CaelumRecipeOffer(Actor.Spawn("CaelumRecipeOffer",Pos,NO_REPLACE));if(offer==null)return null;
        offer.Recipe=recipe;offer.Tier=tier;offer.BaseValue=value;
        offer.Amount=CaelumShopCatalogue.BOOK_STOCK;offer.AttachToOwner(self);return offer;
    }
    CaelumLockItem SeedLock(int type)
    {
        if(EnumeratingStock)
        {
            let product=CaelumShopProduct.Add(self,CaelumShopProduct.LOCK,CaelumCityData.EQUIPMENT_STOCK);
            product.ItemType=type;product.Tier=type<3?type+1:1;return null;
        }
        let pair=type<3 ? new("CaelumLockIdentity") : null;
        let item=CaelumLockRules.Create(type,Pos,pair);if(item==null)return null;
        CaelumLockItem key=type<3 ? CaelumLockRules.Create(type+3,Pos,pair) : null;
        if(type<3 && key==null){item.Destroy();return null;}
        item.MerchantPairedSale=type<3;item.AttachToOwner(self);
        if(key!=null){key.MerchantPairedSale=true;key.AttachToOwner(self);}return item;
    }
    void SeedShotgunAmmo(CaelumPlayer user)
    {
        if(Revision>=2 && !EnumeratingStock)return;
        if(Category==2)SeedSimple('CaelumShotgunAmmo',CaelumCityData.AMMUNITION_STOCK);
        if(!EnumeratingStock)Revision=2;
    }

    void EnsureStock(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        SeedShotgunAmmo(user);
        if(!StockInitialized)
        {
            // Sólo materializar al abrir: la ciudad conserva sus tiendas vagas.
            StockInitialized=true;PopulateBaseStock(user);
        }
        EnsureCatalogue(user);CaelumShopRestock.Sync(self,user);
        CaelumLandImports.Ensure(self,user);
        CaelumMarineImports.Ensure(self,user);
        CaelumSupportCatalogue.Ensure(self,user);
    }
    void PopulateBaseStock(CaelumPlayer user)
    {
        if(Category==0)
            for(int type=0;type<=CaelumConstants.CONSUMABLE_WATER_RATION;type++)
            {
                SeedSimple(user.GetConsumableClassName(type),CaelumCityData.CONSUMABLE_STOCK);
            }
        if(Category==2)
            for(int type=0;type<=CaelumConstants.AMMUNITION_BOLT;type++)
            {
                SeedSimple(user.GetAmmunitionClassName(type),CaelumCityData.AMMUNITION_STOCK);
            }
        for(int type=0;type<CaelumConstants.WEAPON_TYPE_COUNT;type++)
            if(Category==WeaponCategory(type))
                for(int size=0;size<CaelumConstants.EQUIPMENT_SIZE_COUNT;size++)
                    for(int essence=0;essence<(Category==5 ? CaelumConstants.ESSENCE_TYPE_COUNT : 1);essence++)
                        SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,type,0,size,essence);
        if(Category==4 || Category==5)
            for(int type=0;type<CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;type++)
                if((type==CaelumConstants.ARMOR_TYPE_MAGIC)==(Category==5))
                    for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
                        for(int size=0;size<CaelumConstants.EQUIPMENT_SIZE_COUNT;size++)
                            SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_ARMOR,type,slot,size,0);
        if(Category==4 || Category==5)
            for(int type=0;type<CaelumConstants.SHIELD_TYPE_COUNT;type++)
                if((type==CaelumConstants.SHIELD_TYPE_MAGIC)==(Category==5))
                    for(int size=0;size<CaelumConstants.EQUIPMENT_SIZE_COUNT;size++)
                        SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_SHIELD,type,0,size,0);
        if(Category==3)
        {
            for(int type=0;type<CaelumConstants.AMULET_TYPE_COUNT;type++)
                SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_AMULET,type,0,CaelumConstants.EQUIPMENT_SIZE_M,0);
            for(int type=0;type<CaelumConstants.SEAL_TYPE_COUNT;type++)
                SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_SEAL,type,0,CaelumConstants.EQUIPMENT_SIZE_M,0);
        }
    }

    void EnsureCatalogue(CaelumPlayer user)
    {
        if(CatalogueRevision>=CaelumShopCatalogue.REVISION && !EnumeratingStock)return;
        if(Category==CaelumShopCatalogue.CLOTHING)
            for(int type=0;type<CaelumClothingData.COUNT;type++)
                for(int size=0;size<CaelumConstants.EQUIPMENT_SIZE_COUNT;size++)
                {
                    int entry=type*CaelumConstants.EQUIPMENT_SIZE_COUNT+size;if(entry<CatalogueCursor && !EnumeratingStock)continue;
                    if(SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_CLOTHING,type,CaelumClothingData.Region(type),size,0)==null && !EnumeratingStock)return;
                    if(!EnumeratingStock)CatalogueCursor=entry+1;
                }
        if(Category==CaelumShopCatalogue.LIBRARY)
            for(int recipe=0;recipe<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;recipe++)
                for(int tier=1;tier<=CaelumRecipeLearning.TIERS;tier++)
                {
                    int entry=recipe*CaelumRecipeLearning.TIERS+tier-1;if(entry<CatalogueCursor && !EnumeratingStock)continue;
                    if(CaelumRecipeLearning.Tier(recipe,tier)!=tier || CaelumSupportImplementData.RetiredRecipe(recipe))continue;
                    double value=CaelumLibrary.BookValue(user,recipe,tier);if(value<=0)continue;
                    if(SeedBook(recipe,tier,value)==null && !EnumeratingStock)return;
                    if(!EnumeratingStock)CatalogueCursor=entry+1;
                }
        if(Category==2)
            for(int n=0;n<2;n++)
            {
                if(n<CatalogueCursor && !EnumeratingStock)continue;
                if(EnumeratingStock)
                {
                    let product=CaelumShopProduct.Add(self,CaelumShopProduct.MATERIAL,CaelumCityData.AMMUNITION_STOCK);
                    product.ItemType=n==0 ? CaelumConstants.MATERIAL_CARBINE_KIT : CaelumConstants.MATERIAL_SHOTGUN_KIT;
                }
                else
                {
                    let kit=user.CreateDetachedMaterialStack(n==0 ? CaelumConstants.MATERIAL_CARBINE_KIT
                        : CaelumConstants.MATERIAL_SHOTGUN_KIT,1,CaelumCityData.AMMUNITION_STOCK);
                    if(kit==null)return;kit.AttachToOwner(self);CatalogueCursor=n+1;
                }
            }
        if(Category==1)
            for(int type=0;type<CaelumLockRules.MASTER+1;type++)
            {
                if(type<CatalogueCursor && !EnumeratingStock)continue;
                if(type>=3 && type<6)continue;
                if(SeedLock(type)==null && !EnumeratingStock)return;
                if(!EnumeratingStock)CatalogueCursor=type+1;
            }
        if(Category==0)
            for(int type=CaelumConstants.CONSUMABLE_LIFE_MEDIUM;type<CaelumConstants.CONSUMABLE_TYPE_COUNT;type++)
            {
                if(type<CatalogueCursor && !EnumeratingStock)continue;
                if(SeedSimple(user.GetConsumableClassName(type),CaelumCityData.CONSUMABLE_STOCK)==null && !EnumeratingStock)return;
                if(!EnumeratingStock)CatalogueCursor=type+1;
            }
        if(!EnumeratingStock)CatalogueRevision=CaelumShopCatalogue.REVISION;
    }

    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(user==null || user.health<=0 || !CaelumUseGeometry.AimedAt(user,self))return false;
        if((user.player.cmd.buttons&BT_USE)==0 || user.FolkloreInteractionUseLatched)return true;
        user.FolkloreInteractionUseLatched=true;user.FolkloreInteractionReleaseGuardTics=0;
        CaelumPoiKnowledge.RecordUse(user,self,CaelumPoiData.MERCHANT);
        CaelumCityTradeSession.Open(user,self);return true;
    }

    Default
    {
        Radius 16; Height 57.6; Health 100; Scale 0.409091;
        +SOLID +USESPECIAL +INVULNERABLE +NOTARGET
        Tag "$CA_CITY_SHOPKEEPER";
    }
    States { Spawn: DOID A -1; Stop; }
}

class CaelumCityTradeSession : Object play
{
    CaelumCityMerchant Vendor;
    Array<Inventory> Rows;
    Array<String> Names;
    Array<int> Quantities, Prices;
    int Selection,CategoryFilter;
    bool Selling;

    static void Open(CaelumPlayer user,CaelumCityMerchant vendor)
    {
        CaelumMerchantCoordinator.OpenCityTrade(user, vendor);
    }

    static bool Boxed(Inventory item)
    {
        let special=CaelumSpecialInventoryItem(item);if(special!=null)return special.InMagicBox;
        let eq=CaelumEquipmentItem(item);if(eq!=null)return eq.InMagicBox;
        let food=CaelumConsumableItem(item);if(food!=null)return food.InMagicBox;
        let ammo=CaelumCarbineAmmo(item);return ammo!=null && ammo.InMagicBox;
    }
    static void SetBoxed(Inventory item,bool value)
    {
        let special=CaelumSpecialInventoryItem(item);if(special!=null)special.InMagicBox=value;
        let eq=CaelumEquipmentItem(item);if(eq!=null)eq.InMagicBox=value;
        let food=CaelumConsumableItem(item);if(food!=null)food.InMagicBox=value;
        let ammo=CaelumCarbineAmmo(item);if(ammo!=null)ammo.InMagicBox=value;
    }
    static bool Sellable(CaelumPlayer user,Inventory item)
    {
        if(CaelumWaterBoiling.Locked(item))return false;
        let special=CaelumSpecialInventoryItem(item);
        if(special!=null && special.LimboQuestUnits>0)return false;
        let material=CaelumMaterialPickup(item);
        if(material!=null && user.GetReservedCraftingMaterialUnits(material.GetSpecialType(),material.GetSpecialTier())>0)return false;
        let eq=CaelumEquipmentItem(item);
        return eq==null || (!eq.Equipped && eq.ItemFlags==0 && !user.IsEquipmentItemCraftingLocked(eq.ItemId));
    }
    static Inventory Stack(Actor owner,Inventory item)
    {
        if(item is "CaelumEquipmentItem" || item is "CaelumLockItem" || item is "CaelumRecipeOffer")return null;
        for(Inventory current=owner.Inv;current!=null;current=current.Inv)
        {
            if(current.GetClass()!=item.GetClass())continue;
            let special=CaelumSpecialInventoryItem(item);let match=CaelumSpecialInventoryItem(current);
            if(special!=null && (special.GetSpecialType()!=match.GetSpecialType() || special.GetSpecialTier()!=match.GetSpecialTier()))continue;
            return current;
        }
        return null;
    }
    static CaelumLockItem Companion(Inventory item)
    {
        let lock=CaelumLockItem(item);
        if(lock==null || !lock.MerchantPairedSale || lock.LockItemType>=3 || lock.Owner==null)return null;
        for(Inventory current=lock.Owner.Inv;current!=null;current=current.Inv)
        {
            let key=CaelumLockItem(current);
            if(key!=null && key.Amount==1 && key.MerchantPairedSale && key.LockItemType==lock.LockItemType+3
                && CaelumLockRules.SamePair(lock.PairIdentity,key.PairIdentity))return key;
        }
        return null;
    }
    static double Value(Inventory item)
    {let key=Companion(item);return CaelumEconomyRules.GetInventoryUnitBaseValue(item)+(key==null?0:CaelumEconomyRules.GetInventoryUnitBaseValue(key));}
    static bool Single(Inventory item)
    {return item is "CaelumEquipmentItem" || item is "CaelumLockItem" || item is "CaelumRecipeOffer";}
    void Refresh(CaelumPlayer user)
    {
        CaelumMerchantCoordinator.RefreshCityTrade(self, user);
    }
    void Cycle(CaelumPlayer user,int direction)
    {
        CaelumMerchantCoordinator.CycleCityTrade(self, user, direction);
    }

    bool Capacity(CaelumPlayer user,Inventory item,int quantity,int price,Inventory receiving)
    {
        return CaelumMerchantCoordinator.CapacityCityTrade(self, user, item, quantity, price, receiving);
    }

    void Execute(CaelumPlayer user)
    {
        CaelumMerchantCoordinator.ExecuteCityTrade(self, user);
    }
}
