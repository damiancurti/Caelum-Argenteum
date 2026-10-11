// Decisiones del autor en #183. Los costes se consultan en las recetas;
// este catálogo sólo define el equipo, los recuentos y las proporciones.
class CaelumOnboardingCatalogue : Object
{
    const GOLD_KG = 2;
    const STARTER_ROUNDS = 24;
    const ARMOR_REPAIRS = 1;
    const WEAPON_REPAIRS = 3;
    const TOOL_REPAIRS = 5;
    const LEATHER_SHARE = 0.9;
    const ROPE_SHARE = 0.1;
    // Posición del antiguo suministro del sótano; ahora es el único mineral.
    static Vector3 GoldPosition() { return (1780,640,-384); }

    static int Weapon(int profession)
    {
        switch (profession)
        {
            case CaelumConstants.PROFESSION_WARRIOR: return CaelumConstants.WEAPON_TYPE_GREATSWORD;
            case CaelumConstants.PROFESSION_MERCENARY: return CaelumConstants.WEAPON_TYPE_SWORD;
            case CaelumConstants.PROFESSION_CLERIC: return CaelumConstants.WEAPON_TYPE_FLAIL;
            case CaelumConstants.PROFESSION_BATTLE_MAGE: return CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS;
            case CaelumConstants.PROFESSION_EXPLORER: return CaelumConstants.WEAPON_TYPE_LONGBOW;
            case CaelumConstants.PROFESSION_PILGRIM: return CaelumConstants.WEAPON_TYPE_BELL;
            case CaelumConstants.PROFESSION_INVESTIGATOR: return CaelumConstants.WEAPON_TYPE_CROSSBOW;
            case CaelumConstants.PROFESSION_PRIEST: return CaelumConstants.WEAPON_TYPE_STATUETTE;
            case CaelumConstants.PROFESSION_ARCANIST: return CaelumConstants.WEAPON_TYPE_BOOK;
            default: return CaelumConstants.WEAPON_TYPE_STAFF;
        }
    }

    static int Shield(int profession)
    {
        switch (profession)
        {
            case CaelumConstants.PROFESSION_WARRIOR: return CaelumConstants.SHIELD_TYPE_TOWER;
            case CaelumConstants.PROFESSION_MERCENARY:
            case CaelumConstants.PROFESSION_CLERIC:
            case CaelumConstants.PROFESSION_BATTLE_MAGE: return CaelumConstants.SHIELD_TYPE_KITE;
            case CaelumConstants.PROFESSION_EXPLORER:
            case CaelumConstants.PROFESSION_PILGRIM:
            case CaelumConstants.PROFESSION_PRIEST: return CaelumConstants.SHIELD_TYPE_BUCKLER;
            default: return CaelumConstants.SHIELD_TYPE_MAGIC;
        }
    }

    static int StarterOption(int profession)
    {
        for (int option = 0; option < CaelumMainM00StarterRules.OPTION_COUNT; option++)
            if (CaelumMainM00StarterRules.GetWeaponType(option) == Weapon(profession)
                && (option < 16 || CaelumCraftingRules.GetUnifiedEssenceType(
                    CaelumMainM00StarterRules.GetRecipe(option)) == CaelumConstants.ESSENCE_FIRE)) return option;
        return -1;
    }

    static int Armor(int profession)
    {
        switch (Shield(profession))
        {
            case CaelumConstants.SHIELD_TYPE_TOWER: return CaelumConstants.ARMOR_TYPE_HEAVY;
            case CaelumConstants.SHIELD_TYPE_KITE: return CaelumConstants.ARMOR_TYPE_MEDIUM;
            case CaelumConstants.SHIELD_TYPE_BUCKLER: return CaelumConstants.ARMOR_TYPE_LIGHT;
            default: return CaelumConstants.ARMOR_TYPE_MAGIC;
        }
    }

    static int Necklace(int firstClass)
    {
        int family = CaelumCharacterAllocation.PreferredFamily(firstClass), best = 0;
        for (int type = 1; type < CaelumConstants.AMULET_TYPE_COUNT; type++)
            if (CaelumEquipmentRules.AmuletFamilyBonus(type, family, 1)
                > CaelumEquipmentRules.AmuletFamilyBonus(best, family, 1)) best = type;
        return best;
    }
}
