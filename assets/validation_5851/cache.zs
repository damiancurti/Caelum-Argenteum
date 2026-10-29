// Compare the original per-step commits with retained frames at identical dates.
class CA415CacheChecks : EventHandler
{
    CA415RoundSoldier Baseline,Retained;
    int Passed,Failed;
    void Check(bool result,String label)
    {if(result)Passed++;else Failed++;Console.Printf("CA415C %s %s",result?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<.0000001;}
    void Prepare(CaelumPlayer user)
    {
        Baseline=CA415RoundSoldier(Actor.Spawn('CA415RoundSoldier',(128,48,0),NO_REPLACE));
        Retained=CA415RoundSoldier(Actor.Spawn('CA415RoundSoldier',(128,208,0),NO_REPLACE));
        for(int i=0;i<2;i++)
        {
            let owner=i==0?Baseline:Retained;
            let food=Inventory(Actor.Spawn('CaelumFoodRation',owner.Pos,NO_REPLACE));food.Amount=3;food.AttachToOwner(owner);
        }
    }
    void Compare(CaelumPlayer user,bool partial=false)
    {
        for(int i=0;i<2;i++)
        {
            let owner=i==0?Baseline:Retained;owner.bBuddha=true;owner.CombatToughness=0;
            CaelumContaminationStorage.Set(owner,72);CaelumContaminationAbsence.Capture(owner,user);
            let row=owner.ContaminationAbsence;row.Map="MAP03";row.Idle=true;
        }
        let a=Baseline.ContaminationAbsence;let b=Retained.ContaminationAbsence;
        double start=a.Stamp,oldTime=MSTimeF();
        for(int i=1;i<=4320;i++)a.SyncTo(Baseline,start+i*20);
        double original=MSTimeF()-oldTime;oldTime=MSTimeF();
        for(int i=1;i<=(partial?2160:4320);i++)b.SyncTo(Retained,start+i*20,true);
        Check(b.SyncPrepared,"paused dispatcher keeps its serialized frame between pulses");
        if(partial){level.setFrozen(true);return;}
        b.CommitSync(Retained);double retainedTime=MSTimeF()-oldTime;
        Verify();
        Console.Printf("CA415C TIMING original_ms=%.6f retained_ms=%.6f",original,retainedTime);
    }
    void Verify()
    {
        let a=Baseline.ContaminationAbsence;let b=Retained.ContaminationAbsence;
        Check(!b.SyncPrepared,"chronological boundary commits the retained inventory");
        Check(a.Life==b.Life && Near(a.Stamp,b.Stamp) && Near(a.Civil,b.Civil),"one-day Life and clocks match prior per-step commits");
        Check(Near(CaelumContaminationStorage.Value(Baseline),CaelumContaminationStorage.Value(Retained)),"one-day body contamination matches prior commits");
        Check(Near(Baseline.IdleHealthAccumulator,Retained.IdleHealthAccumulator) && Near(a.ActiveFraction,b.ActiveFraction),"fractional recovery and active tics remain identical");
        Check(a.Exposure.Frame.Items.Size()==b.Exposure.Frame.Items.Size(),"exposure inventory cardinality retained");
        for(int i=0;i<a.Exposure.Frame.Items.Size();i++)
            Check(Near(a.Exposure.Frame.Items[i].Endpoint.Value(),b.Exposure.Frame.Items[i].Endpoint.Value()),"one-day equipment contamination matches prior commits");
        let fa=CaelumConsumableItem(Baseline.FindInventory('CaelumFoodRation'));
        let fb=CaelumConsumableItem(Retained.FindInventory('CaelumFoodRation'));
        Check(fa.Amount==fb.Amount,"food quantity unchanged by retained ownership");
        let la=CaelumFoodInventory.Prepare(fa);let lb=CaelumFoodInventory.Prepare(fb);
        Check(la!=null && lb!=null,"food lots remain native");
        Check(la.Lots.Size()==lb.Lots.Size() && Near(la.Exposure,lb.Exposure),"food lot history has identical exposure");
        for(int i=0;i<la.Lots.Size();i++)
            Check(Near(la.Contamination(i),lb.Contamination(i)) && la.Lots[i].Units==lb.Lots[i].Units,"food contamination and lot amounts remain identical");
    }
    void Reload()
    {
        let a=Baseline.ContaminationAbsence;let b=Retained.ContaminationAbsence;
        Check(b.SyncPrepared && b.Stamp<a.Stamp,"native save preserves a partially advanced owned frame");
        while(b.Stamp<a.Stamp)b.SyncTo(Retained,Min(a.Stamp,b.Stamp+20),true);
        b.CommitSync(Retained);Verify();level.setFrozen(false);
    }
    bool SameThermal(CaelumThermalState a,CaelumThermalState b)
    {
        if(!Near(a.Exposure,b.Exposure) || !Near(a.Acclimation,b.Acclimation) || !Near(a.Hydration,b.Hydration)
            || !Near(a.DrinkRemaining,b.DrinkRemaining) || !Near(a.ShiveringHunger,b.ShiveringHunger)
            || a.Severity!=b.Severity || !Near(a.Conductance,b.Conductance) || !Near(a.Imbalance,b.Imbalance))return false;
        for(int i=0;i<4;i++)if(!Near(a.WorkWaterKg[i],b.WorkWaterKg[i]))return false;
        return true;
    }
    void Thermal()
    {
        let cache=new('CaelumAbsentThermal');
        for(int scenario=0;scenario<20;scenario++)
        {
            let source=CaelumThermalService.CaptureForecast(Baseline);
            source.Available=scenario!=0;source.Exposure=scenario-10;source.Hydration=20+scenario;
            source.AirC=source.ClimateC=5+scenario;source.WindMps=scenario/3.0;source.RainMmHour=scenario;
            source.Roof=scenario%2==0;source.CanBreathe=scenario%3==0;source.BreathingAirRatio=scenario/20.0;
            source.DrinkRemaining=scenario/10.0;source.DrinkOffset=5;source.ShiveringHungerPerMetSecond=.001;
            source.ShiveringHunger=50;source.WorkWaterKg[1]=scenario*.001;
            source.SubmergedCoverage[3]=source.Coverage[3]*.5;source.SubmergedTemperatureC[3]=12;
            let a=source.CopyForForecast();let b=source.CopyForForecast();let c=source.CopyForForecast();
            a.SurfaceC=b.SurfaceC=c.SurfaceC=13;a.SurfaceCoverage[0]=b.SurfaceCoverage[0]=c.SurfaceCoverage[0]=.03;
            double expected=CaelumThermalService.Integrate(a,20,1,scenario,scenario*2,scenario*3,0,scenario*4);
            double first=cache.Integrate(b,scenario,20,1,scenario,scenario*2,scenario*3,scenario*4);
            int hits=cache.Hits;
            double second=cache.Integrate(c,scenario,20,1,scenario,scenario*2,scenario*3,scenario*4);
            Check(SameThermal(a,b) && SameThermal(a,c) && Near(expected,first) && Near(expected,second),"memoized thermal reserves and severity dose equal native integration");
            Check(cache.Hits==hits+1,"only an identical physical input reuses its thermal calculation");
            let d=source.CopyForForecast();d.SurfaceC=13;d.SurfaceCoverage[0]=.03;d.WorkWaterKg[1]+=.001;
            int misses=cache.Misses;cache.Integrate(d,scenario,20,1,scenario,scenario*2,scenario*3,scenario*4);
            Check(cache.Misses==misses+1,"changed individual clothing water invalidates shared result");
        }
        Console.Printf("CA415C THERMAL hits=%d misses=%d",cache.Hits,cache.Misses);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);
        if(e.Name=="ca415c_prepare"){Prepare(user);return;}
        if(e.Name=="ca415c_compare")Compare(user);else if(e.Name=="ca415c_thermal")Thermal();
        else if(e.Name=="ca415c_partial")Compare(user,true);else if(e.Name=="ca415c_reload")Reload();else return;
        Console.Printf("CA415C RESULT passed=%d failed=%d",Passed,Failed);
    }
}
