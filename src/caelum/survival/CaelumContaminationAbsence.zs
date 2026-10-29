// #502: el registro pertenece al cuerpo nativo. No retiene sectores, lÃ­neas,
// objetivos ni otros actores del mapa ausente. Los objetos del inventario
// siguen siendo los originales, tambiÃ©n en el protocolo viajero domÃ©stico.
class CaelumContaminationAbsence : Object play
{
    int Revision,Life;
    bool Away,Idle,Covered,Immune,Nonlethal;
    String Map;
    double Stamp,Civil,Reference,ActiveFraction,RecoveryRate;
    CaelumFoodClimate Climate;
    CaelumContaminationNPC Exposure;
    CaelumJourneyFood Foods;
    bool SyncPrepared;
    transient CaelumContaminationWeatherDay WeatherDay;

    static double Clock(CaelumPlayer user,String map)
    {
        let clock=CaelumWorldClock.Get(user);if(clock==null)return -1;
        if(!CaelumWorldCatalogue.IsLimboMap(map))return CaelumHouseAwayWork.Civil(user);
        return double(clock.LocalDays())*86400+double(clock.LocalTics())*3600/CaelumWorldClock.TicsPerHour()
            +double(clock.LimboSubTics)/TICRATE;
    }
    static void Capture(CaelumCombatActor npc,CaelumPlayer user)
    {
        if(npc==null || npc.health<=0 || !npc.CombatProfileInitialized || user==null)return;
        if(CaelumRedemption.Pending(npc))return;
        let summoned=CaelumSummonedZupay(npc);if(summoned!=null && summoned.AwaitingPlacement)return;
        if(npc.ContaminationAbsence!=null && npc.ContaminationAbsence.Away)return;
        CaelumThermalRuntime.NPCStep(npc,true);
        let thermal=CaelumThermalBody.Get(npc);
        // Un actor reciÃ©n inicializado puede salir antes de su primer turno
        // tÃ©rmico. Tomar la muestra nativa, sin inventar cuerpo ni ambiente.
        if(thermal==null || !thermal.Available)
            thermal=CaelumThermalService.CaptureForecast(npc);
        if(npc.health<=0)return;
        let row=npc.ContaminationAbsence;
        if(row==null){row=new('CaelumContaminationAbsence');npc.ContaminationAbsence=row;}
        row.Map=level.MapName;row.Stamp=Clock(user,row.Map);if(row.Stamp<0)return;
        row.Revision=CaelumContaminationData.NPC_ABSENCE_REVISION;row.Life=npc.health;row.Idle=npc.IsCombatIdle();
        row.NativePolicy(npc);
        row.RecoveryRate=CaelumContaminationNPC.HealthRate(npc);
        row.Reference=CaelumContaminationEnvironment.ReferenceAt(npc);
        row.Covered=CaelumThermalShelter.Roof(npc);
        row.Climate=new('CaelumFoodClimate');
        row.Climate.Capture(npc,CaelumWorldClock.Get(user),CaelumCalendarState.Get(user),CaelumWeatherState.Get(user));
        row.Civil=row.Climate.CivilSeconds;
        row.Exposure=null;row.WeatherDay=null;row.SyncPrepared=false;
        if(thermal!=null && thermal.Available)
        {row.Exposure=new('CaelumContaminationNPC');row.Exposure.Capture(npc,thermal);}
        row.Foods=new('CaelumJourneyFood');row.Foods.Capture(npc);
        if(row.Exposure!=null)row.Exposure.Frame.BindFood(row.Foods);
        row.Away=true;
    }
    void NativePolicy(CaelumCombatActor npc)
    {
        // Equivale a la entrada nativa de daÃ±o sostenido sin inflictor. Capturar
        // antes de que Suspend quite SHOOTABLE para aparcar al residente.
        Immune=npc.bInvulnerable || npc.bNoDamage || npc.bSpectral || (!npc.bShootable && !npc.bVulnerable)
            || !CaelumRedemption.AllowsDamage(null,npc,'CaelumDiseaseDOT');
        Nonlethal=npc.bBuddha;
        let resident=CaelumAnchoredResident(npc);
        if(resident!=null)
        {Nonlethal=Nonlethal || resident.IsProtectedStoryResident();Immune=Immune || resident.RuloPartyMode!=0;}
    }

