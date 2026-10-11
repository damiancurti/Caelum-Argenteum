// Development-only native MAP01 fixture. Conversation actions and transactions
// run in play scope; elapsed crafting time and travel are accelerated explicitly.
class CA177Route : EventHandler
{
    int Stage, Age, StaffId, PickaxeId, BolasId, SwordId, BeforeHealth, BullStartTime;
    double BeforeAir, BeforeAnima;
    bool SeenReleased, Reloaded;
    static void Check(bool ok, String label) { Console.Printf("CA177 %s %s",ok?"PASS":"FAIL",label); }
    static Actor Find(String cls) { let it=ThinkerIterator.Create(cls);return Actor(it.Next()); }
    static void EndTalk(CaelumPlayer u)
    {if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;u.player.ConversationNPC=null;}
    static Actor Talk(CaelumPlayer u,String cls)
    {
        EndTalk(u);let npc=Find(cls);if(npc==null)return null;
        u.SetOrigin(npc.Pos+(0,-64,0),false);u.Vel=(0,0,0);u.Angle=90;u.Pitch=0;
        u.player.ConversationNPC=npc;npc.bInConversation=true;return npc;
    }
    static CaelumPalomo Palomo(CaelumPlayer u)
    {
        let p=CaelumPalomo(Find("CaelumPalomo"));
        p.SetOrigin((500,120,264),false);p.DepartureStarted=true;p.DepartureDone=true;p.NarrativeRevealRequired=true;
        Talk(u,"CaelumPalomo");return p;
    }
    static int Count(CaelumPlayer u,int type=-1)
    {
        int n=0;for(Inventory c=u.Inv;c!=null;c=c.Inv)
        {let item=CaelumEquipmentItem(c);if(item!=null && (type<0 || (item.EquipmentKind==0 && item.ItemType==type)))n++;}return n;
    }
    static CaelumCraftingStation Station(CaelumPlayer u)
    {
        EndTalk(u);let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation s;
        while((s=CaelumCraftingStation(it.Next()))!=null)
        {
            if(s.CraftingRoomGroup!=5 || s.GetCraftingStationType()!=CaelumConstants.CRAFTING_STATION_WORKBENCH)continue;
            u.SetOrigin(s.Pos+(0,48,0),false);u.Vel=(0,0,0);
            s.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());u.OpenCraftingNetwork(s);return s;
        }return null;
    }
    static void Craft(CaelumPlayer u,int recipe,CaelumMainM00StarterMaterials needs)
    {
        Check(Station(u)!=null,"MAP01 workshop network");
        for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)
        {
            if(needs.Units[m]<=0)continue;
            let stack=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,m,1);
            if(stack==null){stack=u.CreateDetachedMaterialStack(m,1,needs.Units[m]);stack.InMagicBox=false;stack.AttachToOwner(u);}
            else stack.Amount+=needs.Units[m];
        }
        u.OnNativeInventoryChanged();u.CraftingSelectionRecipe=recipe;u.CraftingSelectionTier=1;
        u.CraftingSelectionSize=u.GetPersistentCharacterState(true).MainM00StarterSize;
        u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
        u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"native crafting task starts");
        if(!u.CraftingTaskActive){Console.Printf("CA177 CRAFT diagnostic action=%d known=%d infra=%d",u.LastCraftingAction,u.CraftingSelectedRecipeKnown,u.CraftingSelectedInfrastructureAvailable);return;}
        int count=Count(u);u.CancelCraftingTask();Check(!u.CraftingTaskActive && Count(u)==count,"cancel produces no equipment");
        u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"cancelled craft reopens");
        u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(u.LastCraftingAction==CaelumConstants.CRAFTING_ACTION_CREATED,"native payment and output transaction");
        u.CloseCraftingStationSession();
    }
    // Exercise real actor movement and physical walls after the normal checkpoint.
    // Separate lanes avoid contact with the frozen observers used by this fixture.
    Vector3 EdgeStart;
    bool EdgeWarped;
    double MaximumJumpZ;
    void CheckArena(CaelumPlayer u)
    {
        int lane=(Age-1)/22, tick=(Age-1)%22;
        if(lane>=5)return;
        let bull=CaelumMainM00RuloTrial.GetBull();
        if(tick==0)
        {
            bull.bNoInteraction=true;
            let it=ThinkerIterator.Create("CaelumAnchoredResident");CaelumAnchoredResident a;
            while((a=CaelumAnchoredResident(it.Next()))!=null)if(a.RuloPartyBull==bull)a.bNoInteraction=true;
            EdgeStart=lane==0?(-2420,180,0):lane==1?(-2250,280,0):lane==2?(-2250,-280,0):lane==3?(-1900,180,0):(-2250,180,0);
            u.SetOrigin(EdgeStart,false);u.Vel=(0,0,lane==4?u.JumpZ*2:0);EdgeWarped=false;MaximumJumpZ=0;
        }
        else if((u.Pos.XY-EdgeStart.XY).Length()>140 || Abs(u.Pos.Y)<10)EdgeWarped=true;
        MaximumJumpZ=Max(MaximumJumpZ,u.Pos.Z);
        if(lane<4)u.Vel=lane==0?(-5,0,0):lane==1?(0,5,0):lane==2?(0,-5,0):(5,0,0);
        if(tick==20)
        {
            Console.Printf("CA177 EDGE lane=%d pos=(%.3f,%.3f,%.3f) radius=%.3f",lane,u.Pos.X,u.Pos.Y,u.Pos.Z,u.Radius);
            Check(!EdgeWarped,String.Format("arena lane %d retains position instead of recentering",lane));
            Check(bull.IsTrialOpponent(u),String.Format("arena lane %d remains an eligible trial opponent",lane));
            if(lane<4)Check(u.TestMobjLocation(),String.Format("arena wall %d uses valid physical collision",lane));
            else Check(MaximumJumpZ>64,"airborne position beyond old vertical bound survives");
            u.Vel=(0,0,0);
        }
    }
    void VerifyCheckpoint()
    {
        Reloaded=true;
        let u=CaelumPlayer(players[0].mo);let b=CaelumMainM00RuloTrial.GetBull();
        if(b==null)return;
        if(b.TrialGraceTicks<=0)
        {
            Check(b.TrialFighter==u && u.FindNativeEquipmentItemById(StaffId)!=null && u.FindNativeEquipmentItemById(PickaxeId)!=null && u.FindNativeEquipmentItemById(BolasId)!=null && u.FindNativeEquipmentItemById(SwordId)!=null,"older active-fight save retains fighter and exact equipment identities");
            return;
        }
        Console.Printf("CA177 CHECKPOINT time=%d released=%d grace=%d health=%d air=%.6f anima=%.6f party=%d fighter=%d",level.time,b.TrialReleased,b.TrialGraceTicks,u.health,u.CurrentAir,u.CurrentAnima,b.RuloPartyPrepared,b.TrialFighter==u);
        Check(!b.TrialReleased && b.TrialGraceTicks>0 && b.RuloPartyPrepared && b.TrialFighter==u,"actual native autosave reload is pre-hostility with party");
        Check(u.health==BeforeHealth && u.CurrentAir< u.DerivedStats.MaximumAir && u.CurrentAnima<u.DerivedStats.MaximumAnima,"checkpoint retains wounded resources without refill");
        Check(u.FindNativeEquipmentItemById(StaffId)!=null && u.FindNativeEquipmentItemById(PickaxeId)!=null && u.FindNativeEquipmentItemById(BolasId)!=null && u.FindNativeEquipmentItemById(SwordId)!=null,"checkpoint retains exact gift and crafted IDs");
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        let r=u.GetPersistentCharacterState(true);
        int wanted=CVar.FindCVar('ca177_stage').GetInt();
        if(wanted!=Stage){Stage=wanted;Age=0;Console.Printf("CA177 STAGE %d time=%d",Stage,level.time);}Age++;
        if(Stage==1 && Age==1)
        {
            r.EnsureQuestStateInitialized();r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
            r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
            u.bInvulnerable=true;Palomo(u);
            Check(!u.MagicBoxOwned && u.FindInventory("CaelumTarotDeck")==null,"fresh Palomo has no deck or Box");
            Check(CaelumMainM00Loadout.Choose(u,0,4),"choose only sword with Palomo");
            Check(CaelumMainM00Loadout.IsComplete(r) && !r.MainM00ArmorChosen && r.MainM00SealChoice==0 && r.MainM00ShieldChoice==0 && r.MainM00AmuletChoice==0,"weapon-only plan can continue");
            EndTalk(u);Talk(u,"CaelumArgento");CaelumMainM00SocialDialogue.Apply(u,'StartArgento');
            Check(r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED) && u.FindInventory("CaelumTarotDeck")!=null && !u.MagicBoxOwned,"Argento grants deck before Box");
            let deck=u.FindInventory("CaelumTarotDeck");CaelumTarotDeckRules.Grant(u);Check(deck==u.FindInventory("CaelumTarotDeck"),"deck retry retains exact instance");
            Check(CaelumTarotService.CountTarotCards(r)==0,"78 physical cards unlock no essence");
            Check(CaelumTrucazoMatch.Open(u,CaelumArgento(u.player.ConversationNPC)),"Trucazo opens before Box");
            let match=CaelumTrucazoMatch.Get(u,false);match.Start();Check(match.HandNumber>0,"Trucazo deals native practice hand");match.Visible=false;
            Check(!CaelumTarotDeckRules.InOwnedBox(u),"capture remains unavailable without owned Box");
            EndTalk(u);
        }
        if(Stage==2 && Age==1)
        {
            for(int i=0;i<3;i++)r.RecordMainM00ResidentMet(i);
            Talk(u,"CaelumRulo");CaelumMainM00SocialDialogue.Apply(u,'ReadRulo');
            Talk(u,"CaelumCaella");CaelumMainM00SocialDialogue.Apply(u,'PersuadeCaella');
            Talk(u,"CaelumArgento");CaelumMainM00SocialDialogue.Apply(u,'RuloAdvice');CaelumMainM00SocialDialogue.Apply(u,'RonnieAdvice');CaelumMainM00SocialDialogue.Apply(u,'CaellaAdvice');
            Talk(u,"CaelumRulo");CaelumMainM00SocialDialogue.Apply(u,'RespectRulo');
            Talk(u,"CaelumRonnie");CaelumMainM00SocialDialogue.Apply(u,'RonnieAdvicePlan');
            Talk(u,"CaelumCaella");CaelumMainM00SocialDialogue.Apply(u,'CaellaSafety');
            Talk(u,"CaelumArgento");CaelumMainM00SocialDialogue.Apply(u,'FinishArgento');
            Check(r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE),"native social advice route completes Argento");
            Talk(u,"CaelumCaella");Check(CaelumMainM00MagicTrial.Begin(u),"Caella starts after Argento");
            StaffId=r.MainM00UtilityStaffId;
            Check(u.ActiveWeaponItemId==StaffId && u.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_UTILITY_STAFF,"new staff autoequips exact instance");let staff=u.FindNativeEquipmentItemById(StaffId);
            Check(staff!=null && staff.ItemType==21 && !staff.IsLimboTemporary(),"Caella gives permanent utility staff");
            Check(u.FindInventory("CA_LimboMagicSeal")==null && u.GetEquippedSeal()==null,"no additional Seal");
            int count=Count(u);CaelumMainM00MagicTrial.PrepareEquipment(u);Check(Count(u)==count && r.MainM00UtilityStaffId==StaffId,"repeated Caella preparation grants once");
            EndTalk(u);let dummy=CaelumMainM00RuloTrial.EnsurePracticeTarget();
            u.SetOrigin(dummy.Pos+(-96,0,0),false);u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            u.SelectNativeWeaponConfiguration(21,0,1);
        }
        if(Stage==3 && Age==1)
            Check(r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_PRIMARY_USED),"held primary fire contacts native dummy");
        if(Stage==4 && Age==30)
        {
            Check(r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_SECONDARY_USED),"held secondary ice contacts native dummy");
            Check(r.IsMainM00MagicPracticeComplete() && !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_CHANNEL_USED),"four mandatory actions complete without Channel");
            let staff=u.FindNativeEquipmentItemById(StaffId);if(staff==null){Check(false,"missing staff prevents route");return;}Check(staff.UtilityStaffContactTics==0 && staff.Durability==u.WeaponModel.GetMaximumDurabilityFor(21,1,staff.EquipmentSize),"training dummy causes no staff wear");
            for(int i=0;i<4;i++)Check(CaelumMainM00MagicTrial.UseRune(u,r.GetMainM00RuneElement(i)),"rune with utility staff and no Seal");
            Talk(u,"CaelumCaella");Check(CaelumMainM00MagicTrial.Complete(u),"Caella completes with optional Channel skipped");
            Check(u.FindNativeEquipmentItemById(StaffId)==staff,"Caella keeps exact staff owned");
            Talk(u,"CaelumRonnie");Check(CaelumMainM00RonnieTrial.Start(u),"Ronnie starts with only chosen weapon");
            PickaxeId=r.MainM00PickaxeId;
            Check(u.ActiveWeaponItemId==PickaxeId && u.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_PICKAXE,"new Pickaxe autoequips exact instance");
            Check(PickaxeId>0 && r.KnowsCraftingRecipe(CaelumConstants.CRAFTING_PICKAXE_RECIPE) && r.MainM00StarterWeaponId==0,"Pickaxe grant unlocks recipe but does not count as crafted weapon");
            let needs=new("CaelumMainM00StarterMaterials");needs.Build(r.MainM00StarterOption,r.MainM00StarterSize,2);
            Craft(u,CaelumMainM00StarterRules.GetRecipe(r.MainM00StarterOption),needs);SwordId=r.MainM00StarterWeaponId;
            Check(u.ActiveWeaponItemId==SwordId && u.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_SWORD,"crafted starter autoequips exact instance");
            Talk(u,"CaelumRonnie");Check(CaelumMainM00RonnieTrial.Finish(u),"only chosen weapon craft finishes Ronnie");
            Talk(u,"CaelumRulo");Check(CaelumMainM00RuloTrial.Begin(u),"Rulo starts after mandatory branches");
            BolasId=r.MainM00BolasId;
            Check(u.ActiveWeaponItemId==BolasId && u.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_BOLAS,"Rulo preparation leaves new bolas active");Check(BolasId>0 && u.FindNativeEquipmentItemById(StaffId)!=null && u.FindNativeEquipmentItemById(PickaxeId)!=null,"Rulo bolas preserves earlier gifts");
            Check(!r.CanReceiveMainM00MagicBox() && !u.MagicBoxOwned,"Box unavailable before bull");
            EndTalk(u);let dummy=CaelumMainM00RuloTrial.EnsurePracticeTarget();u.SetOrigin(dummy.Pos+(-48,0,0),false);u.Vel=(0,0,0);u.Angle=0;u.Pitch=0;
            let sword=u.FindNativeEquipmentItemById(SwordId);sword.Equipped=true;
            u.SyncActiveModelsToNativeInventory();u.ActivateExactEquippedWeapon(sword);
            int count=Count(u);CaelumMainM00Gifts.EnsureTool(u,false);CaelumMainM00Gifts.EnsureTool(u,true);CaelumMainM00RonnieTrial.EnsurePickaxe(u);
            Check(u.ActiveWeaponItemId==SwordId && Count(u)==count,"repeated gift recognition preserves manual weapon choice and item count");
        }
        if(Stage==5 && Age==1)
        {
            Check(r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMBAT_PRIMARY_USED),"native sword primary dummy practice");
            Check(r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMBAT_SECONDARY_USED),"native sword secondary dummy practice");
            // Remaining established #62 exercises are seeded only for checkpoint coverage.
            for(int i=0;i<6;i++)CaelumMainM00RuloTrial.RecordPractice(u,CaelumMainM00RuloTrial.PracticeFlag(i));
            Talk(u,"CaelumArgento");Check(CaelumMainM00SocialDialogue.GiveSilverKey(u),"Argento releases same silver key after practice");EndTalk(u);
            u.health=Max(2,u.health/2);u.player.health=u.health;u.CurrentAir=u.DerivedStats.MaximumAir/2;u.CurrentAnima=u.DerivedStats.MaximumAnima/2;
            BeforeHealth=u.health;BeforeAir=u.CurrentAir;BeforeAnima=u.CurrentAnima;
            let sword=u.FindNativeEquipmentItemById(SwordId);sword.Durability-=17;u.WeaponModel.Durability=sword.Durability;
            u.SetOrigin((-1900,0,0),false);u.Vel=(0,0,0);u.Angle=180;u.Pitch=0;
        }
        if(Stage==5)
        {
            let bull=CaelumMainM00RuloTrial.GetBull();
            if(bull!=null && bull.TrialFighter==u && BullStartTime==0)
            {
                BullStartTime=level.time;
                Check(!bull.TrialReleased && bull.TrialGraceTicks>0,"fight setup precedes hostility");
                Check(u.health==BeforeHealth && u.CurrentAir<u.DerivedStats.MaximumAir && u.CurrentAnima<u.DerivedStats.MaximumAnima,"fight setup does not heal or refill");
                int party=0;let it=ThinkerIterator.Create("CaelumAnchoredResident");CaelumAnchoredResident a;
                while((a=CaelumAnchoredResident(it.Next()))!=null)if(a.StoryAnchored && a.RuloPartyBull==bull && a.RuloPartyMode==1)party++;
                Check(party==4,"all four established helpers gathered before save");
                Console.Printf("CA177 SAVE_REQUEST time=%d health=%d",level.time,u.health);
            }
            if(bull!=null && bull.TrialReleased && !SeenReleased)
            {SeenReleased=true;Console.Printf("CA177 RELEASE time=%d grace=%d",level.time,bull.TrialGraceTicks);}
            if(Age==180)
            {
                int fighting=0;let it=ThinkerIterator.Create("CaelumAnchoredResident");CaelumAnchoredResident a;
                while((a=CaelumAnchoredResident(it.Next()))!=null)if(a.StoryAnchored && a.IsRuloPartyFighting())fighting++;
                Check(SeenReleased && fighting>0,"resident AI fights live after checkpoint grace");
            }
        }
        if(Stage==8) CheckArena(u);
        if(Stage==6 && Age==1)
        {
            u.bInvulnerable=false;u.DamageMobj(null,null,10000000,'None',DMG_FORCED);
        }
        if(Stage==6 && Age==50)
        {
            Check(u.health<=0 && u.player.playerstate==PST_DEAD && !r.MainM00BullResetPending,"death stays dead without scripted retry");
            Console.Printf("CA177 DEATH_DONE time=%d",level.time);
        }
        if(Stage==7 && Age==1)
        {
            Check(Reloaded,"manual native checkpoint reload observed");u.bInvulnerable=true;
            let bull=CaelumMainM00RuloTrial.GetBull();bull.bNoInteraction=false;bull.bShootable=true;bull.DamageMobj(u,u,10000000,'None',DMG_FORCED);
        }
        if(Stage==7 && Age==20)
        {
            Talk(u,"CaelumRulo");Check(CaelumMainM00RuloTrial.Complete(u),"bull victory finishes Rulo");
            Check(r.CanReceiveMainM00MagicBox(),"weapon-only route reaches final Box");Palomo(u);
            Check(CaelumMainM00PalomoFinal.AcceptMagicBox(u),"Palomo grants Box after mandatory progression");
            Check(u.FindInventory("CaelumSleepingBag")!=null,"Palomo exit gift includes the sleeping bag");
            let box=CaelumMagicBox.EnsureOwned(u);let deck=u.FindInventory("CaelumTarotDeck");int count=Count(u);
            Check(CaelumMainM00PalomoFinal.AcceptMagicBox(u) && box==CaelumMagicBox.EnsureOwned(u) && deck==u.FindInventory("CaelumTarotDeck") && count==Count(u),"repeated finale duplicates no Box deck or tool");
            Check(!CaelumTarotDeckRules.InOwnedBox(u),"personal deck still cannot capture after Box grant");
            CaelumTarotDeck(deck).InMagicBox=true;Check(CaelumTarotDeckRules.InOwnedBox(u),"deck stored in owned Box enables capture prerequisite");
            EndTalk(u);
            let bag=u.FindInventory("CaelumSleepingBag");
            // Seed the unrelated Fool prerequisites, then use the real departure transaction.
            r.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_THE_FOOL_CAPTURED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_CONFIRMED);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_EXIT_CONFIRMED;
            let controller=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
            controller.PresentReturnDoor(true);let door=controller.ReturnDoor;
            u.SetOrigin(door.Pos+(0,-80,0),false);u.Vel=(0,0,0);
            Check(CaelumMainM00Return.Commit(u),"native departure transaction commits");
            Check(bag!=null && u.FindInventory("CaelumSleepingBag")==bag,"departure preserves the exact Palomo sleeping bag");
            Console.Printf("CA177 ROUTE_DONE");
        }
    }
}

class CA177RouteObserver : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let route=CA177Route(EventHandler.Find("CA177Route"));
        let u=CaelumPlayer(players[0].mo);
        if(route!=null && u!=null && !u.GetPersistentCharacterState(true).HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED))route.VerifyCheckpoint();
    }
}
