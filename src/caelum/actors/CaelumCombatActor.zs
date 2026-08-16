// Base de combate compartida por los actores originales de Caelum.
// Gestiona anatomia, armadura localizada, refuerzo, durabilidad, resistencias,
// evasion, dolor, adrenalina y efectos de los estados de salud.
class CaelumCombatActor : Actor
{
    CaelumAnatomyProfile AnatomyProfile;
    CaelumArmorModel CombatArmor;
    int CombatMaximumHealth;
    int CombatToughness;
    int CombatResilience;
    int CombatAgility;
    int CombatPatience;
    int CombatDexterity;
    int CombatInsight;
    int CombatEffectiveDexterity;
    int CombatEffectiveInsight;
    int CombatStrength;
    int CombatIntelligence;
    bool CombatProfileInitialized;
    double CombatBaseSpeed;
    double CombatPhysicalPowerMultiplier;
    double CombatPhysicalPushMultiplier;
    double CombatMagicalPushMultiplier;

    double CurrentCombatAdrenaline;
    double MaximumCombatAdrenaline;
    double CombatTimeRemaining;
    double EffectiveCombatEvasionChance;
    double CombatHealthPerformanceMultiplier;
    double CombatHealthPainMultiplier;
    double CombatAdrenalineGainMultiplier;
    double CurrentCombatLucidity;
    int CombatLucidityState;
    double CombatLucidityAccuracyMultiplier;
    double CombatLucidityPhysicalStunRemaining;
    int CombatHealthState;
    double CombatPhysicalAccuracyPercent;
    double CombatMagicalAccuracyPercent;
    double CombatPhysicalCriticalChancePercent;
    double CombatMagicalCriticalChancePercent;

    bool LastCombatEvasionAttempted;
    bool LastCombatEvasionSucceeded;
    double LastCombatEvasionChancePercent;
    double LastCombatEvasionRollPercent;
    double LastCombatHealthLossPercent;
    double LastCombatToughnessDamageMultiplier;
    double LastCombatPainChancePercent;
    bool LastCombatPainTriggered;
    int LastAnatomyLocation;
    int LastAnatomyNaturalVulnerabilityGrade;
    int LastAnatomyVulnerabilityGrade;
    double LastAnatomyHeightRatio;
    double LastAnatomyLateralRatio;
    int LastCombatArmorSlot;
    int LastCombatArmorDefensePercent;
    double LastCombatArmorIncomingDamage;
    double LastCombatArmorAbsorbedDamage;
    double LastCombatArmorPostDefenseDamage;
    int LastCombatArmorDurabilityLoss;
    double LastCombatArmorDurabilityChancePercent;
    double LastCombatArmorDurabilityRollPercent;
    bool PendingLocalizedImpact;
    bool PendingLocalizedCriticalHit;
    double LastCombatLucidityLoss;
    double LastCombatLucidityCriticalFactor;
    bool LastCombatAttackAttempted;
    bool LastCombatAttackMagical;
    bool LastCombatAttackAccuracySucceeded;
    double LastCombatAttackAccuracyChancePercent;
    double LastCombatAttackAccuracyRollPercent;
    bool LastCombatAttackCriticalHit;
    double LastCombatAttackCriticalChancePercent;
    double LastCombatAttackCriticalRollPercent;
    int LastCombatAttackBaseDamage;
    int LastCombatAttackCalculatedDamage;
    double LastCombatPushForce;
    bool PendingCombatCriticalDelivery;

    Default
    {
        // El dolor nativo se desactiva para usar un unico calculo de Caelum.
        PainChance 0;
        // El retroceso se calcula despues de confirmar dano fisico real.
        +NODAMAGETHRUST
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        CombatBaseSpeed = Speed;
        CombatPhysicalPowerMultiplier = Max(0.0, Mass / 100.0);
        CombatMaximumHealth = Max(1, health);
        CombatHealthPerformanceMultiplier = 1.0;
        CombatHealthPainMultiplier = 1.0;
        CombatAdrenalineGainMultiplier = 1.0;
        LastCombatToughnessDamageMultiplier = 1.0;
        CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        CombatLucidityState = CaelumConstants.LUCIDITY_STATE_NORMAL;
        CombatLucidityAccuracyMultiplier = 1.0;
        LastCombatLucidityCriticalFactor = 1.0;
        if (AnatomyProfile == null)
        {
            AnatomyProfile = CaelumAnatomyProfile(new("CaelumAnatomyProfile"));
            AnatomyProfile.InitializeHumanoid();
        }
        LastAnatomyLocation = CaelumConstants.HIT_LOCATION_NONE;
        LastAnatomyNaturalVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        LastAnatomyVulnerabilityGrade = CaelumConstants.VULNERABILITY_NEUTRAL_POINT;
        LastCombatArmorSlot = CaelumConstants.ARMOR_SLOT_BODY;
        if (CombatArmor == null)
        {
            CombatArmor = CaelumArmorModel(new("CaelumArmorModel"));
            CombatArmor.InitializeUniformLoadout(
                CaelumConstants.ARMOR_TYPE_UNARMORED,
                1
            );
        }
        RecalculateCombatStatistics();
        UpdateActorLucidityState();
    }

