class CA502HouseProof : Inventory
{
    CaelumStashChest Chest;CaelumConsumableItem Food;CaelumWaterContainer Water;
    vector3 Position;int Profile,Region;double Money,Soap,Worked;
    String TargetKey,FloorKey;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502HouseAbsenceChecks : CA502DomesticChecks
{
    void Seed(CaelumPlayer u)
    {
        let w=Work();Check(w!=null && w.Initialized && w.Chest!=null,"real house initializes domestic coffer");if(w==null || w.Chest==null)return;
        let p=CA502HouseProof(u.GiveInventoryType('CA502HouseProof'));p.Chest=w.Chest;p.Position=w.Chest.Pos;
        Check(p.Chest.DomesticStorage!=null && p.Chest.DomesticStorage.House==0,"house registers original coffer once");
        CaelumHouseStorage.Register(p.Chest,0);Check(CaelumHouseStorage.Get().Houses.Size()==1,"coffer registration is idempotent");
        p.Chest.ChangeTid(600101);
        p.Food=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation'));p.Food.Amount=3;p.Food.AttachToOwner(p.Chest);p.Food.ChangeTid(600102);
        CaelumFoodInventory.Prepare(p.Food).Exposure=27;let clock=CaelumFoodClock.Get(p.Food);clock.Advance();
        p.Profile=clock.Climate.Profile;p.Region=clock.Climate.Region;
        p.Water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge'));p.Water.AttachToOwner(p.Chest);p.Water.AddWater(.5,CaelumWaterQuality.BIOLOGICAL,65,true);p.Water.ChangeTid(600103);
        Record(u).WorkedSeconds=321.25;p.Worked=Record(u).WorkedSeconds;
        if(w.Targets.Size()>0){w.Targets[0].Progress=17.5;w.Targets[0].Initial=60;w.Targets[0].Done=false;p.TargetKey=p.Chest.DomesticStorage.TargetKey(w.Targets[0]);}
        for(int i=0;i<w.Targets.Size();i++)if(w.Targets[i].Tile!=null)
        {w.Targets[i].Progress=3.25;w.Targets[i].Initial=40;p.FloorKey=p.Chest.DomesticStorage.TargetKey(w.Targets[i]);break;}
        p.Money=Money(p.Chest);p.Soap=CaelumHousekeepingWork.Soap(p.Chest);
        Check(p.Money>0 && Vendor()!=null,"fixture preserves actual domestic funds and city vendor");
    }
    void Away(CaelumPlayer u,bool purchase)
    {
        let p=CA502HouseProof(u.FindInventory('CA502HouseProof'));Check(p!=null && p.Chest!=null,"actual coffer survives leaving its house");if(p==null || p.Chest==null)return;
        let entry=p.Chest.DomesticStorage;
        Console.Printf("CA502H PROGRESS key=%s ready=%d rows=%d",p.TargetKey,entry.WorkReady,entry.Progress.Size());
        for(int i=0;i<entry.Progress.Size();i++)if(entry.Progress[i].Key==p.TargetKey)Console.Printf("CA502H SNAPSHOT %.6f %.6f",entry.Progress[i].Progress,entry.Progress[i].Initial);
        Check(entry!=null && entry.Parked && !p.Chest.bSolid && p.Chest.bInvisible,"remote coffer has no local physical presence");
        Check(!p.Chest.CanReachStorage(u) && p.Chest.Cargo==null,"remote coffer is not usable or player cargo");
        Check(p.Chest.TID==600101 && p.Food.TID==600102 && p.Water.TID==600103,"actual coffer and contents preserve native TIDs");
        Check(p.Food.Owner==p.Chest && p.Food.Amount==3 && p.Water.Owner==p.Chest && p.Water.WaterQuality==CaelumWaterQuality.BIOLOGICAL,"same native inventories retain ownership and quantities");
        let foodClock=CaelumFoodClock.Get(p.Food);
        Console.Printf("CA502H CLIMATE expected=%d/%d actual=%d/%d house=%d/%d remote=%d ready=%d",p.Profile,p.Region,foodClock.Climate!=null?foodClock.Climate.Profile:-1,foodClock.Climate!=null?foodClock.Climate.Region:-1,entry.Climate!=null?entry.Climate.Profile:-1,entry.Climate!=null?entry.Climate.Region:-1,CaelumHouseStorageEntry.Remote(foodClock.Location())!=null,foodClock.Ready);
        Check(foodClock!=null && foodClock.Climate!=null && foodClock.Climate.Profile==p.Profile && foodClock.Climate.Region==p.Region,"food retains home climate in another region");
        Check(Near(Record(u).WorkedSeconds,p.Worked),"travel does not reset daily household work");
        if(purchase)
        {
            let vendor=Vendor();let stock=CaelumHousePurchase.Find(vendor,2);int before=stock.Amount;double money=Money(p.Chest),soap=CaelumHousekeepingWork.Soap(p.Chest);
            int price=CaelumEconomyRules.GetPriceChargedByMerchant(CaelumEconomyRules.GetInventoryUnitBaseValue(stock),50);
            Check(CaelumHousePurchase.Buy(u,p.Chest,0,vendor,stock,50),"remote household buys from actual Provisions stock");
            Check(stock.Amount==before-50 && Near(Money(p.Chest),money-price) && Near(CaelumHousekeepingWork.Soap(p.Chest),soap+50),"remote purchase pays once and transfers actual soap");
            p.Money=Money(p.Chest);p.Soap=CaelumHousekeepingWork.Soap(p.Chest);
            CaelumContaminationStorage.Set(p.Chest,0);
            double old=p.Food.FoodLots.OldestContamination();let clock=CaelumWorldClock.Get(u);clock.DayTics+=CaelumWorldClock.TicsPerHour();
            CaelumFoodInventory.Reconcile(p.Food);p.Water.SyncAmbientTemperature();
            Check(p.Food.FoodLots.OldestContamination()>old && foodClock.Climate.Profile==p.Profile,"stored food ages using source house climate");
            Check(p.Water.WaterTemperatureC<65 && p.Water.WaterTemperatureC>0 && Near(p.Water.WaterLiters,.5),"remote water cools without changing volume");
            double dirt=CaelumContaminationStorage.Value(p.Chest);Check(dirt>0 && dirt<=100,"coffer itself retains source-environment exposure while absent");
            Check(Near(CaelumContaminationStorage.Value(p.Chest),dirt),"same instant does not charge coffer exposure twice");
        }
        Check(Near(Money(p.Chest),p.Money) && Near(CaelumHousekeepingWork.Soap(p.Chest),p.Soap),"remote resource balances persist");
    }
    void Back(CaelumPlayer u)
    {
        let p=CA502HouseProof(u.FindInventory('CA502HouseProof'));let w=Work();Check(p!=null && w!=null && w.Chest==p.Chest,"native home reuses original returned coffer");if(p==null || p.Chest==null)return;
        Check(!p.Chest.DomesticStorage.Parked && p.Chest.bSolid && !p.Chest.bInvisible && (p.Chest.Pos-p.Position).Length()<.001,"coffer restores original place and collision");
        Check(Near(Money(p.Chest),p.Money) && Near(CaelumHousekeepingWork.Soap(p.Chest),p.Soap) && Near(Record(u).WorkedSeconds,p.Worked),"return preserves purchased supplies funds and daily quota");
        bool matched=false;for(int i=0;i<w.Targets.Size();i++)if(p.Chest.DomesticStorage.TargetKey(w.Targets[i])==p.TargetKey)
            {matched=Near(w.Targets[i].Progress,17.5) && Near(w.Targets[i].Initial,60);Console.Printf("CA502H MATCH %.6f %.6f",w.Targets[i].Progress,w.Targets[i].Initial);}
        Console.Printf("CA502H TARGETS %d first=%s",w.Targets.Size(),w.Targets.Size()>0?p.Chest.DomesticStorage.TargetKey(w.Targets[0]):"none");
        Check(matched,"partly cleaned target retains previous effort and initial concentration");
        matched=false;for(int i=0;i<w.Targets.Size();i++)if(p.Chest.DomesticStorage.TargetKey(w.Targets[i])==p.FloorKey)
            matched=Near(w.Targets[i].Progress,3.25) && Near(w.Targets[i].Initial,40);
        Check(matched,"partial floor-zone cleaning retains stable surface identity");
        Check(p.Food.Owner==p.Chest && p.Food.Amount==3 && p.Food.FoodLots.OldestContamination()>=27 && Near(p.Water.WaterLiters,.5),"food lots and bottle remain the same native objects");
        int count=0;let it=ThinkerIterator.Create('CaelumStashChest');CaelumStashChest chest;while((chest=CaelumStashChest(it.Next()))!=null)if(chest.TID==600101)count++;
        Check(count==1 && CaelumHouseStorage.Get().Houses.Size()==1,"no duplicate coffer after repeated restoration");
    }
    void Performance(CaelumPlayer u)
    {
        let w=Work();if(w==null || w.Chest==null)return;let entry=w.Chest.DomesticStorage;
        Check(entry!=null,"production registry is available for bounded persistence timing");if(entry==null)return;
        Array<double> samples;double total=0;
        for(int i=0;i<20;i++)
        {double begin=MSTimeF();entry.CaptureProgress(w);entry.RestoreProgress(w);double cost=MSTimeF()-begin;total+=cost;samples.Push(cost);}
        for(int i=1;i<samples.Size();i++)for(int j=i;j>0 && samples[j]<samples[j-1];j--)
        {double swap=samples[j];samples[j]=samples[j-1];samples[j-1]=swap;}
        Console.Printf("CA502H TIMING snapshot_restore_targets=%d mean_ms=%.6f p95_ms=%.6f max_ms=%.6f",w.Targets.Size(),total/20,samples[18],samples[19]);
        for(int i=0;i<w.Targets.Size()/2;i++){int j=w.Targets.Size()-i-1;let swap=w.Targets[i];w.Targets[i]=w.Targets[j];w.Targets[j]=swap;}
        entry.RestoreProgress(w);bool ok=true;
        for(int i=0;i<w.Targets.Size();i++)
        {let t=w.Targets[i];int n=entry.ProgressIndex(entry.TargetKey(t),i);if(n<0 || !Near(t.Progress,entry.Progress[n].Progress))ok=false;}
        Check(ok,"changed target enumeration preserves every stored effort by identity");
        for(int i=0;i<w.Targets.Size()/2;i++){int j=w.Targets.Size()-i-1;let swap=w.Targets[i];w.Targets[i]=w.Targets[j];w.Targets[j]=swap;}
        Check(CaelumHouseStorage.Get().Houses.Size()==1,"repeated snapshots never create extra household records");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502h_market')Market(u);else if(e.Name=='ca502h_seed')Seed(u);
        else if(e.Name=='ca502h_away')Away(u,true);else if(e.Name=='ca502h_load')Away(u,false);else if(e.Name=='ca502h_back')Back(u);else if(e.Name=='ca502h_perf')Performance(u);else return;
        Console.Printf("CA502H RESULT passed=%d failed=%d",Passed,Failed);
    }
}
