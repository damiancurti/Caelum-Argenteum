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
    // Solo vive durante DamageMobj; evita repetir el dano y desgaste nativos.
    transient Actor CaelumDefenseReceiver;
    transient bool CaelumPreparingDefense;

    virtual void ApplyPreparedWeaponWear(Actor victim){}

    static int PrepareDefense(Actor victim,Actor inflictor,int damage,Name mod,int flags)
    {
        let shot=CaelumActorProjectile(inflictor);
        if(shot!=null && shot.PreventSummoningFriendlyFire(victim))return 0;
        if(shot==null || shot.CaelumDefenseReceiver==victim || (flags & DMG_FORCED)
            || (damage>=CaelumCrushingDamage.NATIVE_TELEFRAG_THRESHOLD && !victim.bLAXTELEFRAGDMG))return damage;
        if(victim.health<=0 || victim.bDORMANT
            || (victim.bINVULNERABLE && !shot.bFOILINVUL && !(flags & DMG_FOILINVUL)))return damage;
        shot.ResolveCaelumCritical(victim);
        // Una explosion ya trae su propio presupuesto, no el impacto directo.
        if(!(flags & DMG_EXPLOSION))
        {
            bool previous=shot.CaelumPreparingDefense;shot.CaelumPreparingDefense=true;
            damage=shot.DoSpecialDamage(victim,damage,mod);
            shot.CaelumPreparingDefense=previous;
        }
        else
        {
            if((shot is "CaelumActorSimpleElementalProjectile" || shot is "CaelumActorExplosiveElementalProjectile")
                && shot.PreventCaelumMassDiagnosticFriendlyFire(victim))return 0;
            shot.ApplyPreparedWeaponWear(victim);
        }
        shot.CaelumDefenseReceiver=victim;
        return damage;
    }


    Array<Actor> ThermalRecipients;
    bool CaelumAttackPrepared;
    bool MainM00ChargedPractice;
    bool MainM00MobilePractice;
    bool CaelumCriticalHit;
    int CaelumCriticalRevision;
    bool CaelumHunterEligible;
    double CaelumCriticalBaseChance,CaelumCriticalRollPercent;
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
    int CaelumTravelRevision;
    double CaelumTravelledDistance;
    bool CaelumDiagnosticCompletionRecorded;
    // Campos cosméticos: cero en saves anteriores; no alteran el vuelo guardado.
    int CaelumVFXAge,CaelumVFXRevision;
    int CaelumRockVisualRevision;
    bool CaelumZupayRockVisual;
    bool CaelumVFXImpactShown;
    // #249/#250 conservan la protección aliada aunque expire su invocación/conversión.
    bool CaelumSummonShot;
    CaelumPlayer CaelumSummonOwner;

    bool PreventSummoningFriendlyFire(Actor victim)
    {return CaelumSummonShot && !CaelumSummoning.Enemy(CaelumSummonOwner,victim);}

    // Conserva la identidad del arma que originó el proyectil. Así la
    // durabilidad se descuenta del objeto correcto aunque el jugador cambie
    // de arma antes de que el proyectil impacte.
    bool CaelumWeaponWearPrepared;
    int CaelumPersonalityRevision;
    double CaelumIdeologyPenetration;
    CaelumEquipmentItem CaelumWearSourceItem;
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
        let summoned=CaelumSummonedZupay(Target);
        if(summoned!=null)
        {
            CaelumSummonShot=true;
            CaelumSummonOwner=CaelumPlayer(summoned.master);
        }
        let commander=CaelumRedemption.Commander(Target);
        if(commander!=null){CaelumSummonShot=true;CaelumSummonOwner=commander;}
        CaelumPreparedDamage = Max(0, preparedDamage);
        CaelumAttackAccuracySucceeded = accuracySucceeded;
        CaelumCriticalHit = criticalHit;
        CaelumMagicalAttack = magicalAttack;
        CaelumPushMultiplier = Max(0.0, pushMultiplier);
        // Capturar al lanzar, incluida la jabalina sin desgaste diferido.
        CaelumIdeologyPenetration=CaelumPersonalityRules.Penetration(CaelumPersonalityRules.Profile(Target));
        CaelumPersonalityRevision=CaelumPersonalityRules.REVISION;
    }

    void StoreCaelumCriticalRoll(double chance,double roll)
    {
        CaelumCriticalRevision=CaelumHuntersInstinct.CRITICAL_REVISION;
        CaelumCriticalBaseChance=Clamp(chance,0.0,100.0);
        CaelumCriticalRollPercent=roll;
        CaelumHunterEligible=CaelumHuntersInstinct.Active(CaelumPlayer(Target));
    }

    void ResolveCaelumCritical(Actor victim)
    {
        // Los vuelos antiguos conservan su resultado; nunca se vuelve a tirar.
        if(CaelumCriticalRevision!=CaelumHuntersInstinct.CRITICAL_REVISION)return;
        CaelumCriticalHit=CaelumCriticalRollPercent<CaelumHuntersInstinct.RearChance(
            Target,victim,CaelumCriticalBaseChance,CaelumHunterEligible);
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

    override void Tick()
    {
        if(CaelumTravelRevision<1)
        {
            // En vuelos antiguos de velocidad fija, la edad guardada conserva
            // lo ya recorrido. Los proyectiles antiguos sin límite lo retienen.
            let simple=CaelumActorSimpleElementalProjectile(self);
            let explosive=CaelumActorExplosiveElementalProjectile(self);
            CaelumTravelledDistance=simple!=null ? simple.CaelumLifetimeTicks*Max(1.0,Speed)
                : explosive!=null ? explosive.CaelumDistanceTraveled : 0;
            CaelumTravelRevision=1;
        }
        bool limited=bMissile && CaelumMaximumTravelDistance>0;
        if(limited)
        {
            double remaining=CaelumMaximumTravelDistance-CaelumTravelledDistance;
            if(remaining<=0){RegisterCaelumDiagnosticCompletion(false,true);Destroy();return;}
            double step=Vel.Length();
            // Limitar antes de la colisión impide un impacto después del alcance.
            if(step>remaining)Vel*=remaining/step;
        }
        vector3 previous=Pos;
        Super.Tick();
        if(limited && bMissile)
        {
            CaelumTravelledDistance+=(Pos-previous).Length();
            if(CaelumTravelledDistance>=CaelumMaximumTravelDistance)
            {RegisterCaelumDiagnosticCompletion(false,true);Destroy();}
        }
    }

    void RegisterCaelumDiagnosticCompletion(bool impact, bool expired)
    {
        if (CaelumDiagnosticCompletionRecorded) { return; }
        CaelumDiagnosticCompletionRecorded = true;
        CaelumCombatActor projectileOwner = CaelumCombatActor(target);
        if (projectileOwner == null || level.MapName != "TACTORS") { return; }
        if (impact) { projectileOwner.ImpactDiagnosticProjectileImpacts++; }
        if (expired) { projectileOwner.ImpactDiagnosticProjectilesExpired++; }
        projectileOwner.ImpactDiagnosticProjectilesDestroyed++;
    }

    bool PreventCaelumMassDiagnosticFriendlyFire(Actor victim)
    {
        CaelumCombatActor projectileOwner = CaelumCombatActor(target);
        if (projectileOwner == null
            || !projectileOwner.IsCaelumMassDiagnosticAlly(victim))
        {
            return false;
        }
        projectileOwner.ImpactDiagnosticFriendlyFirePrevented++;
        return true;
    }

    action void A_CaelumRecordDiagnosticProjectileImpact()
    {
        CaelumActorProjectile projectile = CaelumActorProjectile(self);
        if (projectile != null)
        {
            projectile.RegisterCaelumDiagnosticCompletion(true, false);
            CaelumElementalVFX.Impact(projectile);
        }
    }

    action void A_CaelumShowElementalImpact()
    {
        CaelumElementalVFX.Impact(CaelumActorProjectile(invoker));
    }

    void StoreCaelumWeaponWearIdentity(
        int weaponType,
        int tier,
        int equipmentSize
    )
    {
        CaelumWeaponWearPrepared = true;
        let user = CaelumPlayer(Target);
        if (user != null) CaelumWearSourceItem = user.FindNativeEquipmentItemById(user.ActiveWeaponItemId);
        CaelumWearWeaponType = weaponType;
        CaelumWearWeaponTier = tier;
        CaelumWearWeaponSize = equipmentSize;
    }

    override int SpecialMissileHit(Actor victim)
    {
        if(PreventSummoningFriendlyFire(victim))return MHIT_PASS;
        let ally = CaelumAnchoredResident(Target);
        if (ally != null && ally.RuloPartyMode != 0
            && (victim == ally.RuloPartyTraveler
                || CaelumMainM00RuloTrial.IsPartyMember(victim, ally.RuloPartyTraveler))) return MHIT_PASS;
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
