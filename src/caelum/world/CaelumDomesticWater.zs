// El registro viaja con el padrón doméstico existente. La reposición se evalúa
// al consultar/usar la reserva: no necesita recorrer viviendas cada tic.
class CaelumDomesticWaterState : Object play
{
    int Revision;
    double Liters, Stamp;

    void Sync(double now)
    {
        if(Revision<CaelumDomesticWaterData.REVISION)
        {
            Liters=CaelumDomesticWaterData.CAPACITY_LITERS;
            Stamp=now;Revision=CaelumDomesticWaterData.REVISION;
            return;
        }
        // Un reloj retrocedido no regala agua ni retrocede el anclaje guardado.
        if(now<=Stamp)return;
        Liters=Min(CaelumDomesticWaterData.CAPACITY_LITERS,Max(0.0,Liters)
            +(now-Stamp)*CaelumDomesticWaterData.REFILL_LITERS_PER_WORLD_MINUTE/60.0);
        Stamp=now;
    }
    double Withdraw(double requested)
    {
        if(Revision<CaelumDomesticWaterData.REVISION || requested<=0)return 0;
        double taken=Min(Max(0.0,Liters),requested);
        Liters-=taken;return taken;
    }
    bool Spend(double required)
    {
        if(Revision<CaelumDomesticWaterData.REVISION || required<=0 || required>Liters)return false;
        Liters-=required;return true;
    }
}

class CaelumDomesticWater : Object play
{
    static CaelumDomesticWaterState Get(int house)
    {
        if(house<0 || house>=CaelumCityData.HOUSE_COUNT)return null;
        let roster=CaelumHouseResidents.Get(true);if(roster==null)return null;
        let user=CaelumPlayer(roster.Owner);
        if(!CaelumPlayerAuthority.CanMutate(user))return null;
        let clock=CaelumWorldClock.Get(user,true);if(clock==null)return null;
        while(roster.HouseWater.Size()<=house)roster.HouseWater.Push(null);
        if(roster.HouseWater[house]==null)roster.HouseWater[house]=new('CaelumDomesticWaterState');
        let reserve=roster.HouseWater[house];
        reserve.Sync(CaelumConnectedWaterMap.ClockStamp(clock));
        return reserve;
    }
}
