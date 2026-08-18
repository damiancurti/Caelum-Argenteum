// Un unico actor de arma delega en el modelo equipado. Asi los futuros tipos
// no multiplican estados Ready/Select/Fire ni rompen los slots nativos.
class CaelumEquippedWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 1;
        Weapon.SlotNumber 1;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    action void A_CaelumPrimaryAttack()
    {
        // En estados de arma, invoker identifica el arma y evita que GZDoom
        // confunda el self del psprite con el actor propietario.
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformEquippedWeaponPrimaryAttack();
        }
    }

    action void A_CaelumSecondaryHand()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformEquippedSecondaryHandAction();
        }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady;
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Select:
        TNT1 A 1 A_Raise;
        Loop;
    Fire:
        TNT1 A 0 A_CaelumPrimaryAttack;
        TNT1 A 1;
        Goto Ready;
    AltFire:
        TNT1 A 0 A_CaelumSecondaryHand;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

// Selectores invisibles para los botones numericos de familia. No representan
// copias adicionales: activan el registro equipado correspondiente del jugador.
class CaelumSwordWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 300;
        Weapon.SlotNumber 3;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    action void A_CaelumActivateFamily()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ActivateEquippedWeaponFamily(
                CaelumConstants.CATALOGUE_FAMILY_ONE_HANDED
            );
        }
    }

    action void A_CaelumFamilyPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilyPrimaryAttack(
                CaelumConstants.CATALOGUE_FAMILY_ONE_HANDED
            );
        }
    }

    action void A_CaelumFamilySecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilySecondaryAction(
                CaelumConstants.CATALOGUE_FAMILY_ONE_HANDED
            );
        }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady;
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Select:
        TNT1 A 0 A_CaelumActivateFamily;
        TNT1 A 1 A_Raise;
        Loop;
    Fire:
        TNT1 A 0 A_CaelumFamilyPrimary;
        TNT1 A 1;
        Goto Ready;
    AltFire:
        TNT1 A 0 A_CaelumFamilySecondary;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumLightWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 200;
        Weapon.SlotNumber 2;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    action void A_CaelumActivateFamily()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ActivateEquippedWeaponFamily(
                CaelumConstants.CATALOGUE_FAMILY_SMALL
            );
        }
    }

    action void A_CaelumFamilyPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilyPrimaryAttack(
                CaelumConstants.CATALOGUE_FAMILY_SMALL
            );
        }
    }

    action void A_CaelumFamilySecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilySecondaryAction(
                CaelumConstants.CATALOGUE_FAMILY_SMALL
            );
        }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady;
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Select:
        TNT1 A 0 A_CaelumActivateFamily;
        TNT1 A 1 A_Raise;
        Loop;
    Fire:
        TNT1 A 0 A_CaelumFamilyPrimary;
        TNT1 A 1;
        Goto Ready;
    AltFire:
        TNT1 A 0 A_CaelumFamilySecondary;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumLargeWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 400;
        Weapon.SlotNumber 4;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    action void A_CaelumActivateFamily()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ActivateEquippedWeaponFamily(
                CaelumConstants.CATALOGUE_FAMILY_LARGE
            );
        }
    }

    action void A_CaelumFamilyPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilyPrimaryAttack(
                CaelumConstants.CATALOGUE_FAMILY_LARGE
            );
        }
    }

    action void A_CaelumFamilySecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilySecondaryAction(
                CaelumConstants.CATALOGUE_FAMILY_LARGE
            );
        }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady;
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Select:
        TNT1 A 0 A_CaelumActivateFamily;
        TNT1 A 1 A_Raise;
        Loop;
    Fire:
        TNT1 A 0 A_CaelumFamilyPrimary;
        TNT1 A 1;
        Goto Ready;
    AltFire:
        TNT1 A 0 A_CaelumFamilySecondary;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumCarbineWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 500;
        Weapon.SlotNumber 5;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    action void A_CaelumActivateFamily()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ActivateEquippedWeaponFamily(
                CaelumConstants.CATALOGUE_FAMILY_RANGED
            );
        }
    }

    action void A_CaelumFamilyPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilyPrimaryAttack(
                CaelumConstants.CATALOGUE_FAMILY_RANGED
            );
        }
    }

    action void A_CaelumFamilySecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformFamilySecondaryAction(
                CaelumConstants.CATALOGUE_FAMILY_RANGED
            );
        }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady;
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Select:
        TNT1 A 0 A_CaelumActivateFamily;
        TNT1 A 1 A_Raise;
        Loop;
    Fire:
        TNT1 A 0 A_CaelumFamilyPrimary;
        TNT1 A 1;
        Goto Ready;
    AltFire:
        TNT1 A 0 A_CaelumFamilySecondary;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

