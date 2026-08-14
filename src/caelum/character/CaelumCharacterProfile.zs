// CaelumCharacterProfile stores the three background choices that establish
// a new character's four base attribute layers.
class CaelumCharacterProfile : Object
{
    int Origin;
    int Identity;
    int CharacterClass;

    // Copy all profile choices from another profile. This supports cancelling
    // character creation without losing the previously confirmed character.
    void CopyFrom(CaelumCharacterProfile source)
    {
        Origin = source.Origin;
        Identity = source.Identity;
        CharacterClass = source.CharacterClass;
    }

    // The first test character follows the documented Federal warrior from the
    // southern city. These values remain editable through debug controls.
    void InitializeDefaultTestProfile()
    {
        Origin = CaelumConstants.ORIGIN_SOUTH;
        Identity = CaelumConstants.IDENTITY_FEDERAL;
        CharacterClass = CaelumConstants.CLASS_WARRIOR;
    }

    // Move to the next option and wrap from the fourth option back to the first.
    void CycleOrigin()
    {
        Origin = (Origin + 1) % 4;
    }

    void CycleIdentity()
    {
        Identity = (Identity + 1) % 4;
    }

    void CycleClass()
    {
        CharacterClass = (CharacterClass + 1) % 4;
    }

    // Returns one layer from one of the four documented 12-point patterns.
    // Pattern 0: Capital  = 3 / 1 / 5 / 3
    // Pattern 1: North    = 1 / 3 / 3 / 5
    // Pattern 2: West     = 3 / 5 / 1 / 3
    // Pattern 3: South    = 5 / 3 / 3 / 1
    int GetDistributionValue(int pattern, int layer)
    {
        switch (pattern)
        {
            case 0:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 3;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 1;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 5;
                return 3;

            case 1:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 1;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 3;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 3;
                return 5;

            case 2:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 3;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 5;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 1;
                return 3;

            default:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 5;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 3;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 3;
                return 1;
        }
    }

    // Origins already use the same ordering as the four patterns.
    int GetOriginLayerValue(int layer)
    {
        return GetDistributionValue(Origin, layer);
    }

    // Convert an identity into its documented distribution pattern.
    int GetIdentityLayerValue(int layer)
    {
        switch (Identity)
        {
            case CaelumConstants.IDENTITY_FEDERAL:
                return GetDistributionValue(3, layer);
            case CaelumConstants.IDENTITY_UNITARIAN:
                return GetDistributionValue(0, layer);
            case CaelumConstants.IDENTITY_BEAST:
                return GetDistributionValue(2, layer);
            default:
                return GetDistributionValue(1, layer);
        }
    }

    // Convert a class into its documented distribution pattern.
    int GetClassLayerValue(int layer)
    {
        switch (CharacterClass)
        {
            case CaelumConstants.CLASS_WARRIOR:
                return GetDistributionValue(3, layer);
            case CaelumConstants.CLASS_EXPLORER:
                return GetDistributionValue(2, layer);
            case CaelumConstants.CLASS_PRIEST:
                return GetDistributionValue(0, layer);
            default:
                return GetDistributionValue(1, layer);
        }
    }

    // Add origin, identity, and class contributions for one attribute layer.
    int GetCombinedLayerValue(int layer)
    {
        return GetOriginLayerValue(layer)
            + GetIdentityLayerValue(layer)
            + GetClassLayerValue(layer);
    }
}
