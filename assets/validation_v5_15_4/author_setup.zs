// Preparación exclusiva de las partidas descartables del autor.
class CA515AuthorSetup : Object play
{
    static void Prepare(CaelumPlayer user)
    {
        if(!user.DebugAttributesAt100)user.ToggleDebugAttributes100();
        user.ApplyCharacterProfile();
    }
    static void Materials(CaelumPlayer user)
    {
        // Reponer sólo lo que falta para una receta de cada máquina, a la
        // eficiencia seleccionada. Pulsar otra vez no acumula toneladas.
        int percent=CaelumCraftingRules.GetCraftingEfficiencyPercent(user.CraftingEfficiencyIndex);
        for(int slot=0;slot<2;slot++)
        {
            int kind=slot==0?CaelumConstants.MATERIAL_WOOD:CaelumConstants.MATERIAL_IRON_INGOT;
            int target=(CaelumMachineData.Grams(CaelumMachineData.BARRICADE,slot)
                +CaelumMachineData.Grams(CaelumMachineData.CANNON,slot))*100/percent;
            int missing=target-user.CountRawCraftingMaterial(kind,1);
            if(missing<=0)continue;
            let stack=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,kind,1);
            if(stack!=null)stack.Amount+=missing;
            else
            {
                stack=user.CreateDetachedMaterialStack(kind,1,missing);
                stack.InMagicBox=true;stack.AttachToOwner(user);
            }
        }
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
    }
    static void Report(CaelumPlayer user)
    {
        let a=user.Attributes;let d=user.DerivedStats;
        bool okay=a.Strength==100 && a.Toughness==100 && a.Constitution==100
            && a.Agility==100 && a.Dexterity==100 && a.Resilience==100
            && a.Charisma==100 && a.Empathy==100 && a.Eloquence==100
            && a.Intelligence==100 && a.Patience==100 && a.Insight==100
            && !d.HasExceededCapacity();
        Console.Printf("CA515 AUTHOR SETUP %s attributes100=%d load=%.4f capacity=%.4f ratio=%.6f wood=%d iron=%d",
            okay?"PASS":"FAIL",a.Strength==100 && a.Intelligence==100,
            d.CarriedWeight,d.CarryCapacity,d.LoadRatio,
            user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1),
            user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_IRON_INGOT,1));
    }
}
