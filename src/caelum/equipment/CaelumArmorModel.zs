// Modelo provisional de cuatro piezas para las pruebas de combate localizado.
// Es independiente de la armadura nativa de Doom para facilitar la futura UI.
class CaelumArmorModel : Object
{
    int ArmorType[4];
    int Tier[4];
    int Size[4];
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
            // Antes de confirmar la ficha solo existe la ropa corporal base.
            ArmorType[slot] = CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            Tier[slot] = 1;
            Size[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            Durability[slot] = 0;
        }

        SelectedSlot = CaelumConstants.ARMOR_SLOT_HEAD;
        Initialized = true;
    }

    // Los actores originales usan las mismas cuatro piezas que el jugador.
    // Cada pieza conserva durabilidad independiente por region golpeada.
    void InitializeUniformLoadout(int requestedArmorType, int requestedTier)
    {
        int resolvedType = Clamp(
            requestedArmorType,
            CaelumConstants.ARMOR_TYPE_MAGIC,
            CaelumConstants.ARMOR_TYPE_HEAVY
        );
        int resolvedTier = Clamp(requestedTier, 1, 3);
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            ArmorType[slot] = resolvedType;
            Tier[slot] = resolvedTier;
            Size[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
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
        if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING) { return 0; }
        if (Durability[slot] <= 0) { return 0; }
        int tier = Clamp(Tier[slot], 1, 3);
        switch (ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_MAGIC:
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

    // El peso pertenece a la pieza equipada aunque su durabilidad llegue a cero.
    // La tabla final distribuye el total entre cabeza, cuerpo, brazos y piernas;
    // los nombres internos HANDS/FEET representan brazos/piernas en este modelo.
    double GetMediumSizeWeightFor(int slot, int armorType, int tier)
    {
        int resolvedType = Clamp(armorType, 0, CaelumConstants.ARMOR_TYPE_COUNT - 1);
        if (resolvedType == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING) return 0.0;
        int resolvedTier = Clamp(tier, 1, 3);

        if (resolvedType == CaelumConstants.ARMOR_TYPE_MAGIC)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD
                || slot == CaelumConstants.ARMOR_SLOT_FEET)
            {
                return resolvedTier == 3 ? 2.0 : 1.0;
            }
            if (slot == CaelumConstants.ARMOR_SLOT_BODY)
            {
                if (resolvedTier == 1) return 2.0;
                if (resolvedTier == 2) return 4.0;
                return 5.0;
            }
            return 1.0;
        }

        if (resolvedType == CaelumConstants.ARMOR_TYPE_LIGHT)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD
                || slot == CaelumConstants.ARMOR_SLOT_FEET)
            {
                if (resolvedTier == 1) return 2.0;
                if (resolvedTier == 2) return 3.0;
                return 4.0;
            }
            if (slot == CaelumConstants.ARMOR_SLOT_BODY)
            {
                if (resolvedTier == 1) return 5.0;
                if (resolvedTier == 2) return 8.0;
                return 10.0;
            }
            return resolvedTier == 3 ? 2.0 : 1.0;
        }

        double totalMultiplier = resolvedType == CaelumConstants.ARMOR_TYPE_MEDIUM
            ? 1.0 : 2.0;
        if (slot == CaelumConstants.ARMOR_SLOT_HEAD
            || slot == CaelumConstants.ARMOR_SLOT_FEET)
        {
            if (resolvedTier == 1) return 4.0 * totalMultiplier;
            if (resolvedTier == 2) return 6.0 * totalMultiplier;
            return 8.0 * totalMultiplier;
        }
        if (slot == CaelumConstants.ARMOR_SLOT_BODY)
        {
            if (resolvedTier == 1) return 10.0 * totalMultiplier;
            if (resolvedTier == 2) return 15.0 * totalMultiplier;
            return 20.0 * totalMultiplier;
        }
        if (resolvedTier == 1) return 2.0 * totalMultiplier;
        if (resolvedTier == 2) return 3.0 * totalMultiplier;
        return 4.0 * totalMultiplier;
    }

    double GetWeightFor(int slot, int armorType, int tier, int equipmentSize)
    {
        return GetMediumSizeWeightFor(slot, armorType, tier)
            * CaelumEquipmentRules.GetSizeWeightMultiplier(equipmentSize);
    }

    double GetWeight(int slot)
    {
        return GetWeightFor(slot, ArmorType[slot], Tier[slot], Size[slot]);
    }

    double GetTotalWeight()
    {
        double total = 0.0;
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            total += GetWeight(slot);
        }
        return total;
    }

    int GetReinforcement(int slot)
    {
        if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING) { return 0; }
        if (Durability[slot] <= 0) { return 0; }
        switch (ArmorType[slot])
        {
            case CaelumConstants.ARMOR_TYPE_MAGIC:
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
        if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_MAGIC)
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
        return GetBaseDurabilityForType(ArmorType[slot]);
    }

    int GetBaseDurabilityForType(int armorType)
    {
        if (armorType == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING) { return 0; }
        switch (Clamp(armorType, 0, CaelumConstants.ARMOR_TYPE_COUNT - 1))
        {
            case CaelumConstants.ARMOR_TYPE_MAGIC: return 20;
            case CaelumConstants.ARMOR_TYPE_LIGHT: return 40;
            case CaelumConstants.ARMOR_TYPE_MEDIUM: return 60;
            default: return 100;
        }
    }

    int GetMaximumDurability(int slot)
    {
        return GetMaximumDurabilityFor(
            ArmorType[slot],
            Tier[slot],
            Size[slot]
        );
    }

    int GetMaximumDurabilityFor(int armorType, int tier, int equipmentSize)
    {
        if (armorType == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING) { return 0; }
        int multiplier = 1;
        if (tier == 2) { multiplier = 3; }
        else if (tier >= 3) { multiplier = 9; }
        return CaelumEquipmentRules.ScaleDurabilityForSize(
            GetBaseDurabilityForType(armorType) * multiplier,
            equipmentSize
        );
    }

    void CycleSelectedSlot()
    {
        SelectedSlot = (SelectedSlot + 1) % CaelumConstants.ARMOR_SLOT_COUNT;
    }

    void CycleSelectedType()
    {
        ArmorType[SelectedSlot] = (ArmorType[SelectedSlot] + 1)
            % CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT;
        Durability[SelectedSlot] = GetMaximumDurability(SelectedSlot);
    }

    void CycleSelectedTier()
    {
        Tier[SelectedSlot]++;
        if (Tier[SelectedSlot] > 3) { Tier[SelectedSlot] = 1; }
        Durability[SelectedSlot] = GetMaximumDurability(SelectedSlot);
    }

    void CycleSelectedSize()
    {
        Size[SelectedSlot] = (Size[SelectedSlot] + 1)
            % CaelumConstants.EQUIPMENT_SIZE_COUNT;
        Durability[SelectedSlot] = GetMaximumDurability(SelectedSlot);
    }

    void RepairSelectedPiece()
    {
        Durability[SelectedSlot] = GetMaximumDurability(SelectedSlot);
    }
}
