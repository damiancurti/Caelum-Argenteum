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
            caelumPlayer.ActivateEquippedWeaponType(
                CaelumConstants.WEAPON_TYPE_SWORD
            );
        }
    }

    action void A_CaelumFamilyPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilyPrimaryAttack(
                CaelumConstants.WEAPON_TYPE_SWORD
            );
        }
    }

    action void A_CaelumFamilySecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilySecondaryAction(
                CaelumConstants.WEAPON_TYPE_SWORD
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
            caelumPlayer.ActivateEquippedWeaponType(
                CaelumConstants.WEAPON_TYPE_CARBINE
            );
        }
    }

    action void A_CaelumFamilyPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilyPrimaryAttack(
                CaelumConstants.WEAPON_TYPE_CARBINE
            );
        }
    }

    action void A_CaelumFamilySecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilySecondaryAction(
                CaelumConstants.WEAPON_TYPE_CARBINE
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

class CaelumStaffWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 600;
        Weapon.SlotNumber 6;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    action void A_CaelumActivateFamily()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ActivateEquippedWeaponType(
                CaelumConstants.WEAPON_TYPE_STAFF
            );
        }
    }

    action void A_CaelumFamilyPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilyPrimaryAttack(
                CaelumConstants.WEAPON_TYPE_STAFF
            );
        }
    }

    action void A_CaelumFamilySecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformWeaponFamilySecondaryAction(
                CaelumConstants.WEAPON_TYPE_STAFF
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
