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

    // Alterna las fortalezas de las dos clases; al saturarlas pasa a su
    // familia asociada. Los empates internos reparten puntos uniformemente.
    static int PreferredFamily(int component)
    {
        int best = 0;
        for (int f = 1; f < 4; f++)
            if (CaelumCharacterProfile.DistributionFor(component, f)
                > CaelumCharacterProfile.DistributionFor(component, best)) best = f;
        return best;
    }

    static int PairedFamily(int family) { return family ^ 1; }

    void Recommend(CaelumCharacterProfile profile)
    {
        ResetAllocations();
        for (int phase = 0; phase < 2; phase++)
        {
            int count = phase == 0 ? CaelumConstants.FREE_LAYER_POINTS
                : CaelumConstants.INDIVIDUAL_ATTRIBUTE_POINTS;
            for (int point = 0; point < count; point++)
            {
                int component = point % 2 == 0 ? profile.FirstClass : profile.SecondClass;
                int first = PreferredFamily(component);
                bool added = false;
                for (int pass = 0; pass < 4 && !added; pass++)
                {
                    int family = pass == 0 ? first : pass == 1 ? PairedFamily(first)
                        : pass == 2 ? (first ^ 2) : (first ^ 3);
                    if (phase == 0)
                    {
                        SelectedLayer = family;
                        added = TryAddSelectedLayerPoint(profile);
                    }
                    else
                    {
                        int best = -1;
                        for (int a = family * 3; a < family * 3 + 3; a++)
                            if (AttributeBonus[a] < GetMaximumIndividualBonus(profile, a)
                                && (best < 0 || AttributeBonus[a] < AttributeBonus[best])) best = a;
                        if (best >= 0)
                        { SelectedAttribute = best; added = TryAddSelectedAttributePoint(profile); }
                    }
                }
            }
        }
        SelectedLayer = 0; SelectedAttribute = 0;
    }

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
