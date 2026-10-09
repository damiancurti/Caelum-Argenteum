// Adaptadores de consecuencias: los costes nominales siguen en sus catálogos.
class CaelumThermalEffects : Object play
{
    static int Incoming(Actor body,Actor inflictor,Actor source,int damage,Name mod)
    {
        if(damage<=0 || mod=='CaelumImpact' || mod=='Crush' || mod=='CaelumWeight'
            || mod=='Drowning' || mod=='CaelumThermal')return damage;
        if(!(source is 'CaelumPlayer') && !(source is 'CaelumCombatActor')
            && !(inflictor is 'CaelumActorProjectile'))return damage;
        let thermal=CaelumThermalBody.Get(body);
        if(thermal==null)return damage;
        let user=CaelumPlayer(source);let npc=CaelumCombatActor(source);
        bool blunt=!(inflictor is 'CaelumActorProjectile')
            && ((user!=null && user.ThermalBluntDelivery) || (npc!=null && npc.ThermalBluntDelivery));
        return int(damage*CaelumThermalRules.ColdAttack(thermal.Exposure,thermal.Toughness,blunt)+0.5);
    }

    static double HeatCost(Actor body)
    {
        let thermal=CaelumThermalBody.Get(body);
        return thermal==null ? 1 : CaelumThermalRules.HeatCost(thermal.Exposure,thermal.Toughness);
    }

    static double Speed(Actor body)
    {
        let thermal=CaelumThermalBody.Get(body);
        return thermal==null ? 1 : CaelumThermalRules.Speed(thermal.Exposure,thermal.Toughness);
    }

    static double NominalJumpAir(Actor body)
    {
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        if(user!=null && user.DerivedStats!=null)
            return CaelumConstants.JUMP_AIR_COST*user.DerivedStats.AirConsumptionMultiplier;
        return npc!=null ? npc.GetEffectiveAttackAir(CaelumConstants.JUMP_AIR_COST) : 0;
    }

    static void RecordAction(Actor body,double nominalAir)
    { CaelumThermalService.ProfiledAction(body,nominalAir,NominalJumpAir(body)); }

    static void RecordWeaponAction(Actor body,int type,bool secondary=false,bool charged=false,bool sweep=false)
    {
        double work=CaelumThermalData.WeaponWork(type,secondary);
        if(charged)work*=CaelumThermalData.CHARGED_WORK_MULTIPLIER;
        if(sweep)work*=CaelumThermalData.SWEEP_WORK_MULTIPLIER;
        CaelumThermalService.Impulse(body,CaelumThermalRules.PositiveWorkHeat(work),true);
    }

    static clearscope double FirearmWatts(double area,bool reloading)
    {
        double work=reloading ? CaelumThermalData.RELOAD_WORK_JOULES_PER_M2 : CaelumThermalData.FIRE_WORK_JOULES_PER_M2;
        double duration=reloading ? CaelumThermalData.RELOAD_REFERENCE_SECONDS : CaelumThermalData.FIRE_CYCLE_REFERENCE_SECONDS;
        return CaelumThermalRules.PositiveWorkHeat(Max(0.0,area)*work)/duration;
    }

    static clearscope double SwimmingWatts(double area,bool fast)
    {
        double work=fast ? CaelumThermalData.SWIM_FAST_WORK_WATTS_PER_M2 : CaelumThermalData.SWIM_WORK_WATTS_PER_M2;
        return CaelumThermalRules.PositiveWorkHeat(Max(0.0,area)*work);
    }

    static clearscope double PushingWatts(double area)
    {
        return Max(0.0,area)*CaelumThermalData.MET_WATTS_M2*Max(0.0,CaelumThermalData.PUSH_MET-1.0);
    }

    static clearscope double BlockingWatts(double movedMassKg,double heldMassKg)
    {
        return Max(0.0,movedMassKg)*Max(0.0,heldMassKg)
            *CaelumThermalData.BLOCK_WATTS_PER_BODY_KG_HELD_KG;
    }

    static double FirearmActionHeat(Actor body,bool reloading)
    {
        let thermal=CaelumThermalBody.Get(body,true);if(thermal==null)return 0;
        CaelumThermalBody.Refresh(body,thermal);
        return FirearmWatts(thermal.SurfaceArea,reloading)*(reloading
            ? CaelumThermalData.RELOAD_REFERENCE_SECONDS : CaelumThermalData.FIRE_CYCLE_REFERENCE_SECONDS);
    }

    static void RecordFirearmShot(Actor body)
    {
        let thermal=CaelumThermalBody.Get(body,true);if(thermal==null || body.health<=0)return;
        thermal.PendingFirearmJoules+=FirearmActionHeat(body,false);
    }

    static void BeginFirearmReload(Actor body)
    {
        let thermal=CaelumThermalBody.Get(body,true);if(thermal==null)return;
        thermal.ReloadHeatBudget=FirearmActionHeat(body,true);
    }

    // Cobrar sólo la fracción de tarea completada; destreza y ralentización
    // alteran la duración, nunca los julios de una misma recarga completa.
    static void RecordReloadProgress(Actor body,double completedSeconds,double totalSeconds)
    {
        if(body==null || body.health<=0 || totalSeconds<=0 || completedSeconds<=0)return;
        let thermal=CaelumThermalBody.Get(body,true);if(thermal==null)return;
        // Al cargar una revisión antigua sólo se paga el progreso futuro.
        if(thermal.ReloadHeatBudget<=0)BeginFirearmReload(body);
        thermal.PendingFirearmJoules+=thermal.ReloadHeatBudget*Clamp(completedSeconds/totalSeconds,0.0,1.0);
    }

    // Acumular trabajo no fuerza una integración del NPC por cada tic. La
    // siguiente actualización térmica consume la energía persistente una vez.
    static void RecordFirearmWork(Actor body,double seconds,bool reloading)
    {
        if(body==null || body.health<=0 || seconds<=0)return;
        let thermal=CaelumThermalBody.Get(body,true);if(thermal==null)return;
        if(thermal.SurfaceArea<=0)CaelumThermalBody.Refresh(body,thermal);
        thermal.PendingFirearmJoules+=FirearmWatts(thermal.SurfaceArea,reloading)*seconds;
    }

    // Adaptador sólo para fixtures históricos; los eventos reales pagan el
    // disparo una vez y la recarga según su progreso, no por animación residual.
    static void PlayerFirearmTic(CaelumPlayer user) {}

    static double EffortWatts(Actor body,double nominalAirPerSecond)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null)return 0;
        return CaelumThermalRules.ProfiledActionHeat(thermal.ReferenceJumpHeat,
            nominalAirPerSecond,NominalJumpAir(body));
    }
}
