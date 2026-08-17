// Reglas compartidas de talle y tier para todo objeto equipable.
class CaelumEquipmentRules : Object
{
    static double GetTierWeightMultiplier(int tier)
    {
        if (tier <= 1) { return 1.0; }
        if (tier == 2) { return 1.5; }
        return 2.0;
    }

    static double GetSizeWeightMultiplier(int equipmentSize)
    {
        switch (Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1))
        {
            case CaelumConstants.EQUIPMENT_SIZE_XS: return 0.50;
            case CaelumConstants.EQUIPMENT_SIZE_S: return 0.75;
            case CaelumConstants.EQUIPMENT_SIZE_L: return 1.25;
            case CaelumConstants.EQUIPMENT_SIZE_XL: return 1.50;
            default: return 1.00;
        }
    }

    static bool IsSizeCompatible(int equipmentSize, int characterSizeTier)
    {
        int sizeTier = Clamp(characterSizeTier, 1, 7);
        switch (Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1))
        {
            case CaelumConstants.EQUIPMENT_SIZE_XS: return sizeTier <= 2;
            case CaelumConstants.EQUIPMENT_SIZE_S: return sizeTier >= 2 && sizeTier <= 3;
            case CaelumConstants.EQUIPMENT_SIZE_M: return sizeTier >= 3 && sizeTier <= 5;
            case CaelumConstants.EQUIPMENT_SIZE_L: return sizeTier >= 5 && sizeTier <= 6;
            default: return sizeTier >= 6;
        }
    }

    static int GetDefaultSizeForCharacterTier(int characterSizeTier)
    {
        int sizeTier = Clamp(characterSizeTier, 1, 7);
        if (sizeTier <= 2) { return CaelumConstants.EQUIPMENT_SIZE_XS; }
        if (sizeTier <= 5) { return CaelumConstants.EQUIPMENT_SIZE_M; }
        if (sizeTier == 6) { return CaelumConstants.EQUIPMENT_SIZE_L; }
        return CaelumConstants.EQUIPMENT_SIZE_XL;
    }

    static double CalculateTieredEquipmentWeight(
        double tierOneBaseWeight,
        int tier,
        int equipmentSize
    )
    {
        return Max(0.0, tierOneBaseWeight)
            * GetTierWeightMultiplier(tier)
            * GetSizeWeightMultiplier(equipmentSize);
    }

    static int ScaleDurabilityForSize(int baseDurability, int equipmentSize)
    {
        return Max(1, int(baseDurability * GetSizeWeightMultiplier(equipmentSize) + 0.5));
    }
}
