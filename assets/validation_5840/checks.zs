class CA410DiningProof : Inventory
{
    CaelumDiningSetItem Sets[4];CaelumPortableDiningTable Tables[4];
    CaelumConsumableItem Foods[4];CaelumWaterContainer Waters[4];CaelumRestChair Seats[48];
    CaelumStashChest Chest;CaelumChestCargo Cargo;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA410DiningChecks : CA410RestChecks
{
    CA410DiningProof Proof(CaelumPlayer u,bool create=false)
    {let p=CA410DiningProof(u.FindInventory('CA410DiningProof'));if(p==null && create){p=CA410DiningProof(Actor.Spawn('CA410DiningProof'));p.AttachToOwner(u);}return p;}
    bool PlaceSet(CaelumPlayer u,CaelumDiningSetItem item)
    {
        double r=CaelumRestFurnitureData.Radius(item.Variant()),h=CaelumRestFurnitureData.Height(item.Variant());
        for(int z=0;z<=136;z+=136)for(int x=-400;x<=400;x+=64)for(int y=160;y<=640;y+=64)
        {
            vector3 target=(x,y,z);u.SetOrigin(target-(u.Radius+r+1,0,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            if(Abs(u.FloorZ-u.Pos.Z)<=1 && CaelumCampLand.AllowsFurniture(u,target,r)
                && CaelumPlacementGeometry.Fits(u,target,r,h,item.Table) && item.Place(u))return true;
        }
        return false;
    }
    void ApproachTable(CaelumPlayer u,CaelumPortableDiningTable t)
    {u.SetOrigin(t.LocalPoint(0,-t.WidthMU()/2-2*CaelumDiningSetData.ChairRadius(t.Kind())-u.Radius-1),false);u.FindFloorCeiling();u.Angle=t.Angle+90;u.Pitch=0;u.Vel=(0,0,0);u.DerivedStats.CarryCapacity=10000;}
    void DiningSeed(CaelumPlayer u)
    {
        Profile(u);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);let p=Proof(u,true);
        for(int k=0;k<4;k++)
        {
            let item=CaelumDiningSetItem(Actor.Spawn(CaelumDiningSetData.ItemClass(k)));item.AttachToOwner(u);p.Sets[k]=item;
            Check(Near(item.GetUnitWeight(),CaelumDiningSetData.Mass(k)),"empty mass includes actual chairs");
            Check(PlaceSet(u,item),"set deploys through production land/volume checks");if(item.Table==null || item.Owner!=item.Table)continue;
            let t=item.Table;p.Tables[k]=t;t.ChangeTid(7000+k);
            Check(t.LayoutFits() && t.HasSeatLayout(t.SeatCount()),"full physical layout and seat count valid");
            Check(t.Capacity()==CaelumDiningSetData.Capacity(k) && t.FreeSlot()==0,"new set starts with approved empty capacity");
            for(int s=0;s<t.SeatCount();s++)
            {
                p.Seats[k*12+s]=t.Chairs[s];t.Chairs[s].ChangeTid(7100+k*12+s);Check(t.Chairs[s].DiningTable==t,"chair belongs to same table");
                let chair=t.Chairs[s];u.SetOrigin(chair.Pos+(Cos(chair.Angle),Sin(chair.Angle),0)*(chair.Radius+u.Radius+1),false);u.FindFloorCeiling();
                vector3 entry=u.Pos;bool seated=chair.Seat(u);Check(seated,"native full-size body can occupy this chair");
                if(!seated)Console.Printf("CA410DS DETAIL kind=%d seat=%d reach=%d userRadius=%f gap=%f",k,s,chair.CanReach(u),u.Radius,CaelumDiningSetData.SeatClearance(k));
                vector3 toward=t.Pos-t.Chairs[s].Pos;double facing=t.Chairs[s].PoseAngle();
                Check(toward.X*Cos(facing)+toward.Y*Sin(facing)>0,"seated posture faces the table");
                t.Chairs[s].Release(u,entry);
            }
            let product=new('CaelumShopProduct');product.Kind=CaelumShopProduct.SIMPLE;product.NativeClass=item.GetClassName();
            Check(!product.Matches(item),"deployed assembly cannot merge into anonymous manufactured stock");
            let food=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation'));food.Amount=3;food.AttachToOwner(t);t.Items[0]=food;p.Foods[k]=food;
            let lots=CaelumFoodInventory.Prepare(food);lots.Exposure=40;CaelumFoodClock.Get(food).Advance();
            let water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge'));water.AttachToOwner(t);t.Items[1]=water;p.Waters[k]=water;
            water.AddWater(.75,CaelumWaterQuality.BIOLOGICAL,73.25,true);
            food.ChangeTid(7200+k);water.ChangeTid(7300+k);t.RefreshDisplays();
            t.RestockMansion();Check(t.Items[2]==null && Near(water.WaterLiters,.75),"portable table neither creates food nor refills bottles in mansion");
            Check(Near(item.GetUnitWeight(),CaelumDiningSetData.Mass(k)+food.GetUnitWeight()*3+water.GetUnitWeight()),"packed mass sums exact real contents");
            ApproachTable(u,t);t.Chairs[0].Occupant=u;
            Check(!item.Carry(u),"occupied chair prevents carrying entire set");t.Chairs[0].Occupant=null;
            u.DerivedStats.CarryCapacity=.001;Check(!item.Carry(u),"insufficient capacity rejects pickup");u.DerivedStats.CarryCapacity=10000;
            CaelumContaminationStorage.Set(t,33);CaelumContaminationStorage.Set(t.Chairs[0],44);
            Check(item.Carry(u) && item.Owner==u && t.Packed(),"carry retains table and cargo");
            Check(food.Owner==t && water.Owner==t && food.Amount==3 && Near(water.WaterTemperatureC,73.25),"packing retains real food and warm bottle");
            Check(!CaelumContaminationObject.Eligible(t.Chairs[0]) && !t.Chairs[0].bSolid && t.Chairs[0].bInvisible,"packed seats have no world collision or exposure");
            Check(CaelumFoodClock.Get(food).Location()==u,"packed food uses carrier climate");
            Select(u,item);u.DerivedStats.CarryCapacity=10000;u.ToggleFormalInventoryStorage();Check(item.InMagicBox,"complete loaded set enters Box");
            Select(u,item);u.DerivedStats.CarryCapacity=10000;u.ActivateFormalInventorySelection();Check(!item.InMagicBox,"Box retrieval keeps set identity");
            Check(PlaceSet(u,item) && item.Table==t && t.Items[0]==food && t.Items[1]==water,"redeployment retains same objects and lots");
            Check(Near(CaelumContaminationStorage.Value(t),33) && Near(CaelumContaminationStorage.Value(t.Chairs[0]),44),"set and individual chair contamination preserved");
            ApproachTable(u,t);Check(item.Carry(u),"set ready for native save/hub travel");
        }
    }
    void DiningResume(CaelumPlayer u)
    {
        Profile(u);let p=Proof(u);Check(p!=null,"proof survives save/hub");if(p==null)return;
        for(int k=0;k<4;k++)
        {
            let item=p.Sets[k];let t=p.Tables[k];let food=p.Foods[k];let water=p.Waters[k];
            Check(item!=null && t!=null && item.Table==t && item.Owner==u,"native set identity persists");if(item==null || t==null)continue;
            Check(t.TID==7000+k && food.TID==7200+k && water.TID==7300+k,"table and cargo TIDs persist");
            Check(food.Owner==t && water.Owner==t && food.Amount==3 && Near(water.WaterLiters,.75),"actual food quantity and water volume persist");
            Check(water.WaterQuality==CaelumWaterQuality.BIOLOGICAL && water.WaterTemperatureC>0 && water.WaterTemperatureC<=73.25,"water quality and cooling state persist");
            let clock=CaelumFoodClock.Get(food);CaelumFoodInventory.Reconcile(food);
            Check(clock!=null && clock.Item==food && clock.Location()==u && food.FoodLots.OldestContamination()>=40,"food age clock survives with same lots");
            Check(PlaceSet(u,item),"travelled layout redeploys safely");
            for(int s=0;s<t.SeatCount();s++)Check(t.Chairs[s]==p.Seats[k*12+s] && t.Chairs[s].TID==7100+k*12+s && t.Chairs[s].DiningTable==t,"same chair and linkage survive");
            ApproachTable(u,t);Check(item.Carry(u),"loaded set remains movable after return");
        }
    }
    void Migration(CaelumPlayer u)
    {
        Profile(u);let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();
        for(int k=0;k<8;k++)r.LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1);
        r.RecipeBookVersion=22;r.KnownRecipeTiers[CaelumRestFurnitureData.FIRST_RECIPE+8]=7;r.EnsureTierRecipeBook();
        Check(r.RecipeBookVersion==23,"recipe revision advances once");
        for(int k=0;k<8;k++)Check(r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1),"earlier furniture learning retained");
        for(int k=8;k<12;k++)Check(!r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+k,1),"new dining recipes remain unlearned");
        r.LearnCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+8,1);r.EnsureTierRecipeBook();Check(r.KnowsCraftingRecipe(CaelumRestFurnitureData.FIRST_RECIPE+8,1),"migration does not erase new learning on retry");
    }
    void Nested(CaelumPlayer u)
    {
        DiningSeed(u);let p=Proof(u);if(p==null)return;
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(64,0,0)));p.Chest=chest;chest.args[4]=3;chest.EnsureStorage();
        chest.GrantLawfulTitle(u);CaelumContainerSession.Open(u,chest);u.DerivedStats.CarryCapacity=10000;
        Check(CaelumInventoryService.TransferContainerItem(u,chest,p.Sets[0],1,true),"normal storage puts loaded dining set into chest");
        CaelumContainerSession.Get(u).Close();u.DerivedStats.CarryCapacity=10000;
        Check(CaelumInventoryService.CarryStorageChest(u,chest),"carry chest containing actual loaded dining set");p.Cargo=chest.Cargo;
        Check(p.Sets[0].Table.ContentLocation()==u,"nested contents follow chest carrier climate");
    }
    void NestedResume(CaelumPlayer u)
    {
        Profile(u);let p=Proof(u);Check(p!=null && p.Cargo!=null && p.Cargo.Owner==u,"native chest cargo survives travel");if(p==null || p.Cargo==null)return;
        Check(p.Sets[0].Owner==p.Chest && p.Sets[0].Table==p.Tables[0],"nested dining inventory ownership survives");
        CaelumContainerSession.Open(u,p.Chest);u.DerivedStats.CarryCapacity=10000;
        Check(CaelumInventoryService.TransferContainerItem(u,p.Chest,p.Sets[0],1,false),"normal retrieval returns same loaded set");
        CaelumContainerSession.Get(u).Close();p.Sets[0].InMagicBox=false;DiningResume(u);
    }
    void Gallery(CaelumPlayer u,int k,bool inventory)
    {
        Profile(u);if(inventory){View(u,8+k);return;}
        let t=CaelumPortableDiningTable(Actor.Spawn(CaelumDiningSetData.BodyClass(k),(0,0,0)));t.Angle=0;
        Check(t.ConfigureParts(),"native gallery has complete physical dining set");t.RefreshDisplays();
        for(int i=0;i<t.SeatCount();i++)Check(t.Chairs[i]!=null,"gallery chair exists");
        double distance=k==3?125:k==2?110:80;
        u.SetOrigin((distance,-distance,0),false);u.Angle=135;u.Pitch=14;u.Vel=(0,0,0);
        Check(TexMan.CheckForTexture(CaelumDiningSetData.Icon(k),TexMan.Type_Any).IsValid(),"painted inventory texture available");
    }
    void Input(CaelumPlayer u,int stage)
    {
        if(stage==0)
        {
            Profile(u);let p=Proof(u,true);let item=CaelumDiningSetItem(Actor.Spawn('CaelumNormalDiningSetItem'));item.AttachToOwner(u);p.Sets[0]=item;
            Check(PlaceSet(u,item),"normal-input set deployed");if(item.Table==null)return;
            ApproachTable(u,item.Table);u.Pitch=30;u.DerivedStats.CarryCapacity=10000;
        }
        else
        {
            let p=Proof(u);Check(p!=null && p.Sets[0]!=null && p.Sets[0].Owner==u,"actual crouch plus Use packs table assembly");
        }
    }
    void Weather(CaelumPlayer u)
    {
        DiningSeed(u);let p=Proof(u);if(p==null)return;
        let clock=CaelumWorldClock.Get(u);double before[4];
        for(int k=0;k<4;k++)
        {
            p.Sets[k].InMagicBox=true;CaelumFoodInventory.Reconcile(p.Foods[k]);before[k]=p.Foods[k].FoodLots.OldestContamination();
            p.Waters[k].WaterTemperatureC=80;p.Waters[k].TemperatureStamp=CaelumThermalRuntime.Stamp(clock);p.Waters[k].TemperatureClockReady=true;
        }
        clock.DayTics+=CaelumWorldClock.TicsPerHour();
        for(int k=0;k<4;k++)
        {
            CaelumFoodInventory.Reconcile(p.Foods[k]);p.Waters[k].SyncAmbientTemperature();
            Check(p.Foods[k].FoodLots.OldestContamination()>before[k],"food keeps ageing inside a boxed table set");
            Check(p.Waters[k].WaterTemperatureC<80 && p.Waters[k].WaterTemperatureC>0 && Near(p.Waters[k].WaterLiters,.75),"world-hour wait cools packed water without altering volume");
            double dirt=p.Foods[k].FoodLots.OldestContamination(),heat=p.Waters[k].WaterTemperatureC;
            CaelumFoodInventory.Reconcile(p.Foods[k]);p.Waters[k].SyncAmbientTemperature();
            Check(Near(dirt,p.Foods[k].FoodLots.OldestContamination()) && Near(heat,p.Waters[k].WaterTemperatureC),"same world instant does not age or cool twice");
        }
    }
    void LoadedTrade(CaelumPlayer u)
    {
        Profile(u);let p=Proof(u);Check(p!=null,"loaded-table sale uses saved real assemblies");if(p==null)return;
        u.SetOrigin((0,-64,0),false);u.GiveInventoryType('CaelumGoldCoin').Amount=20000;u.OnNativeInventoryChanged();
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,0,0)));vendor.Category=0;vendor.WalletCopper=10000000;
        CaelumMerchantCoordinator.OpenCityTrade(u,vendor);let s=u.CityTrade;Check(s!=null,"actual merchant opens for loaded-set resale");if(s==null)return;
        for(int k=0;k<4;k++)
        {
            let item=p.Sets[k];CaelumContaminationStorage.Set(item,0);
            Inventory stock=null;for(int j=0;j<vendor.Products.Size();j++)if(vendor.Products[j].NativeClass==item.GetClassName())stock=vendor.Products[j].Stock;
            int amount=stock!=null?stock.Amount:0;double mass=item.GetUnitWeight();
            u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_SELL;s.Refresh(u);s.Selection=s.Rows.Find(item);s.Refresh(u);u.DerivedStats.CarryCapacity=10000;s.Execute(u);
            Check(item.Owner==vendor && item.Table==p.Tables[k] && stock!=null && stock.Amount==amount,"clean used assembly sells without merging manufactured stock");
            Check(item.Table.ContentLocation()==vendor && p.Foods[k].Owner==item.Table && p.Waters[k].Owner==item.Table && Near(item.GetUnitWeight(),mass),"merchant owns same complete cargo and climate location");
            u.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;s.Refresh(u);s.Selection=s.Rows.Find(item);s.Refresh(u);u.DerivedStats.CarryCapacity=10000;s.Execute(u);
            Check(item.Owner==u && item.Table==p.Tables[k] && p.Foods[k].Amount==3 && Near(p.Waters[k].WaterLiters,.75),"buyback returns original loaded set and real quantities");
        }
        u.ClosePalomoMerchant();
    }
    void ExposureBoundary(CaelumPlayer u)
    {
        Profile(u);let item=CaelumDiningSetItem(Actor.Spawn('CaelumSmallDiningSetItem'));item.AttachToOwner(u);
        Check(PlaceSet(u,item),"exposure boundary set deploys");if(item.Table==null)return;
        let chair=item.Table.Chairs[0];let entry=CaelumContaminationStorage.Get(chair);
        Check(entry!=null && entry.Exposure!=null,"deployed chair registers environmental exposure");
        if(entry==null || entry.Exposure==null)return;
        let node=entry.Exposure;let clock=CaelumWorldClock.Get(u);
        entry.Concentration=20;node.HistoryReady=true;node.HistoryVariable=false;
        node.HistoryStamp=CaelumThermalRuntime.Stamp(clock);node.HistoryAmbient=80;
        node.HistoryRain=0;node.HistoryArea=CaelumContaminationObject.Area(chair);
        clock.DayTics+=TICRATE;
        double expected=CaelumContaminationObjectBalance.Evolve(20,80,0,node.HistoryArea,CaelumThermalRuntime.Stamp(clock)-node.HistoryStamp);
        ApproachTable(u,item.Table);
        Check(item.Carry(u),"exposed set packs normally");
        Console.Printf("CA410DS DETAIL settled=%f expected=%f exposure=%d",entry.Concentration,expected,entry.Exposure!=null);
        Check(Near(entry.Concentration,expected) && entry.Exposure==null,"packing settles final interval before disabling exposure");
        Check(PlaceSet(u,item) && entry.Exposure!=null,"redeployment restarts chair exposure");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410ds_catalogue')Catalogue(u);else if(e.Name=='ca410ds_craft')Craft(u);
        else if(e.Name=='ca410ds_trade')Trade(u);else if(e.Name=='ca410ds_items')Items(u);
        else if(e.Name=='ca410ds_seed')DiningSeed(u);else if(e.Name=='ca410ds_resume')DiningResume(u);
        else if(e.Name=='ca410ds_nested')Nested(u);else if(e.Name=='ca410ds_nestedresume')NestedResume(u);
        else if(e.Name=='ca410ds_view')Gallery(u,e.Args[0],false);else if(e.Name=='ca410ds_icon')Gallery(u,e.Args[0],true);
        else if(e.Name=='ca410ds_input')Input(u,e.Args[0]);
        else if(e.Name=='ca410ds_weather')Weather(u);
        else if(e.Name=='ca410ds_exposure')ExposureBoundary(u);
        else if(e.Name=='ca410ds_loadedtrade')LoadedTrade(u);
        else if(e.Name=='ca410ds_studyseed')StudySeed(u);
        else if(e.Name=='ca410ds_studyresume')StudyResume(u);
        else if(e.Name=='ca410ds_legacy')Migration(u);else return;
        Result();
    }
}
