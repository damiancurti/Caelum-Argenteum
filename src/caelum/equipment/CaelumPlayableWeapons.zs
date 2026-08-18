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
    Default
    {
        +SEEKERMISSILE
        +INTERPOLATEANGLES
    }

    States
    {
    Spawn:
        PUFF A 1 Bright A_SeekerMissile(10, 30);
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