// Las cuatro armas de esencia comparten la familia numerica 6, pero cada una
// necesita su propio selector nativo para que repetir la tecla 6 las recorra.
class CaelumMagicSelectorWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 600;
        Weapon.SlotNumber 6;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    virtual int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    action void A_CaelumActivateWeapon()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ActivateEquippedWeaponType(
                invoker.GetCaelumWeaponType()
            );
        }
    }

    action void A_CaelumWeaponPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilyPrimaryAttack(
                invoker.GetCaelumWeaponType()
            );
        }
    }

    action void A_CaelumWeaponSecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilySecondaryAction(
                invoker.GetCaelumWeaponType()
            );
        }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady;
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Select:
        TNT1 A 0 A_CaelumActivateWeapon;
        TNT1 A 1 A_Raise;
        Loop;
    Fire:
        TNT1 A 0 A_CaelumWeaponPrimary;
        TNT1 A 1;
        Goto Ready;
    AltFire:
        TNT1 A 0 A_CaelumWeaponSecondary;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumStaffWeapon : CaelumMagicSelectorWeapon
{
    Default { Weapon.SelectionOrder 603; }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }
}

class CaelumBellWeapon : CaelumMagicSelectorWeapon
{
    Default { Weapon.SelectionOrder 602; }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }
}

class CaelumBookWeapon : CaelumMagicSelectorWeapon
{
    Default { Weapon.SelectionOrder 601; }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }
}

class CaelumStatuetteWeapon : CaelumMagicSelectorWeapon
{
    Default { Weapon.SelectionOrder 600; }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }
}

// El proyectil conserva dano, critico y empuje al salir del canon. En actores
// Caelum registra la region exacta del impacto antes de entrar a la armadura.
class CaelumCarbineProjectile : CaelumActorProjectile
{
    Default
    {
        Radius 2;
        Height 2;
        Speed 80;
        Damage 1;
        DamageType "CaelumRangedTest";
        Projectile;
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        int preparedDamage = GetCaelumPreparedDamage(
            int(CaelumConstants.CARBINE_TIER_ONE_DAMAGE)
        );
        CaelumCombatActor combatTarget = CaelumCombatActor(victim);
        if (combatTarget == null) { return preparedDamage; }

        double heightRatio = victim.Height > 0.0
            ? Clamp((Pos.Z - victim.Pos.Z) / victim.Height, 0.0, 1.0)
            : 0.60;
        int vulnerabilityGrade = combatTarget.RegisterAnatomyImpact(
            heightRatio,
            0.50
        );
        combatTarget.RegisterPendingCriticalHit(CaelumCriticalHit);
        double multiplier = combatTarget.GetActorVulnerabilityMultiplier(
            vulnerabilityGrade
        );
        if (CaelumCriticalHit) { multiplier *= multiplier + 1.0; }
        return Max(1, int(preparedDamage * multiplier + 0.5));
    }

    States
    {
    Spawn:
        PUFF A 24 Bright;
        Stop;
    Death:
        PUFF BCD 2 Bright;
        Stop;
    }
}

class CaelumPlayerMagicProjectile : CaelumActorProjectile
{
    Default
    {
        Radius 4;
        Height 4;
        // Velocidad normal estandarizada: referencia del cohete de Doom.
        Speed 20;
        Damage 1;
        DamageType "CaelumMagicTest";
        Projectile;
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        int preparedDamage = GetCaelumPreparedDamage(1);
        CaelumCombatActor combatTarget = CaelumCombatActor(victim);
        if (combatTarget == null) { return preparedDamage; }
        double heightRatio = victim.Height > 0.0
            ? Clamp((Pos.Z - victim.Pos.Z) / victim.Height, 0.0, 1.0)
            : 0.60;
        int vulnerabilityGrade = combatTarget.RegisterAnatomyImpact(
            heightRatio, 0.50
        );
        combatTarget.RegisterPendingCriticalHit(CaelumCriticalHit);
        double multiplier = combatTarget.GetActorVulnerabilityMultiplier(
            vulnerabilityGrade
        );
        if (CaelumCriticalHit) { multiplier *= multiplier + 1.0; }
        return Max(1, int(preparedDamage * multiplier + 0.5));
    }

    States
    {
    Spawn:
        PUFF A 1 Bright;
        Loop;
    Death:
        PUFF BCD 2 Bright;
        Stop;
    }
}

class CaelumHomingMagicProjectile : CaelumPlayerMagicProjectile
{
    Vector3 CaelumSeekOrigin;
    double CaelumSeekRange;
    double CaelumSeekAimAngle;
    double CaelumSeekAimPitch;
    double CaelumSeekHalfAngle;
    int CaelumSeekRetryTics;

    Default
    {
        +SEEKERMISSILE
        +INTERPOLATEANGLES
    }

    void ConfigureCaelumSeeking(
        double seekRange,
        double aimAngle,
        double aimPitch,
        double halfAngle
    )
    {
        CaelumSeekOrigin = Pos;
        CaelumSeekRange = Max(1.0, seekRange);
        CaelumSeekAimAngle = aimAngle;
        CaelumSeekAimPitch = aimPitch;
        CaelumSeekHalfAngle = Max(0.1, halfAngle);
        CaelumSeekRetryTics = 0;
        Tracer = FindBestCaelumSeekTarget();
    }

