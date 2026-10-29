// #502: superficies equivalentes desde la geometría térmica ya aprobada.
// El contenido no modifica el área exterior ni la concentración del recipiente.
class CaelumVesselSurfaceData : Object play
{
    static bool Eligible(Inventory item)
    {return item is 'CaelumWaterContainer' || item is 'CaelumMateItem';}
    static double Area(Inventory item)
    {
        double pi=CaelumWaterThermalData.PI;
        let mate=CaelumMateItem(item);
        if(mate!=null)
        {
            int v=mate.Variant();double inner=CaelumMateData.Radius(v);
            double outer=inner+CaelumMateData.Wall(v)+CaelumMateData.CoatingWall(v);
            return 2*pi*outer*outer+pi*(outer*outer-inner*inner);
        }
        let water=CaelumWaterContainer(item);if(water==null)return 0;
        if(item is 'CaelumCampPot')
        {
            double inner=CaelumCampData.POT_DIAMETER_M/2;
            double outer=inner+CaelumCampData.POT_WALL_M;
            double height=CaelumCampData.PotDepth()+CaelumCampData.POT_WALL_M;
            double body=2*pi*outer*height+pi*outer*outer+pi*(outer*outer-inner*inner);
            double trivet=pi*CaelumCampData.TRIVET_ROD_M*(pi*CaelumCampData.TRIVET_DIAMETER_M
                +CaelumCampData.TRIVET_LEGS*CaelumCampData.TRIVET_HEIGHT_M);
            return body+trivet;
        }
        double inner=(water.GetCapacityLiters()/1000*3/(4*pi))**(1.0/3.0);
        double outer=water.IsLeather()?inner+CaelumWaterThermalData.LEATHER_WALL_M
            :(inner*inner*inner+CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT
                /CaelumWaterThermalData.GLASS_DENSITY_KG_M3*3/(4*pi))**(1.0/3.0);
        return 4*pi*outer*outer;
    }
}
