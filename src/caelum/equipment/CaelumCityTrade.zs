// Comercio de la ciudad: el vendedor es dueño del inventario y de su caja.
// La sesión sólo proyecta filas; nunca usa los stocks personales de Palomo.
class CaelumCityMerchant : Actor
{
    int ShopIdentity, Category, Revision, WalletCopper;
    bool StockInitialized;

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
            if(Find(i)!=null)continue;
            let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",CaelumCityData.ShopPosition(i),NO_REPLACE));
            if(vendor==null)return false;
            vendor.ShopIdentity=i;vendor.Category=i%CaelumCityData.SHOP_CATEGORIES;
            vendor.WalletCopper=CaelumCityData.MERCHANT_COPPER;vendor.Revision=1;
        }
        return true;
    }

    bool Accepts(Inventory item)
    {
        let equipment=CaelumEquipmentItem(item);
        if(equipment!=null)
        {
            if(equipment.Tier!=CaelumCityData.SHOP_TIER || equipment.ItemFlags!=0)return false;
            int kind=equipment.EquipmentKind,type=equipment.ItemType;
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

    void SeedEquipment(CaelumPlayer user,int kind,int type,int slot,int size,int essence)
    {
        Name itemClass=kind==CaelumConstants.EQUIPMENT_KIND_WEAPON ? 'CaelumWeaponPickup'
            : kind==CaelumConstants.EQUIPMENT_KIND_ARMOR ? 'CaelumArmorPickup'
            : kind==CaelumConstants.EQUIPMENT_KIND_SHIELD ? 'CaelumShieldPickup'
            : kind==CaelumConstants.EQUIPMENT_KIND_AMULET ? 'CaelumAmuletPickup' : 'CaelumSealPickup';
        let item=CaelumEquipmentItem(Actor.Spawn(itemClass,Pos,NO_REPLACE));
        if(item==null)return;
        item.EquipmentKind=kind;item.ItemType=type;item.ArmorSlot=slot;
        item.Tier=CaelumCityData.SHOP_TIER;item.EquipmentSize=size;item.EssenceType=essence;
        item.PickupDataInitialized=true;item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        item.bDropped=false;
        item.SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
        item.UnitWeight=item.PreviewUnitWeight(user);item.Durability=item.PreviewMaximumDurability(user);
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.ShotgunRevision=CaelumShotgunRules.REVISION;
        item.Amount=CaelumCityData.EQUIPMENT_STOCK;item.AttachToOwner(self);
    }

    void SeedShotgunAmmo(CaelumPlayer user)
    {
        if(Revision>=2)return;
        if(Category==2)
        {
            let item=Inventory(Actor.Spawn("CaelumShotgunAmmo",Pos,NO_REPLACE));
            if(item==null)return;
            item.Amount=CaelumCityData.AMMUNITION_STOCK;item.AttachToOwner(self);
        }
        Revision=2;
    }

    void EnsureStock(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        if(StockInitialized)
        {
            SeedShotgunAmmo(user);
            return;
        }
        // Sólo materializar al abrir: 64 tiendas vacías de compradores no
        // necesitan miles de actores de inventario en cada tic de asedio.
        StockInitialized=true;
        SeedShotgunAmmo(user);
        if(Category==0)
            for(int type=0;type<=CaelumConstants.CONSUMABLE_WATER_RATION;type++)
            {
                let item=Inventory(Actor.Spawn(user.GetConsumableClassName(type),Pos,NO_REPLACE));
                if(item!=null){item.Amount=CaelumCityData.CONSUMABLE_STOCK;item.AttachToOwner(self);}
            }
        if(Category==2)
            for(int type=0;type<=CaelumConstants.AMMUNITION_BOLT;type++)
            {
                let item=Inventory(Actor.Spawn(user.GetAmmunitionClassName(type),Pos,NO_REPLACE));
                if(item!=null){item.Amount=CaelumCityData.AMMUNITION_STOCK;item.AttachToOwner(self);}
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
    int Selection;
    bool Selling;

    static void Open(CaelumPlayer user,CaelumCityMerchant vendor)
    {
        CaelumMerchantCoordinator.OpenCityTrade(user, vendor);
    }

    static bool Boxed(Inventory item)
    {
        let eq=CaelumEquipmentItem(item);if(eq!=null)return eq.InMagicBox;
        let food=CaelumConsumableItem(item);if(food!=null)return food.InMagicBox;
        let ammo=CaelumCarbineAmmo(item);return ammo!=null && ammo.InMagicBox;
    }
    static void SetBoxed(Inventory item,bool value)
    {
        let eq=CaelumEquipmentItem(item);if(eq!=null)eq.InMagicBox=value;
        let food=CaelumConsumableItem(item);if(food!=null)food.InMagicBox=value;
        let ammo=CaelumCarbineAmmo(item);if(ammo!=null)ammo.InMagicBox=value;
    }
    static bool Sellable(CaelumPlayer user,Inventory item)
    {
        let eq=CaelumEquipmentItem(item);
        return eq==null || (!eq.Equipped && eq.ItemFlags==0 && !user.IsEquipmentItemCraftingLocked(eq.ItemId));
    }
    static Inventory Stack(Actor owner,Inventory item)
    {
        if(item is "CaelumEquipmentItem")return null;
        for(Inventory current=owner.Inv;current!=null;current=current.Inv)
            if(current.GetClass()==item.GetClass())return current;
        return null;
    }
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
