// Registro invisible que viaja en el inventario real de GZDoom.
// Conserva el perfil confirmado, los recursos y la propiedad del equipo entre
// mapas sin convertir los controles temporales en objetos visibles todavia.
class CaelumPersistentCharacterState : Inventory
{
    bool ProfileCommitted;
    int Race;
    int FirstClass;
    int SecondClass;
    int Sex;
    int HeightChoice;
    int LayerBonus[4];
    int AttributeBonus[12];

    bool EquipmentInitialized;
    int ArmorType[4];
    int ArmorTier[4];
    int ArmorSize[4];
    int ArmorDurability[4];
    int ArmorSelectedSlot;
    int ShieldType;
    int ShieldTier;
    int ShieldSize;
    int ShieldDurability;
    bool ShieldEquipped;
    double EquippedWeaponBaseWeight;
    int EquippedWeaponTier;
    int EquippedWeaponSize;
    bool OwnedArmor[48];
    bool OwnedShield[12];
    int OwnedArmorDurability[48];
    int OwnedShieldDurability[12];
    bool OwnershipDurabilityInitialized;
    // Los registros antiguos se conservan para migrar partidas 4.5 al talle M.
    bool SizedOwnedArmor[300];
    bool SizedOwnedShield[60];
    int SizedOwnedArmorDurability[300];
    int SizedOwnedShieldDurability[60];
    bool EquipmentSizeInitialized;
    bool WeaponWeightInitialized;

