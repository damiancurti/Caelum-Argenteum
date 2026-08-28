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
            caelumPlayer.PerformEquippedWeaponSecondaryAttack();
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

// Cada arma fisica posee su propio selector nativo invisible. Compartir el
// SlotNumber hace que GZDoom recorra las armas equipadas de una familia al
// repetir su tecla, sin duplicar los objetos reales guardados en Actor.Inv.
class CaelumPhysicalSelectorWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 200;
        Weapon.SlotNumber 2;
        Weapon.KickBack 0;
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    virtual int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_DAGGER;
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

            // Las armas a distancia conservan AltFire como acceso alternativo
            // a Aim, pero ahora el estado tambien modifica el FOV real.
            if (caelumPlayer.IsRangedWeaponType(invoker.GetCaelumWeaponType()))
            {
                A_ZoomFactor(
                    caelumPlayer.RangedAimModeActive ? 2.0 : 1.0
                );
            }
        }
    }

    action void A_CaelumContextZoomInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer == null) { return; }
        if (caelumPlayer.CombatZoomInputLatched) { return; }
        caelumPlayer.CombatZoomInputLatched = true;

        // Zoom es contextual: ADS para distancia y Block para armas que
        // realmente pueden compartir la mano secundaria con un escudo.
        if (caelumPlayer.IsRangedWeaponType(invoker.GetCaelumWeaponType()))
        {
            caelumPlayer.ToggleRangedAim(invoker.GetCaelumWeaponType());
            A_ZoomFactor(
                caelumPlayer.RangedAimModeActive ? 2.0 : 1.0
            );
            return;
        }

        A_ZoomFactor(1.0);
        caelumPlayer.ToggleCombatBlockMode();
    }

    action void A_CaelumReloadInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.RequestWeaponReloadOrCharge(
                invoker.GetCaelumWeaponType(), false
            );
            A_ZoomFactor(1.0);
        }
    }

    action void A_CaelumRacialAbilityInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ReserveRacialAbilityInput();
        }
    }

    action void A_CaelumChannelInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null) { caelumPlayer.RequestCombatChannelInput(); }
    }

    action void A_CaelumTarotInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null) { caelumPlayer.ReserveTarotInput(); }
    }

    action void A_CaelumClassAbilityInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null) { caelumPlayer.ReserveClassAbilityInput(); }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady(
            WRF_ALLOWZOOM
            | WRF_ALLOWRELOAD
            | WRF_ALLOWUSER1
            | WRF_ALLOWUSER2
            | WRF_ALLOWUSER3
            | WRF_ALLOWUSER4
        );
        Loop;
    Deselect:
        TNT1 A 1 A_Lower;
        Loop;
    Select:
        TNT1 A 0 A_ZoomFactor(1.0, 1);
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
    Zoom:
        TNT1 A 0 A_CaelumContextZoomInput;
        TNT1 A 1;
        Goto Ready;
    Reload:
        TNT1 A 0 A_CaelumReloadInput;
        TNT1 A 1;
        Goto Ready;
    User1:
        TNT1 A 0 A_CaelumRacialAbilityInput;
        TNT1 A 1;
        Goto Ready;
    User2:
        TNT1 A 0 A_CaelumChannelInput;
        TNT1 A 1;
        Goto Ready;
    User3:
        TNT1 A 0 A_CaelumTarotInput;
        TNT1 A 1;
        Goto Ready;
    User4:
        TNT1 A 0 A_CaelumClassAbilityInput;
        TNT1 A 1;
        Goto Ready;
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumDaggerSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 203; Weapon.SlotNumber 2; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_DAGGER; }
}

class CaelumHatchetSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 202; Weapon.SlotNumber 2; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_HATCHET; }
}

class CaelumMacheteSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 201; Weapon.SlotNumber 2; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_MACHETE; }
}

class CaelumJavelinSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 200; Weapon.SlotNumber 2; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_JAVELIN; }
}

class CaelumSwordSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 303; Weapon.SlotNumber 3; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_SWORD; }
}

class CaelumAxeSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 302; Weapon.SlotNumber 3; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_AXE; }
}

class CaelumFlailSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 301; Weapon.SlotNumber 3; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_FLAIL; }
}

class CaelumSpearSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 300; Weapon.SlotNumber 3; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_SPEAR; }
}

class CaelumGreatswordSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 403; Weapon.SlotNumber 4; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_GREATSWORD; }
}

class CaelumWarAxeSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 402; Weapon.SlotNumber 4; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_WAR_AXE; }
}

class CaelumHalberdSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 401; Weapon.SlotNumber 4; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_HALBERD; }
}

class CaelumGiantGauntletsSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 400; Weapon.SlotNumber 4; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS; }
}

class CaelumStandardBowSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 503; Weapon.SlotNumber 5; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_STANDARD_BOW; }
}

class CaelumCarbineSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 502; Weapon.SlotNumber 5; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_CARBINE; }
}

class CaelumLongbowSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 501; Weapon.SlotNumber 5; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_LONGBOW; }
}

class CaelumCrossbowSelectorWeapon : CaelumPhysicalSelectorWeapon
{
    Default { Weapon.SelectionOrder 500; Weapon.SlotNumber 5; }
    override int GetCaelumWeaponType() { return CaelumConstants.WEAPON_TYPE_CROSSBOW; }
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

    virtual int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    virtual int GetCaelumTier()
    {
        return 1;
    }