    void InitializeCombatArmor(int requestedArmorType, int requestedTier)
    {
        if (CombatArmor == null)
        {
            CombatArmor = CaelumArmorModel(new("CaelumArmorModel"));
        }
        CombatArmor.InitializeUniformLoadout(requestedArmorType, requestedTier);
    }

    int GetArmorSlotForLocation(int location)
    {
        switch (location)
        {
            case CaelumConstants.HIT_LOCATION_HEAD:
                return CaelumConstants.ARMOR_SLOT_HEAD;
            case CaelumConstants.HIT_LOCATION_ARMS:
                return CaelumConstants.ARMOR_SLOT_HANDS;
            case CaelumConstants.HIT_LOCATION_LEGS:
                return CaelumConstants.ARMOR_SLOT_FEET;
            default:
                return CaelumConstants.ARMOR_SLOT_BODY;
        }
    }

    int GetEffectiveActorVulnerability(int naturalGrade, int location)
    {
        int reinforcement = 0;
        if (CombatArmor != null)
        {
            reinforcement = CombatArmor.GetReinforcement(
                GetArmorSlotForLocation(location)
            );
        }
        return Min(
            CaelumConstants.VULNERABILITY_ARMORED_POINT,
            naturalGrade + reinforcement
        );
    }

    int RegisterAnatomyImpact(double heightRatio, double lateralRatio)
    {
        LastAnatomyHeightRatio = Clamp(heightRatio, 0.0, 1.0);
        LastAnatomyLateralRatio = Clamp(lateralRatio, 0.0, 1.0);
        if (AnatomyProfile == null)
        {
            AnatomyProfile = CaelumAnatomyProfile(new("CaelumAnatomyProfile"));
            AnatomyProfile.InitializeHumanoid();
        }
        int regionIndex = AnatomyProfile.FindRegion(
            LastAnatomyHeightRatio,
            LastAnatomyLateralRatio
        );
        LastAnatomyLocation = AnatomyProfile.GetLocation(regionIndex);
        LastAnatomyNaturalVulnerabilityGrade = AnatomyProfile.GetVulnerability(regionIndex);
        LastAnatomyVulnerabilityGrade = GetEffectiveActorVulnerability(
            LastAnatomyNaturalVulnerabilityGrade,
            LastAnatomyLocation
        );
        PendingLocalizedImpact = true;
        return LastAnatomyVulnerabilityGrade;
    }

    // La anatomia se registra antes de resolver el critico. Esta marca explicita
    // separa el efecto critico del DamageMobj generico para todo tipo de dano.
    void RegisterPendingCriticalHit(bool criticalHit)
    {
        PendingLocalizedCriticalHit = PendingLocalizedImpact && criticalHit;
    }

    // Cada actor carga una vez sus atributos defensivos; puede recalcularlos.
    void InitializeCombatProfile(
        int toughness,
        int resilience,
        int agility,
        int patience,
        int dexterity,
        int insight,
        int strength,
        int intelligence
    )
    {
        CombatToughness = Max(0, toughness);
        CombatResilience = Max(0, resilience);
        CombatAgility = Max(0, agility);
        CombatPatience = Max(0, patience);
        CombatDexterity = Max(0, dexterity);
        CombatInsight = Max(0, insight);
        CombatStrength = Max(0, strength);
        CombatIntelligence = Max(0, intelligence);
        CombatProfileInitialized = true;
        RecalculateCombatStatistics();
    }

    void RecalculateCombatStatistics()
    {
        MaximumCombatAdrenaline = 1000.0
            * (100.0 + 2.0 * CombatResilience
                * (CombatResilience + 1) / 101.0) / 100.0;
        CurrentCombatAdrenaline = Clamp(
            CurrentCombatAdrenaline,
            0.0,
            MaximumCombatAdrenaline
        );
        UpdateCombatHealthEffects();
        UpdateActorOffensiveStatistics();
    }

    double CalculateActorType1Percent(int level)
    {
        return 100.0 + level * (level + 1) / 2.0;
    }

    double CalculateActorType2Percent(int level)
    {
        return level * (level + 1) / 101.0;
    }

