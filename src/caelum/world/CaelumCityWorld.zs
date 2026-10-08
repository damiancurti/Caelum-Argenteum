// #133: preparación idempotente de la ciudad nueva. Los planos anteriores
// conservan sus actores y sus rutinas; no se traslada una partida visitada.
class CaelumCityWorld : Object play
{
    static bool Prepare()
    {
        if(!CaelumCityData.Enabled())return true;
        bool ready=true;
        for(int i=0;i<CaelumCityData.HOUSE_COUNT;i++)
        {
            int slot=CaelumCityData.FURNITURE_SLOT_BASE+i;
            if(!CaelumDiningWorld.Place(slot,CaelumCityData.TablePosition(i),2,90))ready=false;
            if(!CaelumMansionFurniture.Bed(slot,CaelumCityData.BedPosition(i),90))ready=false;
        }
        return CaelumCityMerchant.Prepare() && ready;
    }

    static int SiegeDay()
    {return CaelumCalendarRules.ToSerial(CaelumCityData.SIEGE_YEAR,CaelumCityData.SIEGE_MONTH,CaelumCityData.SIEGE_DAY);}

    static bool SiegeDue()
    {
        double due=CaelumScheduleRules.Stamp(SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour());
        for(int i=0;i<MAXPLAYERS;i++)
            if(playeringame[i] && players[i].mo!=null
                && CaelumScheduleState.Now(CaelumPlayer(players[i].mo))>=due)return true;
        return false;
    }
}