    bool IsCaelumSeekCandidate(Actor candidate, bool requireAimCone)
    {
        if (candidate == null
            || candidate == Target
            || candidate.health <= 0
            || !candidate.bShootable)
        {
            return false;
        }

        // Solo se adquieren combatientes y el muneco construido para pruebas;
        // decoraciones destructibles no deben atraer los hechizos del libro.
        bool isCombatTarget = candidate.bMonster
            || candidate.player != null
            || CaelumTrainingDummy(candidate) != null;
        if (!isCombatTarget) { return false; }
        if (Target != null && candidate.IsFriend(Target)) { return false; }

        Vector3 candidateCenter = candidate.Pos
            + (0.0, 0.0, candidate.Height * 0.5);
        Vector3 offset = candidateCenter - CaelumSeekOrigin;
        if (offset.Length() > CaelumSeekRange) { return false; }
        if (!CheckSight(candidate)) { return false; }
        if (!requireAimCone) { return true; }

        Vector2 horizontalOffset = (offset.X, offset.Y);
        double targetAngle = VectorAngle(offset.X, offset.Y);
        double targetPitch = -ATan2(
            offset.Z,
            Max(0.001, horizontalOffset.Length())
        );
        double yawDifference = Abs(DeltaAngle(
            CaelumSeekAimAngle,
            targetAngle
        ));
        double pitchDifference = Abs(DeltaAngle(
            CaelumSeekAimPitch,
            targetPitch
        ));
        return yawDifference <= CaelumSeekHalfAngle
            && pitchDifference <= CaelumSeekHalfAngle;
    }

    Actor FindBestCaelumSeekTarget()
    {
        Actor bestTarget;
        double bestAngularScore = double.max;
        double bestDistance = double.max;
        ThinkerIterator iterator = ThinkerIterator.Create("Actor");
        Thinker entry;

        while ((entry = iterator.Next()) != null)
        {
            Actor candidate = Actor(entry);
            if (!IsCaelumSeekCandidate(candidate, true)) { continue; }

            Vector3 candidateCenter = candidate.Pos
                + (0.0, 0.0, candidate.Height * 0.5);
            Vector3 offset = candidateCenter - CaelumSeekOrigin;
            Vector2 horizontalOffset = (offset.X, offset.Y);
            double targetAngle = VectorAngle(offset.X, offset.Y);
            double targetPitch = -ATan2(
                offset.Z,
                Max(0.001, horizontalOffset.Length())
            );
            double yawDifference = Abs(DeltaAngle(
                CaelumSeekAimAngle,
                targetAngle
            ));
            double pitchDifference = Abs(DeltaAngle(
                CaelumSeekAimPitch,
                targetPitch
            ));
            double angularScore = yawDifference * yawDifference
                + pitchDifference * pitchDifference;
            double distance = offset.Length();

            // La prioridad es la cercania a la mira; la distancia solo
            // desempata objetivos con practicamente el mismo angulo.
            if (angularScore < bestAngularScore
                || (Abs(angularScore - bestAngularScore) < 0.0001
                    && distance < bestDistance))
            {
                bestTarget = candidate;
                bestAngularScore = angularScore;
                bestDistance = distance;
            }
        }
        return bestTarget;
    }

    action void A_UpdateCaelumSeeking()
    {
        // Las acciones de estado resuelven los campos propios desde invoker
        // para evitar el self ambiguo de GZDoom 4.14.2.
        if (!invoker.IsCaelumSeekCandidate(invoker.Tracer, false))
        {
            invoker.Tracer = null;
            if (invoker.CaelumSeekRetryTics <= 0)
            {
                invoker.Tracer = invoker.FindBestCaelumSeekTarget();
                invoker.CaelumSeekRetryTics = 3;
            }
            else
            {
                invoker.CaelumSeekRetryTics--;
            }
        }
        else
        {
            invoker.CaelumSeekRetryTics = 0;
        }

        if (invoker.Tracer != null)
        {
            // Valores equivalentes al giro base del proyectil del Revenant.
            invoker.A_SeekerMissile(10, 30);
        }
    }

    States
    {
    Spawn:
        PUFF A 1 Bright A_UpdateCaelumSeeking;
        Loop;
    }
}

class CaelumExplosiveMagicProjectile : CaelumPlayerMagicProjectile
{
    int CaelumExplosionDamage;
    double CaelumExplosionRadius;

    void ConfigureCaelumExplosion(int damage, double radius)
    {
        CaelumExplosionDamage = Max(0, damage);
        CaelumExplosionRadius = Max(1.0, radius);
    }

    action void A_CaelumExplode()
    {
        // En una accion de estado, GZDoom 4.14.2 necesita que los campos
        // propios del proyectil se resuelvan explicitamente desde invoker.
        invoker.A_Explode(
            invoker.CaelumExplosionDamage,
            invoker.CaelumExplosionRadius,
            0,
            false
        );
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        return Max(1, int(
            Super.DoSpecialDamage(victim, damage, damageType)
                * CaelumConstants.ESSENCE_EXPLOSIVE_DIRECT_DAMAGE_RATIO + 0.5
        ));
    }

    States
    {
    Spawn:
        PUFF A 1 Bright;
        Loop;
    Death:
        TNT1 A 0 A_CaelumExplode;
        PUFF BCD 2 Bright;
        Stop;
    }
}
