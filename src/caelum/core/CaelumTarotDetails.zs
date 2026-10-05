// El cálculo y el texto consultan la misma contribución fija de cada carta.
class CaelumTarotDetails : Object
{
    static int MinorTenths(int card, int attribute)
    {
        if (!CaelumTrucazoRules.Minor(card) || attribute < 0 || attribute >= CaelumConstants.PRIMARY_ATTRIBUTE_COUNT) return 0;
        int family = attribute / 3;
        int suit = family == CaelumConstants.LAYER_PHYSICAL ? CaelumConstants.TAROT_SUIT_WANDS
            : family == CaelumConstants.LAYER_TECHNICAL ? CaelumConstants.TAROT_SUIT_COINS
            : family == CaelumConstants.LAYER_SOCIAL ? CaelumConstants.TAROT_SUIT_CUPS : CaelumConstants.TAROT_SUIT_SWORDS;
        if (CaelumTrucazoRules.Suit(card) != suit) return 0;
        int rank = CaelumTrucazoRules.Rank(card), position = attribute % 3;
        if (rank == 0) return 10;
        if (rank == 13) return 5;
        if (rank >= 10 && rank - 10 == position) return 6;
        if (rank <= 9 && (rank - 1) / 3 == position) return 3;
        return 0;
    }
    static String L(String key) { return StringTable.Localize(key, false); }
    static String AttributeKey(int attribute)
    {
        static const String keys[] = {"CA_ATTRIBUTE_STRENGTH", "CA_ATTRIBUTE_TOUGHNESS", "CA_ATTRIBUTE_CONSTITUTION",
            "CA_ATTRIBUTE_AGILITY", "CA_ATTRIBUTE_DEXTERITY", "CA_ATTRIBUTE_RESILIENCE",
            "CA_ATTRIBUTE_CHARISMA", "CA_ATTRIBUTE_EMPATHY", "CA_ATTRIBUTE_ELOQUENCE",
            "CA_ATTRIBUTE_INTELLIGENCE", "CA_ATTRIBUTE_PATIENCE", "CA_ATTRIBUTE_INSIGHT"};
        return keys[Clamp(attribute, 0, CaelumConstants.PRIMARY_ATTRIBUTE_COUNT-1)];
    }
    static String FixedBonus(int card, int multiplier = 1)
    {
        String text;
        for (int attribute = 0; attribute < CaelumConstants.PRIMARY_ATTRIBUTE_COUNT; attribute++)
        {
            int tenths = MinorTenths(card, attribute);
            if (tenths <= 0) continue;
            if (text != "") text = text .. ", ";
            text = text .. String.Format("+%.1f %s", tenths * multiplier / 10.0, L(AttributeKey(attribute)));
        }
        return text;
    }
    static String Passive(int card, bool captured)
    {
        if (!captured) return L("CA_TAROT_DETAIL_UNREVEALED");
        String fixed = FixedBonus(card);
        return (fixed == "" ? L("CA_TAROT_DETAIL_NO_FIXED") : fixed) .. ". "
            .. String.Format(L("CA_TAROT_DETAIL_COLLECTION"), card < CaelumConstants.TAROT_MAJOR_COUNT
                ? CaelumConstants.TAROT_MAJOR_ATTRIBUTE_PERCENT : CaelumConstants.TAROT_MINOR_ATTRIBUTE_PERCENT);
    }
    static String Active(int card, bool captured)
    {
        if (!captured) return L("CA_TAROT_DETAIL_UNREVEALED");
        if (!CaelumTarotPowers.Implemented(card)) return L("CA_TAROT_DETAIL_PENDING");
        String effect = card == CaelumConstants.TAROT_THE_FOOL ? L("CA_TAROT_DETAIL_FOOL")
            : String.Format(L("CA_TAROT_DETAIL_DOUBLE"), FixedBonus(card, 2));
        return effect .. " " .. String.Format(L("CA_TAROT_POWER_RULE"),
            CaelumConstants.TAROT_ACTIVATION_ANIMA, CaelumConstants.TAROT_EFFECT_SECONDS, CaelumConstants.TAROT_COOLDOWN_SECONDS)
            .. " " .. L("CA_TAROT_DETAIL_CONTEXT");
    }
    static String Trucazo(int card, bool captured)
    {
        if (!captured) return L("CA_TAROT_DETAIL_TRUCAZO_UNREVEALED");
        if (!CaelumTrucazoRules.Minor(card)) return L("CA_TAROT_DETAIL_TRUCAZO_MAJOR");
        int rank = CaelumTrucazoRules.Rank(card);
        if (!CaelumTrucazoRules.Playable(card))
            return rank == 12 ? L("CA_TAROT_DETAIL_TRUCAZO_QUEEN")
                : String.Format(L("CA_TAROT_DETAIL_TRUCAZO_ROW"), CaelumTrucazoRules.Number(card), CaelumTrucazoRules.Number(card)*2);
        String text = String.Format(L("CA_TAROT_DETAIL_TRUCAZO_PLAYABLE"), CaelumTrucazoRules.Strength(card));
        return text .. " " .. (rank >= 10 ? L("CA_TAROT_DETAIL_TRUCAZO_FIGURE")
            : String.Format(L("CA_TAROT_DETAIL_TRUCAZO_NUMBER"), CaelumTrucazoRules.EnvidoNumber(card, false), CaelumTrucazoRules.EnvidoNumber(card, true)))
            .. " " .. L("CA_TAROT_DETAIL_TRUCAZO_AWAKE");
    }
}
