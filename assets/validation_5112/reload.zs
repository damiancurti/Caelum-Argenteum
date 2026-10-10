class CA158Reload : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA158 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);
        Check("reload keeps original-stock staff and shield",r.MainM00StarterWeaponId>0 && r.MainM00ShieldCrafted);
        Check("reload keeps XL choice and old M task snapshot",u.CraftingSelectionSize==4 && u.CraftingTaskActive && u.CraftingTaskSize==2 && u.CraftingTaskRecipeIndex==60);
        int before=0;
        for(Inventory i=u.Inv;i!=null;i=i.Inv)if(CaelumSealPickup(i)!=null)before++;
        u.CompleteCraftingTask();
        int after=0;bool metadata=true;
        for(Inventory i=u.Inv;i!=null;i=i.Inv)
        {
            let seal=CaelumSealPickup(i);if(seal==null)continue;
            after++;metadata=metadata && seal.EquipmentSize==2 && abs(seal.UnitWeight-CaelumCraftingRules.GetJewelryWeight(seal.Tier))<0.000001;
        }
        Check("fixed-size completion creates exactly one canonical M seal",after==before+1 && metadata && !u.CraftingTaskActive);
        Check("fixed-size completion preserves XL choice",u.CraftingSelectionSize==4);
        u.CraftingSelectionRecipe=33;u.RefreshCraftingPreview();
        Check("return to staff preserves XL",u.CraftingSelectionSize==4);
        Check("UI reports M for fixed recipe, XL for staff",CaelumCraftingRules.GetRecipeEquipmentSize(60,4)==2 && CaelumCraftingRules.GetRecipeEquipmentSize(33,4)==4);
        u.PersistCharacterState();Console.Printf("CA158 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
