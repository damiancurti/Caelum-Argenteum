// Isolated numerical and native ownership probe, never packaged in production.
class CA133SweatReload : StaticEventHandler
{
    bool HasTravelSnapshot;
    double TravelThirst,TravelSweat,TransitionPassiveThirst;
    override void WorldUnloaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);let state=CaelumThermalBody.Get(user);
        if(user==null || state==null)return;
        HasTravelSnapshot=true;TravelThirst=user.CurrentThirst;TravelSweat=state.SweatKg;
        TransitionPassiveThirst=100.0/(CaelumConstants.THIRST_EMPTY_GAME_HOURS
            *CaelumWorldClock.SecondsPerGameHour(level.MapName))*user.DerivedStats.HungerThirstLossMultiplier/TICRATE;
        Console.Printf("CA133 SWEAT_LEAVE map=%s thirst=%.9f sweat=%.9f",level.MapName,TravelThirst,TravelSweat);
    }
    override void WorldLoaded(WorldEvent e)
    {
        if((!e.IsSaveGame && !e.IsReopen) || level.MapName!="CA133")return;
        let body=CaelumCombatActor(ThinkerIterator.Create("CaelumMandinga").Next());
        let user=CaelumPlayer(players[0].mo);
        let n=CaelumThermalBody.Get(body,true);let p=CaelumThermalBody.Get(user,true);
        Console.Printf("CA133 SWEAT_LOAD save=%d reopen=%d npcHydration=%.9f npcSweat=%.9f npcRunoff=%.9f playerThirst=%.9f playerSweat=%.9f",e.IsSaveGame,e.IsReopen,n==null ? -1 : n.Hydration,n==null ? -1 : n.SweatKg,n==null ? -1 : n.SweatRunoffKg,user==null ? -1 : user.CurrentThirst,p==null ? -1 : p.SweatKg);
        // One final source-map player tic runs after WorldUnloaded in this
        // fixture. Account for its normal passive loss, not extra sweat.
        double expectedThirst=e.IsReopen && HasTravelSnapshot ? TravelThirst-TransitionPassiveThirst : 33.7;
        double expectedSweat=e.IsReopen && HasTravelSnapshot ? TravelSweat : 0.234;
        Console.Printf("CA133 SWEAT_EXPECT captured=%d thirst=%.9f sweat=%.9f",HasTravelSnapshot,expectedThirst,expectedSweat);
        bool ok=n!=null && p!=null && Abs(n.Hydration-43.25)<1e-8 && Abs(n.SweatKg-0.123)<1e-8
            && Abs(n.SweatRunoffKg-0.004)<1e-8 && Abs(user.CurrentThirst-expectedThirst)<1e-8 && Abs(p.SweatKg-expectedSweat)<1e-8;
        Console.Printf("CA133 %s native player and NPC sweat persistence",ok ? "PASS" : "FAIL");
        Console.Printf("CA133 SWEAT_RELOAD checks=1 failures=%d reopen=%d",int(!ok),e.IsReopen);
    }
}
class CA133Sweat : EventHandler
{
    int Checks,Failures;
    CaelumPlayer User;
    CaelumCombatActor NPC;
    bool Finished;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA133 %s %s",ok ? "PASS" : "FAIL",label);}
    bool Near(double a,double b,double tolerance=0.00000001){return Abs(a-b)<=tolerance;}
    CaelumThermalState Sample(double exposure=8)
    {
        let s=new("CaelumThermalState");s.Initialize();s.Sweats=true;s.Available=true;
        s.BodyMassKg=80;s.HeightMeters=1.75;s.SurfaceArea=CaelumThermalRules.Area(80,1.75);
        s.Inertia=CaelumThermalRules.Inertia(80);s.ComfortC=22;s.ClimateC=22;s.AirC=28;
        s.WindMps=1;s.Humidity=40;s.Roof=true;s.Exposure=exposure;s.Hydration=100;
        s.Coverage[0]=1;s.Material[0]=CaelumThermalData.LIGHT_CLOTH;
        return s;
    }
    double Stored(CaelumThermalState s)
    {double result=0;for(int i=0;i<4;i++)result+=s.WorkWaterKg[i];return result;}
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame || !Finished)return;
        let s=CaelumThermalBody.Get(NPC,true);
        Check(Near(s.Hydration,43.25) && Near(s.SweatKg,0.123) && Near(s.SweatRunoffKg,0.004),"native save retains NPC hydration and sweat budgets");
        let p=CaelumThermalBody.Get(User,true);
        Check(Near(User.CurrentThirst,33.7) && Near(p.SweatKg,0.234),"native save retains player authoritative Thirst and sweat");
        Console.Printf("CA133 SWEAT_RELOAD checks=%d failures=%d",Checks,Failures);
    }
    override void WorldTick()
    {
        if(level.time==1)
        {
            User=CaelumPlayer(players[0].mo);User.InitializeDirectMapCharacter();User.PersistCharacterState();
            User.CreationWizardOpen=true;
            let marker=Actor.Spawn("CaelumClimateRegion",(0,0,0),NO_REPLACE);marker.args[0]=1;marker.args[1]=5;
            NPC=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(7000,7000,0),NO_REPLACE));NPC.tics=-1;
        }
        if(level.time!=90 || Finished)return;
        double a=CaelumThermalRules.Area(80,1.75);
        Check(Near(CaelumThermalRules.SweatRate(5,a,100),2),"reference maximum is two litres per world hour");
        Check(Near(CaelumThermalRules.SweatRate(2.5,a,100),1),"heat-response ramp reaches half rate at E=2.5");
        Check(CaelumThermalRules.SweatRate(-1,a,100)==0 && CaelumThermalRules.SweatRate(0,a,100)==0,"cold and neutral bodies produce no regulated sweat");
        Check(Near(CaelumThermalRules.SweatRate(50,a,100),2),"extreme exposure cannot exceed production ceiling");
        Check(Near(CaelumThermalRules.SweatRate(5,a,10),1) && CaelumThermalRules.SweatRate(5,a,0)==0,"hydration fades below twenty and cannot cool from an empty reserve");
        Check(Near(CaelumThermalRules.SweatRate(5,a*2,100),4),"sweat production scales with external surface area");
        Check(Near(CaelumThermalRules.HydrationPointsPerKg(80)*0.2,10) && Near(CaelumThermalRules.HydrationPointsPerKg(160)*0.2,5),"water loss is inverse to the existing drinking conversion");
        let dry=Sample();let humid=dry.CopyForForecast();humid.Humidity=100;
        CaelumThermalService.Integrate(dry,120,6);CaelumThermalService.Integrate(humid,120,6);
        Check(dry.EvaporatedKg>humid.EvaporatedKg && dry.Exposure<humid.Exposure,"humid air limits evaporative cooling");
        Check(humid.SweatKg>0 && Stored(humid)>0 && humid.Hydration<100,"sweat spends hydration and wets clothing when evaporation is limited");
        Check(Near(dry.SweatKg,Stored(dry)+dry.SweatRunoffKg+dry.EvaporatedKg),"secreted water equals retained plus evaporated plus runoff");
        Check(Near(100-dry.Hydration,dry.SweatKg*50) && Near(dry.EvaporationJoules,dry.EvaporatedKg*2450000,0.000001),"water and latent energy are charged exactly once");
        let wet=Sample();wet.SubmergedCoverage[0]=1;wet.SubmergedTemperatureC[0]=40;
        CaelumThermalService.Integrate(wet,1,0);
        Check(wet.SweatKg>0 && Near(wet.SweatRunoffKg,wet.SweatKg) && wet.EvaporatedKg==0 && wet.Hydration<100,"immersed sweat spends water without evaporative cooling");
        let cold=Sample(-3);cold.AirC=10;CaelumThermalService.Integrate(cold,60,3);
        Check(cold.SweatKg==0 && cold.Hydration==100,"cold exposure does not secrete sweat");
        let paused=Sample();CaelumThermalService.Integrate(paused,0,0);
        Check(paused.SweatKg==0 && paused.Exposure==8 && paused.Hydration==100,"zero elapsed time creates no sweat or cooling");
        let unknown=Sample();unknown.Available=false;CaelumThermalService.Integrate(unknown,60,3);
        Check(unknown.SweatKg==0,"missing climate does not invent environmental cooling");
        let animal=Sample();animal.Sweats=false;CaelumThermalService.Integrate(animal,120,6);
        Check(animal.SweatKg==0 && animal.Hydration==100,"unapproved animal sweat profile stays disabled");
        let still=Sample();let windy=still.CopyForForecast();windy.WindMps=4;
        CaelumThermalService.Integrate(still,5,0);CaelumThermalService.Integrate(windy,5,0);
        Check(windy.Conductance>still.Conductance,"wind increases heat conductance");
        Check(CaelumThermalRules.Advance(0,100,10,1000,1)>0 && CaelumThermalRules.Advance(0,-100,10,1000,1)<0,"environmental transfer warms or cools with gradient sign");
        let split=Sample();for(int i=0;i<60;i++)CaelumThermalService.Integrate(split,2,0.1);
        Check(Near(split.Exposure,dry.Exposure) && Near(split.Hydration,dry.Hydration),"bounded numerical steps agree across batching");
        let fine=Sample();for(int i=0;i<240;i++)CaelumThermalService.Integrate(fine,0.5,0.025);
        Console.Printf("CA133 SWEAT_CONVERGENCE exposureError=%.9f waterError=%.9f",Abs(fine.Exposure-dry.Exposure),Abs(fine.SweatKg-dry.SweatKg));
        Check(Abs(fine.Exposure-dry.Exposure)<0.1 && Abs(fine.SweatKg-dry.SweatKg)<0.001,"coarse NPC and fine player intervals converge within 0.1 exposure degree and 1 mL");
        let cloth=Sample();let leather=cloth.CopyForForecast();leather.Material[0]=CaelumThermalData.LEATHER;
        cloth.WorkWaterKg[0]=0.1;leather.WorkWaterKg[0]=0.1;
        CaelumThermalService.Integrate(cloth,5,0);CaelumThermalService.Integrate(leather,5,0);
        Check(cloth.EvaporatedKg>leather.EvaporatedKg,"less permeable leather limits evaporation");
        let old=Sample();old.Revision=2;old.AcclimationMultiplier=3;old.Acclimation=12;old.DamageRemainder=0.375;
        old.Initialize();old.Hydration=43;old.Initialize();
        Check(old.Revision==3 && old.Hydration==43 && old.Exposure==8 && old.Acclimation==12 && old.AcclimationMultiplier==3 && old.DamageRemainder==0.375,"revision-two migration is idempotent and preserves existing thermal state");
        let live=CaelumThermalBody.Get(User,true);CaelumThermalBody.Refresh(User,live);
        User.CurrentThirst=37;live.Revision=2;live.Initialize();CaelumThermalBody.Refresh(User,live);
        Check(live.Hydration==37,"migration never refills player Thirst");
        live.Available=true;live.AirC=28;live.ClimateC=22;live.Humidity=40;live.WindMps=1;live.Roof=true;live.Exposure=5;
        CaelumThermalBody.SampleCoverage(User,live,0);double water=User.CurrentThirst;double sweat=live.SweatKg;
        CaelumThermalService.Advance(User,5,0);
        Check(User.CurrentThirst<water && Near(water-User.CurrentThirst,(live.SweatKg-sweat)*CaelumThermalRules.HydrationPointsPerKg(live.BodyMassKg)),"live player uses authoritative Thirst for actual sweat mass");
        let npcState=CaelumThermalBody.Get(NPC,true);CaelumThermalBody.Refresh(NPC,npcState);
        Check(npcState!=live && npcState.Sweats && npcState.Hydration==100 && npcState.ComfortC==32,"demon shares sweat profile with independent reserve and racial comfort");
        let bull=CaelumCombatActor(Actor.Spawn("CaelumBull",(7500,7500,0),NO_REPLACE));
        let bs=new("CaelumThermalState");bs.Initialize();CaelumThermalBody.Refresh(bull,bs);
        Check(!bs.Sweats,"native bull retains its distinct no-sweat scope");bull.Destroy();
        let projection=live.CopyForForecast();double retained=live.SweatKg;
        CaelumThermalService.Integrate(projection,60,0);
        Check(live.SweatKg==retained && Near(User.CurrentThirst,live.Hydration),"forecast cannot mutate live hydration or sweat");
        live.Exposure=0;live.ActivityWatts=0;User.CurrentThirst=100;User.CurrentHunger=100;User.CurrentSleep=100;
        let clock=CaelumWorldClock.Get(User,true);let calendar=CaelumCalendarState.Get(User,true);
        calendar.EnsureCampaign(clock);CaelumWeatherState.Sync(User,clock,calendar);
        let model=new("CaelumJourneyModel");model.Capture(User,true);
        let travel=new("CaelumThermalJourney");int duration=CaelumWorldClock.TicsPerHour();
        bool safe=travel.Forecast(User,CaelumJourneyState.MODE_FOOT,duration,5,-1,model);
        let control=new("CaelumJourneyModel");control.Capture(User,true);control.Simulate(duration);
        Console.Printf("CA133 SWEAT_JOURNEY safe=%d reason=%s elapsed=%d sweat=%.8f water=%d control=%d thirst=%.5f",safe,travel.Failure,model.ElapsedTics,travel.Result.SweatKg-live.SweatKg,model.WaterSpent,control.WaterSpent,model.Thirst);
        Check(safe && model.ElapsedTics==duration && model.WaterSpent>control.WaterSpent,"journey provisions account for sweat during walking");
        Check(User.CurrentThirst==100 && live.SweatKg==retained && Near(model.Thirst,travel.Result.Hydration),"journey hydration and thermal projection agree without touching live state");
        double beforeCommit=User.CurrentThirst;CaelumThermalService.CommitForecast(User,travel.Result);
        Check(User.CurrentThirst==beforeCommit,"thermal commit does not charge projected sweat a second time");
        User.CurrentThirst=0;User.CurrentHunger=100;User.CurrentAir=User.DerivedStats.MaximumAir/2;
        double beforeAir=User.CurrentAir;CaelumPlayerResources.ApplyAirRegeneration(User);
        Check(User.CurrentAir>beforeAir && User.CurrentThirst==0 && User.CurrentHunger<100,"Air recovery spends food and works without consuming water");
        // Same route/weather, different accessible water; neither preview touches the actor.
        User.CurrentThirst=5;User.CurrentHunger=100;User.Attributes.Toughness=0;live.Exposure=0;live.ActivityWatts=0;
        for(int i=0;i<4;i++){live.BaseWaterKg[i]=0;let piece=CaelumThermalBody.EquippedPiece(User,i);if(piece!=null)piece.ThermalWaterKg=0;}
        let supplied=new("CaelumJourneyModel");supplied.Capture(User,true);
        let depleted=new("CaelumJourneyModel");depleted.Capture(User,false);depleted.WaterStock=0;depleted.ContainerStock=0;
        let safeTrip=new("CaelumThermalJourney");let dryTrip=new("CaelumThermalJourney");
        bool suppliedSafe=safeTrip.Forecast(User,CaelumJourneyState.MODE_FOOT,duration,10,-1,supplied);
        bool depletedSafe=dryTrip.Forecast(User,CaelumJourneyState.MODE_FOOT,duration,10,-1,depleted);
        Console.Printf("CA133 SWEAT_SUPPLY supplied=%d depleted=%d dryReason=%s water=%d dryE=%.6f wetE=%.6f",suppliedSafe,depletedSafe,dryTrip.Failure,supplied.WaterSpent,dryTrip.Result.Exposure,safeTrip.Result.Exposure);
        Check(suppliedSafe && !depletedSafe && dryTrip.Failure=="CA_JOURNEY_HEAT","insufficient route water can turn a thermally safe walk into a blocked hot journey");
        Check(User.CurrentThirst==5 && live.Exposure==0,"failed forecast consumes no live water or exposure");
        // Freeze only diagnostic actors after capturing the owned-state boundary.
        npcState.Hydration=43.25;npcState.SweatKg=0.123;npcState.SweatRunoffKg=0.004;npcState.NextUpdateTic=2147480000;
        npcState.RuntimeReady=true;npcState.RuntimeMap=level.MapName;npcState.LastRealTic=level.maptime;
        User.CurrentThirst=33.7;live.SweatKg=0.234;User.PersistCharacterState();Finished=true;
        Console.Printf("CA133 SWEAT_COMPLETE checks=%d failures=%d dryE=%.6f humidE=%.6f sweat=%.9f",Checks,Failures,dry.Exposure,humid.Exposure,dry.SweatKg);
    }
}
