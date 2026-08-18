// Puff sin retroceso nativo: Caelum aplica su propia formula de masa despues.
class CaelumNoDamageThrustPuff : BulletPuff
{
    Default
    {
        +NODAMAGETHRUST
    }
}

// Immutable offensive metadata stored by a Caelum projectile at launch.
// Keeping this base independent from CaelumCombatActor avoids circular class
// dependencies while allowing the receiver to inspect the result at impact.
class CaelumActorProjectile : Actor
{
    bool CaelumAttackPrepared;
    bool CaelumCriticalHit;
    bool CaelumAttackAccuracySucceeded;
    bool CaelumMagicalAttack;
    int CaelumPreparedDamage;
    double CaelumPushMultiplier;
    int CaelumEssenceType;
    bool CaelumSecondaryElement;
    double CaelumDebuffPowerPercent;
    double CaelumBuffPowerPercent;
    bool CaelumElementalPayloadPrepared;

    Default
    {
        +NODAMAGETHRUST
    }

    void StoreCaelumElementalPayload(
        int essenceType,
        bool secondaryElement,
        double debuffPowerPercent,
        double buffPowerPercent
    )
    {
        CaelumElementalPayloadPrepared = true;
        CaelumEssenceType = Clamp(
            essenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
        CaelumSecondaryElement = secondaryElement;
        CaelumDebuffPowerPercent = Max(0.0, debuffPowerPercent);
        CaelumBuffPowerPercent = Max(0.0, buffPowerPercent);
    }

    void StoreCaelumAttackResult(
        int preparedDamage,
        bool accuracySucceeded,
        bool criticalHit,
        bool magicalAttack,
        double pushMultiplier
    )
    {
        CaelumAttackPrepared = true;
        CaelumPreparedDamage = Max(0, preparedDamage);
        CaelumAttackAccuracySucceeded = accuracySucceeded;
        CaelumCriticalHit = criticalHit;
        CaelumMagicalAttack = magicalAttack;
        CaelumPushMultiplier = Max(0.0, pushMultiplier);
    }

    int GetCaelumPreparedDamage(int fallbackDamage)
    {
        if (!CaelumAttackPrepared)
        {
            CaelumPreparedDamage = Max(0, fallbackDamage);
            CaelumAttackAccuracySucceeded = true;
            CaelumCriticalHit = false;
            CaelumMagicalAttack = false;
            CaelumPushMultiplier = 1.0;
        }
        return CaelumPreparedDamage;
    }
}
