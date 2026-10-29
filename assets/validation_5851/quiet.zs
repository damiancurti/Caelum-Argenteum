class CA415QuietChecks : EventHandler
{
    CaelumAbsentBattle Battle;
    CaelumPortDefender Soldier;
    double Start;
    int Passed,Failed;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA415Q %s %s",value?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}

    void Prepare(CaelumPlayer user)
    {
        Soldier=CaelumPortDefender(ThinkerIterator.Create('CA415RoundSoldier').Next());
        Soldier.bFriendly=true;Soldier.target=null;Soldier.CombatArmor=null;
        Soldier.health=800;Soldier.CombatMaximumHealth=1000;Soldier.CombatToughness=100;
        Soldier.IdleHealthAccumulator=0;Soldier.RecoveryPhase=0;
        let port=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(512,512,0),NO_REPLACE));
        port.SiegeStarted=true;port.SetupRevision=1;port.Defenders.Push(Soldier);
        Battle=new('CaelumAbsentBattle');port.AbsentBattle=Battle;Battle.Capture(port,user);
        Check(Near(Battle.ActiveScale,0.05),"exterior uses the existing active/world clock conversion");
        Start=Ceil(Battle.Stamp/60)*60;Battle.Stamp=Start;
        let absence=Soldier.ContaminationAbsence;
        absence.Stamp=absence.Civil=Start;absence.Climate.Ready=false;absence.Exposure=null;
        absence.RecoveryRate=10;absence.Immune=false;absence.Life=800;
        CaelumContaminationStorage.Get(Soldier,true).Concentration=90;
        let thermal=Soldier.AbsentCombatant.Thermal;
        thermal.Available=true;thermal.AirC=thermal.ClimateC=20;thermal.Humidity=50;
        thermal.WindMps=thermal.RainMmHour=thermal.FireWatts=0;
        thermal.Exposure=4;Soldier.ThermalState.Exposure=4;
        Soldier.ThermalState.PendingActivityJoules=Soldier.ThermalState.PendingFirearmJoules=0;
    }
    void Guards(CaelumPlayer user)
    {
        Prepare(user);
        Check(Battle.NextSpan(Start,100)==20,"quiet exterior follows one active second instead of combat rounds");
        Check(Battle.NextSpan(Start+55,100)==5,"quiet work stops at the weather minute");
        Check(Battle.NextSpan(Start,7)==7,"quiet work never crosses its arrival or scheduled-event limit");
        Battle.ActiveScale=1;Check(Battle.NextSpan(Start,100)==1,"Limbo keeps its one-to-one clock");Battle.ActiveScale=0.05;
        Soldier.ForcedSleepTics=35;Check(Battle.NextSpan(Start,100)==1,"sleep retains fine wake ordering");Soldier.ForcedSleepTics=0;
        Soldier.ElementalStatus.FreezeRemaining=1;Check(Battle.NextSpan(Start,100)==1,"temporary elemental effects retain combat resolution");Soldier.ElementalStatus.FreezeRemaining=0;
        Soldier.ElementalStatus.ApplyBurnHeat(1,1,100);Check(Battle.NextSpan(Start,100)==1,"burn heat cannot cross a quiet batch");Soldier.ElementalStatus.ClearBurnHeat();
        let support=CaelumSupportStatus(Soldier.GiveInventoryType('CaelumSupportStatus'));
        support.Apply(CaelumSupportImplementData.CENSER,user,0);
        Check(Battle.NextSpan(Start,100)==1,"active support doses retain their original ordering");support.AnyActive=false;
        let port=CaelumPortSiege(Battle.Encounter);port.Reinforcements=new('CaelumSiegeReinforcements');
        port.Reinforcements.Enabled=true;port.Reinforcements.Remaining=1;
        Check(Battle.NextSpan(Start,100)==1,"pending reserves prevent quiet batching");port.Reinforcements.Enabled=false;
        let demon=CaelumCombatActor(ThinkerIterator.Create('CA415RoundDemon').Next());
        demon.bFriendly=false;Battle.Add(demon);
        Check(Battle.NextSpan(Start,100)==1,"opposed forces keep one-world-second simultaneous rounds");
        demon.AbsentCombatant.Participating=false;Battle.TargetCacheReady=false;
        Check(Battle.NextSpan(Start,100)==20,"inactive participants do not prevent quiet work");
        let projected=Soldier.AbsentCombatant.Thermal.CopyForForecast();
        CaelumThermalBody.Refresh(Soldier,projected);
        for(int i=0;i<4;i++)projected.Material[i]=CaelumThermalBody.Material(Soldier,i);
        CaelumThermalService.Integrate(projected,20,1);
        Battle.SyncTo(Start+20);
        Check(Soldier.health==810 && Near(CaelumContaminationStorage.Value(Soldier),89.99),
            "quiet disease immunity and natural depuration retain the canonical NPC physiology budget");
        Check(Near(Soldier.ThermalState.Exposure,projected.Exposure)
            && Near(Soldier.ThermalState.Acclimation,projected.Acclimation)
            && Near(Soldier.ThermalState.SweatKg,projected.SweatKg),
            "quiet temperature and sweat use the canonical thermal integrator");
        Check(Battle.Rounds==0 && Near(Battle.Stamp,Start+20) && Near(Soldier.ContaminationAbsence.Stamp,Start+20),
            "quiet batching advances physiology without inventing attacks or losing time");
    }
    void Save(CaelumPlayer user)
    {
        Prepare(user);Battle.Busy=true;Battle.Work=new('CaelumAbsentWork');
        let climate=new('CaelumFoodClimate');climate.Ready=true;climate.Profile=CaelumWeatherRules.PROFILE_LIMBO;
        climate.Shelter=CaelumWeatherRules.LIMBO;
        Battle.WeatherSample(climate,Start);
        Battle.Work.Begin(Battle,Start+20,20,true);Battle.Work.Advance(1);
        Check(Battle.Work.Phase==1 && Soldier.health==800,"saved quiet job stops before applying its physiology");
    }
    void Load()
    {
        Check(Battle.Weather.Size()==0,"save rebuilds the transient weather cache instead of serializing shared samples");
        Check(Battle.Work.Phase==1 && Battle.Work.WorldSeconds==20 && Near(Battle.Work.ActiveSeconds,1),
            "save restores the quiet span and its active-time budget");
        while(!Battle.Work.Advance(1)){}
        Check(Soldier.health==810 && Near(Soldier.ContaminationAbsence.Stamp,Start+20),
            "loaded quiet worker completes the original interval exactly once");
        Battle.Work.Advance(1);Check(Soldier.health==810,"completed quiet worker does not repeat healing after load");
    }
    void WeatherChecks(CaelumPlayer user)
    {
        Prepare(user);
        let climate=new('CaelumFoodClimate');climate.Ready=true;
        climate.Profile=CaelumWeatherRules.PROFILE_TEMPERATE_TRIAL;climate.Region=1;climate.Seed=415;
        for(int shelter=0;shelter<=CaelumWeatherRules.LIMBO;shelter++)
        {
            climate.Shelter=shelter;
            for(int minute=0;minute<3;minute++)
            {
                double when=Start+minute*60;
                let reference=climate.Copy();reference.Rate(when);
                let actual=Battle.WeatherSample(climate,when);
                Check(actual.Available==reference.Local.Available
                    && Near(actual.AirTemperatureC,reference.Local.AirTemperatureC)
                    && Near(actual.RelativeHumidityPercent,reference.Local.RelativeHumidityPercent)
                    && Near(actual.WindSpeedKmh,reference.Local.WindSpeedKmh)
                    && Near(actual.PrecipitationMmPerHour,reference.Local.PrecipitationMmPerHour),
                    "shared regional weather matches an independent native sample at each shelter and minute");
                Check(Battle.WeatherSample(climate.Copy(),when)==actual,
                    "distinct bodies with the same climate reuse the minute sample");
            }
        }
        Check(Battle.Weather.Size()==5,"cache size follows climate contexts rather than bodies or elapsed minutes");
        let before=Battle.WeatherSample(climate,Start);double temperature=before.AirTemperatureC;
        climate.Rate(Start+86400);
        Check(Near(before.AirTemperatureC,temperature) && before!=climate.Local,
            "a private inventory forecast cannot mutate the shared combat sample");
        climate.HeatDelta=17;climate.HumidityDelta=-20;
        Check(Battle.WeatherSample(climate,Start)==before && Near(before.AirTemperatureC,temperature),
            "personal seal deltas remain outside the regional weather cache");
        climate.Seed++;let changed=Battle.WeatherSample(climate,Start);
        Check(changed!=before && Battle.Weather.Size()==6,"a different seed cannot reuse another climate context");
        climate.Profile=CaelumWeatherRules.PROFILE_LIMBO;climate.Region=0;
        let limbo=climate.Copy();limbo.Rate(Start);
        Check(Near(Battle.WeatherSample(climate,Start).AirTemperatureC,limbo.Local.AirTemperatureC),
            "Limbo uses its own canonical weather evaluation");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca415r_quiet")Guards(user);
        else if(e.Name=="ca415r_quietsave")Save(user);
        else if(e.Name=="ca415r_quietload")Load();
        else if(e.Name=="ca415r_weather")WeatherChecks(user);
        else return;
        Console.Printf("CA415Q RESULT passed=%d failed=%d",Passed,Failed);
    }
}
