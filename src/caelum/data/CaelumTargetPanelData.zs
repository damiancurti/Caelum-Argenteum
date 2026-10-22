// #481: sólo presentación; no cambia distancias ni reglas de interacción.
class CaelumTargetPanelData : Object
{
    const WIDTH=384;
    const TOP=12;
    const PADDING=8;
    const ROW_GAP=3;
    const BACKGROUND=0x181512;
    const OPACITY=0.85;

    static clearscope String AttributeKey(int index)
    {
        static const String keys[]={"CA_ATTRIBUTE_STRENGTH","CA_ATTRIBUTE_TOUGHNESS","CA_ATTRIBUTE_CONSTITUTION",
            "CA_ATTRIBUTE_AGILITY","CA_ATTRIBUTE_DEXTERITY","CA_ATTRIBUTE_RESILIENCE",
            "CA_ATTRIBUTE_CHARISMA","CA_ATTRIBUTE_EMPATHY","CA_ATTRIBUTE_ELOQUENCE",
            "CA_ATTRIBUTE_INTELLIGENCE","CA_ATTRIBUTE_PATIENCE","CA_ATTRIBUTE_INSIGHT"};
        return keys[Clamp(index,0,11)];
    }

    static clearscope bool TravelSpecial(int special)
    {return special==70 || special==71 || special==74 || special==75 || special==97 || special==243 || special==244;}
    static clearscope bool DoorSpecial(int special)
    {return special==7 || special==8 || (special>=10 && special<=14) || special==202;}
}
