// #414: pruebas nativas de conservación, referencia analítica y calendario.
class CA414RuntimeChecks : EventHandler
{
    int Passed,Failed;
    double SavedLeft,SavedRight,SavedStamp;
    bool FlowSeeded;
    override void WorldTick()
    {
        if(level.MapName!="MAP01" || level.maptime>70)return;
        for(int i=0;i<MAXPLAYERS;i++)
        {let u=CaelumPlayer(players[i].mo);if(u!=null)u.MainM00UnknownVoiceDelayTics=1000;}
    }
    void Check(bool ok,String name)
    {if(ok)Passed++;else Failed++;Console.Printf("CA414R %s %s",ok?"PASS":"FAIL",name);}
    CaelumConnectedWaterState NewState()
    {let model=new('CaelumConnectedWaterState');model.Initialize();return model;}
    void Finish(CaelumConnectedWaterState model,double seconds)
    {
        model.Advance(seconds);int steps=model.LastSteps,rounds=1;
        while(model.PendingSeconds>0 && rounds<100)
        {model.Advance(0);steps+=model.LastSteps;rounds++;}
        Console.Printf("CA414R SOLVE steps=%d rounds=%d remaining=%.9f left=%.9f right=%.9f",steps,rounds,model.PendingSeconds,model.Liters.X,model.Liters.Y);
        Check(model.PendingSeconds==0,"elapsed interval completed within bounded work");
    }
    void Numeric()
    {
        let model=NewState();
        Check(model.Liters==(28000,4000),"approved reference levels and capacities");
        model.Withdraw(0,100);model.Liters.Y+=100;Finish(model,40);
        Check(model.Liters==(27940,4060),"closed gate applies one litre per second");
        Finish(model,1000);Check(model.Liters==(28000,4000),"closed regulators stop at authored levels");
        model.Open=true;model.InflowLps=0;model.DrainLps=0;
        model.QualityA=CaelumWaterQuality.BIOLOGICAL;model.QualityB=CaelumWaterQuality.SALT;
        double coefficient=0.62*CaelumConnectedWaterData.PI*0.1*0.1*Sqrt(2*9.81);
        double expectedDiff=(Sqrt(1.5)-coefficient*40.0/16.0)**2;
        Finish(model,40);
        Check(Abs(model.Liters.X+model.Liters.Y-32000)<0.00001,"unforced transfer conserves volume");
        Check(Abs(model.Liters.X-model.Liters.Y-expectedDiff*16000)<0.001,"solution matches analytic Torricelli equal-area reference");
        Check(model.QualityA==1 && model.QualityB==3,"transferred contamination mixes without backflow");
        Finish(model,86400*365);
        Check(Abs(model.Liters.X-16000)<0.001 && Abs(model.Liters.Y-16000)<0.001,"long unforced interval equalizes without overshoot");
        model=NewState();model.Open=true;Finish(model,86400*365);
        double head=(0.001/coefficient)**2;
        Check(Abs(model.Liters.X+model.Liters.Y-32000)<0.001,"balanced supply and drain preserve total");
        Check(Abs((model.Liters.X-model.Liters.Y)/16000-head)<0.000001,"regulated steady state retains the physical head");
        let split=NewState();split.Open=true;for(int i=0;i<60;i++)Finish(split,1);
        let batch=NewState();batch.Open=true;Finish(batch,60);
        Check((batch.Liters-split.Liters).Length()<0.001,"partitioned elapsed time matches a single advance");
        model=NewState();model.Open=true;model.InflowLps=0;model.DrainLps=0;model.Liters=(1000,3000);
        Check(model.FlowLps(model.Liters)<0,"partially submerged circular opening permits reverse flow");
        Finish(model,100);Check(Abs(model.Liters.X+model.Liters.Y-4000)<0.001,"partial opening preserves total water");
        double before=model.Liters.X;
        Check(model.Withdraw(0,100000)==before && model.Liters.X==0,"withdrawal is bounded by actual water");
        Check(model.QualityA==CaelumWaterQuality.POTABLE,"empty reservoir clears its previous contents");
    }
    void Result(){Console.Printf("CA414R RESULT passed=%d failed=%d map=%s",Passed,Failed,level.MapName);}
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CurrentThirst=100;
        for(let item=u.Inv;item!=null;item=item.Inv)
        {let bottle=CaelumWaterContainer(item);if(bottle!=null)bottle.InMagicBox=true;}
        u.SetOrigin((64,192,64),false);u.Vel=(0,0,0);
        let installation=CaelumConnectedWaterMap.Get();
        Check(installation!=null,"marked map initializes its saved controller");
        if(installation==null)return;
        Check(installation.Water!=null && installation.Revision==1,"revisioned state initialized");
        Check(installation.Models[0]!=null && installation.Models[1]!=null,"control sectors located by authored metadata");
        Check(Abs(installation.Models[0].CenterCeiling()-56)<0.001 && Abs(installation.Models[1].CenterCeiling()-8)<0.001,"native surfaces match approved levels");
        Check(installation.GateControl!=null,"authored gate control spawned");
        let saved=installation.Water;CaelumConnectedWaterMap.Initialize();
        Check(CaelumConnectedWaterMap.Get()==installation && installation.Water==saved,"repeated initialization preserves controller and water identity");
    }
    void Calendar(CaelumPlayer u)
    {
        let installation=CaelumConnectedWaterMap.Get();if(installation==null)return;
        let clock=CaelumWorldClock.Get(u,true);installation.Sync(clock);
        installation.Water.Withdraw(0,1000);installation.Water.Liters.Y=5000;
        clock.AdvanceTics(CaelumWorldClock.TicsPerHour()/60);installation.Sync(clock);
        Check((installation.Water.Liters-(27060,4940)).Length()<0.00001,"one game minute applies exactly sixty litres of supply and drain");
        vector2 once=installation.Water.Liters;installation.Sync(clock);
        Check(installation.Water.Liters==once,"same timestamp does not duplicate elapsed time");
        installation.Stamp+=60;installation.Sync(clock);
        Check(installation.Water.Liters==once,"backward timestamp cannot create water or reverse time");
        installation.Stamp-=60;installation.Water=NewState();installation.ApplyLevels();
        u.SetOrigin((192,224,64),false);u.Angle=270;u.Pitch=0;u.Vel=(0,0,0);
        Check(installation.GateControl.Used(u) && installation.Water.Open,"normal aimed use opens gate");
        Check(CaelumInteractionHint.ForActor(u,installation.GateControl).IndexOf("{bind:+use}")>=0,"gate action hint uses the current key-binding formatter");
        clock.AdvanceTics(CaelumWorldClock.TicsPerHour()/60);installation.Sync(clock);
        Check(installation.Water.Liters.X<28000 && installation.Water.Liters.Y>4000,"open gate transfers over the actual game clock");
        Check(installation.GateControl.Used(u) && !installation.Water.Open,"second normal use closes gate");
        u.Angle=90;Check(!installation.GateControl.Used(u),"looking away cannot operate gate");
        installation.Water=NewState();installation.ApplyLevels();u.SetOrigin((64,64,0),false);u.Vel=(0,0,0);
    }
    void Immersion(CaelumPlayer u)
    {
        let installation=CaelumConnectedWaterMap.Get();if(installation==null)return;
        Check(u.WaterLevel==3,"native immersion detects the raised surface");
        Check(CaelumWaterQuality.Model(u)==installation.Models[0],"water source resolves the actual swimmable 3D floor");
        installation.Water.QualityA=CaelumWaterQuality.BIOLOGICAL|CaelumWaterQuality.CHEMICAL;
        Check(CaelumWaterQuality.Source(u)==5,"source reports dynamic reservoir contaminants");
        let bottle=CaelumBottleSmall(u.FindInventory('CaelumBottleSmall'));
        if(bottle==null)bottle=CaelumBottleSmall(u.GiveInventoryType('CaelumBottleSmall'));
        Check(bottle!=null,"test bottle acquired");if(bottle==null)return;
        bottle.InMagicBox=false;bottle.WaterLiters=0;bottle.WaterQuality=0;
        installation.Sync(CaelumWorldClock.Get(u));double before=installation.Water.Liters.X;
        Check(bottle.FillFromSource(u) && bottle.WaterLiters==1 && bottle.WaterQuality==5,"explicit refill collects contaminated water with its identity");
        Check(Abs(before-installation.Water.Liters.X-1)<0.00001,"refill deducts exactly the bottle volume from reservoir");
        before=installation.Water.Liters.X;
        Check(!bottle.FillFromSource(u) && installation.Water.Liters.X==before,"full bottle cannot drain the reservoir");
        bottle.WaterLiters=0;bottle.InMagicBox=true;
        Check(!bottle.FillFromSource(u) && installation.Water.Liters.X==before,"boxed bottle cannot drain the reservoir");
        Check(CaelumWaterQuality.DrinkSource(u,1)==0 && installation.Water.Liters.X==before,"contaminated source cannot hydrate directly");
        installation.Water.QualityA=0;
        double recovered=CaelumWaterQuality.DrinkSource(u,1);
        double perLiter=CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE*CaelumConstants.CONSUMABLE_REGENERATION_SECONDS/u.DerivedStats.BaseMass;
        Check(Abs(recovered-1)<0.00001 && Abs(before-installation.Water.Liters.X-1/perLiter)<0.00001,"direct hydration uses the accepted container litres-to-thirst ratio");
        before=installation.Water.Liters.X;
        Check(CaelumWaterQuality.DrinkSource(u,0)==0 && installation.Water.Liters.X==before,"full hydration requests no water");
        installation.Water.Liters.X=0;installation.Water.InflowLps=0;installation.ApplyLevels();
    }
    void Dry(CaelumPlayer u)
    {
        Check(u.WaterLevel==0,"native immersion clears after the reservoir empties");
        Check(CaelumWaterQuality.Source(u)==CaelumWaterQuality.UNIDENTIFIED,"empty reservoir is not a usable water source");
        let installation=CaelumConnectedWaterMap.Get();installation.Water=NewState();installation.ApplyLevels();
        u.SetOrigin((64,192,64),false);u.Vel=(0,0,0);
    }
    void Seed(CaelumPlayer u)
    {
        let installation=CaelumConnectedWaterMap.Get();installation.Sync(CaelumWorldClock.Get(u));
        installation.Water.Liters=(22000,10000);installation.Water.QualityA=1;installation.Water.QualityB=2;
        installation.Water.Open=false;installation.Water.InflowLps=0;installation.Water.DrainLps=0;
        installation.ApplyLevels();SavedLeft=22000;SavedRight=10000;SavedStamp=installation.Stamp;
        Check(installation.Revision==1,"seeded revisioned save checkpoint");
    }
    void Loaded(CaelumPlayer u)
    {
        let installation=CaelumConnectedWaterMap.Get();
        Check(installation!=null && installation.Revision==1,"saved controller rebound after restore");if(installation==null)return;
        Check(installation.Water.Liters==(SavedLeft,SavedRight) && SavedLeft==22000,"saved reservoir contents survive save and hub transitions");
        Check(installation.Water.QualityA==1 && installation.Water.QualityB==2 && !installation.Water.Open,"saved contamination and gate state survive");
        Check(Abs(installation.Models[0].CenterCeiling()-44)<0.001 && Abs(installation.Models[1].CenterCeiling()-20)<0.001,"saved native water planes agree with contents");
        Check(installation.Stamp>=SavedStamp,"restored clock remains monotonic");
    }
    void Mansion(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CurrentThirst=100;
        u.RecordMainM00UnknownVoiceHeard();u.health=u.CaelumMaximumHealth;u.player.health=u.health;u.CurrentAir=u.DerivedStats.MaximumAir;u.UpdateHealthStateEffects();
        let record=u.GetPersistentCharacterState(false);
        u.SetOrigin(CaelumCartographyCatalogueData.MansionPosition(0),false);
        CaelumAuthoredCartography.Update(u,record);
        Check(CaelumCartographyCatalogueData.MatchesMansionGeometry(level.GetChecksum())
            && CaelumPoiKnowledge.Find(record,"MAP01","mansion-room-"..CaelumCartographyCatalogueData.MansionId(0))!=null,
            "new mansion geometry retains authored room discovery");
        let installation=CaelumConnectedWaterMap.Get();
        Check(installation!=null,"campaign installation initialized");if(installation==null)return;
        Check(installation.Models[0].CenterFloor()==-64 && installation.Models[1].CenterFloor()==-64,"campaign basins have approved two metre depth");
        Check(Abs(installation.Models[0].CenterCeiling()+8)<0.001 && Abs(installation.Models[1].CenterCeiling()+56)<0.001,"campaign surfaces match approved initial water");
        Check(installation.GateModel!=null && Abs(installation.GateModel.CenterCeiling()+57.6)<0.001,"circular connection begins with native closed gate");
        u.SetOrigin((3552,-4,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
        Check(installation.GateControl.Used(u) && installation.Water.Open,"campaign lever reachable from existing pool path");
        Check(Abs(installation.GateModel.CenterCeiling()+64)<0.001,"opening the lever retracts native gate geometry");
        Check(installation.GateControl.Used(u) && !installation.Water.Open,"campaign lever can close again");
        for(int basin=0;basin<2;basin++)
        {
            double y=basin==0?92:-44;
            u.SetOrigin((3736,y,-64),false);u.Vel=(0,0,0);bool clear=true;
            // Consulta nativa de colisión por cada paso, sin impulso de salto.
            for(int i=0;i<64;i++)
            {
                if(!u.TryMove(u.Pos.XY+(-2,0),0)){clear=false;break;}
                if(u.FloorZ>u.Pos.Z)u.SetOrigin((u.Pos.X,u.Pos.Y,u.FloorZ),false);
            }
            Check(clear && u.Pos.X<=3608 && u.Pos.Z>=0,basin==0?"north service steps provide native collision clearance":"south service steps provide native collision clearance");
        }
        u.SetOrigin((3488,-4,128),false);u.Angle=0;u.Pitch=35;u.Vel=(0,0,0);u.bNoGravity=true;
    }
    void FlowSeed(CaelumPlayer u)
    {
        let installation=CaelumConnectedWaterMap.Get();installation.Sync(CaelumWorldClock.Get(u));
        installation.Water=NewState();installation.Water.Open=true;
        installation.Water.QualityA=1;installation.Water.QualityB=2;
        installation.ApplyLevels();SavedStamp=installation.Stamp;FlowSeeded=true;
        Check(FlowSeeded,"open flowing state seeded for unloaded catch-up");
    }
    void FlowLoaded(CaelumPlayer u)
    {
        let installation=CaelumConnectedWaterMap.Get();installation.Sync(CaelumWorldClock.Get(u));
        Check(FlowSeeded && installation.Water.Open,"open gate state survives save or hub return");
        let expected=NewState();expected.Open=true;Finish(expected,installation.Stamp-SavedStamp);
        Check((installation.Water.Liters-expected.Liters).Length()<0.001,"saved or unloaded elapsed flow equals independent numerical reference");
        Check(installation.Water.QualityA==1 && installation.Water.QualityB==3,"directional contamination survives elapsed transfer");
    }
    void Report()
    {
        let installation=CaelumConnectedWaterMap.Get();if(installation==null)return;
        vector2 heights=installation.Water.Heights(installation.Water.Liters);
        Console.Printf("CA414R WATER north=%.3f L / %.4f m south=%.3f L / %.4f m open=%d pending=%.6f s",installation.Water.Liters.X,heights.X,installation.Water.Liters.Y,heights.Y,installation.Water.Open,installation.Water.PendingSeconds);
    }
    void AuthorStart(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.RecordMainM00UnknownVoiceHeard();u.health=u.CaelumMaximumHealth;u.player.health=u.health;u.CurrentAir=u.DerivedStats.MaximumAir;u.UpdateHealthStateEffects();
        let bottle=CaelumBottleSmall(u.FindInventory('CaelumBottleSmall'));
        if(bottle==null)bottle=CaelumBottleSmall(u.GiveInventoryType('CaelumBottleSmall'));
        if(bottle!=null){bottle.InMagicBox=false;bottle.WaterLiters=0;bottle.WaterQuality=0;}
        u.bNoGravity=false;u.SetOrigin((3552,-4,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);Report();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca414r_numeric'){Numeric();Result();}
        else if(e.Name=='ca414r_prepare'){Prepare(u);Result();}
        else if(e.Name=='ca414r_calendar'){Calendar(u);Result();}
        else if(e.Name=='ca414r_immersion'){Immersion(u);Result();}
        else if(e.Name=='ca414r_dry'){Dry(u);Result();}
        else if(e.Name=='ca414r_seed'){Seed(u);Result();}
        else if(e.Name=='ca414r_loaded'){Loaded(u);Result();}
        else if(e.Name=='ca414r_mansion'){Mansion(u);Result();}
        else if(e.Name=='ca414r_quiet'){u.RecordMainM00UnknownVoiceHeard();}
        else if(e.Name=='ca414r_flowseed'){FlowSeed(u);Result();}
        else if(e.Name=='ca414r_flowloaded'){FlowLoaded(u);Result();}
        else if(e.Name=='ca414r_hour'){CaelumWorldClock.Get(u,true).AdvanceTics(CaelumWorldClock.TicsPerHour());Report();Result();}
        else if(e.Name=='ca414r_report'){Report();Result();}
        else if(e.Name=='ca414r_pool'){u.SetOrigin((3000,400,-128),false);u.bNoGravity=false;u.Vel=(0,0,0);}
        else if(e.Name=='ca414r_poolcheck'){Check(u.WaterLevel==3 && CaelumWaterQuality.Source(u)==0,"existing mansion pool remains identified potable water");Result();}
        else if(e.Name=='ca414r_author'){AuthorStart(u);Result();}
        else if(e.Name=='ca414r_dock'){u.bNoGravity=false;u.SetOrigin((3552,-4,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);}
        else if(e.Name=='ca414r_north' || e.Name=='ca414r_south'){u.bNoGravity=false;u.SetOrigin((3736,e.Name=='ca414r_north'?32:-104,-64),false);u.Vel=(0,0,0);}
        else if(e.Name=='ca414r_minute'){CaelumWorldClock.Get(u,true).AdvanceTics(CaelumWorldClock.TicsPerHour()/60);CaelumConnectedWaterMap.Get().Sync(CaelumWorldClock.Get(u));Report();}
        else if(e.Name=='ca414r_overview'){u.bNoGravity=true;u.SetOrigin((3488,-4,128),false);u.Angle=0;u.Pitch=35;u.Vel=(0,0,0);}
    }
}
