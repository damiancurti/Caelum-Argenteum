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
        let surfaceWorld=CaelumThermalWorld.Get();
        bool surfaceChanged=surfaceWorld!=null && surfaceWorld.HasThermalSurfaces
            && thermal.SurfaceKind!=CaelumThermalSurface.KindAt(user);
        bool changed=!thermal.WaterContactReady || thermal.SealClimateRevision<CaelumSealClimateData.REVISION || thermal.SourceMap!=level.MapName || thermal.LastEnvironmentTic>level.maptime
            || level.maptime-thermal.LastEnvironmentTic>=CaelumThermalData.ENVIRONMENT_SAMPLE_TICS
            || thermal.LastWaterLevel!=user.WaterLevel || thermal.EnvironmentDate!=weather.SampleDate
            || thermal.EnvironmentMinute!=weather.SampleMinute || surfaceChanged;
        if(changed)
        {
            CaelumThermalEnvironment.Sample(user,thermal,thermal.LocalMotionMps);
            thermal.FireWatts=CaelumThermalFire.Sample(user,thermal);
            thermal.LastWaterLevel=user.WaterLevel;
            thermal.EnvironmentDate=weather.SampleDate;thermal.EnvironmentMinute=weather.SampleMinute;
        }
        double activity=realStep ? thermal.PendingActivityJoules*TICRATE : 0;
        double firearm=0;
        if(realStep)
        {
            firearm=thermal.PendingFirearmJoules*TICRATE;thermal.PendingFirearmJoules=0;
            thermal.PendingActivityJoules=0;
            if(user.DebugShieldBlocking && user.HasActiveBlockSource())
                activity+=CaelumThermalEffects.BlockingWatts(thermal.MovedMassKg,user.GetActiveBlockWeight());
        }
        double burn=user.ElementalStatus!=null ? user.ElementalStatus.TakeBurnHeat()*TICRATE : 0;
        CaelumThermalService.Advance(user,WorldTicSeconds(),1.0/TICRATE,activity,burn,thermal.FireWatts,firearm);
    }

    static void NPCStep(CaelumCombatActor npc,bool force=false)
    {
        let ca871Probe=CA871ThermalProbe.FindSample();
        int ca871Family=ca871Probe!=null?CA871ThermalProbe.Family(npc):0;
        
        double ca871Start=ca871Probe!=null?MSTimeF():0;
        CA871Original0(npc,force);
        if(ca871Probe!=null)ca871Probe.Record(ca871Family*10+0,ca871Start);
        
        
    }
    static void CA871Original0(CaelumCombatActor npc,bool force=false)
    {
        if(npc.health<=0)return;
        int surfaceKind=CaelumThermalSurfaceData.NONE;
        if(npc.ThermalState!=null)
        {
            let contact=npc.ThermalState.Coefficients;
            if(contact==null)force=true;
            else if(contact.SurfaceMap)
            {
                surfaceKind=CaelumThermalSurface.KindAt(npc);
                force=force || surfaceKind!=CaelumThermalSurfaceData.NONE
                    || contact.PreviousSurface!=CaelumThermalSurfaceData.NONE;
            }
        }
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
        let contact=CaelumThermalCoefficients.Get(thermal);
        if(!contact.SurfaceScheduleReady)
        {
            contact.SurfaceScheduleReady=true;contact.SurfaceMap=world.HasThermalSurfaces;
            surfaceKind=contact.SurfaceMap ? CaelumThermalSurface.KindAt(npc) : CaelumThermalSurfaceData.NONE;
            contact.PreviousSurface=surfaceKind;
        }
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
        if(thermal.SealClimateRevision<CaelumSealClimateData.REVISION || thermal.SourceMap!=level.MapName || level.maptime-thermal.LastEnvironmentTic>=TICRATE
            || thermal.LastWaterLevel!=npc.WaterLevel || thermal.EnvironmentDate!=world.ReferenceWeather.SampleDate
            || thermal.EnvironmentMinute!=world.ReferenceWeather.SampleMinute || surfaceKind!=contact.PreviousSurface)
        {
            CaelumThermalEnvironment.Sample(npc,thermal,thermal.LocalMotionMps);
            thermal.FireWatts=CaelumThermalFire.Sample(npc,thermal);
            thermal.LastWaterLevel=npc.WaterLevel;thermal.EnvironmentDate=world.ReferenceWeather.SampleDate;
            thermal.EnvironmentMinute=world.ReferenceWeather.SampleMinute;
        }
        // Minuto de mundo como límite numérico. El total real se reparte una
        // vez: acelerar el calendario no multiplica el daño ni crea acciones.
        int steps=Max(1,int(Ceil(dw/60.0)));
        double firearm=dr>0 ? thermal.PendingFirearmJoules/dr : 0;
        double burn=dr>0 && npc.ElementalStatus!=null ? npc.ElementalStatus.TakeBurnHeat()/dr : 0;
        // Al entrar se cierra el intervalo anterior con su superficie anterior,
        // sin aplicar lava/hielo retroactivamente al segundo ambiental acumulado.
        for(int i=0;i<steps && npc.health>0;i++)CaelumThermalService.Advance(npc,dw/steps,dr/steps,dr>0 ? thermal.PendingActivityJoules/dr : 0,burn,thermal.FireWatts,firearm,contact.PreviousSurface);
        contact.PreviousSurface=surfaceKind;
        // La proyección visible corresponde al soporte actual, aunque el
        // intervalo cerrado haya pertenecido al soporte anterior.
        if(thermal.SurfaceKind!=surfaceKind)CaelumThermalSurface.Sample(npc,thermal,surfaceKind);
        if(dr>0)thermal.PendingFirearmJoules=0;
        thermal.PendingActivityJoules=0;
        thermal.LastRealTic=level.maptime;thermal.LastWorldStamp=now;
        thermal.NextUpdateTic=level.maptime+TICRATE;
    }
}

class CA871ThermalProbe : StaticEventHandler
{
    const METRICS=30;const WINDOW=700;
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;int CurrentFamily;
    static CA871ThermalProbe FindSample()
    {
        if(level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA871ThermalProbe(StaticEventHandler.Find('CA871ThermalProbe'));
    }
    static int Family(Actor body){return body is 'CaelumMandinga'?0:body is 'CaelumPortDefender'?1:2;}
    override void WorldLoaded(WorldEvent e)
    {Total.Resize(METRICS*WINDOW);Maximum.Resize(METRICS*WINDOW);Calls.Resize(METRICS*WINDOW);CurrentFamily=2;Ready=true;}
    void Record(int metric,double start)
    {double elapsed=MSTimeF()-start;int cell=metric*WINDOW+level.time-3599;Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;}
    void CountSlot(bool dry){Calls[(CurrentFamily*10+(dry?8:9))*WINDOW+level.time-3599]++;}
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<WINDOW;tic++)for(int metric=0;metric<METRICS;metric++)
        {int cell=metric*WINDOW+tic;if(Calls[cell]>0)Console.Printf("CA871 THERMAL tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA871 THERMAL_COMPLETE");
    }
}
