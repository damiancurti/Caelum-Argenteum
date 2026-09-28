// Masas de #19 y atributos de portones aprobados en #52 el 2026-09-28.
class CaelumGateData : Object
{
    const WOOD = 0;
    const REINFORCED = 1;
    const ARMORED = 2;
    const WIDTH = 96.0; // Referencia visual aceptada: 3 m a 32 MU/m.
    const HEIGHT = 96.0;
    const THICKNESS = 2.56; // Madera de 80 mm.
    const HOLD_TICS = 105; // Mismo tiempo de CaelumSlidingDoorLeaf.

    const BALANCE_REVISION = 2;
    const CONSTITUTION = 0.0;

    static double ArmorDefense(int material)
    {
        switch (material)
        {
            case REINFORCED: return 20.0;
            case ARMORED: return 30.0;
            default: return 10.0;
        }
    }

    static double ToughnessLevel(int material)
    {
        switch (material)
        {
            case REINFORCED: return 50;
            case ARMORED: return 75;
            default: return 25;
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
