class CA410KitchenChecks : CA410FoodChecks
{
    CaelumMaterialPickup SavedRaw;
    CaelumCityMerchant SavedVendor;
    bool Gallery;
    double DigestionStart,DigestionExpected;
    Array<String> Readings;
    CaelumMaterialPickup Raw(CaelumPlayer u,int id,int grams,double contamination,Actor owner=null)
    {
        let ingredient=u.CreateDetachedMaterialStack(id,1,grams);
        if(owner!=null)ingredient.AttachToOwner(owner);
        let lots=CaelumFoodInventory.Prepare(ingredient);
        if(lots!=null)lots.Lots[0].BaseContamination=contamination;
        return ingredient;
    }
    void Ingredients(CaelumPlayer u)
    {
        Setup(u);
        for(int id=108;id<=112;id++)
        {
            let ingredient=Raw(u,id,250,0,u);
            Check(ingredient.GetSpecialType()==id && ingredient.Amount==250,"native gram identity and quantity");
            Check(Near(ingredient.GetUnitWeight(),0.001),"one native unit weighs one gram");
            ingredient.UpdateMaterialVisuals();let texture=TexMan.CheckForTexture(CaelumKitchenData.Icon(id),TexMan.Type_MiscPatch);let size=TexMan.GetScaledSize(texture);
            Check(texture.IsValid() && ingredient.Icon==texture && size.X==128,"ingredient selects its own registered 128px icon");
            double expected=id==108?0.02:id==109?0.08:id==110?0.06:id==111?0.03:0.01;
            Check(Near(CaelumEconomyRules.GetMaterialUnitBaseValue(id,1),expected),"approved price per gram");
            Check(CaelumFoodInventory.IsFood(ingredient)==(id!=112),"salt does not acquire biological spoilage");
            double before=CaelumFoodIllness.Value(u);
            bool eaten=u.UseInventory(ingredient);
            Check(eaten==(id>=109 && id<=111),"only beef fish and vegetables can be eaten raw");
            if(eaten)
            {
                Check(ingredient.Amount==150 && ingredient.FoodLots.Units()==150,"raw use spends exactly one full 100g portion");
                let power=CaelumHungerRegeneration(u.FindInventory('CaelumHungerRegeneration'));
                double kcal=id==109?170:id==110?81:60;
                Check(power!=null && Near(power.FoodRecoveryPerPulse,kcal/240*800/u.DerivedStats.BaseMass/10),"distinct approved nutrition uses ten digestion pulses");
                ingredient.InMagicBox=true;
                Check(!u.UseInventory(ingredient) && ingredient.Amount==150,"boxed raw food cannot be consumed");
                ingredient.InMagicBox=false;ingredient.Amount=50;CaelumFoodInventory.Reconcile(ingredient);
                Check(!u.UseInventory(ingredient) && ingredient.Amount==50,"less than a full portion is preserved");
            }
            else Check(ingredient.Amount==250 && Near(CaelumFoodIllness.Value(u),before),"preparation-only ingredients remain unchanged");
            ingredient.Destroy();
        }
        let full=Raw(u,109,100,40,u);u.CurrentHunger=100;double before=CaelumFoodIllness.Value(u);
        Check(u.UseInventory(full),"full Hunger still accepts the approved complete portion");
        Check(Near(CaelumFoodIllness.Value(u),Min(100.0,before+40*80/u.DerivedStats.BaseMass)),"complete ingested mass applies body-mass contamination dose");
        Summary();
    }
    void Transfers(CaelumPlayer u)
    {
        Setup(u);let original=Raw(u,109,250,30,u);let fresh=Raw(u,109,50,0);
        original.FoodLots.Lots[0].CreatedStamp=-10;
        Check(original.HandlePickup(fresh) && original.Amount==300,"native ingredient pickup merges grams");
        Check(original.FoodLots.Units()==300 && original.FoodLots.Lots.Size()==2
            && Near(original.FoodLots.OldestContamination(),30),"fresh ingredient does not rejuvenate oldest lot");
        let dropped=CaelumMaterialPickup(original.CreateTossable(125));
        Check(dropped!=null && dropped.Amount==125 && original.Amount==175,"native toss splits arbitrary gram quantity");
        Check(dropped!=null && dropped.FoodLots!=original.FoodLots && dropped.FoodLots.Units()==125
            && original.FoodLots.Units()==175 && Near(dropped.FoodLots.OldestContamination(),30),"gram split preserves independent oldest lots");
        Check(!CaelumFoodInventory.CanSell(original),"contaminated raw food cannot be sold as fresh");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(64,0,0),NO_REPLACE));
        chest.ChestUnlocked=true;chest.ChestOpen=true;chest.EnsureStorage();
        let session=CaelumContainerSession.Get(u,true);session.Chest=chest;
        Check(CaelumInventoryService.TransferContainerItem(u,chest,original,75,true),"coffer accepts an exact 75g transfer");
        let stored=CaelumMaterialPickup(chest.FindInventory('CaelumMaterialPickup'));
        Check(stored!=null && stored.Amount==75 && stored.FoodLots.Units()==75 && original.Amount==100
            && original.FoodLots.Units()==100,"coffer transfer conserves native grams and lots");
        if(stored!=null)
        {
            Check(CaelumInventoryService.TransferContainerItem(u,chest,stored,25,false),"withdraw grams into existing material stack");
            Check(stored.Amount==50 && stored.FoodLots.Units()==50 && original.Amount==125
                && original.FoodLots.Units()==125,"withdrawal merges metadata once");
        }
        session.Close();SavedRaw=original;SavedChest=chest;Summary();
    }
    void IngredientClock(CaelumPlayer u)
    {
        Setup(u);let ingredient=Raw(u,110,1000,0,u);CaelumFoodInventory.Reconcile(ingredient);
        let clock=ingredient.FoodClock;
        Check(clock!=null && clock.Ready && ingredient.FoodSchemaRevision==1,"raw food receives revisioned native climate clock");
        double rate=clock.Climate.Rate(clock.Climate.CivilSeconds);
        clock.Stamp-=3600;CaelumFoodInventory.Reconcile(ingredient);
        Check(Near(ingredient.FoodLots.OldestContamination(),100.0/6*rate),"raw fish ages with its six-hour reference lifetime");
        ingredient.InMagicBox=true;clock.Stamp-=3600;CaelumFoodInventory.Reconcile(ingredient);
        Check(Near(ingredient.FoodLots.OldestContamination(),100.0/3*rate),"Box retains raw-food spoilage");
        let model=new('CaelumJourneyFood');model.Capture(u);int grams=ingredient.Amount;
        model.Advance(3600,20,50);
        Check(ingredient.Amount==grams && Near(ingredient.FoodLots.OldestContamination(),100.0/3*rate),"journey prediction cannot age live ingredients");
        Check(model.Consume()==0 && model.Stacks[0].Lots.Units()==grams,"automatic ration selection does not consume raw recipe ingredients");
        model.Commit(u);Check(ingredient.Amount==grams && ingredient.FoodLots.OldestContamination()>100.0/3*rate,"journey commits ingredient ageing without spending grams");
        SavedRaw=ingredient;Summary();
    }
    void Market(CaelumPlayer u)
    {
        Setup(u);let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(300,300,0),NO_REPLACE));
        vendor.Category=0;vendor.StockInitialized=true;vendor.EnumeratingStock=true;
        CaelumKitchenCatalogue.Ensure(vendor,u);int count=vendor.Products.Size();
        Check(count==5 && vendor.KitchenCatalogueRevision==1,"Provisions adds five approved ingredients");
        for(int i=0;i<count;i++)
        {
            let p=vendor.Products[i];int expected=p.ItemType==112?1000:p.ItemType==110?5000:10000;
            Check(p.Stock!=null && p.Stock.Amount==expected && p.Target==expected && p.ImportedMaterial,"approved import stock and maximum preserved");
            Check(Near(CaelumShopRestock.Duration(p,u),CaelumWorldClock.TicsPerDay()/(expected*0.001)),"imports replenish 0.1 percent of maximum per day");
            if(CaelumFoodInventory.IsFood(p.Stock))
            {
                CaelumFoodInventory.Reconcile(p.Stock);let clock=CaelumFoodClock.Get(p.Stock);
                clock.Stamp-=86400;CaelumFoodInventory.Reconcile(p.Stock);
                Check(CaelumFoodInventory.GetLots(p.Stock).OldestContamination()==0,"commercial ingredient stock stays fresh");
            }
        }
        vendor.Products[0].Stock.Amount-=100;CaelumFoodInventory.Reconcile(vendor.Products[0].Stock);
        CaelumKitchenCatalogue.Ensure(vendor,u);
        Check(vendor.Products.Size()==5 && vendor.Products[0].Stock.Amount==9900,"catalogue migration cannot refill existing stock");
        SavedVendor=vendor;Summary();
    }
    void Saved(CaelumPlayer u)
    {
        Console.Printf("CA410K SAVED type=%d grams=%d lots=%d contamination=%.8f",SavedRaw!=null?SavedRaw.GetSpecialType():-1,
            SavedRaw!=null?SavedRaw.Amount:-1,SavedRaw!=null && SavedRaw.FoodLots!=null?SavedRaw.FoodLots.Units():-1,
            SavedRaw!=null && SavedRaw.FoodLots!=null?SavedRaw.FoodLots.OldestContamination():-1);
        Check(SavedRaw!=null && SavedRaw.GetSpecialType()==109 && SavedRaw.Amount==125
            && SavedRaw.FoodLots.Units()==125 && SavedRaw.FoodLots.OldestContamination()>=30
            && SavedRaw.FoodLots.OldestContamination()<30.1,"save retains raw ingredient identity grams and oldest contamination");
        let clock=CaelumFoodClock.Get(SavedRaw);Check(clock!=null && clock.Item==SavedRaw,"saved generic food clock rebinds original material");
        Check(SavedVendor!=null && SavedVendor.KitchenCatalogueRevision==1 && SavedVendor.Products.Size()==5
            && SavedVendor.Products[0].Stock.Amount==9900,"save retains additive catalogue and purchased quantity");
        Summary();
    }
    void NativePickup(CaelumPlayer u)
    {
        Setup(u);Actor recipient=u;let ground=Raw(u,111,225,27);
        Check(ground.CallTryPickup(recipient),"native ground pickup accepted");
        let acquired=CaelumMaterialPickup(CaelumCityTradeSession.Stack(u,ground));
        Check(acquired!=null && acquired.Amount==225 && acquired.FoodLots.Units()==225
            && Near(acquired.FoodLots.OldestContamination(),27),"native pickup retains grams and age");
        let extra=Raw(u,111,75,0);extra.CallTryPickup(recipient);
        Check(acquired!=null && acquired.Amount==300 && acquired.FoodLots.Units()==300
            && acquired.FoodLots.Lots.Size()==2,"native pickup into carried stack preserves lots");
        if(acquired!=null)acquired.Destroy();
        let capped=Raw(u,110,250,19);capped.MaxAmount=100;
        Check(capped.CallTryPickup(recipient),"native capped pickup accepted");
        let kept=CaelumMaterialPickup(u.FindInventory('CaelumMaterialPickup'));
        Check(kept!=null && kept.Amount==100 && kept.FoodLots.Units()==100
            && Near(kept.FoodLots.OldestContamination(),19),"native capped copy limits ledger with native amount");
        Summary();
    }
    void FormalInput(CaelumPlayer u)
    {
        Setup(u);let ingredient=Raw(u,109,200,10,u);u.OnNativeInventoryChanged();
        u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        for(int i=0;i<u.FormalInventoryEntryCount;i++)
            if(u.GetFormalInventoryEntryAt(i)==ingredient){u.FormalInventorySelectionIndex=i;break;}
        u.RefreshFormalInventorySnapshot();u.ActivateFormalInventorySelection();
        Check(ingredient.Amount==100 && !ingredient.InMagicBox,"journal use consumes one portion instead of boxing it");
        ingredient.InMagicBox=true;u.OnNativeInventoryChanged();u.RefreshFormalInventorySnapshot();
        u.ActivateFormalInventorySelection();
        Check(ingredient.Amount==100 && !ingredient.InMagicBox,"journal retrieves boxed ingredient without consuming it");
        u.ActivateFormalInventorySelection();
        Check(ingredient.bDestroyed || ingredient.Amount==0,"journal consumes final complete portion");Summary();
    }
    void RawHubReturn()
    {
        let stored=SavedChest!=null?CaelumMaterialPickup(SavedChest.FindInventory('CaelumMaterialPickup')):null;
        Check(stored!=null && stored.Amount==50,"unloaded coffer keeps raw ingredient grams");
        if(stored!=null)
        {
            CaelumFoodInventory.Reconcile(stored);
            Check(stored.FoodLots.Units()==50 && stored.FoodLots.OldestContamination()>30.01,"raw ingredient ages during absence from its storage map");
            Check(stored.FoodClock!=null && stored.FoodClock.Item==stored,"hub rebinds generic material clock");
        }
        Summary();
    }
    void IngredientCensus(CaelumPlayer u)
    {
        Setup(u);
        for(int i=0;i<500;i++)
        {
            let item=u.CreateDetachedMaterialStack(109,1,1000);
            item.SetOrigin((200+(i%20)*8,200+(i/20)*8,0),false);item.bInvisible=true;
        }
        double start=MSTimeF();int count=0,foods=0;
        let census=ThinkerIterator.Create('CaelumMaterialPickup');Inventory item;
        while((item=Inventory(census.Next()))!=null){count++;if(CaelumFoodClock.Get(item)!=null)foods++;}
        Console.Printf("CA410K CENSUS material=%d food=%d cold_ms=%.6f",count,foods,MSTimeF()-start);
        Check(count>=500 && foods==500,"single typed migration census initializes 500 ingredient clocks");Summary();
    }
    void Purchase(CaelumPlayer u)
    {
        Market(u);let vendor=SavedVendor;vendor.SetOrigin(u.Pos+(48,0,0),false);
        u.GiveInventory('CaelumCopperCoin',1000);CaelumCityTradeSession.Open(u,vendor);
        let session=u.CityTrade;u.PalomoMerchantQuantityIndex=4;session.Refresh(u);
        Inventory stock=null;
        for(int i=0;i<session.Rows.Size();i++)
            if(CaelumMaterialPickup(session.Rows[i]).GetSpecialType()==109){session.Selection=i;stock=session.Rows[i];break;}
        session.Refresh(u);int money=u.GetOwnedMoneyCopperValue(),stockBefore=stock!=null?stock.Amount:0;
        int price=u.PalomoMerchantSelectedLotPrice;session.Execute(u);
        let acquired=stock!=null?CaelumMaterialPickup(CaelumCityTradeSession.Stack(u,stock)):null;
        Check(acquired!=null && acquired.Amount==100 && acquired.FoodLots.Units()==100
            && acquired.FoodLots.OldestContamination()==0,"native purchase delivers 100 fresh grams");
        Check(stock!=null && stock.Amount==stockBefore-100 && u.GetOwnedMoneyCopperValue()==money-price,"native purchase spends quoted coins and real stock");
        if(acquired!=null)
        {
            acquired.FoodLots.Lots[0].BaseContamination=21;session.Execute(u);
            Check(acquired.Amount==200 && acquired.FoodLots.Units()==200
                && acquired.FoodLots.Lots.Size()==2 && Near(acquired.FoodLots.OldestContamination(),21),"second native purchase cannot freshen carried ingredients");
            u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;session.Refresh(u);bool listed=false;
            for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i]==acquired)listed=true;
            Check(!listed,"contaminated ingredients are absent from resale offers");
        }
        u.ClosePalomoMerchant();Summary();
    }
    void Digestion(CaelumPlayer u,bool finish,bool control=false)
    {
        if(!finish)
        {
            Setup(u);u.health=u.CaelumMaximumHealth;u.player.health=u.health;
            u.CurrentAir=u.DerivedStats.MaximumAir;u.CurrentAnima=u.DerivedStats.MaximumAnima;
            let ingredient=Raw(u,109,100,0,u);DigestionStart=u.CurrentHunger;
            DigestionExpected=170.0/240*800/u.DerivedStats.BaseMass;
            if(control){ingredient.Destroy();DigestionExpected=0;}
            else Check(u.UseInventory(ingredient),"begin native timed raw-food digestion");
        }
        else
        {
            Console.Printf("CA410K DIGESTION actual=%.8f expected=%.8f",u.CurrentHunger-DigestionStart,DigestionExpected);
            Check(u.FindInventory('CaelumHungerRegeneration')==null,"native timed digestion has completed");
            Summary();
        }
    }
    void ReadKitchen(CaelumPlayer u)
    {
        Readings.Clear();
        for(int id=108;id<=112;id++)
        {
            CaelumMaterialPickup ingredient=null;
            for(Inventory it=u.Inv;it!=null;it=it.Inv)
            {let m=CaelumMaterialPickup(it);if(m!=null && m.GetSpecialType()==id){ingredient=m;break;}}
            if(ingredient==null)continue;
            CaelumFoodInventory.Reconcile(ingredient);let lots=ingredient.FoodLots;
            String line=String.Format("%s: %d g | lotes %d | C %.2f",CaelumKitchenData.Slug(id),ingredient.Amount,
                lots!=null?lots.Lots.Size():0,lots!=null?lots.OldestContamination():0);
            Readings.Push(line);Console.Printf("CA410K %s",line);
        }
        Readings.Push(String.Format("Cuerpo C %.2f | Hambre %.2f",CaelumFoodIllness.Value(u),u.CurrentHunger));
        Console.Printf("CA410K %s",Readings[Readings.Size()-1]);
    }
    void ManualKitchen(CaelumPlayer u)
    {
        Setup(u);Gallery=true;CaelumFoodIllness.Get(u).Contamination=0;
        for(Inventory it=u.Inv;it!=null;)
        {Inventory next=it.Inv;let m=CaelumMaterialPickup(it);if(m!=null && CaelumKitchenData.IsMaterial(m.GetSpecialType()))m.Destroy();it=next;}
        for(int id=108;id<=112;id++)Raw(u,id,500,id==109?30:0,u);
        u.OnNativeInventoryChanged();u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        for(int i=0;i<u.FormalInventoryEntryCount;i++)
        {let m=CaelumMaterialPickup(u.GetFormalInventoryEntryAt(i));if(m!=null && m.GetSpecialType()==109){u.FormalInventorySelectionIndex=i;break;}}
        u.RefreshFormalInventorySnapshot();
        ReadKitchen(u);Summary();
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Gallery)return;
        let f=Font.GetFont('CaelumMono');Screen.Dim(0x181512,.88,0,0,Screen.GetWidth(),int(Screen.GetHeight()*.68));
        Screen.DrawText(f,Font.CR_GOLD,12,8,"#410 - Ingredientes de cocina",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        for(int i=0;i<5;i++)
        {
            let texture=TexMan.CheckForTexture(CaelumKitchenData.Icon(108+i),TexMan.Type_MiscPatch);
            let size=TexMan.GetScaledSize(texture);
            if(texture.IsValid() && size.X>0)
                Screen.DrawTexture(texture,false,12+i*125,27,DTA_DestWidth,90,DTA_DestHeight,90,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        }
        for(int i=0;i<Readings.Size();i++)Screen.DrawText(f,Font.CR_WHITE,12,120+i*15,Readings[i],DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_GOLD,12,218,"F1 reiniciar | F2 leer | F3 comer carne | F4 envejecer 1h",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
        Screen.DrawText(f,Font.CR_WHITE,12,234,"T inventario; F5 oculta/muestra esta vista.",DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360);
    }
    void Summary(){Console.Printf("CA410K RESULT passed=%d failed=%d",Passed,Failed);}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410k_core')Ingredients(u);
        else if(e.Name=='ca410k_transfer')Transfers(u);
        else if(e.Name=='ca410k_clock')IngredientClock(u);
        else if(e.Name=='ca410k_market')Market(u);
        else if(e.Name=='ca410k_seed'){Transfers(u);Market(u);}
        else if(e.Name=='ca410k_load')Saved(u);
        else if(e.Name=='ca410k_pickup')NativePickup(u);
        else if(e.Name=='ca410k_formal')FormalInput(u);
        else if(e.Name=='ca410k_hubreturn')RawHubReturn();
        else if(e.Name=='ca410k_census')IngredientCensus(u);
        else if(e.Name=='ca410k_purchase')Purchase(u);
        else if(e.Name=='ca410k_digest')Digestion(u,false);
        else if(e.Name=='ca410k_digestcontrol')Digestion(u,false,true);
        else if(e.Name=='ca410k_digested')Digestion(u,true);
        else if(e.Name=='ca410k_manual')ManualKitchen(u);
        else if(e.Name=='ca410k_read')ReadKitchen(u);
        else if(e.Name=='ca410k_view')Gallery=!Gallery;
        else if(e.Name=='ca410k_eat')
        {
            for(Inventory it=u.Inv;it!=null;it=it.Inv)
            {let m=CaelumMaterialPickup(it);if(m!=null && m.GetSpecialType()==109){u.UseInventory(m);break;}}
            u.RefreshFormalInventorySnapshot();ReadKitchen(u);
        }
        else if(e.Name=='ca410k_age')
        {
            for(Inventory it=u.Inv;it!=null;it=it.Inv)if(CaelumFoodInventory.IsFood(it))
            {CaelumFoodInventory.Reconcile(it);CaelumFoodClock.Get(it).Stamp-=3600;CaelumFoodInventory.Reconcile(it);}
            u.RefreshFormalInventorySnapshot();ReadKitchen(u);
        }
        else Super.NetworkProcess(e);
    }
}
class CA410KitchenMenu : CaelumLiveMenu
{
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_KeyDown)
        {
            String command="";
            if(e.KeyChar==UIEvent.Key_F1)command="ca410k_manual";
            else if(e.KeyChar==UIEvent.Key_F2)command="ca410k_read";
            else if(e.KeyChar==UIEvent.Key_F3)command="ca410k_eat";
            else if(e.KeyChar==UIEvent.Key_F4)command="ca410k_age";
            else if(e.KeyChar==UIEvent.Key_F5)command="ca410k_view";
            if(command.Length()>0){EventHandler.SendNetworkEvent(command);return true;}
        }
        return Super.OnUIEvent(e);
    }
}
