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

class CaelumCarbineAmmo : Ammo
{
    Default
    {
        Inventory.MaxAmount 999;
        Ammo.BackpackAmount 20;
        Ammo.BackpackMaxAmount 1998;
    }

    States
    {
    Spawn:
        CLIP A -1;
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
