// Generado desde PROGRESSION.json; no activa escenas ni viajes.
class CaelumCampaignFinaleData : Object
{
    const REQUIRED_ESSENCES=78;
    const MINIMUM_REPUTATION=250;
    const FACTION_COUNT=4;
    static clearscope int Faction(int index)
    {
        switch(index)
        {
        case 0:return CaelumConstants.FACTION_UNITARIOS;
        case 1:return CaelumConstants.FACTION_FEDERALS;
        case 2:return CaelumConstants.FACTION_PUEBLOS_LIBRES;
        case 3:return CaelumConstants.FACTION_SUN_WARRIORS;
        }
        return -1;
    }
}
