// #502: aritmética sin actores, inventarios ni cambios en el reloj.
class CaelumContaminationRules : Object
{
    static double GarmentArea(int slot,int size)
    {
        return CaelumThermalRules.Area(CaelumThermalData.REFERENCE_MASS_KG,CaelumThermalData.REFERENCE_HEIGHT_METERS)
            *CaelumContaminationData.GarmentCoverage(slot)
            *(CaelumEquipmentRules.GetSizeWeightMultiplier(size)**(2.0/3.0));
    }
    static clearscope double ContactPrimitive(double value)
    {
        double floor=CaelumContaminationData.CONTACT_RATIO_FLOOR;
        return value<floor ? value*floor : 0.5*(value*value+floor*floor);
    }
    static double WeaponArea(int kind,int size)
    {
        return CaelumContaminationData.WeaponAreaM(kind)
            *(CaelumEquipmentRules.GetSizeWeightMultiplier(size)**(2.0/3.0));
    }
    static double ShieldArea(int kind,int size)
    {
        return CaelumContaminationData.ShieldAreaM(kind)
            *(CaelumEquipmentRules.GetSizeWeightMultiplier(size)**(2.0/3.0));
    }
    static clearscope double CylinderArea(double radius,double height)
    {
        double r=Max(0.0,radius)/CaelumJourneyRules.MAP_UNITS_PER_METER;
        double h=Max(0.0,height)/CaelumJourneyRules.MAP_UNITS_PER_METER;
        return 2*CaelumThermalData.CIRCLE_PI*r*(r+h);
    }
    static clearscope double DamageFactor(double contamination)
    {
        return contamination>=CaelumContaminationData.SEVERE_THRESHOLD
            ? CaelumContaminationData.SEVERE_DAMAGE_FACTOR : 1.0;
    }
    static clearscope double Environment(double reference,double celsius,double humidity)
    {
        return Clamp(Max(0.0,reference)
            *(2.0**((celsius-CaelumFoodData.REFERENCE_CELSIUS)/CaelumFoodData.DOUBLING_CELSIUS))
            *(CaelumFoodData.HUMIDITY_BASE_FACTOR+Clamp(humidity,0.0,100.0)/100.0),
            0.0,CaelumFoodData.MAX_CONTAMINATION);
    }
    // Integra dC/dt=k*fuente/max(C,1), recalculando la proporción durante
    // el contacto. Así diez segundos producen lo mismo juntos o por tics.
    // La fuente mantiene su concentración; nunca se sobrepasa ni se limpia.
    static clearscope double AfterContact(double recipient,double source,double areaM2,
        double seconds,double doseFactor=1.0)
    {
        recipient=Clamp(recipient,0.0,CaelumFoodData.MAX_CONTAMINATION);
        source=Clamp(source,0.0,CaelumFoodData.MAX_CONTAMINATION);
        if(source<=recipient || areaM2<=0 || seconds<=0 || doseFactor<=0)return recipient;
        double rate=CaelumContaminationData.CONTACT_DEGREES_M2_SECOND*areaM2*source*doseFactor;
        double floor=CaelumContaminationData.CONTACT_RATIO_FLOOR;
        if(recipient<floor)
        {
            double untilFloor=(Min(floor,source)-recipient)*floor/rate;
            double first=Min(seconds,untilFloor);
            recipient+=rate*first/floor;seconds-=first;
        }
        if(seconds>0 && recipient<source)
            recipient=Sqrt(recipient*recipient+2.0*rate*seconds);
        return Min(source,recipient);
    }
    static clearscope double BodyDoseFactor(double bodyKg)
    {return bodyKg>0 ? CaelumFoodData.REFERENCE_BODY_KG/bodyKg : 0;}
    static clearscope double EquipmentWaterLiters(double areaM2)
    {return Max(0.0,areaM2)*CaelumContaminationData.EQUIPMENT_WATER_L_M2;}
    static clearscope double SoapGrams(double waterLiters)
    {return Max(0.0,waterLiters)*CaelumContaminationData.SOAP_G_L;}
    static clearscope double BathWaterLiters(double degrees,double bodyKg)
    {
        return Clamp(degrees,0.0,CaelumFoodData.MAX_CONTAMINATION)
            *CaelumContaminationData.BATH_WATER_L_DEGREE
            *Max(0.0,bodyKg)/CaelumFoodData.REFERENCE_BODY_KG;
    }
}