    action void A_CaelumActivateWeapon()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ActivateEquippedMagicWeapon(
                invoker.GetCaelumWeaponType(),
                invoker.GetCaelumEssenceType(),
                invoker.GetCaelumTier()
            );
        }
    }

    action void A_CaelumWeaponPrimary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformMagicWeaponPrimaryAttack(
                invoker.GetCaelumWeaponType(),
                invoker.GetCaelumEssenceType(),
                invoker.GetCaelumTier()
            );
        }
    }

    action void A_CaelumWeaponSecondary()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.PerformMagicWeaponSecondaryAttack(
                invoker.GetCaelumWeaponType(),
                invoker.GetCaelumEssenceType(),
                invoker.GetCaelumTier()
            );
        }
    }

    action void A_CaelumBlockInputPulse()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer == null || caelumPlayer.CombatZoomInputLatched)
        {
            return;
        }
        caelumPlayer.CombatZoomInputLatched = true;
        caelumPlayer.ToggleCombatBlockMode();
    }

    action void A_CaelumReloadInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.RequestWeaponReloadOrCharge(
                invoker.GetCaelumWeaponType(), true
            );
        }
    }

    action void A_CaelumRacialAbilityInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null)
        {
            caelumPlayer.ReserveRacialAbilityInput();
        }
    }

    action void A_CaelumChannelInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null) { caelumPlayer.RequestCombatChannelInput(); }
    }

    action void A_CaelumTarotInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null) { caelumPlayer.ReserveTarotInput(); }
    }

    action void A_CaelumClassAbilityInput()
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(invoker.Owner);
        if (caelumPlayer != null) { caelumPlayer.ReserveClassAbilityInput(); }
    }

    States
    {
    Ready:
        TNT1 A 1 A_WeaponReady(
            WRF_ALLOWZOOM
            | WRF_ALLOWRELOAD
            | WRF_ALLOWUSER1
            | WRF_ALLOWUSER2
            | WRF_ALLOWUSER3
            | WRF_ALLOWUSER4
        );
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
    Zoom:
        TNT1 A 0 A_CaelumBlockInputPulse;
        TNT1 A 1;
        Goto Ready;
    Reload:
        TNT1 A 0 A_CaelumReloadInput;
        TNT1 A 1;
        Goto Ready;
    User1:
        TNT1 A 0 A_CaelumRacialAbilityInput;
        TNT1 A 1;
        Goto Ready;
    User2:
        TNT1 A 0 A_CaelumChannelInput;
        TNT1 A 1;
        Goto Ready;
    User3:
        TNT1 A 0 A_CaelumTarotInput;
        TNT1 A 1;
        Goto Ready;
    User4:
        TNT1 A 0 A_CaelumClassAbilityInput;
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

// V4.24.2a: cada selector mágico identifica elemento + implemento + tier.
// Slots: 6 Fuego, 7 Agua, 8 Tierra, 9 Aire, 0 Quintaesencia.
// Cada slot recorre únicamente las variantes realmente equipadas.

class CaelumFireStaffT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 643;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumFireStaffT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 642;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumFireStaffT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 641;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumFireBellT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 633;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumFireBellT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 632;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumFireBellT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 631;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumFireBookT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 623;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumFireBookT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 622;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumFireBookT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 621;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumFireStatuetteT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 613;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumFireStatuetteT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 612;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumFireStatuetteT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 611;
        Weapon.SlotNumber 6;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_FIRE;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumWaterStaffT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 643;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumWaterStaffT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 642;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumWaterStaffT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 641;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumWaterBellT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 633;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumWaterBellT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 632;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumWaterBellT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 631;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumWaterBookT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 623;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumWaterBookT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 622;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumWaterBookT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 621;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumWaterStatuetteT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 613;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumWaterStatuetteT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 612;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumWaterStatuetteT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 611;
        Weapon.SlotNumber 7;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WATER;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumEarthStaffT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 643;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumEarthStaffT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 642;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumEarthStaffT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 641;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumEarthBellT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 633;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumEarthBellT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 632;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumEarthBellT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 631;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumEarthBookT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 623;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumEarthBookT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 622;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumEarthBookT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 621;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumEarthStatuetteT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 613;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumEarthStatuetteT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 612;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumEarthStatuetteT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 611;
        Weapon.SlotNumber 8;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_EARTH;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumAirStaffT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 643;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumAirStaffT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 642;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumAirStaffT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 641;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumAirBellT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 633;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumAirBellT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 632;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumAirBellT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 631;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumAirBookT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 623;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumAirBookT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 622;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumAirBookT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 621;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumAirStatuetteT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 613;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumAirStatuetteT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 612;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumAirStatuetteT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 611;
        Weapon.SlotNumber 9;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_WIND;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumQuintessenceStaffT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 643;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumQuintessenceStaffT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 642;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumQuintessenceStaffT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 641;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STAFF;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumQuintessenceBellT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 633;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumQuintessenceBellT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 632;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumQuintessenceBellT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 631;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BELL;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumQuintessenceBookT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 623;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumQuintessenceBookT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 622;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumQuintessenceBookT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 621;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_BOOK;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 3;
    }
}

class CaelumQuintessenceStatuetteT1Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 613;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 1;
    }
}

class CaelumQuintessenceStatuetteT2Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 612;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 2;
    }
}

class CaelumQuintessenceStatuetteT3Weapon : CaelumMagicSelectorWeapon
{
    Default
    {
        Weapon.SelectionOrder 611;
        Weapon.SlotNumber 0;
    }

    override int GetCaelumWeaponType()
    {
        return CaelumConstants.WEAPON_TYPE_STATUETTE;
    }

    override int GetCaelumEssenceType()
    {
        return CaelumConstants.ESSENCE_QUINTESSENCE;
    }

