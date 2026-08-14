// Stores the two player-controlled allocation phases of character creation:
// four free layer points and thirty individual attribute points.
class CaelumCharacterAllocation : Object
{
    // Arrays are indexed with constants defined in CaelumConstants.
    int LayerBonus[4];
    int AttributeBonus[12];

    // Debug selectors are stored so saving and loading restores the same UI state.
    int SelectedLayer;
    int SelectedAttribute;

    void CopyFrom(CaelumCharacterAllocation source)
    {
        for (int i = 0; i < CaelumConstants.ATTRIBUTE_LAYER_COUNT; i++)
        {
            LayerBonus[i] = source.LayerBonus[i];
        }

        for (int i = 0; i < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; i++)
        {
            AttributeBonus[i] = source.AttributeBonus[i];
        }

        SelectedLayer = source.SelectedLayer;
        SelectedAttribute = source.SelectedAttribute;
    }

    void ResetAllocations()
    {
        for (int i = 0; i < CaelumConstants.ATTRIBUTE_LAYER_COUNT; i++)
        {
            LayerBonus[i] = 0;
        }

        for (int i = 0; i < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; i++)
        {
            AttributeBonus[i] = 0;
        }

        SelectedLayer = 0;
        SelectedAttribute = 0;
    }

    int GetSpentLayerPoints()
    {
        int total = 0;

        for (int i = 0; i < CaelumConstants.ATTRIBUTE_LAYER_COUNT; i++)
        {
            total += LayerBonus[i];
        }

        return total;
    }

    int GetRemainingLayerPoints()
    {
        return CaelumConstants.FREE_LAYER_POINTS - GetSpentLayerPoints();
    }

    int GetSpentAttributePoints()
    {
        int total = 0;

        for (int i = 0; i < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; i++)
        {
            total += AttributeBonus[i];
        }

        return total;
    }

    int GetRemainingAttributePoints()
    {
        return CaelumConstants.INDIVIDUAL_ATTRIBUTE_POINTS - GetSpentAttributePoints();
    }

    void CycleSelectedLayer()
    {
        SelectedLayer = (SelectedLayer + 1) % CaelumConstants.ATTRIBUTE_LAYER_COUNT;
    }

    void CycleSelectedAttribute()
    {
        SelectedAttribute = (SelectedAttribute + 1) % CaelumConstants.PRIMARY_ATTRIBUTE_COUNT;
    }

    // Adds one free point only when the pool has points and the resulting layer
    // base would not exceed 15.
    bool TryAddSelectedLayerPoint(CaelumCharacterProfile profile)
    {
        if (GetRemainingLayerPoints() <= 0)
        {
            return false;
        }

        int currentBase = profile.GetCombinedLayerValue(SelectedLayer)
            + LayerBonus[SelectedLayer];

        if (currentBase >= CaelumConstants.MAX_LAYER_BASE)
        {
            return false;
        }

        LayerBonus[SelectedLayer]++;
        return true;
    }

    // Returns the layer to which one attribute belongs.
    int GetAttributeLayer(int attributeIndex)
    {
        return attributeIndex / 3;
    }

    int GetFinalLayerBase(CaelumCharacterProfile profile, int layer)
    {
        return profile.GetCombinedLayerValue(layer) + LayerBonus[layer];
    }

    // An individual attribute may gain at most +5, but may also never exceed
    // twice its base. Example: base 3 permits only +3, while base 15 permits +5.
    int GetMaximumIndividualBonus(CaelumCharacterProfile profile, int attributeIndex)
    {
        int layer = GetAttributeLayer(attributeIndex);
        int baseValue = GetFinalLayerBase(profile, layer);
        return Min(CaelumConstants.MAX_INDIVIDUAL_BONUS, baseValue);
    }

    bool TryAddSelectedAttributePoint(CaelumCharacterProfile profile)
    {
        if (GetRemainingAttributePoints() <= 0)
        {
            return false;
        }

        int maximumBonus = GetMaximumIndividualBonus(profile, SelectedAttribute);

        if (AttributeBonus[SelectedAttribute] >= maximumBonus)
        {
            return false;
        }

        AttributeBonus[SelectedAttribute]++;
        return true;
    }
}
