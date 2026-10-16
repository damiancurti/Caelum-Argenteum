// #259: categorías de dispersión; no son niveles de atributo ni probabilidades.
class CaelumDispersionRules : Object
{
    const MAXIMUM_TIER = 7;
    const MELEE_BASE = 3;
    const RANGED_BASE = 1;
    const SHOTGUN_BASE = 4;
    const STAFF_BOOK_BASE = 1;
    const STATUETTE_BASE = 2;
    const BELL_BASE = 4;
    const TOOL_BASE = 6;

    static int LucidityPenalty(double lucidity)
    {
        double ratio = lucidity / CaelumConstants.MAXIMUM_LUCIDITY;
        return ratio < CaelumConstants.LUCIDITY_STUNNED_THRESHOLD ? 2
            : ratio < CaelumConstants.LUCIDITY_DIZZY_THRESHOLD ? 1 : 0;
    }

    static int EffectiveTier(int baseTier, int weaponTier, double lucidity)
    {
        return Clamp(baseTier + Clamp(weaponTier, 1, 3) - 1
            + LucidityPenalty(lucidity), 1, MAXIMUM_TIER);
    }

    static int MagicBase(int weaponType)
    {
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_STAFF:
            case CaelumConstants.WEAPON_TYPE_BOOK: return STAFF_BOOK_BASE;
            case CaelumConstants.WEAPON_TYPE_STATUETTE: return STATUETTE_BASE;
            case CaelumConstants.WEAPON_TYPE_BELL: return BELL_BASE;
            default: return 4;
        }
    }
}