    override int GetCaelumTier()
    {
        return 3;
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
        CaelumPlayer weaponOwner = CaelumPlayer(Target);
        if (weaponOwner != null && CaelumWeaponWearPrepared)
        {
            weaponOwner.ApplyWeaponDurabilityFromSuccessfulDamage(
                preparedDamage,
                CaelumWearWeaponType,
                CaelumWearWeaponTier,
                CaelumWearWeaponSize
            );
        }
        CaelumCombatActor combatTarget = CaelumCombatActor(victim);
        if (combatTarget == null) { return preparedDamage; }

        double heightRatio = victim.Height > 0.0
            ? Clamp((Pos.Z - victim.Pos.Z) / victim.Height, 0.0, 1.0)
            : 0.60;
        int vulnerabilityGrade =
            combatTarget.RegisterDirectionalAnatomyImpact(self, heightRatio);
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

class CaelumArrowProjectile : CaelumCarbineProjectile
{
    Default
    {
        Scale 0.20;
        Speed 35;
    }

    States
    {
    Spawn:
        ARRO A 1;
        Loop;
    Death:
        PUFF BCD 2 Bright;
        Stop;
    }
}

class CaelumBoltProjectile : CaelumCarbineProjectile
{
    Default
    {
        Scale 0.20;
        Speed 45;
    }

    States
    {
    Spawn:
        BOLT A 1;
        Loop;
    Death:
        PUFF BCD 2 Bright;
        Stop;
    }
}

// El proyectil lento conserva daño, crítico y empuje. La jabalina se considera
// rota al finalizar su trayectoria y deja materiales calculados con la misma
// receta y recuperación de desensamblaje que ya usa el sistema de crafteo.
class CaelumJavelinProjectile : CaelumCarbineProjectile
{
    int JavelinTier;
    int JavelinSize;
    int JavelinBasicMaterialDropAmount;
    int JavelinTierMaterialDropAmount;
    bool JavelinBreakageConfigured;

    Default
    {
        Speed 15;
        Scale 0.25;
        DamageType "CaelumRangedTest";
        -NOGRAVITY
    }

    void StoreJavelinBreakageConfiguration(
        int tier,
        int equipmentSize,
        int basicMaterialDropAmount,
        int tierMaterialDropAmount
    )
    {
        JavelinTier = Clamp(tier, 1, 3);
        JavelinSize = Clamp(
            equipmentSize,
            CaelumConstants.EQUIPMENT_SIZE_XS,
            CaelumConstants.EQUIPMENT_SIZE_XL
        );
        JavelinBasicMaterialDropAmount = Max(0, basicMaterialDropAmount);
        JavelinTierMaterialDropAmount = Max(0, tierMaterialDropAmount);
        JavelinBreakageConfigured = true;
    }

    void SpawnBrokenMaterial(
        int materialType,
        int materialTier,
        int materialAmount,
        double lateralOffset
    )
    {
        if (materialAmount <= 0) { return; }

        Vector3 dropPos = Pos + (
            Cos(Angle + 90.0) * lateralOffset,
            Sin(Angle + 90.0) * lateralOffset,
            0.0
        );
        CaelumMaterialPickup material = CaelumMaterialPickup(
            Spawn("CaelumMaterialPickup", dropPos, NO_REPLACE)
        );
        if (material == null) { return; }

        material.args[0] = materialType;
        material.args[1] = materialTier;
        material.Amount = materialAmount;
        material.InMagicBox = false;
    }

    void DropBrokenJavelinMaterials()
    {
        if (!JavelinBreakageConfigured) { return; }

        int weaponId = CaelumConstants.CATALOGUE_WEAPON_JAVELIN;
        int basicType = CaelumCraftingRules.GetBasicMaterial(weaponId);
        int tierType = CaelumCraftingRules.GetTierMaterial(weaponId);
        int basicTier = CaelumMaterialRules.ResolveTier(basicType, 1);
        int tierTier = CaelumMaterialRules.ResolveTier(tierType, JavelinTier);

        // El jugador ya calculó cuánto corresponde exactamente a este punto
        // de durabilidad. Al sumar todos los lanzamientos desde durabilidad
        // máxima hasta cero, la recuperación total converge exactamente a la
        // mitad de los materiales de la receta.
        SpawnBrokenMaterial(
            basicType, basicTier, JavelinBasicMaterialDropAmount, -6.0
        );
        SpawnBrokenMaterial(
            tierType, tierTier, JavelinTierMaterialDropAmount, 6.0
        );
        JavelinBreakageConfigured = false;
    }

    States
    {
    Spawn:
        // JAVL dispone de A1-A8; GZDoom elige automáticamente la vista según
        // el ángulo relativo entre cámara y proyectil.
        JAVL A 1 Bright;
        Loop;
    Death:
        TNT1 A 0 DropBrokenJavelinMaterials();
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

    void UpdateCaelumElementalWorldSprite()
    {
        if (!CaelumElementalPayloadPrepared) { return; }

        // Cada esencia usa un juego rotacional de ocho vistas. El ataque
        // secundario cambia únicamente el arte elemental; la lógica de daño
        // y estados sigue usando CaelumEssenceType + CaelumSecondaryElement.
        String visual = "XFIR";
        if (CaelumEssenceType == CaelumConstants.ESSENCE_FIRE)
        {
            visual = CaelumSecondaryElement ? "XLIT" : "XFIR";
        }
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_WATER)
        {
            visual = CaelumSecondaryElement ? "XICE" : "XWAT";
        }
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_EARTH)
        {
            visual = CaelumSecondaryElement ? "XVSN" : "XERT";
        }
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_WIND)
        {
            visual = CaelumSecondaryElement ? "XRAY" : "XAIR";
        }
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_QUINTESSENCE)
        {
            visual = "XQUI";
        }
        sprite = GetSpriteIndex(visual);
        frame = 0;
    }

    override void Tick()
    {
        Super.Tick();
        UpdateCaelumElementalWorldSprite();
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        int preparedDamage = GetCaelumPreparedDamage(1);
        CaelumPlayer weaponOwner = CaelumPlayer(Target);
        if (weaponOwner != null && CaelumWeaponWearPrepared)
        {
            weaponOwner.ApplyWeaponDurabilityFromSuccessfulDamage(
                preparedDamage,
                CaelumWearWeaponType,
                CaelumWearWeaponTier,
                CaelumWearWeaponSize
            );
        }
        CaelumCombatActor combatTarget = CaelumCombatActor(victim);
        if (combatTarget == null) { return preparedDamage; }
        double heightRatio = victim.Height > 0.0
            ? Clamp((Pos.Z - victim.Pos.Z) / victim.Height, 0.0, 1.0)
            : 0.60;
        int vulnerabilityGrade =
            combatTarget.RegisterDirectionalAnatomyImpact(self, heightRatio);
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
        XFIR A 1 Bright;
        Loop;
    Death:
        XFIR A 2 Bright;
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
        bool isCombatTarget = candidate.bCountKill
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
        XFIR A 1 Bright A_UpdateCaelumSeeking;
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
        XFIR A 1 Bright;
        Loop;
    Death:
        XFIR A 0 A_CaelumExplode;
        XFIR A 2 Bright;
        Stop;
    }
}

// GZDoom 4.14.2 no expone Radius/Height ni SetSize para cambios dinámicos
// desde ZScript. Estas variantes fijan la geometría cargada en Default.
// 4 * sqrt(2) duplica el área transversal respecto del proyectil normal.
class CaelumChargedPlayerMagicProjectile : CaelumPlayerMagicProjectile
{
    Default
    {
        Radius 5.6568542495;
        Height 5.6568542495;
        Scale 1.4142135624;
    }
}

class CaelumChargedHomingMagicProjectile : CaelumHomingMagicProjectile
{
    Default
    {
        Radius 5.6568542495;
        Height 5.6568542495;
        Scale 1.4142135624;
    }
}

class CaelumChargedExplosiveMagicProjectile
    : CaelumExplosiveMagicProjectile
{
    Default
    {
        Radius 5.6568542495;
        Height 5.6568542495;
        Scale 1.4142135624;
    }
}
