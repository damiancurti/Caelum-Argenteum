// Planificación del tiempo, separada de la integración y de las fuentes de calor.
class CaelumThermalRuntime : Object play
{
    static double WorldTicSeconds()
    {return 3600.0/CaelumWorldClock.SecondsPerGameHour(level.MapName)/TICRATE;}

    static double Stamp(CaelumWorldClock clock)
    {
        if(clock==null)return 0;
        double seconds=double(clock.CompletedDays)*86400.0+double(clock.DayTics)*3600.0/CaelumWorldClock.TicsPerHour();
        if(CaelumWorldCatalogue.IsLimboMap(level.MapName))seconds+=double(clock.LimboSubTics)/TICRATE;
        return seconds;
    }

    static void PlayerStep(CaelumPlayer user,bool realStep)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.health<=0)return;
        let thermal=CaelumThermalBody.Get(user,true);
        let weather=CaelumWeatherState.Get(user);
        if(thermal==null || weather==null)return;
        bool changed=thermal.SourceMap!=level.MapName || thermal.LastEnvironmentTic>level.maptime
            || level.maptime-thermal.LastEnvironmentTic>=CaelumThermalData.ENVIRONMENT_SAMPLE_TICS
            || thermal.LastWaterLevel!=user.WaterLevel || thermal.EnvironmentDate!=weather.SampleDate
            || thermal.EnvironmentMinute!=weather.SampleMinute;
        if(changed)
        {
            CaelumThermalEnvironment.Sample(user,thermal,thermal.LocalMotionMps);
            thermal.FireWatts=CaelumThermalFire.Sample(user,thermal);
            thermal.LastWaterLevel=user.WaterLevel;
            thermal.EnvironmentDate=weather.SampleDate;thermal.EnvironmentMinute=weather.SampleMinute;
        }
        double activity=realStep ? thermal.PendingActivityJoules*TICRATE : 0;
        if(realStep)
        {
            thermal.PendingActivityJoules=0;
            if(user.DebugShieldBlocking && user.HasActiveBlockSource())
                activity+=CaelumThermalEffects.EffortWatts(user,user.CurrentShieldAirCostPerSecond);
        }
        CaelumThermalService.Advance(user,WorldTicSeconds(),realStep ? 1.0/TICRATE : 0,activity,0,thermal.FireWatts);
    }

    static void NPCStep(CaelumCombatActor npc,bool force=false)
    {
        if(npc.health<=0)return;
        // La programación ya pertenece al NPC: los tics intermedios no
        // reconstruyen reloj, atributos ni búsquedas globales.
        if(!force && npc.ThermalState!=null && npc.ThermalState.RuntimeReady
            && npc.ThermalState.RuntimeMap==level.MapName && level.maptime>=npc.ThermalState.LastRealTic
            && level.maptime<npc.ThermalState.NextUpdateTic)return;
        if(!npc.CombatProfileInitialized || !CaelumThermalBody.Supported(npc))return;
        let world=CaelumThermalWorld.Get();
        if(world==null || world.ReferenceClock==null || world.ReferenceWeather==null)return;
        let thermal=CaelumThermalBody.Get(npc,true);
        if(thermal==null)return;
        double now=Stamp(world.ReferenceClock);
        if(!thermal.RuntimeReady || thermal.RuntimeMap!=level.MapName || thermal.LastRealTic>level.maptime)
        {
            thermal.RuntimeReady=true;thermal.RuntimeMap=level.MapName;
            thermal.LastRealTic=level.maptime;thermal.LastWorldStamp=now;
            thermal.NextUpdateTic=level.maptime+1+world.NextPhase++%TICRATE;
            return;
        }
        if(!force && level.maptime<thermal.NextUpdateTic)return;
        double dr=Max(0.0,double(level.maptime-thermal.LastRealTic)/TICRATE);
        double dw=Max(0.0,now-thermal.LastWorldStamp);
        if(thermal.SourceMap!=level.MapName || level.maptime-thermal.LastEnvironmentTic>=TICRATE
            || thermal.LastWaterLevel!=npc.WaterLevel || thermal.EnvironmentDate!=world.ReferenceWeather.SampleDate
            || thermal.EnvironmentMinute!=world.ReferenceWeather.SampleMinute)
        {
            CaelumThermalEnvironment.Sample(npc,thermal,thermal.LocalMotionMps);
            thermal.FireWatts=CaelumThermalFire.Sample(npc,thermal);
            thermal.LastWaterLevel=npc.WaterLevel;thermal.EnvironmentDate=world.ReferenceWeather.SampleDate;
            thermal.EnvironmentMinute=world.ReferenceWeather.SampleMinute;
        }
        // Minuto de mundo como límite numérico. El total real se reparte una
        // vez: acelerar el calendario no multiplica el daño ni crea acciones.
        int steps=Max(1,int(Ceil(dw/60.0)));
        for(int i=0;i<steps && npc.health>0;i++)CaelumThermalService.Advance(npc,dw/steps,dr/steps,dr>0 ? thermal.PendingActivityJoules/dr : 0,0,thermal.FireWatts);
        thermal.PendingActivityJoules=0;
        thermal.LastRealTic=level.maptime;thermal.LastWorldStamp=now;
        thermal.NextUpdateTic=level.maptime+TICRATE;
    }
}
