// Ficha autoritativa de las armas físicas planificadas. Centralizar estos
// valores evita que la documentación, el crafteo y las futuras armas jugables
// terminen usando estadísticas distintas.
class CaelumWeaponCatalogue : Object
{
    static int ResolveWeapon(int weaponId)
    {
        return Clamp(
            weaponId, 0, CaelumConstants.CATALOGUE_PHYSICAL_WEAPON_COUNT - 1
        );
    }

    static String GetNameKey(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return "CA_WEAPON_CATALOGUE_DAGGER";
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return "CA_WEAPON_CATALOGUE_HATCHET";
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return "CA_WEAPON_CATALOGUE_MACHETE";
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return "CA_WEAPON_CATALOGUE_JAVELIN";
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return "CA_WEAPON_CATALOGUE_SWORD";
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return "CA_WEAPON_CATALOGUE_AXE";
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return "CA_WEAPON_CATALOGUE_FLAIL";
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return "CA_WEAPON_CATALOGUE_SPEAR";
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return "CA_WEAPON_CATALOGUE_GREATSWORD";
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return "CA_WEAPON_CATALOGUE_WAR_AXE";
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return "CA_WEAPON_CATALOGUE_HALBERD";
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return "CA_WEAPON_CATALOGUE_GIANT_GAUNTLETS";
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return "CA_WEAPON_CATALOGUE_STANDARD_BOW";
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return "CA_WEAPON_CATALOGUE_CARBINE";
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return "CA_WEAPON_CATALOGUE_LONGBOW";
            default: return "CA_WEAPON_CATALOGUE_CROSSBOW";
        }
    }

    static int GetFamily(int weaponId)
    {
        int resolved = ResolveWeapon(weaponId);
        if (resolved <= CaelumConstants.CATALOGUE_WEAPON_JAVELIN)
        {
            return CaelumConstants.CATALOGUE_FAMILY_SMALL;
        }
        if (resolved <= CaelumConstants.CATALOGUE_WEAPON_SPEAR)
        {
            return CaelumConstants.CATALOGUE_FAMILY_ONE_HANDED;
        }
        if (resolved <= CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS)
        {
            return CaelumConstants.CATALOGUE_FAMILY_LARGE;
        }
        return CaelumConstants.CATALOGUE_FAMILY_RANGED;
    }

    static bool UsesOneHandedShieldRules(int weaponId)
    {
        int family = GetFamily(weaponId);
        return family == CaelumConstants.CATALOGUE_FAMILY_SMALL
            || family == CaelumConstants.CATALOGUE_FAMILY_ONE_HANDED;
    }

    static bool CanAttackWhileBlocking(int weaponId)
    {
        return ResolveWeapon(weaponId)
            == CaelumConstants.CATALOGUE_WEAPON_SPEAR;
    }

    static double GetUnshieldedPrimaryDamageMultiplier(int weaponId)
    {
        return ResolveWeapon(weaponId)
            == CaelumConstants.CATALOGUE_WEAPON_SPEAR ? 1.10 : 1.0;
    }

    static bool SecondaryIsThrown(int weaponId)
    {
        return ResolveWeapon(weaponId)
            == CaelumConstants.CATALOGUE_WEAPON_JAVELIN;
    }

    static bool UsesAutomaticMeleeFallback(int weaponId)
    {
        // La jabalina arrojada se convierte en apuñalamiento si el objetivo
        // está suficientemente cerca al resolver el ataque secundario.
        return SecondaryIsThrown(weaponId);
    }

    static double GetPrimaryDamage(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return 60.0;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return 80.0;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return 90.0;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return 100.0;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return 120.0;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return 140.0;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return 130.0;
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return 150.0;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return 200.0;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return 220.0;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return 180.0;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return 240.0;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return 120.0;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return 360.0;
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return 180.0;
            default: return 140.0;
        }
    }

    static double GetSecondaryDamage(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return 80.0;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return 100.0;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return 110.0;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return 120.0;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return 140.0;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return 160.0;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return 180.0;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return 240.0;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return 260.0;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return 200.0;
            default: return 0.0;
        }
    }

    static int GetAttackTics(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return 8;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET:
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return 10;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return 12;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return 14;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return 16;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return 15;
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return 18;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return 22;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return 24;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return 20;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return 26;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return 20;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return 48;
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return 24;
            default: return 30;
        }
    }

    static double GetPrimaryRange(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER:
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return 48.0;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return 52.0;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return 56.0;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return 64.0;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return 60.0;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return 62.0;
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return 72.0;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return 80.0;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return 76.0;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return 84.0;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return 60.0;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return 20.0;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return 60.0;
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return 30.0;
            default: return 25.0;
        }
    }

    static double GetSecondaryRange(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER:
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return 40.0;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return 58.0;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return 72.0;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return 50.0;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return 62.0;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return 90.0;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return 64.0;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return 92.0;
            default: return 0.0;
        }
    }

    static double GetMinimumSpread(int weaponId)
    {
        return GetMaximumSpread(weaponId) * 0.10;
    }

    static double GetMaximumSpread(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return 30.0;
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW: return 50.0;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return 70.0;
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return 90.0;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET:
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE:
            case CaelumConstants.CATALOGUE_WEAPON_SWORD:
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR:
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD:
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN:
            case CaelumConstants.CATALOGUE_WEAPON_AXE:
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD:
                return 110.0;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL:
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE:
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS:
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE:
                return 130.0;
            default: return 70.0;
        }
    }

    static double GetCriticalChancePercent(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return 15.0;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET:
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE:
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD:
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return 10.0;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN:
            case CaelumConstants.CATALOGUE_WEAPON_SWORD:
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR:
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD:
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW: return 8.0;
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return 12.0;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return 0.0;
            default: return 5.0;
        }
    }

    static double GetPrimaryAirCost(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return 2.0;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET:
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE:
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return 3.0;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return 4.0;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return 5.0;
            case CaelumConstants.CATALOGUE_WEAPON_AXE:
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL:
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW: return 6.0;
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return 7.0;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD:
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return 10.0;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return 12.0;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return 14.0;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return 15.0;
            default: return 20.0;
        }
    }

    static double GetSecondaryAirCost(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return 3.0;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return 4.0;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return 5.0;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN:
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW: return 6.0;
            case CaelumConstants.CATALOGUE_WEAPON_SWORD: return 8.0;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return 9.0;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return 10.0;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return 15.0;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return 18.0;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return 20.0;
            default: return 0.0;
        }
    }

    static int GetPrimaryDamageType(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER:
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN:
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR:
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE:
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW:
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW:
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW:
                return CaelumConstants.CATALOGUE_DAMAGE_PIERCING;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL:
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS:
                return CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
            default: return CaelumConstants.CATALOGUE_DAMAGE_SLASHING;
        }
    }

    static int GetSecondaryDamageType(int weaponId)
    {
        switch (ResolveWeapon(weaponId))
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER:
                return CaelumConstants.CATALOGUE_DAMAGE_SLASHING;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET:
            case CaelumConstants.CATALOGUE_WEAPON_AXE:
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL:
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE:
                return CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE:
            case CaelumConstants.CATALOGUE_WEAPON_SWORD:
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD:
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD:
                return CaelumConstants.CATALOGUE_DAMAGE_PIERCING;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN:
                return CaelumConstants.CATALOGUE_ACTION_THROW;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS:
                return CaelumConstants.CATALOGUE_ACTION_BLOCK;
            default: return CaelumConstants.CATALOGUE_DAMAGE_NONE;
        }
    }
}