    // Salta tics sin cambios enteros de Vida. Conserva exactamente el orden
    // enfermedad -> recuperaciÃ³n y sus residuos; no itera cada tic de dÃ­as.
    void Physiology(CaelumCombatActor npc,double seconds)
    {
        if(Life<=0 || seconds<=0)return;
        ActiveFraction+=seconds*TICRATE;
        int ticks=int(ActiveFraction+0.000000001);ActiveFraction=Max(0,ActiveFraction-ticks);
        let body=CaelumContaminationStorage.Get(npc,true);body.EnsurePhysiology();
        while(ticks>0 && Life>0)
        {
            double disease=CaelumFoodRules.DamagePerSecond(body.Concentration,npc.CombatMaximumHealth,
                CaelumToughnessRules.Effective(npc))/TICRATE;
            double healing=Idle && (Life<npc.CombatMaximumHealth || body.Concentration>0)?RecoveryRate/TICRATE:0;
            int skip=ticks;
            if(disease>0)skip=Min(skip,Max(0,int(Ceil((1-body.DiseaseFraction)/disease-0.000000001))-1));
            if(healing>0)skip=Min(skip,Max(0,int(Ceil((1-npc.IdleHealthAccumulator)/healing-0.000000001))-1));
            body.DiseaseFraction+=disease*skip;npc.IdleHealthAccumulator+=healing*skip;ticks-=skip;
            if(ticks<=0)break;
            ticks--;body.DiseaseFraction+=disease;
            int damage=int(body.DiseaseFraction+0.0000001);
            if(damage>0)
            {
                body.DiseaseFraction=Max(0,body.DiseaseFraction-damage);
                int retained=0;
                if(!Immune)
                {
                    retained=npc.GetModifiedDamage('CaelumDiseaseDOT',damage,true,null,null,DMG_NO_ARMOR);
                    if(retained>0)retained=npc.ApplyDamageFactor('CaelumDiseaseDOT',retained);
                    double previous=npc.RallyDamageFactor;
                    npc.RallyDamageFactor=CaelumRally.DamageFactor(npc,null)*CaelumSupportMagic.DamageFactor(npc,null);
                    if(retained>=0)retained=npc.TakeSpecialDamage(null,null,retained,'CaelumDiseaseDOT');
                    npc.RallyDamageFactor=previous;
                }
                Life=Max(Nonlethal?1:0,Life-Max(0,retained));
            }
            if(Life<=0)break;
            npc.IdleHealthAccumulator+=healing;
            int recovered=int(npc.IdleHealthAccumulator+0.0000001);
            npc.IdleHealthAccumulator=Max(0.0,npc.IdleHealthAccumulator-recovered);Life=Min(npc.CombatMaximumHealth,Life+recovered);
            if(npc.CombatMaximumHealth>0)body.Concentration=Max(0,body.Concentration-double(recovered)/npc.CombatMaximumHealth);
        }
    }
    void CommitSync(CaelumCombatActor npc)
    {
        if(!SyncPrepared || npc==null)return;
        if(Exposure!=null)Exposure.CommitCaptured(npc);
        if(Foods!=null)Foods.Commit(npc);
        SyncPrepared=false;
    }
    void SyncTo(CaelumCombatActor npc,double end,bool retain=false)
    {
        if(!Away || Revision!=CaelumContaminationData.NPC_ABSENCE_REVISION || npc==null)return;
        if(end<=Stamp){if(!retain)CommitSync(npc);return;}
        double scale=CaelumWorldClock.SecondsPerGameHour(Map)/3600.0;
        let body=CaelumContaminationStorage.Get(npc,true);body.EnsurePhysiology();
        // La carga pausada mantiene este cuerpo bajo un unico propietario.
        // Conservar el marco entre pulsos evita releer/aplicar el inventario
        // cada segundo activo. Antes de robos o de reanudar, se confirma todo.
        if(!SyncPrepared)
        {
            if(Foods==null){Foods=new('CaelumJourneyFood');Foods.Capture(npc);}else Foods.Refresh(npc);
            if(Exposure!=null){Exposure.Frame.ReadLive();Exposure.Frame.BindFood(Foods);Exposure.Body.Contamination=body.Concentration;}
            SyncPrepared=true;
        }
        while(Stamp<end && Life>0)
        {
            // La misma resoluciÃ³n ambiental de un segundo activo del servicio
            // tÃ©rmico; cortar tambiÃ©n en el minuto del clima de origen.
            double step=Min(end-Stamp,Min(1/scale,(Floor(Civil/60)+1)*60-Civil));
            if(step<=0)break;
            Foods.AdvanceClimate(step);
            if(Exposure!=null)
            {
                double ambient=-1;
                if(Reference>=0 && Climate!=null && Climate.Ready)
                {
                    let world=CaelumContaminationWorld.Get();
                    if(world!=null && Climate.Profile!=CaelumWeatherRules.PROFILE_LIMBO
                        && Climate.HeatDelta==0 && Climate.HumidityDelta==0)
                    {
                        if(world.HistoryWeather==null)world.HistoryWeather=new('CaelumContaminationWeatherCache');
                        int day=int(Floor(Civil/86400)),minute=int(Floor((Civil-double(day)*86400)/60));
                        if(WeatherDay==null || WeatherDay.Day!=day)
                            WeatherDay=world.HistoryWeather.FindDay(Climate.Profile,Climate.Region,Climate.Seed,
                                Climate.Shelter,Reference,Covered,day);
                        WeatherDay.Sample(minute);ambient=WeatherDay.Ambient[minute];
                    }
                    else
                    {
                        Climate.Rate(Civil);
                        if(Climate.Local!=null && Climate.Local.Available)
                            ambient=CaelumContaminationRules.Ambient(Reference,Climate.Local.AirTemperatureC+Climate.HeatDelta,
                                Clamp(Climate.Local.RelativeHumidityPercent+Climate.HumidityDelta,0.0,100.0),
                                Climate.Local.PrecipitationMmPerHour,!Covered);
                    }
                }
                Exposure.Frame.Advance(Exposure.Body,ambient,step);body.Concentration=Exposure.Body.Contamination;
            }
            Physiology(npc,step*scale);
            if(Exposure!=null)Exposure.Body.Contamination=body.Concentration;
            Stamp+=step;Civil+=step;
        }
        if(!retain)CommitSync(npc);
        // Un fallecido no recibe exposiciÃ³n ni recuperaciÃ³n retroactiva.
        if(Stamp<end){Civil+=end-Stamp;Stamp=end;}
    }
    static bool Alive(CaelumCombatActor npc,double civil)
    {
        if(npc==null || npc.bDestroyed || npc.health<=0)return false;
        let row=npc.ContaminationAbsence;
        if(row==null || !row.Away)return true;
        row.SyncTo(npc,civil);return row.Life>0;
    }
    static void Restore(CaelumCombatActor npc,CaelumPlayer user,double at=-1)
    {
        let row=npc.ContaminationAbsence;if(row==null || !row.Away)return;
        double now=at>=0?at:Clock(user,row.Map);if(now<0)return;
        row.SyncTo(npc,now);row.Away=false;
        if(npc.health<=0)return;
        npc.health=row.Life;
        if(row.Life<=0)
        {
            // La muerte nativa y el botÃ­n ocurren una sola vez, en su mapa.
            // Nunca invocar Die con los sectores del destino del viajero.
            npc.Die(null,null,DMG_NO_ARMOR,'CaelumDiseaseDOT');
        }
        else npc.UpdateCombatHealthEffects();
        row.Exposure=null;row.Foods=null;
    }
}
