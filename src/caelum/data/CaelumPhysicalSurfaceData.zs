// Generado por generate_contamination_physical.py; referencias en su JSON.
class CaelumPhysicalSurfaceData : Object play
{
    static double FoodDensity(int kind)
    {
        static const double density[]={1054,960,1054,960,1050,420,1000,1000,550,1000};
        return kind>=0 && kind<10?density[kind]:0;
    }
    static double MaterialDensity(int kind,int tier)
    {
        if(CaelumStackSurfaceData.AbstractMaterial(kind))return CaelumStackSurfaceData.ABSTRACT_DENSITY_KG_M3;
        switch(kind)
        {
            case 0: return 7870;
            case 18: case 72: return 1540;
            case 19: case 76: case 77: case 78: return 860;
            case 42: case 90: case 91: return 760;
            case 54: case 55: return 4000;
            case 56: return 2720;
            case 57: return 3530;
            case 58: return 2150;
            case 59: return 8920;
            case 60: return 7200;
            case 61: return 1350;
            case 62: case 63: case 64: case 65: case 66: return 2500;
            case 67: case 89: return 8150;
            case 68: return 7800;
            case 69: return 10490;
            case 70: return 19300;
            case 71: return 1350;
            case 73: return 1360;
            case 74: case 75: return 1480;
            case 81: return 480;
            case 82: case 83: case 84: case 87: return 230;
            case 85: return 760;
            case 86: case 95: return 1400;
            case 88: return 4930;
            case 92: return 2110;
            case 93: return 2015;
            case 94: return 1950;
            case 96: return 1000;
            case 97: return 789;
            case 98: return 950;
            case 99: return 1590;
            case 104: return 124;
            case 105: return 898.5;
            case 106: return 2130;
            case 108: return 550;
            case 109: return 960;
            case 110: return 1054;
            case 111: case 113: return 1000;
            case 112: return 2160;
            case 107: return 1020;
        }
        // Componentes: misma materia prima y tier que su receta vigente.
        if(kind>=CaelumConstants.MATERIAL_BLADE && kind<=CaelumConstants.MATERIAL_OPAL_BROOCH)
            return MaterialDensity(CaelumCraftingRules.GetComponentBaseMaterial(kind,tier),tier);
        return 0;
    }
}
