// Immutable offensive metadata stored by a Caelum projectile at launch.
// Keeping this base independent from CaelumCombatActor avoids circular class
// dependencies while allowing the receiver to inspect the result at impact.
class CaelumActorProjectile : Actor
{
    bool CaelumAttackPrepared;
    bool CaelumCriticalHit;
    bool CaelumAttackAccuracySucceeded;
    int CaelumPreparedDamage;

    void StoreCaelumAttackResult(
        int preparedDamage,
        bool accuracySucceeded,
        bool criticalHit
    )
    {
        CaelumAttackPrepared = true;
        CaelumPreparedDamage = Max(0, preparedDamage);
        CaelumAttackAccuracySucceeded = accuracySucceeded;
        CaelumCriticalHit = criticalHit;
    }

    int GetCaelumPreparedDamage(int fallbackDamage)
    {
        if (!CaelumAttackPrepared)
        {
            CaelumPreparedDamage = Max(0, fallbackDamage);
            CaelumAttackAccuracySucceeded = true;
            CaelumCriticalHit = false;
        }
        return CaelumPreparedDamage;
    }
}
