// Masas de #19 y atributos finales de #21 aprobados el 2026-09-27.
class CaelumGateData : Object
{
    const WOOD = 0;
    const REINFORCED = 1;
    const ARMORED = 2;
    const WIDTH = 96.0; // Referencia visual aceptada: 3 m a 32 MU/m.
    const HEIGHT = 96.0;
    const THICKNESS = 2.56; // Madera de 80 mm.
    const HOLD_TICS = 105; // Mismo tiempo de CaelumSlidingDoorLeaf.

    const BALANCE_REVISION = 1;

    static double AttributeLevel(int material)
    {
        switch (material)
        {
            case REINFORCED: return 100;
            case ARMORED: return 200;
            default: return 50;
        }
    }

    // Sólo para migración reversible de los saves de #19/#20/#21 inicial.
    static double LegacyReduction(int material)
    {
        switch (material)
        {
            case REINFORCED: return 0.5;
            case ARMORED: return 0.7;
            default: return 0.3;
        }
    }

    static int MovingMass(int material)
    {
        switch (material)
        {
            case REINFORCED: return 650;
            case ARMORED: return 1100;
            default: return 550;
        }
    }

    static class<Actor> VisualClass(int material)
    {
        switch (material)
        {
            case REINFORCED: return "CaelumSiegeGateReinforced";
            case ARMORED: return "CaelumSiegeGateArmored";
            default: return "CaelumSiegeGate";
        }
    }
}
