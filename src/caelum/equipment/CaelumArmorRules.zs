// Datos de absorción aprobados en #52. Compartidos por combate y presentación.
class CaelumArmorRules : Object
{
    const PALOMO_DEFENSE = 77.0;
    static clearscope double TierMultiplier(int tier)
    {
        return tier >= 3 ? 2.0 : tier == 2 ? 1.5 : 1.0;
    }

    static clearscope double EquipmentDefense(int armorType, int tier, bool magical = false)
    {
        double baseDefense = 0.0;
        switch (armorType)
        {
            case CaelumConstants.ARMOR_TYPE_MAGIC: baseDefense = magical ? 30.0 : 10.0; break;
            case CaelumConstants.ARMOR_TYPE_LIGHT: baseDefense = 15.0; break;
            case CaelumConstants.ARMOR_TYPE_MEDIUM: baseDefense = 22.5; break;
            case CaelumConstants.ARMOR_TYPE_HEAVY: baseDefense = 35.0; break;
        }
        return baseDefense * TierMultiplier(tier);
    }

    static clearscope double InnateDefense(int race, bool magical = false)
    {
        switch (race)
        {
            case CaelumConstants.RACE_BEAST_MAN: return magical ? 2.5 : 12.5;
            case CaelumConstants.RACE_CAELITH: return magical ? 5.0 : 10.0;
            case CaelumConstants.RACE_GOBLIN: return magical ? 10.0 : 5.0;
            default: return 7.5;
        }
    }

    static double TotalDefense(double innateDefense, CaelumArmorModel armor, int slot, bool magical = false)
    {
        return Clamp(innateDefense
            + (armor != null ? armor.GetDefense(slot, magical) : 0.0), 0.0, 100.0);
    }

    static bool IsMagical(Actor inflictor, Name mod)
    {
        let projectile = CaelumActorProjectile(inflictor);
        return mod == 'CaelumMagicTest' || mod == 'CaelumTrapMagic'
            || (mod == 'Electric' && inflictor is 'CaelumChannelEffect')
            || (projectile != null && projectile.CaelumMagicalAttack);
    }
}
