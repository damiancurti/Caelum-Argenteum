class CA502FurnitureProof : Inventory
{
    Array<String> Keys;
    Array<double> Values;
    double Money,Worked;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502FurnitureChecks : CA502DomesticChecks
{
    void Seed(CaelumPlayer u)
    {
        let w=Work();Check(w!=null && w.Initialized && w.Chest!=null,"actual home initialized");if(w==null || w.Chest==null)return;
        let p=CA502FurnitureProof(u.FindInventory('CA502FurnitureProof'));
        if(p==null)p=CA502FurnitureProof(u.GiveInventoryType('CA502FurnitureProof'));
        p.Keys.Clear();p.Values.Clear();
        for(int i=0;i<w.Targets.Size();i++)
        {
            let t=w.Targets[i];if(t.Furniture==null || t.Furniture==w.Chest)continue;
            String key=w.Chest.DomesticStorage.TargetKey(t);p.Keys.Push(key);
            double value=p.Keys.Size()==1?0:80+p.Keys.Size();
            CaelumContaminationStorage.Set(t.Furniture,value);p.Values.Push(value);
            t.Initial=95;t.Progress=11.25;t.Done=false;
        }
        Check(p.Keys.Size()>=7,"table chairs bed and bathroom are actual distinct targets");
        p.Money=Money(w.Chest);p.Worked=Record(u).WorkedSeconds;
        Check(p.Money>0,"existing household money is retained");
    }
    void CheckPrior(CaelumPlayer u)
    {
        let w=Work();let p=CA502FurnitureProof(u.FindInventory('CA502FurnitureProof'));
        Check(w!=null && w.Chest!=null && p!=null,"original saved home and diagnostic values survive load");if(w==null || p==null || w.Chest==null)return;
        for(int j=0;j<p.Keys.Size();j++)
        {
            bool found=false;
            for(int i=0;i<w.Targets.Size();i++)if(w.Chest.DomesticStorage.TargetKey(w.Targets[i])==p.Keys[j])
            {found=CaelumContaminationStorage.Value(w.Targets[i].Furniture)+.00001>=p.Values[j];break;}
            Check(found,"previous saved furnishing concentration remains authoritative");
        }
    }
    void Clean(CaelumPlayer u)
    {
        let w=Work();if(w==null || w.Chest==null)return;
        for(int i=0;i<w.Targets.Size();i++)if(w.Targets[i].Furniture!=null && w.Targets[i].Furniture!=w.Chest)
            CaelumContaminationStorage.Set(w.Targets[i].Furniture,2);
        Check(true,"later cleaning updates actual furniture state");
    }
    void CleanSaved(CaelumPlayer u)
    {
        let w=Work();Check(w!=null && w.Chest!=null,"cleaned household loads");if(w==null || w.Chest==null)return;
        bool ok=true;
        for(int i=0;i<w.Targets.Size();i++)if(w.Targets[i].Furniture!=null && w.Targets[i].Furniture!=w.Chest)
            ok=ok && CaelumContaminationStorage.Value(w.Targets[i].Furniture)<30;
        Check(ok,"saving or returning after cleaning never resurrects the older dirty snapshot");
    }
    // CURRENT-ONLY-BEGIN
    void Migrated(CaelumPlayer u)
    {
        CheckPrior(u);let w=Work();
        Check(w!=null && w.Chest!=null && w.Chest.DomesticStorage.FurnishingRevision==0,
            "previous save has no invented furnishing history before its first departure");
    }
    void Away(CaelumPlayer u)
    {
        let store=CaelumHouseStorage.Get();let p=CA502FurnitureProof(u.FindInventory('CA502FurnitureProof'));
        Check(store!=null && store.Houses.Size()>0 && p!=null,"travelling household registry and fixture survived");if(store==null || p==null)return;
        let entry=store.Houses[0];
        Check(entry.FurnishingRevision==1 && entry.FurnishingsPending,"unload captures versioned furnishing state automatically");
        Check(entry.Furnishings.Size()==p.Keys.Size(),"one snapshot per actual furnishing with no floor or coffer duplication");
        int ready=0;for(int i=0;i<entry.Furnishings.Size();i++)if(entry.Furnishings[i].Ready)ready++;
        Check(ready>0,"exposed furnishings retain their source environment history");
        let clock=CaelumWorldClock.Get(u);clock.DayTics+=CaelumWorldClock.TicsPerHour();
        Check(Near(Money(entry.Chest),p.Money) && Near(Record(u).WorkedSeconds,p.Worked),"absence does not invent purchases or household work");
    }
    void Returned(CaelumPlayer u)
    {
        let w=Work();let p=CA502FurnitureProof(u.FindInventory('CA502FurnitureProof'));
        Check(w!=null && w.Chest!=null && p!=null,"real home and proof available after return");if(w==null || w.Chest==null || p==null)return;
        let entry=w.Chest.DomesticStorage;
        Check(!entry.FurnishingsPending,"restoration is consumed once");
        for(int j=0;j<p.Keys.Size();j++)
        {
            Actor body=null;CaelumDomesticCleanTarget target;
            for(int i=0;i<w.Targets.Size();i++)if(entry.TargetKey(w.Targets[i])==p.Keys[j]){target=w.Targets[i];body=target.Furniture;break;}
            Check(body!=null,String.Format("installation identity restored: %s",p.Keys[j]));if(body==null)continue;
            double value=CaelumContaminationStorage.Value(body);
            Check(value+0.00001>=p.Values[j] && (p.Values[j]>0 || value>0),String.Format("saved dirt and absent exposure survive: %s value=%.5f",p.Keys[j],value));
            Check(Near(target.Progress,11.25) && Near(target.Initial,95),"partial work accompanies the same furnishing");
            double before=value;entry.RestoreFurnishings(w,u);
            Check(Near(CaelumContaminationStorage.Value(body),before),"repeated restoration does not replay absence twice");
        }
        Check(Near(Money(w.Chest),p.Money) && Near(Record(u).WorkedSeconds,p.Worked),"return retains funds and daily quota");
    }
    void Core(CaelumPlayer u)
    {
        let w=Work();Check(w!=null && w.Chest!=null,"real household available for state edge checks");if(w==null || w.Chest==null)return;
        Actor body;for(int i=0;i<w.Targets.Size();i++)if(w.Targets[i].Furniture!=null && w.Targets[i].Furniture!=w.Chest){body=w.Targets[i].Furniture;break;}
        if(body==null)return;double now=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(u));
        CaelumContaminationStorage.Set(body,20);let record=CaelumContaminationStorage.Get(body);let node=record.Exposure;
        node.HistoryReady=true;node.HistoryStamp=now-10;node.HistoryAmbient=80;node.HistoryArea=.1;node.HistoryVariable=false;node.HistoryRain=0;
        let row=new('CaelumHouseStoredFurnishing');row.Capture(body,"fixture-test",now);
        Check(Near(row.Concentration,Sqrt(20*20+2*.1*.1*80*10)),"capture settles the preceding constant interval analytically");
        node.HistoryTemporaryClimate=true;node.HistoryNaturalAmbient=12;node.HistoryNaturalVariable=false;
        row.Capture(body,"fixture-test",now);
        Check(Near(row.Ambient,12) && !row.Variable,"temporary seal ends at departure without losing prior exposure");
        row.Concentration=0;row.Ambient=10;row.Area=.1;row.Stamp=now-10;row.Variable=false;row.Ready=true;
        row.Restore(body,now);
        Check(Near(CaelumContaminationStorage.Value(body),Sqrt(1+2*.1*.1*10*(10-10))),"constant replay respects the low-concentration floor");
        // At rate 0.1, ten seconds reach exactly one degree; no source caps are crossed.
        row.Ready=false;row.Concentration=37;row.Stamp=now-86400;row.Restore(body,now);
        Check(Near(CaelumContaminationStorage.Value(body),37),"missing historical sample starts now without retroactive dirt");
        row.BodyType='CaelumFoodRation';row.Concentration=99;row.Restore(body,now);
        Check(Near(CaelumContaminationStorage.Value(body),37),"different installation class cannot receive another object's state");
        let entry=w.Chest.DomesticStorage;entry.FurnishingsPending=false;CaelumContaminationStorage.Set(body,2);entry.RestoreFurnishings(w,u);
        Check(Near(CaelumContaminationStorage.Value(body),2),"a consumed snapshot never undoes later cleaning");
        Array<double> costs;double sum=0;
        for(int i=0;i<20;i++){double start=MSTimeF();entry.CaptureFurnishings(w,u);entry.RestoreFurnishings(w,u);double ms=MSTimeF()-start;costs.Push(ms);sum+=ms;}
        for(int i=1;i<costs.Size();i++)for(int j=i;j>0 && costs[j]<costs[j-1];j--){double v=costs[j];costs[j]=costs[j-1];costs[j-1]=v;}
        Console.Printf("CA502H TIMING furnishings=%d targets=%d mean_ms=%.6f p95_ms=%.6f max_ms=%.6f",entry.Furnishings.Size(),w.Targets.Size(),sum/20,costs[18],costs[19]);
        Check(entry.Furnishings.Size()>0 && !entry.FurnishingsPending,"repeated native boundary remains idempotent");
    }
    // CURRENT-ONLY-END
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502f_market')Market(u);else if(e.Name=='ca502f_seed')Seed(u);
        else if(e.Name=='ca502f_away')Away(u);else if(e.Name=='ca502f_back')Returned(u);else if(e.Name=='ca502f_core')Core(u);
        else if(e.Name=='ca502f_migrated')Migrated(u);else if(e.Name=='ca502f_clean')Clean(u);else if(e.Name=='ca502f_clean_saved')CleanSaved(u);else return;
        Console.Printf("CA502H RESULT passed=%d failed=%d",Passed,Failed);
    }
}
