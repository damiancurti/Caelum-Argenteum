// #380: escena aislada, datos artificiales fuera del paquete de producción.
class CA380Checkpoint : Inventory
{
    int Kits[2],Ammo[2],Practice[2],Readings[2];
    int Recipe,BookRevision;
    double Remaining,Total;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA380Checks : StaticEventHandler
{
    int Passed,Failed;
    CaelumCraftingStation Bench,Ranged;
    void Check(bool ok,String label)
    { if(ok)Passed++;else Failed++;Console.Printf("CA380 %s %s",ok?"PASS":"FAIL",label); }
    void Result(){Console.Printf("CA380 RESULT %d PASS %d FAIL",Passed,Failed);}
    int Recipe(int n){return n==0?CaelumConstants.CRAFTING_CARBINE_CARTRIDGE_RECIPE:CaelumConstants.CRAFTING_SHOTGUN_CARTRIDGE_RECIPE;}
    int Kit(int n){return CaelumCraftingRules.GetRecipeCartridgeKit(Recipe(n));}
    int Count(CaelumPlayer u,int n)
    {let a=u.FindInventory(u.GetAmmunitionClassName(CaelumCraftingRules.GetRecipeAmmunitionType(Recipe(n))));return a==null?0:a.Amount;}
    CaelumMaterialPickup Stock(CaelumPlayer u,int type,int amount,bool boxed=true)
    {
        let m=CaelumMaterialPickup(u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,type,1));
        if(m==null){m=CaelumMaterialPickup(u.CreateDetachedMaterialStack(type,1,Max(1,amount)));m.AttachToOwner(u);}
        m.Amount=amount;m.InMagicBox=boxed;m.UpdateMaterialVisuals();return m;
    }
    void Open(CaelumPlayer u)
    {Bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(Bench);}
    void Setup(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.CreationWizardOpen=false;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.CloseCraftingStationSession();u.CombatTimeRemaining=0;
        u.GrantMagicBoxFromPalomo(false);u.DebugSetAllCraftingRecipesKnown(true);
        Bench=CaelumCraftingStation(Actor.Spawn("CaelumWorkbenchStation",u.Pos+(48,0,0),NO_REPLACE));
        Ranged=CaelumCraftingStation(Actor.Spawn("CaelumRangedWorkshopStation",u.Pos+(0,48,0),NO_REPLACE));Open(u);
    }
    void Select(CaelumPlayer u,int n,int efficiency)
    {u.CraftingSelectionRecipe=Recipe(n);u.CraftingSelectionTier=3;u.CraftingEfficiencyIndex=efficiency;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();}
    void Suite(CaelumPlayer u)
    {
        Setup(u);let r=u.GetPersistentCharacterState(true);
        for(int n=0;n<2;n++)
        {
            int recipe=Recipe(n),slot=CaelumRecipeLearning.Slot(recipe,1);
            Check(CaelumCraftingRules.FindComponentRecipeForOutput(Kit(n))<0
                && CaelumCraftingRules.FindProcessingRecipeForOutput(Kit(n),1)<0,"kit is terminal purchased input");
            Check(CaelumMaterialRules.ResolveTier(Kit(n),3)==1,"kit remains single tier");
            Check(abs(CaelumEconomyRules.GetMaterialUnitBaseValue(Kit(n))-0.8*CaelumEconomyRules.GetAmmunitionUnitBaseValue(CaelumCraftingRules.GetRecipeAmmunitionType(recipe)))<0.000001,"kit price uses cartridge anchor exactly once");
            for(int efficiency=0;efficiency<3;efficiency++)
            {
                r.RecipeRereadings[slot]=0;r.RecipePractice[slot]=0;
                let m=Stock(u,Kit(n),100);u.OnNativeInventoryChanged();Select(u,n,efficiency);
                int required=efficiency==0?40:efficiency==1?20:10;
                Check(u.CraftingSelectionTier==1 && u.CraftingBasicRequired==required && u.CraftingTierRequired==0,"preview exact indivisible kit input at each efficiency");
                Check(abs(m.GetUnitWeight()-(n==0?0.040:0.045))<0.000001 && abs(u.CraftingFinalWeight-m.GetUnitWeight()*10)<0.000001,"native input/output mass matches approved kit");
                double base=40.0*CaelumConstants.CRAFTING_COMPLEX_TICS_PER_MATERIAL/TICRATE*100.0/u.GetCraftingDexterityPercent();
                Check(abs(u.CraftingPreviewSeconds-base*(efficiency==0?1:efficiency==1?10:100))<0.00001,"common 25 percent time baseline and mastery factors");
                int before=Count(u,n);u.BeginSelectedCraftingTask();
                Check(u.CraftingTaskActive && m.Amount==100,"start reserves without spending");
                Check(u.GetReservedCraftingMaterialUnits(Kit(n),1)==required,"reservation uses native kit quantities");
                u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
                Check(m.Amount==100-required && Count(u,n)==before+10 && u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"exact kit consumption and existing ammo output");
                Check(r.RecipePractice[slot]==10,"ten cartridges grant ten consumable practice");
                u.CompleteCraftingTask();Check(m.Amount==100-required && Count(u,n)==before+10 && r.RecipePractice[slot]==10,"duplicate completion is inert");
            }
            let m=Stock(u,Kit(n),9);Select(u,n,2);int before=Count(u,n);
            u.BeginSelectedCraftingTask();Check(!u.CraftingTaskActive && m.Amount==9 && Count(u,n)==before,"shortage cannot create ammo or consume kit");
            m.Amount=100;u.OnNativeInventoryChanged();Select(u,n,2);
            r.KnownRecipeTiers[recipe]=0;r.KnownCraftingRecipe[recipe]=false;u.BeginSelectedCraftingTask();
            Check(!u.CraftingTaskActive && m.Amount==100,"unknown recipe cannot start");r.LearnCraftingRecipe(recipe,1);
            Select(u,n,2);u.BeginSelectedCraftingTask();double remaining=u.CraftingTaskRemainingSeconds;
            u.CloseCraftingStationSession();u.UpdateCraftingTask();
            Check(u.CraftingTaskActive && !u.CraftingTaskProgressing && u.CraftingTaskRemainingSeconds==remaining && m.Amount==100,"closed session pauses without spending");
            Open(u);u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            Check(Count(u,n)==before+10 && m.Amount==90,"reopening resumes same reserved output");
            Select(u,n,2);u.BeginSelectedCraftingTask();u.CancelCraftingTask();
            Check(m.Amount==90 && u.GetReservedCraftingMaterialUnits(Kit(n),1)==0,"cancel releases all kits without payment");
            Select(u,n,2);u.BeginSelectedCraftingTask();m.Amount=9;before=Count(u,n);
            u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            Check(m.Amount==9 && Count(u,n)==before,"completion revalidates missing reserved kits before spending");
            u.CancelCraftingTask();m.Amount=90;u.OnNativeInventoryChanged();
            r.RecipeRereadings[slot]=10;r.RecipePractice[slot]=0;Select(u,n,2);double reading=u.CraftingPreviewSeconds;
            r.RecipeRereadings[slot]=0;r.RecipePractice[slot]=1000;Select(u,n,2);
            Check(abs(reading/u.CraftingPreviewSeconds-10)<0.000001,"practice alone reaches minimum; reading alone leaves second factor");
            r.RecipeRereadings[slot]=0;r.RecipePractice[slot]=0;
            let q=new("CaelumRecipeQuote");q.Build(u,recipe,1);
            Check(q.Sheets.Size()==1 && q.Sheets[0]==slot && q.Seconds>0,"recipe sheet includes no invented kit manufacturing");
            let pickup=CaelumMaterialPickup(u.CreateDetachedMaterialStack(Kit(n),1,3));pickup.UpdateMaterialVisuals();
            Check(pickup.Icon.IsValid() && pickup.sprite==pickup.GetSpriteIndex(String.Format("M%03d",Kit(n))),"kit own icon and world sprite registered");
            Actor receiver=u;int old=m.Amount;bool accepted=pickup.CallTryPickup(receiver);
            Check(accepted && m.Amount==old+3,"native pickup merges correct kit identity");
        }
        Ranged.Destroy();Open(u);Select(u,0,2);u.BeginSelectedCraftingTask();
        Check(!u.CraftingTaskActive && u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP,"ranged workshop is required");
        Ranged=CaelumCraftingStation(Actor.Spawn("CaelumRangedWorkshopStation",u.Pos+(0,48,0),NO_REPLACE));Open(u);
        // Municiones ya aceptadas siguen en la misma autoridad y receta.
        for(int recipe=CaelumConstants.CRAFTING_ARROW_RECIPE;recipe<=CaelumConstants.CRAFTING_BOLT_RECIPE;recipe++)
        {
            Stock(u,CaelumConstants.MATERIAL_SHAFT,1000);Stock(u,CaelumConstants.MATERIAL_POINT,1000);
            u.CraftingSelectionRecipe=recipe;u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
            Name cls=u.GetAmmunitionClassName(CaelumCraftingRules.GetRecipeAmmunitionType(recipe));let a=u.FindInventory(cls);int before=a==null?0:a.Amount;
            Check(u.CraftingBasicRequired==350 && u.CraftingTierRequired==150,"arrow and bolt retain 70/30 material recipe");
            u.BeginSelectedCraftingTask();u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();a=u.FindInventory(cls);
            Check(a!=null && a.Amount==before+10,"arrow and bolt native batches still complete");
        }
        Capacity(u);Result();
    }
    void Capacity(CaelumPlayer u)
    {
        for(int n=0;n<2;n++)for(int boxed=0;boxed<2;boxed++)
        {
            let m=Stock(u,Kit(n),20,boxed!=0);let a=CaelumCarbineAmmo(u.FindInventory(u.GetAmmunitionClassName(CaelumCraftingRules.GetRecipeAmmunitionType(Recipe(n)))));
            a.InMagicBox=boxed!=0;u.OnNativeInventoryChanged();Select(u,n,2);
            u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"same-destination capacity reserves batch");
            int slots=u.DerivedStats.MagicBoxCapacity;u.DerivedStats.MagicBoxCapacity=u.CountNativeMagicBoxSlots();
            double limit=u.DerivedStats.CarryCapacity;u.RefreshCarriedInventorySummary();
            // Exact capacity: equal input/output weight must be legal.
            u.DerivedStats.CarryCapacity=u.DerivedStats.CarriedWeight;
            Check(u.CanCompletePreparedEquipmentOutput(u.CraftingFinalWeight),"mass-neutral batch fits exactly full personal or Box load");
            u.DerivedStats.CarryCapacity=limit;u.DerivedStats.MagicBoxCapacity=slots;u.CancelCraftingTask();
            int amount=a.Amount;a.Amount=a.MaxAmount;Select(u,n,2);u.BeginSelectedCraftingTask();
            Check(!u.CraftingTaskActive && m.Amount==20,"full ammo stack rejected before reservation");a.Amount=amount;
            // Output switches destination only by the existing ammo stack flag.
            m.InMagicBox=true;a.InMagicBox=false;u.OnNativeInventoryChanged();Select(u,n,2);
            double cap=u.DerivedStats.CarryCapacity;u.DerivedStats.CarryCapacity=0;u.BeginSelectedCraftingTask();
            Check(!u.CraftingTaskActive && m.Amount==20,"boxed inputs do not bypass personal output capacity");u.DerivedStats.CarryCapacity=cap;
        }
    }
    void Save(CaelumPlayer u)
    {
        Setup(u);let r=u.GetPersistentCharacterState(true);
        for(int n=0;n<2;n++)
        {
            Stock(u,Kit(n),100);CaelumRecipeLearning.Receive(u,Recipe(n),1);Select(u,n,2);
            u.BeginSelectedCraftingTask();u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            int slot=CaelumRecipeLearning.Slot(Recipe(n),1);r.RecipeRereadings[slot]=n+3;
        }
        Select(u,1,2);u.BeginSelectedCraftingTask();u.CloseCraftingStationSession();u.PersistCharacterState();
        let m=CA380Checkpoint(Actor.Spawn("CA380Checkpoint",u.Pos,NO_REPLACE));m.AttachToOwner(u);
        for(int n=0;n<2;n++)
        {int slot=CaelumRecipeLearning.Slot(Recipe(n),1);m.Kits[n]=u.CountRawCraftingMaterial(Kit(n),1);m.Ammo[n]=Count(u,n);m.Practice[n]=r.RecipePractice[slot];m.Readings[n]=r.RecipeRereadings[slot];}
        m.Recipe=u.CraftingTaskRecipeIndex;m.Remaining=u.CraftingTaskRemainingSeconds;m.Total=u.CraftingTaskTotalSeconds;m.BookRevision=r.RecipeBookVersion;Verify(u);
    }
    void Verify(CaelumPlayer u)
    {
        let m=CA380Checkpoint(u.FindInventory("CA380Checkpoint"));Check(m!=null,"checkpoint survives");if(m==null){Result();return;}
        let r=u.GetPersistentCharacterState(true);let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        Check(u.CraftingTaskActive && !u.CraftingTaskProgressing && u.CraftingTaskRecipeIndex==m.Recipe
            && u.CraftingTaskRemainingSeconds==m.Remaining && u.CraftingTaskTotalSeconds==m.Total,"paused cartridge task and time survive");
        Check(r.RecipeBookVersion==11 && m.BookRevision==11,"numbered recipe revision survives");
        for(int n=0;n<2;n++)
        {int slot=CaelumRecipeLearning.Slot(Recipe(n),1);
         Check(u.CountRawCraftingMaterial(Kit(n),1)==m.Kits[n] && Count(u,n)==m.Ammo[n],"saved kits/ammo keep counts and identities");
         Check(r.RecipePractice[slot]==m.Practice[n] && r.RecipeRereadings[slot]==m.Readings[n] && book!=null && book.Sheets[slot],"appended knowledge progress and sheets survive");}
        Check(u.GetReservedCraftingMaterialUnits(Kit(1),1)==10,"saved task reserves ten kits exactly once");Result();
    }
    void Author(CaelumPlayer u)
    {
        Setup(u);u.CloseCraftingStationSession();
        Bench.SetOrigin(u.Pos+(128,-40,0),false);Ranged.SetOrigin(u.Pos+(128,40,0),false);
        Actor.Spawn("CaelumDiningTableSmall",u.Pos+(128,128,0),NO_REPLACE);
        for(int n=0;n<2;n++)
        {Stock(u,Kit(n),1000);CaelumRecipeLearning.Receive(u,Recipe(n),1);
         let p=CaelumMaterialPickup(u.CreateDetachedMaterialStack(Kit(n),1,10));p.SetOrigin(u.Pos+(96,n*80-40,0),false);p.UpdateMaterialVisuals();}
        u.OnNativeInventoryChanged();u.EquipmentMenuOpen=false;u.FormalInventoryFilter=0;u.RefreshFormalInventorySnapshot();
        Console.Printf("CA380 READY: 1000 kits de cada tipo en la Caja, recetario y 2 kits en el suelo. Banco/taller delante; recetas aprendidas para la prueba.");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca380_suite")Suite(u);
        if(e.Name=="ca380_save")Save(u);
        if(e.Name=="ca380_verify")Verify(u);
        if(e.Name=="ca380_author")Author(u);
    }
}
