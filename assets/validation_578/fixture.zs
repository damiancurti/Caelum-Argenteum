class CA479Checks : EventHandler
{
    int Passed,Failed;
    CaelumSupportEffectState Saved;
    double SavedHealth;

    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA479 %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.00000001;}
    CaelumSupportEffectState Fresh(){return new("CaelumSupportEffectState");}

    void Checks()
    {
        Check(Near(CaelumSupportImplementData.Power(0),1),"M2 zero");
        Check(Near(CaelumSupportImplementData.Power(100),4),"M2 hundred");
        Check(Near(CaelumSupportImplementData.Power(150),7.3),"M2 effective levels remain uncapped");
        Check(CaelumSupportImplementData.Essence()==CaelumConstants.ESSENCE_QUINTESSENCE,"Quintessence identity");
        Check(CaelumSupportImplementData.BaseRadius()==128,"authoritative explosion radius");
        Check(CaelumSupportImplementData.PreparationTics()==14,"authoritative preparation cycle");
        for(int role=0;role<4;role++)
        {
            Check(CaelumSupportImplementData.Beneficial(role)==(role==1 || role==2),String.Format("polarity role %d",role));
            Check(CaelumSupportImplementData.Area(role)==(role<2),String.Format("area role %d",role));
            Check(CaelumSupportImplementData.SecondaryModifiers(role)==(role>=2),String.Format("secondary role %d",role));
            for(int tier=1;tier<=3;tier++)
                Check(Near(CaelumSupportImplementData.BaseAnimaCost(role,tier),(role<2?70:100)*(tier==3?2.5:tier==2?1.6:1)),
                    String.Format("cost role %d tier %d",role,tier));
        }
        Check(CaelumSupportImplementData.BaseAnimaCost(-1,1)==0 && CaelumSupportImplementData.BaseAnimaCost(4,1)==0,"invalid role rejected");
        Check(CaelumSupportImplementData.BaseAnimaCost(0,0)==0 && CaelumSupportImplementData.BaseAnimaCost(0,4)==0,"invalid tier rejected");
        let effect=Fresh();
        Check(!effect.Active() && effect.Factor()==1,"empty effect neutral");
        Check(effect.Apply(0) && effect.Revision==1,"initial revision");
        Check(Near(effect.IntensityPercent,1) && Near(effect.RemainingSeconds,1),"base application");
        double total=0;for(int i=0;i<TICRATE;i++)total+=effect.Advance(1.0/TICRATE,73);
        Check(Near(total,0.73),"fractional health survives per-tic integration");
        Check(!effect.Active() && effect.Factor()==1,"exact expiry neutralizes factor");
        Check(effect.Advance(5,1000)==0,"expired effect never repeats health");
        effect.Apply(100);total=effect.Advance(0.25,1000);
        Check(Near(total,10) && Near(effect.RemainingSeconds,3.75),"scaled potency and duration");
        effect.Apply(0);
        Check(Near(effect.IntensityPercent,5) && Near(effect.RemainingSeconds,1),"mixed caster stack refreshes new duration");
        Check(Near(effect.Factor(),1.05),"scaled secondary factor");
        Check(Near(effect.Advance(0.5,200),5),"current maximum sampled first segment");
        Check(Near(effect.Advance(0.5,400),10),"changed maximum sampled second segment");
        effect.Apply(0);Check(Near(effect.IntensityPercent,1),"expired intensity starts anew");
        double remaining=effect.RemainingSeconds;
        Check(effect.Advance(0,100)==0 && effect.Advance(-1,100)==0 && effect.RemainingSeconds==remaining,"invalid elapsed time is inert");
        Check(Near(effect.Advance(100,1000),10) && !effect.Active(),"elapsed overshoot clipped to expiry");
        effect.Apply(0);Check(effect.Advance(0.5,-10)==0 && Near(effect.RemainingSeconds,0.5),"negative maximum does not produce health");
        effect=Fresh();for(int i=0;i<100;i++)effect.Apply(0);
        Check(Near(effect.IntensityPercent,100) && Near(effect.Factor(),2),"hundred percent doubles factor without cap");
        let curse=Fresh();curse.Apply(100);
        Check(Near(effect.Factor()/curse.Factor(),2.0/1.04),"independent benefit and curse coexist");
        double before=effect.Factor();effect.EnsureRevision();effect.EnsureRevision();
        Check(effect.Factor()==before && effect.RemainingSeconds==1,"revision normalization idempotent");
        curse.Revision=2;double oldIntensity=curse.IntensityPercent;
        Check(!curse.Apply(0) && curse.Advance(1,1000)==0 && curse.IntensityPercent==oldIntensity,"unknown revision preserved without execution");
        Console.Printf("CA479 RESULT model passed=%d failed=%d",Passed,Failed);
    }

    override void NetworkProcess(ConsoleEvent event)
    {
        if(level.MapName!="CSUP479")return;
        if(event.Name=="ca479_checks")Checks();
        if(event.Name=="ca479_save")
        {
            Saved=Fresh();Saved.Apply(100);SavedHealth=Saved.Advance(0.125,73);
            Console.Printf("CA479 RESULT save prepared");
        }
        if(event.Name=="ca479_load")
        {
            Check(Saved!=null,"effect reference serialized");
            if(Saved!=null)
            {
                Check(Saved.Revision==1 && Near(Saved.IntensityPercent,4),"revision and intensity serialized");
                Check(Near(Saved.RemainingSeconds,3.875) && Near(SavedHealth,0.365),"fractional duration and health serialized");
                SavedHealth+=Saved.Advance(10,73);
                Check(Near(SavedHealth,11.68) && !Saved.Active(),"resume equals uninterrupted integration");
                Check(Saved.Advance(1,73)==0,"load does not duplicate expiry");
            }
            Console.Printf("CA479 RESULT load passed=%d failed=%d",Passed,Failed);
        }
    }
}
