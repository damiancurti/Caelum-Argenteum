// Provisional four-slot armor data used by the localized combat test.
// The model is independent from Doom's native armor inventory so the final
// equipment UI can later adopt it without inheriting Doom-specific behavior.
class CaelumArmorModel : Object
{
    int ArmorType[4];
    int Tier[4];
    int Durability[4];
    int SelectedSlot;
    bool Initialized;

    void InitializeDefaults()
    {
        if (Initialized)
        {
            return;
        }

        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            ArmorType[slot] = CaelumConstants.ARMOR_TYPE_UNARMORED;
            Tier[slot] = 1;
            Durability[slot] = GetMaximumDurability(slot);
        }

        SelectedSlot = CaelumConstants.ARMOR_SLOT_HEAD;
        Initialized = true;
    }

    // Original actors use the same four-slot model as the player test.  A
    // loadout initializes every piece together, while the arrays remain
    // independent so one struck region can break without affecting the rest.
    void InitializeUniformLoadout(int requestedArmorType, int requestedTier)
    {
        int resolvedType = Clamp(
            requestedArmorType,
            CaelumConstants.ARMOR_TYPE_UNARMORED,
            CaelumConstants.ARMOR_TYPE_HEAVY
        );
        int resolvedTier = Clamp(requestedTier, 1, 3);
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            ArmorType[slot] = resolvedType;
            Tier[slot] = resolvedTier;
            Durability[slot] = GetMaximumDurability(slot);
        }
        SelectedSlot = CaelumConstants.ARMOR_SLOT_HEAD;
        Initialized = true;
    }

    int GetTierBonus(int slot)
    {
        if (Tier[slot] == 1) { return 5; }
        if (Tier[slot] == 2) { return 10; }
        return 20;
    }

    int GetDefense(int slot)
    {
        if (Durability[slot] <= 0) { return 0; }
        int tier = Clamp(Tier[slot], 1, 3);
        switch (ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_UNARMORED:
                if (tier == 1) { return 5; }
                if (tier == 2) { return 10; }
                return 15;
            case CaelumConstants.ARMOR_TYPE_LIGHT:
                if (tier == 1) { return 10; }
                if (tier == 2) { return 20; }
                return 30;
            case CaelumConstants.ARMOR_TYPE_MEDIUM:
                if (tier == 1) { return 20; }
                if (tier == 2) { return 40; }
                return 60;
            default:
                if (tier == 1) { return 30; }
                if (tier == 2) { return 60; }
                return 90;
        }
    }

    int GetReinforcement(int slot)
    {
        if (Durability[slot] <= 0) { return 0; }
        switch (ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_UNARMORED:
                return slot == CaelumConstants.ARMOR_SLOT_BODY ? 1 : 0;
            case CaelumConstants.ARMOR_TYPE_LIGHT:
                return (slot == CaelumConstants.ARMOR_SLOT_HEAD
                    || slot == CaelumConstants.ARMOR_SLOT_BODY) ? 1 : 0;
            case CaelumConstants.ARMOR_TYPE_MEDIUM:
                return slot == CaelumConstants.ARMOR_SLOT_HANDS ? 0 : 2;
            default:
                return 3;
        }
    }

    int GetBonusAttribute(int slot)
    {
        if (Durability[slot] <= 0) { return -1; }
        if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_UNARMORED)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD) { return CaelumConstants.ATTRIBUTE_INTELLIGENCE; }
            if (slot == CaelumConstants.ARMOR_SLOT_HANDS) { return CaelumConstants.ATTRIBUTE_PATIENCE; }
            if (slot == CaelumConstants.ARMOR_SLOT_FEET) { return CaelumConstants.ATTRIBUTE_INSIGHT; }
        }
        else if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_LIGHT)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HANDS) { return CaelumConstants.ATTRIBUTE_DEXTERITY; }
            if (slot == CaelumConstants.ARMOR_SLOT_FEET) { return CaelumConstants.ATTRIBUTE_AGILITY; }
        }
        else if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_MEDIUM
            && slot == CaelumConstants.ARMOR_SLOT_HANDS)
        {
            return CaelumConstants.ATTRIBUTE_DEXTERITY;
        }

        return -1;
    }

    void ApplyAttributeBonuses(CaelumAttributes attributes)
    {
        if (attributes == null)
        {
            return;
        }

        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            int amount = GetTierBonus(slot);
            switch (GetBonusAttribute(slot))
            {
                case CaelumConstants.ATTRIBUTE_DEXTERITY: attributes.Dexterity += amount; break;
                case CaelumConstants.ATTRIBUTE_AGILITY: attributes.Agility += amount; break;
                case CaelumConstants.ATTRIBUTE_INTELLIGENCE: attributes.Intelligence += amount; break;
                case CaelumConstants.ATTRIBUTE_PATIENCE: attributes.Patience += amount; break;
                case CaelumConstants.ATTRIBUTE_INSIGHT: attributes.Insight += amount; break;
            }
        }
    }

    int GetBaseDurability(int slot)
    {
        switch (ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_UNARMORED: return 20;
            case CaelumConstants.ARMOR_TYPE_LIGHT: return 40;
            case CaelumConstants.ARMOR_TYPE_MEDIUM: return 60;
            default: return 100;
        }
    }

    int GetMaximumDurability(int slot)
    {
        int multiplier = 1;
        if (Tier[slot] == 2) { multiplier = 3; }
        else if (Tier[slot] >= 3) { multiplier = 9; }
        return GetBaseDurability(slot) * multiplier;
    }

    void CycleSelectedSlot()
    {
        SelectedSlot = (SelectedSlot + 1) % CaelumConstants.ARMOR_SLOT_COUNT;
    }

    void CycleSelectedType()
    {
        ArmorType[SelectedSlot] = (ArmorType[SelectedSlot] + 1)
            % CaelumConstants.ARMOR_TYPE_COUNT;
        Durability[SelectedSlot] = GetMaximumDurability(SelectedSlot);
    }

    void CycleSelectedTier()
    {
        Tier[SelectedSlot]++;
        if (Tier[SelectedSlot] > 3) { Tier[SelectedSlot] = 1; }
        Durability[SelectedSlot] = GetMaximumDurability(SelectedSlot);
    }

    void RepairSelectedPiece()
    {
        Durability[SelectedSlot] = GetMaximumDurability(SelectedSlot);
    }
}
