// #378: comprobaciones aisladas; no modifica el catálogo de campaña.
class CA378Checkpoint : Inventory
{
    CaelumRecipeBook Book;
    int Slot;
    double Weight, Total, Remaining;
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA378Checks : StaticEventHandler
{
    int Passed, Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA378 %s %s",ok?"PASS":"FAIL",label);}
    void Suite(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.CloseCraftingStationSession();u.ClosePalomoMerchant();u.CreationWizardOpen=false;
        let r=u.GetPersistentCharacterState(true);r.SetAllCraftingRecipesKnown(false);
        r.HasPendingRecipeSheets=false;
        for(int i=0;i<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;i++)
        {r.PendingRecipeSheets[i]=0;r.IssuedRecipeSheets[i]=0;}
        int recipe=CaelumCraftingRules.FindUnifiedPhysicalRecipeIndex(CaelumConstants.CATALOGUE_WEAPON_LONGBOW);
        int slot=CaelumRecipeLearning.Slot(recipe,1);
        Check(CaelumRecipeLearning.TimeFactor(0,0,recipe,0)==1,"25 percent base");
        Check(CaelumRecipeLearning.TimeFactor(0,0,recipe,1)==10,"50 percent initial");
        Check(CaelumRecipeLearning.TimeFactor(0,0,recipe,2)==100,"100 percent initial");
        Check(CaelumRecipeLearning.TimeFactor(10,0,recipe,2)==10,"reading alone cannot reach fastest");
        Check(CaelumRecipeLearning.TimeFactor(0,10,recipe,2)==1,"practice alone reaches fastest");
        Check(CaelumRecipeLearning.TimeFactor(999,999,recipe,2)==1,"progress bounded");
        int ammo=CaelumConstants.CRAFTING_ARROW_RECIPE;
        Check(CaelumRecipeLearning.TimeFactor(0,1000,ammo,2)==1,"consumable 1000 units");
        Check(CaelumRecipeLearning.TimeFactor(0,10,ammo,2)>1,"one ammunition batch is not mastery");
        double t25=CaelumRecipeLearning.WorkSeconds(u,recipe,1,40,35,0);
        Check(Abs(CaelumRecipeLearning.WorkSeconds(u,recipe,1,20,35,1)/t25-10)<0.00001,"same output normalized 50 percent");
        Check(Abs(CaelumRecipeLearning.WorkSeconds(u,recipe,1,10,35,2)/t25-100)<0.00001,"same output normalized 100 percent");
        int bronze=CaelumCraftingRules.FindProcessingRecipeForOutput(CaelumConstants.MATERIAL_BRONZE_INGOT,1);
        int bronzeSlot=CaelumRecipeLearning.Slot(bronze,1);r.RecipePractice[bronzeSlot]=1000;
        double bronzeBase=CaelumRecipeLearning.WorkSeconds(u,bronze,1,5,35,0,1);
        Check(CaelumRecipeLearning.WorkSeconds(u,bronze,1,3,35,1,1)==bronzeBase
            && CaelumRecipeLearning.WorkSeconds(u,bronze,1,2,35,2,1)==bronzeBase,"rounded one-unit bronze converges at mastery");
        double fixedBase=CaelumRecipeLearning.WorkSeconds(u,bronze,1,10,35,0,2,0);
        Check(CaelumRecipeLearning.WorkSeconds(u,bronze,1,10,35,2,10,0)/10==fixedBase/2,
            "fixed alloy batch preserves 25-percent time per output unit");
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=2;u.CraftingSelectionSize=1;
        u.CraftingEfficiencyIndex=1;u.CraftingProcessingBatchIndex=2;
        u.CraftingTaskActive=true;u.CraftingTaskTotalSeconds=123;u.CraftingTaskRemainingSeconds=91;
        let quote=new("CaelumRecipeQuote");quote.Build(u,recipe,1);
        Check(quote.Seconds>0 && quote.Sheets.Size()>1,"unknown recipe quote and dependency closure");
        Check(u.CraftingTaskActive && u.CraftingTaskTotalSeconds==123 && u.CraftingTaskRemainingSeconds==91,"quote preserves paused task");
        Check(!u.RecipeQuoteActive && u.CraftingEfficiencyIndex==1 && u.CraftingProcessingBatchIndex==2,"quote restores choices");
        Check(!r.KnowsCraftingRecipe(recipe,1) && !r.KnowsCraftingRecipe(recipe,2),"quote grants no knowledge");
        u.CancelCraftingTask();
        Check(r.OfferCraftingRecipe(recipe,1),"NPC source offers sheet");
        CaelumRecipeLearning.DeliverPending(u);
        let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        Check(book!=null && book.Sheets[slot],"first source delivers physical notebook");
        if(book==null){Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);return;}
        Check(Abs(book.GetUnitWeight()-(0.100+0.005*quote.Sheets.Size()))<0.00001,"empty book and all page masses");
        Check(!r.KnowsCraftingRecipe(recipe,1),"receiving paper does not teach");
        double mass=book.GetUnitWeight();
        r.OfferCraftingRecipe(recipe,1);CaelumRecipeLearning.DeliverPending(u);
        Check(book.GetUnitWeight()==mass,"duplicate source creates no second pages");
        let burden=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_WOOD,1,1000000);
        burden.AttachToOwner(u);u.OnNativeInventoryChanged();
        r.OfferCraftingRecipe(recipe,2);CaelumRecipeLearning.DeliverPending(u);
        Check(!book.Sheets[slot+1] && r.PendingRecipeSheets[recipe]!=0 && !r.KnowsCraftingRecipe(recipe,2),
            "capacity rejection keeps source pending without teaching or partial sheets");
        burden.Destroy();u.OnNativeInventoryChanged();CaelumRecipeLearning.DeliverPending(u);
        Check(book.Sheets[slot+1] && r.PendingRecipeSheets[recipe]==0,"capacity retry delivers entitlement once");
        mass=book.GetUnitWeight();
        let shelf=CaelumReadingShelf(Actor.Spawn("CaelumReadingShelf",u.Pos+(32,0,0),NO_REPLACE));
        Check(CaelumRecipeSession.OpenBook(u,book),"open notebook");
        let session=CaelumRecipeSession.Get(u);session.Selection=session.Rows.Find(slot);session.Refresh();
        Check(session.Start(),"start first reading near shelf");
        Check(Abs(session.TotalSeconds-quote.Seconds/8)<0.00001,"Intelligence M3 duration");
        Check(!r.KnowsCraftingRecipe(recipe,1),"start does not teach");
        double beforeStep=session.RemainingSeconds;
        CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(Abs(beforeStep-session.RemainingSeconds-1.0/TICRATE)<0.00001,"personal time step advances reading once");
        Check(CaelumTimeSkipState.TaskActive(u) && CaelumTimeSkipState.TaskAnchor(u)==shelf
            && CaelumTimeSkipState.TaskSeconds(u)==session.RemainingSeconds,"time forecast sees active reading and anchor");
        session.Open=false;beforeStep=session.RemainingSeconds;CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(session.RemainingSeconds==beforeStep,"personal time step preserves closed reading pause");
        session.Open=true;
        u.CraftingTaskActive=true;beforeStep=session.RemainingSeconds;session.Advance();
        Check(session.RemainingSeconds==beforeStep && !CaelumRecipeSession.Working(u) && !session.Start(),
            "paused craft prevents simultaneous reading and conflicting time forecasts");
        u.CraftingTaskActive=false;
        session.RemainingSeconds=0;session.Complete();
        Check(r.KnowsCraftingRecipe(recipe,1) && !r.KnowsCraftingRecipe(recipe,2),"first reading teaches only selected tier");
        Check(r.RecipeRereadings[slot]==0,"first reading has no reread bonus");
        bool children=true;
        for(int i=0;i<quote.Sheets.Size();i++)
            if(!r.KnowsCraftingRecipe(quote.Sheets[i]/3,quote.Sheets[i]%3+1))children=false;
        Check(children,"first reading teaches component recipes");
        double original=session.PreviewSeconds;
        for(int i=0;i<11;i++){session.Start();session.RemainingSeconds=0;session.Complete();}
        Check(r.RecipeRereadings[slot]==10,"ten reread cap");
        Check(session.PreviewSeconds<original,"rereading becomes faster");
        Check(book.GetUnitWeight()==mass && book.Sheets[slot],"reading retains every physical sheet");
        CaelumRecipeLearning.Practice(u,recipe,1,100);
        Check(r.RecipePractice[slot]==10 && r.RecipePractice[slot+1]==0,"practice capped separately per tier");
        Check(Abs(CaelumRecipeLearning.WorkSeconds(u,recipe,1,10,35,2)-t25)<0.00001,"trained 100 equals original 25 time");
        session.Open=false;
        let chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",u.Pos+(0,32,0),NO_REPLACE));
        chest.EnsureStorage();CaelumContainerSession.Open(u,chest);
        Check(CaelumInventoryService.TransferContainerItem(u,chest,book,1,true),"book deposits into chest");
        Check(book.Owner==chest && book.GetUnitWeight()==mass && book.Sheets[slot],"native storage preserves pages and weight");
        Check(CaelumInventoryService.TransferContainerItem(u,chest,book,1,false),"book withdraws from chest");
        Check(book.Owner==u && book.Sheets[slot],"withdrawal retains exact native notebook");
        let duplicate=CaelumRecipeBook(Actor.Spawn("CaelumRecipeBook",u.Pos,NO_REPLACE));
        duplicate.Sheets[slot]=true;
        Actor receiver=u;
        Check(!duplicate.CallTryPickup(receiver) && duplicate.Owner==null,"duplicate notebook pickup cannot bypass native uniqueness");
        duplicate.Destroy();
        CaelumContainerSession.Get(u).Close();CaelumRecipeSession.OpenBook(u,book);
        session.Selection=session.Rows.Find(slot);session.Refresh();session.Start();
        session.Open=false;double remaining=session.RemainingSeconds;session.Tick();
        Check(session.Active && session.RemainingSeconds==remaining,"closed reading pauses without rewarding");
        CaelumContainerSession.Open(u,chest);
        CaelumInventoryService.TransferContainerItem(u,chest,book,1,true);session.Tick();
        Check(!session.Active && !session.Open,"losing notebook releases interrupted task");
        CaelumInventoryService.TransferContainerItem(u,chest,book,1,false);
        CaelumContainerSession.Get(u).Close();CaelumRecipeSession.OpenBook(u,book);
        session.Selection=session.Rows.Find(slot);session.Refresh();
        u.DebugSetAllCraftingRecipesKnown(true);
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.RefreshCraftingPreview();
        u.CraftingBlueprintSelectedNode=Min(1,u.CraftingBlueprintNodeCount-1);
        int oldNode=u.CraftingBlueprintSelectedNode;quote.Build(u,recipe,2);
        Check(u.CraftingBlueprintSelectedNode==oldNode,"sheet quote preserves chosen crafting layer");
        session.Open=false;
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }

    void Craft(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        u.CancelCraftingTask();u.ClosePalomoMerchant();u.CreationWizardOpen=false;
        u.GrantMagicBoxFromPalomo(false);u.DebugSetAllCraftingRecipesKnown(true);
        let session=CaelumRecipeSession.Get(u);if(session!=null){session.Open=false;session.Active=false;}
        Array<Class<CaelumCraftingStation> > classes;
        classes.Push('CaelumWorkbenchStation');classes.Push('CaelumRangedWorkshopStation');
        classes.Push('CaelumSawmillStation');classes.Push('CaelumForgeStation');classes.Push('CaelumAnvilStation');
        CaelumCraftingStation bench;
        for(int i=0;i<classes.Size();i++)
        {let station=CaelumCraftingStation(Actor.Spawn(classes[i],u.Pos+(48,0,0),NO_REPLACE));if(i==0)bench=station;}
        bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(bench);
        u.CombatTimeRemaining=0;
        int recipe=CaelumCraftingRules.FindUnifiedPhysicalRecipeIndex(CaelumConstants.CATALOGUE_WEAPON_LONGBOW);
        for(int which=0;which<2;which++)
        {
            if(which==1)recipe=CaelumConstants.CRAFTING_ARROW_RECIPE;
            u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.CraftingSelectionSize=2;
            u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
            for(int k=0;k<2;k++)
            {
                int type=k==0?u.CraftingBasicMaterialType:u.CraftingTierMaterialType;
                int tier=k==0?u.CraftingBasicMaterialTier:u.CraftingTierMaterialTier;
                int units=k==0?u.CraftingBasicRequired:u.CraftingTierRequired;
                if(units<=0)continue;
                let material=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,type,tier);
                if(material==null){material=u.CreateDetachedMaterialStack(type,tier,units+10);material.AttachToOwner(u);}
                material.Amount=units+10;material.InMagicBox=true;
            }
            u.OnNativeInventoryChanged();u.RefreshCraftingPreview();
            let r=u.GetPersistentCharacterState(true);int slot=CaelumRecipeLearning.Slot(recipe,1);
            r.RecipePractice[slot]=0;
            u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,String.Format("native craft begins family %d",which));
            Check(r.RecipeClaimSlots.Size()>0,"practice waits in task metadata");
            double duration=u.CraftingTaskTotalSeconds;
            r.RecipeRereadings[slot]=10;u.RefreshCraftingPreview();
            Check(u.CraftingTaskTotalSeconds==duration,"new reading progress cannot rewrite active task");
            u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            int expected=which==0?1:CaelumConstants.CRAFTING_ARROW_BATCH;
            Check(r.RecipePractice[slot]==expected,String.Format("only successful output grants %d practice",expected));
            u.CompleteCraftingTask();Check(r.RecipePractice[slot]==expected,"duplicate completion does not grant practice");
            u.BeginSelectedCraftingTask();u.CancelCraftingTask();
            Check(r.RecipePractice[slot]==expected && r.RecipeClaimSlots.Size()==0,"cancel clears claim without practice");
        }
        // Fabricar solo una punta faltante y su bronce; el stock previo no practica.
        u.CraftingSelectionRecipe=CaelumConstants.CRAFTING_ARROW_RECIPE;
        u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
        let shafts=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_SHAFT,1);
        let points=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_POINT,1);
        shafts.Amount=u.CraftingBasicRequired;points.Amount=Max(0,u.CraftingTierRequired-1);
        Array<int> raw;raw.Push(CaelumConstants.MATERIAL_RAW_COPPER);raw.Push(CaelumConstants.MATERIAL_RAW_TIN);
        for(int i=0;i<raw.Size();i++)
        {let item=u.CreateDetachedMaterialStack(raw[i],1,100);item.InMagicBox=true;item.AttachToOwner(u);}
        let r=u.GetPersistentCharacterState(true);
        for(int i=0;i<CaelumRecipeLearning.SLOT_COUNT;i++)r.RecipePractice[i]=0;
        u.OnNativeInventoryChanged();u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
        int point=CaelumCraftingRules.FindComponentRecipeForOutput(CaelumConstants.MATERIAL_POINT);
        int bronze=CaelumCraftingRules.FindProcessingRecipeForOutput(CaelumConstants.MATERIAL_BRONZE_INGOT,1);
        Check(u.CraftingTaskActive && u.CraftingTaskUsesDirectPlan,"recursive craft uses partial component stock");
        int pointClaim=r.RecipeClaimSlots.Find(CaelumRecipeLearning.Slot(point,1));
        int bronzeClaim=r.RecipeClaimSlots.Find(CaelumRecipeLearning.Slot(bronze,1));
        Check(pointClaim<r.RecipeClaimSlots.Size() && bronzeClaim<r.RecipeClaimSlots.Size()
            && r.RecipeClaimAmounts[pointClaim]==1 && r.RecipeClaimAmounts[bronzeClaim]==1,
            "recursive claims contain only one missing point and one bronze unit");
        u.CancelCraftingTask();
        Check(r.RecipePractice[CaelumRecipeLearning.Slot(point,1)]==0 && r.RecipeClaimSlots.Size()==0,
            "recursive cancellation grants no component practice");
        u.BeginSelectedCraftingTask();u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(r.RecipePractice[CaelumRecipeLearning.Slot(point,1)]==1
            && r.RecipePractice[CaelumRecipeLearning.Slot(bronze,1)]==1,
            "recursive completion credits actual manufactured component outputs");
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }

    void SaveReading(CaelumPlayer u)
    {
        Suite(u);
        let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        CaelumRecipeSession.OpenBook(u,book);let session=CaelumRecipeSession.Get(u);session.Start();session.Open=false;
        let mark=CA378Checkpoint(Actor.Spawn("CA378Checkpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
        mark.Book=book;mark.Slot=session.TaskSlot;mark.Weight=book.GetUnitWeight();
        mark.Total=session.TotalSeconds;mark.Remaining=session.RemainingSeconds;
        Check(session.Active && mark.Remaining>0,"saved reading is active and paused");
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Verify(CaelumPlayer u)
    {
        let mark=CA378Checkpoint(u.FindInventory("CA378Checkpoint"));
        let session=CaelumRecipeSession.Get(u);
        Check(mark!=null && mark.Book!=null && mark.Book.Owner==u,"saved notebook identity and owner");
        if(mark==null || mark.Book==null)return;
        Check(mark.Book.GetUnitWeight()==mark.Weight && mark.Book.Sheets[mark.Slot],"saved pages and weight");
        Check(session!=null && session.Active && !session.Open && session.TaskSlot==mark.Slot
            && session.TotalSeconds==mark.Total && session.RemainingSeconds==mark.Remaining,"saved reading keeps frozen duration and pause");
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Mansion(CaelumPlayer u)
    {
        Check(level.MapName=="MAP01","mansion fixture map");
        Check(CaelumMansionFurniture.ReadingShelf(),"reading shelf installation fits opposite room");
        let it=ThinkerIterator.Create("CaelumReadingShelf");int count=0;CaelumReadingShelf shelf;
        while((shelf=CaelumReadingShelf(it.Next()))){count++;Check(shelf.Pos==CaelumReadingFurnitureData.Position(),"authored shelf position");}
        CaelumMansionFurniture.ReadingShelf();
        it=ThinkerIterator.Create("CaelumReadingShelf");int again=0;while(it.Next()!=null)again++;
        Check(count==1 && again==1,"furniture migration idempotent");
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Upgrade(CaelumPlayer u)
    {
        let r=u.GetPersistentCharacterState(true);r.EnsureTierRecipeBook();
        int recipe=CaelumCraftingRules.FindUnifiedPhysicalRecipeIndex(CaelumConstants.CATALOGUE_WEAPON_LONGBOW);
        Check(r.KnowsCraftingRecipe(recipe,1) && r.KnowsCraftingRecipe(recipe,2)
            && r.KnowsCraftingRecipe(recipe,3),"legacy all formerly accessible tiers retained");
        Check(!r.KnowsCraftingRecipe(CaelumConstants.CRAFTING_ARROW_RECIPE,1),"legacy unknown recipe still gated");
        CaelumRecipeLearning.DeliverPending(u);
        let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        Check(book!=null && book.Sheets[CaelumRecipeLearning.Slot(recipe,3)],"legacy known recipes receive physical sheets");
        if(book!=null)
        {
            double weight=book.GetUnitWeight();r.EnsureTierRecipeBook();CaelumRecipeLearning.DeliverPending(u);
            Check(book.GetUnitWeight()==weight && r.RecipeRereadings[CaelumRecipeLearning.Slot(recipe,1)]==0
                && r.RecipePractice[CaelumRecipeLearning.Slot(recipe,1)]==0,"idempotent migration with zero invented progress");
        }
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void UserInterface(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CreationWizardOpen=false;
        u.CancelCraftingTask();u.ClosePalomoMerchant();u.CloseCraftingStationSession();
        let r=u.GetPersistentCharacterState(true);r.SetAllCraftingRecipesKnown(false);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        int recipe=CaelumCraftingRules.FindUnifiedPhysicalRecipeIndex(CaelumConstants.CATALOGUE_WEAPON_LONGBOW);
        for(int tier=1;tier<=3;tier++)CaelumRecipeLearning.Receive(u,recipe,tier);
        let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        CaelumRecipeSession.OpenBook(u,book);
        let session=CaelumRecipeSession.Get(u);session.Filter=0;
        session.Selection=session.Rows.Find(CaelumRecipeLearning.Slot(recipe,1));session.Refresh();
    }
    void ShelfView(CaelumPlayer u)
    {
        u.CreationWizardOpen=false;u.CloseCraftingStationSession();u.ClosePalomoMerchant();u.EquipmentMenuOpen=false;
        let session=CaelumRecipeSession.Get(u);if(session!=null)session.Open=false;
        u.SetOrigin((368,-480,0),false);u.Angle=270;u.Pitch=0;
    }
    void TimeAdvance(CaelumPlayer u)
    {
        UserInterface(u);u.CombatTimeRemaining=0;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        Actor.Spawn("CaelumReadingShelf",u.Pos+(32,0,0),NO_REPLACE);
        let reading=CaelumRecipeSession.Get(u);Check(reading.Start(),"timed reading starts");
        double remaining=reading.RemainingSeconds;
        Check(CaelumTimeAdvanceState.Toggle(u),"existing x105 acceleration accepts reading");
        CaelumTimeAdvanceState.Pump(u);
        Check(reading.RemainingSeconds<remaining-1,"accelerated personal steps perform reading");
        reading.Open=false;let fast=CaelumTimeAdvanceState.Get(u);fast.LastPumpTic=-1;
        CaelumTimeAdvanceState.Pump(u);Check(!fast.Active,"closing book halts acceleration");
        reading.Open=true;reading.RemainingSeconds=1;
        Check(CaelumTimeSkipState.OpenMenu(u),"existing date skip accepts reading");
        let skip=CaelumTimeSkipState.Get(u);
        Check(skip.Forecast!=null && skip.Forecast.RequiredTics==TICRATE,"reading duration feeds common forecast");
        skip.Active=true;skip.Sleeping=true;remaining=reading.RemainingSeconds;
        CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(reading.RemainingSeconds==remaining,"simulated sleep pauses reading");
        skip.Active=false;skip.Sleeping=false;
        let thermal=CaelumThermalBody.Get(u);thermal.Exposure=1;skip.Recalculate(u);
        Check(skip.Forecast.Reason=="CA_SKIP_FORECAST_EFFECT","reading forecast retains thermal-effect guard");
        thermal.Exposure=0;skip.Recalculate(u);skip.Forecast.RunBatch();
        Console.Printf("CA378 FORECAST reason=%s done=%d tics=%d",skip.Forecast.Reason,skip.Forecast.Done,skip.Forecast.RequiredTics);
        Check(skip.Forecast.Done && skip.Forecast.Reason=="","reading forecast completes under existing survival rules");
        skip.TargetDay=skip.Forecast.EndDay;skip.TargetTics=skip.Forecast.EndTics;
        Check(CaelumTimeSkipState.Start(u,true),"forecast destination starts real reading skip");
        CaelumTimeSkipState.Pump(u);
        Check(!reading.Active && skip.WorkTics>=TICRATE,"real skip finishes reading with actual work tics");
        Check(!skip.Active && skip.LastReason=="CA_SKIP_COMPLETE"
            && (CaelumTimeSkipState.NowDay(u)>skip.TargetDay
                || (CaelumTimeSkipState.NowDay(u)==skip.TargetDay && CaelumTimeSkipState.NowTics(u)>=skip.TargetTics)),
            "reading skip reaches the rounded date even after work finishes in Limbo");
        CaelumTimeSkipState.FinishSkip(u,"",true);
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    void Sources(CaelumPlayer u)
    {
        UserInterface(u);let session=CaelumRecipeSession.Get(u);session.Open=false;
        let r=u.GetPersistentCharacterState(true);
        r.MainM00StarterChosen=true;r.MainM00StarterOption=14;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED,false);
        CaelumMainM00RonnieTrial.TeachStarterAmmunition(u);
        Check(r.PendingRecipeSheets[CaelumConstants.CRAFTING_ARROW_RECIPE]==0,"Ronnie source rejects before tutorial eligibility");
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
        CaelumMainM00RonnieTrial.TeachStarterAmmunition(u);CaelumRecipeLearning.DeliverPending(u);
        let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
        Check(book.Sheets[CaelumRecipeLearning.Slot(CaelumConstants.CRAFTING_ARROW_RECIPE,1)]
            && !r.KnowsCraftingRecipe(CaelumConstants.CRAFTING_ARROW_RECIPE),"Ronnie source delivers unread ammunition sheets");
        double weight=book.GetUnitWeight();CaelumMainM00RonnieTrial.TeachStarterAmmunition(u);
        CaelumRecipeLearning.DeliverPending(u);Check(book.GetUnitWeight()==weight,"Ronnie repeated source is idempotent");
        r.MainM00AmuletChoice=1;r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE,false);
        Check(!CaelumMainM00Necklace.Teach(u),"Caella source rejects before quest eligibility");
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
        Check(!CaelumMainM00Necklace.Teach(u),"Caella source requires actual authorized speaker context");
        let speaker=CaelumCaella(Actor.Spawn("CaelumCaella",u.Pos+(64,0,0),NO_REPLACE));
        speaker.StoryAnchored=true;speaker.bInConversation=true;
        u.player.ConversationPC=u;u.player.ConversationNPC=speaker;
        int stage=r.QuestStage[0];
        Check(CaelumMainM00Necklace.Teach(u),"Caella confirmed eligible source offers selected amulet sheets");
        speaker.bInConversation=false;u.player.ConversationNPC=null;u.player.ConversationPC=null;
        CaelumRecipeLearning.DeliverPending(u);
        Check(book.Sheets[CaelumRecipeLearning.Slot(CaelumMainM00Necklace.Recipe(0),1)]
            && !r.KnowsCraftingRecipe(CaelumMainM00Necklace.Recipe(0)),"Caella sheet receipt still requires reading");
        Check(r.QuestStage[0]==stage,"sheet acquisition does not complete or advance quest");
        Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca378_suite")Suite(u);
        if(e.Name=="ca378_craft")Craft(u);
        if(e.Name=="ca378_save")SaveReading(u);
        if(e.Name=="ca378_verify")Verify(u);
        if(e.Name=="ca378_mansion")Mansion(u);
        if(e.Name=="ca378_upgrade")Upgrade(u);
        if(e.Name=="ca378_ui")UserInterface(u);
        if(e.Name=="ca378_shelf_view")ShelfView(u);
        if(e.Name=="ca378_time")TimeAdvance(u);
        if(e.Name=="ca378_sources")Sources(u);
        if(e.Name=="ca378_author"){UserInterface(u);ShelfView(u);}
        if(e.Name=="ca378_finish_reading")
        {
            let session=CaelumRecipeSession.Get(u);
            if(session!=null && session.Active){session.RemainingSeconds=0;session.Complete();}
        }
        if(e.Name=="ca378_native_use")
        {
            let book=CaelumRecipeBook(u.FindInventory("CaelumRecipeBook"));
            Check(book!=null && book.Amount==1 && book.GetUnitWeight()>0.100,"native use command retains notebook");
            Console.Printf("CA378 RESULT %d PASS %d FAIL",Passed,Failed);
        }
    }
}
