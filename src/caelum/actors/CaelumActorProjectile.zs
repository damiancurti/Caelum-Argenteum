// Puff sin retroceso nativo: Caelum aplica su propia formula de masa despues.
class CaelumNoDamageThrustPuff : BulletPuff
{
    Default
    {
        +NODAMAGETHRUST
    }
}

// Puff invisible usado únicamente para trazas de detección. Evita que una
// comprobación lógica de alcance genere un falso efecto de impacto.
class CaelumSilentDetectionPuff : BulletPuff
{
    Default
    {
        +NODAMAGETHRUST
    }

    States
    {
    Spawn:
        TNT1 A 1;
        Stop;
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
    int CaelumActorExplosionDamage;
    double CaelumActorExplosionRadius;
    double CaelumMaximumTravelDistance;

    // Conserva la identidad del arma que originó el proyectil. Así la
    // durabilidad se descuenta del objeto correcto aunque el jugador cambie
    // de arma antes de que el proyectil impacte.
    bool CaelumWeaponWearPrepared;
    int CaelumWearWeaponType;
    int CaelumWearWeaponTier;
    int CaelumWearWeaponSize;

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

    void ConfigureCaelumActorExplosion(
        int damage,
        double radius,
        double maximumTravelDistance
    )
    {
        CaelumActorExplosionDamage = Max(0, damage);
        CaelumActorExplosionRadius = Max(1.0, radius);
        ConfigureCaelumTravelDistance(maximumTravelDistance);
    }

    void ConfigureCaelumTravelDistance(double maximumTravelDistance)
    {
        CaelumMaximumTravelDistance = Max(1.0, maximumTravelDistance);
    }

    void StoreCaelumWeaponWearIdentity(
        int weaponType,
        int tier,
        int equipmentSize
    )
    {
        CaelumWeaponWearPrepared = true;
        CaelumWearWeaponType = weaponType;
        CaelumWearWeaponTier = tier;
        CaelumWearWeaponSize = equipmentSize;
    }

    override int SpecialMissileHit(Actor victim)
    {
        CaelumPlayer playerVictim = CaelumPlayer(victim);
        if (playerVictim != null
            && playerVictim.CombatBlockModeActive
            && playerVictim.ShieldModel != null
            && playerVictim.ShieldModel.Equipped
            && playerVictim.ShieldModel.ShieldType
                == CaelumConstants.SHIELD_TYPE_MAGIC)
        {
            playerVictim.RegisterNativeReflectedShieldBlock(self);
        }
        return Super.SpecialMissileHit(victim);
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
