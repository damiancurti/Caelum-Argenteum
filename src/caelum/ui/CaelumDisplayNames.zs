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

    static ui String GetEquipmentSizeKey(int equipmentSize)
    {
        switch (equipmentSize)
        {
            case CaelumConstants.EQUIPMENT_SIZE_XS:
                return "CA_EQUIPMENT_SIZE_XS";
            case CaelumConstants.EQUIPMENT_SIZE_S:
                return "CA_EQUIPMENT_SIZE_S";
            case CaelumConstants.EQUIPMENT_SIZE_L:
                return "CA_EQUIPMENT_SIZE_L";
            case CaelumConstants.EQUIPMENT_SIZE_XL:
                return "CA_EQUIPMENT_SIZE_XL";
            default: return "CA_EQUIPMENT_SIZE_M";
        }
    }

    static ui String GetArmorSlotKey(int armorSlot)
    {
        switch (armorSlot)
        {
            case CaelumConstants.ARMOR_SLOT_HEAD: return "CA_ARMOR_SLOT_HEAD";
            case CaelumConstants.ARMOR_SLOT_BODY: return "CA_ARMOR_SLOT_BODY";
            case CaelumConstants.ARMOR_SLOT_HANDS: return "CA_ARMOR_SLOT_HANDS";
            default: return "CA_ARMOR_SLOT_FEET";
        }
    }

    static ui String GetConsumableKey(int consumableType)
    {
        switch (consumableType)
        {
            case CaelumConstants.CONSUMABLE_ANIMA_POTION:
                return "CA_CONSUMABLE_ANIMA_POTION";
            case CaelumConstants.CONSUMABLE_ENERGY_DRINK:
                return "CA_CONSUMABLE_ENERGY_DRINK";
            case CaelumConstants.CONSUMABLE_FOOD_RATION:
                return "CA_CONSUMABLE_FOOD_RATION";
            case CaelumConstants.CONSUMABLE_WATER_RATION:
                return "CA_CONSUMABLE_WATER_RATION";
            default: return "CA_CONSUMABLE_LIFE_POTION";
        }
    }

    static ui String GetAmmunitionKey(int ammunitionType)
    {
        switch (ammunitionType)
        {
            case CaelumConstants.AMMUNITION_ARROW:
                return "CA_WEAPON_AMMO_ARROWS";
            case CaelumConstants.AMMUNITION_BOLT:
                return "CA_WEAPON_AMMO_BOLTS";
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_ONE:
                return "CA_WEAPON_AMMO_JAVELIN_T1";
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_TWO:
                return "CA_WEAPON_AMMO_JAVELIN_T2";
            case CaelumConstants.AMMUNITION_JAVELIN_TIER_THREE:
                return "CA_WEAPON_AMMO_JAVELIN_T3";
            default: return "CA_WEAPON_AMMO_CARTRIDGES";
        }
    }

    static ui String GetSpecialItemKey(int specialCategory, int specialType)
    {
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            return "CA_KEY_SILVER";
        }
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            return specialType == CaelumConstants.KEY_ITEM_PROCESSING_MANUAL
                ? "CA_KEY_ITEM_PROCESSING_MANUAL"
                : "CA_KEY_ITEM_SEALED_LETTER";
        }
        switch (specialType)
        {
            case CaelumConstants.MATERIAL_BLADE: return "CA_MATERIAL_BLADE";
            case CaelumConstants.MATERIAL_SMALL_BLADE: return "CA_MATERIAL_SMALL_BLADE";
            case CaelumConstants.MATERIAL_CURVED_BLADE: return "CA_MATERIAL_CURVED_BLADE";
            case CaelumConstants.MATERIAL_LONG_BLADE: return "CA_MATERIAL_LONG_BLADE";
            case CaelumConstants.MATERIAL_BROAD_BLADE: return "CA_MATERIAL_BROAD_BLADE";
            case CaelumConstants.MATERIAL_SHAFT: return "CA_MATERIAL_SHAFT";
            case CaelumConstants.MATERIAL_FRAME: return "CA_MATERIAL_FRAME";
            case CaelumConstants.MATERIAL_LONG_FRAME: return "CA_MATERIAL_LONG_FRAME";
            case CaelumConstants.MATERIAL_WEAPON_HEAD: return "CA_MATERIAL_WEAPON_HEAD";
            case CaelumConstants.MATERIAL_ROUND_HEAD: return "CA_MATERIAL_ROUND_HEAD";
            case CaelumConstants.MATERIAL_PLATE: return "CA_MATERIAL_PLATE";
            case CaelumConstants.MATERIAL_ROUND_PLATE: return "CA_MATERIAL_ROUND_PLATE";
            case CaelumConstants.MATERIAL_KITE_PLATE: return "CA_MATERIAL_KITE_PLATE";
            case CaelumConstants.MATERIAL_TOWER_PLATE: return "CA_MATERIAL_TOWER_PLATE";
            case CaelumConstants.MATERIAL_MAGIC_PLATE: return "CA_MATERIAL_MAGIC_PLATE";
            case CaelumConstants.MATERIAL_LARGE_PLATE: return "CA_MATERIAL_LARGE_PLATE";
            case CaelumConstants.MATERIAL_CHAINMAIL: return "CA_MATERIAL_CHAINMAIL";
            case CaelumConstants.MATERIAL_FABRIC: return "CA_MATERIAL_FABRIC";
            case CaelumConstants.MATERIAL_LEATHER: return "CA_MATERIAL_LEATHER";
            case CaelumConstants.MATERIAL_FIRE_ESSENCE: return "CA_MATERIAL_FIRE_ESSENCE";
            case CaelumConstants.MATERIAL_WATER_ESSENCE: return "CA_MATERIAL_WATER_ESSENCE";
            case CaelumConstants.MATERIAL_EARTH_ESSENCE: return "CA_MATERIAL_EARTH_ESSENCE";
            case CaelumConstants.MATERIAL_WIND_ESSENCE: return "CA_MATERIAL_WIND_ESSENCE";
            case CaelumConstants.MATERIAL_QUINTESSENCE: return "CA_MATERIAL_QUINTESSENCE";
            case CaelumConstants.MATERIAL_HILT: return "CA_MATERIAL_HILT";
            case CaelumConstants.MATERIAL_LONG_HILT: return "CA_MATERIAL_LONG_HILT";
            case CaelumConstants.MATERIAL_POINT: return "CA_MATERIAL_POINT";
            case CaelumConstants.MATERIAL_HANDLE: return "CA_MATERIAL_HANDLE";
            case CaelumConstants.MATERIAL_LONG_HANDLE: return "CA_MATERIAL_LONG_HANDLE";
            case CaelumConstants.MATERIAL_BOWSTRING: return "CA_MATERIAL_BOWSTRING";
            case CaelumConstants.MATERIAL_REINFORCED_BOWSTRING: return "CA_MATERIAL_REINFORCED_BOWSTRING";
            case CaelumConstants.MATERIAL_STRAP: return "CA_MATERIAL_STRAP";
            case CaelumConstants.MATERIAL_REINFORCED_STRAP: return "CA_MATERIAL_REINFORCED_STRAP";
            case CaelumConstants.MATERIAL_BARREL: return "CA_MATERIAL_BARREL";
            case CaelumConstants.MATERIAL_MECHANISM: return "CA_MATERIAL_MECHANISM";
            case CaelumConstants.MATERIAL_STAFF_BASE: return "CA_MATERIAL_STAFF_BASE";
            case CaelumConstants.MATERIAL_BELL_BASE: return "CA_MATERIAL_BELL_BASE";
            case CaelumConstants.MATERIAL_BOOK_BASE: return "CA_MATERIAL_BOOK_BASE";
            case CaelumConstants.MATERIAL_STATUETTE_BASE: return "CA_MATERIAL_STATUETTE_BASE";
            case CaelumConstants.MATERIAL_SMALL_WEAPON_HEAD: return "CA_MATERIAL_SMALL_WEAPON_HEAD";
            case CaelumConstants.MATERIAL_CHAIN: return "CA_MATERIAL_CHAIN";
            case CaelumConstants.MATERIAL_WOOD: return "CA_MATERIAL_WOOD";
            case CaelumConstants.MATERIAL_SILVER_CHAIN: return "CA_MATERIAL_SILVER_CHAIN";
            case CaelumConstants.MATERIAL_SEAL_BASE: return "CA_MATERIAL_SEAL_BASE";
            case CaelumConstants.MATERIAL_RUBY_PENDANT: return "CA_MATERIAL_RUBY_PENDANT";
            case CaelumConstants.MATERIAL_SAPPHIRE_PENDANT: return "CA_MATERIAL_SAPPHIRE_PENDANT";
            case CaelumConstants.MATERIAL_EMERALD_PENDANT: return "CA_MATERIAL_EMERALD_PENDANT";
            case CaelumConstants.MATERIAL_TOPAZ_PENDANT: return "CA_MATERIAL_TOPAZ_PENDANT";
            case CaelumConstants.MATERIAL_RUBY_GEM: return "CA_MATERIAL_RUBY_GEM";
            case CaelumConstants.MATERIAL_SAPPHIRE_GEM: return "CA_MATERIAL_SAPPHIRE_GEM";
            case CaelumConstants.MATERIAL_EMERALD_GEM: return "CA_MATERIAL_EMERALD_GEM";
            case CaelumConstants.MATERIAL_TOPAZ_GEM: return "CA_MATERIAL_TOPAZ_GEM";
            case CaelumConstants.MATERIAL_OPAL_BROOCH: return "CA_MATERIAL_OPAL_BROOCH";
            case CaelumConstants.MATERIAL_RAW_RUBY: return "CA_MATERIAL_RAW_RUBY";
            case CaelumConstants.MATERIAL_RAW_SAPPHIRE: return "CA_MATERIAL_RAW_SAPPHIRE";
            case CaelumConstants.MATERIAL_RAW_EMERALD: return "CA_MATERIAL_RAW_EMERALD";
            case CaelumConstants.MATERIAL_RAW_TOPAZ: return "CA_MATERIAL_RAW_TOPAZ";
            case CaelumConstants.MATERIAL_RAW_OPAL: return "CA_MATERIAL_RAW_OPAL";
            case CaelumConstants.MATERIAL_COPPER_INGOT: return "CA_MATERIAL_COPPER_INGOT";
            case CaelumConstants.MATERIAL_TIN_INGOT: return "CA_MATERIAL_TIN_INGOT";
            case CaelumConstants.MATERIAL_COAL: return "CA_MATERIAL_COAL";
            case CaelumConstants.MATERIAL_RAW_COPPER: return "CA_MATERIAL_RAW_COPPER";
            case CaelumConstants.MATERIAL_RAW_TIN: return "CA_MATERIAL_RAW_TIN";
            case CaelumConstants.MATERIAL_RAW_IRON: return "CA_MATERIAL_RAW_IRON";
            case CaelumConstants.MATERIAL_RAW_SILVER: return "CA_MATERIAL_RAW_SILVER";
            case CaelumConstants.MATERIAL_RAW_GOLD: return "CA_MATERIAL_RAW_GOLD";
            case CaelumConstants.MATERIAL_BRONZE_INGOT: return "CA_MATERIAL_BRONZE_INGOT";
            case CaelumConstants.MATERIAL_STEEL_INGOT: return "CA_MATERIAL_STEEL_INGOT";
            case CaelumConstants.MATERIAL_SILVER_INGOT: return "CA_MATERIAL_SILVER_INGOT";
            case CaelumConstants.MATERIAL_GOLD_INGOT: return "CA_MATERIAL_GOLD_INGOT";
            case CaelumConstants.MATERIAL_WOOL: return "CA_MATERIAL_WOOL";
            case CaelumConstants.MATERIAL_COTTON: return "CA_MATERIAL_COTTON";
            case CaelumConstants.MATERIAL_RAW_SILK: return "CA_MATERIAL_RAW_SILK";
            case CaelumConstants.MATERIAL_PLANT_FIBER: return "CA_MATERIAL_PLANT_FIBER";
            case CaelumConstants.MATERIAL_ROPE: return "CA_MATERIAL_ROPE";
            case CaelumConstants.MATERIAL_COW_HIDE: return "CA_MATERIAL_COW_HIDE";
            case CaelumConstants.MATERIAL_PREDATOR_HIDE: return "CA_MATERIAL_PREDATOR_HIDE";
            case CaelumConstants.MATERIAL_MONSTER_HIDE: return "CA_MATERIAL_MONSTER_HIDE";
            default: return "CA_MATERIAL_IRON_INGOT";
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
