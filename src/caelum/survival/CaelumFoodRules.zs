// Reglas compartidas; no dependen de inventarios, HUD ni del reloj global.
class CaelumFoodRules : Object
{
    static clearscope double EnvironmentRate(double celsius,double humidity)
    {
        if(celsius<=CaelumFoodData.FREEZE_CELSIUS || celsius>=CaelumFoodData.HOT_HOLD_CELSIUS)return 0;
        return (2.0**((celsius-CaelumFoodData.REFERENCE_CELSIUS)/CaelumFoodData.DOUBLING_CELSIUS))
            *(CaelumFoodData.HUMIDITY_BASE_FACTOR+Clamp(humidity,0.0,100.0)/100.0);
    }
    static clearscope double Aged(double contamination,int kind,double seconds,double celsius,double humidity)
    {
        double hours=CaelumFoodData.FreshHours(kind);
        double growth=hours>0 ? CaelumFoodData.MAX_CONTAMINATION*Max(0.0,seconds)*EnvironmentRate(celsius,humidity)/(hours*3600.0) : 0;
        return Clamp(contamination+growth,0.0,CaelumFoodData.MAX_CONTAMINATION);
    }
    static clearscope double Intake(double foodContamination,double grams,double bodyKg)
    {
        if(bodyKg<=0)return 0;
        return Clamp(foodContamination,0.0,CaelumFoodData.MAX_CONTAMINATION)
            *Max(0.0,grams)/CaelumFoodData.REFERENCE_PORTION_G*CaelumFoodData.REFERENCE_BODY_KG/bodyKg;
    }
    static clearscope double Hunger(int kind,double grams,double bodyKg)
    {
        if(bodyKg<=0)return 0;
        return CaelumFoodData.PortionKcal(kind)/CaelumFoodData.REFERENCE_KCAL
            *(CaelumFoodData.HUNGER_MASS_FACTOR/bodyKg)*Max(0.0,grams)/CaelumFoodData.REFERENCE_PORTION_G;
    }
    static clearscope double DamagePerSecond(double contamination,double maximumLife,double toughness)
    {
        return Max(0.0,contamination-CaelumFoodData.ILLNESS_THRESHOLD)*Max(0.0,maximumLife)
            *CaelumFoodData.DAMAGE_MAX_LIFE_PER_DEGREE_SECOND*Max(0.0,CaelumToughnessRules.StatusResponse(toughness));
    }
}

// Única autoridad guardada en el inventario persistente del personaje.
class CaelumFoodIllness : Object play
{
    int Revision;
    double Contamination,DamageFraction;

    void Ensure()
    {
        if(Revision>=CaelumFoodData.REVISION)return;
        Contamination=0;DamageFraction=0;Revision=CaelumFoodData.REVISION;
    }
    static CaelumFoodIllness Get(CaelumPlayer user)
    {
        if(user==null)return null;
        let record=user.GetPersistentCharacterState(false);if(record==null)return null;
        if(record.FoodIllness==null)record.FoodIllness=new('CaelumFoodIllness');
        record.FoodIllness.Ensure();return record.FoodIllness;
    }
    static clearscope double Value(CaelumPlayer user)
    {
        let record=user!=null ? CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState')) : null;
        return record!=null && record.FoodIllness!=null ? record.FoodIllness.Contamination : 0;
    }
    static void Ingest(CaelumPlayer user,double foodContamination,double grams)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.DerivedStats==null)return;
        let illness=Get(user);if(illness==null)return;
        illness.Contamination=Min(CaelumFoodData.MAX_CONTAMINATION,illness.Contamination
            +CaelumFoodRules.Intake(foodContamination,grams,user.DerivedStats.BaseMass));
    }
    static void Recover(CaelumPlayer user,double naturalLifeEffort)
    {
        let illness=Get(user);
        if(illness==null || user.CaelumMaximumHealth<=0)return;
        illness.Contamination=Max(0.0,illness.Contamination-Max(0.0,naturalLifeEffort)/user.CaelumMaximumHealth);
    }
    static void Advance(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.player==null
            || user.player.playerstate!=PST_LIVE || user.Attributes==null)return;
        let illness=Get(user);if(illness==null)return;
        illness.DamageFraction+=CaelumFoodRules.DamagePerSecond(illness.Contamination,
            user.CaelumMaximumHealth,user.Attributes.Toughness)/TICRATE;
        // Igual que los pulsos existentes: compensar sólo redondeo binario.
        int damage=int(illness.DamageFraction+0.0000001);if(damage<=0)return;
        illness.DamageFraction=Max(0.0,illness.DamageFraction-damage);
        int before=user.health,visual=user.PendingDamageVFXKind;
        user.PendingDamageVFXKind=0;
        user.DamageMobj(null,null,damage,'CaelumDiseaseDOT',DMG_NO_ARMOR,0.0);
        user.PendingDamageVFXKind=visual;
        CaelumRestSafety.PeriodicLoss(user,Max(0,before-user.health));
        if(user.health<=0)CaelumRestSafety.Interrupt(user,"CA_REST_UNAVAILABLE");
    }
}
