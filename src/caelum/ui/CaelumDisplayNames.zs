// Nombres de equipo visibles para el jugador. El tier numérico permanece como
// dato interno, pero se expresa como acabado normal, plateado o dorado.
class CaelumDisplayNames : Object
{
    const GRAMMAR_MASCULINE = 0;
    const GRAMMAR_FEMININE = 1;
    const GRAMMAR_MASCULINE_PLURAL = 2;
    const GRAMMAR_FEMININE_PLURAL = 3;

    static ui String GetWeaponKey(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF: return "CA_WEAPON_TYPE_STAFF";
            case CaelumConstants.WEAPON_TYPE_CARBINE: return "CA_WEAPON_TYPE_CARBINE";
            case CaelumConstants.WEAPON_TYPE_DAGGER: return "CA_WEAPON_TYPE_DAGGER";
            case CaelumConstants.WEAPON_TYPE_HATCHET: return "CA_WEAPON_TYPE_HATCHET";
            case CaelumConstants.WEAPON_TYPE_MACHETE: return "CA_WEAPON_TYPE_MACHETE";
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return "CA_WEAPON_TYPE_JAVELIN";
            case CaelumConstants.WEAPON_TYPE_AXE: return "CA_WEAPON_TYPE_AXE";
            case CaelumConstants.WEAPON_TYPE_FLAIL: return "CA_WEAPON_TYPE_FLAIL";
            case CaelumConstants.WEAPON_TYPE_SPEAR: return "CA_WEAPON_TYPE_SPEAR";
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return "CA_WEAPON_TYPE_GREATSWORD";
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return "CA_WEAPON_TYPE_WAR_AXE";
            case CaelumConstants.WEAPON_TYPE_HALBERD: return "CA_WEAPON_TYPE_HALBERD";
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: return "CA_WEAPON_TYPE_GIANT_GAUNTLETS";
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW: return "CA_WEAPON_TYPE_STANDARD_BOW";
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return "CA_WEAPON_TYPE_LONGBOW";
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return "CA_WEAPON_TYPE_CROSSBOW";
            case CaelumConstants.WEAPON_TYPE_BELL: return "CA_WEAPON_TYPE_BELL";
            case CaelumConstants.WEAPON_TYPE_BOOK: return "CA_WEAPON_TYPE_BOOK";
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return "CA_WEAPON_TYPE_STATUETTE";
            default: return "CA_WEAPON_TYPE_SWORD";
        }
    }

    static ui int GetWeaponGrammar(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_CARBINE:
            case CaelumConstants.WEAPON_TYPE_DAGGER:
            case CaelumConstants.WEAPON_TYPE_HATCHET:
            case CaelumConstants.WEAPON_TYPE_JAVELIN:
            case CaelumConstants.WEAPON_TYPE_AXE:
            case CaelumConstants.WEAPON_TYPE_SPEAR:
            case CaelumConstants.WEAPON_TYPE_WAR_AXE:
            case CaelumConstants.WEAPON_TYPE_HALBERD:
            case CaelumConstants.WEAPON_TYPE_CROSSBOW:
            case CaelumConstants.WEAPON_TYPE_BELL:
            case CaelumConstants.WEAPON_TYPE_STATUETTE:
                return GRAMMAR_FEMININE;
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS:
                return GRAMMAR_MASCULINE_PLURAL;
            default:
                return GRAMMAR_MASCULINE;
        }
    }

    static ui String GetArmorTypeKey(int armorType)
    {
        switch (armorType)
        {
            case CaelumConstants.ARMOR_TYPE_LIGHT:
                return "CA_EQUIPMENT_NAME_ARMOR_LIGHT";
            case CaelumConstants.ARMOR_TYPE_MEDIUM:
                return "CA_EQUIPMENT_NAME_ARMOR_MEDIUM";
            case CaelumConstants.ARMOR_TYPE_HEAVY:
                return "CA_EQUIPMENT_NAME_ARMOR_HEAVY";
            default: return "CA_EQUIPMENT_NAME_ARMOR_MAGIC";
        }
    }

    static ui String GetShieldKey(int shieldType)
    {
        switch (shieldType)
        {
            case CaelumConstants.SHIELD_TYPE_KITE: return "CA_SHIELD_TYPE_KITE";
            case CaelumConstants.SHIELD_TYPE_TOWER: return "CA_SHIELD_TYPE_TOWER";
            case CaelumConstants.SHIELD_TYPE_MAGIC: return "CA_SHIELD_TYPE_MAGIC";
            default: return "CA_SHIELD_TYPE_BUCKLER";
        }
    }

    static ui String GetAmuletKey(int amuletType)
    {
        switch (amuletType)
        {
            case CaelumConstants.AMULET_SAPPHIRE: return "CA_AMULET_SAPPHIRE";
            case CaelumConstants.AMULET_EMERALD: return "CA_AMULET_EMERALD";
            case CaelumConstants.AMULET_TOPAZ: return "CA_AMULET_TOPAZ";
            default: return "CA_AMULET_RUBY";
        }
    }

    static ui String GetSealKey(int sealType)
    {
        switch (sealType)
        {
            case CaelumConstants.SEAL_WATER: return "CA_SEAL_WATER";
            case CaelumConstants.SEAL_EARTH: return "CA_SEAL_EARTH";
            case CaelumConstants.SEAL_AIR: return "CA_SEAL_AIR";
            case CaelumConstants.SEAL_QUINTESSENCE: return "CA_SEAL_QUINTESSENCE";
            default: return "CA_SEAL_FIRE";
        }
    }

    static ui String GetFinishFormatKey(int tier, int grammar)
    {
        bool silver = tier == 2;
        if (grammar == GRAMMAR_FEMININE)
        {
            return silver
                ? "CA_EQUIPMENT_FINISH_SILVER_FEMININE"
                : "CA_EQUIPMENT_FINISH_GOLD_FEMININE";
        }
        if (grammar == GRAMMAR_MASCULINE_PLURAL)
        {
            return silver
                ? "CA_EQUIPMENT_FINISH_SILVER_MASCULINE_PLURAL"
                : "CA_EQUIPMENT_FINISH_GOLD_MASCULINE_PLURAL";
        }
        if (grammar == GRAMMAR_FEMININE_PLURAL)
        {
            return silver
                ? "CA_EQUIPMENT_FINISH_SILVER_FEMININE_PLURAL"
                : "CA_EQUIPMENT_FINISH_GOLD_FEMININE_PLURAL";
        }
        return silver
            ? "CA_EQUIPMENT_FINISH_SILVER_MASCULINE"
            : "CA_EQUIPMENT_FINISH_GOLD_MASCULINE";
    }

    static ui String FormatLocalizedKey(String baseKey, int tier, int grammar)
    {
        String baseName = StringTable.Localize(baseKey, false);
        if (tier <= 1) { return baseName; }
        return String.Format(
            StringTable.Localize(
                GetFinishFormatKey(Clamp(tier, 2, 3), grammar), false
            ),
            baseName
        );
    }

    static ui String FormatWeaponName(int weaponType, int tier)
    {
        return FormatLocalizedKey(
            GetWeaponKey(weaponType), tier, GetWeaponGrammar(weaponType)
        );
    }

    static ui String FormatArmorTypeName(int armorType, int tier)
    {
        return FormatLocalizedKey(
            GetArmorTypeKey(armorType), tier, GRAMMAR_FEMININE
        );
    }

    static ui String FormatShieldName(int shieldType, int tier)
    {
        return FormatLocalizedKey(
            GetShieldKey(shieldType), tier, GRAMMAR_MASCULINE
        );
    }

    static ui String FormatAmuletName(int amuletType, int tier)
    {
        return FormatLocalizedKey(
            GetAmuletKey(amuletType), tier, GRAMMAR_MASCULINE
        );
    }

    static ui String FormatSealName(int sealType, int tier)
    {
        return FormatLocalizedKey(
            GetSealKey(sealType), tier, GRAMMAR_MASCULINE
        );
    }

    static ui int GetCatalogueWeaponType(int weaponId)
    {
        switch (weaponId)
        {
            case CaelumConstants.CATALOGUE_WEAPON_DAGGER: return CaelumConstants.WEAPON_TYPE_DAGGER;
            case CaelumConstants.CATALOGUE_WEAPON_HATCHET: return CaelumConstants.WEAPON_TYPE_HATCHET;
            case CaelumConstants.CATALOGUE_WEAPON_MACHETE: return CaelumConstants.WEAPON_TYPE_MACHETE;
            case CaelumConstants.CATALOGUE_WEAPON_JAVELIN: return CaelumConstants.WEAPON_TYPE_JAVELIN;
            case CaelumConstants.CATALOGUE_WEAPON_AXE: return CaelumConstants.WEAPON_TYPE_AXE;
            case CaelumConstants.CATALOGUE_WEAPON_FLAIL: return CaelumConstants.WEAPON_TYPE_FLAIL;
            case CaelumConstants.CATALOGUE_WEAPON_SPEAR: return CaelumConstants.WEAPON_TYPE_SPEAR;
            case CaelumConstants.CATALOGUE_WEAPON_GREATSWORD: return CaelumConstants.WEAPON_TYPE_GREATSWORD;
            case CaelumConstants.CATALOGUE_WEAPON_WAR_AXE: return CaelumConstants.WEAPON_TYPE_WAR_AXE;
            case CaelumConstants.CATALOGUE_WEAPON_HALBERD: return CaelumConstants.WEAPON_TYPE_HALBERD;
            case CaelumConstants.CATALOGUE_WEAPON_GIANT_GAUNTLETS: return CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS;
            case CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW: return CaelumConstants.WEAPON_TYPE_STANDARD_BOW;
            case CaelumConstants.CATALOGUE_WEAPON_CARBINE: return CaelumConstants.WEAPON_TYPE_CARBINE;
            case CaelumConstants.CATALOGUE_WEAPON_LONGBOW: return CaelumConstants.WEAPON_TYPE_LONGBOW;
            case CaelumConstants.CATALOGUE_WEAPON_CROSSBOW: return CaelumConstants.WEAPON_TYPE_CROSSBOW;
            default: return CaelumConstants.WEAPON_TYPE_SWORD;
        }
    }

    static ui String FormatCatalogueWeaponName(int weaponId, int tier)
    {
        return FormatWeaponName(GetCatalogueWeaponType(weaponId), tier);
    }
}
