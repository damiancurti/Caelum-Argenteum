class CA502AwayProof : Inventory
{
    double Worked,Money,Wallet,Stamp;
    int Reachable,Blocked;
    CaelumConsumableItem Food;
    CaelumWaterContainer Water;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502AwayChecks : CA502DomesticChecks
{
    CA502AwayProof Saved(CaelumPlayer u)
    {let p=CA502AwayProof(u.FindInventory('CA502AwayProof'));return p!=null?p:CA502AwayProof(u.GiveInventoryType('CA502AwayProof'));}
    CaelumHouseStorageEntry Home()
    {let s=CaelumHouseStorage.Get();return s!=null && s.Houses.Size()>0?s.Houses[0]:null;}
    void Seed(CaelumPlayer u)
    {
        let w=Work();Check(w!=null && w.Initialized && w.Chest!=null,"real home ready");if(w==null || w.Chest==null)return;
        AutoStart(u);Live=false;
        let p=Saved(u);p.Money=Money(w.Chest);p.Wallet=Vendor().WalletCopper;p.Worked=Record(u).WorkedSeconds;p.Stamp=CaelumHouseAwayWork.Civil(u);
        Check(CaelumHousekeepingWork.Soap(w.Chest)>=300 && CaelumHousePurchase.Count(w.Chest,1)>0,"real shared supplies available");
        Check(w.HasChestAccess(),"living resident has actual household key");
        if(p.Food==null){p.Food=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation'));p.Food.Amount=1;p.Food.AttachToOwner(w.Chest);CaelumFoodInventory.Reconcile(p.Food);}
        if(p.Water==null){p.Water=CaelumWaterContainer(Actor.Spawn('CaelumCanteenLarge'));p.Water.AttachToOwner(w.Chest);p.Water.AddWater(.5,0,65,true);p.Water.SyncAmbientTemperature();}
    }
    void Away(CaelumPlayer u)
    {
        let entry=Home();Check(entry!=null && entry.Parked && entry.Away!=null,"production departure captured remote work");if(entry==null || entry.Away==null)return;
        let work=entry.Away;int reachable=0,blocked=0;
        for(int i=0;i<work.Targets.Size();i++){if(work.Targets[i].Workers.Size()>0)reachable++;else blocked++;}
        Console.Printf("CA502A ACCESS workers=%d reachable=%d blocked=%d targets=%d",work.Residents.Size(),reachable,blocked,work.Targets.Size());
        Check(work.Residents.Size()>0 && reachable>0,"native access snapshot has living workers and reachable surfaces");
        Check(blocked>0,"native obstacles exclude unreachable targets");
        let p=Saved(u);p.Reachable=reachable;p.Blocked=blocked;
        double start=MSTimeF();CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerHour()*2);
        Console.Printf("CA502A TIMING catchup_ms=%.6f",MSTimeF()-start);
        double worked=Record(u).WorkedSeconds;
        Check(worked>p.Worked && worked<=CaelumHousekeepingData.DAILY_SECONDS,"unloaded home performs at most one shared hour");
        int cleaned=0;bool blockedIntact=true;
        for(int i=0;i<work.Targets.Size();i++)
        {let t=work.Targets[i];if(t.Work.Progress>0)cleaned++;if(t.Workers.Size()==0 && t.Work.Progress>0)blockedIntact=false;}
        Check(cleaned>0 && blockedIntact,"only targets with actual captured access are cleaned");
        Check(Near(Money(entry.Chest)+Vendor().WalletCopper,p.Money+p.Wallet),"all purchases transfer household money to actual merchant");
        p.Worked=worked;p.Money=Money(entry.Chest);p.Wallet=Vendor().WalletCopper;p.Stamp=CaelumHouseAwayWork.Civil(u);
        double soap=CaelumHousekeepingWork.Soap(entry.Chest);CaelumHouseAway.Sync(u);CaelumHouseAway.Sync(u);
        Check(Near(Record(u).WorkedSeconds,worked) && Near(CaelumHousekeepingWork.Soap(entry.Chest),soap),"repeated catch-up never charges twice");
    }
    void Returned(CaelumPlayer u)
    {
        let entry=Home();let w=Work();let p=Saved(u);
        Check(entry!=null && !entry.Parked && w!=null && w.Chest==entry.Chest,"same real coffer restored");if(entry==null || w==null)return;
        double elapsed=Max(0.0,CaelumHouseAwayWork.Civil(u)-p.Stamp);
        Check(Record(u).WorkedSeconds+.00001>=p.Worked && Record(u).WorkedSeconds<=p.Worked+elapsed+.00001,"return retains quota and settles only real exterior seconds");
        int restored=0;bool correct=true;
        for(int i=0;i<w.Targets.Size();i++)
        {
            String key=entry.TargetKey(w.Targets[i]);int n=entry.ProgressIndex(key,i);if(n<0)continue;
            correct=correct && Near(w.Targets[i].Progress,entry.Progress[n].Progress);
            if(w.Targets[i].Progress>0)restored++;
        }
        Check(correct,"every target restores its saved cleaning progress");
        Check(Near(Money(entry.Chest),p.Money) && Near(Vendor().WalletCopper,p.Wallet),"return does not create money or another purchase");
        Console.Printf("CA502A RESTORED targets_with_progress=%d",restored);
    }
    void Limbo(CaelumPlayer u)
    {
        let e=Home();Check(e!=null && e.Parked,"home remains in its source region");if(e==null)return;
        let p=Saved(u);p.Worked=Record(u).WorkedSeconds;p.Money=Money(e.Chest);p.Wallet=Vendor().WalletCopper;
        double before=CaelumHouseAwayWork.Civil(u),source=e.SourceNow(u),water=CaelumDomesticWater.Get(e.House).Liters;p.Stamp=before;
        double soap=CaelumHousekeepingWork.Soap(e.Chest);e.SyncDirt();let dirt=CaelumContaminationStorage.Get(e.Chest,true);double value=dirt.Concentration;
        CaelumFoodInventory.Reconcile(p.Food);double food=CaelumFoodInventory.Prepare(p.Food).Exposure;
        p.Water.SyncAmbientTemperature();double temperature=p.Water.WaterTemperatureC;
        let clock=CaelumWorldClock.Get(u);for(int i=0;i<TICRATE*3600;i++)clock.AdvanceOnMap("MAP01");
        e.SyncDirt();
        Check(Near(CaelumHouseAwayWork.Civil(u),before) && Near(e.SourceNow(u),source),"real Limbo advancement freezes exterior civil and source clocks");
        Check(Near(CaelumDomesticWater.Get(e.House).Liters,water),"Limbo creates no exterior household refill");
        Check(Near(Record(u).WorkedSeconds,p.Worked) && Near(CaelumHousekeepingWork.Soap(e.Chest),soap),"Limbo creates no cleaning or soap consumption");
        Check(Near(dirt.Concentration,value),"Limbo creates no source coffer exposure");
        Check(Near(Money(e.Chest),p.Money) && Near(Vendor().WalletCopper,p.Wallet),"Limbo creates no household purchase");
        CaelumFoodInventory.Reconcile(p.Food);p.Water.SyncAmbientTemperature();
        Check(Near(CaelumFoodInventory.Prepare(p.Food).Exposure,food),"stored food does not age during frozen exterior time");
        Check(Near(p.Water.WaterTemperatureC,temperature),"stored water does not cool during frozen exterior time");
    }
    void Repeat(CaelumPlayer u)
    {
        let e=Home();let p=Saved(u);Check(e!=null && e.Parked,"away save retains actual household");if(e==null)return;
        CaelumHouseAway.Sync(u);
        Check(Near(Record(u).WorkedSeconds,p.Worked),"loading away save does not replay paid work");
        Check(Near(Money(e.Chest),p.Money) && Near(Vendor().WalletCopper,p.Wallet),"loading away save does not duplicate payments");
    }
    void Core(CaelumPlayer u)
    {
        let w=Work();if(w==null || w.Chest==null)return;
        let stock=CaelumHousePurchase.Find(Vendor(),2);double money=Money(w.Chest);
        Check(!CaelumHousePurchase.BuyAt(u,w.Chest,0,Vendor(),stock,1,-1),"negative purchase dates rejected");
        Check(!CaelumHousePurchase.BuyAt(u,w.Chest,0,Vendor(),stock,1,Vendor().RestockLastSeen-1),"future stock cannot be sold into its past");
        Check(Near(money,Money(w.Chest)),"invalid chronology never charges money");
        let row=new('CaelumHouseStoredFurnishing');row.Ready=true;row.Stamp=0;row.Area=.1;row.Concentration=20;row.Ambient=80;
        row.Advance(10);Check(Near(row.Concentration,Sqrt(400+16)),"remote scalar history shares analytic object exposure");
        double value=row.Concentration;row.Advance(10);Check(Near(row.Concentration,value),"scalar history settles once");
        let entry=w.Chest.DomesticStorage;Array<double> times;double sum=0;
        entry.CaptureProgress(w);entry.CaptureFurnishings(w,u);
        for(int i=0;i<20;i++)
        {
            let snapshot=new('CaelumHouseAwayWork');double start=MSTimeF();snapshot.Capture(entry,w,u);
            double ms=MSTimeF()-start;times.Push(ms);sum+=ms;
        }
        for(int i=1;i<times.Size();i++)for(int j=i;j>0 && times[j]<times[j-1];j--){double ms=times[j];times[j]=times[j-1];times[j-1]=ms;}
        Console.Printf("CA502A TIMING access_targets=%d mean_ms=%.6f p95_ms=%.6f max_ms=%.6f",w.Targets.Size(),sum/20,times[18],times[19]);
        Check(w.Worker!=null && CaelumHousekeepingWork.Free(w.Worker,w.House),"access queries do not move or suspend the actual resident");
        CaelumContaminationTile original;
        for(int i=0;i<w.Targets.Size();i++)if(w.Targets[i].Tile!=null){original=w.Targets[i].Tile;break;}
        let away=new('CaelumHouseAwayWork');away.Sheet=w.Sheet;
        for(int covered=0;covered<2;covered++)for(int band=0;band<3;band++)
        {
            let a=original.Copy();a.Covered=covered!=0;a.Shelter=covered!=0?original.Shelter:CaelumWeatherRules.OPEN;
            a.Concentration=band==0?0:band==1?20:90;a.Stamp=CaelumContaminationSurfaces.Now(u)-21600;
            let b=a.Copy();double now=CaelumContaminationSurfaces.Now(u);
            w.Sheet.Sync(a,now);away.SyncFloor(b,now);
            Check(Near(a.Concentration,b.Concentration) && Near(a.Stamp,b.Stamp),"shared floor-weather cache preserves direct six-hour integration");
        }
    }
    void Shortages(CaelumPlayer u)
    {
        let e=Home();if(e==null || e.Away==null)return;
        let roster=CaelumHouseResidents.Get();let clock=CaelumWorldClock.Get(u);
        double before=Record(u).WorkedSeconds;
        for(int i=0;i<e.Away.Residents.Size();i++)roster.Residents[e.Away.Residents[i]].Body.ForcedSleepTics=100;
        clock.AdvanceTics(CaelumWorldClock.TicsPerHour()/60*2);
        Check(Near(Record(u).WorkedSeconds,before),"sleeping residents perform no unloaded work");
        for(int i=0;i<e.Away.Residents.Size();i++)roster.Residents[e.Away.Residents[i]].Body.ForcedSleepTics=0;
        e.Away.Stamp=CaelumHouseAwayWork.Civil(u);e.Away.NextDue=e.Away.Stamp+60;CaelumHouseStorage.Get().AwayCacheReady=false;
        let cloth=CaelumHousePurchase.Find(e.Chest,1);if(cloth!=null)cloth.Amount=0;
        for(Inventory item=e.Chest.Inv;item!=null;item=item.Inv)if(item is 'CaelumCurrencyItem')item.Amount=0;
        double soap=CaelumHousekeepingWork.Soap(e.Chest),wallet=Vendor().WalletCopper;
        clock.AdvanceTics(CaelumWorldClock.TicsPerHour()/60*2);
        Check(Near(Record(u).WorkedSeconds,before) && Near(CaelumHousekeepingWork.Soap(e.Chest),soap),"no cloth and no household funds prevent work and soap costs");
        Check(Near(Vendor().WalletCopper,wallet),"unaffordable automatic purchases transfer no money");
        let personal=CaelumCurrencyItem(u.GiveInventoryType(CaelumEconomyRules.GetCurrencyClassName(0)));if(personal!=null)personal.Amount=100000;
        double playerFunds=Money(u);clock.AdvanceTics(CaelumWorldClock.TicsPerHour()/60*2);
        Check(Near(Money(u),playerFunds) && CaelumHousePurchase.Count(e.Chest,1)==0,"household never pays with player money");
    }
    void ExtraHome(CaelumPlayer u)
    {
        let w=Work();Check(w!=null && w.House==1 && w.Chest!=null,"second real household ready");if(w==null || w.Chest==null)return;
        let r=CaelumHousekeepingWork.Record(w.House,int(Floor(CaelumHouseAwayWork.Civil(u)/86400)));
        r.WorkedSeconds=0;w.Day=r.Day;w.Active=-1;
        for(int i=0;i<w.Targets.Size();i++)
        {
            let t=w.Targets[i];t.Done=false;t.Progress=0;
            if(t.Tile!=null){t.Tile.Stamp=CaelumContaminationSurfaces.Now(u);t.Tile.Concentration=80;}
            else CaelumContaminationStorage.Set(t.Furniture,80);
        }
        CaelumHousePurchase.Replenish(u,w.Chest,w.House);CaelumDomesticWater.Get(w.House).Liters=100;
    }
    void Multiple(CaelumPlayer u)
    {
        let store=CaelumHouseStorage.Get();Check(store!=null && store.Houses.Size()>=2,"two actual households share one travelling shop");if(store==null)return;
        double money=Vendor().WalletCopper;
        for(int i=0;i<store.Houses.Size();i++)money+=Money(store.Houses[i].Chest);
        double start=MSTimeF();CaelumWorldClock.Get(u).AdvanceTics(CaelumWorldClock.TicsPerDay());
        Console.Printf("CA502A TIMING households=%d day_catchup_ms=%.6f",store.Houses.Size(),MSTimeF()-start);
        double after=Vendor().WalletCopper;int day=int(Floor(CaelumHouseAwayWork.Civil(u)/86400));
        for(int i=0;i<store.Houses.Size();i++)
        {
            let e=store.Houses[i];after+=Money(e.Chest);let r=CaelumHousekeepingWork.Record(e.House,day);
            Check(r.WorkedSeconds>0 && r.WorkedSeconds<=3600,"each household receives its own single daily hour");
            Check(e.Away.Stamp<=CaelumHouseAwayWork.Civil(u) && e.Away.NextDue>CaelumHouseAwayWork.Civil(u),"each timeline stops before future work");
            Check(CaelumHousekeepingWork.Soap(e.Chest)>=0,"shared stock never creates negative household supplies");
        }
        Check(Near(after,money),"chronological multi-house purchases conserve all actual money");
        Check(Vendor().RestockLastSeen<=CaelumScheduleState.Now(u),"shared merchant never advances beyond the real date");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502a_market')Market(u);else if(e.Name=='ca502a_seed')Seed(u);
        else if(e.Name=='ca502a_work')Away(u);else if(e.Name=='ca502a_back')Returned(u);
        else if(e.Name=='ca502a_extra')ExtraHome(u);else if(e.Name=='ca502a_multiple')Multiple(u);
        else if(e.Name=='ca502a_shortages')Shortages(u);else if(e.Name=='ca502a_limbo')Limbo(u);else if(e.Name=='ca502a_repeat')Repeat(u);else if(e.Name=='ca502a_core')Core(u);else return;
        Console.Printf("CA502A RESULT passed=%d failed=%d",Passed,Failed);
    }
}
