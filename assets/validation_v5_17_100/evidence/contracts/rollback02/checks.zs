class CA844StackReference : Object play
{
    static bool Eligible(Inventory item)
    {
        if(CaelumContaminationStack.Generic(item))return true;
        if(CaelumVesselSurfaceData.Eligible(item))return true;
        let material=CaelumMaterialPickup(item);
        if(material!=null)return material.GetSpecialType()>=0 && material.GetSpecialType()<CaelumConstants.MATERIAL_TYPE_COUNT;
        let prepared=CaelumConsumableItem(item);
        return prepared!=null && (CaelumPotionRules.IsPotion(prepared.GetConsumableType()) || CaelumFoodInventory.IsFood(prepared) || prepared.GetConsumableType()==CaelumConstants.CONSUMABLE_WATER_RATION);
    }
}

class MAP01ullChecks : EventHandler
{
    int Revision;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca844_null")return;
        int checks=0,errors=0;bool good=!CA844StackReference.Eligible(null) && !CaelumContaminationStack.Eligible(null);
        checks++;if(!good)errors++;
        let user=CaelumPlayer(players[e.Player].mo);
        for(Inventory item=user.Inv;item!=null;item=item.Inv)
        {checks++;if(CA844StackReference.Eligible(item)!=CaelumContaminationStack.Eligible(item))errors++;}
        checks++;if(Revision!=0 && Revision!=1)errors++;Revision=1;
        Console.Printf("CA844 NULL_CHECKS checks=%d errors=%d",checks,errors);
    }
}
