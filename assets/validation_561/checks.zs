// Fixtures aislados de #377; ninguna cifra de prueba pertenece al balance.
class CA377Checkpoint : Inventory
{
    CaelumCityMerchant Vendor;
    CaelumEquipmentItem Equipment;
    int Money, Wallet, Stock, ItemIdentity, Wear, Size, PalomoStock, PalomoWallet;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}

class CA377Checks : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok, String label)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA377 %s %s",ok ? "PASS" : "FAIL",label);
    }
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.ClosePalomoMerchant();u.CloseCraftingStationSession();
        u.CreationWizardOpen=false;u.GrantMagicBoxFromPalomo(false);
    }
    void Money(CaelumPlayer u, int type=5, int amount=1000)
    {
        for(int c=0;c<CaelumConstants.CURRENCY_TYPE_COUNT;c++)
        {
            let coin=u.FindNativeCurrency(c);if(coin!=null)coin.Destroy();
        }
        let coin=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(type),u.Pos,NO_REPLACE));
        coin.Amount=amount;coin.AttachToOwner(u);u.OnNativeInventoryChanged();
    }
    CaelumCityMerchant Vendor(CaelumPlayer u, int category)
    {
        let v=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",u.Pos+(48,0,0),NO_REPLACE));
        v.Category=category;v.StockInitialized=true;v.Revision=2;v.WalletCopper=200000;
        return v;
    }
    Inventory Food(CaelumPlayer u,Actor owner,int amount)
    {
        let i=Inventory(Actor.Spawn(u.GetConsumableClassName(CaelumConstants.CONSUMABLE_FOOD_RATION),u.Pos,NO_REPLACE));
        i.Amount=amount;i.AttachToOwner(owner);return i;
    }
    CaelumEquipmentItem Weapon(CaelumPlayer u,CaelumCityMerchant v)
    {
        v.SeedEquipment(u,CaelumConstants.EQUIPMENT_KIND_WEAPON,
            CaelumConstants.WEAPON_TYPE_LONGBOW,0,CaelumConstants.EQUIPMENT_SIZE_M,0);
        let item=CaelumEquipmentItem(v.Inv);item.Durability=17;
        v.RemoveInventory(item);item.AttachToOwner(u);u.EnsureEquipmentItemId(item);
        u.RemoveInventory(item);item.AttachToOwner(v);return item;
    }
    bool Select(CaelumPlayer u,Inventory item,int quantity=0,bool sell=false)
    {
        u.PalomoMerchantMode=sell ? CaelumConstants.PALOMO_MERCHANT_MODE_SELL : CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        u.PalomoMerchantQuantityIndex=quantity;u.CityTrade.Refresh(u);
        for(int i=0;i<u.CityTrade.Rows.Size();i++)
            if(u.CityTrade.Rows[i]==item)
            {u.CityTrade.Selection=i;u.CityTrade.Refresh(u);return true;}
        return false;
    }
    int Total(Actor owner,Name type)
    {
        int result=0;
        for(Inventory i=owner.Inv;i!=null;i=i.Inv)if(i.GetClassName()==type)result+=i.Amount;
        return result;
    }
    void City(CaelumPlayer u)
    {
        Money(u);
        let v=Vendor(u,0);let other=Vendor(u,0);let item=Food(u,v,20);Food(u,other,31);
        CaelumCityTradeSession.Open(u,v);Check(Select(u,item),"city stack row selected");
        int price=u.PalomoMerchantSelectedLotPrice,quantity=u.PalomoMerchantSelectedQuantity;
        int money=int(u.GetOwnedMoneyCopperValue()),wallet=v.WalletCopper,owned=Total(u,item.GetClassName());
        u.ExecutePalomoMerchantTransaction();
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT,"city buy succeeds");
        Check(int(u.GetOwnedMoneyCopperValue())==money-price && v.WalletCopper==wallet+price,"city exact denomination change");
        Check(item.Amount==20-quantity && Total(u,item.GetClassName())==owned+quantity,"city partial stack once");
        Check(Total(other,item.GetClassName())==31 && other.WalletCopper==200000,"other vendor isolated");
        let received=CaelumCityTradeSession.Stack(u,item);
        Check(Select(u,received,0,true),"sale row selected");
        price=u.PalomoMerchantSelectedLotPrice;money=int(u.GetOwnedMoneyCopperValue());wallet=v.WalletCopper;
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money+price && v.WalletCopper==wallet-price,"city sale exact credit");
        Check(item.Amount==20 && Total(u,item.GetClassName())==owned,"city stack returns");
        Select(u,item,1);
        Check(u.PalomoMerchantSelectedLotPrice==CaelumEconomyRules.GetPriceChargedByMerchant(
            CaelumEconomyRules.GetInventoryUnitBaseValue(item),u.PalomoMerchantSelectedQuantity),"lot rounding authoritative");
        money=int(u.GetOwnedMoneyCopperValue());wallet=v.WalletCopper;
        u.PalomoMerchantSelectedLotPrice++;
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && v.WalletCopper==wallet && item.Amount==20,"stale city quote no mutation");
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED,"stale city quote reported");
        Select(u,item);item.Owner.RemoveInventory(item);item.AttachToOwner(other);
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && item.Owner==other,"foreign item cannot be bought from old row");
        item.Owner.RemoveInventory(item);item.AttachToOwner(v);Select(u,item);
        Money(u,0,0);wallet=v.WalletCopper;
        u.ExecutePalomoMerchantTransaction();
        Check(item.Amount==20 && v.WalletCopper==wallet && u.GetOwnedMoneyCopperValue()==0,"missing money no mutation");
        Money(u);Select(u,item,1);int previous=item.Amount;item.Amount=1;
        money=int(u.GetOwnedMoneyCopperValue());u.ExecutePalomoMerchantTransaction();
        Check(item.Amount==1 && int(u.GetOwnedMoneyCopperValue())==money,"missing stock no mutation");
        item.Amount=previous;Select(u,item);v.WalletCopper=2147483647;
        u.ExecutePalomoMerchantTransaction();
        Check(item.Amount==20 && int(u.GetOwnedMoneyCopperValue())==money && v.WalletCopper==2147483647,"city wallet overflow rejects");
        v.WalletCopper=wallet;
        let old=u.CityTrade;CaelumCityTradeSession.Open(u,other);
        money=int(u.GetOwnedMoneyCopperValue());old.Execute(u);
        Check(int(u.GetOwnedMoneyCopperValue())==money && item.Amount==20 && u.CityTrade.Vendor==other,"foreign session cannot transact");
        // Restaurar sólo el fixture para que el fallo del paquete viejo no se propague.
        Money(u);money=int(u.GetOwnedMoneyCopperValue());item.Amount=20;
        u.ClosePalomoMerchant();old.Execute(u);
        Check(int(u.GetOwnedMoneyCopperValue())==money && item.Amount==20,"closed session cannot replay");
        CaelumCityTradeSession.Open(u,v);Select(u,item);u.ActivePalomoMerchant=null;
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && item.Amount==20,"lost active vendor cannot charge");
        CaelumCityTradeSession.Open(u,v);Select(u,item);
        v.SetOrigin(v.Pos+(1000,0,0),false);u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && item.Amount==20,"distance loss cannot charge");
        v.SetOrigin(u.Pos+(48,0,0),false);u.ClosePalomoMerchant();
    }
    void Equipment(CaelumPlayer u)
    {
        Money(u);
        let v=Vendor(u,2);let e=Weapon(u,v);let spare=Weapon(u,v);
        int id=e.ItemId,size=e.EquipmentSize,wear=e.Durability;
        CaelumCityTradeSession.Open(u,v);Select(u,e);
        int price=u.PalomoMerchantSelectedLotPrice,money=int(u.GetOwnedMoneyCopperValue());
        u.ExecutePalomoMerchantTransaction();
        Check(e.Owner==u && e.ItemId==id && e.Durability==wear && e.EquipmentSize==size,"exact equipment identity and state purchased");
        Check(spare.Owner==v && int(u.GetOwnedMoneyCopperValue())==money-price,"duplicate copy remains at vendor");
        Check(Select(u,e,0,true),"exact equipment sale selected");
        price=u.PalomoMerchantSelectedLotPrice;money=int(u.GetOwnedMoneyCopperValue());
        v.WalletCopper=0;u.ExecutePalomoMerchantTransaction();
        Check(e.Owner==u && int(u.GetOwnedMoneyCopperValue())==money,"empty merchant wallet rejects sale");
        v.WalletCopper=200000;
        e.Equipped=true;Check(!Select(u,e,0,true),"equipped equipment excluded");e.Equipped=false;
        e.ItemFlags=1;Check(!Select(u,e,0,true),"flagged equipment excluded");e.ItemFlags=0;
        u.CraftingTaskActive=true;u.CraftingTaskTargetItemId=e.ItemId;
        Check(!Select(u,e,0,true),"reserved equipment excluded");
        u.CraftingTaskActive=false;u.CraftingTaskTargetItemId=0;
        Select(u,e,0,true);u.ExecutePalomoMerchantTransaction();
        Check(e.Owner==v && e.ItemId==id && e.Durability==wear && e.EquipmentSize==size,"exact equipment sold intact");
        Check(int(u.GetOwnedMoneyCopperValue())==money+price,"equipment sale paid once");
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money+price && e.Owner==v,"repeated depleted equipment sale cannot pay twice");
        u.ClosePalomoMerchant();
    }
    void CapacityAndAuthority(CaelumPlayer u)
    {
        Money(u);
        let v=Vendor(u,0);let food=Food(u,v,20);
        CaelumCityTradeSession.Open(u,v);Select(u,food);
        int money=int(u.GetOwnedMoneyCopperValue()),wallet=v.WalletCopper;
        double carry=u.DerivedStats.CarryCapacity;
        int slots=u.DerivedStats.MagicBoxCapacity;
        u.DerivedStats.CarryCapacity=0;u.DerivedStats.MagicBoxCapacity=0;
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && v.WalletCopper==wallet && food.Amount==20,"city full Box and load reject atomically");
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY,"city capacity rejection reported");
        u.DerivedStats.CarryCapacity=carry;u.DerivedStats.MagicBoxCapacity=slots;
        let foreign=CaelumPlayer(Actor.Spawn("CaelumPlayer",u.Pos+(96,0,0),NO_REPLACE));
        CaelumCityTradeSession.Open(foreign,v);
        Check(foreign.CityTrade==null && int(u.GetOwnedMoneyCopperValue())==money,"foreign unbound pawn cannot open trade");
        foreign.Destroy();
        u.ClosePalomoMerchant();
        u.OpenPalomoMerchant(v);
        let p=u.GetPersistentCharacterState(true);p.PalomoMerchantStock[0]=100;
        u.PalomoMerchantSelection=0;u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        u.PalomoMerchantQuantityIndex=1;u.RefreshPalomoMerchantSnapshot();
        int owned=u.CountPalomoMerchantProduct(0,true);
        wallet=p.PalomoMerchantWalletCopper;
        u.DerivedStats.CarryCapacity=0;u.DerivedStats.MagicBoxCapacity=0;
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && p.PalomoMerchantWalletCopper==wallet
            && p.PalomoMerchantStock[0]==100 && u.CountPalomoMerchantProduct(0,true)==owned,"Palomo full Box and load reject atomically");
        u.DerivedStats.CarryCapacity=carry;u.DerivedStats.MagicBoxCapacity=slots;
        Money(u,0,0);u.RefreshPalomoMerchantSnapshot();u.ExecutePalomoMerchantTransaction();
        Check(p.PalomoMerchantStock[0]==100 && u.CountPalomoMerchantProduct(0,true)==owned
            && u.GetOwnedMoneyCopperValue()==0,"Palomo missing money rejects");
        Money(u);u.RefreshPalomoMerchantSnapshot();
        p.PalomoMerchantWalletCopper=2147483647;
        u.ExecutePalomoMerchantTransaction();
        Check(p.PalomoMerchantWalletCopper==2147483647 && u.CountPalomoMerchantProduct(0,true)>owned,"Palomo accepted wallet saturation preserved");
        u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;u.RefreshPalomoMerchantSnapshot();
        owned=u.CountPalomoMerchantProduct(0,true);money=int(u.GetOwnedMoneyCopperValue());
        p.PalomoMerchantWalletCopper=0;u.ExecutePalomoMerchantTransaction();
        Check(u.CountPalomoMerchantProduct(0,true)==owned && int(u.GetOwnedMoneyCopperValue())==money,"Palomo empty wallet no sale");
        u.ClosePalomoMerchant();
    }
    void Palomo(CaelumPlayer u)
    {
        Money(u);
        let v=Vendor(u,0);let p=u.GetPersistentCharacterState(true);
        p.EnsurePalomoMerchantInitialized();p.EnsurePalomoDiscountInitialized();
        p.PalomoDiscountGranted=false;p.PalomoMerchantWalletCopper=200000;
        for(int product=0;product<CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT;product++)
        {
            p.PalomoMerchantStock[product]=100;
            let old=u.FindPalomoMerchantProduct(product);if(old!=null)old.Destroy();
            u.OpenPalomoMerchant(v);u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
            u.PalomoMerchantSelection=product;u.PalomoMerchantQuantityIndex=1;u.RefreshPalomoMerchantSnapshot();
            int price=u.PalomoMerchantSelectedLotPrice,qty=u.PalomoMerchantSelectedQuantity;
            int money=int(u.GetOwnedMoneyCopperValue()),wallet=p.PalomoMerchantWalletCopper;
            u.ExecutePalomoMerchantTransaction();
            Check(u.CountPalomoMerchantProduct(product,true)==qty && p.PalomoMerchantStock[product]==100-qty,"Palomo new product allocated");
            Check(int(u.GetOwnedMoneyCopperValue())==money-price && p.PalomoMerchantWalletCopper==wallet+price,"Palomo purchase exact payment");
            u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;u.RefreshPalomoMerchantSnapshot();
            price=u.PalomoMerchantSelectedLotPrice;money=int(u.GetOwnedMoneyCopperValue());wallet=p.PalomoMerchantWalletCopper;
            u.ExecutePalomoMerchantTransaction();
            Check(u.CountPalomoMerchantProduct(product,true)==0 && p.PalomoMerchantStock[product]==100,"Palomo full stack sold");
            Check(int(u.GetOwnedMoneyCopperValue())==money+price && p.PalomoMerchantWalletCopper==wallet-price,"Palomo sale exact payment");
        }
        u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        u.PalomoMerchantSelection=0;u.PalomoMerchantQuantityIndex=1;u.RefreshPalomoMerchantSnapshot();
        int money=int(u.GetOwnedMoneyCopperValue()),stock=p.PalomoMerchantStock[0];
        p.PalomoDiscountGranted=true;u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && p.PalomoMerchantStock[0]==stock,"discount change invalidates quote");
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED,"discount refresh reported");
        u.RefreshPalomoMerchantSnapshot();p.PalomoMerchantStock[0]=0;u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && p.PalomoMerchantStock[0]==0,"Palomo empty stock no charge");
        p.PalomoMerchantStock[0]=stock;u.ClosePalomoMerchant();u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money,"Palomo closed session no replay");
        u.OpenPalomoMerchant(v);
        u.PalomoIncomingItemInMagicBox=false;
        u.AddPalomoMerchantProduct(3,5);u.AddPalomoMerchantProduct(4,5);
        u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;
        u.PalomoMerchantSelection=3;u.PalomoMerchantQuantityIndex=0;u.RefreshPalomoMerchantSnapshot();
        u.FindPalomoMerchantProduct(3).Destroy();
        money=int(u.GetOwnedMoneyCopperValue());
        int tin=u.CountPalomoMerchantProduct(4,true);
        u.ExecutePalomoMerchantTransaction();
        Check(int(u.GetOwnedMoneyCopperValue())==money && u.CountPalomoMerchantProduct(4,true)==tin,
            "Palomo stale row cannot sell equal-price alternative");
        CaelumCityTradeSession.Open(u,v);u.OpenPalomoMerchant(v);
        Check(u.CityTrade==null && u.PalomoMerchantMenuOpen,"city to Palomo clears projection");
        u.ClosePalomoMerchant();
    }
    void Save(CaelumPlayer u)
    {
        Prepare(u);Money(u);
        let v=Vendor(u,2);v.ShopIdentity=1000;
        Actor.Spawn("CaelumWorkbenchStation",u.Pos+(0,48,0),NO_REPLACE);
        let e=Weapon(u,v);
        let ammo=Inventory(Actor.Spawn("CaelumCarbineAmmo",u.Pos,NO_REPLACE));
        ammo.Amount=3;ammo.AttachToOwner(v);
        CaelumCityTradeSession.Open(u,v);Select(u,e);u.ExecutePalomoMerchantTransaction();
        Select(u,ammo);u.ExecutePalomoMerchantTransaction();
        let m=CA377Checkpoint(Actor.Spawn("CA377Checkpoint",u.Pos,NO_REPLACE));m.AttachToOwner(u);
        m.Vendor=v;m.Equipment=e;m.Money=int(u.GetOwnedMoneyCopperValue());
        m.Wallet=v.WalletCopper;m.Stock=ammo.Amount;m.ItemIdentity=e.ItemId;m.Wear=e.Durability;m.Size=e.EquipmentSize;
        let p=u.GetPersistentCharacterState(true);p.EnsurePalomoMerchantInitialized();
        m.PalomoStock=p.PalomoMerchantStock[0];m.PalomoWallet=p.PalomoMerchantWalletCopper;
        u.PersistCharacterState();
        Check(e.Owner==u && ammo.Amount==2,"saved fixture has depleted stock and bought equipment");
        Check(u.CityTrade!=null && u.PalomoMerchantMenuOpen,"save starts with open session");
        Console.Printf("CA377 PERSIST prepared passed=%d failed=%d",Passed,Failed);
    }
    void Verify(CaelumPlayer u,bool travel=false)
    {
        let m=CA377Checkpoint(u.FindInventory("CA377Checkpoint"));
        Check(m!=null,"checkpoint survives");if(m==null)return;
        Check(int(u.GetOwnedMoneyCopperValue())==m.Money,"saved money unchanged");
        Check(m.Equipment!=null && m.Equipment.Owner==u && m.Equipment.ItemId==m.ItemIdentity
            && m.Equipment.Durability==m.Wear && m.Equipment.EquipmentSize==m.Size,"saved exact equipment unchanged");
        let p=u.GetPersistentCharacterState(true);
        Check(p.PalomoMerchantStock[0]==m.PalomoStock && p.PalomoMerchantWalletCopper==m.PalomoWallet,"saved Palomo ledger unchanged");
        if(level.MapName=="TMAINT")
        {
            let v=CaelumCityMerchant.Find(1000);
            Check(v!=null,"saved merchant exists");if(v==null)return;
            Check(v.WalletCopper==m.Wallet && Total(v,'CaelumCarbineAmmo')==m.Stock,"saved stock and wallet unchanged");
            CaelumCityTradeSession.Open(u,v);
            Check(Total(v,'CaelumCarbineAmmo')==m.Stock,"reopen never reseeds depleted stock");
        }
        if(travel)u.ClosePalomoMerchant();
        Console.Printf("CA377 PERSIST passed=%d failed=%d map=%s",Passed,Failed,level.MapName);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca377_suite")
        {
            Prepare(u);City(u);Equipment(u);Palomo(u);CapacityAndAuthority(u);
            Console.Printf("CA377 RESULT passed=%d failed=%d",Passed,Failed);
        }
        if(e.Name=="ca377_save")Save(u);
        if(e.Name=="ca377_verify")Verify(u);
        if(e.Name=="ca377_travelcheck")Verify(u,true);
    }
}
