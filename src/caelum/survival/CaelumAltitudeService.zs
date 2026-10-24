// Reutiliza el marcador físico guardado y el handler ya presente en saves viejos.
// La referencia queda cacheada al cargar, sin búsquedas por cuerpo o tic.
class CaelumAltitudeWorld : Object play
{
    static CaelumPhysicsMapState Get()
    {
        let ticker=CaelumWorldClockTicker(StaticEventHandler.Find("CaelumWorldClockTicker"));
        return ticker!=null ? ticker.AltitudeMap : null;
    }
}

// #413: un estado por cuerpo y el reloj ya compartido. No busca otros actores.
class CaelumAltitudeService : Object play
{
    static CaelumAltitudeState Get(Actor body,bool create=false)
    {
        if(body==null || CaelumRedemption.Pending(body))return null;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        CaelumAltitudeState altitude;
        if(user!=null)
        {
            if(!CaelumPlayerAuthority.CanMutate(user))return null;
            let record=user.GetPersistentCharacterState(create);
            if(record==null)return null;
            if(record.AltitudeState==null && create)record.AltitudeState=new("CaelumAltitudeState");
            altitude=record.AltitudeState;
        }
        else if(npc!=null && npc.CombatProfileInitialized)
        {
            if(npc.AltitudeState==null && create)npc.AltitudeState=new("CaelumAltitudeState");
            altitude=npc.AltitudeState;
        }
        if(altitude!=null && create)altitude.Initialize();
        return altitude;
    }

    static double Stamp(CaelumWorldClock clock)
    {
        if(clock==null)return 0;
        // La fracción del Limbo sigue perteneciendo al reloj al cambiar de mapa.
        return double(clock.CompletedDays)*CaelumThermalData.WORLD_DAY_SECONDS
            +double(clock.DayTics)*3600.0/CaelumWorldClock.TicsPerHour()
            +double(clock.LimboSubTics)/TICRATE;
    }

    static CaelumWorldClock Clock(Actor body)
    {
        let user=CaelumPlayer(body);
        if(user!=null)return CaelumWorldClock.Get(user);
        let world=CaelumThermalWorld.Get();
        return world!=null ? world.ReferenceClock : null;
    }

    static double HeightMeters(Actor body)
    {
        if(CaelumAltitudeData.NeutralAtmosphere(level.MapName))return 0;
        let world=CaelumAltitudeWorld.Get();
        return Max(0.0,(world!=null ? world.AltitudeBaseMeters : 0.0)
            +body.Pos.Z/CaelumPhysicsUnits.MAP_UNITS_PER_METER);
    }

    static void RefreshAttributes(Actor body,CaelumAltitudeState altitude)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null && user.Attributes!=null && user.DerivedStats!=null && user.CharacterProfile!=null)
        {
            altitude.Race=user.CharacterProfile.Race;
            altitude.SelectTarget(altitude.Ratio,1.0+user.DerivedStats.CalculateType2Percent(Max(0.0,user.Attributes.Resilience))/100.0);
        }
        else if(npc!=null)
        {
            altitude.Race=npc.GetArmorRace();
            altitude.SelectTarget(altitude.Ratio,1.0+npc.CalculateActorType2Percent(Max(0,npc.CombatResilience
                +npc.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_RESILIENCE)))/100.0);
        }
        altitude.NextAttributeTic=level.maptime+TICRATE;
    }

    static CaelumAltitudeState Update(Actor body)
    {
        if(body==null || body.health<=0)return null;
        let user=CaelumPlayer(body);
        if(user!=null && (!user.CharacterCreationComplete || user.CreationWizardOpen))return null;
        let altitude=Get(body,true);let clock=Clock(body);
        if(altitude==null || clock==null)return altitude;
        double now=Stamp(clock),height=HeightMeters(body);
        bool changed=!altitude.ClockReady || altitude.LastMap!=level.MapName || altitude.LastHeight!=height;
        if(!changed && now==altitude.LastStamp && level.maptime<altitude.NextAttributeTic && level.maptime>=altitude.LastTic)return altitude;
        // El intervalo transcurrido pertenece a la altura anterior, incluso
        // al volver a un NPC del hub. Cargar no añade tiempo de reloj real.
        if(altitude.ClockReady)altitude.Advance(Max(0.0,now-altitude.LastStamp));
        if(changed)
        {
            altitude.LastHeight=height;altitude.Ratio=CaelumAltitudeRules.PressureRatio(height);
            altitude.SelectTarget(altitude.Ratio,altitude.GainMultiplier);
        }
        if(!altitude.ClockReady || altitude.LastMap!=level.MapName || level.maptime>=altitude.NextAttributeTic || level.maptime<altitude.LastTic)
            RefreshAttributes(body,altitude);
        altitude.ClockReady=true;altitude.LastStamp=now;altitude.LastMap=level.MapName;altitude.LastTic=level.maptime;
        altitude.RefreshFactors();
        return altitude;
    }

    static double Recovery(Actor body)
    { let altitude=Update(body);return altitude!=null ? altitude.RecoveryFactor : 1.0; }
    static double Effort(Actor body)
    { let altitude=Update(body);return altitude!=null ? altitude.EffortFactor : 1.0; }

    static void StopClock(Actor body)
    {
        let altitude=Get(body);
        if(altitude!=null)altitude.ClockReady=false;
    }
    static void CommitForecast(CaelumPlayer user,CaelumAltitudeState forecast)
    {
        if(forecast==null)return;
        let record=user.GetPersistentCharacterState(true);
        if(record==null)return;
        record.AltitudeState=forecast.Copy();
        record.AltitudeState.LastStamp=Stamp(Clock(user));
        record.AltitudeState.LastMap=level.MapName;
        record.AltitudeState.LastTic=level.maptime;
        record.AltitudeState.ClockReady=user.health>0;
    }
}