    int StoredHealth;
    double StoredAnima;
    double StoredAir;
    double StoredAdrenaline;
    double StoredLucidity;
    double StoredHunger;
    double StoredThirst;
    double StoredSleep;

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVENTORY.KEEPDEPLETED
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }

    int GetArmorOwnershipIndex(int slot, int armorType, int tier)
    {
        return Clamp(slot, 0, 3) * 12
            + Clamp(armorType, 0, 3) * 3
            + Clamp(tier, 1, 3) - 1;
    }

    int GetShieldOwnershipIndex(int shieldType, int tier)
    {
        return Clamp(shieldType, 0, 3) * 3 + Clamp(tier, 1, 3) - 1;
    }

    int GetSizedArmorOwnershipIndex(int slot, int armorType, int tier, int equipmentSize)
    {
        return (((Clamp(slot, 0, 3) * CaelumConstants.ARMOR_TYPE_COUNT
            + Clamp(armorType, 0, CaelumConstants.ARMOR_TYPE_COUNT - 1)) * 3
            + Clamp(tier, 1, 3) - 1) * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    int GetSizedShieldOwnershipIndex(int shieldType, int tier, int equipmentSize)
    {
        return ((Clamp(shieldType, 0, 3) * 3 + Clamp(tier, 1, 3) - 1)
            * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    // Migra registros creados antes de que cada objeto guardara su propia
    // durabilidad. Solo se ejecuta una vez; después, cero vuelve a significar
    // correctamente que ese objeto está roto.
    void EnsureOwnershipDurabilityInitialized()
    {
        if (OwnershipDurabilityInitialized) { return; }
        // Los registros 4.3 siempre representaban un escudo equipado.
        ShieldEquipped = true;
        for (int index = 0; index < 48; index++)
        {
            if (!OwnedArmor[index]) { continue; }
            int armorType = (index % 12) / 3;
            int tier = index % 3 + 1;
            int baseDurability = 20;
            if (armorType == CaelumConstants.ARMOR_TYPE_LIGHT) { baseDurability = 40; }
            else if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM) { baseDurability = 60; }
            else if (armorType == CaelumConstants.ARMOR_TYPE_HEAVY) { baseDurability = 100; }
            int multiplier = tier == 1 ? 1 : (tier == 2 ? 3 : 9);
            OwnedArmorDurability[index] = baseDurability * multiplier;
        }
        for (int shieldIndex = 0; shieldIndex < 12; shieldIndex++)
        {
            if (!OwnedShield[shieldIndex]) { continue; }
            int shieldType = shieldIndex / 3;
            int tier = shieldIndex % 3 + 1;
            int baseDurability = 100;
            if (shieldType == CaelumConstants.SHIELD_TYPE_BUCKLER) { baseDurability = 80; }
            else if (shieldType == CaelumConstants.SHIELD_TYPE_KITE) { baseDurability = 150; }
            else if (shieldType == CaelumConstants.SHIELD_TYPE_TOWER) { baseDurability = 250; }
            int multiplier = tier == 1 ? 1 : (tier == 2 ? 3 : 9);
            OwnedShieldDurability[shieldIndex] = baseDurability * multiplier;
        }
        OwnershipDurabilityInitialized = true;
    }

    // Las partidas anteriores no guardaban talle. Todo su equipo pasa a M,
    // que conserva exactamente el peso y la durabilidad documentados entonces.
    void EnsureEquipmentSizeInitialized()
    {
        EnsureOwnershipDurabilityInitialized();
        if (EquipmentSizeInitialized) { return; }
        for (int slot = 0; slot < 4; slot++)
        {
            ArmorSize[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
        }
        ShieldSize = CaelumConstants.EQUIPMENT_SIZE_M;
        for (int oldArmorIndex = 0; oldArmorIndex < 48; oldArmorIndex++)
        {
            if (!OwnedArmor[oldArmorIndex]) { continue; }
            int slot = oldArmorIndex / 12;
            int armorType = (oldArmorIndex % 12) / 3;
            int tier = oldArmorIndex % 3 + 1;
            int newIndex = GetSizedArmorOwnershipIndex(
                slot, armorType, tier, CaelumConstants.EQUIPMENT_SIZE_M
            );
            SizedOwnedArmor[newIndex] = true;
            SizedOwnedArmorDurability[newIndex] = OwnedArmorDurability[oldArmorIndex];
        }
        for (int oldShieldIndex = 0; oldShieldIndex < 12; oldShieldIndex++)
        {
            if (!OwnedShield[oldShieldIndex]) { continue; }
            int shieldType = oldShieldIndex / 3;
            int tier = oldShieldIndex % 3 + 1;
            int newIndex = GetSizedShieldOwnershipIndex(
                shieldType, tier, CaelumConstants.EQUIPMENT_SIZE_M
            );
            SizedOwnedShield[newIndex] = true;
            SizedOwnedShieldDurability[newIndex] = OwnedShieldDurability[oldShieldIndex];
        }
        EquipmentSizeInitialized = true;
    }

    void MarkCurrentEquipmentOwned()
    {
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
            {
                continue;
            }
            int armorIndex = GetSizedArmorOwnershipIndex(
                slot,
                ArmorType[slot],
                ArmorTier[slot],
                ArmorSize[slot]
            );
            SizedOwnedArmor[armorIndex] = true;
            SizedOwnedArmorDurability[armorIndex] = ArmorDurability[slot];
        }
        if (ShieldEquipped)
        {
            int shieldIndex = GetSizedShieldOwnershipIndex(
                ShieldType, ShieldTier, ShieldSize
            );
            SizedOwnedShield[shieldIndex] = true;
            SizedOwnedShieldDurability[shieldIndex] = ShieldDurability;
        }
    }

    bool RegisterOwnedArmor(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedArmor[index];
        SizedOwnedArmor[index] = true;
        SizedOwnedArmorDurability[index] = Max(
            SizedOwnedArmorDurability[index],
            Max(0, durability)
        );
        return newlyOwned;
    }

    bool RegisterOwnedShield(int shieldType, int tier, int equipmentSize, int durability)
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedShield[index];
        SizedOwnedShield[index] = true;
        SizedOwnedShieldDurability[index] = Max(
            SizedOwnedShieldDurability[index],
            Max(0, durability)
        );
        return newlyOwned;
    }

    bool OwnsArmor(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedOwnedArmor[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    bool OwnsShield(int shieldType, int tier, int equipmentSize)
    {
        return SizedOwnedShield[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    int GetOwnedArmorDurability(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedOwnedArmorDurability[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    int GetOwnedShieldDurability(int shieldType, int tier, int equipmentSize)
    {
        return SizedOwnedShieldDurability[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    void StoreOwnedArmorDurability(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        if (SizedOwnedArmor[index])
        {
            SizedOwnedArmorDurability[index] = Max(0, durability);
        }
    }

    void StoreOwnedShieldDurability(
        int shieldType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        if (SizedOwnedShield[index])
        {
            SizedOwnedShieldDurability[index] = Max(0, durability);
        }
    }

    void RemoveOwnedArmor(int slot, int armorType, int tier, int equipmentSize)
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        SizedOwnedArmor[index] = false;
        SizedOwnedArmorDurability[index] = 0;
    }

    void RemoveOwnedShield(int shieldType, int tier, int equipmentSize)
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        SizedOwnedShield[index] = false;
        SizedOwnedShieldDurability[index] = 0;
    }

    int CountOwnedArmor()
    {
        int total = 0;
        for (int i = 0; i < 300; i++) { if (SizedOwnedArmor[i]) total++; }
        return total;
    }

    int CountOwnedShields()
    {
        int total = 0;
        for (int i = 0; i < 60; i++) { if (SizedOwnedShield[i]) total++; }
        return total;
    }
}
