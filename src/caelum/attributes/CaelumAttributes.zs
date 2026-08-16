// CaelumAttributes stores the twelve primary attributes belonging to one
// character. It contains data and attribute-related calculations only.
//
// Keeping this logic outside CaelumPlayer prevents the player class from
// becoming one enormous file as the game grows.
class CaelumAttributes : Object
{
    // Physical layer.
    int Strength;
    int Toughness;
    int Constitution;

    // Technical layer.
    int Agility;
    int Dexterity;
    int Survival;

    // Social layer.
    int Charisma;
    int Empathy;
    int Eloquence;

    // Mental layer.
    int Intelligence;
    int Patience;
    int Insight;

    // Development-only shortcut. It deliberately bypasses character-creation
    // budgets without changing the saved allocation that will be restored.
    void SetAllForDebug(int level)
    {
        Strength = level;
        Toughness = level;
        Constitution = level;
        Agility = level;
        Dexterity = level;
        Survival = level;
        Charisma = level;
        Empathy = level;
        Eloquence = level;
        Intelligence = level;
        Patience = level;
        Insight = level;
    }

    // Applies the four combined profile layers. All three attributes inside a
    // layer begin with the same base value, as specified by the design document.
    void InitializeFromCreation(
        CaelumCharacterProfile profile,
        CaelumCharacterAllocation allocation
    )
    {
        int physical = allocation.GetFinalLayerBase(profile, CaelumConstants.LAYER_PHYSICAL);
        int technical = allocation.GetFinalLayerBase(profile, CaelumConstants.LAYER_TECHNICAL);
        int social = allocation.GetFinalLayerBase(profile, CaelumConstants.LAYER_SOCIAL);
        int mental = allocation.GetFinalLayerBase(profile, CaelumConstants.LAYER_MENTAL);

        Strength = physical + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_STRENGTH];
        Toughness = physical + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_TOUGHNESS];
        Constitution = physical + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_CONSTITUTION];

        Agility = technical + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_AGILITY];
        Dexterity = technical + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_DEXTERITY];
        Survival = technical + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_SURVIVAL];

        Charisma = social + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_CHARISMA];
        Empathy = social + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_EMPATHY];
        Eloquence = social + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_ELOQUENCE];

        Intelligence = mental + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_INTELLIGENCE];
        Patience = mental + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_PATIENCE];
        Insight = mental + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_INSIGHT];
    }

    // Returns the sum of all twelve primary attributes. For neutral test values
    // of 3, the expected result is 36.
    int GetTotalPrimaryLevels()
    {
        return Strength + Toughness + Constitution
            + Agility + Dexterity + Survival
            + Charisma + Empathy + Eloquence
            + Intelligence + Patience + Insight;
    }
}
