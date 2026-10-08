class CA133Trade : EventHandler
{
    int Checks,Failures;
    int PurchasedId;
    void Check(bool result,String label)
    {Checks++;if(!result)Failures++;Console.Printf("CA133 %s %s",result ? "PASS" : "FAIL",label);}
    int Count(Actor vendor){int n=0;for(Inventory p=vendor.Inv;p!=null;p=p.Inv)n++;return n;}
    int Food(CaelumPlayer user){let item=user.FindNativeConsumableItem(CaelumConstants.CONSUMABLE_FOOD_RATION);return item==null ? 0 : item.Amount;}
    void Select(CaelumPlayer user,Inventory item)
    {
        let s=user.CityTrade;s.Refresh(user);
        for(int i=0;i<s.Rows.Size();i++)if(s.Rows[i]==item){s.Selection=i;s.Refresh(user);return;}
        Check(false,"requested item present in transaction rows");
    }
    override void WorldTick()
    {
        if(level.MapName!="MAP06")return;
        if(level.time==85)
        {
            let u=CaelumPlayer(players[0].mo);let item=u.FindNativeEquipmentItemById(PurchasedId);
            Check(item!=null && item is "CaelumArmorPickup" && item.UnitWeight>0 && item.Durability==1,"purchased native pickup survives later inventory ticks");
            if(item!=null)
            {
                double water=item.ThermalWaterKg;
                u.ApplyFormalInventorySelection(item);u.DropSelectedEquipment();
                CaelumEquipmentItem dropped=null;let it=ThinkerIterator.Create("CaelumEquipmentItem");CaelumEquipmentItem candidate;
                while((candidate=CaelumEquipmentItem(it.Next()))!=null)if(candidate.ItemId==PurchasedId && candidate.Owner==null){dropped=candidate;break;}
                Check(dropped!=null && dropped.Durability==1 && dropped.ThermalWaterKg==water,"drop retains item identity and physical condition");
                Actor receiver=u;if(dropped!=null)dropped.CallTryPickup(receiver);
                let recovered=u.FindNativeEquipmentItemById(PurchasedId);
                Check(recovered!=null && recovered.Durability==1 && recovered.ThermalWaterKg==water,"native pickup recovers the traded item");
            }
            let marker=CA133TradeMarker(Actor.Spawn("CA133TradeMarker",u.Pos));marker.ItemId=PurchasedId;marker.Vendor=CaelumCityMerchant.Find(4);
            marker.Cash=marker.Vendor.WalletCopper;marker.Stock=Count(marker.Vendor);
            marker.Body=CaelumPortSiege.Get().Defenders[0];marker.Body.Carbine.Magazine=3;marker.Body.Carbine.ReloadTotal=5;marker.Body.Carbine.ReloadRemaining=5;
            Console.Printf("CA133 COMPLETE checks=%d failures=%d",Checks,Failures);
            return;
        }
        if(level.time!=75)return;
        let u=CaelumPlayer(players[0].mo);let persistent=u.GetPersistentCharacterState(true);
        u.CreationWizardOpen=false;
        u.GrantMagicBoxFromPalomo(false);
        persistent.EnsurePalomoMerchantInitialized();int palomo=persistent.PalomoMerchantWalletCopper;
        int vendors=0;for(int i=0;i<64;i++)if(CaelumCityMerchant.Find(i)!=null)vendors++;
        Check(vendors==64,"64 independent static vendors");
        for(int c=0;c<6;c++)
        {
            let v=CaelumCityMerchant.Find(c);Check(v!=null && v.Revision==1 && !v.StockInitialized && !v.bShootable && !v.bIsMonster,"vendor initial noncombat identity");
            v.EnsureStock(u);int before=Count(v);v.EnsureStock(u);
            int expected=c==0 ? 5 : c==1 ? 65 : c==2 ? 23 : c==3 ? 9 : c==4 ? 75 : 125;
            Check(before==expected && Count(v)==before,"complete T1 variant catalogue and idempotent stock");
            bool valid=true;
            for(Inventory item=v.Inv;item!=null;item=item.Inv)
            {
                let eq=CaelumEquipmentItem(item);
                valid=valid && v.Accepts(item) && CaelumEconomyRules.GetInventoryUnitBaseValue(item)>0;
                if(eq!=null)
                {
                    valid=valid && eq.Tier==1 && eq.Amount==1 && eq.UnitWeight>0 && !eq.Equipped;
                    if(CaelumEconomyRules.GetInventoryUnitBaseValue(item)<=0 || eq.UnitWeight<=0 || !v.Accepts(item) || eq.Amount!=1 || eq.Equipped)
                        Console.Printf("CA133 STOCK category=%d kind=%d type=%d tier=%d weight=%.3f value=%.3f qty=%d equipped=%d accepts=%d",c,eq.EquipmentKind,eq.ItemType,eq.Tier,eq.UnitWeight,CaelumEconomyRules.GetInventoryUnitBaseValue(item),eq.Amount,eq.Equipped,v.Accepts(item));
                }
            }
            Check(valid,"stock uses priced native items and approved tier");
        }
        Check(CaelumEconomyRules.GetConsumableUnitBaseValue(0)==12
            && CaelumEconomyRules.GetConsumableUnitBaseValue(1)==12
            && CaelumEconomyRules.GetConsumableUnitBaseValue(2)==12,"recovery provisions cost three food rations");
        Check(Abs(CaelumEconomyRules.GetAmmunitionUnitBaseValue(0)-4*CaelumEconomyRules.GetAmmunitionUnitBaseValue(1))<0.000001,"cartridge value four arrows");
        let money=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(CaelumConstants.CURRENCY_GOLD),u.Pos));
        money.Amount=1;money.AttachToOwner(u);u.OnNativeInventoryChanged();
        let v=CaelumCityMerchant.Find(0);u.SetOrigin(v.Pos+(48,0,0),false);
        CaelumCityTradeSession.Open(u,v);u.PalomoMerchantQuantityIndex=0;
        Inventory food=null;for(Inventory p=v.Inv;p!=null;p=p.Inv)
            if(CaelumConsumableItem(p).GetConsumableType()==CaelumConstants.CONSUMABLE_FOOD_RATION)food=p;
        Select(u,food);double beforeMoney=u.GetOwnedMoneyCopperValue();int beforeCash=v.WalletCopper;
        int beforeFood=Food(u);
        int price=u.PalomoMerchantSelectedLotPrice;u.ExecutePalomoMerchantTransaction();
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT
            && u.GetOwnedMoneyCopperValue()==beforeMoney-price && v.WalletCopper==beforeCash+price
            && food.Amount==19 && Food(u)==beforeFood+1,"buy commits stock, currency change and native inventory once");
        Check(CaelumCityMerchant.Find(6).WalletCopper==200 && !CaelumCityMerchant.Find(6).StockInitialized
            && persistent.PalomoMerchantWalletCopper==palomo,"same-category vendor and Palomo remain independent");
        u.PalomoMerchantQuantityIndex=4;Select(u,food);beforeMoney=u.GetOwnedMoneyCopperValue();beforeCash=v.WalletCopper;
        u.ExecutePalomoMerchantTransaction();Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_STOCK
            && beforeMoney==u.GetOwnedMoneyCopperValue() && beforeCash==v.WalletCopper && food.Amount==19,"insufficient stock is atomic");
        u.PalomoMerchantQuantityIndex=0;u.TogglePalomoMerchantMode();let owned=u.FindNativeConsumableItem(CaelumConstants.CONSUMABLE_FOOD_RATION);
        Select(u,owned);v.WalletCopper=0;u.ExecutePalomoMerchantTransaction();
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_MERCHANT_MONEY
            && beforeMoney==u.GetOwnedMoneyCopperValue(),"empty merchant wallet rejects without changes");
        v.WalletCopper=beforeCash;Select(u,owned);price=u.PalomoMerchantSelectedLotPrice;u.ExecutePalomoMerchantTransaction();
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD
            && u.GetOwnedMoneyCopperValue()==beforeMoney+price && food.Amount==20,"sale returns actual stock at approved margin");
        u.ClosePalomoMerchant();v=CaelumCityMerchant.Find(4);u.SetOrigin(v.Pos+(48,0,0),false);CaelumCityTradeSession.Open(u,v);
        let eq=CaelumEquipmentItem(v.Inv);
        for(Inventory p=v.Inv;p!=null;p=p.Inv)if(CaelumEquipmentItem(p).UnitWeight<eq.UnitWeight)eq=CaelumEquipmentItem(p);
        owned=u.FindNativeConsumableItem(CaelumConstants.CONSUMABLE_FOOD_RATION);
        if(owned==null){owned=CaelumConsumableItem(Actor.Spawn(u.GetConsumableClassName(CaelumConstants.CONSUMABLE_FOOD_RATION),u.Pos));owned.AttachToOwner(u);}
        int actualFood=owned.Amount;owned.Amount=1000000;u.OnNativeInventoryChanged();Select(u,eq);
        beforeMoney=u.GetOwnedMoneyCopperValue();beforeCash=v.WalletCopper;u.ExecutePalomoMerchantTransaction();
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY
            && eq.Owner==v && beforeMoney==u.GetOwnedMoneyCopperValue() && beforeCash==v.WalletCopper,"capacity rejection leaves item, coins and stock unchanged");
        owned.Amount=actualFood;u.OnNativeInventoryChanged();Select(u,eq);u.ExecutePalomoMerchantTransaction();
        Console.Printf("CA133 EQUIPMENT action=%d price=%d weight=%.3f owner_player=%d cash=%d",u.LastPalomoMerchantAction,u.PalomoMerchantSelectedLotPrice,eq.UnitWeight,eq.Owner==u,v.WalletCopper);
        Check(eq.Owner==u && eq.AcquisitionResolved && eq.ItemId>0,"equipment keeps fixed size and gains player-owned identity");
        int id=eq.ItemId;eq.Durability=1;eq.ThermalWaterKg=0.125;u.TogglePalomoMerchantMode();Select(u,eq);u.ExecutePalomoMerchantTransaction();
        Check(eq.Owner==v && eq.ItemId==id && eq.Durability==1 && eq.ThermalWaterKg==0.125,"resale preserves original instance, wear and wetness");
        u.TogglePalomoMerchantMode();Select(u,eq);u.ExecutePalomoMerchantTransaction();
        Check(eq.Owner==u && eq.ItemId==id && eq.Durability==1 && eq.ThermalWaterKg==0.125,"repurchase preserves equipment rather than recreating seed");
        u.ClosePalomoMerchant();CaelumCityTradeSession.Open(u,v);Check(eq.Owner==u,"reopening never restocks sold items");
        PurchasedId=id;u.ClosePalomoMerchant();
    }
}

