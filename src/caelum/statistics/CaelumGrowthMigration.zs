// Fórmulas antiguas únicamente para migrar registros viajeros que no guardaban
// máximos. Las curvas actuales siempre proceden de CaelumGrowthRules.
class CaelumGrowthMigration : Object play
{
    static double LegacyLargePercent(double level)
    { return 100.0+level*(level+1.0)/2.0; }
    static double LegacyModerateMultiplier(double level)
    { return 1.0+2.0*level*(level+1.0)/10100.0; }

    static void StoredResources(CaelumPlayer user,CaelumPersistentCharacterState record)
    {
        if(record.GrowthRevision>=CaelumGrowthRules.REVISION || user.DerivedStats==null || user.Attributes==null)return;
        let stats=user.DerivedStats;let attributes=user.Attributes;
        double oldHealth=Max(1,int(CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE
            *LegacyLargePercent(attributes.Constitution)*stats.BaseMassMultiplier));
        double oldAnima=CaelumConstants.HEALTH_ANIMA_DAMAGE_SCALE*LegacyLargePercent(attributes.Patience);
        double oldAir=CaelumConstants.BASE_AIR_CAPACITY*LegacyModerateMultiplier(attributes.Resilience);
        double oldAdrenaline=100.0*CaelumConstants.ADRENALINE_CAPACITY_SCALE*LegacyModerateMultiplier(attributes.Resilience);
        if(record.StoredHealth>0)
            record.StoredHealth=Max(1,int(Clamp(record.StoredHealth/oldHealth,0.0,1.0)*int(stats.MaximumHealth)+0.5));
        record.StoredAnima=Clamp(record.StoredAnima/oldAnima,0.0,1.0)*stats.MaximumAnima;
        record.StoredAir=Clamp(record.StoredAir/oldAir,0.0,1.0)*stats.MaximumAir;
        record.StoredAdrenaline=Clamp(record.StoredAdrenaline/oldAdrenaline,0.0,1.0)*stats.MaximumAdrenaline;
        record.StoredUnderwaterAirRecoveryDebt*=stats.MaximumAir/oldAir;
        record.GrowthRevision=CaelumGrowthRules.REVISION;
    }
}
