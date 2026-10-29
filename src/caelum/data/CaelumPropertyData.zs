// #411: precio y plazo aprobados; vivienda existente junto al centro comercial.
class CaelumPropertyData : Object play
{
    const REVISION=1;
    const CENTRAL_HOUSE=69;
    const RELOCATION_HOUSE=70;
    const PURCHASE_COPPER=100000;
    const RENT_COPPER=1000;
    const RENT_DAYS=30;
    static clearscope bool Offered(int house){return house==CENTRAL_HOUSE;}
    static clearscope int ResidentHouse(int identity)
    {int house=identity%CaelumCityData.HOUSE_COUNT;return house==CENTRAL_HOUSE?RELOCATION_HOUSE:house;}
    static vector3 ResidentPosition(int identity)
    {
        if(identity%CaelumCityData.HOUSE_COUNT!=CENTRAL_HOUSE)return CaelumCityData.HomePosition(identity);
        switch(identity/CaelumCityData.HOUSE_COUNT)
        {
            case 0:return CaelumCityData.HouseOrigin(RELOCATION_HOUSE)+(528,544,0);
            case 1:return CaelumCityData.HouseOrigin(RELOCATION_HOUSE)+(656,544,0);
            case 2:return CaelumCityData.HouseOrigin(RELOCATION_HOUSE)+(784,544,0);
            case 3:return CaelumCityData.HouseOrigin(RELOCATION_HOUSE)+(528,672,0);
        }
        return CaelumCityData.HouseOrigin(RELOCATION_HOUSE);
    }
    static vector3 RelocatedChestPosition()
    {return CaelumCityData.HouseOrigin(RELOCATION_HOUSE)+(864,1056,0);}
}
