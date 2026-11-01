// Accepted pre-cursor thermal forecast retained below as an independent oracle.
class CA440JourneyFriend : CaelumCombatActor
{
    override void Tick(){}
    Default {Health 4000;Radius 12;Height 56;Mass 80;Speed 0;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440JourneyLedger : Inventory
{
    int Phase;
    CaelumLoversJourney Forecast;
    double FractionA,FractionB;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool okay,String label){Console.Printf("CA440LJ %s %s",okay?"PASS":"FAIL",label);}
    void Reset(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        for(int i=0;i<78;i++){record.TarotOwned[i]=true;record.TarotSelected[i]=false;record.TarotActive[i]=false;record.TarotRemaining[i]=0;}
        record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
        record.TarotCooldownTics=record.TarotEffectTics=0;user.ApplyCharacterProfile();
        user.player.cheats&=~(CF_GODMODE|CF_GODMODE2|CF_BUDDHA|CF_BUDDHA2);
        user.DerivedStats.AbilityRangePercent=100;user.CurrentAnima=user.DerivedStats.MaximumAnima;
        user.health=user.player.health=user.CaelumMaximumHealth;user.CurrentAir=user.DerivedStats.MaximumAir;
        user.CurrentHunger=user.CurrentThirst=user.CurrentSleep=80;
        user.ElementalStatus=new('CaelumElementalStatus');CaelumFoodIllness.Get(user).Contamination=0;
        CaelumWeatherState.Get(user,true).Region=1;
        let rest=CaelumLoversRemainder(user.FindInventory('CaelumLoversRemainder'));if(rest!=null)rest.DamageFraction=0;
    }
    CaelumLoversJourney Pair(CaelumPlayer a,CaelumPlayer b)
    {
        let group=new('CaelumLoversJourney');group.Add(a,null);group.Add(b,null);
        for(int i=0;i<2;i++)
        {let row=group.Rows[i];row.Model=new('CaelumJourneyModel');row.Model.Capture(CaelumPlayer(row.Body),false);row.Model.Lovers=group;row.Model.LoversIndex=i;}
        group.CaptureLinks();return group;
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440JourneyLedger(user.FindInventory('CA440JourneyLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        if(ledger==null)
        {
            ledger=CA440JourneyLedger(user.GiveInventoryType('CA440JourneyLedger'));
            Reset(user);Reset(other);user.SetOrigin((0,0,0),false);other.SetOrigin((48,0,0),false);
            let before=new('CaelumJourneyModel');before.Capture(user,false);
            let after=new('CaelumJourneyModel');after.Capture(user,false);
            let old=new('CA440LegacyThermalJourney');let cursor=new('CaelumThermalJourney');
            bool okay=old.Forecast(user,CaelumJourneyState.MODE_FOOT,900,5,1,before);
            bool now=cursor.Forecast(user,CaelumJourneyState.MODE_FOOT,900,5,1,after);
            Console.Printf("CA440LJ DIAG old=%s new=%s elapsed=%d/%d health=%d/%d exposure=%.12f/%.12f thirst=%.12f/%.12f",old.Failure,cursor.Failure,before.ElapsedTics,after.ElapsedTics,before.Health,after.Health,old.Result.Exposure,cursor.Result.Exposure,before.Thirst,after.Thirst);
            Check(okay && now,"old and cursor thermal forecasts complete the same route segment");
            Check(before.Health==after.Health && before.ElapsedTics==after.ElapsedTics && before.FoodSpent==after.FoodSpent
                && before.WaterSpent==after.WaterSpent && Abs(before.Hunger-after.Hunger)<1e-7
                && Abs(before.Thirst-after.Thirst)<1e-7 && Abs(before.Air-after.Air)<1e-7,"cursor preserves accepted resource trajectory without an aura");
            Check(Abs(old.Result.Exposure-cursor.Result.Exposure)<1e-7 && Abs(old.Result.SweatKg-cursor.Result.SweatKg)<1e-7,
                "cursor preserves thermal state across minute sample boundaries");
            CaelumTarotService.Select(user,6);CaelumTarotService.Select(other,6);
            let friend=CA440JourneyFriend(Actor.Spawn('CA440JourneyFriend',(80,0,0),NO_REPLACE));friend.CombatMaximumHealth=4000;friend.bFriendly=true;
            let party=CaelumCompanionParty.Get(user,true);party.Roster.Clear();
            let bond=new('CaelumCompanionBond');bond.Body=friend;bond.Party=party;bond.Enlisted=true;bond.Identity=0;
            bond.Order=CaelumCompanionData.FOLLOW;party.Roster.Push(bond);friend.Companion=bond;
            let group=Pair(user,other);int a=user.health,b=other.health,c=friend.health;
            Check(group.Rows.Size()==3,"journey uses only travelling players and their enlisted following roster");
            for(int i=0;i<3;i++)group.Damage(0,1);
            Check(group.Rows[0].Model.Health==a-1 && group.Rows[1].Model.Health==b-1 && group.Rows[2].Model.Health==c-1,
                "overlapping auras retain fractional equal damage without recursion");
            Check(user.health==a && other.health==b && friend.health==c,"forecast sharing does not mutate real bodies");
            group.Rows[2].Model.Health=0;group.Damage(0,10);
            Check(group.Rows[0].Model.Health==a-6 && group.Rows[1].Model.Health==b-6,"dead recipients leave the next simulated share");
            group=Pair(user,other);group.Rows[1].Immune=true;group.Damage(0,6);
            Check(group.Rows[0].Model.Health==a-2 && group.Rows[1].Model.Health==b && group.Rows[2].Model.Health==c-2,
                "immune secondary keeps its discarded share without new defenses");
            group=Pair(user,other);group.Damage(0,2);group.Commit();group.Commit();
            Check(friend.health==c && Abs(CaelumLoversRemainder(friend.FindInventory('CaelumLoversRemainder')).DamageFraction-2.0/3)<1e-7,
                "commit preserves the NPC fraction once without rounding a duplicate hit");
            bond.Order=CaelumCompanionData.WAIT;
            group=Pair(user,other);Check(group.Rows.Size()==2,"waiting companion does not accompany the abstract journey");
            let pa=CaelumJourneyPlan(Actor.Spawn('CaelumJourneyPlan',user.Pos,NO_REPLACE));
            let pb=CaelumJourneyPlan(Actor.Spawn('CaelumJourneyPlan',other.Pos,NO_REPLACE));
            Check(pa.Parameters(user,8,CaelumJourneyState.MODE_FOOT,5) && pb.Parameters(other,8,CaelumJourneyState.MODE_FOOT,5),"native journey parameters retain route and common pace");
            CaelumFoodIllness.Get(user).Contamination=100;user.DerivedStats.HealthRegenerationPerSecond=0;other.DerivedStats.HealthRegenerationPerSecond=0;
            let coupled=new('CaelumLoversJourney');coupled.Add(user,pa);coupled.Add(other,pb);
            Check(coupled.Run(false,350),"coupled disease and thermal forecast completes");
            Console.Printf("CA440LJ DIAG coupled=%s/%s elapsed=%d/%d health=%d/%d",coupled.Rows[0].Thermal.Failure,coupled.Rows[1].Thermal.Failure,pa.Available.ElapsedTics,pb.Available.ElapsedTics,pa.Available.Health,pb.Available.Health);
            Check(pa.Available.ElapsedTics==350 && pb.Available.ElapsedTics==350 && pb.Available.Health<b,
                "shared damage changes the peer during the same forecast clock");
            Check(user.health==a && other.health==b && CaelumFoodIllness.Get(user).Contamination==100,
                "complete preview leaves real health and disease unchanged");
            int resultA=pa.Available.Health,resultB=pb.Available.Health;
            pa.Apply(user,false);pb.Apply(other,false);
            Check(user.health==resultA && other.health==resultB,"confirmation applies both modeled health outcomes once");
            Check(pa.Available.Lovers==null && pb.Available.Lovers==null && pa.Needed==null && pb.Needed==null,
                "closed plans release cross-player projection ownership");
            let same=Pair(user,other);other.SetOrigin((800,0,0),false);let changed=Pair(user,other);
            Check(!CaelumLoversJourney.SameParticipants(same,changed),"a changed aura recipient requires a new confirmation");
            other.SetOrigin((48,0,0),false);
            user.health=user.player.health=1;other.health=other.player.health=1;
            let fatal=new('CaelumLoversJourney');fatal.Add(user,pa);fatal.Add(other,pb);
            Check(fatal.Run(false,350) && pa.Available.ElapsedTics==pb.Available.ElapsedTics
                && pa.Available.WalkTics==pb.Available.WalkTics && pa.Available.SleepTics==pb.Available.SleepTics
                && pa.Available.ElapsedTics<350 && (pa.Available.Health<=0 || pb.Available.Health<=0),
                "first simulated death stops all travellers at one common tic");
            user.health=user.player.health=resultA;other.health=other.player.health=resultB;
            let solo=CaelumJourneyPlan(Actor.Spawn('CaelumJourneyPlan',user.Pos,NO_REPLACE));
            Check(solo.Calculate(user,8,CaelumJourneyState.MODE_FOOT,5,35) && solo.Available.Lovers!=null
                && solo.Available.ElapsedTics==35 && solo.Available.Lovers.PlayersCount==1,
                "public solo planner selects the isolated Lovers forecast");
            Check(user.health==resultA && other.health==resultB,"public planner remains read-only");
            solo.Destroy();
            ledger.Forecast=coupled;ledger.FractionA=coupled.Rows[0].Fraction;ledger.FractionB=coupled.Rows[1].Fraction;
            CaelumFoodIllness.Get(user).Contamination=CaelumFoodIllness.Get(other).Contamination=0;
            user.player.cheats|=CF_GODMODE;other.player.cheats|=CF_GODMODE;
            ledger.Phase=1;Console.Printf("CA440LJ RESULT capture");return;
        }
        if(Reloaded && ledger.Phase==1)
        {
            let a=CaelumLoversRemainder(user.FindInventory('CaelumLoversRemainder'));
            let b=CaelumLoversRemainder(other.FindInventory('CaelumLoversRemainder'));
            Check(a!=null && b!=null && Abs(a.DamageFraction-ledger.FractionA)<1e-7 && Abs(b.DamageFraction-ledger.FractionB)<1e-7,
                "common save restores both share fractions");
            Check(ledger.Forecast!=null && ledger.Forecast.Committed,"saved projection remembers its committed transaction");
            int before=user.health,peer=other.health;ledger.Forecast.Commit();
            Check(user.health==before && other.health==peer && ledger.Forecast.Revision==CaelumMajorArcanaData.LOVERS_REVISION,"recovery cannot replay the projection commit");
            ledger.Phase=2;Console.Printf("CA440LJ RESULT reload");
        }
    }
}

// Oracle: 3b52e069c CaelumThermalJourney, class name changed only.
// Previsión aislada: no muta equipo, recursos, reloj ni fracciones de daño.
class CA440LegacyThermalJourney : Object play
{
    CaelumThermalState Result;
    String Failure;
    double WorstExposure;

    // Dos climas evaluados en el mismo instante; la mezcla avanza por distancia.
    static void BlendRoute(CaelumWeatherSample result,CaelumWeatherSample origin,
        CaelumWeatherSample destination,double progress)
    {
        result.Clear();if(!origin.Available || !destination.Available)return;
        double p=Clamp(progress,0,1);result.Available=true;
        result.AirTemperatureC=CaelumWeatherRules.Mix(origin.AirTemperatureC,destination.AirTemperatureC,p);
        result.RelativeHumidityPercent=CaelumWeatherRules.Mix(origin.RelativeHumidityPercent,destination.RelativeHumidityPercent,p);
        result.WindSpeedKmh=CaelumWeatherRules.Mix(origin.WindSpeedKmh,destination.WindSpeedKmh,p);
        result.PrecipitationMmPerHour=CaelumWeatherRules.Mix(origin.PrecipitationMmPerHour,destination.PrecipitationMmPerHour,p);
        result.NormalMeanC=CaelumWeatherRules.Mix(origin.NormalMeanC,destination.NormalMeanC,p);
        result.AnnualMeanC=CaelumWeatherRules.Mix(origin.AnnualMeanC,destination.AnnualMeanC,p);
        result.GroundTemperatureC=CaelumWeatherRules.Mix(origin.GroundTemperatureC,destination.GroundTemperatureC,p);
        result.CloudFraction=CaelumWeatherRules.Mix(origin.CloudFraction,destination.CloudFraction,p);
    }

    bool Forecast(CaelumPlayer user,int mode,int elapsedTics,double speedKmh,int destinationRegion=-1,CaelumJourneyModel supplies=null,int limitTics=0)
    {
        Result=CaelumThermalService.CaptureForecast(user);Failure="";WorstExposure=0;
        // El viaje abstracto no arrastra el suelo de su punto de partida.
        if(Result!=null)CaelumThermalSurface.Clear(Result);
        let weather=CaelumWeatherState.Get(user);
        let clock=CaelumWorldClock.Get(user);
        let calendar=CaelumCalendarState.Get(user);
        int serial=calendar!=null ? calendar.DateSerial(clock) : -1;
        if(Result==null || weather==null || weather.Region<=0 || serial<0)
        {Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
        if(destinationRegion==-1)destinationRegion=weather.Region;
        if(!CaelumClimateNormals.Valid(destinationRegion))
        {Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
        if(CaelumThermalRules.Severity(Result.Exposure,Result.Toughness)>0)
        {Failure=Result.Exposure<0 ? "CA_JOURNEY_COLD" : "CA_JOURNEY_HEAT";return false;}
        bool sheltered=mode==CaelumJourneyState.MODE_CART || mode==CaelumJourneyState.MODE_SHIP;
        int civil=calendar.CivilDayTics(clock);
        int hour=CaelumWorldClock.TicsPerHour(),day=CaelumWorldClock.TicsPerDay();
        let origin=new("CaelumWeatherSample");let destination=new("CaelumWeatherSample");
        let outside=new("CaelumWeatherSample");let local=new("CaelumWeatherSample");
        int moving=CaelumJourneyRules.MovingTics(elapsedTics,mode);
        Result.Roof=sheltered;Result.WindSheltered=sheltered;Result.Available=true;
        for(int i=0;i<4;i++)Result.SubmergedCoverage[i]=0;
        Result.DirtyWaterRowMask=0;Result.CleanWaterRowMask=0;Result.DynamicContactWater=false;Result.WaterRowMask=0;
        for(int i=0;i<4;i++){Result.DirtyWaterCoverage[i]=0;Result.CleanWaterCoverage[i]=0;}
        if(supplies!=null && supplies.Contamination!=null)supplies.Contamination.ClearImmersion();
        int elapsed=0;
        int end=limitTics>0 ? Min(elapsedTics,limitTics) : elapsedTics;
        while(elapsed<end)
        {
            int phase=elapsed%(24*hour);
            bool sleeping=phase>=CaelumJourneyRules.WALK_HOURS*hour;
            int boundary=(sleeping ? 24*hour : CaelumJourneyRules.WALK_HOURS*hour)-phase;
            int step=Min(end-elapsed,Min(boundary,hour/60));
            int midpoint=elapsed+step/2;
            int timestamp=civil+midpoint;
            origin.EvaluateRegion(weather.Region,serial+timestamp/day,timestamp%day,weather.Seed);
            destination.EvaluateRegion(destinationRegion,serial+timestamp/day,timestamp%day,weather.Seed);
            double progress=moving>0 ? double(CaelumJourneyRules.MovingTics(midpoint,mode))/moving : 0;
            BlendRoute(outside,origin,destination,progress);
            if(!outside.Available){Failure="CA_JOURNEY_THERMAL_UNKNOWN";return false;}
            local.ApplyShelter(outside,sheltered ? CaelumWeatherRules.INDOOR : CaelumWeatherRules.OPEN,
                CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL);
            double speed=!sheltered && !sleeping ? speedKmh/3.6 : 0;
            Result.AirC=local.AirTemperatureC;Result.ClimateC=local.AirTemperatureC;
            Result.Humidity=local.RelativeHumidityPercent;
            Result.RainMmHour=sheltered ? 0 : local.PrecipitationMmPerHour;
            Result.WindMps=Sqrt(local.WindSpeedKmh*local.WindSpeedKmh/12.96+speed*speed);
            Result.WaterC=local.GroundTemperatureC;
            double seconds=double(step)*3600.0/hour;
            double effort=CaelumThermalRules.LocomotionHeat(Result.MovedMassKg,speed,0,false,CaelumThermalMotion.Gravity(user),Result.MuscularEfficiency);
            // Segundos lógicos de esfuerzo explícitos; dr permanece cero.
            int substeps=supplies!=null ? step : 1;
            for(int t=0;t<substeps;t++)
            {
                if(supplies!=null)
                {
                    Result.Hydration=supplies.Thirst;Result.BreathingAirRatio=supplies.MaxAir>0 ? supplies.Air/supplies.MaxAir : 1;
                    Result.ShiveringHunger=supplies.Hunger;
                    Result.ShiveringHungerPerMetSecond=supplies.HungerLoss*hour/3600.0/supplies.Comfort(sleeping);
                }
                CaelumThermalService.Integrate(Result,seconds/substeps,0,effort,0,0,seconds/substeps);
                if(Abs(Result.Exposure)>Abs(WorstExposure))WorstExposure=Result.Exposure;
                if(Result.Severity>0)
                {Failure=Result.Exposure<0 ? "CA_JOURNEY_COLD" : "CA_JOURNEY_HEAT";return false;}
                if(supplies!=null)
                {
                    // Como AdvancePersonalTimeTic: primero el balance térmico,
                    // luego provisiones y recuperación. Nunca cobrar dos veces.
                    supplies.Thirst=Result.Hydration;supplies.ThermalExposure=Result.Exposure;
                    supplies.Hunger=Result.ShiveringHunger;
                    supplies.ThermalToughness=Result.Toughness;
                    if(supplies.FoodInventory!=null)supplies.FoodInventory.Advance(seconds/substeps,Result.AirC,Result.Humidity);
                    if(supplies.Contamination!=null)
                        supplies.Contamination.Advance(supplies.FoodIllness,CaelumContaminationRules.Environment(
                            CaelumContaminationData.NATURAL_REFERENCE,Result.AirC,Result.Humidity),seconds/substeps);
                    supplies.Step(sleeping);
                    supplies.WalkTics+=int(!sleeping || mode==CaelumJourneyState.MODE_SHIP);
                    supplies.SleepTics+=int(sleeping);Result.Hydration=supplies.Thirst;Result.ShiveringHunger=supplies.Hunger;
                    if(supplies.Health<=0)return true;
                }
            }
            elapsed+=step;
        }
        return true;
    }
}
