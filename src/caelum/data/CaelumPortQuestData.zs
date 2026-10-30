// #422: dos encargos aprobados, sin nuevas recompensas económicas.
class CaelumPortQuestData : Object
{
    const REVISION = 1;
    const RENTAL_CONVERSATION = 43660;
    static clearscope bool Defined(int id)
    { return id == CaelumConstants.QUEST_FIND_HOUSE || id == CaelumConstants.QUEST_INVESTIGATE_SIEGE; }
    static clearscope int Count(int mask)
    { int count=0; for(int i=0;i<CaelumConstants.PRISONER_COUNT;i++)if(mask&(1<<i))count++; return count; }
    static clearscope String ObjectiveKey(int id,int objective)
    {
        if(id==CaelumConstants.QUEST_INVESTIGATE_SIEGE)return "CA_Q_PORT_ACCOUNTS";
        return objective==0 ? "CA_Q_HOUSE_GUARD" : "CA_Q_HOUSE_REGISTER";
    }
    static play vector3 AgentPosition()
    {
        // Junto a la entrada ya definida, dejando libre el paso con dos diámetros.
        double radius=GetDefaultByType("CaelumCityMerchant").Radius;
        return CaelumCityData.DoorOutside(CaelumPropertyData.CENTRAL_HOUSE)+(0,radius*4,0);
    }
}
