// Isolated native transactions. Existing social/magic/combat challenges are
// seeded explicitly; crafting duration is accelerated in this fixture only.
class CA183Journey : StaticEventHandler
{
    int Age, Failures, Stage, WeaponId, Wear, ArrowCount;
    Inventory Bag, Canteen, Deck;
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        Stage=3;let u=CaelumPlayer(players[0].mo);if(u==null)return;let r=u.GetPersistentCharacterState(true);
        if(level.MapName=="MAP01")
        {
            Check(r.MainM00GoldRewardStarted && Find("CaelumTutorialGoldVein")==null,"partial reward save retains paid gold and depleted node");
            let ballast=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_RAW_IRON,1);if(ballast!=null)ballast.Destroy();u.OnNativeInventoryChanged();
            Talk(u,"CaelumRonnie");CaelumOnboarding.ClaimMaterials(u);int total=Materials(u);CaelumOnboarding.ClaimMaterials(u);
            Check(total==Materials(u),"reloaded reward remainder is issued once");
            let needs=CaelumOnboarding.LessonMaterials(u);
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)Check(r.MainM00SupplyIssued[m]==needs.Units[m],"reloaded reward has exact recipe totals");
            Console.Printf("CA183 PARTIAL_RELOAD_DONE failures=%d",Failures);EndTalk(u);return;
        }
        Check(level.MapName=="MAP02" && CaelumOnboarding.LessonsComplete(r),"MAP02 reload retains lesson identities");
        Check(r.MainM00CraftedBag.Owner==u && r.MainM00CraftedCanteen.Owner==u && CaelumWaterContainer(r.MainM00CraftedCanteen).WaterLiters==1.25,"reload retains owned bag/canteen and water");
        Check(CaelumCarbineAmmo(u.FindInventory("CaelumArrowAmmo")).InMagicBox && r.HasTarotCard(CaelumConstants.TAROT_THE_FOOL),"reload retains boxed matching ammo and Fool");
        let boxes=ThinkerIterator.Create("CaelumMazeChest");CaelumMazeChest chest;int remaining=0;
        while((chest=CaelumMazeChest(boxes.Next()))!=null)for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)remaining+=chest.MaterialRemaining[m];
        Check(remaining==0,"depleted chests remain empty after save/load");Console.Printf("CA183 RELOAD_DONE failures=%d",Failures);
    }
    void Check(bool ok, String text) { if(!ok)Failures++; Console.Printf("CA183 %s %s",ok?"PASS":"FAIL",text); }
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
    void Craft(CaelumPlayer u,int recipe)
    {
        Check(Station(u,recipe==56?4:2),"appropriate resident workshop reachable");
        u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;u.CraftingSelectionSize=u.GetPersistentCharacterState(true).MainM00StarterSize;
        u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
        u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"native task begins with exchange materials only");
        Console.Printf("CA183 CRAFT recipe=%d action=%d known=%d infra=%d seconds=%.6f stock=%d",recipe,u.LastCraftingAction,u.CraftingSelectedRecipeKnown,u.CraftingSelectedInfrastructureAvailable,u.CraftingTaskRemainingSeconds,Materials(u));
        if(!u.CraftingTaskActive)return;
        int stock=Materials(u);u.CancelCraftingTask();Check(Materials(u)==stock,"cancellation preserves stock");
        u.BeginSelectedCraftingTask();u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"native output and payment complete");u.CloseCraftingStationSession();
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;Age++;
        let r=u.GetPersistentCharacterState(true);
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.bInvulnerable=true;}
        if(Age==90 && Stage==0)
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
            if(CVar.FindCVar('ca183_stage').GetInt()==1){Stage=99;EndTalk(u);Console.Printf("CA183 PARTIAL_SAVE_READY remainder=%d",pending);return;}
            ballast.Destroy();u.OnNativeInventoryChanged();CaelumOnboarding.ClaimMaterials(u);
            Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_RAW_GOLD,1)==0,"exchange consumes all gold");
            int stock=Materials(u);CaelumOnboarding.ClaimMaterials(u);Check(stock==Materials(u),"exchange replay cannot duplicate materials");
            Craft(u,CaelumConstants.CRAFTING_SLEEPING_BAG_RECIPE);Check(!CaelumOnboarding.LessonsComplete(r),"bag alone cannot complete Ronnie");
            Craft(u,56);Craft(u,CaelumConstants.CRAFTING_LARGE_CANTEEN_RECIPE);
            Check(CaelumOnboarding.LessonsComplete(r),"all three utilities complete lesson");
            if(!CaelumOnboarding.LessonsComplete(r)){Stage=99;return;}
            Check(Materials(u)==0,"exact exchange budget leaves no spare materials");
            Talk(u,"CaelumRonnie");Check(CaelumMainM00RonnieTrial.Finish(u),"Ronnie completion unlocks combat");
            Talk(u,"CaelumRulo");Check(CaelumMainM00RuloTrial.Begin(u),"Rulo gives armor and bolas");
            let weapon=u.FindNativeEquipmentItemById(WeaponId);Wear=weapon.Durability-1;weapon.Durability=Wear;
            CaelumMainM00RuloTrial.Begin(u);Check(weapon.Durability==Wear,"Rulo replay does not repair weapon");
            for(int s=0;s<4;s++)Check(r.MainM00ArmorIds[s]>0,"Rulo armor piece exists");
            // Seed the already accepted combat and Fool challenge, preserving new gifts.
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_RULO_COMPLETE;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_UPSTAIRS_ENABLED);
            Palomo(u);Check(CaelumMainM00PalomoFinal.AcceptMagicBox(u),"Palomo grants Box");EndTalk(u);
            r.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_FOOL_CAPTURED;
            // Exercise the same native copy/toss hooks as Inventory > Drop.
            let original=r.MainM00CraftedBag;let tossed=original.CreateTossable(1);
            Check(tossed!=null && r.MainM00CraftedBag==tossed,"bag drop preserves tracked identity");
            if(tossed!=null){Actor receiver=u;Check(tossed.CallTryPickup(receiver),"crafted bag can be retrieved");}
            original=r.MainM00CraftedCanteen;tossed=original.CreateTossable(1);
            Check(tossed!=null && r.MainM00CraftedCanteen==tossed,"canteen drop preserves tracked identity");
            if(tossed!=null){Actor receiver=u;Check(tossed.CallTryPickup(receiver),"crafted canteen can be retrieved");}
            Check(r.MainM00CraftedBag.Owner==u && r.MainM00CraftedCanteen.Owner==u,"retrieved crafted instances remain tracked");
            Bag=r.MainM00CraftedBag;Canteen=r.MainM00CraftedCanteen;Deck=u.FindInventory("CaelumTarotDeck");
            if(Canteen!=null)CaelumWaterContainer(Canteen).WaterLiters=1.25;
            ArrowCount=u.CountInv("CaelumArrowAmmo");
        }
        if(Stage==1 && Age==120)
        {
            let controller=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));let door=controller.ReturnDoor;
            Check(door!=null,"departure door exists");if(door==null){Stage=99;return;}
            u.SetOrigin(door.Pos+(0,-64,0),false);u.Vel=(0,0,0);u.player.ConversationNPC=door;door.bInConversation=true;
            Check(CaelumMainM00Return.Begin(u),"native departure begins");EndTalk(u);
        }
        if(Stage==1 && level.MapName=="MAP02")
        {
            Stage=2;EndTalk(u);
            Check(r.MainM00CraftedBag==Bag && r.MainM00CraftedCanteen==Canteen && u.FindInventory("CaelumTarotDeck")==Deck,"real hub travel retains crafted instances and deck");
            Check(CaelumWaterContainer(Canteen).WaterLiters==1.25 && CaelumWaterContainer(Canteen).InMagicBox,"canteen water and Box placement retained");
            let w=u.FindNativeEquipmentItemById(WeaponId);Check(w!=null && w.Durability==Wear && w.InMagicBox && !w.Equipped,"weapon identity/wear retained inside Box");
            Check(u.CountInv("CaelumArrowAmmo")==ArrowCount && CaelumCarbineAmmo(u.FindInventory("CaelumArrowAmmo")).InMagicBox,"matching ammunition retained inside Box");
            Check(r.HasTarotCard(CaelumConstants.TAROT_THE_FOOL) && CaelumSpecialInventoryItem(Deck).InMagicBox,"Fool and physical deck retained");
            // Withdraw every real chest, consume its stock only in the fixture to
            // avoid carry limits, then confirm repeat withdrawal cannot refill.
            int totals[CaelumConstants.MATERIAL_TYPE_COUNT];int chests=0;
            let boxes=ThinkerIterator.Create("CaelumMazeChest");CaelumMazeChest chest;
            while((chest=CaelumMazeChest(boxes.Next()))!=null)
            {
                chests++;
                for(int pass=0;pass<20;pass++)
                {
                    chest.CollectMaterials(u);int collected=0;
                    for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)
                    {int amount=u.CountRawCraftingMaterial(m,1);totals[m]+=amount;collected+=amount;if(amount>0)u.ConsumeCraftingMaterial(m,1,amount);}
                    u.OnNativeInventoryChanged();if(collected==0)break;
                }
                chest.CollectMaterials(u);Check(Materials(u)==0,"empty chest cannot replenish");
            }
            Check(chests==39,"all 39 actual MAP02 chests tested");
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)Check(totals[m]==r.MainM00MazeRepairUnits[m],"collected aggregate equals frozen repair budget");
            // Restore the collected budget, then use a real refuge and repair UI.
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)if(totals[m]>0)
            {let stock=u.CreateDetachedMaterialStack(m,1,totals[m]);stock.InMagicBox=true;stock.AttachToOwner(u);}
            u.OnNativeInventoryChanged();let benches=ThinkerIterator.Create("CaelumWorkbenchStation");CaelumCraftingStation bench;
            while((bench=CaelumCraftingStation(benches.Next()))!=null)
            {
                u.SetOrigin(bench.Pos+(0,48,0),false);bench.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());
                if(CaelumCraftingRules.NetworkHasStation(u.CraftingNetworkCapabilities,CaelumConstants.CRAFTING_STATION_ARMOR_WORKSHOP))break;
            }
            Check(bench!=null,"MAP02 armor workshop connected to refuge bench");
            if(bench!=null)
            {
                u.OpenCraftingNetwork(bench);u.CraftingEfficiencyIndex=2;
                let armor=u.FindNativeEquipmentItemById(r.MainM00ArmorIds[0]);armor.Durability=0;
                let browser=u.CraftingBrowser;browser.Mode=CaelumCraftingBrowser.REPAIR;browser.SelectedWeaponId=armor.ItemId;browser.Refresh(u);
                Check(browser.SelectedWeaponId==armor.ItemId && browser.SelectedIndex>=0,"light armor appears in native repair selector");
                browser.Confirm(u,browser.Mode,armor.ItemId,browser.Serial);
                Check(u.CraftingTaskActive,"full light armor repair starts from MAP02 supply");
                if(u.CraftingTaskActive){u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();}
                Check(armor.Durability==u.GetEquipmentTaskMaximumDurability(armor),"native armor repair restores the same item");
                // The author's correction uses five manufactured replacements.
                for(int replacement=0;replacement<5;replacement++)
                {
                    browser.Mode=CaelumCraftingBrowser.CRAFT;u.CraftingSelectionRecipe=CaelumConstants.CRAFTING_BOLAS_RECIPE;u.CraftingSelectionTier=1;u.CraftingSelectionSize=r.MainM00StarterSize;u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();u.BeginSelectedCraftingTask();
                    Check(u.CraftingTaskActive,"MAP02 materials start a replacement bolas craft");
                    Console.Printf("CA183 BOLAS_CRAFT action=%d known=%d infra=%d missing=%d weight=%.6f max=%.6f recipe=%d direct=%d",u.LastCraftingAction,u.CraftingSelectedRecipeKnown,u.CraftingSelectedInfrastructureAvailable,u.CraftingMissingStationType,u.DerivedStats.CarriedWeight,u.DerivedStats.CarryCapacity,u.CraftingSelectionRecipe,u.CraftingDirectPlanAvailable);
                    if(u.CraftingTaskActive){u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();}
                    Check(u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"native replacement bolas craft completes");
                }
                u.CloseCraftingStationSession();
            }
            Console.Printf("CA183 JOURNEY_DONE failures=%d slots=%d capacity=%d",Failures,u.CountNativeMagicBoxSlots(),u.DerivedStats.MagicBoxCapacity);
        }
    }
}
