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
    int ArmorDurability[4];
    int ArmorSelectedSlot;
    int ShieldType;
    int ShieldTier;
    int ShieldDurability;
    bool OwnedArmor[48];
    bool OwnedShield[12];

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

    void MarkCurrentEquipmentOwned()
    {
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            OwnedArmor[GetArmorOwnershipIndex(
                slot,
                ArmorType[slot],
                ArmorTier[slot]
            )] = true;
        }
        OwnedShield[GetShieldOwnershipIndex(ShieldType, ShieldTier)] = true;
    }

    int CountOwnedArmor()
    {
        int total = 0;
        for (int i = 0; i < 48; i++) { if (OwnedArmor[i]) total++; }
        return total;
    }

    int CountOwnedShields()
    {
        int total = 0;
        for (int i = 0; i < 12; i++) { if (OwnedShield[i]) total++; }
        return total;
    }
}
