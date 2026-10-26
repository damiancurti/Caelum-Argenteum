class CA410FoodChecks : EventHandler
{
    int Passed,Failed;
    CaelumStashChest SavedChest;
    override void WorldTick()
    {
        if(level.maptime>2)return;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.A_SetBlend("Black",0,1);
    }
    void Check(bool yes,String label)
    {if(yes)Passed++;else Failed++;Console.Printf("CA410F %s %s",yes?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Setup(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.CombatTimeRemaining=0;u.DerivedStats.CarryCapacity=1000;u.CurrentHunger=50;
        u.CurrentThirst=100;u.CurrentSleep=100;u.MagicBoxOwned=true;
        let persistent=u.GetPersistentCharacterState(true);persistent.ProfileCommitted=true;
        persistent.GrantMagicBoxOwnership();u.SyncLiveMagicBoxOwnershipFromPersistentState();
        CaelumThermalWorld.Get().ReferenceClock=CaelumWorldClock.Get(u,true);
        let old=u.FindInventory('CaelumFoodRation');if(old!=null)old.Destroy();
    }
    CaelumConsumableItem Food(int count,double contamination,Actor owner=null)
    {
        let item=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation',(300,300,0),NO_REPLACE));
        item.Amount=count;if(owner!=null)item.AttachToOwner(owner);
        let lots=CaelumFoodInventory.Prepare(item);lots.Lots[0].BaseContamination=contamination;
        return item;
    }
    void Core(CaelumPlayer u)
    {
        Setup(u);let original=Food(5,30,u);let extra=Food(3,0);
        original.FoodLots.Lots[0].CreatedStamp=-10;
        Check(original.HandlePickup(extra) && original.Amount==8,"native pickup merges quantities");
        Check(original.FoodLots.Units()==8 && original.FoodLots.Lots.Size()==2,"pickup preserves both lots");
        Check(Near(original.FoodLots.OldestContamination(),30),"fresh addition cannot rejuvenate original ration");
        let tossed=CaelumConsumableItem(original.CreateTossable(2));
        Check(tossed!=null && tossed.Amount==2 && original.Amount==6,"native toss splits quantity");
        Check(tossed!=null && tossed.FoodLots!=original.FoodLots && tossed.FoodLots.Units()==2
            && original.FoodLots.Units()==6,"toss has independent metadata and conserves units");
        Check(tossed!=null && Near(tossed.FoodLots.OldestContamination(),30),"toss takes oldest lot");
        if(tossed!=null)Check(original.HandlePickup(tossed) && original.FoodLots.Units()==8,"pickup of dropped food retains age");
        original.InMagicBox=true;double before=CaelumFoodIllness.Value(u);
        Check(!original.Use(false) && original.FoodLots.Units()==8 && CaelumFoodIllness.Value(u)==before,"blocked boxed use consumes nothing");
        original.InMagicBox=false;double mass=u.DerivedStats.BaseMass;
        Check(u.UseInventory(original),"native inventory use accepted");
        Check(original.Amount==7 && original.FoodLots.Units()==7,"native use consumes one lot exactly once");
        Check(Near(CaelumFoodIllness.Value(u)-before,30*2*80/mass),"200g dose scales by body mass");
        Check(!CaelumFoodInventory.CanSell(original),"shop rejects contaminated food");
        let clean=Food(2,0);
        Check(CaelumFoodInventory.CanSell(clean),"shop accepts fresh food");
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(400,300,0),NO_REPLACE));vendor.Category=0;
        Check(!vendor.Accepts(original) && vendor.Accepts(clean),"actual merchant filters contaminated resale");
        clean.Destroy();vendor.Destroy();
        original.Amount+=2;CaelumFoodInventory.Reconcile(original);
        Check(original.FoodLots.Units()==9 && Near(original.FoodLots.OldestContamination(),30),"external fresh gift keeps old lots");
        original.Amount-=1;CaelumFoodInventory.Reconcile(original);
        Check(original.FoodLots.Units()==8,"external native removal consumes oldest once");
        let copySource=Food(4,19);copySource.MaxAmount=2;
        let copy=CaelumConsumableItem(copySource.CreateCopy(u));
        Check(copy!=null && copy.FoodLots!=null && copy.FoodLots.Units()==copy.Amount,"native copy quantity and metadata match");
        if(copy!=copySource)Check(copy.FoodLots!=copySource.FoodLots,"native copy metadata is independent");
    }
    void Clock(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;let food=Food(4,0,u);
        CaelumFoodInventory.Reconcile(food);let clock=food.FoodClock;
        Check(clock!=null && clock.Ready && clock.Climate!=null && clock.Climate.Ready,"native food clock initialized with actual climate");
        if(clock==null || clock.Climate==null || !clock.Climate.Ready)return;
        double rate=clock.Climate.Rate(clock.Climate.CivilSeconds);
        clock.Stamp-=3600;CaelumFoodInventory.Reconcile(food);
        Check(Near(food.FoodLots.OldestContamination(),100.0/168*rate),"hour of world time ages native ration at mansion climate");
        double before=food.FoodLots.OldestContamination();CaelumFoodInventory.Reconcile(food);
        Check(food.FoodLots.OldestContamination()==before,"repeated clock update cannot age twice");
        food.InMagicBox=true;clock.Stamp-=3600;CaelumFoodInventory.Reconcile(food);
        Check(Near(food.FoodLots.OldestContamination(),before*2),"Box retains carrier climate and food spoilage");
        let vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(400,300,0),NO_REPLACE));
        let stock=Food(5,0,vendor);CaelumFoodInventory.Reconcile(stock);stock.FoodClock.Stamp-=86400;
        CaelumFoodInventory.Reconcile(stock);Check(stock.FoodLots.OldestContamination()==0,"commercial stock remains fresh");
        let climate=clock.Climate.Copy();let copied=food.FoodLots.Copy();double original=food.FoodLots.OldestContamination();
        climate.Advance(copied,168*3600);
        Check(copied.OldestContamination()==100 && food.FoodLots.OldestContamination()==original,"climate replay saturates independent copy");
        let coarse=clock.Climate.Copy(),fine=clock.Climate.Copy();let a=food.FoodLots.Copy(),b=food.FoodLots.Copy();
        coarse.Advance(a,3601);for(int i=0;i<3601;i++)fine.Advance(b,1);
        Check(Near(a.OldestContamination(),b.OldestContamination()),"calendar interval is independent of frame grouping");
        food.InMagicBox=false;u.RefreshFormalInventorySnapshot();bool displayed=false;
        for(int i=0;i<CaelumPlayer.FORMAL_INVENTORY_VISIBLE_ROWS;i++)
            if(u.FormalInventoryRowFoodContamination[i]>=0)displayed=true;
        Check(displayed,"inventory snapshot exposes food contamination");
    }
    void Travel(CaelumPlayer u)
    {
        Setup(u);let item=Food(5,10,u);double before=CaelumFoodIllness.Value(u);
        let model=new('CaelumJourneyModel');model.Capture(u,false);model.Hunger=0;
        Check(model.FoodInventory!=null && model.FoodInventory.Stacks.Size()==1,"travel captures actual ration stacks");
        model.FoodInventory.Advance(168*3600/10,20,50);model.BeginServings();
        Check(Near(model.FoodIllness.Contamination-before,20*2*80/model.Mass),"travel ingests contamination at eating time after ageing");
        Check(item.Amount==5 && item.FoodLots.Units()==5 && Near(item.FoodLots.OldestContamination(),10)
            && CaelumFoodIllness.Value(u)==before,"forecast cannot mutate live food or disease");
        model.FoodInventory.Commit(u);
        Check(item.Amount==4 && item.FoodLots.Units()==4 && Near(item.FoodLots.OldestContamination(),20),"travel commits aged remaining lots once");
        CaelumFoodInventory.Reconcile(item);
        Check(Near(item.FoodLots.OldestContamination(),20),"committed travel does not age twice");
        let skip=new('CaelumSkipSupply');skip.Capture(item);
        Check(skip.FoodLots!=item.FoodLots && skip.FoodClimate!=item.FoodClock.Climate,"wait captures independent food and weather");
        let waitModel=new('CaelumTimeSkipModel');waitModel.Mass=model.Mass;waitModel.FoodIllness=new('CaelumFoodIllness');waitModel.FoodIllness.Ensure();
        waitModel.Hunger=0;waitModel.Thirst=100;waitModel.FoodTrigger=100;waitModel.Supplies.Push(skip);
        waitModel.ServeSupplies();
        Check(skip.Count==3 && skip.FoodLots.Units()==3 && Near(waitModel.FoodIllness.Contamination,20*2*80/model.Mass),"wait serving consumes copied oldest lot and applies dose");
        Check(item.Amount==4 && item.FoodLots.Units()==4,"wait preview leaves native food untouched");
        let committed=new('CaelumJourneyModel');committed.Capture(u,false);committed.Hunger=0;
        committed.BeginServings();committed.ElapsedTics=CaelumWorldClock.TicsPerHour();
        committed.FoodInventory.Advance(3600,20,50);
        let plan=CaelumJourneyPlan(Actor.Spawn('CaelumJourneyPlan',u.Pos,NO_REPLACE));plan.Available=committed;
        plan.Apply(u);
        Check(item.Amount==3 && item.FoodLots.Units()==3,"actual journey Apply commits native remainder");
        double expected=20+100.0/168;
        Check(Near(item.FoodLots.OldestContamination(),expected),"actual journey clock advance does not age food twice");
        Check(Near(CaelumFoodIllness.Value(u),committed.FoodIllness.Contamination),"actual journey applies copied dose once");
        plan.Destroy();
    }
    void Container(CaelumPlayer u)
    {
        Setup(u);let food=Food(6,25,u);food.FoodLots.Lots[0].CreatedStamp=-100;
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',u.Pos+(64,0,0),NO_REPLACE));
        chest.ChestUnlocked=true;chest.ChestOpen=true;chest.EnsureStorage();
        let session=CaelumContainerSession.Get(u,true);session.Chest=chest;
        Check(CaelumInventoryService.TransferContainerItem(u,chest,food,2,true),"deposit partial native ration stack");
        let stored=CaelumConsumableItem(chest.FindInventory('CaelumFoodRation'));
        Check(stored!=null && stored.Amount==2 && stored.FoodLots!=food.FoodLots
            && food.Amount==4 && food.FoodLots.Units()==4,"coffer split conserves quantity and independent lots");
        if(stored==null)return;
        Check(Near(stored.FoodLots.OldestContamination(),25),"coffer deposit preserves contamination");
        Check(CaelumInventoryService.TransferContainerItem(u,chest,stored,1,false),"withdraw partial stack into existing ration");
        Check(stored.Amount==1 && stored.FoodLots.Units()==1 && food.Amount==5 && food.FoodLots.Units()==5,"withdraw merges metadata exactly once");
        Check(!CaelumInventoryService.TransferContainerItem(u,chest,stored,2,false)
            && stored.Amount==1 && food.Amount==5,"failed overdraw preserves both lots");
        Check(CaelumInventoryService.TransferContainerItem(u,chest,food,5,true),"whole stack merge into coffer");
        Check(stored.Amount==6 && stored.FoodLots.Units()==6 && stored.Owner==chest,"coffer authoritative quantity after full transfer");
        SavedChest=chest;u.CurrentHunger=100;session.Close();
    }
    void HubReturn(CaelumPlayer u)
    {
        let food=SavedChest!=null?CaelumConsumableItem(SavedChest.FindInventory('CaelumFoodRation')):null;
        Check(food!=null && food.Amount==6,"hub preserves coffer native food");
        if(food==null)return;
        CaelumFoodInventory.Reconcile(food);
        Check(food.FoodLots.Units()==6 && food.FoodLots.OldestContamination()>25.5,"unloaded coffer ages using its saved mansion climate");
        Check(food.FoodClock!=null && food.FoodClock.Item==food,"hub clock remains bound to native item");
    }
    void Read(CaelumPlayer u)
    {
        let item=CaelumConsumableItem(u.FindInventory('CaelumFoodRation'));
        if(item==null){Console.Printf("CA410F no rations remaining");return;}
        CaelumFoodInventory.Reconcile(item);
        Console.Printf("CA410F FOOD portions=%d lots=%d oldest=%.4f boxed=%d sale=%d",item.Amount,item.FoodLots.Lots.Size(),item.FoodLots.OldestContamination(),item.InMagicBox,CaelumFoodInventory.CanSell(item));
        Console.Printf("CA410F BODY contamination=%.4f mass=%.2f kg next-dose=%.4f",CaelumFoodIllness.Value(u),u.DerivedStats.BaseMass,
            CaelumFoodRules.Intake(item.FoodLots.OldestContamination(),200,u.DerivedStats.BaseMass));
    }
    void Manual(CaelumPlayer u)
    {
        Setup(u);u.CurrentHunger=100;CaelumFoodIllness.Get(u).Contamination=0;
        let item=Food(3,30,u);item.FoodLots.Lots[0].CreatedStamp=-100;
        let fresh=Food(3,0);item.HandlePickup(fresh);fresh.Destroy();
        u.FormalInventoryFilter=5;u.FormalInventorySelectionIndex=0;u.RefreshFormalInventorySnapshot();
        for(int i=0;i<u.FormalInventoryEntryCount;i++)
            if(u.GetFormalInventoryEntryAt(i)==item){u.FormalInventorySelectionIndex=i;break;}
        u.RefreshFormalInventorySnapshot();Read(u);Check(true,"manual food fixture ready");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca410f_core")Core(u);
        else if(e.Name=="ca410f_manual")Manual(u);
        else if(e.Name=="ca410f_read")Read(u);
        else if(e.Name=="ca410f_eat")
        {
            let item=u.FindInventory('CaelumFoodRation');
            if(item!=null)u.UseInventory(item);u.RefreshFormalInventorySnapshot();Read(u);
        }
        else if(e.Name=="ca410f_day")
        {
            let item=CaelumConsumableItem(u.FindInventory('CaelumFoodRation'));
            if(item!=null){CaelumFoodInventory.Reconcile(item);item.FoodClock.Stamp-=86400;CaelumFoodInventory.Reconcile(item);}
            u.RefreshFormalInventorySnapshot();Read(u);
        }
        else if(e.Name=="ca410f_clock")Clock(u);
        else if(e.Name=="ca410f_travel")Travel(u);
        else if(e.Name=="ca410f_container")Container(u);
        else if(e.Name=="ca410f_away")
        {CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour());Check(true,"one campaign hour away from stored food");}
        else if(e.Name=="ca410f_return")HubReturn(u);
        else if(e.Name=="ca410f_seed"){Setup(u);u.CurrentHunger=100;Food(4,37,u);Check(true,"seed saved food");}
        else if(e.Name=="ca410f_load")
        {
            let item=CaelumConsumableItem(u.FindInventory('CaelumFoodRation'));
            Check(item!=null && item.Amount==4 && item.FoodLots!=null && item.FoodLots.Units()==4,"native food lots survive save");
            Check(item!=null && item.FoodLots.OldestContamination()>=37 && item.FoodLots.OldestContamination()<37.1,"saved contamination retained");
        }
        else return;
        Console.Printf("CA410F RESULT passes=%d failures=%d",Passed,Failed);
    }
}
