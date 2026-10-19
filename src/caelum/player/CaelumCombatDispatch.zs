// #310: coordina solicitudes sobre el receptor explícito, sin estado propio.
// El jugador conserva temporizadores, commits y datos serializados.
class CaelumCombatDispatch : Object play
{
    static void PerformEquippedWeaponPrimaryAttack(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if(CaelumBattleCry.Active(user))return;
        if(CaelumClassCastView.Active(user))return;
        if(user.WeaponModel!=null && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_BOLAS)
        {CaelumBolas.Throw(user);return;}
        if(user.WeaponModel!=null && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_UTILITY_STAFF)
        {CaelumUtilityStaff.Request(user,CaelumUtilityStaffRules.FIRE);return;}
        user.RefreshWeaponAttackClock();
        if (user.WeaponModel == null || !user.WeaponModel.Equipped
            || user.WeaponModel.Durability <= 0
            || user.EquipmentMenuOpen || user.CreationWizardOpen
            || user.EquippedWeaponCooldownRemaining > 0.0
            || user.IsPhysicallyImmobilized())
        {
            return;
        }

        if (user.WeaponChargeActive) { return; }

        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                user.WeaponModel.WeaponType
            );

        // Fire rompe Block y continúa con el ataque en la misma pulsación.
        if (user.CombatBlockModeActive)
        {
            user.CancelCombatBlockMode();
        }

        if (catalogueWeapon >= 0
            && CaelumWeaponCatalogue.GetFamily(catalogueWeapon)
                == CaelumConstants.CATALOGUE_FAMILY_RANGED)
        {
            user.BeginPhysicalAttackCycle(false);
            return;
        }
        switch (user.WeaponModel.WeaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
            case CaelumConstants.WEAPON_TYPE_BELL:
            case CaelumConstants.WEAPON_TYPE_BOOK:
            case CaelumConstants.WEAPON_TYPE_STATUETTE:
                user.PerformDebugStaffAttack(false);
                break;
            default:
                user.BeginPhysicalAttackCycle(false);
                break;
        }
    }

    static void PerformLargeWeaponSweep(CaelumPlayer user, int weaponType)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        user.RefreshWeaponAttackClock();
        if (!user.SupportsLargeWeaponSweep(weaponType)
            || user.EquipmentMenuOpen || user.CreationWizardOpen || user.CraftingMenuOpen
            || user.CombatChannelModeActive || user.StaffCastPending || user.WeaponChargeActive
            || user.EquippedWeaponCooldownRemaining > 0.0
            || user.IsPhysicallyImmobilized()
            || !user.ActivateEquippedWeaponType(weaponType)
            || user.WeaponModel == null || !user.WeaponModel.Equipped
            || user.WeaponModel.Durability <= 0) return;
        user.CancelCombatBlockMode();
        user.BeginPhysicalAttackCycle(false,true);
    }

    static void PerformEquippedWeaponSecondaryAttack(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user)) return;
        if(CaelumBattleCry.Active(user))return;
        if(CaelumClassCastView.Active(user))return;
        if(user.WeaponModel!=null && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_BOLAS)return;
        if(user.WeaponModel!=null && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_UTILITY_STAFF)
        {CaelumUtilityStaff.Request(user,CaelumUtilityStaffRules.ICE);return;}
        user.RefreshWeaponAttackClock();
        if (user.WeaponModel == null || !user.WeaponModel.Equipped
            || user.WeaponModel.Durability <= 0
            || user.EquipmentMenuOpen || user.CreationWizardOpen
            || user.IsPhysicallyImmobilized()
            || user.StaffCastPending)
        {
            return;
        }

        if (user.WeaponChargeActive) { return; }

        int catalogueWeapon =
            CaelumCraftingRules.GetCatalogueWeaponForPlayableType(
                user.WeaponModel.WeaponType
            );

        if (user.IsRangedWeaponType(user.WeaponModel.WeaponType))
        {
            // AltFire, igual que Zoom, alterna ADS una sola vez por pulsación.
            // El bloqueo es propio de esta tecla y no afecta ataques secundarios.
            if (user.RangedAimSecondaryLatched) { return; }
            user.RangedAimSecondaryLatched = true;
            user.ToggleRangedAim(user.WeaponModel.WeaponType);
            return;
        }

        if (user.CombatBlockModeActive)
        {
            user.CancelCombatBlockMode();
        }

        if (catalogueWeapon == CaelumConstants.CATALOGUE_WEAPON_JAVELIN)
        {
            if (user.JavelinSecondaryLatched) { return; }
            user.JavelinSecondaryLatched = true;
        }

        if (user.EquippedWeaponCooldownRemaining > 0.0
            || user.StaffCastCooldownRemaining > 0.0)
        {
            return;
        }

        if (user.WeaponModel.IsMagicalType(user.WeaponModel.WeaponType))
        {
            user.PerformDebugStaffAttack(true);
            return;
        }

        if (catalogueWeapon == CaelumConstants.CATALOGUE_WEAPON_JAVELIN
            && !user.HasJavelinMeleeFallbackTarget())
        {
            user.BeginPhysicalAttackCycle(true);
            return;
        }

        if (catalogueWeapon >= 0
            && CaelumWeaponCatalogue.GetSecondaryDamage(catalogueWeapon) > 0.0)
        {
            user.BeginPhysicalAttackCycle(true);
        }
    }

}
