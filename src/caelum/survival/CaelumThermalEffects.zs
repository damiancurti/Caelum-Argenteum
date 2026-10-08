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

    static clearscope double FirearmWatts(double area,bool reloading)
    {
        double met=reloading ? CaelumThermalData.CARBINE_RELOAD_MET : CaelumThermalData.CARBINE_FIRE_MET;
        return Max(0.0,area)*CaelumThermalData.MET_WATTS_M2*Max(0.0,met-1.0);
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

    static void PlayerFirearmTic(CaelumPlayer user)
    {
        if(user.WeaponModel==null || !user.WeaponModel.Equipped || user.WeaponModel.Durability<=0
            || !CaelumRangedRules.IsFirearm(user.WeaponModel.WeaponType)
            || user.IsPhysicallyImmobilized() || user.CombatBlockModeActive)return;
        if(user.RangedReloadActive && CaelumRangedRules.IsFirearm(user.RangedReloadWeaponType))
            RecordFirearmWork(user,Min(1.0/TICRATE,user.RangedReloadRemainingSeconds
                /Max(0.000001,user.GetReloadProgressMultiplier())),true);
        else if(user.AttackAnimationMap==level.MapName
            && CaelumRangedRules.IsFirearm(user.AttackAnimationKind)
            && user.AttackAnimationItemId==user.ActiveWeaponItemId)
            RecordFirearmWork(user,Min(1.0/TICRATE,Max(0.0,
                (user.AttackAnimationStartTic+user.AttackAnimationDurationTics-level.time+1)/TICRATE)),false);
    }

    static double EffortWatts(Actor body,double nominalAirPerSecond)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null)return 0;
        return CaelumThermalRules.ProfiledActionHeat(thermal.ReferenceJumpHeat,
            nominalAirPerSecond,NominalJumpAir(body));
    }
}
