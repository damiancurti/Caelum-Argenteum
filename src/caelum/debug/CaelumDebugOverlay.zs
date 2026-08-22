// CaelumDebugOverlay draws development information over the game view.
// It is deliberately separate from the final HUD and can be toggled off.
class CaelumDebugOverlay : EventHandler
{
    // GZDoom supplies SmallFont. We use it only as a temporary debug font.
    Font DebugFont;
    Array<Actor> LastDamagedActors;
    Array<Actor> LastPlayerDamageOwners;
    CaelumCombatActor LastInspectedCombatActor;

    Actor ResolvePlayerDamageOwner(Actor source)
    {
        if (source == null) { return null; }
        if (source.player != null) { return source; }
        if (source.Target != null && source.Target.player != null)
        {
            return source.Target;
        }
        return null;
    }

    override void WorldThingDamaged(WorldEvent e)
    {
        CaelumCombatActor combatActor = CaelumCombatActor(e.Thing);
        if (combatActor != null)
        {
            LastInspectedCombatActor = combatActor;
        }

        Actor owner = ResolvePlayerDamageOwner(e.DamageSource);
        if (e.Thing == null || owner == null || e.Damage <= 0) { return; }

        for (int i = 0; i < LastDamagedActors.Size(); i++)
        {
            if (LastDamagedActors[i] == e.Thing)
            {
                LastPlayerDamageOwners[i] = owner;
                return;
            }
        }
        LastDamagedActors.Push(e.Thing);
        LastPlayerDamageOwners.Push(owner);
    }

    Actor GetRecordedDamageOwner(Actor victim)
    {
        for (int i = LastDamagedActors.Size() - 1; i >= 0; i--)
        {
            if (LastDamagedActors[i] == victim)
            {
                return LastPlayerDamageOwners[i];
            }
        }
        return null;
    }

    void ForgetRecordedDamageOwner(Actor victim)
    {
        for (int i = LastDamagedActors.Size() - 1; i >= 0; i--)
        {
            if (LastDamagedActors[i] == victim)
            {
                LastDamagedActors.Delete(i);
                LastPlayerDamageOwners.Delete(i);
                return;
            }
        }
    }

    ui String GetVulnerabilityKey(int grade)
    {
        switch (grade)
        {
            case CaelumConstants.VULNERABILITY_CRITICAL_POINT: return "CA_VULNERABILITY_CRITICAL";
            case CaelumConstants.VULNERABILITY_SENSITIVE_POINT: return "CA_VULNERABILITY_SENSITIVE";
            case CaelumConstants.VULNERABILITY_WEAK_POINT: return "CA_VULNERABILITY_WEAK";
            case CaelumConstants.VULNERABILITY_STRONG_POINT: return "CA_VULNERABILITY_STRONG";
            case CaelumConstants.VULNERABILITY_HARD_POINT: return "CA_VULNERABILITY_HARD";
            case CaelumConstants.VULNERABILITY_ARMORED_POINT: return "CA_VULNERABILITY_ARMORED";
            default: return "CA_VULNERABILITY_NEUTRAL";
        }
    }

    ui String GetHitLocationKey(int location)
    {
        switch (location)
        {
            case CaelumConstants.HIT_LOCATION_HEAD: return "CA_HIT_LOCATION_HEAD";
            case CaelumConstants.HIT_LOCATION_TORSO: return "CA_HIT_LOCATION_TORSO";
            case CaelumConstants.HIT_LOCATION_ARMS: return "CA_HIT_LOCATION_ARMS";
            case CaelumConstants.HIT_LOCATION_LEGS: return "CA_HIT_LOCATION_LEGS";
            default: return "CA_HIT_LOCATION_NONE";
        }
    }

    ui String GetLucidityStateKey(int lucidityState)
    {
        if (lucidityState == CaelumConstants.LUCIDITY_STATE_STUNNED)
        {
            return "CA_LUCIDITY_STATE_STUNNED";
        }
        if (lucidityState == CaelumConstants.LUCIDITY_STATE_DIZZY)
        {
            return "CA_LUCIDITY_STATE_DIZZY";
        }
        return "CA_LUCIDITY_STATE_NORMAL";
    }

    ui String GetAdrenalineEventKey(int eventType)
    {
        switch (eventType)
        {
            case CaelumConstants.ADRENALINE_EVENT_DAMAGE: return "CA_ADRENALINE_EVENT_DAMAGE";
            case CaelumConstants.ADRENALINE_EVENT_PAIN: return "CA_ADRENALINE_EVENT_PAIN";
            case CaelumConstants.ADRENALINE_EVENT_MELEE: return "CA_ADRENALINE_EVENT_MELEE";
            case CaelumConstants.ADRENALINE_EVENT_EVASION: return "CA_ADRENALINE_EVENT_EVASION";
            case CaelumConstants.ADRENALINE_EVENT_ENEMY_KILL: return "CA_ADRENALINE_EVENT_ENEMY_KILL";
            case CaelumConstants.ADRENALINE_EVENT_ALLY_DEATH: return "CA_ADRENALINE_EVENT_ALLY_DEATH";
            case CaelumConstants.ADRENALINE_EVENT_SHIELD_BLOCK: return "CA_ADRENALINE_EVENT_SHIELD_BLOCK";
            case CaelumConstants.ADRENALINE_EVENT_MAGIC_DAMAGE: return "CA_ADRENALINE_EVENT_MAGIC_DAMAGE";
            default: return "CA_ADRENALINE_EVENT_OTHER";
        }
    }

    ui String GetArmorSlotKey(int slot)
    {
        switch (slot)
        {
            case CaelumConstants.ARMOR_SLOT_HEAD: return "CA_ARMOR_SLOT_HEAD";
            case CaelumConstants.ARMOR_SLOT_BODY: return "CA_ARMOR_SLOT_BODY";
            case CaelumConstants.ARMOR_SLOT_HANDS: return "CA_ARMOR_SLOT_HANDS";
            default: return "CA_ARMOR_SLOT_FEET";
        }
    }

    ui String GetArmorTypeKey(int armorType)
    {
        switch (armorType)
        {
            case CaelumConstants.ARMOR_TYPE_LIGHT: return "CA_ARMOR_TYPE_LIGHT";
            case CaelumConstants.ARMOR_TYPE_MEDIUM: return "CA_ARMOR_TYPE_MEDIUM";
            case CaelumConstants.ARMOR_TYPE_HEAVY: return "CA_ARMOR_TYPE_HEAVY";
            default: return "CA_ARMOR_TYPE_MAGIC";
        }
    }

    // El estado realmente desequipado usa una etiqueta distinta por zona.
    ui String GetArmorDisplayKey(int slot, int armorType)
    {
        if (armorType != CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
        {
            return GetArmorTypeKey(armorType);
        }
        if (slot == CaelumConstants.ARMOR_SLOT_HANDS)
        {
            return "CA_ARMOR_BASE_SHIRT";
        }
        if (slot == CaelumConstants.ARMOR_SLOT_FEET)
        {
            return "CA_ARMOR_BASE_PANTS";
        }
        return "CA_ARMOR_BASE_NOTHING";
    }

    ui int GetArmorDefenseForPanel(CaelumArmorModel armor, int slot)
    {
        if (armor.Durability[slot] <= 0) { return 0; }
        int tier = armor.Tier[slot];
        switch (armor.ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_MAGIC: return tier == 1 ? 5 : (tier == 2 ? 10 : 15);
            case CaelumConstants.ARMOR_TYPE_LIGHT: return tier == 1 ? 10 : (tier == 2 ? 20 : 30);
            case CaelumConstants.ARMOR_TYPE_MEDIUM: return tier == 1 ? 20 : (tier == 2 ? 40 : 60);
            default: return tier == 1 ? 30 : (tier == 2 ? 60 : 90);
        }
    }

    ui int GetArmorReinforcementForPanel(CaelumArmorModel armor, int slot)
    {
        if (armor.Durability[slot] <= 0) { return 0; }
        switch (armor.ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_MAGIC: return slot == CaelumConstants.ARMOR_SLOT_BODY ? 1 : 0;
            case CaelumConstants.ARMOR_TYPE_LIGHT:
                return (slot == CaelumConstants.ARMOR_SLOT_HEAD || slot == CaelumConstants.ARMOR_SLOT_BODY) ? 1 : 0;
            case CaelumConstants.ARMOR_TYPE_MEDIUM: return slot == CaelumConstants.ARMOR_SLOT_HANDS ? 0 : 2;
            default: return 3;
        }
    }

    ui int GetArmorMaximumDurabilityForPanel(CaelumArmorModel armor, int slot)
    {
        if (armor.ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
        {
            return 0;
        }
        int baseDurability = 20;
        switch (armor.ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_LIGHT: baseDurability = 40; break;
            case CaelumConstants.ARMOR_TYPE_MEDIUM: baseDurability = 60; break;
            case CaelumConstants.ARMOR_TYPE_HEAVY: baseDurability = 100; break;
        }
        int multiplier = armor.Tier[slot] == 1 ? 1 : (armor.Tier[slot] == 2 ? 3 : 9);
        double sizeMultiplier = 1.0;
        if (armor.Size[slot] == CaelumConstants.EQUIPMENT_SIZE_XS) sizeMultiplier = 0.50;
        else if (armor.Size[slot] == CaelumConstants.EQUIPMENT_SIZE_S) sizeMultiplier = 0.75;
        else if (armor.Size[slot] == CaelumConstants.EQUIPMENT_SIZE_L) sizeMultiplier = 1.25;
        else if (armor.Size[slot] == CaelumConstants.EQUIPMENT_SIZE_XL) sizeMultiplier = 1.50;
        return Max(1, int(baseDurability * multiplier * sizeMultiplier + 0.5));
    }

    ui String GetShieldTypeKey(int shieldType)
    {
        switch (shieldType)
        {
            case CaelumConstants.SHIELD_TYPE_KITE: return "CA_SHIELD_TYPE_KITE";
            case CaelumConstants.SHIELD_TYPE_TOWER: return "CA_SHIELD_TYPE_TOWER";
            case CaelumConstants.SHIELD_TYPE_MAGIC: return "CA_SHIELD_TYPE_MAGIC";
            default: return "CA_SHIELD_TYPE_BUCKLER";
        }
    }

    ui String GetWeaponTypeKey(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_DAGGER: return "CA_WEAPON_TYPE_DAGGER";
            case CaelumConstants.WEAPON_TYPE_HATCHET: return "CA_WEAPON_TYPE_HATCHET";
            case CaelumConstants.WEAPON_TYPE_MACHETE: return "CA_WEAPON_TYPE_MACHETE";
            case CaelumConstants.WEAPON_TYPE_JAVELIN: return "CA_WEAPON_TYPE_JAVELIN";
            case CaelumConstants.WEAPON_TYPE_STAFF: return "CA_WEAPON_TYPE_STAFF";
            case CaelumConstants.WEAPON_TYPE_CARBINE: return "CA_WEAPON_TYPE_CARBINE";
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

    ui String GetEssenceTypeKey(int essenceType)
    {
        switch (essenceType)
        {
            case CaelumConstants.ESSENCE_WATER: return "CA_ESSENCE_WATER";
            case CaelumConstants.ESSENCE_EARTH: return "CA_ESSENCE_EARTH";
            case CaelumConstants.ESSENCE_WIND: return "CA_ESSENCE_WIND";
            case CaelumConstants.ESSENCE_QUINTESSENCE:
                return "CA_ESSENCE_QUINTESSENCE";
            default: return "CA_ESSENCE_FIRE";
        }
    }
    ui String GetAmuletTypeKey(int t)
    {
        if (t==CaelumConstants.AMULET_SAPPHIRE) return "CA_AMULET_SAPPHIRE";
        if (t==CaelumConstants.AMULET_EMERALD) return "CA_AMULET_EMERALD";
        if (t==CaelumConstants.AMULET_TOPAZ) return "CA_AMULET_TOPAZ";
        return "CA_AMULET_RUBY";
    }
    ui String GetSealTypeKey(int t)
    {
        if (t==CaelumConstants.SEAL_WATER) return "CA_SEAL_WATER";
        if (t==CaelumConstants.SEAL_EARTH) return "CA_SEAL_EARTH";
        if (t==CaelumConstants.SEAL_AIR) return "CA_SEAL_AIR";
        if (t==CaelumConstants.SEAL_QUINTESSENCE) return "CA_SEAL_QUINTESSENCE";
        return "CA_SEAL_FIRE";
    }


    ui String GetCraftingWeaponKey(int weaponId)
    {
        switch (weaponId)
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

    ui String GetCraftingStationKey(int stationType)
    {
        switch (stationType)
        {
            case CaelumConstants.CRAFTING_STATION_FORGE:
                return "CA_CRAFTING_STATION_FORGE";
            case CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP:
                return "CA_CRAFTING_STATION_RANGED_WORKSHOP";
            case CaelumConstants.CRAFTING_STATION_ARMOR_WORKSHOP:
                return "CA_CRAFTING_STATION_ARMOR_WORKSHOP";
            case CaelumConstants.CRAFTING_STATION_ESSENCE_ALTAR:
                return "CA_CRAFTING_STATION_ESSENCE_ALTAR";
            case CaelumConstants.CRAFTING_STATION_WORKBENCH:
                return "CA_CRAFTING_STATION_WORKBENCH";
            case CaelumConstants.CRAFTING_STATION_ANVIL:
                return "CA_CRAFTING_STATION_ANVIL";
            case CaelumConstants.CRAFTING_STATION_SAWMILL:
                return "CA_CRAFTING_STATION_SAWMILL";
            case CaelumConstants.CRAFTING_STATION_SEWING_MACHINE:
                return "CA_CRAFTING_STATION_SEWING_MACHINE";
            case CaelumConstants.CRAFTING_STATION_GLOBE:
                return "CA_CRAFTING_STATION_GLOBE";
            case CaelumConstants.CRAFTING_STATION_JEWELER_BENCH:
                return "CA_CRAFTING_STATION_JEWELER_BENCH";
            case CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH:
                return "CA_CRAFTING_STATION_FINE_TOOLS_BENCH";
            case CaelumConstants.CRAFTING_STATION_MASTER_BENCH:
                return "CA_CRAFTING_STATION_MASTER_BENCH";
            default:
                return "CA_CRAFTING_STATION_NONE";
        }
    }

    ui String GetCraftingActionKey(int craftingAction)
    {
        switch (craftingAction)
        {
            case CaelumConstants.CRAFTING_ACTION_CREATED:
                return "CA_CRAFTING_ACTION_CREATED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS:
                return "CA_CRAFTING_ACTION_FAILED_MATERIALS";
            case CaelumConstants.CRAFTING_ACTION_FAILED_BOX_FULL:
                return "CA_CRAFTING_ACTION_FAILED_BOX_FULL";
            case CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE:
                return "CA_CRAFTING_ACTION_FAILED_DUPLICATE";
            case CaelumConstants.CRAFTING_ACTION_MATERIALS_SPAWNED:
                return "CA_CRAFTING_ACTION_MATERIALS_SPAWNED";
            case CaelumConstants.CRAFTING_ACTION_FAILED_STATION:
                return "CA_CRAFTING_ACTION_FAILED_STATION";
            case CaelumConstants.CRAFTING_ACTION_FAILED_INFRASTRUCTURE:
                return "CA_CRAFTING_ACTION_FAILED_INFRASTRUCTURE";
            default: return "CA_CRAFTING_ACTION_NONE";
        }
    }

    ui String GetEquipmentSizeKey(int equipmentSize)
    {
        switch (equipmentSize)
        {
            case CaelumConstants.EQUIPMENT_SIZE_XS: return "CA_EQUIPMENT_SIZE_XS";
            case CaelumConstants.EQUIPMENT_SIZE_S: return "CA_EQUIPMENT_SIZE_S";
            case CaelumConstants.EQUIPMENT_SIZE_L: return "CA_EQUIPMENT_SIZE_L";
            case CaelumConstants.EQUIPMENT_SIZE_XL: return "CA_EQUIPMENT_SIZE_XL";
            default: return "CA_EQUIPMENT_SIZE_M";
        }
    }

    ui String GetConsumableTypeKey(int consumableType)
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
            default:
                return "CA_CONSUMABLE_LIFE_POTION";
        }
    }

    ui String GetAmmunitionTypeKey(int ammunitionType)
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
            default:
                return "CA_WEAPON_AMMO_CARTRIDGES";
        }
    }

