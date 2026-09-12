// CaelumAttributes stores the twelve primary attributes belonging to one
// character. It contains data and attribute-related calculations only.
//
// Keeping this logic outside CaelumPlayer prevents the player class from
// becoming one enormous file as the game grows.
class CaelumAttributes : Object
{
    // Physical layer.
    double Strength;
    double Toughness;
    double Constitution;

    // Technical layer.
    double Agility;
    double Dexterity;
    double Resilience;

    // Social layer.
    double Charisma;
    double Empathy;
    double Eloquence;

    // Mental layer.
    double Intelligence;
    double Patience;
    double Insight;

    // Development-only shortcut. It deliberately bypasses character-creation
    // budgets without changing the saved allocation that will be restored.
    void SetAllForDebug(int level)
    {
        Strength = level;
        Toughness = level;
        Constitution = level;
        Agility = level;
        Dexterity = level;
        Resilience = level;
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
        Resilience = technical + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_RESILIENCE];

        Charisma = social + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_CHARISMA];
        Empathy = social + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_EMPATHY];
        Eloquence = social + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_ELOQUENCE];

        Intelligence = mental + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_INTELLIGENCE];
        Patience = mental + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_PATIENCE];
        Insight = mental + allocation.AttributeBonus[CaelumConstants.ATTRIBUTE_INSIGHT];
    }

    // Las pasivas menores suman base antes del porcentaje de colección.
    play void ApplyTarotMinorBonuses(CaelumPersistentCharacterState record)
    {
        if (record == null) return;
        Strength += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_STRENGTH);
        Toughness += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_TOUGHNESS);
        Constitution += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_CONSTITUTION);
        Agility += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_AGILITY);
        Dexterity += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
        Resilience += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_RESILIENCE);
        Charisma += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_CHARISMA);
        Empathy += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_EMPATHY);
        Eloquence += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_ELOQUENCE);
        Intelligence += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_INTELLIGENCE);
        Patience += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_PATIENCE);
        Insight += record.GetTarotMinorBaseBonus(CaelumConstants.ATTRIBUTE_INSIGHT);
    }

    // Recalcular siempre desde creación/equipo antes de aplicar el factor.
    // Nunca multiplicar la asignación guardada ni truncar fracciones de nivel.
    void ApplyTarotBonus(int percent)
    {
        double factor = 1.0 + Max(0, percent) / 100.0;
        Strength *= factor;
        Toughness *= factor;
        Constitution *= factor;
        Agility *= factor;
        Dexterity *= factor;
        Resilience *= factor;
        Charisma *= factor;
        Empathy *= factor;
        Eloquence *= factor;
        Intelligence *= factor;
        Patience *= factor;
        Insight *= factor;
    }

    // Returns the sum of all twelve primary attributes. For neutral test values
    // of 3, the expected result is 36.
    double GetTotalPrimaryLevels()
    {
        return Strength + Toughness + Constitution
            + Agility + Dexterity + Resilience
            + Charisma + Empathy + Eloquence
            + Intelligence + Patience + Insight;
    }
}
