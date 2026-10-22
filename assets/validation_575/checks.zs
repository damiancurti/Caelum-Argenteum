// Pruebas aisladas: cantidades, avances y objetos de esta sala no son balance.
class CA407Checks : CA407Legacy
{
    CaelumCraftingStation Bench,Alchemy;
    bool Measuring,Finished;
    int MeasureTic;
    ui bool Flushed;
    ui double LastFrame;
    ui Array<double> FrameMS;
    override void WorldLoaded(WorldEvent e){Bench=null;Alchemy=null;}
    override void WorldTick()
    {
        if(Measuring && !Finished && level.time-MeasureTic>=525)
        {Finished=true;Console.Printf("CA407 PERF END tic=%d ms=%.6f",level.time,MSTimeF());}
    }
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(Measuring && !Finished){if(LastFrame>0)FrameMS.Push(now-LastFrame);LastFrame=now;}
        if(Finished && !Flushed){Flushed=true;for(int i=0;i<FrameMS.Size();i++)Console.Printf("CA407 FRAME %.6f",FrameMS[i]);Console.Printf("CA407 FRAMES_END count=%d",FrameMS.Size());}
    }
    void Open(CaelumPlayer u)
    {
        if(Bench==null)
        {
            let it=BlockThingsIterator.Create(u,128);
            while(it.Next())if(it.thing is 'CaelumWorkbenchStation'){Bench=CaelumCraftingStation(it.thing);break;}
        }
        if(Bench==null)return;
        u.CombatTimeRemaining=0;Bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(Bench);
    }
    void Setup(CaelumPlayer u)
    {
        Prepare(u);u.SetOrigin((0,0,0),false);
        Bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(48,0,0),NO_REPLACE));
        Alchemy=CaelumCraftingStation(Actor.Spawn('CaelumAlchemyStation',(48,64,0),NO_REPLACE));
        Open(u);
    }
    CaelumMaterialPickup Material(CaelumPlayer u,int type,int amount)
    {
        let item=u.CreateDetachedMaterialStack(type,1,amount);item.AttachToOwner(u);return item;
    }
    void Select(CaelumPlayer u,int batch=0,int efficiency=2)
    {
        u.CraftingSelectionRecipe=168;u.CraftingSelectionTier=1;u.CraftingEfficiencyIndex=efficiency;
        u.CraftingProcessingBatchIndex=batch;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
    }
    void Contract(CaelumPlayer u)
    {
        Setup(u);let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();r.LearnCraftingRecipe(168,1);
        Check(CaelumConstants.MATERIAL_TYPE_COUNT==89 && CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT==169,"catalogues append two materials and one recipe");
        Check(CaelumCraftingRules.GetComponentRecipeStart()==79 && CaelumConstants.CRAFTING_CARBINE_CARTRIDGE_RECIPE==166 && CaelumConstants.CRAFTING_SHOTGUN_CARTRIDGE_RECIPE==167,"previous recipe IDs unchanged");
        Check(CaelumCraftingRules.FindProcessingRecipeForOutput(88,1)==168 && CaelumCraftingRules.GetUnifiedRecipeKind(168)==CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING,"iodine is ordinary processing with stable tail ID");
        Check(CaelumCraftingRules.GetProcessingInputOneMaterial(168)==87 && CaelumCraftingRules.GetProcessingInputTwoMaterial(168)<0
            && CaelumCraftingRules.GetProcessingInputTwoUnits(168,0)==0,"only dried kelp is consumed; no fuel added");
        for(int batch=0;batch<4;batch++)for(int eff=0;eff<3;eff++)
        {
            Select(u,batch,eff);int scale=CaelumCraftingRules.GetProcessingBatchMultiplier(batch);
            int output=int(scale*(eff==0?.25:eff==1?.5:1.0));
            Check(u.CraftingBasicRequired==100*scale && u.CraftingOutputAmount==output,"approved ratio and inherited integer efficiency across batch sizes");
            double factor=eff==0?1:eff==1?10:100;
            Check(Abs(u.CraftingPreviewSeconds-60.0*scale*factor*100/u.GetCraftingDexterityPercent())<.001,"preview uses authored base work plus learning and dexterity");
        }
        r.RecipePractice[168*3]=1000;Select(u);
        Check(Abs(u.CraftingPreviewSeconds-60*100/u.GetCraftingDexterityPercent())<.001,"mastered nominal batch uses sixty base seconds");
        let quote=new('CaelumRecipeQuote');quote.Build(u,168,1);
        Check(quote.Sheets.Size()==1 && quote.Sheets[0]==504 && quote.OutputUnits==1 && Abs(quote.ManufactureSeconds-60)<.001,"book quote shares recipe and mastered manufacturing time");
        Check(CaelumLibrary.BookValue(u,168,1)==100,"library price inherits ten consumable unit values");
        for(int type=87;type<=88;type++)
        {
            let item=Material(u,type,37);
            Check(item.GetSpecialType()==type && item.GetSpecialTier()==1 && item.GetUnitWeight()==.001,"material identity and gram mass");
            Check(CaelumEconomyRules.GetMaterialUnitBaseValue(type,1)==(type==87?.05:10),"approved base value shared by economy");
            Check(CaelumMaterialPickup.GetMaterialIconPathForType(type)!="" && CaelumDisplayNames.GetSpecialItemKey(CaelumConstants.EQUIPMENT_KIND_MATERIAL,type)!="","material has localized name and icon");
            let drop=CaelumMaterialPickup(item.CreateTossable(11));
            Check(drop!=null && drop.GetSpecialType()==type && drop.Amount==11 && item.Amount==26,"native split drop conserves material");
            if(drop!=null){drop.UpdateMaterialVisuals();Check(drop.sprite==Actor.GetSpriteIndex(String.Format("M%03d",type)),"registered sprite selects 3D material binding");drop.Destroy();}
        }
        Result();
    }
    bool Choose(CaelumPlayer u,Inventory item,bool sell=false)
    {
        u.PalomoMerchantMode=sell?CaelumConstants.PALOMO_MERCHANT_MODE_SELL:CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        u.PalomoMerchantQuantityIndex=0;u.CityTrade.Refresh(u);
        for(int i=0;i<u.CityTrade.Rows.Size();i++)if(u.CityTrade.Rows[i]==item)
        {u.CityTrade.Selection=i;u.CityTrade.Refresh(u);return true;}return false;
    }
    void Reach(CaelumPlayer u,double due)
    {double delta=due-CaelumScheduleState.Now(u);if(delta>0)CaelumWorldClock.Get(u).AdvanceTics(int(Ceil(delta)));}
    void Trade(CaelumPlayer u)
    {
        Prepare(u);let money=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(5),u.Pos,NO_REPLACE));money.Amount=1000;money.AttachToOwner(u);
        u.OnNativeInventoryChanged();let v=Vendor(u,0);let p=Imported(v,87);
        Check(p!=null && p.Stock.Amount==1000 && p.Stock.Owner==v,"provisions seed one kilogram of dried kelp");
        if(p==null){Result();return;}
        int count=v.Products.Size();v.EnsureStock(u);v.EnsureStock(u);
        Check(v.Products.Size()==count && p.Stock.Amount==1000,"reopen cannot duplicate imported stock");
        Check(Imported(Vendor(u,7),87)==null && Imported(Vendor(u,2),87)==null,"kelp limited to provision shops");
        CaelumCityTradeSession.Open(u,v);Check(Choose(u,p.Stock),"ordinary shop lists dried kelp");
        int price=u.PalomoMerchantSelectedLotPrice,owned=int(u.GetOwnedMoneyCopperValue()),wallet=v.WalletCopper,quantity=u.PalomoMerchantSelectedQuantity;
        u.ExecutePalomoMerchantTransaction();let bought=CaelumCityTradeSession.Stack(u,p.Stock);
        Check(bought!=null && bought.Amount==quantity && p.Stock.Amount==1000-quantity,"purchase transfers exact grams once");
        Check(int(u.GetOwnedMoneyCopperValue())==owned-price && v.WalletCopper==wallet+price,"native margins and exact currency settlement");
        if(bought!=null){Check(Choose(u,bought,true),"kelp can be resold at provisions");u.ExecutePalomoMerchantTransaction();Check(p.Stock.Amount==1000,"resale restores exact grams");}
        u.ClosePalomoMerchant();p.Stock.Amount=998;CaelumShopRestock.Sync(v,u,true);
        double due=p.NextDue;wallet=v.WalletCopper;
        Check(Abs(p.UnitTics-CaelumWorldClock.TicsPerDay())<.001,"one gram renews per game day");
        Reach(u,due-1);CaelumShopRestock.Sync(v,u);Check(p.Stock.Amount==998,"no early replenishment");
        Reach(u,due);CaelumShopRestock.Sync(v,u);Check(p.Stock.Amount==999,"exact due replenishes one gram");
        CaelumShopRestock.Sync(v,u);v.EnsureStock(u);Check(p.Stock.Amount==999,"same timestamp and reinitialization cannot repeat credit");
        Reach(u,due+CaelumWorldClock.TicsPerDay()*10);CaelumShopRestock.Sync(v,u);
        Check(p.Stock.Amount==1000 && p.NextDue<0 && v.WalletCopper==wallet,"long absence caps stock without replenishing money");
        let library=Vendor(u,6);let book=Book(library,168);
        Check(book!=null && book.Stock.Amount==10 && book.BaseValue==100,"ordinary library provides new recipe using existing stock and price policy");
        CaelumCityTradeSession.Open(u,library);Check(Choose(u,book.Stock),"iodine manual is selectable");u.ExecutePalomoMerchantTransaction();
        let pages=CaelumRecipeBook(u.FindInventory('CaelumRecipeBook'));
        Check(pages!=null && pages.Sheets[504] && book.Stock.Amount==9,"purchase delivers physical iodine sheet exactly once");
        u.ClosePalomoMerchant();Actor.Spawn('CaelumReadingShelf',u.Pos+(48,0,0),NO_REPLACE);
        CaelumRecipeSession.OpenBook(u,pages);let session=CaelumRecipeSession(u.FindInventory('CaelumRecipeSession'));
        if(session!=null)
        {
            for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i]==504)session.Selection=i;
            Check(session.Start(),"new sheet can be studied at existing reading furniture");
            session.RemainingSeconds=0;session.Complete();Check(u.GetPersistentCharacterState(true).KnowsCraftingRecipe(168,1),"completed reading learns iodine recipe");
        }
        else Check(false,"recipe study session exists");
        Result();
    }
    void Craft(CaelumPlayer u)
    {
        Setup(u);let raw=Material(u,87,10000);raw.InMagicBox=true;u.OnNativeInventoryChanged();
        let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();Select(u);
        u.BeginSelectedCraftingTask();Check(!u.CraftingTaskActive && raw.Amount==10000,"unlearned recipe cannot consume kelp");
        r.LearnCraftingRecipe(168,1);Alchemy.SetOrigin((500,500,0),false);Open(u);Select(u);
        u.BeginSelectedCraftingTask();Check(!u.CraftingTaskActive && u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_ALCHEMY,"workbench without Alchemy cannot process iodine");
        Alchemy.SetOrigin((48,64,0),false);Open(u);
        for(int eff=0;eff<2;eff++)
        {Select(u,0,eff);u.BeginSelectedCraftingTask();Check(!u.CraftingTaskActive && raw.Amount==10000 && u.GetCraftingTaskReservedUnitTotal()==0,"zero whole-gram yield is rejected before reservation");u.CancelCraftingTask();}
        for(int eff=0;eff<3;eff++)
        {
            Open(u);Select(u,1,eff);int before=raw.Amount,output=u.CountCraftingMaterial(88,1),yield=eff==0?2:eff==1?5:10;
            u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive && u.GetCraftingTaskReservedUnitTotal()==1000,"selected batch reserves only one thousand grams of kelp");
            u.CancelCraftingTask();Check(raw.Amount==before && u.CountCraftingMaterial(88,1)==output,"cancel leaves inputs and outputs unchanged");
            Open(u);Select(u,1,eff);u.BeginSelectedCraftingTask();u.CompleteCraftingTask();
            Check(!u.CraftingTaskActive && raw.Amount==before-1000 && u.CountCraftingMaterial(88,1)==output+yield,"completion consumes once and yields inherited efficiency result");
            u.CompleteCraftingTask();Check(raw.Amount==before-1000 && u.CountCraftingMaterial(88,1)==output+yield,"repeated completion cannot duplicate iodine");
        }
        Check(r.RecipePractice[504]==17,"practice records only real produced grams");Result();
    }
    void Storage(CaelumPlayer u)
    {
        Prepare(u);let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(48,0,0),NO_REPLACE));chest.EnsureStorage();chest.StorageTier=1;chest.ApplyStorageSize();CaelumContainerSession.Open(u,chest);
        for(int type=87;type<=88;type++)
        {
            let item=Material(u,type,37);u.OnNativeInventoryChanged();
            Check(CaelumInventoryService.TransferContainerItem(u,chest,item,37,true) && item.Owner==chest,"marine material enters native chest");
            Check(CaelumInventoryService.TransferContainerItem(u,chest,item,37,false) && item.Owner==u && item.Amount==37,"chest withdrawal preserves identity and units");
            item.InMagicBox=true;u.OnNativeInventoryChanged();Check(u.CountCraftingMaterial(type,1)==37,"boxed marine material available for crafting");
        }
        Result();
    }
    void Upgrade(CaelumPlayer u)
    {
        let m=CA407Mark(u.FindInventory('CA407Mark'));Check(m!=null,"old native save checkpoint loaded");if(m==null){Result();return;}
        let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();
        Check(r.RecipeBookVersion==12 && r.MarineMaterialSchemaRevision==1,"new state migrated with explicit revisions");
        Check(r.MainM00SupplyIssued[86]==17 && r.MainM00SupplyLimit[81]==23 && r.MainM00SupplyIssued[87]==0 && r.MainM00SupplyIssued[88]==0,"old arrays preserved and new material slots empty");
        Check(r.KnowsCraftingRecipe(166,1) && r.KnowsCraftingRecipe(167,1) && r.RecipeRereadings[498]==7 && r.RecipePractice[501]==123,"old recipes and mastery survive expansion");
        Check(!r.KnowsCraftingRecipe(168,1) && r.RecipePractice[504]==0 && r.PendingRecipeSheets[168]==0,"new recipe remains unlearned without unapproved entitlement");
        m.Vendor.EnsureStock(u);m.Library.EnsureStock(u);
        Check(m.Existing.Stock.Amount==777 && m.Existing.NextDue==m.Due && m.Vendor.WalletCopper==m.Wallet,"migration preserves existing import queue stock and wallet");
        Check(m.Vendor.Products.Size()==m.Products+1 && m.Library.Products.Size()==m.Books+1,"legacy provision and library append exactly one product");
        Check(Imported(m.Vendor,87).Stock.Amount==1000 && Book(m.Library,168).Stock.Amount==10 && Book(m.Library,166).Stock.Amount==7,"new stocks initialized without resetting purchased older books");
        m.Vendor.EnsureStock(u);m.Library.EnsureStock(u);r.EnsureMarineMaterialSchema();r.EnsureTierRecipeBook();
        Check(m.Vendor.Products.Size()==m.Products+1 && m.Library.Products.Size()==m.Books+1 && r.RecipePractice[501]==123,"repeated migrations are idempotent");Result();
    }
    void Save(CaelumPlayer u)
    {
        Prepare(u);let m=CA407Mark(u.GiveInventoryType('CA407Mark'));m.Vendor=Vendor(u,0);m.Vendor.ShopIdentity=9407;
        let p=Imported(m.Vendor,87);p.Stock.Amount=777;CaelumShopRestock.Sync(m.Vendor,u,true);m.Due=p.NextDue;m.Wallet=m.Vendor.WalletCopper;
        Material(u,87,123).InMagicBox=true;Material(u,88,17).InMagicBox=true;u.PersistCharacterState();Verify(u);
    }
    void Verify(CaelumPlayer u)
    {
        InventoryCheck(u);let m=CA407Mark(u.FindInventory('CA407Mark'));
        let it=ThinkerIterator.Create('CaelumCityMerchant');CaelumCityMerchant v;
        while((v=CaelumCityMerchant(it.Next()))!=null)if(v.ShopIdentity==9407)m.Vendor=v;
        let p=Imported(m.Vendor,87);m.Vendor.EnsureStock(u);
        Check(p.Stock.Amount==777 && p.NextDue==m.Due && m.Vendor.WalletCopper==m.Wallet,"saved import stock deadline and wallet survive reload or hub return");Result();
    }
    void InventoryCheck(CaelumPlayer u)
    {Check(u.CountCraftingMaterial(87,1)==123 && u.CountCraftingMaterial(88,1)==17,"boxed kelp and iodine survive save and map travel");}
    void TaskSave(CaelumPlayer u)
    {
        Setup(u);Material(u,87,1000).InMagicBox=true;u.GetPersistentCharacterState(true).LearnCraftingRecipe(168,1);u.OnNativeInventoryChanged();
        Select(u);u.BeginSelectedCraftingTask();let m=CA407Mark(u.GiveInventoryType('CA407Mark'));m.Seconds=u.CraftingTaskTotalSeconds;
        Check(u.CraftingTaskActive && u.CraftingTaskRecipeIndex==168,"new task starts before save");u.PersistCharacterState();Result();
    }
    void TaskLoad(CaelumPlayer u)
    {
        let m=CA407Mark(u.FindInventory('CA407Mark'));
        Check(m!=null && u.CraftingTaskActive && u.CraftingTaskRecipeIndex==168 && u.CraftingTaskTotalSeconds==m.Seconds,"saved iodine task preserves identity and time");
        u.CompleteCraftingTask();Check(u.CountCraftingMaterial(87,1)==900 && u.CountCraftingMaterial(88,1)==1,"resumed task produces exactly one gram once");
        u.CompleteCraftingTask();Check(u.CountCraftingMaterial(87,1)==900 && u.CountCraftingMaterial(88,1)==1,"second completion after resume cannot duplicate");Result();
    }
    void Gallery(CaelumPlayer u)
    {
        Prepare(u);u.SetOrigin((0,0,0),false);u.Angle=0;u.Pitch=25;
        for(int type=87;type<=88;type++)
        {let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',(80,(type-87)*32-16,0),NO_REPLACE));item.args[0]=type;item.args[1]=1;item.Amount=100;item.UpdateMaterialVisuals();}
        Check(true,"two 3D material drops placed for visible review");Result();
    }
    void Campaign(CaelumPlayer u)
    {
        Prepare(u);int provision=0,library=0;let it=ThinkerIterator.Create('CaelumCityMerchant');CaelumCityMerchant v;
        while((v=CaelumCityMerchant(it.Next()))!=null)
        {
            if(v.Category==0){v.EnsureStock(u);if(Imported(v,87)!=null)provision++;}
            if(v.Category==6){v.EnsureStock(u);if(Book(v,168)!=null)library++;}
        }
        Check(provision>0 && library>0,"real MAP03 provision shops and library expose approved routes");Result();
    }
    void Author(CaelumPlayer u)
    {
        Setup(u);let m=CA407Mark(u.GiveInventoryType('CA407Mark'));
        m.Vendor=Vendor(u,0);m.Vendor.SetOrigin((-48,0,0),false);
        Material(u,87,1000);let money=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(5),u.Pos,NO_REPLACE));money.Amount=10;money.AttachToOwner(u);
        let r=u.GetPersistentCharacterState(true);r.LearnCraftingRecipe(168,1);r.RecipePractice[504]=1000;
        u.OnNativeInventoryChanged();Select(u);u.CloseCraftingStationSession();u.SetCraftingJournalState(false);u.Angle=0;u.Pitch=0;
        for(int type=87;type<=88;type++)
        {let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',(128,(type-87)*32-16,0),NO_REPLACE));item.args[0]=type;item.args[1]=1;item.Amount=1;item.UpdateMaterialVisuals();}
        Check(u.CountCraftingMaterial(87,1)==1000 && r.KnowsCraftingRecipe(168,1),"author scene supplies isolated kelp and learned recipe");Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca407_contract")Contract(u);if(e.Name=="ca407_trade")Trade(u);
        if(e.Name=="ca407_craft")Craft(u);if(e.Name=="ca407_storage")Storage(u);
        if(e.Name=="ca407_upgrade")Upgrade(u);if(e.Name=="ca407_save")Save(u);
        if(e.Name=="ca407_verify")Verify(u);if(e.Name=="ca407_inventory"){InventoryCheck(u);Result();}
        if(e.Name=="ca407_task_save")TaskSave(u);if(e.Name=="ca407_task_load")TaskLoad(u);
        if(e.Name=="ca407_gallery")Gallery(u);
        if(e.Name=="ca407_side"){u.SetOrigin((80,-80,0),false);u.Angle=90;u.Pitch=25;}
        if(e.Name=="ca407_campaign")Campaign(u);
        if(e.Name=="ca407_author")Author(u);
        if(e.Name=="ca407_shop")
        {let m=CA407Mark(u.FindInventory('CA407Mark'));u.SetOrigin((0,0,0),false);CaelumCityTradeSession.Open(u,m.Vendor);Choose(u,Imported(m.Vendor,87).Stock);}
        if(e.Name=="ca407_alchemy")
        {u.ClosePalomoMerchant();u.SetOrigin((0,0,0),false);Open(u);Select(u);}
        if(e.Name=="ca407_fast")CaelumCraftingCoordinator.AdvanceDebugCraftingTime(u);
        if(e.Name=="ca407_use")
        {Check(u.CraftingMenuOpen && u.CraftingSelectionRecipe==168,"real Use opens the learned iodine recipe in author scene");Result();}
        if(e.Name=="ca407_live")
        {Setup(u);Material(u,87,100);u.GetPersistentCharacterState(true).LearnCraftingRecipe(168,1);u.GetPersistentCharacterState(true).RecipePractice[504]=1000;u.OnNativeInventoryChanged();Select(u);u.BeginSelectedCraftingTask();Console.Printf("CA407 LIVE duration=%.6f",u.CraftingTaskTotalSeconds);}
        if(e.Name=="ca407_live_verify")
        {Check(!u.CraftingTaskActive && u.CountCraftingMaterial(87,1)==0 && u.CountCraftingMaterial(88,1)==1,"unpaused native task finishes through normal ticking exactly once");Result();}
        if(e.Name=="ca407_perf")
        {Gallery(u);Measuring=true;MeasureTic=level.time;Console.Printf("CA407 PERF BEGIN tic=%d ms=%.6f",level.time,MSTimeF());}
    }
}
