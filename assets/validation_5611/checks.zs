// Cada salto temporal ocurre sólo en la sala privada de pruebas.
class CA385Mark : Inventory
{
    CaelumCityMerchant Vendor;
    CaelumShopProduct Product;
    int Money,Wallet,Stock;
    double Due,Period;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA385Checks : CA383Checks
{
    double PauseStamp,PauseWall;
    CaelumCityMerchant Fresh385(CaelumPlayer u,int category)
    {
        let v=Vendor(u,category);v.StockInitialized=false;v.Revision=0;
        v.TradesClothing=category==7;v.EnsureStock(u);return v;
    }
    void Setup385(CaelumPlayer u)
    {
        Prepare(u);Money(u,10);let clock=CaelumWorldClock.Get(u,true);
        CaelumCalendarState.Get(u,true).EnsureCampaign(clock);
    }
    void Coverage(CaelumPlayer u)
    {
        int products=0,unrenewed=0;
        for(int category=0;category<8;category++)
        {
            let v=Fresh385(u,category);
            for(int i=0;i<v.Products.Size();i++)
            {
                let p=v.Products[i];products++;
                Check(p.Stock!=null && p.Matches(p.Stock),String.Format("catalogue %d product %d has exact native stock",category,i));
                if(p.Recipe<0)unrenewed++;
                else Check(CaelumShopRestock.Duration(p,u)>0,String.Format("catalogue %d product %d has finite recipe-chain duration",category,i));
            }
        }
        Check(unrenewed==13,"only eleven provisions and two prepared kits lack recipes");
        Console.Printf("CA385 COVERAGE products=%d unrenewed=%d",products,unrenewed);
    }
    void NewEquipment(CaelumPlayer u)
    {
        let v=Fresh385(u,7);let p=v.Products[0];let old=CaelumEquipmentItem(p.Stock);
        CaelumCityTradeSession.Open(u,v);Select(u,old);u.ExecutePalomoMerchantTransaction();
        Reach(u,p.NextDue);CaelumShopRestock.Sync(v,u);
        let made=CaelumEquipmentItem(p.Stock);
        Check(made!=null && made!=old && made.Owner==v && old.Owner==u && p.Matches(made)
            && made.Durability==made.PreviewMaximumDurability(u),"depleted garment produces fresh matching equipment without copying old instance");
        let locks=Fresh385(u,1);let lockProduct=Product(locks,CaelumShopProduct.LOCK,0);
        let oldLock=CaelumLockItem(lockProduct.Stock);let oldKey=CaelumCityTradeSession.Companion(oldLock);
        CaelumCityTradeSession.Open(u,locks);Select(u,oldLock);u.ExecutePalomoMerchantTransaction();
        Reach(u,lockProduct.NextDue);CaelumShopRestock.Sync(locks,u);
        let newLock=CaelumLockItem(lockProduct.Stock);let newKey=CaelumCityTradeSession.Companion(newLock);
        Check(oldLock.Owner==u && oldKey.Owner==u && newLock!=oldLock && newKey!=null && newKey!=oldKey,
            "lock renewal creates another paired lock and key without touching purchased pair");
        u.ClosePalomoMerchant();
    }
    CaelumShopProduct Product(CaelumCityMerchant v,int kind,int item=0,Name nativeClassName='None',int recipe=-1)
    {
        for(int i=0;i<v.Products.Size();i++)
        {
            let p=v.Products[i];
            if(p.Kind==kind && (kind==CaelumShopProduct.SIMPLE ? p.NativeClass==nativeClassName
                : kind==CaelumShopProduct.BOOK ? p.Recipe==recipe : p.ItemType==item))return p;
        }
        return null;
    }
    void Reach(CaelumPlayer u,double stamp)
    {
        double delta=stamp-CaelumScheduleState.Now(u);
        if(delta>0)CaelumWorldClock.Get(u).AdvanceTics(int(Ceil(delta)));
    }
    void Timing(CaelumPlayer u)
    {
        let v=Fresh385(u,2);let carbine=Product(v,CaelumShopProduct.SIMPLE,0,'CaelumCarbineAmmo');
        let shotgun=Product(v,CaelumShopProduct.SIMPLE,0,'CaelumShotgunAmmo');
        Check(carbine!=null && shotgun!=null,"authored ammunition products registered");
        if(carbine==null || shotgun==null)return;
        Check(abs(CaelumShopRestock.Duration(carbine,u)-16)<0.00001 && abs(CaelumShopRestock.Duration(shotgun,u)-16)<0.00001,"each cartridge takes 160-tic batch divided by ten outputs");
        CaelumCityTradeSession.Open(u,v);Select(u,carbine.Stock,1);u.ExecutePalomoMerchantTransaction();
        Select(u,shotgun.Stock,1);u.ExecutePalomoMerchantTransaction();
        Check(carbine.Stock.Amount==995 && shotgun.Stock.Amount==995,"five units depleted independently");
        double due=carbine.NextDue;int wallet=v.WalletCopper;
        Check(due==shotgun.NextDue && due==CaelumScheduleState.Now(u)+16,"products begin concurrent independent queues");
        Reach(u,due-1);CaelumShopRestock.Sync(v,u);Check(carbine.Stock.Amount==995,"before deadline no unit is made");
        Reach(u,due);CaelumShopRestock.Sync(v,u);
        Check(carbine.Stock.Amount==996 && shotgun.Stock.Amount==996,"at deadline exactly one unit per product");
        Check(carbine.NextDue==due+16,"second unit waits a full serial period");
        CaelumShopRestock.Sync(v,u);CaelumCityTradeSession.Open(u,v);
        Check(carbine.Stock.Amount==996 && shotgun.Stock.Amount==996,"same timestamp and reopen do not repeat renewal");
        Reach(u,due+16);CaelumShopRestock.Sync(v,u);Check(carbine.Stock.Amount==997,"second sequential unit at second deadline");
        Reach(u,due+100000);CaelumShopRestock.Sync(v,u);
        Check(carbine.Stock.Amount==1000 && shotgun.Stock.Amount==1000 && carbine.NextDue<0,"long skip caps stock and discards idle production time");
        Check(v.WalletCopper==wallet,"production never replenishes merchant money");
        Select(u,carbine.Stock);u.ExecutePalomoMerchantTransaction();
        Check(carbine.Stock.Amount==999 && carbine.NextDue==CaelumScheduleState.Now(u)+16,"new sale starts a fresh period after long idle");
        u.ClosePalomoMerchant();
    }
    void BooksAndQuotes(CaelumPlayer u)
    {
        let library=Fresh385(u,6);let book=Product(library,CaelumShopProduct.BOOK,0,'None',166);
        Check(book!=null && abs(CaelumShopRestock.Duration(book,u)-160)<0.00001,"cartridge book takes the whole represented batch");
        let clothing=Fresh385(u,7);let garment=clothing.Products[0];
        let quote=new("CaelumRecipeQuote");quote.Build(u,garment.Recipe,1,garment.Size);
        Check(quote.CompleteManufactureSeconds>quote.ManufactureSeconds,"garment quote includes work through component chain");
        Check(abs(CaelumShopRestock.Duration(garment,u)-quote.CompleteManufactureSeconds*TICRATE)<0.00001,"replenishment uses full chain, not just final assembly");
        int selected=u.CraftingSelectionRecipe,tier=u.CraftingSelectionTier,size=u.CraftingSelectionSize;
        let record=u.GetPersistentCharacterState(true);double before=CaelumShopRestock.Duration(garment,u);
        for(int slot=0;slot<CaelumRecipeLearning.SLOT_COUNT;slot++)
        {record.RecipeRereadings[slot]=10;record.RecipePractice[slot]=CaelumRecipeLearning.PracticeLimit(slot/3);}
        double oldDex=u.Attributes.Dexterity;u.Attributes.Dexterity=0;
        double after=CaelumShopRestock.Duration(garment,u);
        Check(abs(before-after)<0.0001,"merchant time independent of player mastery and Technical attribute");
        quote.Build(u,garment.Recipe,1,garment.Size);
        Check(abs(quote.Seconds-quote.CompleteManufactureSeconds)<0.0001,"mastered zero-attribute native recipe duration agrees with complete merchant quote");
        u.Attributes.Dexterity=oldDex;
        Check(u.CraftingSelectionRecipe==selected && u.CraftingSelectionTier==tier && u.CraftingSelectionSize==size,"merchant quote restores player crafting selection");
        CaelumCityTradeSession.Open(u,library);Select(u,book.Stock);u.ExecutePalomoMerchantTransaction();
        int wallet=library.WalletCopper;double due=book.NextDue;
        Check(book.Stock.Amount==9 && due>CaelumScheduleState.Now(u),"book purchase arms replenishment");
        Reach(u,due);CaelumShopRestock.Sync(library,u);Check(book.Stock.Amount==10 && library.WalletCopper==wallet,"book restocks to ten without wallet grants");
        int money=int(u.GetOwnedMoneyCopperValue());Select(u,book.Stock);u.ExecutePalomoMerchantTransaction();
        Check(book.Stock.Amount==10 && int(u.GetOwnedMoneyCopperValue())==money,"restocking does not bypass duplicate-page rejection");
        u.ClosePalomoMerchant();
    }
    void Sources(CaelumPlayer u)
    {
        let v=Fresh385(u,2);let kit=Product(v,CaelumShopProduct.MATERIAL,79);
        CaelumCityTradeSession.Open(u,v);Select(u,kit.Stock);u.ExecutePalomoMerchantTransaction();
        let food=Fresh385(u,0);CaelumCityTradeSession.Open(u,food);let ration=Product(food,CaelumShopProduct.SIMPLE,0,'CaelumFoodRation');
        if(ration==null)ration=food.Products[0];Select(u,ration.Stock);u.ExecutePalomoMerchantTransaction();
        int foodCount=ration.Stock.Amount;CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerDay()*30);
        CaelumShopRestock.Sync(v,u,true);CaelumShopRestock.Sync(food,u,true);
        Check(kit.Recipe<0 && kit.Stock.Amount==999 && kit.NextDue<0,"prepared kit has no recipe and never renews");
        Check(ration.Recipe<0 && ration.Stock.Amount==foodCount,"recipe-less provisions never renew");
        let clothing=Fresh385(u,7);int products=clothing.Products.Size();let product=clothing.Products[0];
        CaelumCityTradeSession.Open(u,clothing);let original=CaelumEquipmentItem(product.Stock);Select(u,original);u.ExecutePalomoMerchantTransaction();
        original.Durability=17;int identity=original.ItemId;
        Select(u,original,0,true);u.ExecutePalomoMerchantTransaction();
        CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerDay()*30);CaelumShopRestock.Sync(clothing,u,true);
        Check(original.Owner==clothing && original.ItemId==identity && original.Durability==17 && Count(clothing)==125,"sold worn exact item remains itself and prevents extra same-variant stock");
        let extra=clothing.SeedEquipment(u,CaelumConstants.EQUIPMENT_KIND_CLOTHING,0,0,0,0);
        extra.Tier=2;extra.ItemId=7654321;extra.Durability=19;
        CaelumShopRestock.Sync(clothing,u,true);CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerDay()*30);CaelumShopRestock.Sync(clothing,u,true);
        Check(clothing.Products.Size()==products && Count(clothing)==126 && extra.ItemId==7654321 && extra.Durability==19,"non-catalogue trade-in creates no production entry or copy");
        u.ClosePalomoMerchant();
    }
    void Save385(CaelumPlayer u)
    {
        Setup385(u);let v=Fresh385(u,2);v.ShopIdentity=1385;
        let product=Product(v,CaelumShopProduct.SIMPLE,0,'CaelumArrowAmmo');
        CaelumCityTradeSession.Open(u,v);Select(u,product.Stock,1);u.ExecutePalomoMerchantTransaction();
        Reach(u,CaelumScheduleState.Now(u)+Floor(product.UnitTics/2));
        let m=CA385Mark(Actor.Spawn("CA385Mark",u.Pos,NO_REPLACE));m.AttachToOwner(u);
        m.Vendor=v;m.Product=product;m.Money=int(u.GetOwnedMoneyCopperValue());m.Wallet=v.WalletCopper;
        m.Stock=product.Stock.Amount;m.Due=product.NextDue;m.Period=product.UnitTics;
        u.ClosePalomoMerchant();u.PersistCharacterState();
        Check(product.NextDue>CaelumScheduleState.Now(u) && m.Stock==995,"save contains fractional serial production progress");
    }
    void Verify385(CaelumPlayer u,bool resume=false,bool completed=false)
    {
        let m=CA385Mark(u.FindInventory("CA385Mark"));Check(m!=null,"production checkpoint survives");if(m==null)return;
        let v=CaelumCityMerchant.Find(1385);Check(v!=null,"same hub merchant survives");if(v==null)return;
        let product=Product(v,CaelumShopProduct.SIMPLE,0,'CaelumArrowAmmo');
        Check(product!=null && abs(product.UnitTics-m.Period)<0.00001,"saved per-unit duration survives");
        Check(int(u.GetOwnedMoneyCopperValue())==m.Money && v.WalletCopper==m.Wallet,"stock catch-up does not change either wallet");
        if(completed){CaelumShopRestock.Sync(v,u);Check(product.Stock.Amount==m.Stock+3,"completed saved output is not paid twice");return;}
        Check(product.NextDue==m.Due && product.Stock.Amount==m.Stock,"save and hub return preserve fractional deadline and native stock");
        if(resume)
        {
            Reach(u,m.Due+2*m.Period);CaelumShopRestock.Sync(v,u);
            Check(product.Stock.Amount==m.Stock+3,"three elapsed sequential deadlines produce exactly three units after loading");
        }
    }
    void Active385(CaelumPlayer u)
    {
        Setup385(u);let v=Fresh385(u,2);v.ShopIdentity=2385;
        let p=Product(v,CaelumShopProduct.SIMPLE,0,'CaelumCarbineAmmo');
        CaelumCityTradeSession.Open(u,v);Select(u,p.Stock,1);u.ExecutePalomoMerchantTransaction();
        Check(p.Stock.Amount==995,"active clock begins with five missing cartridges");
    }
    void Upgrade385(CaelumPlayer u,bool repeated=false)
    {
        let m=CA385LegacyMark(u.FindInventory("CA385LegacyMark"));Check(m!=null,"depleted legacy sources load in revised runtime");if(m==null)return;
        let v=m.Vendor;double now=CaelumScheduleState.Now(u);
        if(!repeated)Check(v.RestockRevision==0,"legacy stock has no invented historical production agenda");
        v.EnsureStock(u);let p=Product(v,CaelumShopProduct.SIMPLE,0,'CaelumArrowAmmo');
        Check(v.RestockRevision==1 && p.Stock==m.Ammo && p.Stock.Amount==m.Stock && v.WalletCopper==37,"migration keeps native remaining stock and wallet");
        double due=p.NextDue;
        if(!repeated)Check(due==now+p.UnitTics,"first synchronization starts one new period without retroactive output");
        v.EnsureStock(u);Check(p.NextDue==due && p.Stock.Amount==m.Stock,"repeated initialization cannot restart or duplicate production");
        Check(m.Node.ResourceYieldCarry==m.Carry && m.Node.ResourceCalendarId==m.CalendarId,"node fraction and recovery identity survive migration");
        double elapsed=double(CaelumWorldClock.Get(u).CompletedDays)*CaelumWorldClock.TicsPerDay()+CaelumWorldClock.Get(u).DayTics-m.Stamp;
        m.Node.SyncResourceClock();
        double expected=Min(m.Capacity,m.Remaining+elapsed*m.Capacity*CaelumConstants.NATURAL_RESOURCE_RECOVERY_PER_GAME_DAY/CaelumWorldClock.TicsPerDay());
        Check(abs(m.Node.ResourceRemainingUnits-expected)<0.001,"existing node recovers solely from authoritative elapsed clock");
        double remaining=m.Node.ResourceRemainingUnits;m.Node.SyncResourceClock();
        Check(m.Node.ResourceRemainingUnits==remaining,"node repeated synchronization cannot regenerate twice");
        m.Finite.SyncResourceClock();
        Check(m.Finite.ResourceRemainingUnits==17 && m.Finite.ResourceYieldCarry==0.25
            && u.GetPersistentCharacterState(false).MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]==19,"finite salvage and tutorial issuance stay unchanged");
    }
    void Author385(CaelumPlayer u)
    {
        Setup385(u);let ranged=Fresh385(u,2);ranged.SetOrigin((72,0,0),false);
        let library=Fresh385(u,6);library.SetOrigin((72,112,0),false);
        let clothing=Fresh385(u,7);clothing.SetOrigin((72,-112,0),false);
        let tools=Fresh385(u,1);tools.SetOrigin((-72,112,0),false);
        Actor.Spawn("CaelumReadingShelf",(-128,0,0),NO_REPLACE);
        let sign=Actor.Spawn("CaelumShopSign",(72,112,96),NO_REPLACE);sign.frame=6;
        sign=Actor.Spawn("CaelumShopSign",(72,-112,96),NO_REPLACE);sign.frame=7;
        CaelumCityTradeSession.Open(u,ranged);
        Console.Printf("CA385 READY cartridges ahead; library left; clothes right; tools behind left; coins and Box supplied.");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca385_suite"){Setup385(u);Timing(u);BooksAndQuotes(u);Sources(u);NewEquipment(u);Coverage(u);}
        if(e.Name=="ca385_save")Save385(u);
        if(e.Name=="ca385_verify")Verify385(u);
        if(e.Name=="ca385_resume")Verify385(u,true);
        if(e.Name=="ca385_completed")Verify385(u,false,true);
        if(e.Name=="ca385_upgrade")Upgrade385(u);
        if(e.Name=="ca385_upgrade_verify")Upgrade385(u,true);
        if(e.Name=="ca385_author")Author385(u);
        if(e.Name=="ca385_active")Active385(u);
        if(e.Name=="ca385_active_verify")
        {let v=CaelumCityMerchant.Find(2385);Check(v!=null && Product(v,CaelumShopProduct.SIMPLE,0,'CaelumCarbineAmmo').Stock.Amount==1000,"native WorldTick replenishes open trade without input or manual Sync");}
        if(e.Name=="ca385_pause_mark"){Setup385(u);PauseStamp=CaelumScheduleState.Now(u);PauseWall=MSTimeF();}
        if(e.Name=="ca385_pause_verify")Check(MSTimeF()-PauseWall>1000 && CaelumScheduleState.Now(u)-PauseStamp<10,"native paused engine advances wall time without production calendar time");
        if(e.Name=="ca385_day")
        {CaelumWorldClock.Get(u,true).AdvanceTics(CaelumWorldClock.TicsPerDay());CaelumShopRestock.UpdateActive(u);Console.Printf("CA385: +1 dia del calendario de prueba.");}
        if(e.Name=="ca385_perf")
        {
            Setup385(u);double start=MSTimeF();let v=Fresh385(u,6);double seed=MSTimeF()-start;
            for(int i=0;i<v.Products.Size();i++)v.Products[i].Stock.Amount=9;
            start=MSTimeF();CaelumShopRestock.Sync(v,u,true);double arm=MSTimeF()-start;
            CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerDay()*30);
            start=MSTimeF();CaelumShopRestock.Sync(v,u);double catchup=MSTimeF()-start;
            CaelumCityTradeSession.Open(u,v);
            start=MSTimeF();for(int i=0;i<1000;i++)CaelumShopRestock.UpdateActive(u);double idle=(MSTimeF()-start)/1000;
            Console.Printf("CA385 PERF products=%d seed_ms=%.6f arm_all_ms=%.6f catchup_ms=%.6f idle_ms=%.6f",v.Products.Size(),seed,arm,catchup,idle);
            Measuring=true;MeasureTic=level.time;
        }
        if(e.Name.Left(6)=="ca385_")Console.Printf("CA385 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