    ui String GetSpecialItemTypeKey(int specialCategory, int specialType)
    {
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            return "CA_KEY_SILVER";
        }
        if (specialCategory == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            return "CA_KEY_ITEM_SEALED_LETTER";
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
            default: return "CA_MATERIAL_IRON_INGOT";
        }
    }

    ui int GetMaterialFamilyForPanel(int materialType)
    {
        if (materialType == CaelumConstants.MATERIAL_IRON_INGOT
            || (materialType >= CaelumConstants.MATERIAL_BLADE
                && materialType <= CaelumConstants.MATERIAL_BROAD_BLADE)
            || (materialType >= CaelumConstants.MATERIAL_WEAPON_HEAD
                && materialType <= CaelumConstants.MATERIAL_CHAINMAIL)
            || materialType == CaelumConstants.MATERIAL_BARREL
            || materialType == CaelumConstants.MATERIAL_SMALL_WEAPON_HEAD)
        {
            return CaelumConstants.MATERIAL_FAMILY_METAL;
        }
        if (materialType >= CaelumConstants.MATERIAL_SHAFT
            && materialType <= CaelumConstants.MATERIAL_LONG_FRAME)
        {
            return CaelumConstants.MATERIAL_FAMILY_WOOD;
        }
        if (materialType >= CaelumConstants.MATERIAL_FIRE_ESSENCE
            && materialType <= CaelumConstants.MATERIAL_QUINTESSENCE)
        {
            return CaelumConstants.MATERIAL_FAMILY_ESSENCE;
        }
        if (materialType == CaelumConstants.MATERIAL_LEATHER)
        {
            return CaelumConstants.MATERIAL_FAMILY_LEATHER;
        }
        if (materialType == CaelumConstants.MATERIAL_FABRIC)
        {
            return CaelumConstants.MATERIAL_FAMILY_FABRIC;
        }
        if (materialType >= CaelumConstants.MATERIAL_RUBY_PENDANT
            && materialType <= CaelumConstants.MATERIAL_OPAL_BROOCH)
        {
            return CaelumConstants.MATERIAL_FAMILY_GEM;
        }
        return CaelumConstants.MATERIAL_FAMILY_NONE;
    }

    ui String GetMaterialGradeKey(int materialType, int tier)
    {
        int family = GetMaterialFamilyForPanel(materialType);
        if (family == CaelumConstants.MATERIAL_FAMILY_METAL)
        {
            return tier == 1 ? "CA_MATERIAL_GRADE_BRONZE"
                : (tier == 2 ? "CA_MATERIAL_GRADE_IRON"
                    : "CA_MATERIAL_GRADE_STEEL");
        }
        if (family == CaelumConstants.MATERIAL_FAMILY_WOOD)
        {
            return tier == 1 ? "CA_MATERIAL_GRADE_COMMON_WOOD"
                : (tier == 2 ? "CA_MATERIAL_GRADE_HARD_WOOD"
                    : "CA_MATERIAL_GRADE_EBONY_WOOD");
        }
        if (family == CaelumConstants.MATERIAL_FAMILY_ESSENCE)
        {
            return tier == 1 ? "CA_MATERIAL_GRADE_SIMPLE"
                : (tier == 2 ? "CA_MATERIAL_GRADE_FINE"
                    : "CA_MATERIAL_GRADE_PURE");
        }
        if (family == CaelumConstants.MATERIAL_FAMILY_LEATHER)
        {
            return tier == 1 ? "CA_MATERIAL_GRADE_COW_LEATHER"
                : (tier == 2 ? "CA_MATERIAL_GRADE_PREDATOR_LEATHER"
                    : "CA_MATERIAL_GRADE_MONSTER_LEATHER");
        }
        if (family == CaelumConstants.MATERIAL_FAMILY_FABRIC)
        {
            return tier == 1 ? "CA_MATERIAL_GRADE_WOOL"
                : (tier == 2 ? "CA_MATERIAL_GRADE_COTTON"
                    : "CA_MATERIAL_GRADE_SILK");
        }
        if (family == CaelumConstants.MATERIAL_FAMILY_GEM)
        {
            return tier == 1 ? "CA_MATERIAL_GRADE_NORMAL"
                : (tier == 2 ? "CA_MATERIAL_GRADE_REFINED"
                    : "CA_MATERIAL_GRADE_LUXURY");
        }
        return "";
    }

    ui String GetEquipmentActionKey(int equipmentAction)
    {
        switch (equipmentAction)
        {
            case CaelumConstants.EQUIPMENT_ACTION_CREATED:
                return "CA_EQUIPMENT_ACTION_CREATED";
            case CaelumConstants.EQUIPMENT_ACTION_EQUIPPED:
                return "CA_EQUIPMENT_ACTION_EQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_UNEQUIPPED:
                return "CA_EQUIPMENT_ACTION_UNEQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_BROKEN:
                return "CA_EQUIPMENT_ACTION_BROKEN";
            case CaelumConstants.EQUIPMENT_ACTION_DROPPED:
                return "CA_EQUIPMENT_ACTION_DROPPED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_SIZE:
                return "CA_EQUIPMENT_ACTION_FAILED_SIZE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_BOX_FULL:
                return "CA_EQUIPMENT_ACTION_FAILED_BOX_FULL";
            case CaelumConstants.EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY:
                return "CA_EQUIPMENT_ACTION_FAILED_CARRY_CAPACITY";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED:
                return "CA_EQUIPMENT_ACTION_FAILED_NOT_OWNED";
            case CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX:
                return "CA_EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX";
            case CaelumConstants.EQUIPMENT_ACTION_SPAWNED_ON_FLOOR:
                return "CA_EQUIPMENT_ACTION_SPAWNED_ON_FLOOR";
            case CaelumConstants.EQUIPMENT_ACTION_USED:
                return "CA_EQUIPMENT_ACTION_USED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_KEY_STORAGE:
                return "CA_EQUIPMENT_ACTION_FAILED_KEY_STORAGE";
            case CaelumConstants.EQUIPMENT_ACTION_DISMANTLED:
                return "CA_EQUIPMENT_ACTION_DISMANTLED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_EQUIPPED:
                return "CA_EQUIPMENT_ACTION_FAILED_EQUIPPED";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_STORAGE:
                return "CA_EQUIPMENT_ACTION_FAILED_STORAGE";
            case CaelumConstants.EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED:
                return "CA_EQUIPMENT_ACTION_FAILED_DISMANTLE_UNSUPPORTED";
            default:
                return "CA_EQUIPMENT_ACTION_NONE";
        }
    }

    // UI-scope mirrors of the shield data keep the overlay compatible with
    // GZDoom's play/UI scope separation.
    ui int GetShieldMaximumDurabilityForPanel(CaelumShieldModel shield)
    {
        int baseDurability = 100;
        switch (shield.ShieldType)
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER: baseDurability = 80; break;
            case CaelumConstants.SHIELD_TYPE_KITE: baseDurability = 150; break;
            case CaelumConstants.SHIELD_TYPE_TOWER: baseDurability = 250; break;
        }
        int multiplier = shield.Tier == 1 ? 1 : (shield.Tier == 2 ? 3 : 9);
        double sizeMultiplier = 1.0;
        if (shield.Size == CaelumConstants.EQUIPMENT_SIZE_XS) sizeMultiplier = 0.50;
        else if (shield.Size == CaelumConstants.EQUIPMENT_SIZE_S) sizeMultiplier = 0.75;
        else if (shield.Size == CaelumConstants.EQUIPMENT_SIZE_L) sizeMultiplier = 1.25;
        else if (shield.Size == CaelumConstants.EQUIPMENT_SIZE_XL) sizeMultiplier = 1.50;
        return Max(1, int(baseDurability * multiplier * sizeMultiplier + 0.5));
    }

    ui int GetShieldCoverageForPanel(CaelumShieldModel shield)
    {
        if (!shield.Equipped) { return 0; }
        if (shield.ShieldType == CaelumConstants.SHIELD_TYPE_KITE) { return 140; }
        if (shield.ShieldType == CaelumConstants.SHIELD_TYPE_TOWER) { return 160; }
        return 120;
    }

    ui int GetShieldDefenseForPanel(CaelumShieldModel shield, int damageKind)
    {
        if (!shield.Equipped || shield.Durability <= 0) { return 0; }
        int physicalDefense = 50;
        switch (shield.ShieldType)
        {
            case CaelumConstants.SHIELD_TYPE_BUCKLER: physicalDefense = 60; break;
            case CaelumConstants.SHIELD_TYPE_KITE: physicalDefense = 80; break;
            case CaelumConstants.SHIELD_TYPE_TOWER: physicalDefense = 90; break;
        }
        int defense = physicalDefense;
        if (damageKind == CaelumConstants.SHIELD_DAMAGE_MAGICAL
            && shield.ShieldType == CaelumConstants.SHIELD_TYPE_MAGIC)
        {
            defense = 90;
        }
        int tierOffset = (Clamp(shield.Tier, 1, 3) - 2) * 10;
        return Max(0, defense + tierOffset);
    }

    // OnRegister runs once when GZDoom registers this event handler.
    override void OnRegister()
    {
        DebugFont = Font.GetFont("SmallFont");
    }

    // Confirmed enemy kills reward the player responsible. An allied death
    // rewards every living friendly player within the documented ten meters.
    override void WorldThingDied(WorldEvent e)
    {
        Actor dead = e.Thing;
        if (dead == null)
        {
            return;
        }

        // A Doom monster keeps the player it was fighting in Target. This is
        // the reliable owner for ordinary player kills, including LineAttack.
        // Inflictor remains a fallback for actors without a combat target.
        Actor killOwner = GetRecordedDamageOwner(dead);
        if (killOwner == null)
        {
            killOwner = dead.Target;
        }
        if (killOwner == null)
        {
            killOwner = ResolvePlayerDamageOwner(e.Inflictor);
        }
        if (killOwner != null && killOwner.player == null && killOwner.Target != null)
        {
            killOwner = killOwner.Target;
        }
        CaelumPlayer killer = CaelumPlayer(killOwner);
        if (killer != null
            && dead.bIsMonster
            && !dead.IsFriend(killer))
        {
            killer.GrantEnemyKillAdrenaline();
        }

        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex]) { continue; }
            CaelumPlayer recipient = CaelumPlayer(players[playerIndex].mo);
            if (recipient == null
                || recipient == dead
                || recipient.health <= 0
                || !dead.IsFriend(recipient))
            {
                continue;
            }

            double distance = recipient.Distance3D(dead);
            if (distance <= CaelumConstants.ALLY_DEATH_ADRENALINE_RANGE)
            {
                recipient.GrantNearbyAllyDeathAdrenaline();
            }
        }

        ForgetRecordedDamageOwner(dead);
    }

    // DrawAttribute prints one localized attribute label and its current value.
    // The virtual 640x360 coordinate system keeps the layout consistent across
    // different screen resolutions and aspect ratios.
    ui void DrawAttribute(String languageKey, int value, double x, double y)
    {
        String label = StringTable.Localize(languageKey, false);
        String line = String.Format("%s: %d", label, value);

        Screen.DrawText(
            DebugFont,
            Font.CR_WHITE,
            x,
            y,
            line,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );
    }

    // Convierte las selecciones guardadas en claves localizadas.
    ui String GetRaceKey(int race)
    {
        switch (race)
        {
            case CaelumConstants.RACE_BEAST_MAN: return "CA_RACE_BEAST_MAN";
            case CaelumConstants.RACE_CAELITH: return "CA_RACE_CAELITH";
            case CaelumConstants.RACE_HUMAN: return "CA_RACE_HUMAN";
            case CaelumConstants.RACE_DEBUG: return "CA_RACE_DEBUG";
            default: return "CA_RACE_GOBLIN";
        }
    }

    ui String GetClassKey(int characterClass)
    {
        switch (characterClass)
        {
            case CaelumConstants.CLASS_WARRIOR: return "CA_CLASS_WARRIOR";
            case CaelumConstants.CLASS_EXPLORER: return "CA_CLASS_EXPLORER";
            case CaelumConstants.CLASS_PRIEST: return "CA_CLASS_PRIEST";
            default: return "CA_CLASS_MAGE";
        }
    }

    ui String GetProfessionKey(int firstClass, int secondClass)
    {
        int lowClass = Min(firstClass, secondClass);
        int highClass = Max(firstClass, secondClass);
        if (lowClass == highClass) return GetClassKey(lowClass);
        if (lowClass == 0 && highClass == 1) return "CA_PROFESSION_MERCENARY";
        if (lowClass == 0 && highClass == 2) return "CA_PROFESSION_CLERIC";
        if (lowClass == 0 && highClass == 3) return "CA_PROFESSION_BATTLE_MAGE";
        if (lowClass == 1 && highClass == 2) return "CA_PROFESSION_PILGRIM";
        if (lowClass == 1 && highClass == 3) return "CA_PROFESSION_INVESTIGATOR";
        return "CA_PROFESSION_ARCANIST";
    }

    ui String GetSexKey(int sex)
    {
        return sex == CaelumConstants.SEX_FEMALE ? "CA_SEX_FEMALE" : "CA_SEX_MALE";
    }

    ui String GetHeightChoiceKey(int heightChoice)
    {
        if (heightChoice == CaelumConstants.HEIGHT_SHORT) return "CA_HEIGHT_SHORT";
        if (heightChoice == CaelumConstants.HEIGHT_TALL) return "CA_HEIGHT_TALL";
        return "CA_HEIGHT_NORMAL";
    }

    ui String GetLayerKey(int layer)
    {
        switch (layer)
        {
            case CaelumConstants.LAYER_PHYSICAL: return "CA_LAYER_PHYSICAL";
            case CaelumConstants.LAYER_TECHNICAL: return "CA_LAYER_TECHNICAL";
            case CaelumConstants.LAYER_SOCIAL: return "CA_LAYER_SOCIAL";
            default: return "CA_LAYER_MENTAL";
        }
    }

    ui String GetAttributeKey(int attributeIndex)
    {
        switch (attributeIndex)
        {
            case CaelumConstants.ATTRIBUTE_STRENGTH: return "CA_ATTRIBUTE_STRENGTH";
            case CaelumConstants.ATTRIBUTE_TOUGHNESS: return "CA_ATTRIBUTE_TOUGHNESS";
            case CaelumConstants.ATTRIBUTE_CONSTITUTION: return "CA_ATTRIBUTE_CONSTITUTION";
            case CaelumConstants.ATTRIBUTE_DEXTERITY: return "CA_ATTRIBUTE_DEXTERITY";
            case CaelumConstants.ATTRIBUTE_RESILIENCE: return "CA_ATTRIBUTE_RESILIENCE";
            case CaelumConstants.ATTRIBUTE_AGILITY: return "CA_ATTRIBUTE_AGILITY";
            case CaelumConstants.ATTRIBUTE_CHARISMA: return "CA_ATTRIBUTE_CHARISMA";
            case CaelumConstants.ATTRIBUTE_EMPATHY: return "CA_ATTRIBUTE_EMPATHY";
            case CaelumConstants.ATTRIBUTE_ELOQUENCE: return "CA_ATTRIBUTE_ELOQUENCE";
            case CaelumConstants.ATTRIBUTE_INTELLIGENCE: return "CA_ATTRIBUTE_INTELLIGENCE";
            case CaelumConstants.ATTRIBUTE_PATIENCE: return "CA_ATTRIBUTE_PATIENCE";
            default: return "CA_ATTRIBUTE_INSIGHT";
        }
    }

    ui void DrawCenteredText(String text, double y, int color)
    {
        double textWidth = DebugFont.StringWidth(text);
        double x = 320.0 - (textWidth * 0.5);

        Screen.DrawText(
            DebugFont, color, x, y, text,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );
    }

    // Dibuja las ocho paginas del creador de personajes 4.0.
    ui void DrawCreationWizard(CaelumPlayer localPlayer)
    {
        CaelumCharacterProfile profile = localPlayer.CharacterProfile;
        CaelumCharacterAllocation allocation = localPlayer.CharacterAllocation;
        if (profile == null || allocation == null)
        {
            return;
        }

        String pageTitle;
        String selectedValue;
        String explanation;

        switch (localPlayer.CreationWizardPage)
        {
            case CaelumConstants.CREATION_PAGE_RACE:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_RACE", false);
                selectedValue = StringTable.Localize(GetRaceKey(profile.Race), false);
                explanation = StringTable.Localize("CA_CREATION_HELP_RACE", false);
                break;

            case CaelumConstants.CREATION_PAGE_FIRST_CLASS:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_FIRST_CLASS", false);
                selectedValue = StringTable.Localize(GetClassKey(profile.FirstClass), false);
                explanation = StringTable.Localize("CA_CREATION_HELP_FIRST_CLASS", false);
                break;

            case CaelumConstants.CREATION_PAGE_SECOND_CLASS:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_SECOND_CLASS", false);
                selectedValue = String.Format("%s -> %s",
                    StringTable.Localize(GetClassKey(profile.SecondClass), false),
                    StringTable.Localize(GetProfessionKey(profile.FirstClass, profile.SecondClass), false));
                explanation = StringTable.Localize("CA_CREATION_HELP_SECOND_CLASS", false);
                break;

            case CaelumConstants.CREATION_PAGE_SEX:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_SEX", false);
                selectedValue = StringTable.Localize(GetSexKey(profile.Sex), false);
                explanation = StringTable.Localize("CA_CREATION_HELP_SEX", false);
                break;

            case CaelumConstants.CREATION_PAGE_HEIGHT:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_HEIGHT", false);
                selectedValue = StringTable.Localize(GetHeightChoiceKey(profile.HeightChoice), false);
                explanation = StringTable.Localize("CA_CREATION_HELP_HEIGHT", false);
                break;

            case CaelumConstants.CREATION_PAGE_LAYERS:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_LAYERS", false);
                selectedValue = String.Format(
                    "%s: %s   |   %s: %d",
                    StringTable.Localize("CA_CREATION_SELECTED_LAYER", false),
                    StringTable.Localize(GetLayerKey(allocation.SelectedLayer), false),
                    StringTable.Localize("CA_CREATION_POINTS_LEFT", false),
                    allocation.GetRemainingLayerPoints()
                );
                explanation = StringTable.Localize("CA_CREATION_HELP_LAYERS", false);
                break;

            case CaelumConstants.CREATION_PAGE_ATTRIBUTES:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_ATTRIBUTES", false);
                selectedValue = String.Format(
                    "%s: %s (+%d)   |   %s: %d",
                    StringTable.Localize("CA_CREATION_SELECTED_ATTRIBUTE", false),
                    StringTable.Localize(GetAttributeKey(allocation.SelectedAttribute), false),
                    allocation.AttributeBonus[allocation.SelectedAttribute],
                    StringTable.Localize("CA_CREATION_POINTS_LEFT", false),
                    allocation.GetRemainingAttributePoints()
                );
                explanation = StringTable.Localize("CA_CREATION_HELP_ATTRIBUTES", false);
                break;

            default:
                pageTitle = StringTable.Localize("CA_CREATION_TITLE_SUMMARY", false);
                if (profile.Race == CaelumConstants.RACE_DEBUG)
                {
                    selectedValue = StringTable.Localize(
                        "CA_CREATION_DEBUG_SUMMARY", false
                    );
                }
                else
                {
                    selectedValue = String.Format(
                        "%s / %s / %s / %s",
                        StringTable.Localize(GetRaceKey(profile.Race), false),
                        StringTable.Localize(GetProfessionKey(profile.FirstClass, profile.SecondClass), false),
                        StringTable.Localize(GetSexKey(profile.Sex), false),
                        StringTable.Localize(GetHeightChoiceKey(profile.HeightChoice), false)
                    );
                }
                explanation = StringTable.Localize("CA_CREATION_HELP_SUMMARY", false);
                break;
        }

        DrawCenteredText(StringTable.Localize("CA_CREATION_MAIN_TITLE", false), 72.0, Font.CR_GOLD);
        DrawCenteredText(pageTitle, 104.0, Font.CR_WHITE);
        DrawCenteredText(selectedValue, 142.0, Font.CR_GREEN);
        DrawCenteredText(explanation, 176.0, Font.CR_GRAY);
        String navigationKey = "CA_CREATION_NAVIGATION_HELP";

        if (localPlayer.CreationWizardPage == CaelumConstants.CREATION_PAGE_LAYERS
            || localPlayer.CreationWizardPage == CaelumConstants.CREATION_PAGE_ATTRIBUTES)
        {
            navigationKey = "CA_CREATION_ALLOCATION_NAVIGATION_HELP";
        }
        else if (localPlayer.CreationWizardPage == CaelumConstants.CREATION_PAGE_SUMMARY)
        {
            navigationKey = "CA_CREATION_SUMMARY_NAVIGATION_HELP";
        }

        DrawCenteredText(StringTable.Localize(navigationKey, false), 226.0, Font.CR_WHITE);

        String pageNumber = String.Format(
            "%d / 8",
            localPlayer.CreationWizardPage + 1
        );
        DrawCenteredText(pageNumber, 252.0, Font.CR_GRAY);
    }

    ui String GetMaterialSelectionIcon(int materialType)
    {
        switch (materialType)
        {
            case CaelumConstants.MATERIAL_IRON_INGOT: return "graphics/caelum/icons/materials/ca_material_iron_ingot.png";
            case CaelumConstants.MATERIAL_BLADE: return "graphics/caelum/icons/materials/ca_material_blade.png";
            case CaelumConstants.MATERIAL_SMALL_BLADE: return "graphics/caelum/icons/materials/ca_material_small_blade.png";
            case CaelumConstants.MATERIAL_CURVED_BLADE: return "graphics/caelum/icons/materials/ca_material_curved_blade.png";
            case CaelumConstants.MATERIAL_LONG_BLADE: return "graphics/caelum/icons/materials/ca_material_long_blade.png";
            case CaelumConstants.MATERIAL_BROAD_BLADE: return "graphics/caelum/icons/materials/ca_material_broad_blade.png";
            case CaelumConstants.MATERIAL_SHAFT: return "graphics/caelum/icons/materials/ca_material_shaft.png";
            case CaelumConstants.MATERIAL_FRAME: return "graphics/caelum/icons/materials/ca_material_frame.png";
            case CaelumConstants.MATERIAL_LONG_FRAME: return "graphics/caelum/icons/materials/ca_material_long_frame.png";
            case CaelumConstants.MATERIAL_WEAPON_HEAD: return "graphics/caelum/icons/materials/ca_material_weapon_head.png";
            case CaelumConstants.MATERIAL_ROUND_HEAD: return "graphics/caelum/icons/materials/ca_material_round_head.png";
            case CaelumConstants.MATERIAL_PLATE: return "graphics/caelum/icons/materials/ca_material_plate.png";
            case CaelumConstants.MATERIAL_ROUND_PLATE: return "graphics/caelum/icons/materials/ca_material_round_plate.png";
            case CaelumConstants.MATERIAL_KITE_PLATE: return "graphics/caelum/icons/materials/ca_material_kite_plate.png";
            case CaelumConstants.MATERIAL_TOWER_PLATE: return "graphics/caelum/icons/materials/ca_material_tower_plate.png";
            case CaelumConstants.MATERIAL_MAGIC_PLATE: return "graphics/caelum/icons/materials/ca_material_magic_plate.png";
            case CaelumConstants.MATERIAL_LARGE_PLATE: return "graphics/caelum/icons/materials/ca_material_large_plate.png";
            case CaelumConstants.MATERIAL_CHAINMAIL: return "graphics/caelum/icons/materials/ca_material_chainmail.png";
            case CaelumConstants.MATERIAL_FABRIC: return "graphics/caelum/icons/materials/ca_material_fabric.png";
            case CaelumConstants.MATERIAL_LEATHER: return "graphics/caelum/icons/materials/ca_material_leather.png";
            case CaelumConstants.MATERIAL_FIRE_ESSENCE: return "graphics/caelum/icons/materials/ca_material_fire_essence.png";
            case CaelumConstants.MATERIAL_WATER_ESSENCE: return "graphics/caelum/icons/materials/ca_material_water_essence.png";
            case CaelumConstants.MATERIAL_EARTH_ESSENCE: return "graphics/caelum/icons/materials/ca_material_earth_essence.png";
            case CaelumConstants.MATERIAL_WIND_ESSENCE: return "graphics/caelum/icons/materials/ca_material_wind_essence.png";
            case CaelumConstants.MATERIAL_QUINTESSENCE: return "graphics/caelum/icons/materials/ca_material_quintessence.png";
            case CaelumConstants.MATERIAL_HILT: return "graphics/caelum/icons/materials/ca_material_hilt.png";
            case CaelumConstants.MATERIAL_LONG_HILT: return "graphics/caelum/icons/materials/ca_material_long_hilt.png";
            case CaelumConstants.MATERIAL_POINT: return "graphics/caelum/icons/materials/ca_material_point.png";
            case CaelumConstants.MATERIAL_HANDLE: return "graphics/caelum/icons/materials/ca_material_handle.png";
            case CaelumConstants.MATERIAL_LONG_HANDLE: return "graphics/caelum/icons/materials/ca_material_long_handle.png";
            case CaelumConstants.MATERIAL_BOWSTRING: return "graphics/caelum/icons/materials/ca_material_bowstring.png";
            case CaelumConstants.MATERIAL_REINFORCED_BOWSTRING: return "graphics/caelum/icons/materials/ca_material_reinforced_bowstring.png";
            case CaelumConstants.MATERIAL_STRAP: return "graphics/caelum/icons/materials/ca_material_strap.png";
            case CaelumConstants.MATERIAL_REINFORCED_STRAP: return "graphics/caelum/icons/materials/ca_material_reinforced_strap.png";
            case CaelumConstants.MATERIAL_BARREL: return "graphics/caelum/icons/materials/ca_material_barrel.png";
            case CaelumConstants.MATERIAL_MECHANISM: return "graphics/caelum/icons/materials/ca_material_mechanism.png";
            case CaelumConstants.MATERIAL_STAFF_BASE: return "graphics/caelum/icons/ca_staff.png";
            case CaelumConstants.MATERIAL_BELL_BASE: return "graphics/caelum/icons/ca_bell.png";
            case CaelumConstants.MATERIAL_BOOK_BASE: return "graphics/caelum/icons/ca_book.png";
            case CaelumConstants.MATERIAL_STATUETTE_BASE: return "graphics/caelum/icons/ca_statuette.png";
            case CaelumConstants.MATERIAL_SMALL_WEAPON_HEAD: return "graphics/caelum/icons/materials/ca_material_small_weapon_head.png";
            case CaelumConstants.MATERIAL_CHAIN: return "graphics/caelum/icons/materials/ca_material_chain.png";
            case CaelumConstants.MATERIAL_WOOD: return "graphics/caelum/icons/materials/ca_material_wood.png";
            case CaelumConstants.MATERIAL_SILVER_CHAIN: return "graphics/caelum/icons/materials/ca_material_silver_chain.png";
            case CaelumConstants.MATERIAL_SEAL_BASE: return "graphics/caelum/icons/materials/ca_material_seal_base.png";
            case CaelumConstants.MATERIAL_RUBY_PENDANT: return "graphics/caelum/icons/materials/ca_material_ruby_pendant.png";
            case CaelumConstants.MATERIAL_SAPPHIRE_PENDANT: return "graphics/caelum/icons/materials/ca_material_sapphire_pendant.png";
            case CaelumConstants.MATERIAL_EMERALD_PENDANT: return "graphics/caelum/icons/materials/ca_material_emerald_pendant.png";
            case CaelumConstants.MATERIAL_TOPAZ_PENDANT: return "graphics/caelum/icons/materials/ca_material_topaz_pendant.png";
            case CaelumConstants.MATERIAL_RUBY_GEM: return "graphics/caelum/icons/materials/ca_material_ruby_gem.png";
            case CaelumConstants.MATERIAL_SAPPHIRE_GEM: return "graphics/caelum/icons/materials/ca_material_sapphire_gem.png";
            case CaelumConstants.MATERIAL_EMERALD_GEM: return "graphics/caelum/icons/materials/ca_material_emerald_gem.png";
            case CaelumConstants.MATERIAL_TOPAZ_GEM: return "graphics/caelum/icons/materials/ca_material_topaz_gem.png";
            case CaelumConstants.MATERIAL_OPAL_BROOCH: return "graphics/caelum/icons/materials/ca_material_opal_brooch.png";
            case CaelumConstants.MATERIAL_RAW_RUBY: return "graphics/caelum/icons/materials/ca_material_raw_ruby.png";
            case CaelumConstants.MATERIAL_RAW_SAPPHIRE: return "graphics/caelum/icons/materials/ca_material_raw_sapphire.png";
            case CaelumConstants.MATERIAL_RAW_EMERALD: return "graphics/caelum/icons/materials/ca_material_raw_emerald.png";
            case CaelumConstants.MATERIAL_RAW_TOPAZ: return "graphics/caelum/icons/materials/ca_material_raw_topaz.png";
            case CaelumConstants.MATERIAL_RAW_OPAL: return "graphics/caelum/icons/materials/ca_material_raw_opal.png";
            case CaelumConstants.MATERIAL_COPPER_INGOT: return "graphics/caelum/icons/materials/ca_material_copper_ingot.png";
            case CaelumConstants.MATERIAL_TIN_INGOT: return "graphics/caelum/icons/materials/ca_material_tin_ingot.png";
            case CaelumConstants.MATERIAL_COAL: return "graphics/caelum/icons/materials/ca_material_coal.png";
            default: return "graphics/caelum/icons/materials/ca_material_iron_ingot.png";
        }
    }

    ui String GetEssenceBadgeIcon(int essenceType)
    {
        switch (essenceType)
        {
            case CaelumConstants.ESSENCE_WATER: return "graphics/caelum/icons/elements/ca_element_water.png";
            case CaelumConstants.ESSENCE_EARTH: return "graphics/caelum/icons/elements/ca_element_earth.png";
            case CaelumConstants.ESSENCE_WIND: return "graphics/caelum/icons/elements/ca_element_wind.png";
            case CaelumConstants.ESSENCE_QUINTESSENCE: return "graphics/caelum/icons/elements/ca_element_quintessence.png";
            default: return "graphics/caelum/icons/elements/ca_element_fire.png";
        }
    }

    // Devuelve el icono independiente asociado al objeto seleccionado.
    // Los iconos proceden del atlas propio de Caelum Argenteum y no usan
    // recursos gráficos de Doom.
    ui String GetEquipmentSelectionIcon(CaelumPlayer localPlayer)
    {
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            switch (localPlayer.EquipmentSelectionWeaponType)
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
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            switch (localPlayer.EquipmentSelectionShieldType)
            {
                case CaelumConstants.SHIELD_TYPE_BUCKLER: return "graphics/caelum/icons/ca_shield_buckler.png";
                case CaelumConstants.SHIELD_TYPE_KITE: return "graphics/caelum/icons/ca_shield_kite.png";
                case CaelumConstants.SHIELD_TYPE_TOWER: return "graphics/caelum/icons/ca_shield_tower.png";
                default: return "graphics/caelum/icons/ca_shield_magic.png";
            }
        }
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_ARMOR)
        {
            int slot = localPlayer.EquipmentSelectionSlot;
            int armorType = localPlayer.EquipmentSelectionArmorType;
            if (armorType == CaelumConstants.ARMOR_TYPE_MAGIC)
            {
                if (slot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet_magic.png";
                if (slot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves.png";
                if (slot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots.png";
                return "graphics/caelum/icons/ca_armor_magic.png";
            }
            if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM)
            {
                if (slot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet_medium.png";
                if (slot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves_medium.png";
                if (slot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots_medium.png";
                return "graphics/caelum/icons/ca_armor_medium.png";
            }
            if (armorType == CaelumConstants.ARMOR_TYPE_HEAVY)
            {
                if (slot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet.png";
                if (slot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves_heavy.png";
                if (slot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots_heavy.png";
                return "graphics/caelum/icons/ca_armor_heavy.png";
            }
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD) return "graphics/caelum/icons/ca_helmet_light.png";
            if (slot == CaelumConstants.ARMOR_SLOT_HANDS) return "graphics/caelum/icons/ca_gloves_light.png";
            if (slot == CaelumConstants.ARMOR_SLOT_FEET) return "graphics/caelum/icons/ca_boots_light.png";
            return "graphics/caelum/icons/ca_armor_light.png";
        }
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            if (localPlayer.EquipmentSelectionAmuletType == CaelumConstants.AMULET_SAPPHIRE)
                return "graphics/caelum/icons/jewelry/ca_amulet_sapphire.png";
            if (localPlayer.EquipmentSelectionAmuletType == CaelumConstants.AMULET_EMERALD)
                return "graphics/caelum/icons/jewelry/ca_amulet_emerald.png";
            if (localPlayer.EquipmentSelectionAmuletType == CaelumConstants.AMULET_TOPAZ)
                return "graphics/caelum/icons/jewelry/ca_amulet_topaz.png";
            return "graphics/caelum/icons/jewelry/ca_amulet_ruby.png";
        }
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            if (localPlayer.EquipmentSelectionSealType == CaelumConstants.SEAL_WATER)
                return "graphics/caelum/icons/jewelry/ca_seal_water.png";
            if (localPlayer.EquipmentSelectionSealType == CaelumConstants.SEAL_EARTH)
                return "graphics/caelum/icons/jewelry/ca_seal_earth.png";
            if (localPlayer.EquipmentSelectionSealType == CaelumConstants.SEAL_AIR)
                return "graphics/caelum/icons/jewelry/ca_seal_air.png";
            if (localPlayer.EquipmentSelectionSealType == CaelumConstants.SEAL_QUINTESSENCE)
                return "graphics/caelum/icons/jewelry/ca_seal_quintessence.png";
            return "graphics/caelum/icons/jewelry/ca_seal_fire.png";
        }
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            switch (localPlayer.EquipmentSelectionAmmunitionType)
            {
                case CaelumConstants.AMMUNITION_CARBINE: return "graphics/caelum/icons/ca_carbine_ammo.png";
                case CaelumConstants.AMMUNITION_ARROW: return "graphics/caelum/icons/ca_arrow_ammo.png";
                case CaelumConstants.AMMUNITION_BOLT: return "graphics/caelum/icons/ca_bolt_ammo.png";
                default: return "graphics/caelum/icons/ca_javelin.png";
            }
        }
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            switch (localPlayer.EquipmentSelectionConsumableType)
            {
                case CaelumConstants.CONSUMABLE_LIFE_POTION: return "graphics/caelum/icons/ca_medikit.png";
                case CaelumConstants.CONSUMABLE_ANIMA_POTION: return "graphics/caelum/icons/ca_anima_potion.png";
                case CaelumConstants.CONSUMABLE_ENERGY_DRINK: return "graphics/caelum/icons/ca_energy_drink.png";
                case CaelumConstants.CONSUMABLE_FOOD_RATION: return "graphics/caelum/icons/ca_food_ration.png";
                default: return "graphics/caelum/icons/ca_water_ration.png";
            }
        }
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
            return GetMaterialSelectionIcon(localPlayer.EquipmentSelectionSpecialType);
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY)
            return "graphics/caelum/icons/ca_key.png";
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
            return "graphics/caelum/icons/ca_sealed_letter.png";
        return "";
    }

    ui void DrawEquipmentSelectionIcon(CaelumPlayer localPlayer)
    {
        String iconPath = GetEquipmentSelectionIcon(localPlayer);
        if (iconPath.Length() <= 0) { return; }
        TextureID icon = TexMan.CheckForTexture(iconPath, TexMan.Type_MiscPatch);
        if (!icon.IsValid()) { return; }
        bool jewelryIcon =
            localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMULET
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_SEAL;
        if (jewelryIcon)
        {
            Screen.DrawTexture(
                icon, true, 34.0, 112.0,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_DESTWIDTHF, 48.0,
                DTA_DESTHEIGHTF, 48.0,
                DTA_KEEPRATIO, true
            );
        }
        else
        {
            Screen.DrawTexture(
                icon, true, 34.0, 112.0,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true
            );
        }

        // Las armas de esencia reutilizan el icono del objeto base y agregan
        // un orbe pequeño en la esquina superior derecha. Así evitamos crear
        // veinte imágenes duplicadas para las combinaciones arma + esencia.
        bool magicalWeapon = localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && localPlayer.WeaponModel != null
            && localPlayer.WeaponModel.IsMagicalType(
                localPlayer.EquipmentSelectionWeaponType
            );
        if (magicalWeapon)
        {
            TextureID badge = TexMan.CheckForTexture(
                GetEssenceBadgeIcon(localPlayer.SelectedEssenceType),
                TexMan.Type_MiscPatch
            );
            if (badge.IsValid())
            {
                Screen.DrawTexture(
                    badge, true, 76.0, 108.0,
                    DTA_VIRTUALWIDTHF, 640.0,
                    DTA_VIRTUALHEIGHTF, 360.0,
                    DTA_DESTWIDTHF, 20.0,
                    DTA_DESTHEIGHTF, 20.0,
                    DTA_KEEPRATIO, true
                );
            }
        }
    }

    ui void DrawEquipmentMenu(CaelumPlayer localPlayer)
    {
        String categoryKey = "CA_EQUIPMENT_CATEGORY_ARMOR";
        if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_WEAPON";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_SHIELD";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_AMMUNITION";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_CONSUMABLE";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_MATERIAL";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_KEY)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_KEY";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_KEY_ITEM";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_AMULET";
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            categoryKey = "CA_EQUIPMENT_CATEGORY_SEAL";
        }
        String category = StringTable.Localize(categoryKey, false);
        String selection;
        if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_MATERIAL)
        {
            String materialName = StringTable.Localize(
                GetSpecialItemTypeKey(
                    localPlayer.EquipmentSelectionKind,
                    localPlayer.EquipmentSelectionSpecialType
                ), false
            );
            String gradeKey = GetMaterialGradeKey(
                localPlayer.EquipmentSelectionSpecialType,
                localPlayer.EquipmentSelectionTier
            );
            int materialFamily = GetMaterialFamilyForPanel(
                localPlayer.EquipmentSelectionSpecialType
            );
            if (materialFamily == CaelumConstants.MATERIAL_FAMILY_GEM)
            {
                String grade = StringTable.Localize(gradeKey, false);
                selection = localPlayer.EquipmentSelectionTier == 1
                    ? String.Format(
                        "%s x%d", materialName,
                        localPlayer.EquipmentSelectionStackAmount
                    )
                    : String.Format(
                        "%s %s x%d", materialName, grade,
                        localPlayer.EquipmentSelectionStackAmount
                    );
            }
            else if (materialFamily != CaelumConstants.MATERIAL_FAMILY_NONE)
            {
                selection = String.Format(
                    "%s [%s] x%d", materialName,
                    StringTable.Localize(gradeKey, false),
                    localPlayer.EquipmentSelectionStackAmount
                );
            }
            else
            {
                selection = String.Format(
                    "%s x%d", materialName,
                    localPlayer.EquipmentSelectionStackAmount
                );
            }
        }
        else if (localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            selection = String.Format(
                "%s x%d",
                StringTable.Localize(
                    GetSpecialItemTypeKey(
                        localPlayer.EquipmentSelectionKind,
                        localPlayer.EquipmentSelectionSpecialType
                    ),
                    false
                ),
                localPlayer.EquipmentSelectionStackAmount
            );
        }
        else if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_AMULET)
        {
            selection = String.Format("%s T%d",
                StringTable.Localize(GetAmuletTypeKey(localPlayer.EquipmentSelectionAmuletType), false),
                localPlayer.EquipmentSelectionTier);
        }
        else if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            selection = String.Format("%s T%d",
                StringTable.Localize(GetSealTypeKey(localPlayer.EquipmentSelectionSealType), false),
                localPlayer.EquipmentSelectionTier);
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_AMMUNITION)
        {
            selection = String.Format(
                "%s x%d",
                StringTable.Localize(
                    GetAmmunitionTypeKey(
                        localPlayer.EquipmentSelectionAmmunitionType
                    ),
                    false
                ),
                localPlayer.EquipmentSelectionStackAmount
            );
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE)
        {
            selection = String.Format(
                "%s x%d",
                StringTable.Localize(
                    GetConsumableTypeKey(
                        localPlayer.EquipmentSelectionConsumableType
                    ),
                    false
                ),
                localPlayer.EquipmentSelectionStackAmount
            );
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            if (localPlayer.EquipmentSelectionWeaponType
                    == CaelumConstants.WEAPON_TYPE_STAFF
                || localPlayer.EquipmentSelectionWeaponType
                    == CaelumConstants.WEAPON_TYPE_BELL
                || localPlayer.EquipmentSelectionWeaponType
                    == CaelumConstants.WEAPON_TYPE_BOOK
                || localPlayer.EquipmentSelectionWeaponType
                    == CaelumConstants.WEAPON_TYPE_STATUETTE)
            {
                selection = String.Format(
                    "%s / %s T%d %s / %s",
                    StringTable.Localize("CA_WEAPON_HAND_MAIN", false),
                    StringTable.Localize(
                        GetWeaponTypeKey(
                            localPlayer.EquipmentSelectionWeaponType
                        ), false
                    ),
                    localPlayer.EquipmentSelectionTier,
                    StringTable.Localize(
                        GetEquipmentSizeKey(
                            localPlayer.EquipmentSelectionSize
                        ), false
                    ),
                    StringTable.Localize(
                        GetEssenceTypeKey(localPlayer.SelectedEssenceType),
                        false
                    )
                );
            }
            else
            {
                selection = String.Format(
                    "%s / %s T%d %s",
                    StringTable.Localize("CA_WEAPON_HAND_MAIN", false),
                    StringTable.Localize(
                        GetWeaponTypeKey(
                            localPlayer.EquipmentSelectionWeaponType
                        ), false
                    ),
                    localPlayer.EquipmentSelectionTier,
                    StringTable.Localize(
                        GetEquipmentSizeKey(
                            localPlayer.EquipmentSelectionSize
                        ), false
                    )
                );
            }
        }
        else if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_SHIELD)
        {
            selection = String.Format(
                "%s T%d %s",
                StringTable.Localize(
                    GetShieldTypeKey(localPlayer.EquipmentSelectionShieldType),
                    false
                ),
                localPlayer.EquipmentSelectionTier,
                StringTable.Localize(
                    GetEquipmentSizeKey(localPlayer.EquipmentSelectionSize), false
                )
            );
        }
        else
        {
            selection = String.Format(
                "%s / %s T%d %s",
                StringTable.Localize(
                    GetArmorSlotKey(localPlayer.EquipmentSelectionSlot),
                    false
                ),
                StringTable.Localize(
                    GetArmorTypeKey(localPlayer.EquipmentSelectionArmorType),
                    false
                ),
                localPlayer.EquipmentSelectionTier,
                StringTable.Localize(
                    GetEquipmentSizeKey(localPlayer.EquipmentSelectionSize), false
                )
            );
        }

        String ownershipKey = localPlayer.EquipmentSelectionOwned
            ? "CA_EQUIPMENT_OWNED" : "CA_EQUIPMENT_NOT_OWNED";
        String equippedKey = localPlayer.EquipmentSelectionEquipped
            ? "CA_EQUIPMENT_EQUIPPED" : "CA_EQUIPMENT_NOT_EQUIPPED";
        String storageKey = "CA_EQUIPMENT_STORAGE_NONE";
        if (localPlayer.EquipmentSelectionEquipped)
        {
            storageKey = "CA_EQUIPMENT_STORAGE_EQUIPPED";
        }
        else if (localPlayer.EquipmentSelectionInMagicBox)
        {
            storageKey = "CA_EQUIPMENT_STORAGE_MAGIC_BOX";
        }
        else if (localPlayer.EquipmentSelectionOwned)
        {
            storageKey = "CA_EQUIPMENT_STORAGE_INVENTORY";
        }
        String status;
        if (localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_ARMOR
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_SHIELD
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_WEAPON
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMULET
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            status = String.Format(
                "%s | %s | %s",
                StringTable.Localize(ownershipKey, false),
                StringTable.Localize(equippedKey, false),
                StringTable.Localize(storageKey, false)
            );
        }
        else
        {
            status = String.Format(
                "%s | %s",
                StringTable.Localize(ownershipKey, false),
                StringTable.Localize(storageKey, false)
            );
        }
        String detail;
        if (localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMMUNITION
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_CONSUMABLE
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_MATERIAL
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_KEY_ITEM)
        {
            detail = String.Format(
                "%s %d | %s %.3f",
                StringTable.Localize("CA_EQUIPMENT_STACK_AMOUNT", false),
                localPlayer.EquipmentSelectionStackAmount,
                StringTable.Localize("CA_EQUIPMENT_STACK_WEIGHT", false),
                localPlayer.EquipmentSelectionWeight
            );
        }
        else if (localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_AMULET
            || localPlayer.EquipmentSelectionKind
                == CaelumConstants.EQUIPMENT_KIND_SEAL)
        {
            detail = String.Format(
                "Universal | %.3f",
                localPlayer.EquipmentSelectionWeight
            );
        }
        else
        {
            detail = String.Format(
                "%s | %s %d/%d | %.3f",
                StringTable.Localize(
                    localPlayer.EquipmentSelectionSizeCompatible
                        ? "CA_EQUIPMENT_SIZE_COMPATIBLE"
                        : "CA_EQUIPMENT_SIZE_INCOMPATIBLE",
                    false
                ),
                StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                localPlayer.EquipmentSelectionDurability,
                localPlayer.EquipmentSelectionMaximumDurability,
                localPlayer.EquipmentSelectionWeight
            );
        }
        String weaponDetail = "";
        if (localPlayer.EquipmentSelectionKind == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            weaponDetail = String.Format(
                "%s %.0f | %d t | %s %.0f | %s %.0f",
                StringTable.Localize("CA_WEAPON_DAMAGE", false),
                localPlayer.EquipmentSelectionDamage,
                localPlayer.EquipmentSelectionAttackTics,
                StringTable.Localize("CA_WEAPON_AIR_COST", false),
                localPlayer.EquipmentSelectionAirCost,
                StringTable.Localize("CA_WEAPON_ANIMA_COST", false),
                localPlayer.EquipmentSelectionAnimaCost
            );
            if (localPlayer.EquipmentSelectionWeaponType
                == CaelumConstants.WEAPON_TYPE_CARBINE)
            {
                weaponDetail = String.Format(
                    "%s | %s %d",
                    weaponDetail,
                    StringTable.Localize("CA_WEAPON_AMMO_CARTRIDGES", false),
                    localPlayer.CarbineAmmoCount
                );
            }
        }
        String loadBreakdown = String.Format(
            "%s %.3f + %s %.3f + %s %.3f = %s %.3f/%.3f",
            StringTable.Localize("CA_EQUIPMENT_LOAD_EQUIPPED", false),
            localPlayer.DerivedStats.EquippedWeight,
            StringTable.Localize("CA_EQUIPMENT_LOAD_INVENTORY", false),
            localPlayer.DerivedStats.InventoryWeight,
            StringTable.Localize("CA_EQUIPMENT_LOAD_TEST", false),
            localPlayer.DerivedStats.DebugWeight,
            StringTable.Localize("CA_HUD_LOAD", false),
            localPlayer.HUDCarriedWeight,
            localPlayer.HUDCarryCapacity
        );
        String totals = String.Format(
            "%s:%d %s:%d %s:%d   %s:%d %s:%d %s:%d/%d",
            StringTable.Localize("CA_EQUIPMENT_COUNT_ARMOR", false),
            localPlayer.OwnedArmorCount,
            StringTable.Localize("CA_EQUIPMENT_COUNT_SHIELD", false),
            localPlayer.OwnedShieldCount,
            StringTable.Localize("CA_EQUIPMENT_COUNT_WEAPON", false),
            localPlayer.OwnedWeaponCount,
            StringTable.Localize("CA_EQUIPMENT_INVENTORY", false),
            localPlayer.PersonalInventoryItemCount,
            StringTable.Localize("CA_EQUIPMENT_EQUIPPED_SLOTS", false),
            localPlayer.EquippedItemSlotCount,
            StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false),
            localPlayer.MagicBoxUsedSlots,
            localPlayer.MagicBoxMaximumSlots
        );
        String actionResult = StringTable.Localize(
            GetEquipmentActionKey(localPlayer.LastEquipmentAction), false
        );
        if (localPlayer.LastEquipmentAction
            == CaelumConstants.EQUIPMENT_ACTION_DISMANTLED)
        {
            actionResult = String.Format(
                "%s | %s x%d + %s x%d",
                actionResult,
                StringTable.Localize(
                    GetSpecialItemTypeKey(
                        CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                        localPlayer.LastDismantledBasicMaterialType
                    ),
                    false
                ),
                localPlayer.LastDismantledBasicUnits,
                StringTable.Localize(
                    GetSpecialItemTypeKey(
                        CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                        localPlayer.LastDismantledTierMaterialType
                    ),
                    false
                ),
                localPlayer.LastDismantledTierUnits
            );
        }
        int actionColor = Font.CR_GRAY;
        if ((localPlayer.LastEquipmentAction >= CaelumConstants.EQUIPMENT_ACTION_CREATED
                && localPlayer.LastEquipmentAction <= CaelumConstants.EQUIPMENT_ACTION_DROPPED)
            || localPlayer.LastEquipmentAction
                == CaelumConstants.EQUIPMENT_ACTION_CREATED_IN_MAGIC_BOX
            || localPlayer.LastEquipmentAction
                == CaelumConstants.EQUIPMENT_ACTION_STORED_IN_MAGIC_BOX
            || localPlayer.LastEquipmentAction
                == CaelumConstants.EQUIPMENT_ACTION_RETRIEVED_FROM_MAGIC_BOX
            || localPlayer.LastEquipmentAction
                == CaelumConstants.EQUIPMENT_ACTION_SPAWNED_ON_FLOOR
            || localPlayer.LastEquipmentAction
                == CaelumConstants.EQUIPMENT_ACTION_USED
            || localPlayer.LastEquipmentAction
                == CaelumConstants.EQUIPMENT_ACTION_DISMANTLED)
        {
            actionColor = Font.CR_GREEN;
        }
        else if (localPlayer.LastEquipmentAction
            >= CaelumConstants.EQUIPMENT_ACTION_FAILED_NOT_OWNED)
        {
            actionColor = Font.CR_RED;
        }

        DrawEquipmentSelectionIcon(localPlayer);
        DrawCenteredText(
            StringTable.Localize("CA_EQUIPMENT_MENU_TITLE", false),
            70.0,
            Font.CR_GOLD
        );
        DrawCenteredText(category, 104.0, Font.CR_WHITE);
        DrawCenteredText(selection, 136.0, Font.CR_GREEN);
        DrawCenteredText(status, 164.0,
            localPlayer.EquipmentSelectionOwned ? Font.CR_WHITE : Font.CR_RED);
        DrawCenteredText(detail, 188.0,
            localPlayer.EquipmentSelectionSizeCompatible ? Font.CR_WHITE : Font.CR_RED);
        if (localPlayer.EquipmentSelectionKind
            == CaelumConstants.EQUIPMENT_KIND_WEAPON)
        {
            DrawCenteredText(weaponDetail, 206.0, Font.CR_GOLD);
        }
        DrawCenteredText(loadBreakdown, 224.0, Font.CR_GOLD);
        DrawCenteredText(totals, 242.0, Font.CR_CYAN);
        DrawCenteredText(actionResult, 260.0, actionColor);
        DrawCenteredText(
            StringTable.Localize("CA_EQUIPMENT_NAVIGATION_HELP_1", false),
            280.0,
            Font.CR_GRAY
        );
        DrawCenteredText(
            StringTable.Localize("CA_EQUIPMENT_NAVIGATION_HELP_2", false),
            296.0,
            Font.CR_GRAY
        );
        DrawCenteredText(
            StringTable.Localize("CA_EQUIPMENT_NAVIGATION_HELP_3", false),
            312.0,
            Font.CR_GRAY
        );
    }

    ui void DrawCraftingMenu(CaelumPlayer localPlayer)
    {
        String recipeName;
        if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)
        {
            String armorTypeName = StringTable.Localize(
                GetArmorTypeKey(localPlayer.CraftingSelectedArmorType), false
            );
            String armorSlotName = StringTable.Localize(
                GetArmorSlotKey(localPlayer.CraftingSelectedArmorSlot), false
            );
            recipeName = String.Format(
                "%s - %s", armorTypeName, armorSlotName
            );
        }
        else if (localPlayer.CraftingSelectedRecipeKind
            == CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)
        {
            String magicWeaponName = StringTable.Localize(
                GetWeaponTypeKey(
                    localPlayer.CraftingSelectedEssenceWeaponType
                ),
                false
            );
            String essenceName = StringTable.Localize(
                GetEssenceTypeKey(
                    localPlayer.CraftingSelectedEssenceType
                ),
                false
            );
            recipeName = String.Format(
                "%s - %s", magicWeaponName, essenceName
            );
        }
        else if (localPlayer.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_AMULET)
            recipeName=StringTable.Localize(GetAmuletTypeKey(localPlayer.CraftingSelectedAmuletType),false);
        else if (localPlayer.CraftingSelectedRecipeKind == CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)
            recipeName=StringTable.Localize(GetSealTypeKey(localPlayer.CraftingSelectedSealType),false);
        else
        {
            recipeName = StringTable.Localize(
                GetCraftingWeaponKey(localPlayer.CraftingSelectedWeapon), false
            );
        }

        String sizeName = StringTable.Localize(
            GetEquipmentSizeKey(localPlayer.CraftingSelectionSize), false
        );
        String basicName = StringTable.Localize(
            GetSpecialItemTypeKey(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                localPlayer.CraftingBasicMaterialType
            ),
            false
        );
        String tierName = StringTable.Localize(
            GetSpecialItemTypeKey(
                CaelumConstants.EQUIPMENT_KIND_MATERIAL,
                localPlayer.CraftingTierMaterialType
            ),
            false
        );
        String tierGrade = StringTable.Localize(
            GetMaterialGradeKey(
                localPlayer.CraftingTierMaterialType,
                localPlayer.CraftingTierMaterialTier
            ),
            false
        );
        String selection = String.Format(
            "%s | T%d %s | %.3f",
            recipeName,
            localPlayer.CraftingSelectionTier,
            sizeName,
            localPlayer.CraftingFinalWeight
        );
        String basicLine = String.Format(
            "%s: %d / %d",
            basicName,
            localPlayer.CraftingBasicOwned,
            localPlayer.CraftingBasicRequired
        );
        String tierLine;
        if (GetMaterialFamilyForPanel(
                localPlayer.CraftingTierMaterialType
            ) == CaelumConstants.MATERIAL_FAMILY_GEM)
        {
            tierLine = localPlayer.CraftingTierMaterialTier == 1
                ? String.Format(
                    "%s: %d / %d",
                    tierName,
                    localPlayer.CraftingTierOwned,
                    localPlayer.CraftingTierRequired
                )
                : String.Format(
                    "%s %s: %d / %d",
                    tierName,
                    tierGrade,
                    localPlayer.CraftingTierOwned,
                    localPlayer.CraftingTierRequired
                );
        }
        else
        {
            tierLine = String.Format(
                "%s [%s]: %d / %d",
                tierName,
                tierGrade,
                localPlayer.CraftingTierOwned,
                localPlayer.CraftingTierRequired
            );
        }
        String infrastructureLine;
        if (localPlayer.CraftingSelectedInfrastructureAvailable)
        {
            infrastructureLine =
                StringTable.Localize(
                    "CA_CRAFTING_INFRASTRUCTURE_READY", false
                );
        }
        else
        {
            String missingStation = StringTable.Localize(
                GetCraftingStationKey(
                    localPlayer.CraftingMissingStationType
                ),
                false
            );
            infrastructureLine = String.Format(
                "%s: %s",
                StringTable.Localize(
                    "CA_CRAFTING_INFRASTRUCTURE_MISSING", false
                ),
                missingStation
            );
        }

        String boxLine = String.Format(
            "%s: %d / %d",
            StringTable.Localize("CA_EQUIPMENT_MAGIC_BOX", false),
            localPlayer.MagicBoxUsedSlots,
            localPlayer.MagicBoxMaximumSlots
        );
        String actionText = StringTable.Localize(
            GetCraftingActionKey(localPlayer.LastCraftingAction), false
        );
        int actionColor = (localPlayer.LastCraftingAction
                == CaelumConstants.CRAFTING_ACTION_CREATED
            || localPlayer.LastCraftingAction
                == CaelumConstants.CRAFTING_ACTION_MATERIALS_SPAWNED)
            ? Font.CR_GREEN
            : (localPlayer.LastCraftingAction
                    >= CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS
                ? Font.CR_RED : Font.CR_GRAY);

        DrawCenteredText(
            StringTable.Localize("CA_CRAFTING_MENU_TITLE", false),
            70.0,
            Font.CR_GOLD
        );
        DrawCenteredText(
            StringTable.Localize(
                GetCraftingStationKey(localPlayer.ActiveCraftingStationType), false
            ),
            100.0,
            Font.CR_CYAN
        );
        if (localPlayer.CraftingSelectedRecipeKind
                == CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON
            && localPlayer.CraftingSelectedWeapon < 0)
        {
            DrawCenteredText(
                StringTable.Localize("CA_CRAFTING_STATION_NO_RECIPES", false),
                154.0,
                Font.CR_GRAY
            );
            DrawCenteredText(
                StringTable.Localize("CA_CRAFTING_NAVIGATION_HELP_EMPTY", false),
                286.0,
                Font.CR_GRAY
            );
            return;
        }
        DrawCenteredText(selection, 132.0, Font.CR_WHITE);
        DrawCenteredText(
            StringTable.Localize("CA_CRAFTING_RECIPE", false),
            158.0,
            Font.CR_GOLD
        );
        DrawCenteredText(
            basicLine,
            182.0,
            localPlayer.CraftingBasicOwned
                    >= localPlayer.CraftingBasicRequired
                ? Font.CR_GREEN : Font.CR_RED
        );
        DrawCenteredText(
            tierLine,
            204.0,
            localPlayer.CraftingTierOwned >= localPlayer.CraftingTierRequired
                ? Font.CR_GREEN : Font.CR_RED
        );
        DrawCenteredText(
            infrastructureLine,
            224.0,
            localPlayer.CraftingSelectedInfrastructureAvailable
                ? Font.CR_GREEN : Font.CR_RED
        );
        DrawCenteredText(boxLine, 244.0, Font.CR_CYAN);
        DrawCenteredText(actionText, 264.0, actionColor);
        DrawCenteredText(
            StringTable.Localize("CA_CRAFTING_NAVIGATION_HELP_1", false),
            290.0,
            Font.CR_GRAY
        );
        DrawCenteredText(
            StringTable.Localize("CA_CRAFTING_NAVIGATION_HELP_2", false),
            308.0,
            Font.CR_GRAY
        );
    }

    // El creador inicial usa controles propios y no depende de asignaciones.
    // Escape, la consola y el boton Start conservan su comportamiento global.
    override bool InputProcess(InputEvent e)
    {
        CaelumPlayer localPlayer = CaelumPlayer(players[consoleplayer].mo);
        if (localPlayer == null
            || (!localPlayer.CreationWizardOpen
                && !localPlayer.EquipmentMenuOpen
                && !localPlayer.CraftingMenuOpen))
        {
            return false;
        }

        // El crafting debe poder recibir Q aunque GZDoom conserve menuactive
        // tras interactuar con una estación. Los otros menús personalizados
        // mantienen la protección anterior para no interceptar el menú nativo.
        if (menuactive != 0 && !localPlayer.CraftingMenuOpen)
        {
            return false;
        }

        if (e.Type != InputEvent.Type_KeyDown
            && e.Type != InputEvent.Type_KeyUp)
        {
            return false;
        }

        if (e.KeyScan == InputEvent.Key_Grave
            || e.KeyScan == InputEvent.Key_Pad_Start)
        {
            return false;
        }

        if (e.Type == InputEvent.Type_KeyUp)
        {
            return true;
        }

        if (localPlayer.CraftingMenuOpen)
        {
            int craftingCharacter = e.KeyChar;
            String craftingKey = e.KeyString;

            // KeyChar puede llegar vacío/inestable justo después de usar una
            // estación. KeyString deriva del KeyScan y resulta una segunda
            // ruta segura para detectar Q sin intervenir el sistema UI global.
            if (craftingCharacter == 113 || craftingCharacter == 81
                || craftingKey ~== "q")
            {
                SendNetworkEvent("ca_crafting_toggle");
            }
            else if (e.KeyScan == InputEvent.Key_RightArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Right)
            {
                SendNetworkEvent("ca_crafting_recipe_next");
            }
            else if (e.KeyScan == InputEvent.Key_LeftArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Left)
            {
                SendNetworkEvent("ca_crafting_recipe_previous");
            }
            else if (e.KeyScan == InputEvent.Key_Space
                || e.KeyScan == InputEvent.Key_Pad_X)
            {
                SendNetworkEvent("ca_crafting_tier");
            }
            else if (craftingCharacter == 114 || craftingCharacter == 82)
            {
                SendNetworkEvent("ca_crafting_size");
            }
            else if (e.KeyScan == InputEvent.Key_Enter
                || e.KeyScan == InputEvent.Key_Pad_A
                || craftingCharacter == 101 || craftingCharacter == 69)
            {
                SendNetworkEvent("ca_crafting_create");
            }
            else if (craftingCharacter == 112 || craftingCharacter == 80)
            {
                SendNetworkEvent("ca_crafting_spawn_materials");
            }
            return true;
        }

        if (localPlayer.EquipmentMenuOpen)
        {
            // KeyChar resulta estable para letras en GZDoom 4.14.2; KeyString
            // puede llegar vacio segun el teclado o la ruta de entrada.
            int menuCharacter = e.KeyChar;
            if (menuCharacter == 113 || menuCharacter == 81)
            {
                SendNetworkEvent("ca_equipment_toggle");
            }
            else if (e.KeyScan == InputEvent.Key_Tab
                || e.KeyScan == InputEvent.Key_Pad_Y)
            {
                SendNetworkEvent("ca_equipment_kind");
            }
            else if (e.KeyScan == InputEvent.Key_RightArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Right)
            {
                SendNetworkEvent("ca_equipment_type_next");
            }
            else if (e.KeyScan == InputEvent.Key_LeftArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Left)
            {
                SendNetworkEvent("ca_equipment_type_previous");
            }
            else if (e.KeyScan == InputEvent.Key_DownArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Down)
            {
                SendNetworkEvent("ca_equipment_slot_next");
            }
            else if (e.KeyScan == InputEvent.Key_UpArrow
                || e.KeyScan == InputEvent.Key_Pad_DPad_Up)
            {
                SendNetworkEvent("ca_equipment_slot_previous");
            }
            else if (e.KeyScan == InputEvent.Key_Space
                || e.KeyScan == InputEvent.Key_Pad_X)
            {
                SendNetworkEvent("ca_equipment_tier");
            }
            else if (menuCharacter == 114 || menuCharacter == 82)
            {
                SendNetworkEvent("ca_equipment_size");
            }
            else if (e.KeyScan == InputEvent.Key_Enter
                || e.KeyScan == InputEvent.Key_Pad_A)
            {
                SendNetworkEvent("ca_equipment_equip");
            }
            else if (menuCharacter == 101 || menuCharacter == 69)
            {
                SendNetworkEvent("ca_equipment_equip");
            }
            else if (e.KeyScan == InputEvent.Key_Backspace
                || e.KeyScan == InputEvent.Key_Pad_B)
            {
                SendNetworkEvent("ca_equipment_unequip");
            }
            else if (menuCharacter == 117 || menuCharacter == 85)
            {
                SendNetworkEvent("ca_equipment_unequip");
            }
            else if (menuCharacter == 99 || menuCharacter == 67)
            {
                SendNetworkEvent("ca_equipment_magic_box");
            }
            else if (menuCharacter == 112 || menuCharacter == 80)
            {
                // Crea directamente la vista seleccionada para probar el pickup.
                SendNetworkEvent("ca_debug_spawn_equipment");
            }
            else if (menuCharacter == 100 || menuCharacter == 68)
            {
                SendNetworkEvent("ca_equipment_drop");
            }
            else if (menuCharacter == 98 || menuCharacter == 66)
            {
                SendNetworkEvent("ca_equipment_break");
            }
            return true;
        }

        if (e.KeyScan == InputEvent.Key_Escape)
        {
            return false;
        }

        if (e.KeyScan == InputEvent.Key_RightArrow
            || e.KeyScan == InputEvent.Key_DownArrow
            || e.KeyScan == InputEvent.Key_Pad_DPad_Right
            || e.KeyScan == InputEvent.Key_Pad_DPad_Down)
        {
            SendNetworkEvent("ca_creation_next_choice");
        }
        else if (e.KeyScan == InputEvent.Key_Enter
            || e.KeyScan == InputEvent.Key_Pad_A)
        {
            SendNetworkEvent("ca_creation_confirm");
        }
        else if (e.KeyScan == InputEvent.Key_Space
            || e.KeyScan == InputEvent.Key_Pad_X)
        {
            SendNetworkEvent("ca_creation_add_point");
        }
        else if (e.KeyScan == InputEvent.Key_Backspace
            || e.KeyScan == InputEvent.Key_LeftArrow
            || e.KeyScan == InputEvent.Key_Pad_B)
        {
            SendNetworkEvent("ca_creation_back");
        }

        return true;
    }

    // RenderOverlay runs whenever GZDoom draws the player's game view.
    override void RenderOverlay(RenderEvent event)
    {
        CaelumPlayer localPlayer = CaelumPlayer(players[consoleplayer].mo);

        // The creation wizard is independent from the optional debug panel.
        if (localPlayer != null && localPlayer.CreationWizardOpen)
        {
            DrawCreationWizard(localPlayer);
            return;
        }

        if (localPlayer != null && localPlayer.EquipmentMenuOpen)
        {
            DrawEquipmentMenu(localPlayer);
            return;
        }

        if (localPlayer != null && localPlayer.CraftingMenuOpen)
        {
            DrawCraftingMenu(localPlayer);
            return;
        }

        // User CVars store a separate preference for each local player.
        CVar showPanel = CVar.GetCVar(
            "ca_debug_attributes",
            players[consoleplayer]
        );

        if (showPanel == null || !showPanel.GetBool())
        {
            return;
        }

        // Obtain the local player and confirm that the attribute data exists.
        localPlayer = CaelumPlayer(players[consoleplayer].mo);

        if (localPlayer == null || localPlayer.Attributes == null || DebugFont == null)
        {
            return;
        }

        CaelumAttributes attributes = localPlayer.Attributes;
        CaelumCharacterProfile profile = localPlayer.CharacterProfile;
        CaelumCharacterAllocation allocation = localPlayer.CharacterAllocation;
        CaelumDerivedStats derived = localPlayer.DerivedStats;

        if (profile == null || allocation == null || derived == null)
        {
            return;
        }

        int debugPage = Clamp(localPlayer.DebugPanelPage, 0, 5);
        String debugPageKey = "CA_DEBUG_PAGE_CHARACTER";
        if (debugPage == 1) { debugPageKey = "CA_DEBUG_PAGE_RESOURCES"; }
        else if (debugPage == 2) { debugPageKey = "CA_DEBUG_PAGE_COMBAT"; }
        else if (debugPage == 3) { debugPageKey = "CA_DEBUG_PAGE_ARMOR"; }
        else if (debugPage == 4) { debugPageKey = "CA_DEBUG_PAGE_MAGIC"; }
        else if (debugPage == 5) { debugPageKey = "CA_DEBUG_PAGE_ACTORS"; }

        // Draw one compact thematic page instead of every diagnostic at once.
        Screen.DrawText(
            DebugFont,
            Font.CR_GOLD,
            20.0,
            20.0,
            String.Format(
                "%s — %s (%d/6)",
                StringTable.Localize("CA_DEBUG_ATTRIBUTES_TITLE", false),
                StringTable.Localize(debugPageKey, false),
                debugPage + 1
            ),
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        // Muestra el perfil 4.0 en dos lineas compactas.
        String profileLine = String.Format(
            "%s: %s   %s: %s",
            StringTable.Localize("CA_PROFILE_RACE", false),
            StringTable.Localize(GetRaceKey(profile.Race), false),
            StringTable.Localize("CA_PROFILE_PROFESSION", false),
            StringTable.Localize(GetProfessionKey(profile.FirstClass, profile.SecondClass), false)
        );
        String profileClassLine = String.Format(
            "%s: %s   %s: %s",
            StringTable.Localize("CA_PROFILE_SEX", false),
            StringTable.Localize(GetSexKey(profile.Sex), false),
            StringTable.Localize("CA_PROFILE_HEIGHT", false),
            StringTable.Localize(GetHeightChoiceKey(profile.HeightChoice), false)
        );

        Screen.DrawText(
            DebugFont, Font.CR_GRAY, 20.0, 34.0, profileLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );
        Screen.DrawText(
            DebugFont, Font.CR_GRAY, 20.0, 46.0, profileClassLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        if (debugPage == 0)
        {
            DrawAttribute("CA_ATTRIBUTE_STRENGTH", attributes.Strength, 20.0, 62.0);
            DrawAttribute("CA_ATTRIBUTE_TOUGHNESS", attributes.Toughness, 20.0, 78.0);
            DrawAttribute("CA_ATTRIBUTE_CONSTITUTION", attributes.Constitution, 20.0, 94.0);
            DrawAttribute("CA_ATTRIBUTE_AGILITY", attributes.Agility, 180.0, 62.0);
            DrawAttribute("CA_ATTRIBUTE_DEXTERITY", attributes.Dexterity, 180.0, 78.0);
            DrawAttribute("CA_ATTRIBUTE_RESILIENCE", attributes.Resilience, 180.0, 94.0);
            DrawAttribute("CA_ATTRIBUTE_CHARISMA", attributes.Charisma, 340.0, 62.0);
            DrawAttribute("CA_ATTRIBUTE_EMPATHY", attributes.Empathy, 340.0, 78.0);
            DrawAttribute("CA_ATTRIBUTE_ELOQUENCE", attributes.Eloquence, 340.0, 94.0);
            DrawAttribute("CA_ATTRIBUTE_INTELLIGENCE", attributes.Intelligence, 500.0, 62.0);
            DrawAttribute("CA_ATTRIBUTE_PATIENCE", attributes.Patience, 500.0, 78.0);
            DrawAttribute("CA_ATTRIBUTE_INSIGHT", attributes.Insight, 500.0, 94.0);

            String creationLine = String.Format(
                "%s: %d/4   %s: %d/30",
                StringTable.Localize("CA_CREATION_LAYER_POINTS", false),
                allocation.GetRemainingLayerPoints(),
                StringTable.Localize("CA_CREATION_ATTRIBUTE_POINTS", false),
                allocation.GetRemainingAttributePoints()
            );
            String selectionLine = String.Format(
                "%s: %s",
                StringTable.Localize("CA_CREATION_SELECTED_LAYER", false),
                StringTable.Localize(GetLayerKey(allocation.SelectedLayer), false)
            );
            String selectedAttributeLine = String.Format(
                "%s: %s",
                StringTable.Localize("CA_CREATION_SELECTED_ATTRIBUTE", false),
                StringTable.Localize(GetAttributeKey(allocation.SelectedAttribute), false)
            );
            Screen.DrawText(DebugFont, Font.CR_GREEN, 20.0, 122.0, creationLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GREEN, 20.0, 138.0, selectionLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GREEN, 20.0, 154.0, selectedAttributeLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String derivedLine = String.Format(
                "%s: %.0f   %s: %.0f   %s: %.0f",
                StringTable.Localize("CA_STAT_MAX_HEALTH", false), derived.MaximumHealth,
                StringTable.Localize("CA_STAT_MAX_ANIMA", false), derived.MaximumAnima,
                StringTable.Localize("CA_STAT_MAX_AIR", false), derived.MaximumAir
            );
            String massLine = String.Format(
                "%s: %.1f   %s: %d kg (T%d)   %s: %.2f m (T%d)",
                StringTable.Localize("CA_STAT_CARRY_CAPACITY", false), derived.CarryCapacity,
                StringTable.Localize("CA_STAT_BASE_MASS", false), derived.BaseMass, derived.MassTier,
                StringTable.Localize("CA_STAT_SIZE", false), derived.BodyHeightMeters, derived.SizeTier
            );
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 178.0, derivedLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 194.0, massLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String weightLine = String.Format(
                "%s: %.0f + %.0f + %.0f = %.0f   %s: %.1f",
                StringTable.Localize("CA_STAT_CARRIED_WEIGHT", false),
                derived.EquippedWeight, derived.InventoryWeight,
                derived.DebugWeight, localPlayer.HUDCarriedWeight,
                StringTable.Localize("CA_STAT_TOTAL_MASS", false), derived.TotalMass
            );
            String loadLine = String.Format(
                "%s: %.1f%%   %s: x%.2f",
                StringTable.Localize("CA_STAT_LOAD_PERCENT", false), localPlayer.HUDLoadRatio * 100.0,
                StringTable.Localize("CA_STAT_AIR_USE", false), derived.AirConsumptionMultiplier
            );
            Screen.DrawText(DebugFont, Font.CR_GRAY, 20.0, 218.0, weightLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GRAY, 20.0, 234.0, loadLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String impactLine = String.Format(
                "%s: %s %d   RawDV %.3f TraumaDV %.3f Bio %.3f   %s %.2f   %s %.1f%%",
                StringTable.Localize("CA_PHYSICS_IMPACT", false),
                StringTable.Localize("CA_PHYSICS_KIND", false),
                localPlayer.LastImpactKind,
                localPlayer.LastImpactRawDeltaSpeed,
                localPlayer.LastImpactDeltaSpeed,
                localPlayer.LastImpactBiologicalAbsorptionSpeed,
                StringTable.Localize("CA_PHYSICS_EQUIV_TICS", false),
                localPlayer.LastImpactEquivalentTics,
                StringTable.Localize("CA_PHYSICS_DAMAGE", false),
                localPlayer.LastImpactDamagePercent
            );
            String impactDefenseLine = String.Format(
                "AfterTough %.2f%% Final %d | Vul x%.2f ArmorW %.1f%% HeadW %.1f%% Luc %.2f",
                localPlayer.LastImpactPostToughnessPercent,
                localPlayer.LastImpactFinalDamage,
                localPlayer.LastImpactWeightedVulnerabilityMultiplier,
                localPlayer.LastImpactWeightedArmorDefensePercent,
                localPlayer.LastImpactHeadContactWeight * 100.0,
                localPlayer.LastImpactLucidityLoss
            );
            String accelerationLine = String.Format(
                "Accel %.1f%% (%.2fs) | Contact %s Sep %d/%d | Band %.2f-%.2f",
                localPlayer.MovementAccelerationFactor * 100.0,
                localPlayer.MovementAccelerationSeconds,
                localPlayer.ImpactContactActor != null ? "ON" : "OFF",
                localPlayer.ImpactContactSeparatedTics,
                CaelumConstants.IMPACT_CONTACT_REARM_SEPARATED_TICS,
                localPlayer.LastImpactContactMinimumHeightRatio,
                localPlayer.LastImpactContactMaximumHeightRatio
            );
            Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 250.0, impactLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 266.0, impactDefenseLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 282.0, accelerationLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            return;
        }

        if (debugPage == 1)
        {
            String healthLine = String.Format(
                "%s: %d/%d (%s)",
                StringTable.Localize("CA_HUD_HEALTH", false), localPlayer.health,
                localPlayer.CaelumMaximumHealth,
                StringTable.Localize(localPlayer.HealthState == CaelumConstants.HEALTH_STATE_BADLY_WOUNDED
                    ? "CA_HEALTH_STATE_BADLY_WOUNDED" : (localPlayer.HealthState == CaelumConstants.HEALTH_STATE_WOUNDED
                    ? "CA_HEALTH_STATE_WOUNDED" : "CA_HEALTH_STATE_NORMAL"), false)
            );
            String healthFactorLine = String.Format(
                "%s: x%.3f -> x%.3f -> x%.3f",
                StringTable.Localize("CA_STAT_HEALTH_FACTOR", false),
                localPlayer.HealthRawPerformanceMultiplier,
                localPlayer.HealthPatienceMitigatedPerformanceMultiplier,
                localPlayer.HealthPerformanceMultiplier
            );
            Screen.DrawText(DebugFont, Font.CR_GREEN, 20.0, 62.0, healthLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GREEN, 20.0, 78.0, healthFactorLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String patienceLine = String.Format(
                "%s: x%.4f",
                StringTable.Localize("CA_RESOURCE_PATIENCE_HEALTH_MITIGATION", false),
                localPlayer.HealthPatienceMitigationMultiplier
            );
            String healthIntensityLine = String.Format(
                "%s: x%.3f   %s: x%.2f",
                StringTable.Localize("CA_RESOURCE_PAIN_RESISTANCE", false),
                localPlayer.HealthPainMultiplier,
                StringTable.Localize("CA_STAT_HEALTH_INTENSITY", false),
                localPlayer.HealthAdrenalineGainMultiplier
            );
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 98.0, patienceLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 114.0, healthIntensityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String animaLine = String.Format(
                "%s: %.1f/%.1f (+%.3f/s)",
                StringTable.Localize("CA_HUD_ANIMA", false), localPlayer.CurrentAnima,
                derived.MaximumAnima, derived.AnimaRegenerationPerSecond
            );
            String airLine = String.Format(
                "%s: %.1f/%.1f (+%.3f/s)",
                StringTable.Localize("CA_HUD_AIR", false), localPlayer.CurrentAir,
                derived.MaximumAir, derived.AirRegenerationPerSecond
                    * localPlayer.HealthPerformanceMultiplier
            );
            Screen.DrawText(DebugFont, Font.CR_CYAN, 20.0, 138.0, animaLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_CYAN, 20.0, 154.0, airLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String survivalLine = String.Format(
                "%s: %.1f   %s: %.1f   %s: %.1f",
                StringTable.Localize("CA_HUD_HUNGER", false), localPlayer.CurrentHunger,
                StringTable.Localize("CA_HUD_THIRST", false), localPlayer.CurrentThirst,
                StringTable.Localize("CA_HUD_SLEEP", false), localPlayer.CurrentSleep
            );
            String survivalFactorLine = String.Format(
                "%s: x%.3f   %s: x%.3f",
                StringTable.Localize("CA_STAT_SURVIVAL_FACTOR", false),
                localPlayer.SurvivalPerformanceMultiplier,
                StringTable.Localize("CA_STAT_OFFENSIVE_DAMAGE_FACTOR", false),
                localPlayer.EffectiveOffensiveDamageMultiplier
            );
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 182.0, survivalLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 198.0, survivalFactorLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String lucidityLine = String.Format(
                "%s: %.1f/%.0f   %s: %.2fs",
                StringTable.Localize("CA_HUD_LUCIDITY", false), localPlayer.CurrentLucidity,
                CaelumConstants.MAXIMUM_LUCIDITY,
                StringTable.Localize("CA_RESOURCE_LUCIDITY_STUN_TIME", false),
                localPlayer.LucidityPhysicalStunRemaining
            );
            String mobilityLine = String.Format(
                "%s: %.2f%%   %s: %.2f%%",
                StringTable.Localize("CA_STAT_EVASION_EFFECTIVE", false),
                localPlayer.EffectiveEvasionChance,
                StringTable.Localize("CA_STAT_MOVEMENT_AGILITY", false),
                localPlayer.EffectiveMovementPercent
            );
            String accuracyLine = String.Format(
                "%s: %.2f%% x%.2f   %s %.1f%%   Noise %.1f%% / %.1f MU",
                StringTable.Localize("CA_STAT_PHYSICAL_ACCURACY", false),
                localPlayer.EffectivePhysicalAccuracyPercent,
                localPlayer.CrouchAccuracyMultiplier,
                StringTable.Localize("CA_STAT_STEALTH", false),
                localPlayer.EffectiveStealthPercent,
                localPlayer.MovementNoiseMultiplier * 100.0,
                localPlayer.LastMovementNoiseRange
            );
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 226.0, lucidityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 242.0, accuracyLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 258.0, mobilityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            return;
        }

        if (debugPage == 2)
        {
            String adrenalineLine = String.Format(
                "%s: %.1f/%.1f   %s: %.1fs",
                StringTable.Localize("CA_HUD_ADRENALINE", false), localPlayer.CurrentAdrenaline,
                derived.MaximumAdrenaline,
                StringTable.Localize("CA_RESOURCE_COMBAT_TIME", false),
                localPlayer.CombatTimeRemaining
            );
            String adrenalineEventLine = String.Format(
                "%s (%s): %.1f -> %.1f",
                StringTable.Localize("CA_RESOURCE_LAST_ADRENALINE_GAIN", false),
                StringTable.Localize(GetAdrenalineEventKey(localPlayer.LastAdrenalineEvent), false),
                localPlayer.LastAdrenalineBaseGain, localPlayer.LastAdrenalineFinalGain
            );
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 62.0, adrenalineLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 78.0, adrenalineEventLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String painLine = String.Format(
                "%s: %.2f%%   %s: %.2f%%",
                StringTable.Localize("CA_RESOURCE_LAST_HEALTH_LOSS", false),
                localPlayer.LastHealthLossPercent,
                StringTable.Localize("CA_RESOURCE_LAST_PAIN_CHANCE", false),
                localPlayer.LastPainChancePercent
            );
            String painResultLine = String.Format(
                "%s: x%.4f   %s: %s",
                StringTable.Localize("CA_RESOURCE_PAIN_RESISTANCE", false),
                derived.PainChanceMultiplier,
                StringTable.Localize("CA_RESOURCE_LAST_PAIN_RESULT", false),
                StringTable.Localize(localPlayer.LastPainTriggered
                    ? "CA_PAIN_TRIGGERED" : "CA_PAIN_RESISTED", false)
            );
            String painLockLine = String.Format(
                "%s: %.2fs / %.2fs",
                StringTable.Localize("CA_RESOURCE_PAIN_IMMOBILIZATION", false),
                localPlayer.PainImmobilizationRemaining,
                localPlayer.LastPainAnimationDuration
            );
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 106.0, painLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 122.0, painResultLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 138.0, painLockLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String meleeLine = String.Format(
                "%s: %.1f / %d",
                StringTable.Localize("CA_RESOURCE_MELEE_DAMAGE", false),
                derived.DebugSwordDamage
                    * (localPlayer.LastMeleeLocationMultiplier > 0.0
                        ? localPlayer.LastMeleeLocationMultiplier : 1.0)
                    * localPlayer.EffectiveOffensiveDamageMultiplier,
                localPlayer.LastMeleeActualDamage
            );
            String meleeLocationLine = String.Format(
                "%s: %s x%.2f (%.1f%%)",
                StringTable.Localize("CA_RESOURCE_HIT_LOCATION", false),
                StringTable.Localize(GetVulnerabilityKey(localPlayer.LastMeleeVulnerabilityGrade), false),
                localPlayer.LastMeleeLocationMultiplier,
                localPlayer.LastMeleeHitHeightRatio * 100.0
            );
            String meleeAirLine = String.Format(
                "%s: %.1f   %s: %.2f",
                StringTable.Localize("CA_RESOURCE_MELEE_AIR_COST", false),
                localPlayer.LastMeleeAirCost,
                StringTable.Localize("CA_STAT_LAST_PUSH_FORCE", false),
                localPlayer.LastAttackPushForce
            );
            String meleeCriticalLine = String.Format(
                "%s: %.2f%% x%.2f   %s: %.2f%% (%s)",
                StringTable.Localize("CA_STAT_PHYSICAL_CRITICAL", false),
                localPlayer.LastMeleeCriticalAttempted
                    ? localPlayer.LastMeleeCriticalChancePercent
                    : Min(100.0, derived.PhysicalCriticalChance
                        * localPlayer.CrouchCriticalChanceMultiplier),
                localPlayer.CrouchCriticalChanceMultiplier,
                StringTable.Localize("CA_RESOURCE_CRITICAL_ROLL", false),
                localPlayer.LastMeleeCriticalRollPercent,
                StringTable.Localize(!localPlayer.LastMeleeCriticalAttempted
                    ? "CA_CRITICAL_NOT_ATTEMPTED" : (localPlayer.LastMeleeCriticalHit
                    ? "CA_CRITICAL_HIT" : "CA_CRITICAL_NORMAL"), false)
            );
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 166.0, meleeLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 182.0, meleeLocationLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 198.0, meleeAirLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 214.0, meleeCriticalLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String evasionLine = String.Format(
                "%s: %.2f%% x%.2f   %s: %.2f / %.2f",
                StringTable.Localize("CA_STAT_PHYSICAL_ACCURACY", false),
                localPlayer.LastMeleeAccuracyPercent,
                localPlayer.LastMeleeMovementAccuracyMultiplier,
                StringTable.Localize("CA_RESOURCE_AIM_OFFSET", false),
                localPlayer.LastMeleeYawOffset,
                localPlayer.LastMeleePitchOffset
            );
            String evasionResultLine = String.Format(
                "%s: %.2f%% / %.2f%% (%s)",
                StringTable.Localize("CA_RESOURCE_EVASION_LAST", false),
                localPlayer.LastEvasionRollPercent, localPlayer.LastEvasionChancePercent,
                StringTable.Localize(!localPlayer.LastEvasionAttempted
                    ? "CA_EVASION_NOT_ATTEMPTED" : (localPlayer.LastEvasionSucceeded
                    ? "CA_EVASION_SUCCEEDED" : "CA_EVASION_FAILED"), false)
            );
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 242.0, evasionLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 258.0, evasionResultLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            CaelumCombatActor inspectedActor = LastInspectedCombatActor;
            if (inspectedActor != null)
            {
                String inspectedActorNameKey = "CA_ARGENTO_NAME";
                if (CaelumCaella(inspectedActor) != null)
                {
                    inspectedActorNameKey = "CA_CAELLA_NAME";
                }
                else if (CaelumRulo(inspectedActor) != null)
                {
                    inspectedActorNameKey = "CA_RULO_NAME";
                }
                else if (CaelumRonnie(inspectedActor) != null)
                {
                    inspectedActorNameKey = "CA_RONNIE_NAME";
                }
                String actorResourceLine = String.Format(
                    "%s: %s   %s: %d/%d   %s: %.1f/%.1f",
                    StringTable.Localize("CA_RESOURCE_ACTOR_LAST", false),
                    StringTable.Localize(inspectedActorNameKey, false),
                    StringTable.Localize("CA_HUD_HEALTH", false),
                    Max(0, inspectedActor.health),
                    inspectedActor.CombatMaximumHealth,
                    StringTable.Localize("CA_HUD_ADRENALINE", false),
                    inspectedActor.CurrentCombatAdrenaline,
                    inspectedActor.MaximumCombatAdrenaline
                );
                String actorEvasionLine = String.Format(
                    "%s: %.2f%% / %.2f%% (%s)",
                    StringTable.Localize("CA_RESOURCE_ACTOR_EVASION", false),
                    inspectedActor.LastCombatEvasionRollPercent,
                    inspectedActor.LastCombatEvasionChancePercent,
                    StringTable.Localize(!inspectedActor.LastCombatEvasionAttempted
                        ? "CA_EVASION_NOT_ATTEMPTED" : (inspectedActor.LastCombatEvasionSucceeded
                        ? "CA_EVASION_SUCCEEDED" : "CA_EVASION_FAILED"), false)
                );
                String actorPainLine = String.Format(
                    "%s: x%.3f   %.2f%% -> %.2f%% (%s)",
                    StringTable.Localize("CA_RESOURCE_ACTOR_PAIN", false),
                    inspectedActor.LastCombatToughnessDamageMultiplier,
                    inspectedActor.LastCombatHealthLossPercent,
                    inspectedActor.LastCombatPainChancePercent,
                    StringTable.Localize(inspectedActor.LastCombatPainTriggered
                        ? "CA_PAIN_TRIGGERED" : "CA_PAIN_RESISTED", false)
                );
                String actorLucidityLine = String.Format(
                    "%s: %.1f/%d (%s) x%.2f   -%.1f   %s: %.1fs",
                    StringTable.Localize("CA_HUD_LUCIDITY", false),
                    inspectedActor.CurrentCombatLucidity,
                    int(CaelumConstants.MAXIMUM_LUCIDITY),
                    StringTable.Localize(GetLucidityStateKey(
                        inspectedActor.CombatLucidityState), false),
                    inspectedActor.CombatLucidityAccuracyMultiplier,
                    inspectedActor.LastCombatLucidityLoss,
                    StringTable.Localize("CA_RESOURCE_LUCIDITY_STUN_TIME", false),
                    inspectedActor.CombatLucidityPhysicalStunRemaining
                );
                String actorAnatomyLine = String.Format(
                    "%s: %s / %s>%s   H %.1f%% L %.1f%%",
                    StringTable.Localize("CA_RESOURCE_ACTOR_ANATOMY", false),
                    StringTable.Localize(GetHitLocationKey(inspectedActor.LastAnatomyLocation), false),
                    StringTable.Localize(GetVulnerabilityKey(inspectedActor.LastAnatomyNaturalVulnerabilityGrade), false),
                    StringTable.Localize(GetVulnerabilityKey(inspectedActor.LastAnatomyVulnerabilityGrade), false),
                    inspectedActor.LastAnatomyHeightRatio * 100.0,
                    inspectedActor.LastAnatomyLateralRatio * 100.0
                );
                int actorArmorSlot = inspectedActor.LastCombatArmorSlot;
                CaelumArmorModel actorArmor = inspectedActor.CombatArmor;
                int actorArmorDurability = actorArmor != null
                    ? actorArmor.Durability[actorArmorSlot] : 0;
                String actorArmorLine = String.Format(
                    "%s: %s %d%%   %.1f/%d   %s -%d",
                    StringTable.Localize("CA_RESOURCE_ARMOR", false),
                    StringTable.Localize(GetArmorSlotKey(actorArmorSlot), false),
                    inspectedActor.LastCombatArmorDefensePercent,
                    inspectedActor.LastCombatArmorAbsorbedDamage,
                    actorArmorDurability,
                    StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                    inspectedActor.LastCombatArmorDurabilityLoss
                );
                Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 274.0, actorResourceLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_CYAN, 20.0, 288.0, actorLucidityLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 302.0, actorAnatomyLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_PURPLE, 20.0, 316.0, actorArmorLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 330.0, actorEvasionLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 344.0, actorPainLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            }
            return;
        }

        if (debugPage == 3)
        {
            CaelumArmorModel compactArmor = localPlayer.ArmorModel;
            if (compactArmor == null) { return; }
            int compactSlot = compactArmor.SelectedSlot;
            String armorLine = String.Format(
                "%s: %s / %s T%d %s",
                StringTable.Localize("CA_RESOURCE_ARMOR", false),
                StringTable.Localize(GetArmorSlotKey(compactSlot), false),
                StringTable.Localize(GetArmorDisplayKey(
                    compactSlot, compactArmor.ArmorType[compactSlot]
                ), false),
                compactArmor.Tier[compactSlot],
                StringTable.Localize(
                    GetEquipmentSizeKey(compactArmor.Size[compactSlot]), false
                )
            );
            String armorStatsLine = String.Format(
                "%s: %d%%   %s: +%d   %s: %d/%d",
                StringTable.Localize("CA_RESOURCE_ARMOR_DEFENSE", false),
                GetArmorDefenseForPanel(compactArmor, compactSlot),
                StringTable.Localize("CA_RESOURCE_ARMOR_REINFORCEMENT", false),
                GetArmorReinforcementForPanel(compactArmor, compactSlot),
                StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                compactArmor.Durability[compactSlot],
                GetArmorMaximumDurabilityForPanel(compactArmor, compactSlot)
            );
            Screen.DrawText(DebugFont, Font.CR_PURPLE, 20.0, 62.0, armorLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_PURPLE, 20.0, 78.0, armorStatsLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            String ownedEquipmentLine = String.Format(
                "%s: %d   %s: %d",
                StringTable.Localize("CA_RESOURCE_OWNED_ARMOR", false),
                localPlayer.OwnedArmorCount,
                StringTable.Localize("CA_RESOURCE_OWNED_SHIELDS", false),
                localPlayer.OwnedShieldCount
            );
            Screen.DrawText(DebugFont, Font.CR_GREEN, 20.0, 92.0, ownedEquipmentLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String hitLine = String.Format(
                "%s: %s x%.2f -> %.1f",
                StringTable.Localize("CA_RESOURCE_ARMOR_LAST_HIT", false),
                StringTable.Localize(GetVulnerabilityKey(localPlayer.LastArmorVulnerabilityGrade), false),
                localPlayer.LastArmorVulnerabilityMultiplier,
                localPlayer.LastArmorPreDefenseDamage
            );
            String armorDamageLine = String.Format(
                "%s: %.1f   %s: %.1f x%.3f -> %d",
                StringTable.Localize("CA_RESOURCE_ARMOR_ABSORBED", false),
                localPlayer.LastArmorAbsorbedDamage,
                StringTable.Localize("CA_RESOURCE_ARMOR_HEALTH_DAMAGE", false),
                localPlayer.LastArmorPostDefenseDamage,
                localPlayer.LastToughnessDamageMultiplier,
                localPlayer.LastArmorHealthDamage
            );
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 106.0, hitLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 122.0, armorDamageLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String explosionLine = String.Format(
                "%s: %d / %.1f",
                StringTable.Localize("CA_RESOURCE_EXPLOSION_REGIONS", false),
                localPlayer.LastExplosionTouchedRegionCount,
                localPlayer.LastExplosionRadius
            );
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 136.0, explosionLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            String durabilityLine = String.Format(
                "%s: -%d   %s: %.1f%% / %.1f%%   %s",
                StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                localPlayer.LastArmorDurabilityLoss,
                StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY_ROLL", false),
                localPlayer.LastArmorDurabilityRollPercent,
                localPlayer.LastArmorDurabilityChancePercent,
                StringTable.Localize(localPlayer.LastArmorHitWasCritical
                    ? "CA_ARMOR_HIT_CRITICAL" : "CA_ARMOR_HIT_NORMAL", false)
            );
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 150.0, durabilityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            String armorLucidityLine = String.Format(
                "%s: %.2f   %s: x%.3f",
                StringTable.Localize("CA_RESOURCE_LOCALIZED_LUCIDITY_LOSS", false),
                localPlayer.LastLocalizedLucidityLoss,
                StringTable.Localize("CA_RESOURCE_SLEEP_LUCIDITY_FACTOR", false),
                localPlayer.LuciditySleepDebuffMultiplier
            );
            Screen.DrawText(DebugFont, Font.CR_CYAN, 20.0, 178.0, armorLucidityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);

            CaelumShieldModel shield = localPlayer.ShieldModel;
            if (shield != null)
            {
                String shieldLine = String.Format(
                    "%s: %s T%d %s   %s: %s   %s: %d/%d",
                    StringTable.Localize("CA_RESOURCE_SHIELD", false),
                    StringTable.Localize(GetShieldTypeKey(shield.ShieldType), false),
                    shield.Tier,
                    StringTable.Localize(GetEquipmentSizeKey(shield.Size), false),
                    StringTable.Localize("CA_RESOURCE_SHIELD_BLOCKING", false),
                    StringTable.Localize(localPlayer.DebugShieldBlocking
                        ? "CA_RESOURCE_SHIELD_ACTIVE" : "CA_RESOURCE_SHIELD_INACTIVE", false),
                    StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                    shield.Durability, GetShieldMaximumDurabilityForPanel(shield)
                );
                String shieldStatsLine = String.Format(
                    "%s: %d%%/%d%%   %s: %d°/%d°",
                    StringTable.Localize("CA_RESOURCE_SHIELD_DEFENSE", false),
                    GetShieldDefenseForPanel(shield, CaelumConstants.SHIELD_DAMAGE_PHYSICAL),
                    GetShieldDefenseForPanel(shield, CaelumConstants.SHIELD_DAMAGE_MAGICAL),
                    StringTable.Localize("CA_RESOURCE_SHIELD_COVERAGE", false),
                    GetShieldCoverageForPanel(shield),
                    localPlayer.DebugShieldIncomingAngleOffset
                );
                String shieldHitLine = String.Format(
                    "%s: %.2f/s   %s: %.1f/%d   %s",
                    StringTable.Localize("CA_RESOURCE_SHIELD_AIR", false),
                    localPlayer.CurrentShieldAirCostPerSecond,
                    StringTable.Localize("CA_RESOURCE_SHIELD_HIT", false),
                    localPlayer.LastShieldAbsorbedDamage,
                    localPlayer.LastShieldHealthDamage,
                    StringTable.Localize(localPlayer.LastShieldWithinCoverage
                        ? "CA_RESOURCE_SHIELD_COVERED" : "CA_RESOURCE_SHIELD_BYPASSED", false)
                );
                String shieldDurabilityLine = String.Format(
                    "%s: -%d   %.1f%%/%.1f%%",
                    StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                    localPlayer.LastShieldDurabilityLoss,
                    localPlayer.LastShieldDurabilityRollPercent,
                    localPlayer.LastShieldDurabilityChancePercent
                );
                Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 210.0, shieldLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 226.0, shieldStatsLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 242.0, shieldHitLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
                Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 258.0, shieldDurabilityLine,
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            }
            return;
        }

        if (debugPage == 4)
        {
            String staffDamageLine = String.Format(
                "%s: %.1f/%d   %s: %.0f",
                StringTable.Localize("CA_RESOURCE_STAFF_DAMAGE", false),
                localPlayer.LastStaffCalculatedDamage,
                localPlayer.LastStaffActualDamage,
                StringTable.Localize("CA_RESOURCE_STAFF_ANIMA", false),
                derived.StaffAnimaCost
            );
            String staffAccuracyLine = String.Format(
                "%s: %.2f%%   %s: %.2f/%.2f",
                StringTable.Localize("CA_STAT_MAGICAL_ACCURACY", false),
                localPlayer.LastStaffAccuracyPercent,
                StringTable.Localize("CA_RESOURCE_AIM_OFFSET", false),
                localPlayer.LastStaffYawOffset,
                localPlayer.LastStaffPitchOffset
            );
            String staffCriticalLine = String.Format(
                "%s: %.2f%%   %s: %.2f%% (%s)",
                StringTable.Localize("CA_STAT_MAGICAL_CRITICAL", false),
                localPlayer.LastStaffCriticalAttempted
                    ? localPlayer.LastStaffCriticalChancePercent
                    : Min(100.0, derived.StaffCriticalChance
                        * localPlayer.CrouchCriticalChanceMultiplier),
                StringTable.Localize("CA_RESOURCE_CRITICAL_ROLL", false),
                localPlayer.LastStaffCriticalRollPercent,
                StringTable.Localize(!localPlayer.LastStaffCriticalAttempted
                    ? "CA_CRITICAL_NOT_ATTEMPTED" : (localPlayer.LastStaffCriticalHit
                    ? "CA_CRITICAL_HIT" : "CA_CRITICAL_NORMAL"), false)
            );
            String staffResultLine = String.Format(
                "%s: %s x%.2f   %s: %.2fs%s",
                StringTable.Localize("CA_RESOURCE_MELEE_RESULT", false),
                StringTable.Localize(localPlayer.LastStaffHit
                    ? "CA_ATTACK_HIT" : "CA_ATTACK_MISS", false),
                localPlayer.LastStaffLocationMultiplier,
                StringTable.Localize("CA_RESOURCE_STAFF_CAST", false),
                localPlayer.StaffCastCooldownRemaining,
                localPlayer.LastStaffInsufficientAnima
                    ? String.Format("   %s", StringTable.Localize("CA_ATTACK_NO_ANIMA", false))
                    : ""
            );
            String eloquenceLine = String.Format(
                "%s: %.2f%%   %s: %.2f%%",
                StringTable.Localize("CA_STAT_ANIMA_COST_REDUCTION", false),
                derived.AnimaCostReductionPercent,
                StringTable.Localize("CA_STAT_CASTING_SPEED", false),
                derived.CastingSpeedPercent
            );
            String eloquenceUtilityLine = String.Format(
                "%s: %.2f%%   %s: %.2f%%",
                StringTable.Localize("CA_STAT_ABILITY_RANGE", false),
                derived.AbilityRangePercent,
                StringTable.Localize("CA_STAT_DIALOGUE_SKILL", false),
                derived.DialogueSkillPercent
            );
            String activeEssenceLine = String.Format(
                "%s: %s   %s: %.2fs",
                StringTable.Localize("CA_RESOURCE_ACTIVE_ESSENCE", false),
                StringTable.Localize(
                    GetEssenceTypeKey(localPlayer.WeaponModel != null
                        ? localPlayer.WeaponModel.EssenceType
                        : CaelumConstants.ESSENCE_FIRE), false
                ),
                StringTable.Localize("CA_RESOURCE_ILLUMINATION", false),
                localPlayer.IlluminationRemaining
            );
            String elementalEffectsLine = String.Format(
                "%s: %.1f/%.1f/%.1f/%.1f/%.1f/%.1f s",
                StringTable.Localize("CA_RESOURCE_ELEMENTAL_EFFECTS", false),
                localPlayer.ElementalStatus != null
                    ? localPlayer.ElementalStatus.BurnRemaining : 0.0,
                localPlayer.ElementalStatus != null
                    ? localPlayer.ElementalStatus.CutRemaining : 0.0,
                localPlayer.ElementalStatus != null
                    ? localPlayer.ElementalStatus.PoisonRemaining : 0.0,
                localPlayer.ElementalStatus != null
                    ? localPlayer.ElementalStatus.FreezeRemaining : 0.0,
                localPlayer.ElementalStatus != null
                    ? localPlayer.ElementalStatus.DazzleRemaining : 0.0,
                localPlayer.ElementalStatus != null
                    ? localPlayer.ElementalStatus.LightningStunRemaining : 0.0
            );
            String castStateKey = "CA_CAST_STATE_IDLE";
            if (localPlayer.StaffCastPending)
            {
                castStateKey = "CA_CAST_STATE_PREPARING";
            }
            else if (localPlayer.LastStaffCastInterrupted)
            {
                castStateKey = "CA_CAST_STATE_INTERRUPTED";
            }
            else if (localPlayer.LastStaffCastCompleted)
            {
                castStateKey = "CA_CAST_STATE_COMPLETED";
            }
            String castStateLine = String.Format(
                "%s: %s %.2f/%.2fs   %s: %.0f",
                StringTable.Localize("CA_RESOURCE_CAST_STATE", false),
                StringTable.Localize(castStateKey, false),
                localPlayer.StaffCastCooldownRemaining,
                localPlayer.PendingStaffCastTotalSeconds,
                StringTable.Localize("CA_RESOURCE_RESERVED_ANIMA", false),
                localPlayer.PendingStaffAnimaCost
            );
            String interruptionLine = String.Format(
                "%s: %.2f%%/%.2f%%   %s: %.2f%%",
                StringTable.Localize("CA_RESOURCE_INTERRUPTION", false),
                localPlayer.LastStaffInterruptionChancePercent,
                localPlayer.LastStaffInterruptionRollPercent,
                StringTable.Localize("CA_RESOURCE_INTERRUPTION_RESISTANCE", false),
                derived.InterruptionResistancePercent
            );
            Screen.DrawText(DebugFont, Font.CR_PURPLE, 20.0, 62.0, staffDamageLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_CYAN, 20.0, 78.0, staffAccuracyLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 94.0, staffCriticalLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 110.0, staffResultLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_PURPLE, 20.0, 134.0, eloquenceLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_PURPLE, 20.0, 150.0, eloquenceUtilityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 174.0, activeEssenceLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 190.0, elementalEffectsLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 214.0, castStateLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 230.0, interruptionLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            return;
        }

        if (debugPage == 5)
        {
            CaelumCombatActor actor = LastInspectedCombatActor;
            if (actor == null)
            {
                Screen.DrawText(DebugFont, Font.CR_GRAY, 20.0, 62.0,
                    StringTable.Localize("CA_RESOURCE_ACTOR_NONE", false),
                    DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0,
                    DTA_KEEPRATIO, true);
                return;
            }

            String actorNameKey = "CA_ARGENTO_NAME";
            if (CaelumCaella(actor) != null) { actorNameKey = "CA_CAELLA_NAME"; }
            else if (CaelumRulo(actor) != null) { actorNameKey = "CA_RULO_NAME"; }
            else if (CaelumRonnie(actor) != null) { actorNameKey = "CA_RONNIE_NAME"; }
            String healthStateKey = actor.CombatHealthState
                == CaelumConstants.HEALTH_STATE_BADLY_WOUNDED
                ? "CA_HEALTH_STATE_BADLY_WOUNDED"
                : (actor.CombatHealthState == CaelumConstants.HEALTH_STATE_WOUNDED
                    ? "CA_HEALTH_STATE_WOUNDED" : "CA_HEALTH_STATE_NORMAL");
            String actorIdentityLine = String.Format(
                "%s: %s   %s: %d/%d (%s)",
                StringTable.Localize("CA_RESOURCE_ACTOR_LAST", false),
                StringTable.Localize(actorNameKey, false),
                StringTable.Localize("CA_HUD_HEALTH", false),
                Max(0, actor.health), actor.CombatMaximumHealth,
                StringTable.Localize(healthStateKey, false)
            );
            String actorPerformanceLine = String.Format(
                "%s: x%.3f   %s: %.2f/%.2f   %s: %.2f/%.2f",
                StringTable.Localize("CA_STAT_HEALTH_FACTOR", false),
                actor.CombatHealthPerformanceMultiplier,
                StringTable.Localize("CA_RESOURCE_ACTOR_SPEED", false),
                actor.Speed, actor.CombatBaseSpeed,
                StringTable.Localize("CA_HUD_ADRENALINE", false),
                actor.CurrentCombatAdrenaline, actor.MaximumCombatAdrenaline
            );
            String actorIntensityLine = String.Format(
                "%s: x%.3f   %s: x%.2f   %s: %.2f%%",
                StringTable.Localize("CA_RESOURCE_PAIN_RESISTANCE", false),
                actor.CombatHealthPainMultiplier,
                StringTable.Localize("CA_STAT_HEALTH_INTENSITY", false),
                actor.CombatAdrenalineGainMultiplier,
                StringTable.Localize("CA_RESOURCE_ACTOR_EVASION", false),
                actor.EffectiveCombatEvasionChance
            );
            String actorAttributesLine = String.Format(
                "%s: %d (%d)   %s: %d (%d)",
                StringTable.Localize("CA_ATTRIBUTE_DEXTERITY", false),
                actor.CombatDexterity, actor.CombatEffectiveDexterity,
                StringTable.Localize("CA_ATTRIBUTE_INSIGHT", false),
                actor.CombatInsight, actor.CombatEffectiveInsight
            );
            String actorAccuracyLine = String.Format(
                "%s: %.2f%%   %s: %.2f%%   %s: x%.2f",
                StringTable.Localize("CA_STAT_PHYSICAL_ACCURACY", false),
                actor.CombatPhysicalAccuracyPercent,
                StringTable.Localize("CA_STAT_MAGICAL_ACCURACY", false),
                actor.CombatMagicalAccuracyPercent,
                StringTable.Localize("CA_HUD_LUCIDITY", false),
                actor.CombatLucidityAccuracyMultiplier
            );
            String actorCriticalLine = String.Format(
                "%s: %.2f%%   %s: %.2f%%",
                StringTable.Localize("CA_STAT_PHYSICAL_CRITICAL", false),
                actor.CombatPhysicalCriticalChancePercent,
                StringTable.Localize("CA_STAT_MAGICAL_CRITICAL", false),
                actor.CombatMagicalCriticalChancePercent
            );
            String actorAttackLine = String.Format(
                "%s: %s   %d -> %d   %s",
                StringTable.Localize("CA_RESOURCE_ACTOR_ATTACK", false),
                StringTable.Localize(actor.LastCombatAttackMagical
                    ? "CA_RESOURCE_ACTOR_ATTACK_MAGIC"
                    : "CA_RESOURCE_ACTOR_ATTACK_PHYSICAL", false),
                actor.LastCombatAttackBaseDamage,
                actor.LastCombatAttackCalculatedDamage,
                StringTable.Localize(!actor.LastCombatAttackAttempted
                    ? "CA_CRITICAL_NOT_ATTEMPTED"
                    : (actor.LastCombatAttackAccuracySucceeded
                        ? "CA_ATTACK_HIT" : "CA_ATTACK_MISS"), false)
            );
            String actorAttackAccuracyLine = String.Format(
                "%s: %.2f%% / %.2f%% (%s)",
                StringTable.Localize("CA_RESOURCE_ACTOR_ACCURACY_ROLL", false),
                actor.LastCombatAttackAccuracyRollPercent,
                actor.LastCombatAttackAccuracyChancePercent,
                StringTable.Localize(actor.LastCombatAttackAccuracySucceeded
                    ? "CA_ATTACK_HIT" : "CA_ATTACK_MISS", false)
            );
            String actorAttackCriticalLine = String.Format(
                "%s: %.2f%% / %.2f%% (%s)",
                StringTable.Localize("CA_RESOURCE_CRITICAL_ROLL", false),
                actor.LastCombatAttackCriticalRollPercent,
                actor.LastCombatAttackCriticalChancePercent,
                StringTable.Localize(!actor.LastCombatAttackAccuracySucceeded
                    ? "CA_CRITICAL_NOT_ATTEMPTED"
                    : (actor.LastCombatAttackCriticalHit
                        ? "CA_CRITICAL_HIT" : "CA_CRITICAL_NORMAL"), false)
            );
            String incomingCriticalLine = String.Format(
                "%s: %.2f%% / %.2f%% (%s)",
                StringTable.Localize("CA_RESOURCE_ACTOR_INCOMING_CRITICAL", false),
                localPlayer.LastIncomingActorCriticalRollPercent,
                localPlayer.LastIncomingActorCriticalChancePercent,
                StringTable.Localize(localPlayer.LastIncomingActorCriticalHit
                    ? "CA_CRITICAL_HIT" : "CA_CRITICAL_NORMAL", false)
            );

            Screen.DrawText(DebugFont, Font.CR_LIGHTBLUE, 20.0, 62.0, actorIdentityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GREEN, 20.0, 82.0, actorPerformanceLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 102.0, actorIntensityLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_GOLD, 20.0, 130.0, actorAttributesLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_CYAN, 20.0, 150.0, actorAccuracyLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_ORANGE, 20.0, 170.0, actorCriticalLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 198.0, actorAttackLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_WHITE, 20.0, 218.0, actorAttackAccuracyLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 238.0, actorAttackCriticalLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            Screen.DrawText(DebugFont, Font.CR_RED, 20.0, 266.0, incomingCriticalLine,
                DTA_VIRTUALWIDTHF, 640.0, DTA_VIRTUALHEIGHTF, 360.0, DTA_KEEPRATIO, true);
            return;
        }

        /* Legacy full-panel layout retained temporarily as a reference while
           the compact pages are tested. Every valid page returns above, so
           this block is intentionally unreachable and cannot overflow the HUD.
        // Physical attributes: left column.
        DrawAttribute("CA_ATTRIBUTE_STRENGTH", attributes.Strength, 20.0, 58.0);
        DrawAttribute("CA_ATTRIBUTE_TOUGHNESS", attributes.Toughness, 20.0, 70.0);
        DrawAttribute("CA_ATTRIBUTE_CONSTITUTION", attributes.Constitution, 20.0, 82.0);

        // Technical attributes: second column.
        DrawAttribute("CA_ATTRIBUTE_DEXTERITY", attributes.Dexterity, 180.0, 58.0);
        DrawAttribute("CA_ATTRIBUTE_RESILIENCE", attributes.Resilience, 180.0, 70.0);
        DrawAttribute("CA_ATTRIBUTE_AGILITY", attributes.Agility, 180.0, 82.0);

        // Social attributes: third column.
        DrawAttribute("CA_ATTRIBUTE_CHARISMA", attributes.Charisma, 340.0, 58.0);
        DrawAttribute("CA_ATTRIBUTE_EMPATHY", attributes.Empathy, 340.0, 70.0);
        DrawAttribute("CA_ATTRIBUTE_ELOQUENCE", attributes.Eloquence, 340.0, 82.0);

        // Mental attributes: fourth column.
        DrawAttribute("CA_ATTRIBUTE_INTELLIGENCE", attributes.Intelligence, 500.0, 58.0);
        DrawAttribute("CA_ATTRIBUTE_PATIENCE", attributes.Patience, 500.0, 70.0);
        DrawAttribute("CA_ATTRIBUTE_INSIGHT", attributes.Insight, 500.0, 82.0);

        CaelumArmorModel armor = localPlayer.ArmorModel;
        if (armor != null)
        {
            int selectedSlot = armor.SelectedSlot;
            String criticalModeKey = localPlayer.DebugArmorCriticalHit
                ? "CA_ARMOR_HIT_CRITICAL"
                : "CA_ARMOR_HIT_NORMAL";
            String armorConfigLine = String.Format(
                "%s: %s / %s T%d   %s: %d%%   %s: +%d   %s: %d/%d   %s",
                StringTable.Localize("CA_RESOURCE_ARMOR", false),
                StringTable.Localize(GetArmorSlotKey(selectedSlot), false),
                StringTable.Localize(GetArmorDisplayKey(
                    selectedSlot, armor.ArmorType[selectedSlot]
                ), false),
                armor.Tier[selectedSlot],
                StringTable.Localize("CA_RESOURCE_ARMOR_DEFENSE", false),
                GetArmorDefenseForPanel(armor, selectedSlot),
                StringTable.Localize("CA_RESOURCE_ARMOR_REINFORCEMENT", false),
                GetArmorReinforcementForPanel(armor, selectedSlot),
                StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                armor.Durability[selectedSlot],
                GetArmorMaximumDurabilityForPanel(armor, selectedSlot),
                StringTable.Localize(criticalModeKey, false)
            );
            Screen.DrawText(
                DebugFont, Font.CR_PURPLE, 20.0, 94.0, armorConfigLine,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true
            );

            String armorHitLine = String.Format(
                "%s: %s x%.2f -> %.1f   %s: %.1f   %s: %d   %s: -%d (%.1f%% / %.1f%%)",
                StringTable.Localize("CA_RESOURCE_ARMOR_LAST_HIT", false),
                StringTable.Localize(GetVulnerabilityKey(localPlayer.LastArmorVulnerabilityGrade), false),
                localPlayer.LastArmorVulnerabilityMultiplier,
                localPlayer.LastArmorPreDefenseDamage,
                StringTable.Localize("CA_RESOURCE_ARMOR_ABSORBED", false),
                localPlayer.LastArmorAbsorbedDamage,
                StringTable.Localize("CA_RESOURCE_ARMOR_HEALTH_DAMAGE", false),
                localPlayer.LastArmorHealthDamage,
                StringTable.Localize("CA_RESOURCE_ARMOR_DURABILITY", false),
                localPlayer.LastArmorDurabilityLoss,
                localPlayer.LastArmorDurabilityRollPercent,
                localPlayer.LastArmorDurabilityChancePercent
            );
            Screen.DrawText(
                DebugFont, Font.CR_PURPLE, 20.0, 176.0, armorHitLine,
                DTA_VIRTUALWIDTHF, 640.0,
                DTA_VIRTUALHEIGHTF, 360.0,
                DTA_KEEPRATIO, true
            );
        }

        // Allocation status and currently selected targets.
        String layerAllocationLine = String.Format(
            "%s: %d/4   %s: %s",
            StringTable.Localize("CA_CREATION_LAYER_POINTS", false),
            allocation.GetRemainingLayerPoints(),
            StringTable.Localize("CA_CREATION_SELECTED_LAYER", false),
            StringTable.Localize(GetLayerKey(allocation.SelectedLayer), false)
        );

        String attributeAllocationLine = String.Format(
            "%s: %d/30   %s: %s (+%d)",
            StringTable.Localize("CA_CREATION_ATTRIBUTE_POINTS", false),
            allocation.GetRemainingAttributePoints(),
            StringTable.Localize("CA_CREATION_SELECTED_ATTRIBUTE", false),
            StringTable.Localize(GetAttributeKey(allocation.SelectedAttribute), false),
            allocation.AttributeBonus[allocation.SelectedAttribute]
        );

        Screen.DrawText(
            DebugFont, Font.CR_GREEN, 20.0, 106.0, layerAllocationLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            DebugFont, Font.CR_GREEN, 20.0, 120.0, attributeAllocationLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String animaResourceLine = String.Format(
            "%s: %.2f / %.2f   %s: %.3f/s (%.2f%%)",
            StringTable.Localize("CA_HUD_ANIMA", false),
            localPlayer.CurrentAnima,
            derived.MaximumAnima,
            StringTable.Localize("CA_RESOURCE_ANIMA_REGEN", false),
            derived.AnimaRegenerationPerSecond,
            derived.AnimaRegenerationPercent
        );

        Screen.DrawText(
            DebugFont, Font.CR_PURPLE, 20.0, 134.0, animaResourceLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String adrenalineResourceLine = String.Format(
            "%s: %.2f / %.2f   %s: %.2fs",
            StringTable.Localize("CA_HUD_ADRENALINE", false),
            localPlayer.CurrentAdrenaline,
            derived.MaximumAdrenaline,
            StringTable.Localize("CA_RESOURCE_COMBAT_TIME", false),
            localPlayer.CombatTimeRemaining
        );

        Screen.DrawText(
            DebugFont, Font.CR_GOLD, 20.0, 318.0, adrenalineResourceLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String lucidityResourceLine = String.Format(
            "%s: %.2f / %.2f   %s: x%.3f   %s: %.2fs",
            StringTable.Localize("CA_HUD_LUCIDITY", false),
            localPlayer.CurrentLucidity,
            CaelumConstants.MAXIMUM_LUCIDITY,
            StringTable.Localize("CA_RESOURCE_LUCIDITY_RESISTANCE", false),
            derived.LucidityLossMultiplier,
            StringTable.Localize("CA_RESOURCE_LUCIDITY_STUN_TIME", false),
            localPlayer.LucidityPhysicalStunRemaining
        );

        Screen.DrawText(
            DebugFont, Font.CR_CYAN, 20.0, 332.0, lucidityResourceLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String painResultKey = "CA_PAIN_RESISTED";
        if (localPlayer.LastPainTriggered)
        {
            painResultKey = "CA_PAIN_TRIGGERED";
        }
        String painResourceLine = String.Format(
            "%s: x%.4f   %s: %.2f%%   %s: %.2f%%   %s: %s",
            StringTable.Localize("CA_RESOURCE_PAIN_RESISTANCE", false),
            derived.PainChanceMultiplier,
            StringTable.Localize("CA_RESOURCE_LAST_HEALTH_LOSS", false),
            localPlayer.LastHealthLossPercent,
            StringTable.Localize("CA_RESOURCE_LAST_PAIN_CHANCE", false),
            localPlayer.LastPainChancePercent,
            StringTable.Localize("CA_RESOURCE_LAST_PAIN_RESULT", false),
            StringTable.Localize(painResultKey, false)
        );
        Screen.DrawText(
            DebugFont, Font.CR_ORANGE, 20.0, 346.0, painResourceLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String meleeResultKey = "CA_ATTACK_MISS";
        if (!localPlayer.LastMeleeHadEnoughAir
            && localPlayer.LastMeleeAirCost > 0.0)
        {
            meleeResultKey = "CA_ATTACK_NO_AIR";
        }
        else if (localPlayer.LastMeleeHit)
        {
            meleeResultKey = "CA_ATTACK_HIT";
        }
        String hitLocationKey = "CA_HIT_LOCATION_NONE";
        if (localPlayer.LastMeleeHitLocation == CaelumConstants.HIT_LOCATION_HEAD)
        {
            hitLocationKey = "CA_HIT_LOCATION_HEAD";
        }
        else if (localPlayer.LastMeleeHitLocation == CaelumConstants.HIT_LOCATION_TORSO)
        {
            hitLocationKey = "CA_HIT_LOCATION_TORSO";
        }
        else if (localPlayer.LastMeleeHitLocation == CaelumConstants.HIT_LOCATION_ARMS)
        {
            hitLocationKey = "CA_HIT_LOCATION_ARMS";
        }
        else if (localPlayer.LastMeleeHitLocation == CaelumConstants.HIT_LOCATION_LEGS)
        {
            hitLocationKey = "CA_HIT_LOCATION_LEGS";
        }
        String meleeResourceLine = String.Format(
            "%s: %.2f   %s: %d   %s: %s   %s: %s/%s x%.2f (%.1f%%)   %s: %.2f",
            StringTable.Localize("CA_RESOURCE_MELEE_DAMAGE", false),
            derived.DebugSwordDamage * localPlayer.EffectiveOffensiveDamageMultiplier,
            StringTable.Localize("CA_RESOURCE_MELEE_ACTUAL_DAMAGE", false),
            localPlayer.LastMeleeActualDamage,
            StringTable.Localize("CA_RESOURCE_MELEE_RESULT", false),
            StringTable.Localize(meleeResultKey, false),
            StringTable.Localize("CA_RESOURCE_HIT_LOCATION", false),
            StringTable.Localize(hitLocationKey, false),
            StringTable.Localize(GetVulnerabilityKey(localPlayer.LastMeleeVulnerabilityGrade), false),
            localPlayer.LastMeleeLocationMultiplier,
            localPlayer.LastMeleeHitHeightRatio * 100.0,
            StringTable.Localize("CA_RESOURCE_MELEE_AIR_COST", false),
            localPlayer.LastMeleeAirCost
        );
        Screen.DrawText(
            DebugFont, Font.CR_RED, 20.0, 304.0, meleeResourceLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String derivedLineOne = String.Format(
            "%s: %.2f (+%.3f/s)   %s: %.2f   %s: %.2f",
            StringTable.Localize("CA_STAT_MAX_HEALTH", false), derived.MaximumHealth,
            derived.HealthRegenerationPerSecond,
            StringTable.Localize("CA_STAT_MAX_ANIMA", false), derived.MaximumAnima,
            StringTable.Localize("CA_STAT_MAX_AIR", false), derived.MaximumAir
        );

        String derivedLineTwo = String.Format(
            "%s: %.2f   %s: %d",
            StringTable.Localize("CA_STAT_CARRY_CAPACITY", false), localPlayer.HUDCarryCapacity,
            StringTable.Localize("CA_STAT_BASE_MASS", false), derived.BaseMass
        );

        Screen.DrawText(
            DebugFont, Font.CR_GOLD, 20.0, 148.0, derivedLineOne,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            DebugFont, Font.CR_GOLD, 20.0, 162.0, derivedLineTwo,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String loadStateKey = "CA_LOAD_NORMAL";
        int loadColor = Font.CR_GREEN;

        if (localPlayer.HUDLoadRatio >= 1.0)
        {
            loadStateKey = "CA_LOAD_CAPACITY_EXCEEDED";
            loadColor = Font.CR_RED;
        }
        else if (localPlayer.HUDLoadRatio >= CaelumConstants.OVERLOAD_THRESHOLD)
        {
            loadStateKey = "CA_LOAD_OVERLOAD";
            loadColor = Font.CR_GOLD;
        }

        String massLine = String.Format(
            "%s: %.2f   %s: %.2f   %s: %.1f%% (%s)",
            StringTable.Localize("CA_STAT_CARRIED_WEIGHT", false), localPlayer.HUDCarriedWeight,
            StringTable.Localize("CA_STAT_TOTAL_MASS", false), derived.TotalMass,
            StringTable.Localize("CA_STAT_LOAD_PERCENT", false), localPlayer.HUDLoadRatio * 100.0,
            StringTable.Localize(loadStateKey, false)
        );

        String massEffectsLine = String.Format(
            "%s: x%.2f   %s: x%.2f   %s: x%.2f   %s: x%.2f",
            StringTable.Localize("CA_STAT_PUSH_RESISTANCE", false), derived.PushResistance,
            StringTable.Localize("CA_STAT_KNOCKBACK", false), derived.KnockbackMultiplier,
            StringTable.Localize("CA_STAT_MOVEMENT", false), derived.MovementMultiplier,
            StringTable.Localize("CA_STAT_AIR_USE", false), derived.AirConsumptionMultiplier
        );

        Screen.DrawText(
            DebugFont, loadColor, 20.0, 184.0, massLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            DebugFont, Font.CR_GRAY, 20.0, 198.0, massEffectsLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String airStateKey = "CA_AIR_STATE_NORMAL";
        int airColor = Font.CR_GREEN;

        if (localPlayer.AirState == CaelumConstants.AIR_STATE_BREATHLESS)
        {
            airStateKey = "CA_AIR_STATE_BREATHLESS";
            airColor = Font.CR_RED;
        }
        else if (localPlayer.AirState == CaelumConstants.AIR_STATE_TIRED)
        {
            airStateKey = "CA_AIR_STATE_TIRED";
            airColor = Font.CR_GOLD;
        }

        String airResourceLine = String.Format(
            "%s: %.2f / %.2f (%s)   %s: %.2f   %s: %.3f/s",
            StringTable.Localize("CA_RESOURCE_CURRENT_AIR", false), localPlayer.CurrentAir,
            derived.MaximumAir,
            StringTable.Localize(airStateKey, false),
            StringTable.Localize("CA_RESOURCE_TEST_AIR_COST", false),
            CaelumConstants.DEBUG_AIR_ACTION_COST * derived.AirConsumptionMultiplier,
            StringTable.Localize("CA_RESOURCE_AIR_REGEN", false),
            derived.AirRegenerationPerSecond
        );

        Screen.DrawText(
            DebugFont, airColor, 20.0, 220.0, airResourceLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String evasionLineOne = String.Format(
            "%s: %.3f%%   %s: %.3f%%",
            StringTable.Localize("CA_STAT_EVASION_BASE", false), derived.BaseEvasionChance,
            StringTable.Localize("CA_STAT_EVASION_AFTER_MASS", false),
            derived.MassAdjustedEvasionChance
        );

        String evasionLineTwo = String.Format(
            "%s: %.3f%%   %s: x%.2f",
            StringTable.Localize("CA_STAT_EVASION_EFFECTIVE", false),
            localPlayer.EffectiveEvasionChance,
            StringTable.Localize("CA_STAT_AIR_STATE_FACTOR", false),
            localPlayer.AirStatePerformanceMultiplier
        );

        String evasionResultKey = "CA_EVASION_NOT_ATTEMPTED";
        if (localPlayer.LastEvasionAttempted)
        {
            evasionResultKey = localPlayer.LastEvasionSucceeded
                ? "CA_EVASION_SUCCEEDED"
                : "CA_EVASION_FAILED";
        }
        evasionLineTwo = String.Format(
            "%s   %s: %s (%.2f%% / %.2f%%)",
            evasionLineTwo,
            StringTable.Localize("CA_RESOURCE_EVASION_LAST", false),
            StringTable.Localize(evasionResultKey, false),
            localPlayer.LastEvasionRollPercent,
            localPlayer.LastEvasionChancePercent
        );

        Screen.DrawText(
            DebugFont, Font.CR_WHITE, 20.0, 236.0, evasionLineOne,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            DebugFont, Font.CR_WHITE, 20.0, 250.0, evasionLineTwo,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String agilityMovementLine = String.Format(
            "%s: %.2f%% -> %.2f%%   %s: %.2f%% -> %.2f%%",
            StringTable.Localize("CA_STAT_MOVEMENT_AGILITY", false),
            derived.BaseMovementPercent, localPlayer.EffectiveMovementPercent,
            StringTable.Localize("CA_STAT_JUMP_HEIGHT", false),
            derived.BaseJumpHeightPercent, localPlayer.EffectiveJumpHeightPercent
        );

        String runStateKey = localPlayer.IsSpendingRunningAir
            ? "CA_RESOURCE_RUN_ACTIVE"
            : "CA_RESOURCE_RUN_INACTIVE";

        String jumpCostLine = String.Format(
            "%s: %.2f   %s: %.2f/s (%s)",
            StringTable.Localize("CA_RESOURCE_JUMP_COST", false),
            CaelumConstants.JUMP_AIR_COST * derived.AirConsumptionMultiplier,
            StringTable.Localize("CA_RESOURCE_RUN_COST", false),
            CaelumConstants.RUN_AIR_COST_PER_SECOND * derived.AirConsumptionMultiplier,
            StringTable.Localize(runStateKey, false)
        );

        Screen.DrawText(
            DebugFont, Font.CR_WHITE, 20.0, 266.0, agilityMovementLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        Screen.DrawText(
            DebugFont, Font.CR_WHITE, 20.0, 280.0, jumpCostLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );

        String appliedMovementLine = String.Format(
            "%s: x%.3f   %s: %.3f   %s: x%.2f->x%.2f   %s: x%.2f->x%.2f   %s: x%.2f",
            StringTable.Localize("CA_STAT_APPLIED_MOVEMENT", false),
            localPlayer.ForwardMove2,
            StringTable.Localize("CA_STAT_APPLIED_JUMP_Z", false),
            localPlayer.JumpZ,
            StringTable.Localize("CA_STAT_SURVIVAL_FACTOR", false),
            localPlayer.SurvivalRawPerformanceMultiplier,
            localPlayer.SurvivalPerformanceMultiplier,
            StringTable.Localize("CA_STAT_HEALTH_FACTOR", false),
            localPlayer.HealthRawPerformanceMultiplier,
            localPlayer.HealthPerformanceMultiplier,
            StringTable.Localize("CA_STAT_HEALTH_INTENSITY", false),
            localPlayer.HealthPainMultiplier
        );

        Screen.DrawText(
            DebugFont, Font.CR_LIGHTBLUE, 20.0, 296.0, appliedMovementLine,
            DTA_VIRTUALWIDTHF, 640.0,
            DTA_VIRTUALHEIGHTF, 360.0,
            DTA_KEEPRATIO, true
        );
        */
    }

    // KEYCONF aliases send synchronized events here. e.Player identifies the
    // player who pressed the bound key, which is important for future co-op.
    override void NetworkProcess(ConsoleEvent e)
    {
        CaelumPlayer requestingPlayer = CaelumPlayer(players[e.Player].mo);

        if (requestingPlayer == null || requestingPlayer.CharacterProfile == null)
        {
            return;
        }

        if (e.Name == "ca_equipment_toggle")
        {
            requestingPlayer.ToggleEquipmentMenu();
        }
        else if (e.Name == "ca_crafting_toggle")
        {
            requestingPlayer.ToggleCraftingMenu();
        }
        else if (e.Name == "ca_crafting_recipe_next")
        {
            requestingPlayer.CycleCraftingRecipe(1);
        }
        else if (e.Name == "ca_crafting_recipe_previous")
        {
            requestingPlayer.CycleCraftingRecipe(-1);
        }
        else if (e.Name == "ca_crafting_tier")
        {
            requestingPlayer.CycleCraftingTier();
        }
        else if (e.Name == "ca_crafting_size")
        {
            requestingPlayer.CycleCraftingSize();
        }
        else if (e.Name == "ca_crafting_create")
        {
            requestingPlayer.CraftSelectedPhysicalWeapon();
        }
        else if (e.Name == "ca_crafting_spawn_materials")
        {
            requestingPlayer.SpawnSelectedCraftingMaterials();
        }
        else if (e.Name == "ca_equipment_kind")
        {
            requestingPlayer.CycleEquipmentKind();
        }
        else if (e.Name == "ca_equipment_slot_next")
        {
            requestingPlayer.CycleEquipmentSlot(1);
        }
        else if (e.Name == "ca_equipment_slot_previous")
        {
            requestingPlayer.CycleEquipmentSlot(-1);
        }
        else if (e.Name == "ca_equipment_type_next")
        {
            requestingPlayer.CycleEquipmentType(1);
        }
        else if (e.Name == "ca_equipment_type_previous")
        {
            requestingPlayer.CycleEquipmentType(-1);
        }
        else if (e.Name == "ca_equipment_tier")
        {
            requestingPlayer.CycleEquipmentTier();
        }
        else if (e.Name == "ca_equipment_size")
        {
            requestingPlayer.CycleEquipmentSize();
        }
        else if (e.Name == "ca_equipment_equip")
        {
            requestingPlayer.EquipSelectedEquipment();
        }
        else if (e.Name == "ca_equipment_unequip")
        {
            requestingPlayer.UnequipSelectedEquipment();
        }
        else if (e.Name == "ca_equipment_magic_box")
        {
            requestingPlayer.ToggleSelectedMagicBox();
        }
        else if (e.Name == "ca_equipment_drop")
        {
            requestingPlayer.DropSelectedEquipment();
        }
        else if (e.Name == "ca_equipment_break")
        {
            requestingPlayer.BreakSelectedEquipment();
        }
        else if (e.Name == "ca_debug_spawn_equipment")
        {
            requestingPlayer.SpawnDebugEquipmentPickup();
        }
        else if (e.Name == "ca_debug_test_silver_lock")
        {
            requestingPlayer.DebugTestSilverLock();
        }
        else if (e.Name == "ca_debug_audit_crafting_catalogue")
        {
            requestingPlayer.DebugAuditCraftingCatalogue();
        }
        else if (e.Name == "ca_next_race") requestingPlayer.CycleRace();
        else if (e.Name == "ca_next_first_class") requestingPlayer.CycleFirstClass();
        else if (e.Name == "ca_next_second_class") requestingPlayer.CycleSecondClass();
        else if (e.Name == "ca_next_sex") requestingPlayer.CycleSex();
        else if (e.Name == "ca_next_height") requestingPlayer.CycleHeightChoice();
        else if (e.Name == "ca_select_next_layer")
        {
            requestingPlayer.CycleAllocationLayer();
        }
        else if (e.Name == "ca_add_layer_point")
        {
            requestingPlayer.AddSelectedLayerPoint();
        }
        else if (e.Name == "ca_select_next_attribute")
        {
            requestingPlayer.CycleAllocationAttribute();
        }
        else if (e.Name == "ca_add_attribute_point")
        {
            requestingPlayer.AddSelectedAttributePoint();
        }
        else if (e.Name == "ca_reset_allocations")
        {
            requestingPlayer.ResetCreationAllocations();
        }
        else if (e.Name == "ca_creation_open")
        {
            requestingPlayer.BeginCreationWizard();
        }
        else if (e.Name == "ca_creation_next_choice")
        {
            requestingPlayer.CycleCurrentCreationChoice();
        }
        else if (e.Name == "ca_creation_confirm")
        {
            requestingPlayer.AdvanceCreationWizard();
        }
        else if (e.Name == "ca_creation_back")
        {
            requestingPlayer.GoBackCreationWizard();
        }
        else if (e.Name == "ca_creation_add_point")
        {
            requestingPlayer.AddCurrentCreationPoint();
        }
        else if (e.Name == "ca_debug_add_weight")
        {
            requestingPlayer.AddDebugEquipmentWeight();
        }
        else if (e.Name == "ca_debug_reset_weight")
        {
            requestingPlayer.ResetDebugEquipmentWeight();
        }
        else if (e.Name == "ca_debug_consume_air")
        {
            requestingPlayer.ConsumeDebugAir();
        }
        else if (e.Name == "ca_debug_refill_air")
        {
            requestingPlayer.RefillAir();
        }
        else if (e.Name == "ca_debug_jump_air")
        {
            requestingPlayer.ConsumeDebugJumpAir();
        }
        else if (e.Name == "ca_debug_consume_anima")
        {
            requestingPlayer.ConsumeDebugAnima();
        }
        else if (e.Name == "ca_debug_refill_anima")
        {
            requestingPlayer.RefillAnima();
        }
        else if (e.Name == "ca_debug_add_adrenaline")
        {
            requestingPlayer.AddDebugAdrenaline();
        }
        else if (e.Name == "ca_debug_clear_adrenaline")
        {
            requestingPlayer.ClearDebugAdrenaline();
        }
        else if (e.Name == "ca_debug_pain_damage")
        {
            requestingPlayer.ApplyDebugPainDamage();
        }
        else if (e.Name == "ca_debug_evasion_attack")
        {
            requestingPlayer.ApplyDebugEvasionAttack();
        }
        else if (e.Name == "ca_debug_attributes_75")
        {
            requestingPlayer.ToggleDebugAttributes75();
        }
        else if (e.Name == "ca_debug_attributes_100")
        {
            requestingPlayer.ToggleDebugAttributes100();
        }
        else if (e.Name == "ca_debug_health_state")
        {
            requestingPlayer.CycleDebugHealthState();
        }
        else if (e.Name == "ca_debug_heal_health")
        {
            requestingPlayer.HealDebugHealth();
        }
        else if (e.Name == "ca_debug_next_page")
        {
            requestingPlayer.CycleDebugPanelPage();
        }
        else if (e.Name == "ca_debug_sword_attack")
        {
            requestingPlayer.PerformDebugSwordAttack(false);
        }
        else if (e.Name == "ca_debug_staff_attack")
        {
            requestingPlayer.PerformDebugStaffAttack(false);
        }
        else if (e.Name == "ca_debug_armor_slot")
        {
            requestingPlayer.CycleDebugArmorSlot();
        }
        else if (e.Name == "ca_debug_armor_type")
        {
            requestingPlayer.CycleDebugArmorType();
        }
        else if (e.Name == "ca_debug_armor_tier")
        {
            requestingPlayer.CycleDebugArmorTier();
        }
        else if (e.Name == "ca_debug_armor_critical")
        {
            requestingPlayer.ToggleDebugArmorCritical();
        }
        else if (e.Name == "ca_debug_armor_hit")
        {
            requestingPlayer.ApplyDebugArmorHit();
        }
        else if (e.Name == "ca_debug_armor_repair")
        {
            requestingPlayer.RepairDebugArmor();
        }
        else if (e.Name == "ca_debug_lose_lucidity")
        {
            requestingPlayer.LoseDebugLucidity();
        }
        else if (e.Name == "ca_debug_refill_lucidity")
        {
            requestingPlayer.RefillLucidity();
        }
        else if (e.Name == "ca_debug_lucidity_state")
        {
            requestingPlayer.CycleDebugLucidityState();
        }
        else if (e.Name == "ca_debug_lose_hunger")
        {
            requestingPlayer.LoseDebugHunger();
        }
        else if (e.Name == "ca_debug_lose_thirst")
        {
            requestingPlayer.LoseDebugThirst();
        }
        else if (e.Name == "ca_debug_lose_sleep")
        {
            requestingPlayer.LoseDebugSleep();
        }
        else if (e.Name == "ca_debug_refill_survival")
        {
            requestingPlayer.RefillSurvivalResources();
        }
        else if (e.Name == "ca_debug_spawn_dummy")
        {
            requestingPlayer.SpawnDebugTrainingDummy();
        }
        else if (e.Name == "ca_debug_spawn_argento")
        {
            requestingPlayer.SpawnDebugArgento();
        }
        else if (e.Name == "ca_debug_spawn_caella")
        {
            requestingPlayer.SpawnDebugCaella();
        }
        else if (e.Name == "ca_debug_spawn_rulo")
        {
            requestingPlayer.SpawnDebugRulo();
        }
        else if (e.Name == "ca_debug_spawn_ronnie")
        {
            requestingPlayer.SpawnDebugRonnie();
        }
        else if (e.Name == "ca_debug_actor_health_state")
        {
            if (LastInspectedCombatActor != null)
            {
                LastInspectedCombatActor.CycleDebugCombatHealthState();
            }
        }
        else if (e.Name == "ca_debug_actor_lucidity_state")
        {
            if (LastInspectedCombatActor != null)
            {
                LastInspectedCombatActor.CycleDebugCombatLucidityState();
            }
        }
        else if (e.Name == "ca_debug_shield_type")
        {
            requestingPlayer.CycleDebugShieldType();
        }
        else if (e.Name == "ca_debug_shield_tier")
        {
            requestingPlayer.CycleDebugShieldTier();
        }
        else if (e.Name == "ca_debug_shield_block")
        {
            requestingPlayer.ToggleDebugShieldBlock();
        }
        else if (e.Name == "ca_debug_shield_damage")
        {
            requestingPlayer.ToggleDebugShieldDamageKind();
        }
        else if (e.Name == "ca_debug_shield_angle")
        {
            requestingPlayer.CycleDebugShieldIncomingAngle();
        }
        else if (e.Name == "ca_debug_shield_hit")
        {
            requestingPlayer.ApplyDebugShieldHit();
        }
        else if (e.Name == "ca_debug_shield_repair")
        {
            requestingPlayer.RepairDebugShield();
        }
    }
}
