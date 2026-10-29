// #502: convención aprobada para esencias y preparados abstractos. La masa
// procede del catálogo; jamás se aplica la esfera a la masa de toda la pila.
class CaelumStackSurfaceData : Object play
{
    const PI=3.141592653589793;
    const REVISION=3;
    const FOOD_LEDGER_REVISION=2;
    const ABSTRACT_DENSITY_KG_M3=1000.0;
    static bool AbstractMaterial(int kind)
    {
        return (kind>=CaelumConstants.MATERIAL_FIRE_ESSENCE && kind<=CaelumConstants.MATERIAL_QUINTESSENCE)
            || kind==CaelumConstants.MATERIAL_CARBINE_KIT || kind==CaelumConstants.MATERIAL_SHOTGUN_KIT
            || (kind>=100 && kind<=103);
    }
    static double UnitArea(Inventory item)
    {
        if(CaelumVesselSurfaceData.Eligible(item))return CaelumVesselSurfaceData.Area(item);
        if(CaelumContaminationStack.Generic(item))
            return CaelumContaminationRules.CylinderArea(item.Radius,item.Height);
        let material=CaelumMaterialPickup(item);
        double mass=0,density=0;
        if(material!=null)
        {mass=material.GetUnitWeight();density=CaelumPhysicalSurfaceData.MaterialDensity(material.GetSpecialType(),material.GetSpecialTier());}
        let prepared=CaelumConsumableItem(item);
        if(prepared!=null && (CaelumPotionRules.IsPotion(prepared.GetConsumableType()) || prepared.GetConsumableType()==CaelumConstants.CONSUMABLE_WATER_RATION))
        {mass=prepared.GetUnitWeight();density=ABSTRACT_DENSITY_KG_M3;}
        if(prepared!=null && CaelumFoodInventory.IsFood(prepared))
        {mass=prepared.GetUnitWeight();density=CaelumPhysicalSurfaceData.FoodDensity(CaelumFoodInventory.Kind(prepared));}
        if(mass<=0 || density<=0)return 0;
        double radius=(3*mass/(4*PI*density))**(1.0/3.0);
        return 4*PI*radius*radius;
    }
}
