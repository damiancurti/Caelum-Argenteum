class CA424Checks : EventHandler
{
    int Checks,Failures;
    CaelumCityMerchant Vendor;
    Inventory Stock;
    CaelumHingedDoorLeaf Door;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA424 %s %s",ok?"PASS":"FAIL",label);}
    void Seed(CaelumPlayer u)
    {
        u.player.cheats|=CF_GODMODE;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeRevision=1;r.DemoNarrativeDelivered=2047;
        Vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(48,0,0)));
        Vendor.Category=2;Vendor.ShopIdentity=-1;Vendor.WalletCopper=100000;
        Stock=Vendor.SeedSimple('CaelumCarbineAmmo',200);
        Door=CaelumHingedDoorLeaf(Actor.Spawn("CaelumHingedDoorLeaf",(-128,0,0)));
        Door.args[3]=0;
        Check(u.BuildPalomoCurrencyCreditPlan(100000)&&u.ApplyPalomoCurrencyPlan(),"real currency seeded");
        u.PersistCharacterState();
    }
    void Select(CaelumPlayer u,Inventory item)
    {
        let session=u.CityTrade;if(session==null){Check(false,"trade session exists");return;}
        for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i]==item)session.Selection=i;
        session.Refresh(u);
    }
    void Rules(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(false);
        u.GrantMagicBoxFromPalomo(false);
        Check(u.MagicBoxOwned,"existing merchant prerequisite granted through its real owner");
        Check(u.BuildPalomoCurrencyCreditPlan(250000)&&u.ApplyPalomoCurrencyPlan(),"fixture funds all five real price tiers");
        Check(Vendor.AccessCondition==null,"legacy merchant defaults to civilian affiliation");
        r.FactionReputation[0]=-1000;
        CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);
        Check(u.CityTrade!=null&&u.IsActivePalomoMerchantSessionValid(),"civilian merchant ignores hostile faction reputation");
        u.ClosePalomoMerchant();Vendor.AccessCondition=CaelumFactionCondition.Create(0,-1000);
        CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);
        Check(u.CityTrade==null,"hostile faction merchant refuses entry despite permissive legacy minimum");
        int ranks[5]={-249,0,50,250,500};double buy[5]={1.50,1,0.85,0.75,0.66};double sell[5]={0.80,1,1.05,1.10,1.15};
        for(int n=0;n<5;n++)
        {
            r.FactionReputation[0]=ranks[n];CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);
            u.PalomoMerchantQuantityIndex=2;Select(u,Stock);
            int price=CaelumEconomyRules.GetPriceChargedByMerchant(CaelumCityTradeSession.Value(Stock)*buy[n],20);
            Check(u.PalomoMerchantSelectedLotPrice==price,String.Format("rank %d native buy quote",n));
            double before=u.GetOwnedMoneyCopperValue();int amount=Stock.Amount,wallet=Vendor.WalletCopper;
            u.CityTrade.Execute(u);
            Console.Printf("CA424 DETAIL rank=%d amount=%d/%d money=%.0f/%.0f wallet=%d/%d quote=%d action=%d",n,Stock.Amount,amount,u.GetOwnedMoneyCopperValue(),before,Vendor.WalletCopper,wallet,price,u.LastPalomoMerchantAction);
            Check(Stock.Amount==amount-20&&u.GetOwnedMoneyCopperValue()==before-price&&Vendor.WalletCopper==wallet+price,String.Format("rank %d commits real purchase",n));
            let owned=u.FindInventory('CaelumCarbineAmmo');u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;
            u.CityTrade.Refresh(u);Select(u,owned);before=u.GetOwnedMoneyCopperValue();wallet=Vendor.WalletCopper;
            price=CaelumEconomyRules.GetPricePaidByMerchant(CaelumCityTradeSession.Value(owned)*sell[n],20);
            Check(u.PalomoMerchantSelectedLotPrice==price,String.Format("rank %d native sell quote",n));
            u.CityTrade.Execute(u);
            Check(price>0&&u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD
                &&u.GetOwnedMoneyCopperValue()==before+price&&Vendor.WalletCopper==wallet-price,String.Format("rank %d commits real sale",n));
            u.ClosePalomoMerchant();
        }
        r.FactionReputation[0]=0;CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);Select(u,Stock);
        double before=u.GetOwnedMoneyCopperValue();int amount=Stock.Amount;
        r.FactionReputation[0]=500;u.CityTrade.Execute(u);
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED
            &&u.GetOwnedMoneyCopperValue()==before&&Stock.Amount==amount,"changed quote cannot commit stale price");
        r.FactionReputation[0]=-250;u.CityTrade.Execute(u);
        Check(u.GetOwnedMoneyCopperValue()==before&&Stock.Amount==amount&&!u.IsActivePalomoMerchantSessionValid(),"hostility during open city session cannot transfer resources");
        u.ClosePalomoMerchant();r.FactionReputation[0]=500;
        u.OpenPalomoMerchant(Vendor,Vendor.AccessCondition);
        u.PalomoMerchantSelection=CaelumConstants.PALOMO_MERCHANT_ITEM_WOOD;u.PalomoMerchantQuantityIndex=2;u.RefreshPalomoMerchantSnapshot();
        Check(u.PalomoMerchantSelectedLotPrice==40,"generic merchant rank factor rounds once on whole lot");
        before=u.GetOwnedMoneyCopperValue();r.FactionReputation[0]=-250;u.ExecutePalomoMerchantTransaction();
        Check(!u.PalomoMerchantMenuOpen&&u.GetOwnedMoneyCopperValue()==before,"generic merchant revalidates hostile session");
        Door.AccessCondition=Vendor.AccessCondition;
        Check(!CaelumPolyDoors.Guarded(Door,u),"faction door refuses hostile access");
        Door.AccessCondition=null;
        Check(CaelumPolyDoors.Guarded(Door,u),"civilian door keeps access");
        r.FactionReputation[0]=500;Vendor.Category=CaelumShopCatalogue.LIBRARY;
        let offer=Vendor.SeedBook(CaelumHygieneData.CLOTH_RECIPE,1,100);
        CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);Select(u,offer);
        before=u.GetOwnedMoneyCopperValue();amount=offer.Amount;
        Check(u.PalomoMerchantSelectedLotPrice==99,"library offer uses faction price");
        u.CityTrade.Execute(u);
        Check(offer.Amount==amount-1&&u.GetOwnedMoneyCopperValue()==before-99,"library commit accepts authorized faction quote");
        u.ClosePalomoMerchant();u.PersistCharacterState();
    }
    void Preserved(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(false);
        Check(Vendor.AccessCondition!=null&&Vendor.AccessCondition.FactionId==0&&r.FactionReputation[0]==500,"explicit affiliation and actual reputation survive reload");
        CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);
        Check(u.IsActivePalomoMerchantSessionValid()&&u.PalomoMerchantFactionPriceFactor==0.66,"reloaded session recomputes current price factor");
        u.ClosePalomoMerchant();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca424_seed")Seed(u);
        if(e.Name=="ca424_rules")Rules(u);
        if(e.Name=="ca424_preserved")Preserved(u);
        if(e.Name=="ca424_view")CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);
        if(e.Name=="ca424_done")Console.Printf("CA424 RESULT checks=%d failures=%d",Checks,Failures);
    }
}
