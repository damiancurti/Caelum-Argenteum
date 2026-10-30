// Servicios con afiliación explícita; null conserva el acceso civil anterior.
// No infiere una facción por especie, uniforme, ubicación ni relaciones.
class CaelumFactionServices : Object play
{
    static bool Hostile(CaelumPlayer user,CaelumFactionCondition condition)
    {
        return user!=null && condition!=null && condition.Configured
            && CaelumFactionRules.HostileReputation(user.GetPersistentCharacterState(false),condition.FactionId);
    }
    static int Check(CaelumPlayer user,CaelumFactionCondition condition)
    {
        int result=CaelumFactionCondition.Check(user,condition);
        if(result!=CaelumFactionCondition.ALLOWED)return result;
        return Hostile(user,condition)?CaelumFactionCondition.REPUTATION_REQUIRED:result;
    }
    static bool Require(CaelumPlayer user,CaelumFactionCondition condition)
    {
        if(Hostile(user,condition))
        {
            String text=StringTable.Localize("CA_SERVICE_HOSTILE",false);
            text.Replace("%FACTION%",StringTable.Localize(CaelumFactionRules.GetNameKey(condition.FactionId),false));
            CaelumNotifications.Notify(user,text);return false;
        }
        return CaelumFactionCondition.Require(user,condition);
    }
    static double Factor(CaelumPlayer user,CaelumFactionCondition condition,bool selling)
    {
        if(condition==null)return 1;
        if(Check(user,condition)!=CaelumFactionCondition.ALLOWED)return 0;
        let record=user.GetPersistentCharacterState(false);if(record==null)return 0;
        int reputation=record.FactionReputation[condition.FactionId];
        return selling?CaelumFactionData.SaleFactor(reputation):CaelumFactionData.PurchaseFactor(reputation);
    }
    static int Price(CaelumPlayer user,CaelumFactionCondition condition,double value,int amount,bool selling)
    {
        double factor=Factor(user,condition,selling);if(factor<=0)return 0;
        return selling?CaelumEconomyRules.GetPricePaidByMerchant(value*factor,amount)
            :CaelumEconomyRules.GetPriceChargedByMerchant(value*factor,amount);
    }
}
