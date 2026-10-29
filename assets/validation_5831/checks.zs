class CA410StorageProof : Inventory
{
    CaelumStashChest Body;
    CaelumStorageFurnitureItem Item;
    Inventory Food;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA410StorageObstacle : Actor
{Default {Radius 20;Height 80;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA410StorageChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410SF %s %s",ok?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA410SF RESULT passed=%d failed=%d",Passed,Failed);}
    bool Near(double a,double b){return Abs(a-b)<.00001;}
    void Profile(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;u.CombatTimeRemaining=0;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;u.Vel=(0,0,0);u.DerivedStats.CarryCapacity=2000;
        CaelumWorldClock.Get(u,true);
    }
    void Select(CaelumPlayer u,Inventory item)
    {
        u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        for(int i=0;i<u.FormalInventoryEntryCount;i++)if(u.GetFormalInventoryEntryAt(i)==item){u.FormalInventorySelectionIndex=i;break;}
        u.RefreshFormalInventorySnapshot();
    }
    int Count(Actor owner,Name kind)
    {int count=0;for(Inventory i=owner.Inv;i!=null;i=i.Inv)if(i.GetClassName()==kind)count+=i.Amount;return count;}
    void Material(CaelumPlayer u,int type,int tier,int amount)
    {
        let i=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,type,tier);
        if(i==null){i=u.CreateDetachedMaterialStack(type,tier,amount);i.AttachToOwner(u);}
        i.Amount=amount;i.InMagicBox=false;
    }
    void Catalogue(CaelumPlayer u)
    {
        Profile(u);let v=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,0,0)));
        v.Category=0;v.StockInitialized=true;v.CatalogueRevision=1;v.RestockRevision=1;
        CaelumStorageFurnitureCatalogue.Ensure(v,u);
        Check(v.Products.Size()==2,"two storage furniture products appended");
        for(int k=0;k<2;k++)
        {
            let p=v.Products[k];Check(p.Stock.Amount==3 && p.Recipe==CaelumStorageFurnitureData.FIRST_RECIPE+k,"three units with appended recipe identity");
            Check(CaelumShopRestock.Duration(p,u)>0 && Near(p.BaseValue,CaelumStorageFurnitureCrafting.Value(k)),"price and restock use actual recipe");
            p.Stock.Amount=1;
        }
        v.StorageFurnitureRevision=0;CaelumStorageFurnitureCatalogue.Ensure(v,u);
        Check(v.Products.Size()==2 && v.Products[0].Stock.Amount==1 && v.Products[1].Stock.Amount==1,"migration retry does not duplicate or refill sold units");
        for(int k=0;k<2;k++)v.Products[k].NextDue=CaelumScheduleState.Now(u);
        CaelumShopRestock.Sync(v,u,true);
        Check(v.Products[0].Stock.Amount==2 && v.Products[1].Stock.Amount==2,"one elapsed manufacturing cycle replenishes one unit");
        CaelumShopRestock.Sync(v,u,true);
        Check(v.Products[0].Stock.Amount==2 && v.Products[1].Stock.Amount==2,"same instant never produces twice");
        let dirty=CaelumStorageFurnitureItem(Actor.Spawn('CaelumWardrobeItem'));
        CaelumContaminationStorage.Set(dirty,30);dirty.AttachToOwner(v);
        Check(v.Accepts(dirty) && !v.Products[0].Matches(dirty),"used dirty furniture cannot seed fresh manufactured stock");
        let library=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,128,0)));
        library.Category=CaelumShopCatalogue.LIBRARY;library.StockInitialized=true;library.CatalogueRevision=1;library.RestockRevision=1;
        CaelumStorageFurnitureCatalogue.Ensure(library,u);
        Check(library.Products.Size()==2 && library.Products[0].Stock.Amount==10 && library.Products[1].Stock.Amount==10,"library holds ten copies of each recipe");
        let r=u.GetPersistentCharacterState(true);r.LearnCraftingRecipe(CaelumMealData.FIRST_RECIPE,1);r.RecipeBookVersion=17;
        r.KnownRecipeTiers[CaelumStorageFurnitureData.FIRST_RECIPE]=7;r.EnsureTierRecipeBook();
        Check(r.RecipeBookVersion==18 && r.KnowsCraftingRecipe(CaelumMealData.FIRST_RECIPE,1)
            && !r.KnowsCraftingRecipe(CaelumStorageFurnitureData.FIRST_RECIPE,1),"revision18 preserves old learning and locks new recipes");
        r.LearnCraftingRecipe(CaelumStorageFurnitureData.FIRST_RECIPE,1);r.EnsureTierRecipeBook();
        Check(r.KnowsCraftingRecipe(CaelumStorageFurnitureData.FIRST_RECIPE,1),"repeated migration preserves newly learned furniture");
    }
    void Craft(CaelumPlayer u)
    {
        Profile(u);u.SetOrigin((0,-64,0),false);
        let bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(0,0,0)));
        let fine=CaelumCraftingStation(Actor.Spawn('CaelumFineToolsBenchStation',(112,0,0)));
        bench.CraftingRoomGroup=410;fine.CraftingRoomGroup=410;
        bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(bench);
        Check(CaelumStorageFurnitureCrafting.MissingStation(0)==CaelumConstants.CRAFTING_STATION_WORKBENCH,"missing station is enforced");
        for(int v=0;v<2;v++)
        {
            int recipe=CaelumStorageFurnitureData.FIRST_RECIPE+v;
            u.GetPersistentCharacterState(true).LearnCraftingRecipe(recipe,1);u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;
            Material(u,CaelumConstants.MATERIAL_WOOD,1,400000);Material(u,CaelumConstants.MATERIAL_IRON_INGOT,2,10000);
            for(int e=0;e<3;e++)
            {
                u.CraftingEfficiencyIndex=e;u.RefreshCraftingPreview();int factor=e==0?4:e==1?2:1;
                Check(u.CraftingBasicRequired==CaelumStorageFurnitureData.Grams(v,0)*factor
                    && u.CraftingTierRequired==CaelumStorageFurnitureData.Grams(v,1)*factor
                    && u.CraftingSilverRequired==0 && u.CraftingGoldRequired==0,"both construction inputs obey normal waste");
            }
            u.CraftingEfficiencyIndex=2;u.RefreshCraftingPreview();u.DerivedStats.CarryCapacity=2000;u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,"native furniture crafting starts with approved stations");
            if(!u.CraftingTaskActive){Console.Printf("CA410SF DETAIL action=%d station=%d",u.LastCraftingAction,u.CraftingMissingStationType);continue;}
            u.CancelCraftingTask();Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==400000,"cancel releases reservations without spending");
            u.BeginSelectedCraftingTask();u.CraftingTaskRemainingSeconds=.000001;u.UpdateCraftingTask();
            Check(Count(u,CaelumStorageFurnitureData.ItemClass(v))==1 && !u.CraftingTaskActive,"native completion creates one physical furniture item");
            Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==400000-CaelumStorageFurnitureData.Grams(v,0)
                && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_IRON_INGOT,2)==10000-CaelumStorageFurnitureData.Grams(v,1),"completion pays exact materials once");
            u.DerivedStats.CarryCapacity=2000;u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"second same furniture is craftable");u.CancelCraftingTask();
        }
        u.CloseCraftingStationSession();u.SetCraftingJournalState(false);
    }
    void Items(CaelumPlayer u)
    {
        Profile(u);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        for(int v=0;v<2;v++)
        {
            let i=CaelumStorageFurnitureItem(Actor.Spawn(CaelumStorageFurnitureData.ItemClass(v),u.Pos));i.AttachToOwner(u);
            CaelumContaminationStorage.Set(i,25);Select(u,i);u.DerivedStats.CarryCapacity=2000;
            u.ToggleFormalInventoryStorage();Check(i.InMagicBox && Near(CaelumContaminationStorage.Value(i),25),"selected item enters Box with contamination");
            Select(u,i);u.DerivedStats.CarryCapacity=2000;u.ActivateFormalInventorySelection();Check(!i.InMagicBox,"activate retrieves selected item from Box");
            Check(Near(u.GetFormalInventoryEntryWeight(i),CaelumStorageFurnitureData.Mass(v)),"inventory uses full construction mass");
            Check(CaelumCityTradeSession.Stack(u,i)==null && !i.HandlePickup(i),"independent furniture never merges with a duplicate");
            let copy=i.CreateTossable(1);Check(copy!=null && Near(CaelumContaminationStorage.Value(copy),25),"native toss retains contamination");
            Actor receiver=u;u.DerivedStats.CarryCapacity=2000;
            Check(copy!=null && copy.CallTryPickup(receiver),"native pickup recovers dropped furniture");
            Check(Count(u,CaelumStorageFurnitureData.ItemClass(v))==1,"drop and pickup conserve exact furniture quantity");
        }
    }
    void Trade(CaelumPlayer u)
    {
        Profile(u);u.SetOrigin((0,-64,0),false);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        u.GiveInventoryType('CaelumGoldCoin').Amount=20000;u.OnNativeInventoryChanged();
        let v=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,0,0)));v.Category=0;v.WalletCopper=10000000;
        CaelumMerchantCoordinator.OpenCityTrade(u,v);let s=u.CityTrade;Check(s!=null,"native Provisions session opens");if(s==null)return;
        for(int k=0;k<2;k++)
        {
            Inventory stock=null;for(int j=0;j<s.Rows.Size();j++)if(s.Rows[j].GetClassName()==CaelumStorageFurnitureData.ItemClass(k)){stock=s.Rows[j];s.Selection=j;break;}
            Check(stock!=null,"furniture appears in real merchant menu");if(stock==null)continue;
            s.Refresh(u);int before=u.GetOwnedMoneyCopperValue(),price=u.PalomoMerchantSelectedLotPrice;u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            let first=u.FindInventory(CaelumStorageFurnitureData.ItemClass(k));Check(first!=null && stock.Amount==2,"buy one of three actual stock units");
            Check(u.GetOwnedMoneyCopperValue()==before-price,"purchase pays quoted price exactly once");if(first==null)continue;
            s.Selection=s.Rows.Find(stock);s.Refresh(u);u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            Check(Count(u,CaelumStorageFurnitureData.ItemClass(k))==2 && stock.Amount==1,"second purchase retains separate native identity");
            CaelumContaminationStorage.Set(first,35);u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;s.Refresh(u);
            s.Selection=s.Rows.Find(first);s.Refresh(u);u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            Check(first.Owner==v && Near(CaelumContaminationStorage.Value(first),35) && stock.Amount==1,"sale retains original dirt without merging fresh stock");
            if(first.Owner!=v){Console.Printf("CA410SF DETAIL sale action=%d stock=%d",u.LastPalomoMerchantAction,stock.Amount);continue;}
            u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;s.Refresh(u);s.Selection=s.Rows.Find(first);s.Refresh(u);u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            Check(first.Owner==u && Near(CaelumContaminationStorage.Value(first),35),"buyback returns same contaminated furniture");
        }
        u.ClosePalomoMerchant();
    }
    bool FaceClear(CaelumPlayer u,int variant)
    {
        double radius=variant==0?CaelumWardrobeData.RADIUS:CaelumKitchenFixtureData.CUPBOARD_RADIUS;
        double height=variant==0?CaelumWardrobeData.HEIGHT:CaelumKitchenFixtureData.CUPBOARD_HEIGHT;
        for(int x=-400;x<=-160;x+=32)for(int y=400;y<=480;y+=32)
        {
            vector3 target=(x,y,136);u.SetOrigin(target-(u.Radius+radius+1,0,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=15;u.Vel=(0,0,0);
            if(u.TestMobjLocation() && CaelumCampLand.AllowsFurniture(u,target,radius)
                && CaelumPlacementGeometry.Fits(u,target,radius,height))return true;
        }
        return false;
    }
    CaelumStashChest Place(CaelumPlayer u,int variant)
    {
        let item=CaelumStorageFurnitureItem(Actor.Spawn(CaelumStorageFurnitureData.ItemClass(variant),u.Pos));item.AttachToOwner(u);
        CaelumContaminationStorage.Set(item,42);bool found=FaceClear(u,variant);Check(found,"complete free furniture footprint exists");if(!found)return null;
        double radius=variant==0?CaelumWardrobeData.RADIUS:CaelumKitchenFixtureData.CUPBOARD_RADIUS;
        vector3 target=u.Pos+(u.Radius+radius+1,0,0);
        let obstacle=Actor.Spawn('CA410StorageObstacle',target);
        Check(!item.Place(u) && item.Owner==u && item.Amount==1,"blocked placement retains original item and amount");obstacle.Destroy();
        bool placed=item.Place(u);
        Check(placed && item.bDestroyed,"clear placement consumes the inventory representation once");
        let it=BlockThingsIterator.CreateFromPos(target.X,target.Y,target.Z,1,1,false);CaelumStashChest body;
        while(it.Next())if(it.thing is 'CaelumStashChest' && (it.thing.Pos-target).Length()<1)body=CaelumStashChest(it.thing);
        Check(body!=null && body.IsLawfulOwner(u) && Near(CaelumContaminationStorage.Value(body),42),"placed native owner retains title and contamination");
        return body;
    }
    void Placement(CaelumPlayer u)
    {
        Profile(u);
        for(int v=0;v<2;v++)
        {
            let body=Place(u,v);if(body==null)continue;
            Check(body.CanCarryAsStorage() && body.StorageSlotLimit()==(v==0?25:10) && body.StorageWeightLimit()==(v==0?1000:100),"native storage retains approved limits");
            CaelumContainerSession.Open(u,body);u.DerivedStats.CarryCapacity=2000;let bread=Inventory(Actor.Spawn('CaelumBread'));bread.Amount=2;bread.AttachToOwner(u);
            Check(CaelumInventoryService.TransferContainerItem(u,body,bread,2,true),"new furniture accepts real stored food");CaelumContainerSession.Get(u).Close();
            u.DerivedStats.CarryCapacity=2000;Check(CaelumInventoryService.CarryStorageChest(u,body) && bread.Owner==body,"filled furniture uses existing actual-owner carrier");
            Check(body.TryPlaceStorage(u) && bread.Owner==body && bread.Amount==2,"placing filled carrier preserves exact contents");
            u.DerivedStats.CarryCapacity=2000;Check(CaelumInventoryService.CarryStorageChest(u,body),"packed filled furniture frees the tested footprint");
        }
        let fixed=CaelumKitchenCupboard(ThinkerIterator.Create('CaelumKitchenCupboard').Next());
        Check(fixed!=null && !(fixed is 'CaelumPortableCupboard') && !fixed.CanCarryAsStorage(),"authored fixed kitchen cupboard remains fixed");
    }
    void Seed(CaelumPlayer u)
    {
        Profile(u);let proof=CA410StorageProof(Actor.Spawn('CA410StorageProof'));proof.AttachToOwner(u);
        proof.Body=Place(u,1);if(proof.Body==null)return;
        proof.Food=Inventory(Actor.Spawn('CaelumBread'));proof.Food.Amount=2;proof.Food.AttachToOwner(proof.Body);
        u.DerivedStats.CarryCapacity=2000;Check(CaelumInventoryService.CarryStorageChest(u,proof.Body),"seed carries actual cupboard and contents");
        proof.Item=CaelumStorageFurnitureItem(Actor.Spawn('CaelumWardrobeItem'));proof.Item.AttachToOwner(u);CaelumContaminationStorage.Set(proof.Item,33);
        u.GetPersistentCharacterState(true).LearnCraftingRecipe(CaelumStorageFurnitureData.FIRST_RECIPE,1);
        Check(proof.Item.Owner==u,"seed retains an unplaced independent item");
    }
    void Resume(CaelumPlayer u)
    {
        Profile(u);let p=CA410StorageProof(u.FindInventory('CA410StorageProof'));Check(p!=null,"saved proof exists");if(p==null)return;
        Check(p.Body!=null && p.Body.Cargo!=null && p.Body.Cargo.Owner==u && p.Body.IsLawfulOwner(u),"carried cupboard retains actual native owner and title");
        Check(p.Food!=null && p.Food.Owner==p.Body && p.Food.Amount==2,"carried food identity and amount survive save or hub");
        Check(p.Item!=null && p.Item.Owner==u && Near(CaelumContaminationStorage.Value(p.Item),33),"unplaced furniture retains identity and dirt");
        Check(u.GetPersistentCharacterState(true).KnowsCraftingRecipe(CaelumStorageFurnitureData.FIRST_RECIPE,1),"new recipe learning survives save or hub");
    }
    void Legacy(CaelumPlayer u)
    {
        Profile(u);let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();
        Check(r.RecipeBookVersion==18 && !r.KnowsCraftingRecipe(CaelumStorageFurnitureData.FIRST_RECIPE,1),"old save migrates appended recipes as unknown");
        let reading=CaelumRecipeSession.Get(u);
        Check(reading!=null && reading.Book!=null && reading.Book.Owner==reading.StoredSource && Near(reading.RemainingSeconds,321.75),"original stored-book task and ownership survive");
    }
    void InventoryView(CaelumPlayer u)
    {
        Profile(u);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        for(int v=0;v<2;v++)
        {
            let i=Inventory(Actor.Spawn(CaelumStorageFurnitureData.ItemClass(v)));i.AttachToOwner(u);Select(u,i);
            Check(StringTable.Localize(CaelumStorageFurnitureData.NameKey(v),false)!=CaelumStorageFurnitureData.NameKey(v),"native inventory furniture label is localized");
            u.CraftingSelectionRecipe=CaelumStorageFurnitureData.FIRST_RECIPE+v;
            Check(u.ResolveCraftingPreviewIconPath()==CaelumStorageFurnitureData.Icon(v),"crafting preview resolves the owned furniture sprite");
        }
        u.EquipmentMenuOpen=true;Check(u.FormalInventoryEntryCount>=2,"both furniture items appear in native inventory");
    }
    void ShopView(CaelumPlayer u)
    {
        Profile(u);u.SetOrigin((0,-64,0),false);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,0,0)));vendor.Category=0;
        CaelumMerchantCoordinator.OpenCityTrade(u,vendor);let s=u.CityTrade;
        Check(s!=null,"native merchant presentation opens");if(s==null)return;
        for(int j=0;j<s.Rows.Size();j++)if(s.Rows[j] is 'CaelumWardrobeItem'){s.Selection=j;break;}
        s.Refresh(u);Check(s.Rows[s.Selection] is 'CaelumWardrobeItem',"native shop selects the wardrobe stock");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410sf_catalogue')Catalogue(u);else if(e.Name=='ca410sf_craft')Craft(u);
        else if(e.Name=='ca410sf_items')Items(u);else if(e.Name=='ca410sf_trade')Trade(u);
        else if(e.Name=='ca410sf_placement')Placement(u);else if(e.Name=='ca410sf_seed')Seed(u);
        else if(e.Name=='ca410sf_resume')Resume(u);else if(e.Name=='ca410sf_legacy')Legacy(u);
        else if(e.Name=='ca410sf_inventory')InventoryView(u);
        else if(e.Name=='ca410sf_wardrobe'){Select(u,u.FindInventory('CaelumWardrobeItem'));Check(u.EquipmentSelectionSpecialType==CaelumStorageFurnitureData.FIRST_KEY,"inventory selects the wardrobe icon");}
        else if(e.Name=='ca410sf_shop')ShopView(u);else return;
        Result();
    }
}
