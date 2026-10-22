// #282: proyección del inventario poseído; la selección sigue siendo InvSel.
class CaelumQuickUse : Object
{
    static clearscope bool Eligible(CaelumPlayer user,Inventory item)
    {
        if(user==null || item==null || item.Owner!=user
            || item.Amount<=0 || item.bDestroyed)return false;
        let consumable=CaelumConsumableItem(item);
        let bag=CaelumSleepingBag(item);
        return (consumable!=null && !consumable.InMagicBox)
            || (bag!=null && bag.Amount==1 && !bag.InMagicBox);
    }

    static play void Reconcile(CaelumPlayer user)
    {
        if(user==null)return;
        Inventory first=null;
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
        {
            // La munición no tiene una acción Use. No alterar otros objetos
            // nativos ni convertir llaves, documentos o equipo en consumibles.
            if(item is "CaelumCarbineAmmo")item.bInvBar=false;
            if(item is "CaelumConsumableItem" || item is "CaelumSleepingBag")
                item.bInvBar=Eligible(user,item);
            if(first==null && Eligible(user,item))first=item;
        }
        if(!Eligible(user,user.InvSel))user.InvSel=first;
        if(!Eligible(user,user.InvFirst))user.InvFirst=first;
    }

    static clearscope bool Available(CaelumPlayer user,Inventory item)
    {
        if(!Eligible(user,item) || user.health<=0 || user.player==null
            || user.player.playerstate!=PST_LIVE || user.isFrozen()
            || (user.player.cheats & CF_TOTALLYFROZEN))return false;
        let water=CaelumWaterContainer(item);
        return water==null || (user.DerivedStats!=null && user.CurrentThirst<100
            && water.IsPotable() && water.WaterLiters>0.000001);
    }
}
