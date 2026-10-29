class CA410RestProof : Inventory
{CaelumRestFurnitureItem Item;CaelumRestFurniture Body;CaelumCityMerchant Vendor;CaelumRestFurnitureItem Cot;CaelumRestFurniture CotBody;Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE} States {Spawn:TNT1 A -1;Stop;}}
class CA410RestObstacle : Actor
{Default {Radius 20;Height 80;+SOLID +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA410RestChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410RF %s %s",ok?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA410RF RESULT passed=%d failed=%d",Passed,Failed);}
    bool Near(double a,double b){return Abs(a-b)<.00001;}
    void Profile(CaelumPlayer u)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;u.player.ConversationPC=null;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;u.CombatTimeRemaining=0;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=50;u.Vel=(0,0,0);u.DerivedStats.CarryCapacity=2000;
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
        CaelumRestFurnitureCatalogue.Ensure(v,u);
        Check(v.Products.Size()==CaelumRestFurnitureData.COUNT,"four rest furniture products appended");
        for(int k=0;k<CaelumRestFurnitureData.COUNT;k++)
        {
            let p=v.Products[k];Check(p.Stock.Amount==3 && p.Recipe==CaelumRestFurnitureData.FIRST_RECIPE+k,"three units with appended recipe identity");
            Check(CaelumShopRestock.Duration(p,u)>0 && Near(p.BaseValue,CaelumRestFurnitureCrafting.Value(k)),"price and restock use actual recipe");
            p.Stock.Amount=1;
        }
        v.RestFurnitureRevision=0;CaelumRestFurnitureCatalogue.Ensure(v,u);
        Check(v.Products.Size()==CaelumRestFurnitureData.COUNT && v.Products[0].Stock.Amount==1 && v.Products[1].Stock.Amount==1,"migration retry does not duplicate or refill sold units");
        for(int k=0;k<CaelumRestFurnitureData.COUNT;k++)v.Products[k].NextDue=CaelumScheduleState.Now(u);
        CaelumShopRestock.Sync(v,u,true);
        Check(v.Products[0].Stock.Amount==2 && v.Products[1].Stock.Amount==2,"one elapsed manufacturing cycle replenishes one unit");
        CaelumShopRestock.Sync(v,u,true);
        Check(v.Products[0].Stock.Amount==2 && v.Products[1].Stock.Amount==2,"same instant never produces twice");
        let dirty=CaelumRestFurnitureItem(Actor.Spawn('CaelumLuxuryChairItem'));
        CaelumContaminationStorage.Set(dirty,30);dirty.AttachToOwner(v);
        Check(v.Accepts(dirty) && !v.Products[0].Matches(dirty),"used dirty furniture cannot seed fresh manufactured stock");
        let library=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,128,0)));
        library.Category=CaelumShopCatalogue.LIBRARY;library.StockInitialized=true;library.CatalogueRevision=1;library.RestockRevision=1;
        CaelumRestFurnitureCatalogue.Ensure(library,u);
        Check(library.Products.Size()==CaelumRestFurnitureData.COUNT && library.Products[0].Stock.Amount==10 && library.Products[1].Stock.Amount==10,"library holds ten copies of each recipe");
        let r=u.GetPersistentCharacterState(true);r.LearnCraftingRecipe(CaelumMealData.FIRST_RECIPE,1);r.RecipeBookVersion=18;
        r.KnownRecipeTiers[CaelumRestFurnitureData.FIRST_RECIPE]=7;r.EnsureTierRecipeBook();
        Check(r.RecipeBookVersion==20 && r.KnowsCraftingRecipe(CaelumMealData.FIRST_RECIPE,1)
            && !r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE,1),"revision20 preserves old learning and locks new recipes");
        r.LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE,1);r.RecipeBookVersion=19;
        int newRecipe=CaelumRestFurnitureData.FIRST_RECIPE+2;r.KnownRecipeTiers[newRecipe]=7;r.EnsureTierRecipeBook();
        Check(r.RecipeBookVersion==20 && !r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+2,1),"revision19 appends unknown ordinary furniture");
        Check(r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE,1),"repeated migration preserves newly learned furniture");
    }
    void Craft(CaelumPlayer u)
    {
        Profile(u);u.SetOrigin((0,-64,0),false);
        let bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(0,0,0)));
        let fine=CaelumCraftingStation(Actor.Spawn('CaelumFineToolsBenchStation',(112,0,0)));
        let sewing=CaelumCraftingStation(Actor.Spawn('CaelumSewingMachineStation',(0,112,0)));
        bench.CraftingRoomGroup=410;fine.CraftingRoomGroup=410;sewing.CraftingRoomGroup=410;
        bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(bench);
        for(int v=0;v<CaelumRestFurnitureData.COUNT;v++)
        {
            int recipe=CaelumRestFurnitureData.FIRST_RECIPE+v;
            u.GetPersistentCharacterState(true).LearnCraftingRecipe(recipe,1);u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;
            Material(u,CaelumConstants.MATERIAL_WOOD,1,400000);Material(u,CaelumConstants.MATERIAL_IRON_INGOT,2,10000);Material(u,CaelumConstants.MATERIAL_FABRIC,2,10000);
            for(int e=0;e<3;e++)
            {
                u.CraftingEfficiencyIndex=e;u.RefreshCraftingPreview();int factor=e==0?4:e==1?2:1;
                Check(u.CraftingBasicRequired==CaelumRestFurnitureData.Grams(v,0)*factor
                    && u.CraftingTierRequired==CaelumRestFurnitureData.Grams(v,1)*factor
                    && u.CraftingSilverRequired==CaelumRestFurnitureData.Grams(v,2)*factor && u.CraftingGoldRequired==0,"three construction inputs obey normal waste");
            }
            u.CraftingEfficiencyIndex=2;u.RefreshCraftingPreview();u.DerivedStats.CarryCapacity=2000;u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,"native furniture crafting starts with approved stations");
            if(!u.CraftingTaskActive){Console.Printf("CA410RF DETAIL action=%d station=%d",u.LastCraftingAction,u.CraftingMissingStationType);continue;}
            u.CancelCraftingTask();Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==400000,"cancel releases reservations without spending");
            u.BeginSelectedCraftingTask();u.CraftingTaskRemainingSeconds=.000001;u.UpdateCraftingTask();
            Check(Count(u,CaelumRestFurnitureData.ItemClass(v))==1 && !u.CraftingTaskActive,"native completion creates one physical furniture item");
            Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==400000-CaelumRestFurnitureData.Grams(v,0)
                && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_IRON_INGOT,2)==10000-CaelumRestFurnitureData.Grams(v,1)
                && u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_FABRIC,2)==10000-CaelumRestFurnitureData.Grams(v,2),"completion pays exact materials once");
            u.DerivedStats.CarryCapacity=2000;u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"second same furniture is craftable");u.CancelCraftingTask();
        }
        u.CraftingSelectionRecipe=CaelumRestFurnitureData.FIRST_RECIPE+2;
        u.CraftingNetworkCapabilities &= ~(1 << CaelumConstants.CRAFTING_STATION_SEWING_MACHINE);
        u.RefreshCraftingPreview();
        Check(u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_NONE && u.CraftingSilverRequired==0 && u.CraftingTierRequired==0,"wooden chair needs no textile or sewing machine");
        u.CraftingSelectionRecipe++;u.RefreshCraftingPreview();
        Check(u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_SEWING_MACHINE,"cot textile still requires sewing machine");
        u.CloseCraftingStationSession();u.SetCraftingJournalState(false);
    }
    void Items(CaelumPlayer u)
    {
        Profile(u);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        for(int v=0;v<CaelumRestFurnitureData.COUNT;v++)
        {
            let i=CaelumRestFurnitureItem(Actor.Spawn(CaelumRestFurnitureData.ItemClass(v),u.Pos));i.AttachToOwner(u);
            CaelumContaminationStorage.Set(i,25);Select(u,i);u.DerivedStats.CarryCapacity=2000;
            u.ToggleFormalInventoryStorage();Check(i.InMagicBox && Near(CaelumContaminationStorage.Value(i),25),"selected item enters Box with contamination");
            Select(u,i);u.DerivedStats.CarryCapacity=2000;u.ActivateFormalInventorySelection();Check(!i.InMagicBox,"activate retrieves selected item from Box");
            Check(Near(u.GetFormalInventoryEntryWeight(i),CaelumRestFurnitureData.Mass(v)),"inventory uses full construction mass");
            Check(CaelumCityTradeSession.Stack(u,i)==null && !i.HandlePickup(i),"independent furniture never merges with a duplicate");
            let copy=i.CreateTossable(1);Check(copy!=null && Near(CaelumContaminationStorage.Value(copy),25),"native toss retains contamination");
            Actor receiver=u;u.DerivedStats.CarryCapacity=2000;
            Check(copy!=null && copy.CallTryPickup(receiver),"native pickup recovers dropped furniture");
            Check(Count(u,CaelumRestFurnitureData.ItemClass(v))==1,"drop and pickup conserve exact furniture quantity");
        }
    }
    void Trade(CaelumPlayer u)
    {
        Profile(u);u.SetOrigin((0,-64,0),false);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        u.GiveInventoryType('CaelumGoldCoin').Amount=20000;u.OnNativeInventoryChanged();
        let v=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,0,0)));v.Category=0;v.WalletCopper=10000000;
        CaelumMerchantCoordinator.OpenCityTrade(u,v);let s=u.CityTrade;Check(s!=null,"native Provisions session opens");if(s==null)return;
        for(int k=0;k<CaelumRestFurnitureData.COUNT;k++)
        {
            Inventory stock=null;for(int j=0;j<s.Rows.Size();j++)if(s.Rows[j].GetClassName()==CaelumRestFurnitureData.ItemClass(k)){stock=s.Rows[j];s.Selection=j;break;}
            Check(stock!=null,"furniture appears in real merchant menu");if(stock==null)continue;
            s.Refresh(u);int before=u.GetOwnedMoneyCopperValue(),price=u.PalomoMerchantSelectedLotPrice;u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            let first=u.FindInventory(CaelumRestFurnitureData.ItemClass(k));Check(first!=null && stock.Amount==2,"buy one of three actual stock units");
            Check(u.GetOwnedMoneyCopperValue()==before-price,"purchase pays quoted price exactly once");if(first==null)continue;
            s.Selection=s.Rows.Find(stock);s.Refresh(u);u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            Check(Count(u,CaelumRestFurnitureData.ItemClass(k))==2 && stock.Amount==1,"second purchase retains separate native identity");
            CaelumContaminationStorage.Set(first,35);u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;s.Refresh(u);
            s.Selection=s.Rows.Find(first);s.Refresh(u);u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            Check(first.Owner==v && Near(CaelumContaminationStorage.Value(first),35) && stock.Amount==1,"sale retains original dirt without merging fresh stock");
            if(first.Owner!=v){Console.Printf("CA410RF DETAIL sale action=%d stock=%d",u.LastPalomoMerchantAction,stock.Amount);continue;}
            u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;s.Refresh(u);s.Selection=s.Rows.Find(first);s.Refresh(u);u.DerivedStats.CarryCapacity=2000;s.Execute(u);
            Check(first.Owner==u && Near(CaelumContaminationStorage.Value(first),35),"buyback returns same contaminated furniture");
        }
        u.ClosePalomoMerchant();
    }

    bool FaceClear(CaelumPlayer u,int v)
    {
        double r=CaelumRestFurnitureData.Radius(v),h=CaelumRestFurnitureData.Height(v);
        for(int z=0;z<=136;z+=136)for(int x=-400;x<=400;x+=64)for(int y=160;y<=480;y+=64)
        {
            vector3 target=(x,y,z);u.SetOrigin(target-(u.Radius+r+1,0,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=0;
            if(Abs(u.FloorZ-u.Pos.Z)<=1 && CaelumCampLand.AllowsFurniture(u,target,r)
                && CaelumPlacementGeometry.Fits(u,target,r,h))return true;
        }
        return false;
    }
    void Approach(CaelumPlayer u,CaelumRestFurniture body)
    {u.SetOrigin(body.Pos+(body.Radius+u.Radius+1,0,0),false);u.Angle=180;u.Pitch=0;u.Vel=(0,0,0);u.CombatTimeRemaining=0;}
    void Placement(CaelumPlayer u)
    {
        Profile(u);
        for(int v=0;v<CaelumRestFurnitureData.COUNT;v++)
        {
            let item=CaelumRestFurnitureItem(Actor.Spawn(CaelumRestFurnitureData.ItemClass(v)));item.AttachToOwner(u);
            CaelumContaminationStorage.Set(item,42);Check(FaceClear(u,v),"full-size mansion placement exists");
            vector3 point=u.Pos+(u.Radius+CaelumRestFurnitureData.Radius(v)+1,0,0);
            let obstacle=Actor.Spawn('CA410RestObstacle',point);
            Check(!item.Place(u) && item.Owner==u && item.Body==null,"blocked placement leaves original unplaced item");obstacle.Destroy();
            Check(item.Place(u),"native item places a real furniture actor");let body=item.Body;if(body==null)continue;
            Check(item.Owner==body && body.PackedItem==item && Near(CaelumContaminationStorage.Value(body),42),"placed body owns its title and original contamination state");
            Approach(u,body);Check(CaelumRestState.Begin(u,body.RestMode(),0,body),"placed furniture supports native rest");
            Check(body.Occupant==u && !item.Carry(u),"occupied furniture cannot be picked up");
            let rest=CaelumRestState.Get(u);if(rest!=null)rest.Finish(u,CaelumRestRules.STATUS_CANCELLED,"");
            Approach(u,body);let title=item.LawfulOwner;item.LawfulOwner=null;
            Check(!item.Carry(u) && item.Owner==body,"missing lawful title cannot carry another owner furniture");item.LawfulOwner=title;
            u.DerivedStats.CarryCapacity=0;Check(!item.Carry(u) && item.Owner==body,"insufficient carrying capacity leaves the placed piece");
            u.DerivedStats.CarryCapacity=2000;Check(item.Carry(u),"owner can carry unoccupied furniture");
            Check(item.Owner==u && item.Body==body && body.bInvisible && !body.bSolid,"carrying preserves same body and removes its world collision");
            Check(!CaelumContaminationObject.Eligible(body),"packed body has no second world exposure");
            Check(FaceClear(u,v) && item.Place(u) && item.Body==body,"moving restores same furniture identity");
            Check(Near(CaelumContaminationStorage.Value(body),42),"moving preserves contamination");
            Approach(u,body);u.DerivedStats.CarryCapacity=2000;item.Carry(u);
        }
    }
    void OldSeed(CaelumPlayer u)
    {
        Profile(u);let p=CA410RestProof(Actor.Spawn('CA410RestProof'));p.AttachToOwner(u);
        p.Vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,-128,0)));
        p.Vendor.Category=0;p.Vendor.StockInitialized=true;p.Vendor.CatalogueRevision=1;p.Vendor.RestockRevision=1;
        CaelumRestFurnitureCatalogue.Ensure(p.Vendor,u);
        p.Vendor.Products[0].Stock.Amount=1;p.Vendor.Products[1].Stock.Amount=2;
        u.GetPersistentCharacterState(true).LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE,1);
        u.GetPersistentCharacterState(true).LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+1,1);
        p.Item=CaelumRestFurnitureItem(Actor.Spawn('CaelumLuxuryChairItem'));p.Item.AttachToOwner(u);
        Check(FaceClear(u,0) && p.Item.Place(u),"preceding runtime places actual luxury chair");p.Body=p.Item.Body;
        if(p.Body!=null){CaelumContaminationStorage.Set(p.Body,37);Approach(u,p.Body);u.DerivedStats.CarryCapacity=2000;Check(p.Item.Carry(u),"preceding runtime packs same luxury chair");}
        Check(p.Vendor.RestFurnitureRevision==1 && p.Vendor.Products.Size()==2,"preceding runtime has revision1 supply");
        Check(u.GetPersistentCharacterState(true).RecipeBookVersion==19,"preceding runtime records recipe revision19");
    }
    void OldResume(CaelumPlayer u)
    {
        Profile(u);let p=CA410RestProof(u.FindInventory('CA410RestProof'));
        Check(p!=null && p.Vendor!=null && p.Item!=null && p.Body!=null,"preceding save retains actual merchant and furniture");if(p==null || p.Vendor==null || p.Item==null || p.Body==null)return;
        let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();CaelumRestFurnitureCatalogue.Ensure(p.Vendor,u);
        Check(p.Item.Body==p.Body && p.Body.PackedItem==p.Item && p.Item.Owner==u,"upgrade retains original packed body");
        Check(Near(CaelumContaminationStorage.Value(p.Item),37),"upgrade retains prior dirt");
        Check(r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE,1) && r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+1,1),"both previously learned luxury recipes survive");
        Check(p.Vendor.Products[0].Stock.Amount==1 && p.Vendor.Products[1].Stock.Amount==2,"upgrade does not refill depleted luxury stock");
        Check(p.Vendor.Products.Size()==CaelumRestFurnitureData.COUNT,"upgrade appends only missing products");
        if(CaelumRestFurnitureData.COUNT>2)
        {
            Check(r.RecipeBookVersion==20 && !r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+2,1) && !r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+3,1),"actual revision19 save gains two unknown recipes");
            Check(p.Vendor.Products[2].Stock.Amount==3 && p.Vendor.Products[3].Stock.Amount==3,"actual prior shop appends three of each new item");
            CaelumRestFurnitureCatalogue.Ensure(p.Vendor,u);r.EnsureTierRecipeBook();
            Check(p.Vendor.Products.Size()==4 && p.Vendor.Products[0].Stock.Amount==1,"native save migration is idempotent");
        }
        else Check(r.RecipeBookVersion==19 && p.Vendor.RestFurnitureRevision==1,"untouched original save still loads in original runtime");
        Check(FaceClear(u,0) && p.Item.Place(u) && p.Item.Body==p.Body,"original saved furniture still places");
    }
    void Seed(CaelumPlayer u)
    {
        Profile(u);let proof=CA410RestProof(Actor.Spawn('CA410RestProof'));proof.AttachToOwner(u);
        proof.Item=CaelumRestFurnitureItem(Actor.Spawn(CaelumRestFurnitureData.ItemClass(2)));proof.Item.AttachToOwner(u);
        Check(FaceClear(u,2) && proof.Item.Place(u),"seed places chair");proof.Body=proof.Item.Body;if(proof.Body==null)return;
        CaelumContaminationStorage.Set(proof.Body,37);Approach(u,proof.Body);u.DerivedStats.CarryCapacity=2000;
        Check(proof.Item.Carry(u),"seed carries original chair");
        u.GetPersistentCharacterState(true).LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+2,1);
        proof.Cot=CaelumRestFurnitureItem(Actor.Spawn(CaelumRestFurnitureData.ItemClass(3)));proof.Cot.AttachToOwner(u);
        Check(FaceClear(u,3) && proof.Cot.Place(u),"seed places ordinary cot");proof.CotBody=proof.Cot.Body;
        if(proof.CotBody!=null){CaelumContaminationStorage.Set(proof.CotBody,29);Approach(u,proof.CotBody);u.DerivedStats.CarryCapacity=2000;Check(proof.Cot.Carry(u),"seed packs actual cot");}
    }
    void Resume(CaelumPlayer u)
    {
        Profile(u);let p=CA410RestProof(u.FindInventory('CA410RestProof'));
        Check(p!=null && p.Item!=null && p.Body!=null,"saved furniture references survive");if(p==null || p.Item==null || p.Body==null)return;
        Check(p.Item.Owner==u && p.Item.Body==p.Body && p.Body.PackedItem==p.Item,"save or hub retains original body and carrying owner");
        Check(Near(CaelumContaminationStorage.Value(p.Item),37),"save or hub retains item contamination");
        Check(u.GetPersistentCharacterState(true).KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+2,1),"learned ordinary recipe survives");
        Check(p.Cot!=null && p.CotBody!=null && p.Cot.Owner==u && p.Cot.Body==p.CotBody,"native save/hub retains the same packed cot");
        if(p.Cot!=null)Check(Near(CaelumContaminationStorage.Value(p.Cot),29),"cot contamination survives save/hub");
        Check(FaceClear(u,2) && p.Item.Place(u) && p.Item.Body==p.Body,"saved real body can be placed again");
        Approach(u,p.Body);Check(CaelumRestState.Begin(u,p.Body.RestMode(),0,p.Body),"saved real body remains usable for rest");
    }
    void UseSeed(CaelumPlayer u)
    {
        Seed(u);let p=CA410RestProof(u.FindInventory('CA410RestProof'));if(p==null || p.Body==null)return;
        Check(FaceClear(u,2) && p.Item.Place(u) && p.Item.Owner==p.Body,"native Use fixture starts with placed chair");
        Approach(u,p.Body);u.Pitch=atan2(u.player.viewz-p.Body.Pos.Z-p.Body.Height*.5,p.Body.Radius+u.Radius+1);
    }
    void UseResult(CaelumPlayer u)
    {
        let p=CA410RestProof(u.FindInventory('CA410RestProof'));
        Check(p!=null && p.Item.Owner==u && p.Item.Body==p.Body && p.Body.bInvisible,"native crouch plus Use carries the same chair");
    }
    void Legacy(CaelumPlayer u)
    {
        Profile(u);let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();
        Check(r.RecipeBookVersion==20 && !r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE,1),"old save appends unknown rest furniture recipes");
        let s=CaelumRecipeSession.Get(u);Check(s!=null && s.Book!=null && s.Book.Owner==s.StoredSource && Near(s.RemainingSeconds,321.75),"old saved reading retains original book and progress");
    }
    void View(CaelumPlayer u,int v)
    {
        Profile(u);let item=CaelumRestFurnitureItem(Actor.Spawn(CaelumRestFurnitureData.ItemClass(v)));item.AttachToOwner(u);Select(u,item);u.EquipmentMenuOpen=true;
        Check(u.EquipmentSelectionSpecialType==CaelumRestFurnitureData.FIRST_KEY+v,"native inventory selects furniture identity");
        u.CraftingSelectionRecipe=CaelumRestFurnitureData.FIRST_RECIPE+v;
        Check(u.ResolveCraftingPreviewIconPath()==CaelumRestFurnitureData.Icon(v),"crafting preview uses painted furniture sprite");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410rf_catalogue')Catalogue(u);else if(e.Name=='ca410rf_craft')Craft(u);
        else if(e.Name=='ca410rf_trade')Trade(u);else if(e.Name=='ca410rf_items')Items(u);
        else if(e.Name=='ca410rf_placement')Placement(u);else if(e.Name=='ca410rf_seed')Seed(u);
        else if(e.Name=='ca410rf_resume')Resume(u);else if(e.Name=='ca410rf_legacy')Legacy(u);
        else if(e.Name=='ca410rf_view')View(u,e.Args[0]);
        else if(e.Name=='ca410rf_oldseed')OldSeed(u);else if(e.Name=='ca410rf_oldresume')OldResume(u);else if(e.Name=='ca410rf_use_seed')UseSeed(u);else if(e.Name=='ca410rf_use_result')UseResult(u);else return;
        Result();
    }
}
