// Pruebas aisladas de comercio; los suministros no entran en la campaña.
class CA383Checkpoint : Inventory
{
    CaelumCityMerchant Vendor;
    CaelumRecipeOffer Offer;
    CaelumRecipeBook Book;
    int Money,Wallet,Pages,Stock;
    Default { +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE Inventory.MaxAmount 1; }
}
class CA383Checks : CA377Checks
{
    bool Measuring,Finished;
    int MeasureTic;
    ui bool Flushed;
    ui double LastFrame;
    ui Array<double> FrameMS;
    int Count(Actor owner)
    {int n=0;for(Inventory i=owner.Inv;i!=null;i=i.Inv)n++;return n;}
    int Pages(CaelumRecipeBook book)
    {int n=0;if(book!=null)for(int i=0;i<CaelumRecipeLearning.SLOT_COUNT;i++)if(book.Sheets[i])n++;return n;}
    CaelumRecipeOffer Offer(CaelumCityMerchant v,int recipe,int tier=1)
    {for(Inventory i=v.Inv;i!=null;i=i.Inv){let o=CaelumRecipeOffer(i);if(o!=null && o.Recipe==recipe && o.Tier==tier)return o;}return null;}
    CaelumCityMerchant Fresh(CaelumPlayer u,int category)
    {let v=Vendor(u,category);v.StockInitialized=false;v.TradesClothing=category==7;v.EnsureStock(u);return v;}
    void Catalogue(CaelumPlayer u)
    {
        let v=Fresh(u,7);Check(Count(v)==125,"25 garments in five sizes, one each");
        bool valid=true;
        for(Inventory i=v.Inv;i!=null;i=i.Inv)
        {let c=CaelumClothingPickup(i);valid=valid && c!=null && c.Amount==1 && c.Tier==1 && c.UnitWeight>0 && c.Durability>0;}
        Check(valid,"all clothing stock initialized with native weight and durability");
        v.EnsureStock(u);Check(Count(v)==125,"clothing reopen does not duplicate");
        let e=CaelumEquipmentItem(v.Inv);e.Durability=17;e.ThermalWaterKg=0.2;
        Money(u);CaelumCityTradeSession.Open(u,v);Check(Select(u,e),"clothing selectable");
        int size=e.EquipmentSize,price=u.PalomoMerchantSelectedLotPrice,money=int(u.GetOwnedMoneyCopperValue());
        u.ExecutePalomoMerchantTransaction();int identity=e.ItemId;
        Check(e.Owner==u && identity>0 && e.EquipmentSize==size && e.Durability==17 && abs(e.ThermalWaterKg-0.2)<0.00001,"clothing exact wet worn instance bought");
        Check(int(u.GetOwnedMoneyCopperValue())==money-price,"clothing single merchant margin");
        Select(u,e,0,true);u.ExecutePalomoMerchantTransaction();
        Check(e.Owner==v && e.ItemId==identity && e.Durability==17,"clothing resale retains identity");
        let p=Fresh(u,0);Check(Count(p)==11,"all eleven provisions and potion variants");
        valid=true;for(Inventory i=p.Inv;i!=null;i=i.Inv)valid=valid && i.Amount==1000;
        Check(valid,"provisions have 1000 initial units");
        u.ClosePalomoMerchant();
        let l=Fresh(u,6);int expected=0;
        for(int recipe=0;recipe<168;recipe++)for(int tier=1;tier<=3;tier++)
            if(CaelumRecipeLearning.Tier(recipe,tier)==tier)
            {
                expected++;let offer=Offer(l,recipe,tier);
                Check(offer!=null && offer.Amount==10 && offer.BaseValue>0,String.Format("library recipe %d tier %d priced stock",recipe,tier));
            }
        Check(Count(l)==expected,"one library offer per valid recipe and tier");
        Check(abs(Offer(l,166).BaseValue-10*CaelumEconomyRules.GetAmmunitionUnitBaseValue(CaelumConstants.AMMUNITION_CARBINE))<0.00001,"carbine book base is ten finished cartridges");
        Check(abs(Offer(l,141).BaseValue-0.1*CaelumClothingData.Value(0,4))<0.00001,"clothing book reference uses XL and ten percent");
        for(int recipe=136;recipe<=140;recipe++)
        {
            int tier=CaelumLockRules.RecipeTier(recipe),item=CaelumLockRules.RecipeItem(recipe);
            double value=CaelumLockRules.Value(item)+(item<3?CaelumLockRules.Value(item+3):0.0);
            Check(abs(Offer(l,recipe,tier).BaseValue-0.1*value)<0.00001,"lock/tool book is equipment-priced, including its key");
            Check(CaelumCraftingBrowser.RecipeName(recipe,tier)==StringTable.Localize(CaelumLockRules.NameKey(item),false),"lock/tool book has correct localized name");
        }
        int count=Count(l),wallet=l.WalletCopper;
        CaelumCityTradeSession.Open(u,l);
        for(int category=0;category<12;category++)
        {
            u.CityTrade.CategoryFilter=category;u.CityTrade.Refresh(u);valid=true;
            for(int row=0;row<u.CityTrade.Rows.Size();row++)valid=valid && CaelumLibrary.MatchesCategory(CaelumRecipeOffer(u.CityTrade.Rows[row]).Recipe,category);
            Check(valid,"category projection only includes matching recipes");
        }
        l.EnsureStock(u);Check(Count(l)==count && l.WalletCopper==wallet,"browse and reopen never restock or credit wallet");
        Check(u.FindInventory("CaelumRecipeBook")==null,"browsing gives no notebook");u.ClosePalomoMerchant();
    }
    void Library(CaelumPlayer u)
    {
        let old=u.FindInventory("CaelumRecipeBook");if(old!=null)old.Destroy();
        let v=Fresh(u,6);Money(u);CaelumCityTradeSession.Open(u,v);
        let offer=Offer(v,0,3);let plan=new("CaelumLibraryPurchase");plan.Build(u,offer);
        int pages=plan.ExtraPages;Check(pages>1,"equipment book includes component sheets");
        let record=u.GetPersistentCharacterState(true);int known=record.KnownRecipeTiers[0];
        Check(Select(u,offer,4),"library offer selectable");Check(u.PalomoMerchantSelectedQuantity==1,"library always buys one book");
        int price=u.PalomoMerchantSelectedLotPrice,money=int(u.GetOwnedMoneyCopperValue()),wallet=v.WalletCopper;
        double carry=u.DerivedStats.CarryCapacity;int slots=u.DerivedStats.MagicBoxCapacity;
        u.DerivedStats.CarryCapacity=0;u.DerivedStats.MagicBoxCapacity=0;u.ExecutePalomoMerchantTransaction();
        Check(u.FindInventory("CaelumRecipeBook")==null && offer.Amount==10 && v.WalletCopper==wallet && int(u.GetOwnedMoneyCopperValue())==money,"no capacity leaves pages, money and stock untouched");
        u.DerivedStats.CarryCapacity=carry;u.DerivedStats.MagicBoxCapacity=slots;
        Money(u,0,0);Select(u,offer);u.ExecutePalomoMerchantTransaction();
        Check(u.FindInventory("CaelumRecipeBook")==null && offer.Amount==10,"no money cannot receive notebook");
        Money(u,10);Select(u,offer);money=int(u.GetOwnedMoneyCopperValue());u.ExecutePalomoMerchantTransaction();
        let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        Check(book!=null && Pages(book)==pages && abs(book.GetUnitWeight()-(0.1+0.005*pages))<0.000001,"first purchase creates 100g binder and exactly five grams per new sheet");
        Check(offer.Amount==9 && int(u.GetOwnedMoneyCopperValue())==money-price && v.WalletCopper==wallet+price,"book purchase pays and decrements once");
        Check(record.KnownRecipeTiers[0]==known && u.FindInventory("CaelumRecipeOffer")==null,"purchase does not teach or give separate offer object");
        if(book==null)return;
        money=int(u.GetOwnedMoneyCopperValue());wallet=v.WalletCopper;Select(u,offer);u.ExecutePalomoMerchantTransaction();
        Check(offer.Amount==9 && int(u.GetOwnedMoneyCopperValue())==money && v.WalletCopper==wallet && Pages(book)==pages,"duplicate purchase rejects atomically");
        Check(u.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_DUPLICATE,"duplicate has specific feedback");
        // Compra parcial: sólo falta una hoja de la receta final.
        book.Sheets[CaelumRecipeLearning.Slot(0,3)]=false;Select(u,offer);u.ExecutePalomoMerchantTransaction();
        Check(Pages(book)==pages && offer.Amount==8 && abs(book.GetUnitWeight()-(0.1+0.005*pages))<0.000001,"overlap adds only missing sheet to same notebook");
        let ammo=Offer(v,166);book.InMagicBox=true;u.OnNativeInventoryChanged();Select(u,ammo);u.ExecutePalomoMerchantTransaction();
        Check(book.InMagicBox && Pages(book)==pages+1 && ammo.Amount==9,"boxed notebook receives sheets in place");
        u.ClosePalomoMerchant();v.EnsureStock(u);Check(offer.Amount==8 && ammo.Amount==9,"library reopen retains depletion");
        // Una cotización de otra sesión no puede entregar hojas ni gastar.
        let stale=u.CityTrade;CaelumCityTradeSession.Open(u,v);stale=u.CityTrade;
        let other=Fresh(u,6);CaelumCityTradeSession.Open(u,other);money=int(u.GetOwnedMoneyCopperValue());
        plan.Build(u,Offer(v,167));let rejected=CaelumInventoryService.CommitLibraryPurchase(u,stale,Offer(v,167),plan,10);
        Check(rejected==null && int(u.GetOwnedMoneyCopperValue())==money && Offer(v,167).Amount==10,"foreign library session cannot transfer");
        u.ClosePalomoMerchant();
    }
    void KitsAndLocks(CaelumPlayer u)
    {
        Money(u);let v=Fresh(u,2);CaelumMaterialPickup carbine=null,shotgun=null;
        for(Inventory i=v.Inv;i!=null;i=i.Inv)
        {let kit=CaelumMaterialPickup(i);if(kit!=null){if(kit.GetSpecialType()==79)carbine=kit;else if(kit.GetSpecialType()==80)shotgun=kit;}}
        Check(carbine!=null && shotgun!=null && carbine.Amount==1000 && shotgun.Amount==1000,"ranged shops stock both thousand-unit sealed kits");
        CaelumCityTradeSession.Open(u,v);Select(u,carbine,1);u.ExecutePalomoMerchantTransaction();
        Select(u,shotgun,1);u.ExecutePalomoMerchantTransaction();
        let ownedCarbine=CaelumCityTradeSession.Stack(u,carbine),ownedShotgun=CaelumCityTradeSession.Stack(u,shotgun);
        Check(ownedCarbine!=null && ownedShotgun!=null && ownedCarbine!=ownedShotgun && ownedCarbine.Amount==5 && ownedShotgun.Amount==5,"split kits retain distinct material identity");
        Select(u,ownedCarbine,0,true);u.ExecutePalomoMerchantTransaction();
        Check(carbine.Amount==996 && shotgun.Amount==995 && ownedCarbine.Amount==4 && ownedShotgun.Amount==5,"kit resale merges only matching material");
        let tierOne=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_LEATHER,1,1);tierOne.AttachToOwner(u);
        let tierTwo=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_LEATHER,2,1);tierTwo.AttachToOwner(u);
        Check(CaelumCityTradeSession.Stack(u,tierOne)==tierOne,"material stack matching also respects tier");
        u.ClosePalomoMerchant();let locks=Fresh(u,1);CaelumCityTradeSession.Open(u,locks);
        for(int type=0;type<3;type++)
        {
            CaelumLockItem item=null;
            for(Inventory i=locks.Inv;i!=null;i=i.Inv){let l=CaelumLockItem(i);if(l!=null && l.LockItemType==type)item=l;}
            let key=CaelumCityTradeSession.Companion(item);Check(item!=null && key!=null,"merchant lock has matching key");
            Check(!Select(u,key),"paired key not sold separately");Select(u,item);
            int price=u.PalomoMerchantSelectedLotPrice,money=int(u.GetOwnedMoneyCopperValue());
            Check(price==CaelumEconomyRules.GetPriceChargedByMerchant(CaelumLockRules.Value(type)+CaelumLockRules.Value(type+3)),"pair has one margin over combined base value");
            if(type==0)
            {
                double carry=u.DerivedStats.CarryCapacity;int slots=u.DerivedStats.MagicBoxCapacity;
                u.DerivedStats.CarryCapacity=0;u.DerivedStats.MagicBoxCapacity=0;u.ExecutePalomoMerchantTransaction();
                Check(item.Owner==locks && key.Owner==locks && int(u.GetOwnedMoneyCopperValue())==money,"full capacity cannot separate lock and key or charge");
                u.DerivedStats.CarryCapacity=carry;u.DerivedStats.MagicBoxCapacity=slots;
                locks.RemoveInventory(key);key.AttachToOwner(u);Select(u,item);u.ExecutePalomoMerchantTransaction();
                Check(item.Owner==locks && int(u.GetOwnedMoneyCopperValue())==money,"missing companion rejects pair sale");
                u.RemoveInventory(key);key.AttachToOwner(locks);Select(u,item);
            }
            u.ExecutePalomoMerchantTransaction();
            Check(item.Owner==u && key.Owner==u && CaelumLockRules.SamePair(item.PairIdentity,key.PairIdentity) && !item.MerchantPairedSale && !key.MerchantPairedSale,"lock and original matched key transfer together");
            Check(int(u.GetOwnedMoneyCopperValue())==money-price,"matched pair charges once");
        }
        u.ClosePalomoMerchant();
    }
    void Save383(CaelumPlayer u)
    {
        Prepare(u);Money(u);let v=Fresh(u,6);v.ShopIdentity=1383;CaelumCityTradeSession.Open(u,v);
        let offer=Offer(v,166);Select(u,offer);u.ExecutePalomoMerchantTransaction();
        let m=CA383Checkpoint(Actor.Spawn("CA383Checkpoint",u.Pos,NO_REPLACE));m.AttachToOwner(u);
        m.Vendor=v;m.Offer=offer;m.Book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        m.Pages=Pages(m.Book);m.Money=int(u.GetOwnedMoneyCopperValue());m.Wallet=v.WalletCopper;m.Stock=offer.Amount;
        u.PersistCharacterState();Check(m.Book!=null && m.Stock==9,"saved purchased notebook and depleted library");
    }
    void Verify383(CaelumPlayer u)
    {
        let m=CA383Checkpoint(u.FindInventory("CA383Checkpoint"));Check(m!=null,"checkpoint survives");if(m==null)return;
        Check(m.Book!=null && m.Book.Owner==u && Pages(m.Book)==m.Pages,"notebook pages survive save and travel");
        Check(int(u.GetOwnedMoneyCopperValue())==m.Money,"saved player money unchanged");
        if(level.MapName=="CLTHQA")
        {
            let v=CaelumCityMerchant.Find(1383);Check(v!=null && v.WalletCopper==m.Wallet,"saved merchant wallet unchanged");
            if(v!=null){v.EnsureStock(u);let offer=Offer(v,166);Check(offer!=null && offer.Amount==m.Stock,"saved catalogue never reseeds depleted books");}
        }
        u.ClosePalomoMerchant();
    }
    void City383(CaelumPlayer u)
    {
        CaelumCityMerchant.Prepare();bool categories[8];int materialized=0;
        for(int i=0;i<64;i++){let v=CaelumCityMerchant.Find(i);if(v!=null){categories[v.Category]=true;if(v.StockInitialized)materialized++;}}
        Check(CaelumCityMerchant.Find(34).Category==6 && CaelumCityMerchant.Find(35).Category==7,"two exact repeated shops replaced");
        bool all=true;for(int i=0;i<8;i++)all=all && categories[i];Check(all,"all eight specializations remain");
        Check(materialized==0,"city setup keeps shop inventories lazy");
        int library=0,clothing=0,total=0;let it=ThinkerIterator.Create("CaelumShopSign");CaelumShopSign sign;
        while((sign=CaelumShopSign(it.Next()))!=null){total++;if(sign.frame==6)library++;if(sign.frame==7)clothing++;}
        Check(total==64 && library==1 && clothing==1,"city has exactly one sign for each new shop");
    }
    void Upgrade383(CaelumPlayer u)
    {
        let m=CA383LegacyMark(u.FindInventory("CA383LegacyMark"));Check(m!=null,"old marker loaded");if(m==null)return;
        // No llamar Prepare: la migración real debe haber corrido al cargar.
        Check(m.Library.Category==6 && m.Clothing.Category==7,"visited MAP03 migrates both categories automatically");
        Check(m.Library.WalletCopper==37 && m.Clothing.WalletCopper==51,"migration retains wallets");
        Check(m.OldItem.Owner==m.Library && m.OldItem.ItemId==m.Identity && m.OldItem.Durability==m.Wear
            && m.OldItem.EquipmentSize==m.Size,"migration retains exact worn sized player-sold item");
        m.Library.EnsureStock(u);m.Clothing.EnsureStock(u);
        Check(Count(m.Clothing)==m.ClothingCount+125,"clothing migration adds only new variants once");
        int books=0;for(Inventory i=m.Library.Inv;i!=null;i=i.Inv)if(i is "CaelumRecipeOffer")books++;
        Check(books>168 && Count(m.Library)==m.LibraryCount+books,"library migration preserves old inventory and adds books");
        Check(m.Library.Accepts(m.OldItem),"converted shop can sell old merchandise");
        m.Library.EnsureStock(u);m.Clothing.EnsureStock(u);
        Check(Count(m.Clothing)==m.ClothingCount+125 && Count(m.Library)==m.LibraryCount+books,"migration is idempotent");
        int signs=0;let it=ThinkerIterator.Create("CaelumShopSign");CaelumShopSign sign;
        while((sign=CaelumShopSign(it.Next()))!=null)if(sign.frame>=6)signs++;
        Check(signs==2,"old map signs migrate without respawn");
    }
    void Author383(CaelumPlayer u)
    {
        Prepare(u);Money(u);let library=Fresh(u,6);library.SetOrigin((72,0,0),false);
        let clothing=Fresh(u,7);clothing.SetOrigin((72,112,0),false);
        let ranged=Fresh(u,2);ranged.SetOrigin((72,-112,0),false);
        let tools=Fresh(u,1);tools.SetOrigin((-72,112,0),false);
        let shelf=Actor.Spawn("CaelumReadingShelf",(-128,0,0),NO_REPLACE);
        let sign=Actor.Spawn("CaelumShopSign",(72,0,96),NO_REPLACE);sign.frame=6;
        sign=Actor.Spawn("CaelumShopSign",(72,112,96),NO_REPLACE);sign.frame=7;
        CaelumCityTradeSession.Open(u,library);
        Console.Printf("CA383 READY four shops, coins, Box and reading shelf; library ahead, clothing left, ranged right, tools behind left.");
    }
    override void WorldTick()
    {
        if(Measuring && !Finished && level.time-MeasureTic>=350)
        {Finished=true;Console.Printf("CA383 PERF END tic=%d ms=%.6f",level.time,MSTimeF());}
    }
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Measuring && !Finished){if(LastFrame>0)FrameMS.Push(now-LastFrame);LastFrame=now;}
        if(Finished && !Flushed){Flushed=true;for(int i=0;i<FrameMS.Size();i++)Console.Printf("CA383 FRAME %.6f",FrameMS[i]);Console.Printf("CA383 FRAMES_END count=%d",FrameMS.Size());}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca383_suite"){Prepare(u);Catalogue(u);Library(u);KitsAndLocks(u);}
        if(e.Name=="ca383_save")Save383(u);
        if(e.Name=="ca383_verify")Verify383(u);
        if(e.Name=="ca383_city")City383(u);
        if(e.Name=="ca383_upgrade")Upgrade383(u);
        if(e.Name=="ca383_author")Author383(u);
        if(e.Name=="ca383_perf")
        {
            Prepare(u);Money(u,10);double start=MSTimeF();let vendor=Fresh(u,6);double seed=MSTimeF()-start;
            start=MSTimeF();CaelumCityTradeSession.Open(u,vendor);double opened=MSTimeF()-start;
            start=MSTimeF();for(int i=0;i<20;i++)u.CityTrade.Refresh(u);double refresh=(MSTimeF()-start)/20;
            Console.Printf("CA383 PERF seed_ms=%.6f open_ms=%.6f refresh_ms=%.6f rows=%d",seed,opened,refresh,u.CityTrade.Rows.Size());
            Measuring=true;MeasureTic=level.time;Console.Printf("CA383 PERF BEGIN tic=%d ms=%.6f",level.time,MSTimeF());
        }
        if(e.Name.Left(6)=="ca383_")Console.Printf("CA383 RESULT passed=%d failed=%d",Passed,Failed);
    }
}