    void UpdateActorOffensiveStatistics()
    {
        CombatEffectiveDexterity = CombatDexterity
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
        CombatEffectiveInsight = CombatInsight
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_INSIGHT);
        CombatPhysicalAccuracyPercent = CalculateActorType1Percent(
            CombatEffectiveDexterity
        );
        CombatMagicalAccuracyPercent = CalculateActorType1Percent(
            CombatEffectiveInsight
        );
        CombatPhysicalCriticalChancePercent = Clamp(
            CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateActorType2Percent(CombatEffectiveDexterity),
            0.0,
            100.0
        );
        CombatMagicalCriticalChancePercent = Clamp(
            CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT
                + CalculateActorType2Percent(CombatEffectiveInsight),
            0.0,
            100.0
        );
        CombatPhysicalPushMultiplier = Max(0.0, Mass / 100.0)
            * CalculateActorType1Percent(CombatStrength) / 100.0;
        CombatMagicalPushMultiplier = CalculateActorType1Percent(
            CombatIntelligence
        ) / 100.0;
    }

    // Entrada ofensiva comun: salud modifica dano, lucidez modifica precision
    // y el atributo propio del ataque determina su probabilidad critica.
    int PrepareActorOutgoingDamage(int baseDamage, bool magicalAttack)
    {
        UpdateCombatHealthEffects();
        UpdateActorOffensiveStatistics();
        LastCombatAttackAttempted = true;
        LastCombatAttackMagical = magicalAttack;
        LastCombatAttackBaseDamage = Max(0, baseDamage);
        LastCombatAttackAccuracyChancePercent = Clamp(
            (magicalAttack
                ? CombatMagicalAccuracyPercent
                : CombatPhysicalAccuracyPercent)
                * CombatLucidityAccuracyMultiplier,
            0.0,
            100.0
        );
        if (CombatLucidityPhysicalStunRemaining > 0.0)
        {
            LastCombatAttackAccuracyChancePercent = 0.0;
        }
        int accuracyRoll = Random[CaelumActorOffensiveAccuracy](0, 999999);
        LastCombatAttackAccuracyRollPercent = accuracyRoll / 10000.0;
        LastCombatAttackAccuracySucceeded =
            LastCombatAttackAccuracyRollPercent
                < LastCombatAttackAccuracyChancePercent;
        LastCombatAttackCriticalChancePercent = magicalAttack
            ? CombatMagicalCriticalChancePercent
            : CombatPhysicalCriticalChancePercent;
        LastCombatAttackCriticalRollPercent = 0.0;
        LastCombatAttackCriticalHit = false;
        PendingCombatCriticalDelivery = false;
        LastCombatAttackCalculatedDamage = 0;
        MarkActorCombatActivity();
        if (!LastCombatAttackAccuracySucceeded) { return 0; }

        int criticalRoll = Random[CaelumActorOffensiveCritical](0, 999999);
        LastCombatAttackCriticalRollPercent = criticalRoll / 10000.0;
        LastCombatAttackCriticalHit = LastCombatAttackCriticalRollPercent
            < LastCombatAttackCriticalChancePercent;
        PendingCombatCriticalDelivery = LastCombatAttackCriticalHit;
        LastCombatAttackCalculatedDamage = Max(
            1,
            int(LastCombatAttackBaseDamage
                * (magicalAttack ? 1.0 : CombatPhysicalPowerMultiplier)
                * CombatHealthPerformanceMultiplier + 0.5)
        );
        return LastCombatAttackCalculatedDamage;
    }

    bool ConsumePendingCombatCritical()
    {
        bool result = PendingCombatCriticalDelivery;
        PendingCombatCriticalDelivery = false;
        return result;
    }

    // La masa corporal genera empuje; la masa total del receptor lo resiste.
    double GetActorKnockbackMultiplier(Actor receiver)
    {
        if (receiver == null) { return 0.0; }
        CaelumCombatActor combatReceiver = CaelumCombatActor(receiver);
        double receiverMass = Max(1.0, receiver.Mass);
        if (combatReceiver != null && combatReceiver.CombatArmor != null)
        {
            receiverMass += combatReceiver.CombatArmor.GetTotalWeight();
        }
        return 100.0 / (receiverMass + 50.0);
    }

    void ApplyActorAttackPush(Actor receiver, double attackAngle, double attackerMultiplier)
    {
        LastCombatPushForce = 0.0;
        if (receiver == null || receiver.health <= 0) { return; }
        LastCombatPushForce = CaelumConstants.BASE_ATTACK_PUSH_FORCE
            * Max(0.0, attackerMultiplier)
            * GetActorKnockbackMultiplier(receiver);
        if (LastCombatPushForce > 0.0)
        {
            receiver.Thrust(LastCombatPushForce, attackAngle);
        }
    }

    action void A_CaelumMeleeAttack(int baseDamage)
    {
        // Las acciones sin alcance explicito son invocables desde estados de
        // monstruo. El casteo recupera el tipo concreto para llamar su logica.
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            false
        );
        if (calculatedDamage <= 0) { return; }
        Actor meleeVictim = combatActor.Target;
        int victimHealthBefore = meleeVictim != null ? meleeVictim.health : 0;
        combatActor.A_CustomMeleeAttack(
            calculatedDamage,
            "weapons/swordhit"
        );
        if (meleeVictim != null && meleeVictim.health < victimHealthBefore)
        {
            combatActor.ApplyActorAttackPush(
                meleeVictim,
                combatActor.AngleTo(meleeVictim),
                combatActor.CombatPhysicalPushMultiplier
            );
        }
        // Un impacto consume esta marca sincronicamente en CaelumPlayer.
        // Un fallo no debe dejar un critico pendiente para otro dano posterior.
        combatActor.PendingCombatCriticalDelivery = false;
    }

    // El resultado a distancia queda fijado al disparar. Los cambios posteriores
    // del atacante no alteran un proyectil que ya esta viajando por el mundo.
    action void A_CaelumSpawnProjectile(
        class<CaelumActorProjectile> missileType,
        double spawnHeight,
        int baseDamage,
        bool magicalAttack
    )
    {
        CaelumCombatActor combatActor = CaelumCombatActor(self);
        if (combatActor == null) { return; }
        int calculatedDamage = combatActor.PrepareActorOutgoingDamage(
            baseDamage,
            magicalAttack
        );
        if (calculatedDamage <= 0) { return; }

        CaelumActorProjectile missile = CaelumActorProjectile(
            combatActor.A_SpawnProjectile(missileType, spawnHeight)
        );
        if (missile != null)
        {
            missile.StoreCaelumAttackResult(
                calculatedDamage,
                combatActor.LastCombatAttackAccuracySucceeded,
                combatActor.LastCombatAttackCriticalHit,
                magicalAttack,
                magicalAttack
                    ? combatActor.CombatMagicalPushMultiplier
                    : combatActor.CombatPhysicalPushMultiplier
            );
        }
        combatActor.PendingCombatCriticalDelivery = false;
    }

    override int DamageMobj(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags,
        double angle
    )
    {
        LastCombatEvasionAttempted = false;
        LastCombatEvasionSucceeded = false;
        LastCombatEvasionChancePercent = 0.0;
        LastCombatEvasionRollPercent = 0.0;

        if (IsCombatDamageEvadable(inflictor, source, damage, mod, flags))
        {
            LastCombatEvasionAttempted = true;
            LastCombatEvasionChancePercent = Clamp(
                EffectiveCombatEvasionChance,
                0.0,
                100.0
            );
            int evasionRoll = Random[CaelumActorEvasion](0, 999999);
            LastCombatEvasionRollPercent = evasionRoll / 10000.0;
            if (LastCombatEvasionRollPercent < LastCombatEvasionChancePercent)
            {
                LastCombatEvasionSucceeded = true;
                PendingLocalizedImpact = false;
                PendingLocalizedCriticalHit = false;
                AddActorCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_EVASION
                );
                MarkActorCombatActivity();
                return 0;
            }
        }

        if (flags & DMG_EXPLOSION)
        {
            PendingLocalizedImpact = false;
            PendingLocalizedCriticalHit = false;
            return ApplyActorExplosionDefense(
                inflictor,
                source,
                damage,
                mod,
                flags,
                angle
            );
        }

        int healthBeforeDamage = health;
        double adrenalineRatioBeforeDamage = GetCombatAdrenalineRatio();
        bool hadLocalizedImpactForLucidity = PendingLocalizedImpact;
        int naturalVulnerabilityBeforeDamage = hadLocalizedImpactForLucidity
            ? LastAnatomyNaturalVulnerabilityGrade
            : CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
        int effectiveVulnerabilityBeforeDamage = hadLocalizedImpactForLucidity
            ? LastAnatomyVulnerabilityGrade
            : CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
        bool localizedCriticalHit = PendingLocalizedCriticalHit;
        ResolveActorArmorImpact(damage);
        PendingLocalizedCriticalHit = false;
        LastCombatToughnessDamageMultiplier = Clamp(
            1.0 - CombatToughness * (CombatToughness + 1) / 10100.0,
            0.0,
            1.0
        );
        int retainedDamage = Max(
            0,
            int(LastCombatArmorPostDefenseDamage
                * LastCombatToughnessDamageMultiplier + 0.5)
        );
        if (retainedDamage <= 0) { return 0; }
        int result = Super.DamageMobj(
            inflictor,
            source,
            retainedDamage,
            mod,
            flags,
            angle
        );

        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
            if (attackProjectile != null)
            {
                ApplyActorAttackPush(
                    self,
                    inflictor.Angle,
                    attackProjectile.CaelumPushMultiplier
                );
            }
            ApplyActorLocalizedLucidityLoss(
                naturalVulnerabilityBeforeDamage,
                effectiveVulnerabilityBeforeDamage,
                localizedCriticalHit
            );
            UpdateCombatHealthEffects();
            CalculateAndTriggerActorPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage
            );
            AddActorCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE
            );
            MarkActorCombatActivity();
        }

        return result;
    }

    double GetActorEffectiveExplosionRadius(Actor inflictor, int incomingDamage)
    {
        double resolvedRadius = Max(1.0, double(incomingDamage));
        if (inflictor == null) { return resolvedRadius; }

        resolvedRadius = inflictor.ExplosionRadius;
        if (resolvedRadius < 0.0)
        {
            resolvedRadius = inflictor.ExplosionDamage;
        }
        if (resolvedRadius <= 0.0)
        {
            resolvedRadius = Max(1.0, double(incomingDamage));
        }
        return resolvedRadius;
    }

    int ApplyActorExplosionDefense(
        Actor inflictor,
        Actor source,
        int incomingDamage,
        Name mod,
        int flags,
        double damageAngle
    )
    {
        if (incomingDamage <= 0 || inflictor == null || AnatomyProfile == null)
        {
            return 0;
        }
        if (bInvulnerable)
        {
            return Super.DamageMobj(
                inflictor, source, incomingDamage, mod, flags, damageAngle
            );
        }

        double explosionRadius = GetActorEffectiveExplosionRadius(
            inflictor,
            incomingDamage
        );
        int touchedRegionMask = AnatomyProfile.GetExplosionTouchedRegionMask(
            self,
            inflictor.Pos,
            explosionRadius
        );
        if (touchedRegionMask == 0) { return 0; }

        CaelumActorProjectile attackProjectile = CaelumActorProjectile(inflictor);
        bool criticalHit = attackProjectile != null
            && attackProjectile.CaelumCriticalHit;
        LastCombatArmorIncomingDamage = 0.0;
        LastCombatArmorAbsorbedDamage = 0.0;
        LastCombatArmorPostDefenseDamage = 0.0;
        LastCombatArmorDurabilityLoss = 0;
        LastCombatArmorDurabilityChancePercent = 0.0;
        LastCombatArmorDurabilityRollPercent = 0.0;
        LastCombatToughnessDamageMultiplier = Clamp(
            1.0 - CombatToughness * (CombatToughness + 1) / 10100.0,
            0.0,
            1.0
        );

        int totalHealthDamage = 0;
        int lucidityNaturalGrade = -1;
        int lucidityEffectiveGrade = -1;
        double lucidityDefensePercent = 0.0;
        for (int regionIndex = 0;
            regionIndex < AnatomyProfile.RegionCount;
            regionIndex++)
        {
            if ((touchedRegionMask & (1 << regionIndex)) == 0) { continue; }

            int location = AnatomyProfile.GetLocation(regionIndex);
            int naturalGrade = AnatomyProfile.GetVulnerability(regionIndex);
            int effectiveGrade = GetEffectiveActorVulnerability(
                naturalGrade,
                location
            );
            int slot = GetArmorSlotForLocation(location);
            double preDefenseDamage = incomingDamage
                * GetActorVulnerabilityMultiplier(effectiveGrade);
            int defensePercent = CombatArmor != null
                ? CombatArmor.GetDefense(slot) : 0;
            double defenseRatio = Clamp(defensePercent / 100.0, 0.0, 1.0);
            double absorbedDamage = preDefenseDamage * defenseRatio;
            double postDefenseDamage = Max(
                0.0,
                preDefenseDamage - absorbedDamage
            );

            LastAnatomyLocation = location;
            LastAnatomyNaturalVulnerabilityGrade = naturalGrade;
            LastAnatomyVulnerabilityGrade = effectiveGrade;
            LastCombatArmorSlot = slot;
            LastCombatArmorDefensePercent = defensePercent;
            LastCombatArmorIncomingDamage += preDefenseDamage;
            LastCombatArmorAbsorbedDamage += absorbedDamage;
            LastCombatArmorPostDefenseDamage += postDefenseDamage;
            totalHealthDamage += Max(
                0,
                int(postDefenseDamage
                    * LastCombatToughnessDamageMultiplier + 0.5)
            );

            if (naturalGrade == CaelumConstants.VULNERABILITY_CRITICAL_POINT
                && lucidityNaturalGrade < 0)
            {
                lucidityNaturalGrade = naturalGrade;
                lucidityEffectiveGrade = effectiveGrade;
                lucidityDefensePercent = defensePercent;
            }

            if (CombatArmor != null
                && CombatArmor.Durability[slot] > 0
                && absorbedDamage > 0.0)
            {
                int durabilityLoss = int(
                    absorbedDamage
                        / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
                );
                double remainder = absorbedDamage
                    - durabilityLoss
                        * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
                double chancePercent = Clamp(
                    remainder
                        / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
                    0.0,
                    100.0
                );
                double rollPercent = Random[CaelumActorArmorDurability](0, 999999)
                    / 10000.0;
                if (rollPercent < chancePercent) { durabilityLoss++; }
                durabilityLoss = Min(
                    durabilityLoss,
                    CombatArmor.Durability[slot]
                );
                CombatArmor.Durability[slot] -= durabilityLoss;
                LastCombatArmorDurabilityLoss += durabilityLoss;
                LastCombatArmorDurabilityChancePercent = chancePercent;
                LastCombatArmorDurabilityRollPercent = rollPercent;
            }
        }

        if (totalHealthDamage <= 0) { return 0; }
        int healthBeforeDamage = health;
        double adrenalineRatioBeforeDamage = GetCombatAdrenalineRatio();
        int result = Super.DamageMobj(
            inflictor,
            source,
            totalHealthDamage,
            mod,
            flags | DMG_NO_ARMOR,
            damageAngle
        );
        if (health < healthBeforeDamage)
        {
            int actualHealthLost = healthBeforeDamage - health;
            if (attackProjectile != null)
            {
                ApplyActorAttackPush(
                    self,
                    inflictor.AngleTo(self),
                    attackProjectile.CaelumPushMultiplier
                );
            }
            if (lucidityNaturalGrade >= 0)
            {
                LastCombatArmorDefensePercent = int(lucidityDefensePercent);
                ApplyActorLocalizedLucidityLoss(
                    lucidityNaturalGrade,
                    lucidityEffectiveGrade,
                    criticalHit
                );
            }
            UpdateCombatHealthEffects();
            CalculateAndTriggerActorPain(
                actualHealthLost,
                adrenalineRatioBeforeDamage
            );
            AddActorCombatAdrenaline(
                CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE
            );
            MarkActorCombatActivity();
        }
        return result;
    }

    // Natural anatomy decides whether lucidity is affected even when armor
    // reinforcement changes the effective grade. Defense and Toughness reduce
    // the loss; a critical uses the same effective vulnerability relation as
    // the player's localized rule.
    void ApplyActorLocalizedLucidityLoss(
        int naturalVulnerabilityGrade,
        int effectiveVulnerabilityGrade,
        bool criticalHit
    )
    {
        LastCombatLucidityLoss = 0.0;
        LastCombatLucidityCriticalFactor = 1.0;
        if (naturalVulnerabilityGrade
            != CaelumConstants.VULNERABILITY_CRITICAL_POINT)
        {
            return;
        }

        double normalMultiplier = GetActorVulnerabilityMultiplier(
            effectiveVulnerabilityGrade
        );
        if (criticalHit)
        {
            // Critical multiplier = normal * (normal + 1), therefore its
            // relative lucidity factor is normal + 1.
            LastCombatLucidityCriticalFactor = normalMultiplier + 1.0;
        }
        double defenseRatio = Clamp(
            LastCombatArmorDefensePercent / 100.0,
            0.0,
            1.0
        );
        LastCombatLucidityLoss = Min(
            CurrentCombatLucidity,
            CaelumConstants.CRITICAL_POINT_BASE_LUCIDITY_LOSS
                * LastCombatLucidityCriticalFactor
                * (1.0 - defenseRatio)
                * LastCombatToughnessDamageMultiplier
        );
        CurrentCombatLucidity = Max(
            0.0,
            CurrentCombatLucidity - LastCombatLucidityLoss
        );
        UpdateActorLucidityState();
    }

    void UpdateActorLucidityState()
    {
        int previousState = CombatLucidityState;
        double ratio = CurrentCombatLucidity
            / CaelumConstants.MAXIMUM_LUCIDITY;
        if (ratio <= CaelumConstants.LUCIDITY_STUNNED_THRESHOLD)
        {
            CombatLucidityState = CaelumConstants.LUCIDITY_STATE_STUNNED;
        }
        else if (ratio <= CaelumConstants.LUCIDITY_DIZZY_THRESHOLD)
        {
            CombatLucidityState = CaelumConstants.LUCIDITY_STATE_DIZZY;
        }
        else
        {
            CombatLucidityState = CaelumConstants.LUCIDITY_STATE_NORMAL;
        }

        CombatLucidityAccuracyMultiplier = CombatLucidityState
            == CaelumConstants.LUCIDITY_STATE_NORMAL
            ? 1.0
            : CaelumConstants.LUCIDITY_DIZZY_ACCURACY_MULTIPLIER;
        if (previousState != CaelumConstants.LUCIDITY_STATE_STUNNED
            && CombatLucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            CombatLucidityPhysicalStunRemaining =
                CaelumConstants.LUCIDITY_PHYSICAL_STUN_SECONDS;
        }
    }

    void ResolveActorArmorImpact(int incomingDamage)
    {
        bool hadLocalizedImpact = PendingLocalizedImpact;
        LastCombatArmorIncomingDamage = Max(0, incomingDamage);
        LastCombatArmorAbsorbedDamage = 0.0;
        LastCombatArmorPostDefenseDamage = LastCombatArmorIncomingDamage;
        LastCombatArmorDurabilityLoss = 0;
        LastCombatArmorDurabilityChancePercent = 0.0;
        LastCombatArmorDurabilityRollPercent = 0.0;

        if (!PendingLocalizedImpact)
        {
            LastAnatomyLocation = CaelumConstants.HIT_LOCATION_TORSO;
            LastAnatomyNaturalVulnerabilityGrade =
                CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
            LastAnatomyVulnerabilityGrade = GetEffectiveActorVulnerability(
                LastAnatomyNaturalVulnerabilityGrade,
                LastAnatomyLocation
            );
            LastAnatomyHeightRatio = 0.60;
            LastAnatomyLateralRatio = 0.0;
        }
        PendingLocalizedImpact = false;

        // Sword/staff traces already include the authored region multiplier.
        // Damage without contact metadata adopts the sensitive torso fallback
        // here so ordinary attacks still enter the same vulnerability order.
        if (!hadLocalizedImpact)
        {
            LastCombatArmorIncomingDamage *=
                GetActorVulnerabilityMultiplier(LastAnatomyVulnerabilityGrade);
            LastCombatArmorPostDefenseDamage = LastCombatArmorIncomingDamage;
        }

        LastCombatArmorSlot = GetArmorSlotForLocation(LastAnatomyLocation);
        LastCombatArmorDefensePercent = CombatArmor != null
            ? CombatArmor.GetDefense(LastCombatArmorSlot) : 0;
        double defenseRatio = Clamp(
            LastCombatArmorDefensePercent / 100.0,
            0.0,
            1.0
        );
        LastCombatArmorAbsorbedDamage =
            LastCombatArmorIncomingDamage * defenseRatio;
        LastCombatArmorPostDefenseDamage = Max(
            0.0,
            LastCombatArmorIncomingDamage - LastCombatArmorAbsorbedDamage
        );

        if (CombatArmor == null
            || CombatArmor.Durability[LastCombatArmorSlot] <= 0
            || LastCombatArmorAbsorbedDamage <= 0.0)
        {
            return;
        }

        LastCombatArmorDurabilityLoss = int(
            LastCombatArmorAbsorbedDamage
                / CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY
        );
        double remainder = LastCombatArmorAbsorbedDamage
            - LastCombatArmorDurabilityLoss
                * CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
        LastCombatArmorDurabilityChancePercent = Clamp(
            remainder / CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT,
            0.0,
            100.0
        );
        int durabilityRoll = Random[CaelumActorArmorDurability](0, 999999);
        LastCombatArmorDurabilityRollPercent = durabilityRoll / 10000.0;
        if (LastCombatArmorDurabilityRollPercent
            < LastCombatArmorDurabilityChancePercent)
        {
            LastCombatArmorDurabilityLoss++;
        }
        LastCombatArmorDurabilityLoss = Min(
            LastCombatArmorDurabilityLoss,
            CombatArmor.Durability[LastCombatArmorSlot]
        );
        CombatArmor.Durability[LastCombatArmorSlot] -=
            LastCombatArmorDurabilityLoss;
    }

    double GetActorVulnerabilityMultiplier(int grade)
    {
        switch (Clamp(grade, 0, CaelumConstants.VULNERABILITY_GRADE_COUNT - 1))
        {
            case CaelumConstants.VULNERABILITY_CRITICAL_POINT:
                return CaelumConstants.VULNERABILITY_CRITICAL_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_SENSITIVE_POINT:
                return CaelumConstants.VULNERABILITY_SENSITIVE_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_WEAK_POINT:
                return CaelumConstants.VULNERABILITY_WEAK_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_STRONG_POINT:
                return CaelumConstants.VULNERABILITY_STRONG_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_HARD_POINT:
                return CaelumConstants.VULNERABILITY_HARD_MULTIPLIER;
            case CaelumConstants.VULNERABILITY_ARMORED_POINT:
                return CaelumConstants.VULNERABILITY_ARMORED_MULTIPLIER;
            default:
                return CaelumConstants.VULNERABILITY_NEUTRAL_MULTIPLIER;
        }
    }

    bool IsCombatDamageEvadable(
        Actor inflictor,
        Actor source,
        int damage,
        Name mod,
        int flags
    )
    {
        if (health <= 0 || damage <= 0 || (flags & DMG_EXPLOSION))
        {
            return false;
        }
        if (inflictor != null && inflictor.bMissile)
        {
            return true;
        }
        return source != null
            && (mod == 'Melee'
                || mod == 'Hitscan'
                || mod == 'Bullet'
                || mod == 'CaelumMeleeTest'
                || mod == 'CaelumRangedTest'
                || mod == 'CaelumMagicTest');
    }

    void CalculateAndTriggerActorPain(
        int actualHealthLost,
        double adrenalineRatioBeforeDamage
    )
    {
        LastCombatHealthLossPercent = 0.0;
        LastCombatPainChancePercent = 0.0;
        LastCombatPainTriggered = false;
        if (actualHealthLost <= 0 || CombatMaximumHealth <= 0 || health <= 0)
        {
            return;
        }

        LastCombatHealthLossPercent = 100.0
            * actualHealthLost / CombatMaximumHealth;
        LastCombatPainChancePercent = Clamp(
            10.0 * LastCombatHealthLossPercent
                * LastCombatToughnessDamageMultiplier
                * CombatHealthPainMultiplier
                * (1.0 - adrenalineRatioBeforeDamage),
            0.0,
            100.0
        );

        int painRoll = Random[CaelumActorPain](0, 999999);
        if (painRoll < int(LastCombatPainChancePercent * 10000.0))
        {
            State painState = FindState('Pain');
            if (painState != null)
            {
                SetState(painState);
                LastCombatPainTriggered = true;
                AddActorCombatAdrenaline(
                    CaelumConstants.ADRENALINE_GAIN_ON_PAIN
                );
            }
        }
    }

    double GetCombatAdrenalineRatio()
    {
        if (MaximumCombatAdrenaline <= 0.0) { return 0.0; }
        return Clamp(
            CurrentCombatAdrenaline / MaximumCombatAdrenaline,
            0.0,
            1.0
        );
    }

    void AddActorCombatAdrenaline(double baseAmount)
    {
        CurrentCombatAdrenaline = Clamp(
            CurrentCombatAdrenaline
                + Max(0.0, baseAmount) * CombatAdrenalineGainMultiplier,
            0.0,
            MaximumCombatAdrenaline
        );
        UpdateCombatHealthEffects();
    }

    void MarkActorCombatActivity()
    {
        CombatTimeRemaining = CaelumConstants.COMBAT_TIMEOUT_SECONDS;
    }

    void UpdateCombatHealthEffects()
    {
        double healthRatio = CombatMaximumHealth > 0
            ? Clamp(double(health) / CombatMaximumHealth, 0.0, 1.0)
            : 1.0;
        double rawPerformance = 1.0;
        double rawIntensity = 1.0;
        if (healthRatio <= CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD)
        {
            CombatHealthState = CaelumConstants.HEALTH_STATE_BADLY_WOUNDED;
            rawPerformance =
                CaelumConstants.HEALTH_BADLY_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensity =
                CaelumConstants.HEALTH_BADLY_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else if (healthRatio <= CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            CombatHealthState = CaelumConstants.HEALTH_STATE_WOUNDED;
            rawPerformance =
                CaelumConstants.HEALTH_WOUNDED_PERFORMANCE_MULTIPLIER;
            rawIntensity =
                CaelumConstants.HEALTH_WOUNDED_INTENSITY_MULTIPLIER;
        }
        else
        {
            CombatHealthState = CaelumConstants.HEALTH_STATE_NORMAL;
        }

        int effectivePatience = CombatPatience
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_PATIENCE);
        int effectiveAgility = CombatAgility
            + GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_AGILITY);
        double patienceMultiplier = Clamp(
            1.0 - effectivePatience * (effectivePatience + 1) / 10100.0,
            0.0,
            1.0
        );
        double adrenalineRatio = GetCombatAdrenalineRatio();
        double patienceAdjustedPerformance = 1.0
            - (1.0 - rawPerformance) * patienceMultiplier;
        CombatHealthPerformanceMultiplier = patienceAdjustedPerformance
            + (1.0 - patienceAdjustedPerformance) * adrenalineRatio;
        CombatHealthPainMultiplier = 1.0
            + (rawIntensity - 1.0)
                * patienceMultiplier
                * (1.0 - adrenalineRatio);
        CombatAdrenalineGainMultiplier = rawIntensity;

        double baseEvasion = effectiveAgility * (effectiveAgility + 1) / 101.0;
        double massMultiplier = 100.0 / (Mass / 2.0 + 50.0);
        EffectiveCombatEvasionChance = baseEvasion
            * massMultiplier
            * CombatHealthPerformanceMultiplier;
        Speed = CombatBaseSpeed * CombatHealthPerformanceMultiplier;
    }

    void CycleDebugCombatHealthState()
    {
        double healthRatio = CombatMaximumHealth > 0
            ? double(health) / CombatMaximumHealth : 1.0;
        if (healthRatio > CaelumConstants.HEALTH_WOUNDED_THRESHOLD)
        {
            health = Max(1, int(CombatMaximumHealth
                * CaelumConstants.HEALTH_WOUNDED_THRESHOLD));
        }
        else if (healthRatio > CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD)
        {
            health = Max(1, int(CombatMaximumHealth
                * CaelumConstants.HEALTH_BADLY_WOUNDED_THRESHOLD));
        }
        else
        {
            health = CombatMaximumHealth;
        }
        UpdateCombatHealthEffects();
    }

    void CycleDebugCombatLucidityState()
    {
        if (CombatLucidityState == CaelumConstants.LUCIDITY_STATE_NORMAL)
        {
            CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_DIZZY_THRESHOLD;
        }
        else if (CombatLucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY
                * CaelumConstants.LUCIDITY_STUNNED_THRESHOLD;
        }
        else
        {
            CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        }
        UpdateActorLucidityState();
    }

    int GetCombatArmorAttributeBonus(int attribute)
    {
        if (CombatArmor == null) { return 0; }
        int total = 0;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            if (CombatArmor.GetBonusAttribute(slot) == attribute)
            {
                total += CombatArmor.GetTierBonus(slot);
            }
        }
        return total;
    }

    override void Tick()
    {
        Super.Tick();
        UpdateCombatHealthEffects();
        UpdateActorOffensiveStatistics();
        if (health > 0
            && CurrentCombatLucidity < CaelumConstants.MAXIMUM_LUCIDITY)
        {
            CurrentCombatLucidity = Min(
                CaelumConstants.MAXIMUM_LUCIDITY,
                CurrentCombatLucidity
                    + CaelumConstants.MAXIMUM_LUCIDITY
                        / CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS
                        / TICRATE
            );
            UpdateActorLucidityState();
        }
        if (CombatLucidityPhysicalStunRemaining > 0.0)
        {
            Vel.X = 0.0;
            Vel.Y = 0.0;
            CombatLucidityPhysicalStunRemaining = Max(
                0.0,
                CombatLucidityPhysicalStunRemaining - 1.0 / TICRATE
            );
        }
        if (CombatTimeRemaining > 0.0)
        {
            CombatTimeRemaining = Max(
                0.0,
                CombatTimeRemaining - 1.0 / TICRATE
            );
        }
        else if (CurrentCombatAdrenaline > 0.0)
        {
            CurrentCombatAdrenaline = Max(
                0.0,
                CurrentCombatAdrenaline
                    - CaelumConstants.ADRENALINE_DECAY_PER_SECOND / TICRATE
            );
        }
    }
}