class CA133TradeMarker : Actor
{
    int ItemId,Cash,Stock,Step,Identity,Magazine;
    double Reload;
    vector3 Position,Post;
    CaelumCityMerchant Vendor;
    CaelumPortDefender Body;
    override void Tick()
    {
        if(Body==null)return;
        Position=Body.Pos;Post=Body.Station;Step=Body.DeploymentStep;Identity=Body.HomeIdentity;
        Magazine=Body.Carbine.Magazine;Reload=Body.Carbine.ReloadRemaining;
    }
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}

class CA133TradePersistence : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        Console.Printf("CA133 PERSIST map=%s save=%d reopen=%d",level.MapName,e.IsSaveGame,e.IsReopen);
        if(level.MapName!="MAP06" || (!e.IsSaveGame && !e.IsReopen))return;
        let marker=CA133TradeMarker(ThinkerIterator.Create("CA133TradeMarker").Next());
        if(marker==null){Console.Printf("CA133 FAIL missing saved marker");return;}
        let user=CaelumPlayer(players[0].mo);let item=user.FindNativeEquipmentItemById(marker.ItemId);
        int count=0;for(Inventory p=marker.Vendor.Inv;p!=null;p=p.Inv)count++;
        bool inventory=item!=null && item.Durability==1 && item is "CaelumArmorPickup"
            && marker.Vendor==CaelumCityMerchant.Find(4) && marker.Vendor.WalletCopper==marker.Cash && count==marker.Stock;
        let body=marker.Body;
        bool soldier=body!=null && body==CaelumPortSiege.Get().Defenders[0] && body.HomeIdentity==marker.Identity
            && body.DeploymentStep==marker.Step && body.Pos==marker.Position && body.Station==marker.Post
            && body.Carbine.Magazine==marker.Magazine && Abs(body.Carbine.ReloadRemaining-marker.Reload)<0.000001;
        Console.Printf("CA133 %s saved merchant cash, stock and traded native item",inventory ? "PASS" : "FAIL");
        Console.Printf("CA133 %s same soldier, house, station, progress, magazine and partial reload",soldier ? "PASS" : "FAIL");
        Console.Printf("CA133 PERSIST_COMPLETE map=%s",level.MapName);
    }
}
