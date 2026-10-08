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
        return Category==2 && ammo!=null && ammo.GetAmmoType()<=CaelumConstants.AMMUNITION_BOLT;
    }

    static int WeaponCategory(int type)
    {
        if(CaelumEconomyRules.IsEssenceWeaponType(type))return 5;
        if(type==CaelumConstants.WEAPON_TYPE_CARBINE || type==CaelumConstants.WEAPON_TYPE_STANDARD_BOW
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
        item.Amount=CaelumCityData.EQUIPMENT_STOCK;item.AttachToOwner(self);
    }

    void EnsureStock(CaelumPlayer user)
    {
        if(StockInitialized || !CaelumPlayerAuthority.CanMutate(user))return;
        // Sólo materializar al abrir: 64 tiendas vacías de compradores no
        // necesitan miles de actores de inventario en cada tic de asedio.
        StockInitialized=true;
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
        if(!CaelumPlayerAuthority.CanMutate(user) || user.CreationWizardOpen || !user.MagicBoxOwned)return;
        if(user.StaffCastPending)user.CancelPendingStaffCast(false);
        user.EquipmentMenuOpen=false;user.CloseCraftingStationSession();user.SetCraftingJournalState(false);
        user.ClosePalomoMerchant();
        vendor.EnsureStock(user);
        let session=new("CaelumCityTradeSession");session.Vendor=vendor;user.CityTrade=session;
        user.ActivePalomoMerchant=vendor;user.PalomoMerchantTitleKey=String.Format("CA_CITY_SHOP_%d",vendor.Category);
        user.PalomoMerchantMenuOpen=true;user.PalomoMerchantSelection=0;
        user.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        user.PalomoMerchantDiscountGranted=false;user.PalomoMerchantReputationDiscount=false;
        user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        session.Refresh(user);
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
        if(!CaelumPlayerAuthority.CanMutate(user) || Vendor==null)return;
        Selling=user.PalomoMerchantMode==CaelumConstants.PALOMO_MERCHANT_MODE_SELL;
        Inventory selected=Selection<Rows.Size() ? Rows[Selection] : null;
        Rows.Clear();Names.Clear();Quantities.Clear();Prices.Clear();
        Actor owner=Selling ? Actor(user) : Actor(Vendor);
        for(Inventory item=owner.Inv;item!=null;item=item.Inv)
        {
            if(item.Amount<=0 || !Vendor.Accepts(item) || (Selling && !Sellable(user,item)))continue;
            double value=CaelumEconomyRules.GetInventoryUnitBaseValue(item);
            if(value<=0)continue;
            int price=Selling ? CaelumEconomyRules.GetPricePaidByMerchant(value) : CaelumEconomyRules.GetPriceChargedByMerchant(value);
            Rows.Push(item);Names.Push(CaelumNotifications.Describe(user,item,0));Quantities.Push(item.Amount);Prices.Push(price);
            if(item==selected)Selection=Rows.Size()-1;
        }
        Selection=Clamp(Selection,0,Max(0,Rows.Size()-1));
        user.PalomoMerchantVisibleItemCount=Rows.Size();
        user.PalomoMerchantWalletCopper=Vendor.WalletCopper;
        int quantity=user.GetPalomoMerchantQuantityForIndex(user.PalomoMerchantQuantityIndex);
        if(Rows.Size()>0 && Rows[Selection] is "CaelumEquipmentItem")quantity=1;
        user.PalomoMerchantSelectedQuantity=quantity;
        user.PalomoMerchantSelectedLotPrice=0;
        if(Rows.Size()>0)
        {
            double value=CaelumEconomyRules.GetInventoryUnitBaseValue(Rows[Selection]);
            user.PalomoMerchantSelectedLotPrice=Selling ? CaelumEconomyRules.GetPricePaidByMerchant(value,quantity)
                : CaelumEconomyRules.GetPriceChargedByMerchant(value,quantity);
        }
        user.RefreshCarriedInventorySummary();
    }
    void Cycle(CaelumPlayer user,int direction)
    {
        Refresh(user);if(Rows.Size()==0)return;
        Selection=(Selection+(direction<0 ? Rows.Size()-1 : 1))%Rows.Size();
        user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;Refresh(user);
    }

    bool Capacity(CaelumPlayer user,Inventory item,int quantity,int price,Inventory receiving)
    {
        double unit=user.GetFormalInventoryEntryWeight(item)/Max(1,item.Amount);
        bool oldBox=Boxed(Selling ? item : receiving);
        for(int moneyRoute=0;moneyRoute<2;moneyRoute++)
        {
            if(!(Selling ? user.BuildPalomoCurrencyCreditPlan(price) : user.BuildPalomoCurrencyPaymentPlan(price)))return false;
            if(moneyRoute==1){if(!user.MagicBoxOwned)continue;user.RoutePalomoCurrencyGainsToMagicBox();}
            bool canBox=item is "CaelumEquipmentItem" || item is "CaelumConsumableItem" || item is "CaelumCarbineAmmo";
            for(int productRoute=0;productRoute<(Selling || !canBox ? 1 : 2);productRoute++)
            {
                bool box=oldBox || productRoute==1;
                if(box && !user.MagicBoxOwned)continue;
                double personal=user.GetPalomoCurrencyPlanPersonalWeightDelta(),raw=user.GetPalomoCurrencyPlanBoxRawWeightDelta();
                int slots=user.GetPalomoCurrencyPlanBoxSlotDelta();
                double weight=quantity*unit;
                if(Selling)
                {
                    if(oldBox){raw-=weight;if(quantity==item.Amount)slots--;}
                    else personal-=weight;
                }
                else if(box)
                {
                    raw+=weight;
                    if(!oldBox)
                    {
                        slots++;
                        if(receiving!=null){double moved=receiving.Amount*unit;personal-=moved;raw+=moved;}
                    }
                }
                else personal+=weight;
                if(user.PalomoTransactionCapacityFits(personal,raw,slots))
                {user.PalomoIncomingItemInMagicBox=box;return true;}
            }
        }
        return false;
    }

    void Execute(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !user.IsActivePalomoMerchantSessionValid())return;
        if(Selection>=Rows.Size())return;
        Inventory item=Rows[Selection];int quote=user.PalomoMerchantSelectedLotPrice;
        Refresh(user);
        if(Selection>=Rows.Size() || Rows[Selection]!=item || quote!=user.PalomoMerchantSelectedLotPrice)
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED;return;}
        int quantity=user.PalomoMerchantSelectedQuantity,price=user.PalomoMerchantSelectedLotPrice;
        if(item==null || item.Amount<quantity)
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_STOCK;return;}
        if((Selling && Vendor.WalletCopper<price) || (!Selling && user.GetOwnedMoneyCopperValue()<price))
        {user.LastPalomoMerchantAction=Selling ? CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_MERCHANT_MONEY
            : CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_MONEY;return;}
        if(!Selling && Vendor.WalletCopper>2147483647-price)return;
        Actor receiver=Selling ? Actor(Vendor) : Actor(user);
        Inventory receiving=Stack(receiver,item);
        if(receiving!=null && receiving.Amount>receiving.MaxAmount-quantity)
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;return;}
        if(!Capacity(user,item,quantity,price,receiving))
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;return;}
        // Reservar todas las instancias antes de cambiar un solo saldo.
        Inventory split=null;
        if(receiving==null && quantity<item.Amount)
        {
            split=Inventory(Actor.Spawn(item.GetClass(),user.Pos,NO_REPLACE));
            if(split==null)return;
        }
        Array<CaelumCurrencyItem> coins;
        bool ready=true;
        for(int c=0;c<CaelumConstants.CURRENCY_TYPE_COUNT;c++)
        {
            CaelumCurrencyItem created=null;
            if(user.PalomoCurrencyPlanAmount[c]>0 && user.FindNativeCurrency(c)==null)
            {
                created=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(c),user.Pos,NO_REPLACE));
                if(created==null)ready=false;
            }
            coins.Push(created);
        }
        if(!ready)
        {
            if(split!=null)split.Destroy();
            for(int c=0;c<coins.Size();c++)if(coins[c]!=null)coins[c].Destroy();
            return;
        }
        for(int c=0;c<coins.Size();c++)if(coins[c]!=null){coins[c].Amount=0;coins[c].AttachToOwner(user);}
        user.ApplyPalomoCurrencyPlan();
        if(receiving!=null){receiving.Amount+=quantity;item.Amount-=quantity;if(item.Amount==0)item.Destroy();}
        else if(split!=null){split.Amount=quantity;item.Amount-=quantity;split.AttachToOwner(receiver);receiving=split;}
        else{item.Owner.RemoveInventory(item);item.AttachToOwner(receiver);receiving=item;}
        SetBoxed(receiving,!Selling && user.PalomoIncomingItemInMagicBox);
        let equipment=CaelumEquipmentItem(receiving);
        if(!Selling && equipment!=null)
        {equipment.AcquisitionResolved=true;user.EnsureEquipmentItemId(equipment);}
        Vendor.WalletCopper+=Selling ? -price : price;
        if(!Selling)CaelumNotifications.Acquired(user,receiving,quantity);
        user.LastPalomoMerchantAction=Selling ? CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD : CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT;
        user.OnNativeInventoryChanged();user.ApplyCharacterProfile();user.RefreshFormalInventorySnapshot();
        Refresh(user);user.PersistCharacterState();
        user.A_StartSound("caelum/ui/menu_select",CHAN_6,CHANF_LOCAL|CHANF_UI);
    }
}
