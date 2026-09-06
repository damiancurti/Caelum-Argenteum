// Convención visual entregada para objetos equipables: T1 usa el nombre base
// y T2/T3 agregan el sufijo correspondiente antes de .png.
class CaelumIconResolver : Object
{
    static clearscope String ResolveTierPath(String basePath, int tier)
    {
        int resolvedTier = Clamp(tier, 1, 3);
        if (resolvedTier <= 1 || basePath.Length() < 5)
        {
            return basePath;
        }
        return basePath.Left(basePath.Length() - 4)
            .. String.Format("_t%d.png", resolvedTier);
    }

    static clearscope String GetWeaponBasePath(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_SWORD: return "graphics/caelum/icons/ca_sword.png";
            case CaelumConstants.WEAPON_TYPE_STAFF: return "graphics/caelum/icons/ca_staff.png";
            case CaelumConstants.WEAPON_TYPE_CARBINE: return "graphics/caelum/icons/ca_carbine.png";
            case CaelumConstants.WEAPON_TYPE_DAGGER: return "graphics/caelum/icons/ca_dagger.png";
            case CaelumConstants.WEAPON_TYPE_HATCHET: return "graphics/caelum/icons/ca_hatchet.png";
            case CaelumConstants.WEAPON_TYPE_MACHETE: return "graphics/caelum/icons/ca_machete.png";
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return "graphics/caelum/icons/ca_javelin.png";
            case CaelumConstants.WEAPON_TYPE_AXE: return "graphics/caelum/icons/ca_axe.png";
            case CaelumConstants.WEAPON_TYPE_FLAIL: return "graphics/caelum/icons/ca_flail.png";
            case CaelumConstants.WEAPON_TYPE_SPEAR: return "graphics/caelum/icons/ca_spear.png";
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: return "graphics/caelum/icons/ca_greatsword.png";
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: return "graphics/caelum/icons/ca_war_axe.png";
            case CaelumConstants.WEAPON_TYPE_HALBERD: return "graphics/caelum/icons/ca_halberd.png";
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: return "graphics/caelum/icons/ca_giant_gauntlets.png";
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW: return "graphics/caelum/icons/ca_standard_bow.png";
            case CaelumConstants.WEAPON_TYPE_LONGBOW: return "graphics/caelum/icons/ca_longbow.png";
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: return "graphics/caelum/icons/ca_crossbow.png";
            case CaelumConstants.WEAPON_TYPE_BELL: return "graphics/caelum/icons/ca_bell.png";
            case CaelumConstants.WEAPON_TYPE_BOOK: return "graphics/caelum/icons/ca_book.png";
            default: return "graphics/caelum/icons/ca_statuette.png";
        }
    }

    static clearscope String GetShieldBasePath(int shieldType)
    {
        switch (shieldType)
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER: return "graphics/caelum/icons/ca_shield_buckler.png";
            case CaelumConstants.SHIELD_TYPE_KITE: return "graphics/caelum/icons/ca_shield_kite.png";
            case CaelumConstants.SHIELD_TYPE_TOWER: return "graphics/caelum/icons/ca_shield_tower.png";
            default: return "graphics/caelum/icons/ca_shield_magic.png";
        }
    }

    static clearscope String GetArmorBasePath(int armorSlot, int armorType)
    {
        if (armorType == CaelumConstants.ARMOR_TYPE_MAGIC)
        {
            if (armorSlot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet_magic.png";
            if (armorSlot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves.png";
            if (armorSlot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots.png";
            return "graphics/caelum/icons/ca_armor_magic.png";
        }
        if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM)
        {
            if (armorSlot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet_medium.png";
            if (armorSlot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves_medium.png";
            if (armorSlot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots_medium.png";
            return "graphics/caelum/icons/ca_armor_medium.png";
        }
        if (armorType == CaelumConstants.ARMOR_TYPE_HEAVY)
        {
            if (armorSlot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet.png";
            if (armorSlot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves_heavy.png";
            if (armorSlot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots_heavy.png";
            return "graphics/caelum/icons/ca_armor_heavy.png";
        }
        if (armorSlot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet_light.png";
        if (armorSlot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves_light.png";
        if (armorSlot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots_light.png";
        return "graphics/caelum/icons/ca_armor_light.png";
    }

    static clearscope String GetAmuletBasePath(int amuletType)
    {
        if (amuletType == CaelumConstants.AMULET_SAPPHIRE) return "graphics/caelum/icons/jewelry/ca_amulet_sapphire.png";
        if (amuletType == CaelumConstants.AMULET_EMERALD) return "graphics/caelum/icons/jewelry/ca_amulet_emerald.png";
        if (amuletType == CaelumConstants.AMULET_TOPAZ) return "graphics/caelum/icons/jewelry/ca_amulet_topaz.png";
        return "graphics/caelum/icons/jewelry/ca_amulet_ruby.png";
    }

    static clearscope String GetSealBasePath(int sealType)
    {
        if (sealType == CaelumConstants.SEAL_WATER) return "graphics/caelum/icons/jewelry/ca_seal_water.png";
        if (sealType == CaelumConstants.SEAL_EARTH) return "graphics/caelum/icons/jewelry/ca_seal_earth.png";
        if (sealType == CaelumConstants.SEAL_AIR) return "graphics/caelum/icons/jewelry/ca_seal_air.png";
        if (sealType == CaelumConstants.SEAL_QUINTESSENCE) return "graphics/caelum/icons/jewelry/ca_seal_quintessence.png";
        return "graphics/caelum/icons/jewelry/ca_seal_fire.png";
    }

    static clearscope String ResolveEquipmentPath(
        int equipmentKind, int itemType, int armorSlot, int tier
    )
    {
        String basePath = "";
        switch (equipmentKind)
        {
            case CaelumConstants.EQUIPMENT_KIND_WEAPON:
                basePath = GetWeaponBasePath(itemType);
                break;
            case CaelumConstants.EQUIPMENT_KIND_SHIELD:
                basePath = GetShieldBasePath(itemType);
                break;
            case CaelumConstants.EQUIPMENT_KIND_ARMOR:
                basePath = GetArmorBasePath(armorSlot, itemType);
                break;
            case CaelumConstants.EQUIPMENT_KIND_AMULET:
                basePath = GetAmuletBasePath(itemType);
                break;
            case CaelumConstants.EQUIPMENT_KIND_SEAL:
                basePath = GetSealBasePath(itemType);
                break;
            default:
                return "";
        }
        return ResolveTierPath(basePath, tier);
    }
}
