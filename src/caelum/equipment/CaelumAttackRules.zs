// #37: datos y fórmulas comunes; -1 significa ataque impedido por peso.
class CaelumAttackRules : Object
{
    const BASE_TICS = 14;
    const DURABILITY_SCALE = 10;
    const DURABILITY_REVISION = 1;
    const SLAM_PREPARATION_TICS = 48;
    const SLAM_RECOVERY_TICS = 32;
    const THRUST_LOWER = 30.0;
    const THRUST_ADVANCE = 60.0;
    const THRUST_LOWER_END = 0.16;
    const THRUST_TURN_END = 0.32;
    const THRUST_IMPACT = 0.80;
    const SWING_IMPACT = 0.50;

    static bool IsThrust(int kind, bool secondary)
    {
        return (!secondary && kind == CaelumConstants.WEAPON_TYPE_DAGGER)
            || (secondary && (kind == CaelumConstants.WEAPON_TYPE_MACHETE
            || kind == CaelumConstants.WEAPON_TYPE_SWORD
            || kind == CaelumConstants.WEAPON_TYPE_GREATSWORD
            || kind == CaelumConstants.WEAPON_TYPE_HALBERD));
    }

    static double Duration(double attributeDurationMultiplier, double weaponWeight,
        double gloveWeight, double capacity)
    {
        if (capacity <= 0) return -1;
        double ratio = (Max(0.0, weaponWeight) + Max(0.0, gloveWeight)) / capacity;
        if (ratio >= 1 || attributeDurationMultiplier <= 0) return -1;
        return BASE_TICS * attributeDurationMultiplier / (1.0 - ratio);
    }

    static double NaturalAir()
    {
        return CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_DAGGER) - 1;
    }

    static double SlamAir()
    {
        return 2 * (CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_GREATSWORD)
            + CaelumConstants.JUMP_AIR_COST);
    }
}
