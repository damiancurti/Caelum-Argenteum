// Full native task durations and real provision simulation; no accelerated
// remaining seconds. Established story challenge flags are seeded as in journey.
class CA183Endurance : EventHandler
{
    int Age, Stage, WeaponId, Failures, RecipeIndex;
    bool Waiting, Done;
    CaelumTimeSkipModel Forecast;
    void Check(bool ok,String label){if(!ok)Failures++;Console.Printf("CA183 %s %s",ok?"PASS":"FAIL",label);}
    static Actor Find(String cls) { let i=ThinkerIterator.Create(cls);return Actor(i.Next()); }
    static void EndTalk(CaelumPlayer u)
    { if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null; }
    static Actor Talk(CaelumPlayer u,String cls)
    { EndTalk(u);let a=Find(cls);if(a==null)return null;u.SetOrigin(a.Pos+(0,-64,0),false);u.Vel=(0,0,0);u.player.ConversationNPC=a;a.bInConversation=true;return a; }
    static void Palomo(CaelumPlayer u)
    { let p=CaelumPalomo(Find("CaelumPalomo"));p.SetOrigin((500,120,264),false);p.DepartureStarted=true;p.DepartureDone=true;p.NarrativeRevealRequired=true;Talk(u,"CaelumPalomo"); }
    static bool Station(CaelumPlayer u, int group = 2)
    {
        EndTalk(u);let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation s;
        while((s=CaelumCraftingStation(it.Next()))!=null)
            if(s.CraftingRoomGroup==group && s.GetCraftingStationType()==CaelumConstants.CRAFTING_STATION_WORKBENCH)
            {u.SetOrigin(s.Pos+(0,48,0),false);u.Vel=(0,0,0);s.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(s);return true;}
        return false;
    }
    int Materials(CaelumPlayer u)
    {int n=0;for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)n+=u.CountRawCraftingMaterial(m,1);return n;}

    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;Age++;
        let r=u.GetPersistentCharacterState(true);
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.bInvulnerable=true;}
        if(Age==90)
        {
            Stage=1;r.EnsureQuestStateInitialized();r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
            u.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;u.CharacterProfile.FirstClass=1;u.CharacterProfile.SecondClass=1;
            u.CharacterAllocation.Recommend(u.CharacterProfile);u.ApplyCharacterProfile();r.MainM00StarterChosen=false;CaelumOnboarding.Initialize(u);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
            Palomo(u);Check(CaelumMainM00Loadout.Choose(u,2,0),"Palomo chooses Seal");Check(!CaelumMainM00Loadout.Choose(u,0,4),"Palomo cannot change profession weapon");
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE;
            CaelumOnboarding.Update(u);CaelumTarotDeckRules.Grant(u);CaelumMainM00Gifts.EnsureTool(u,false);CaelumMainM00Necklace.EnsureGranted(u);
            Talk(u,"CaelumRonnie");Check(CaelumMainM00RonnieTrial.Start(u),"Ronnie starts after Seal and established practices");
            WeaponId=r.MainM00StarterWeaponId;Check(WeaponId>0 && r.MainM00PickaxeId>0 && r.MainM00ShieldId>0 && r.MainM00NecklaceItemId>0,"resident gifts exist");
            Check(u.CountInv("CaelumArrowAmmo")==24 && u.CountInv("CaelumBoltAmmo")==0 && u.CountInv("CaelumCarbineAmmo")==0,"24 arrows remain separate from bolts/firearm rounds");
            Check(!CaelumOnboarding.ClaimMaterials(u),"exchange rejects missing gold");EndTalk(u);
            int minerals=0;let it=ThinkerIterator.Create("CaelumRockEnvironmentProp");Actor node;while((node=Actor(it.Next()))!=null)if(node.Pos.Z<0)minerals++;
            Check(minerals==1,"basement contains only the gold mineral node");
            let gold=CaelumTutorialGoldVein(Find("CaelumTutorialGoldVein"));Check(gold!=null && Find("CaelumMainM00SupplyChest")==null,"one gold source and no old supply chest");
            if(gold!=null)
            {
                Console.Printf("CA183 GOLD capacity=%.3f",gold.ResourceRemainingUnits);
                Check(gold.ResourceRemainingUnits==2000,"gold capacity exactly two kilograms");
                u.SetOrigin(gold.Pos+(0,-64,0),false);
                gold.TryExtractResource(u,gold.GetRequiredHarvestDamageType(),1000000,CaelumConstants.WEAPON_TYPE_PICKAXE);
                Check(Find("CaelumTutorialGoldVein")==null,"depleted gold disappears");
                let drops=ThinkerIterator.Create("CaelumMaterialPickup");CaelumMaterialPickup drop;
                while((drop=CaelumMaterialPickup(drops.Next()))!=null)if(drop.Owner==null && drop.args[0]==CaelumConstants.MATERIAL_RAW_GOLD){Actor receiver=u;drop.CallTryPickup(receiver);}
            }
            Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_RAW_GOLD,1)==2000,"native extraction yields exactly two kilograms");
            u.RefreshCarriedInventorySummary();
            int fill=int(Max(0,u.DerivedStats.CarryCapacity-u.DerivedStats.CarriedWeight-0.01)/0.001);
            let ballast=u.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_RAW_IRON,1,fill);ballast.InMagicBox=false;ballast.AttachToOwner(u);u.OnNativeInventoryChanged();
            Talk(u,"CaelumRonnie");Check(CaelumOnboarding.ClaimMaterials(u),"gold exchange succeeds with partial carry room");
            let needs=CaelumOnboarding.LessonMaterials(u);int pending=0;
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)pending+=Max(0,needs.Units[m]-r.MainM00SupplyIssued[m]);
            Check(pending>0,"partial reward leaves a finite claimable remainder");
            ballast.Destroy();u.OnNativeInventoryChanged();CaelumOnboarding.ClaimMaterials(u);
            Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_RAW_GOLD,1)==0,"exchange consumes all gold");
            int stock=Materials(u);CaelumOnboarding.ClaimMaterials(u);Check(stock==Materials(u),"exchange replay cannot duplicate materials");

            EndTalk(u);
        }
        if(Age<91 || Done)return;
        if(!Waiting && Forecast==null)
        {
            int recipe=RecipeIndex==0?134:RecipeIndex==1?56:135;
            Check(Station(u,5),"complete upstairs workshop opens");
            u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.CraftingSelectionSize=r.MainM00StarterSize;
            u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive,"real-duration utility task begins");
            if(!u.CraftingTaskActive){Done=true;return;}
            Forecast=new("CaelumTimeSkipModel");Forecast.CaptureSkip(u,false);
            Console.Printf("CA183 DURATION recipe=%d seconds=%.6f required_tics=%d",recipe,u.CraftingTaskRemainingSeconds,Forecast.RequiredTics);
        }
        if(Forecast!=null)
        {
            if(!Forecast.Done)Forecast.RunBatch();
            if(Forecast.Done)
            {
                Check(Forecast.Reason.Length()==0,"forecast completes without provision deadlock");
                Console.Printf("CA183 FORECAST reason=%s elapsed=%d food=%d water=%d",Forecast.Reason,Forecast.ElapsedTics,Forecast.FoodSpent,Forecast.WaterSpent);
                if(Forecast.Reason.Length()!=0){Done=true;return;}
                Check(CaelumTimeSkipState.OpenMenu(u),"native task skip opens");let skip=CaelumTimeSkipState.Get(u);
                skip.Forecast=Forecast;skip.TargetDay=Forecast.EndDay;skip.TargetTics=Forecast.EndTics;
                Check(CaelumTimeSkipState.Start(u,true),"native full-duration execution starts");Forecast=null;Waiting=true;
            }
        }
        let skip=CaelumTimeSkipState.Get(u);
        if(Waiting && skip!=null && skip.Completed)
        {
            Check(!u.CraftingTaskActive && u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"full-duration output succeeds");
            Console.Printf("CA183 LIVE recipe_index=%d work=%d hunger=%.6f thirst=%.6f reason=%s",RecipeIndex,skip.WorkTics,u.CurrentHunger,u.CurrentThirst,skip.LastReason);
            skip.Open=false;Waiting=false;RecipeIndex++;u.CloseCraftingStationSession();
            if(RecipeIndex==3)
            {
                Done=true;Check(CaelumOnboarding.LessonsComplete(r) && Materials(u)==0,"three full-duration lessons use exact reward");
                Station(u,5);u.CraftingSelectionRecipe=135;u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
                Check(!u.CraftingTaskActive && u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE,"duplicate canteen rejected before payment");
                u.CraftingSelectionRecipe=134;u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
                Check(!u.CraftingTaskActive && u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_FAILED_DUPLICATE,"duplicate bag rejected before payment");
                Console.Printf("CA183 ENDURANCE_DONE failures=%d",Failures);
            }
        }
    }
}
