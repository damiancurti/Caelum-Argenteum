// Pruebas aisladas de los objetos reales y sus transacciones de produccion.
class CA411CampProof : Inventory
{
    CaelumCampPot Pot;
    CaelumCampTent Tent;
    Default { +INVENTORY.UNDROPPABLE Inventory.MaxAmount 1; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA411CampChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA411 %s camp %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b,double epsilon=0.000001){return Abs(a-b)<epsilon;}
    void Result(){Console.Printf("CA411 RESULT camp passes=%d failures=%d",Passed,Failed);}
    void Setup(CaelumPlayer user)
    {
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvulnerable=true;
        user.SetOrigin((0,-64,0),false);user.Vel=(0,0,0);user.Angle=90;
        CaelumWorldClock.Get(user,true);
        let thermal=CaelumThermalBody.Get(user,true);thermal.Available=true;thermal.AmbientAirC=20;thermal.AmbientWindKmh=0;
    }
    void Material(CaelumPlayer user,int kind,int tier,int amount)
    {
        let item=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,kind,tier);
        if(item==null){item=user.CreateDetachedMaterialStack(kind,tier,amount);item.AttachToOwner(user);}
        item.Amount=amount;item.InMagicBox=false;
    }
    int Count(Actor owner,Name type)
    {int count=0;for(Inventory item=owner.Inv;item!=null;item=item.Inv)if(item.GetClassName()==type)count+=item.Amount;return count;}
    void Select(CaelumPlayer user,Inventory item)
    {
        user.FormalInventoryFilter=0;user.RefreshFormalInventorySnapshot();
        for(int i=0;i<user.FormalInventoryEntryCount;i++)if(user.GetFormalInventoryEntryAt(i)==item){user.FormalInventorySelectionIndex=i;break;}
        user.RefreshFormalInventorySnapshot();
    }
    void Physics(CaelumPlayer user)
    {
        Setup(user);
        Check(Near(CaelumCampPhysics.FuelGrams(3600),1920),"approved wood consumption per hour");
        Check(Near(CaelumCampPhysics.SecondsFromFuel(1920),3600),"fuel and duration inverse");
        let fire=new('CaelumCampFireState');fire.Lit=true;fire.FuelGrams=1920;
        Check(Near(fire.Advance(7200),3600) && !fire.Lit && fire.FuelGrams==0,"large skip burns only available fuel");
        fire.Lit=true;fire.FuelGrams=1000;fire.Advance(60);double fuel=fire.FuelGrams;fire.LeaveMap();fire.Advance(86400);
        Check(!fire.Lit && Near(fire.FuelGrams,fuel),"map departure stops burning and preserves wood");
        Check(CaelumCampData.PotDepth()>0.196 && CaelumCampData.PotDepth()<0.197,"20 L cylindrical interior depth");
        double cooled=CaelumCampPhysics.Cool(100,20,0,600,20);
        Check(cooled>20 && cooled<100,"iron pot cools towards environment");
        Check(CaelumCampPhysics.Cool(100,20,10,600,20)<cooled,"wind accelerates cooling");
        Check(Near(CaelumCampPhysics.Cool(100,20,10,1e12,20),20),"long cooling cannot cross ambient");
        Check(CaelumCampPhysics.BoilingSeconds(20,20)>CaelumCampPhysics.BoilingSeconds(1,20),"heating includes real water and iron capacity");
        Check(Near(CaelumCampPhysics.BoilingSeconds(1,100),60),"hygiene hold remains 60 seconds");
        Check(Near(CaelumCampCrafting.Value(0),53437.5) && Near(CaelumCampCrafting.Value(1),60156.25),"recipe-derived approved base prices");
        Result();
    }
    void Items(CaelumPlayer user)
    {
        Setup(user);
        let first=CaelumCampPot(Actor.Spawn('CaelumCampPot',user.Pos,NO_REPLACE));first.AttachToOwner(user);
        let second=CaelumCampPot(Actor.Spawn('CaelumCampPot',user.Pos,NO_REPLACE));
        Check(second.AddWater(2,CaelumWaterQuality.ALL,75,true),"detached pot accepts known water");
        Actor receiver=user;Check(second.CallTryPickup(receiver),"second pot picked up as individual container");
        let selected=CaelumCampPot(user.FindInventory('CaelumCampPot'));
        Check(Count(user,'CaelumCampPot')==2 && first.WaterLiters==0 && selected!=first,"two independent pot inventories");
        if(selected!=first)
        {
            Check(Near(selected.WaterLiters,2) && selected.WaterQuality==7 && Near(selected.WaterTemperatureC,75),"pickup preserves temperature volume and contamination");
            Check(Near(selected.GetUnitWeight(),7.5) && selected.GetCapacityLiters()==20,"pot weight includes its actual water");
            Check(!selected.AddWater(19,0,20,true) && selected.WaterLiters==2,"overfill rejects atomically");
            let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(200,0,0),NO_REPLACE));
            selected.DetachFromOwner();selected.AttachToOwner(chest);
            Check(CaelumContainerRules.Allowed(user,selected,false),"second pot can be withdrawn despite an existing one");
            selected.DetachFromOwner();selected.AttachToOwner(user);
            Select(user,selected);user.DropFormalInventorySelection();
            Check(Count(user,'CaelumCampPot')==1 && first.Owner==user,"drop targets selected pot rather than first class match");
        }
        let tent=CaelumCampTent(Actor.Spawn('CaelumCampTent',user.Pos,NO_REPLACE));tent.AttachToOwner(user);
        let other=CaelumCampTent(Actor.Spawn('CaelumCampTent',user.Pos,NO_REPLACE));receiver=user;
        Check(other.CallTryPickup(receiver) && Count(user,'CaelumCampTent')==2,"multiple native tents allowed");
        Check(!tent.HandlePickup(tent) && !first.HandlePickup(first),"native pickup never merges camp instances");
        Check(CaelumCityTradeSession.Stack(user,first)==null && CaelumCityTradeSession.Stack(user,tent)==null,"trade keeps camp instances separate");
        Result();
    }
    void Crafting(CaelumPlayer user)
    {
        Setup(user);
        let bench=CaelumCraftingStation(Actor.Spawn('CaelumWorkbenchStation',(0,0,0),NO_REPLACE));
        let sewing=CaelumCraftingStation(Actor.Spawn('CaelumSewingMachineStation',(112,0,0),NO_REPLACE));
        let fine=CaelumCraftingStation(Actor.Spawn('CaelumFineToolsBenchStation',(224,0,0),NO_REPLACE));
        let forge=CaelumCraftingStation(Actor.Spawn('CaelumForgeStation',(0,112,0),NO_REPLACE));
        let anvil=CaelumCraftingStation(Actor.Spawn('CaelumAnvilStation',(112,112,0),NO_REPLACE));
        bench.CraftingRoomGroup=411;sewing.CraftingRoomGroup=411;fine.CraftingRoomGroup=411;forge.CraftingRoomGroup=411;anvil.CraftingRoomGroup=411;
        bench.CollectCraftingNetwork(user,user.BeginCraftingNetworkScan());user.OpenCraftingNetwork(bench);
        let record=user.GetPersistentCharacterState(true);record.LearnCraftingRecipe(198,1);record.RecipeBookVersion=14;
        record.KnownRecipeTiers[201]=7;record.EnsureTierRecipeBook();
        Check(record.RecipeBookVersion==15 && record.KnowsCraftingRecipe(198,1) && !record.KnowsCraftingRecipe(201,1),"migration preserves learned mates and locks appended camp recipes");
        for(int v=0;v<2;v++)
        {
            int recipe=CaelumCampData.FIRST_RECIPE+v;record.LearnCraftingRecipe(recipe,1);
            user.CraftingSelectionRecipe=recipe;user.CraftingSelectionTier=1;
            for(int slot=0;slot<4;slot++)if(CaelumCampData.Grams(v,slot)>0)
                Material(user,CaelumCampData.Material(v,slot),CaelumCampData.MaterialTier(v,slot),30000);
            for(int efficiency=0;efficiency<3;efficiency++)
            {
                user.CraftingEfficiencyIndex=efficiency;user.RefreshCraftingPreview();int factor=efficiency==0?4:efficiency==1?2:1;
                Check(user.CraftingBasicRequired==CaelumCampData.Grams(v,0)*factor
                    && user.CraftingTierRequired==CaelumCampData.Grams(v,1)*factor
                    && user.CraftingSilverRequired==CaelumCampData.Grams(v,2)*factor
                    && user.CraftingGoldRequired==CaelumCampData.Grams(v,3)*factor,"all four inputs follow existing efficiency waste");
            }
            user.CraftingEfficiencyIndex=2;user.RefreshCraftingPreview();user.DerivedStats.CarryCapacity=1000;user.BeginSelectedCraftingTask();
            Check(user.CraftingTaskActive,"native camp craft begins with connected stations");
            if(!user.CraftingTaskActive){Console.Printf("CA411 DETAIL action=%d missing=%d",user.LastCraftingAction,user.CraftingMissingStationType);continue;}
            user.CancelCraftingTask();Check(user.CountRawCraftingMaterial(CaelumCampData.Material(v,0),CaelumCampData.MaterialTier(v,0))==30000,"cancel keeps reserved ingredients");
            user.BeginSelectedCraftingTask();user.CraftingTaskRemainingSeconds=0.000001;user.UpdateCraftingTask();
            Check(Count(user,CaelumCampData.ItemClass(v))==1 && !user.CraftingTaskActive,"native completion creates one camp item");
            for(int slot=0;slot<4;slot++)if(CaelumCampData.Grams(v,slot)>0)
                Check(user.CountRawCraftingMaterial(CaelumCampData.Material(v,slot),CaelumCampData.MaterialTier(v,slot))==30000-CaelumCampData.Grams(v,slot),"completion pays exact authored input once");
            user.DerivedStats.CarryCapacity=1000;user.BeginSelectedCraftingTask();Check(user.CraftingTaskActive,"owning one does not block another camp item");user.CancelCraftingTask();
        }
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);Result();
    }
    void Catalogue(CaelumPlayer user)
    {
        Setup(user);let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,0,0),NO_REPLACE));
        vendor.Category=0;vendor.StockInitialized=true;vendor.CatalogueRevision=1;vendor.RestockRevision=1;
        CaelumCampCatalogue.Ensure(vendor,user);Check(vendor.Products.Size()==2,"two camp products appended to provisions");
        for(int v=0;v<2;v++)
        {
            let p=vendor.Products[v];Check(p.Stock.Amount==3 && p.Recipe==201+v && CaelumShopRestock.Duration(p,user)>0,"three stock with positive recipe replenishment");
            p.Stock.Amount=1;
        }
        vendor.CampCatalogueRevision=0;CaelumCampCatalogue.Ensure(vendor,user);
        Check(vendor.Products.Size()==2 && vendor.Products[0].Stock.Amount==1 && vendor.Products[1].Stock.Amount==1,"retry does not duplicate or refill existing stock");
        let used=CaelumCampPot(Actor.Spawn('CaelumCampPot',user.Pos,NO_REPLACE));used.AddWater(2,7,75,true);used.AttachToOwner(vendor);
        Check(vendor.Accepts(used) && !vendor.Products[1].Matches(used),"used pot never becomes empty stock template");
        let library=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,64,0),NO_REPLACE));
        library.Category=CaelumShopCatalogue.LIBRARY;library.StockInitialized=true;library.CatalogueRevision=1;library.RestockRevision=1;
        CaelumCampCatalogue.Ensure(library,user);
        Check(library.Products.Size()==2 && library.Products[0].Stock.Amount==10 && library.Products[1].Stock.Amount==10,"ten copies of each learned recipe");
        Result();
    }
    void Transfer(CaelumPlayer user)
    {
        Setup(user);CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
        let coins=user.GiveInventoryType('CaelumGoldCoin');coins.Amount=1000;user.OnNativeInventoryChanged();
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,-64,0),NO_REPLACE));vendor.Category=0;vendor.WalletCopper=1000000;
        CaelumMerchantCoordinator.OpenCityTrade(user,vendor);let session=user.CityTrade;
        if(session==null){Check(false,"native provisions session opens");Result();return;}
        Inventory stock=null;
        for(int i=0;i<session.Rows.Size();i++)if(session.Rows[i] is 'CaelumCampPot'){stock=session.Rows[i];session.Selection=i;break;}
        if(stock==null){Check(false,"camp pot listed in native shop");Result();return;}
        session.Refresh(user);session.Execute(user);let pot=CaelumCampPot(user.FindInventory('CaelumCampPot'));
        Check(pot!=null && pot.Amount==1 && stock.Amount==2,"buy one pot from stock of three");
        if(pot==null){Result();return;}
        session.Selection=session.Rows.Find(stock);session.Refresh(user);session.Execute(user);
        Check(Count(user,'CaelumCampPot')==2 && stock.Amount==1,"buy second pot as separate native item");
        pot.InMagicBox=false;pot.AddWater(2,7,75,true);
        user.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;session.Refresh(user);
        session.Selection=session.Rows.Find(pot);session.Refresh(user);session.Execute(user);
        Check(pot.Owner==vendor && Near(pot.WaterLiters,2) && pot.WaterQuality==7 && stock.Amount==1,"sale keeps filled pot separate from empty stock");
        user.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;session.Refresh(user);
        session.Selection=session.Rows.Find(pot);session.Refresh(user);session.Execute(user);
        Check(pot.Owner==user && Near(pot.WaterLiters,2) && pot.WaterQuality==7,"buyback preserves exact pot and water");
        user.ClosePalomoMerchant();Select(user,pot);user.ToggleFormalInventoryStorage();
        Check(pot.InMagicBox && Near(pot.WaterLiters,2),"Box action moves the selected pot");
        user.ToggleFormalInventoryStorage();Check(!pot.InMagicBox,"selected pot returns from Box");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(0,-64,0),NO_REPLACE));chest.ChestUnlocked=true;
        CaelumContainerSession.Open(user,chest);
        Check(CaelumInventoryService.TransferContainerItem(user,chest,pot,1,true) && pot.Owner==chest,"real chest deposit preserves pot identity");
        Check(CaelumInventoryService.TransferContainerItem(user,chest,pot,1,false) && pot.Owner==user
            && Near(pot.WaterLiters,2) && pot.WaterQuality==7,"real withdrawal allows second pot and preserves contents");
        CaelumContainerSession.Get(user).Close();Result();
    }
    CaelumCityMerchant AuthorVendor;
    void Author(CaelumPlayer user)
    {
        Setup(user);CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
        let coins=CaelumCurrencyItem(user.GiveInventoryType('CaelumGoldCoin'));coins.Amount=1000;coins.InMagicBox=true;
        let tent=CaelumCampTent(Actor.Spawn('CaelumCampTent',user.Pos,NO_REPLACE));tent.InMagicBox=true;tent.AttachToOwner(user);
        let pot=CaelumCampPot(Actor.Spawn('CaelumCampPot',user.Pos,NO_REPLACE));pot.AttachToOwner(user);pot.AddWater(2,0,20,true);
        let other=CaelumCampPot(Actor.Spawn('CaelumCampPot',user.Pos,NO_REPLACE));other.InMagicBox=true;other.AttachToOwner(user);other.AddWater(1,7,20,true);
        AuthorVendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,-64,0),NO_REPLACE));AuthorVendor.Category=0;AuthorVendor.WalletCopper=1000000;
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',(160,-64,0),NO_REPLACE));chest.ChestUnlocked=true;
        user.OnNativeInventoryChanged();Select(user,pot);
        Check(tent.Owner==user && pot.Owner==user && other.Owner==user,"author inventory fixture ready");Result();
    }
    void Save(CaelumPlayer user)
    {
        Setup(user);let proof=CA411CampProof(user.GiveInventoryType('CA411CampProof'));
        proof.Pot=CaelumCampPot(Actor.Spawn('CaelumCampPot',user.Pos,NO_REPLACE));proof.Pot.AttachToOwner(user);
        proof.Pot.AddWater(12,7,65,true);
        proof.Tent=CaelumCampTent(Actor.Spawn('CaelumCampTent',user.Pos,NO_REPLACE));proof.Tent.AttachToOwner(user);
        Check(proof.Pot!=null && proof.Tent!=null,"save owns native camp items");Result();
    }
    void Verify(CaelumPlayer user)
    {
        let proof=CA411CampProof(user.FindInventory('CA411CampProof'));
        Check(proof!=null && proof.Tent!=null && proof.Pot!=null,"native save preserves identity references");
        if(proof!=null && proof.Pot!=null)
        {
            Check(proof.Pot.Owner==user && proof.Tent.Owner==user && proof.Pot.Amount==1 && proof.Tent.Amount==1,"save and hub preserve ownership without clones");
            Check(Near(proof.Pot.WaterLiters,12) && proof.Pot.WaterQuality==7 && proof.Pot.WaterTemperatureC>20 && proof.Pot.WaterTemperatureC<=65,"saved water retains volume quality and gradual cooling");
        }
        Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca411_camp_author")Author(user);
        else if(e.Name=="ca411_camp_author_shop" && AuthorVendor!=null)CaelumMerchantCoordinator.OpenCityTrade(user,AuthorVendor);
        else if(e.Name=="ca411_camp_author_close")user.ClosePalomoMerchant();
        else if(e.Name=="ca411_camp_transfer")Transfer(user);
        else if(e.Name=="ca411_camp_physics")Physics(user);
        else if(e.Name=="ca411_camp_items")Items(user);
        else if(e.Name=="ca411_camp_craft")Crafting(user);
        else if(e.Name=="ca411_camp_shop")Catalogue(user);
        else if(e.Name=="ca411_camp_save")Save(user);
        else if(e.Name=="ca411_camp_verify")Verify(user);
    }
}
