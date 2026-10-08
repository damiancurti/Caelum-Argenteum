class CA135Consumption : EventHandler
{
    CaelumCombatActor Drinker,Cancelled;
    int Checks,Failures;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA135 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==60)
        {
            Drinker=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(6000,6000,0)));
            Cancelled=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(6500,6500,0)));
            Drinker.CaelumDiagnosticPassiveAI=Cancelled.CaelumDiagnosticPassiveAI=true;
            Drinker.tics=Cancelled.tics=-1;
        }
        if(level.time==70)
        {
            Cancelled.CurrentCombatAnima=0;
            Cancelled.UseInventory(CaelumDemonService.Potion(Cancelled,1));
            user.GrantMagicBoxFromPalomo(false);
            let item=CaelumConsumableItem(Actor.Spawn("CaelumLifePotionLarge",user.Pos));
            item.Amount=2;Actor toucher=user;bool picked=item.CallTryPickup(toucher);
            user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_CONSUMABLE;
            user.EquipmentSelectionConsumableType=CaelumConstants.CONSUMABLE_LIFE_LARGE;
            CaelumInventoryService.ToggleSelectedMagicBox(user);
            let held=user.FindNativeConsumableItem(CaelumConstants.CONSUMABLE_LIFE_LARGE);
            Check(picked && held!=null && held.InMagicBox && held.Amount==2,"large potion stack enters the owned Magic Box");
            CaelumInventoryService.ToggleSelectedMagicBox(user);
            Check(!held.InMagicBox && held.Amount==2,"retrieval retains exact size and amount");
            user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_CONSUMABLE;
            user.EquipmentSelectionConsumableType=CaelumConstants.CONSUMABLE_LIFE_LARGE;
            CaelumInventoryService.DropSelectedNativeInventoryItem(user);
            let remainder=user.FindNativeConsumableItem(CaelumConstants.CONSUMABLE_LIFE_LARGE);
            Console.Printf("CA135 DROP remaining=%d action=%d selected=%d",remainder!=null ? remainder.Amount : -1,
                user.LastEquipmentAction,user.EquipmentSelectionConsumableType);
            Check(remainder==null || remainder.Amount<=0,
                "native inventory drop releases the selected size stack");
        }
        if(level.time>=70 && level.time<=2250)
        {
            // Controlled demand, independent of combat accuracy/damage: the
            // actual native power and ten-second expiry continue normally.
            Drinker.health=100;Drinker.CurrentCombatAnima=0;Drinker.CurrentCombatAir=0;
            Drinker.CaelumDiagnosticPassiveAI=false;CaelumDemonService.UpdatePotions(Drinker);Drinker.CaelumDiagnosticPassiveAI=true;
        }
        if(level.time==170)
        {
            double before=Cancelled.CurrentCombatAnima;
            let effect=Cancelled.FindInventory("CaelumAnimaRegeneration");effect.Destroy();
            Check(Cancelled.CurrentCombatAnima==before && before>0,"early cancellation grants no completion bonus");
        }
        if(level.time==2240)
        {
            Check(CaelumDemonService.Potion(Drinker,0)==null && CaelumDemonService.Potion(Drinker,1)==null
                && CaelumDemonService.Potion(Drinker,2)==null,"continuous low resources exhaust exactly six native doses per family");
            CaelumDemonService.Initialize(Drinker);CaelumDemonService.Initialize(Drinker);
            Check(CaelumDemonService.Potion(Drinker,0)==null && CaelumDemonService.Potion(Drinker,1)==null
                && CaelumDemonService.Potion(Drinker,2)==null,"empty supplies remain empty across repeated migration calls");
            Console.Printf("CA135 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
