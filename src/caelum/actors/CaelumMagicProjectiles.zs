// The visual sheets provide one blue and one violet ranged effect. Both use a
// fixed newly-created-character-scale hit before live actor state modifiers.
class CaelumArgentoMagicBolt : CaelumActorProjectile
{
    Default
    {
        Radius 4;
        Height 4;
        Speed 24;
        Damage 1;
        DamageType "CaelumMagicTest";
        Projectile;
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        return GetCaelumPreparedDamage(
            CaelumConstants.TEST_ACTOR_RANGED_DAMAGE
        );
    }

    States
    {
    Spawn:
        CAMG A 2 Bright;
        Loop;
    Death:
        CAMG A 3 Bright;
        Stop;
    }
}

class CaelumCaellaMagicBolt : CaelumArgentoMagicBolt
{
    States
    {
    Spawn:
        CAMG B 2 Bright;
        Loop;
    Death:
        CAMG B 3 Bright;
        Stop;
    }
}

class CaelumRuloThrownAxe : CaelumActorProjectile
{
    Default
    {
        Radius 6;
        Height 6;
        Speed 20;
        Damage 1;
        DamageType "CaelumRangedTest";
        Projectile;
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        return GetCaelumPreparedDamage(
            CaelumConstants.TEST_RULO_RANGED_DAMAGE
        );
    }

    States
    {
    Spawn:
        CARU A 2 Bright;
        Loop;
    Death:
        CARU A 3 Bright;
        Stop;
    }
}

class CaelumRonnieMagicBolt : CaelumActorProjectile
{
    Default
    {
        Radius 4;
        Height 4;
        Speed 28;
        Damage 1;
        DamageType "CaelumMagicTest";
        Projectile;
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        return GetCaelumPreparedDamage(
            CaelumConstants.TEST_RONNIE_MAGIC_DAMAGE
        );
    }

    States
    {
    Spawn:
        CARO B 2 Bright;
        Loop;
    Death:
        CARO B 3 Bright;
        Stop;
    }
}
