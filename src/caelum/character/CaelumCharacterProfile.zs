// Guarda las decisiones estructurales del creador de personajes 4.0.
class CaelumCharacterProfile : Object
{
    int Race;
    int FirstClass;
    int SecondClass;
    int Sex;
    int HeightChoice;

    void CopyFrom(CaelumCharacterProfile source)
    {
        Race = source.Race;
        FirstClass = source.FirstClass;
        SecondClass = source.SecondClass;
        Sex = source.Sex;
        HeightChoice = source.HeightChoice;
    }

    void InitializeDefaultTestProfile()
    {
        Race = CaelumConstants.RACE_HUMAN;
        FirstClass = CaelumConstants.CLASS_WARRIOR;
        SecondClass = CaelumConstants.CLASS_MAGE;
        Sex = CaelumConstants.SEX_MALE;
        HeightChoice = CaelumConstants.HEIGHT_NORMAL;
    }

    void CycleRace() { Race = (Race + 1) % 4; }
    void CycleFirstClass() { FirstClass = (FirstClass + 1) % 4; }
    void CycleSecondClass() { SecondClass = (SecondClass + 1) % 4; }
    void CycleSex() { Sex = (Sex + 1) % 2; }
    void CycleHeight() { HeightChoice = (HeightChoice + 1) % 3; }

    int GetDistributionValue(int pattern, int layer)
    {
        switch (pattern)
        {
            case 0:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 5;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 3;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 3;
                return 1;
            case 1:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 3;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 5;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 1;
                return 3;
            case 2:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 3;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 1;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 5;
                return 3;
            default:
                if (layer == CaelumConstants.LAYER_PHYSICAL) return 1;
                if (layer == CaelumConstants.LAYER_TECHNICAL) return 3;
                if (layer == CaelumConstants.LAYER_SOCIAL) return 3;
                return 5;
        }
    }

    int GetRaceLayerValue(int layer)
    {
        if (Race == CaelumConstants.RACE_BEAST_MAN) return GetDistributionValue(0, layer);
        if (Race == CaelumConstants.RACE_CAELITH) return GetDistributionValue(1, layer);
        if (Race == CaelumConstants.RACE_HUMAN) return GetDistributionValue(2, layer);
        return GetDistributionValue(3, layer);
    }

    int GetCombinedLayerValue(int layer)
    {
        return GetRaceLayerValue(layer)
            + GetDistributionValue(FirstClass, layer)
            + GetDistributionValue(SecondClass, layer);
    }

    int GetProfession()
    {
        int lowClass = Min(FirstClass, SecondClass);
        int highClass = Max(FirstClass, SecondClass);
        if (lowClass == highClass) return lowClass;
        if (lowClass == CaelumConstants.CLASS_WARRIOR && highClass == CaelumConstants.CLASS_EXPLORER) return CaelumConstants.PROFESSION_MERCENARY;
        if (lowClass == CaelumConstants.CLASS_WARRIOR && highClass == CaelumConstants.CLASS_PRIEST) return CaelumConstants.PROFESSION_CLERIC;
        if (lowClass == CaelumConstants.CLASS_WARRIOR && highClass == CaelumConstants.CLASS_MAGE) return CaelumConstants.PROFESSION_BATTLE_MAGE;
        if (lowClass == CaelumConstants.CLASS_EXPLORER && highClass == CaelumConstants.CLASS_PRIEST) return CaelumConstants.PROFESSION_PILGRIM;
        if (lowClass == CaelumConstants.CLASS_EXPLORER && highClass == CaelumConstants.CLASS_MAGE) return CaelumConstants.PROFESSION_INVESTIGATOR;
        return CaelumConstants.PROFESSION_ARCANIST;
    }

    int GetRaceMassModifier()
    {
        if (Race == CaelumConstants.RACE_BEAST_MAN) return 2;
        if (Race == CaelumConstants.RACE_CAELITH) return 1;
        if (Race == CaelumConstants.RACE_GOBLIN) return -1;
        return 0;
    }

    int GetRaceSizeModifier()
    {
        if (Race == CaelumConstants.RACE_BEAST_MAN) return 1;
        if (Race == CaelumConstants.RACE_GOBLIN) return -1;
        return 0;
    }

    int GetProfessionMassModifier()
    {
        int profession = GetProfession();
        if (profession == CaelumConstants.PROFESSION_WARRIOR) return 2;
        if (profession == CaelumConstants.PROFESSION_MAGE) return -1;
        if (profession == CaelumConstants.PROFESSION_MERCENARY
            || profession == CaelumConstants.PROFESSION_CLERIC
            || profession == CaelumConstants.PROFESSION_BATTLE_MAGE) return 1;
        return 0;
    }

    int GetProfessionSizeModifier()
    {
        return GetProfession() == CaelumConstants.PROFESSION_WARRIOR ? 1 : 0;
    }

    int GetSexModifier() { return Sex == CaelumConstants.SEX_FEMALE ? -1 : 0; }
    int GetHeightModifier() { return HeightChoice - CaelumConstants.HEIGHT_NORMAL; }

    int GetMassTier()
    {
        return Clamp(CaelumConstants.BASE_MASS_TIER + GetRaceMassModifier()
            + GetProfessionMassModifier() + GetSexModifier() + GetHeightModifier(),
            CaelumConstants.MIN_MASS_TIER, CaelumConstants.MAX_MASS_TIER);
    }

    int GetSizeTier()
    {
        return Clamp(CaelumConstants.BASE_SIZE_TIER + GetRaceSizeModifier()
            + GetProfessionSizeModifier() + GetSexModifier() + GetHeightModifier(),
            CaelumConstants.MIN_SIZE_TIER, CaelumConstants.MAX_SIZE_TIER);
    }
}
