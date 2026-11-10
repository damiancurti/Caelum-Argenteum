// #449: referencias y tiempos aprobados; los materiales se expresan en gramos.
class CaelumMachineData : Object
{
    const REVISION=1;
    const WORK_REVISION=2;
    const FIRST_RECIPE=CaelumRestFurnitureData.FIRST_RECIPE+CaelumRestFurnitureData.COUNT;
    const RECIPE_COUNT=2;
    const ENEMY_OWNER=-1;
    const BARRICADE=0;
    const CANNON=1;
    const SMALL_RAM=2;
    const LARGE_RAM=3;
    const CAPTURE_SECONDS=CaelumMachineMaterials.CAPTURE_SECONDS;
    const SABOTAGE_SECONDS=CaelumMachineMaterials.SABOTAGE_SECONDS;
    const SABOTAGE_REPAIR_FRACTION=CaelumMachineMaterials.SABOTAGE_REPAIR_FRACTION;
    const BARRICADE_WIDTH=CaelumMachineMaterials.BARRICADE_WIDTH;
    const BARRICADE_HEIGHT=CaelumMachineMaterials.BARRICADE_HEIGHT;
    const BARRICADE_MASS=CaelumMachineMaterials.BARRICADE_MASS;
    const BARRICADE_THICKNESS=CaelumMachineMaterials.BARRICADE_THICKNESS;

    static clearscope double Seconds(int kind)
    {return kind==BARRICADE?CaelumMachineMaterials.BARRICADE_SECONDS:kind==CANNON?CaelumMachineMaterials.CANNON_SECONDS:kind==SMALL_RAM?CaelumMachineMaterials.SMALL_RAM_SECONDS:CaelumMachineMaterials.LARGE_RAM_SECONDS;}
    static int GateMaterial(int kind)
    {return kind==BARRICADE?CaelumGateData.WOOD:kind==CANNON?CaelumGateData.ARMORED:CaelumGateData.REINFORCED;}
    static clearscope bool IsRecipe(int recipe)
    {return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+RECIPE_COUNT;}
    static clearscope String NameKey(int kind)
    {return kind==BARRICADE?"CA_MACHINE_BARRICADE":kind==CANNON?"CA_MACHINE_CANNON":kind==SMALL_RAM?"CA_MACHINE_RAM_SMALL":"CA_MACHINE_RAM_LARGE";}
    static clearscope double Mass(int kind)
    {return kind==BARRICADE?BARRICADE_MASS:CaelumCannonData.MACHINE_MASS;}
    static clearscope int Grams(int kind,int slot,double fraction=1)
    {
        double grams=kind==BARRICADE?(slot==0?CaelumMachineMaterials.BARRICADE_WOOD_GRAMS:CaelumMachineMaterials.BARRICADE_IRON_GRAMS)
            :kind==CANNON?(slot==0?CaelumMachineMaterials.CANNON_WOOD_GRAMS:CaelumMachineMaterials.CANNON_IRON_GRAMS)
            :slot==0?CaelumMachineMaterials.SMALL_RAM_WOOD_GRAMS:CaelumMachineMaterials.SMALL_RAM_IRON_GRAMS;
        if(kind==LARGE_RAM)grams*=double(CaelumRamData.LARGE_CREW)/CaelumRamData.SMALL_CREW;
        return Max(0,int(Ceil(grams*fraction)));
    }
}
