// Escenas descartables por issue. F5-F9 sólo preparan condiciones de revisión.
class CA515LabPort : CaelumPortSiege replaces CaelumPortSiege { override void Tick(){} }
class CA515LabBoss : CaelumPortCommander { override void Tick(){} }
class CA515Author : EventHandler
{
    const SCENE=0;
    CaelumPortSiege Port;
    CaelumPortDefender First,Second;
    CaelumCityMerchant Vendor,LostVendor;
    CaelumCannon Gun;
    bool Seeded,Ready;
    int NextMachine;
    vector3 WalkStart;
    void ClockTo(double civil)
    {
        int day=int(Floor(civil/86400));int tic=int((civil-double(day)*86400)*CaelumWorldClock.TicsPerHour()/3600);
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let user=CaelumPlayer(players[p].mo);
            CaelumCalendarState.Get(user,true).SetAnchor(CaelumWorldClock.Get(user,true),day,tic,false);
        }
    }
    void Seed()
    {
        Seeded=true;
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let user=CaelumPlayer(players[p].mo);let r=user.GetPersistentCharacterState(false);
            r.DemoNarrativeDelivered=(1<<CaelumDemoNarrative.EVENT_COUNT)-1;r.DemoNarrativePending=0;
            r.FactionMember[0]=true;r.FactionReputation[0]=50;
            r.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=CaelumConstants.QUEST_STATE_COMPLETED;
            r.QuestState[CaelumConstants.QUEST_INVESTIGATE_SIEGE]=CaelumConstants.QUEST_STATE_ACTIVE;
            r.PortPrisonerAccountMask=SCENE==3?1:0;
            r.PortSiegeNarrativeStarted=false;
            user.MagicBoxOwned=true;r.MagicBoxOwned=true;
            CA515AuthorSetup.Prepare(user);
            for(int recipe=CaelumMachineData.FIRST_RECIPE;recipe<CaelumMachineData.FIRST_RECIPE+2;recipe++)
            {
                r.LearnCraftingRecipe(recipe);
                r.RecipeRereadings[CaelumRecipeLearning.Slot(recipe,1)]=CaelumRecipeLearning.MAX_READINGS;
                r.RecipePractice[CaelumRecipeLearning.Slot(recipe,1)]=CaelumRecipeLearning.PracticeLimit(recipe);
            }
            if(SCENE==2){user.CraftingEfficiencyIndex=2;CA515AuthorSetup.Materials(user);}
            user.RefreshSocialJournalSnapshot();user.PersistCharacterState();
        }
        ClockTo(CaelumCityWorld.SiegeCivilSeconds()-3600);
        Port=CaelumPortSiege(Actor.Spawn('CA515LabPort',(0,0,0)));
        Port.args[0]=CaelumCityData.LAYOUT_REVISION;Port.SetupRevision=CaelumCityData.LAYOUT_REVISION;
        Port.SiegeStarted=SCENE!=3;
        for(int lane=0;lane<6;lane++)
        {
            let point=CaelumSiegeRouteNode(Actor.Spawn('CaelumSiegeRouteNode',(CaelumPortData.GateX(lane),CaelumPortData.ExitY(),0)));
            point.IsExit=true;Port.Exits.Push(point);
        }
        let boss=CA515LabBoss(Actor.Spawn('CA515LabBoss',Port.Exits[0].Pos));
        Port.Boss=Port.RegisterAttacker(boss);Port.Boss.ExitNode=Port.Exits[0];
        for(int i=0;i<12;i++)
        {
            let cannon=CaelumCannon(Actor.Spawn('CaelumCannon',(-4000+i*256,2000,0)));
            cannon.InitializeCannon(false);cannon.UnlimitedAmmunition=true;Port.RegisterMachine(cannon);
            if(i==0)Gun=cannon;
        }
        First=CaelumPortDefender(Actor.Spawn('CaelumPortDefender',(-256,256,0)));
        Second=CaelumPortDefender(Actor.Spawn('CaelumPortDefender',(-128,256,0)));
        First.Port=Second.Port=Port;First.Station=First.Pos;Second.Station=Second.Pos;
        Port.Defenders.Push(First);Port.Defenders.Push(Second);Port.RosterSealed=SCENE!=3;
        Port.Reinforcements=new('CaelumSiegeReinforcements');
        Port.Reinforcements.Revision=CaelumReinforcementData.REVISION;
        Port.Reinforcements.Remaining=CaelumReinforcementData.TOTAL;Port.Reinforcements.Enabled=true;
        Vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(-384,0,0)));
        Vendor.ShopIdentity=0;Vendor.Category=0;Vendor.WalletCopper=CaelumCityData.MERCHANT_COPPER;
        LostVendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(-384,128,0)));
        LostVendor.ShopIdentity=1;LostVendor.Category=1;
        Actor.Spawn('CaelumWorkbenchStation',(-4000,1600,0));
        Actor.Spawn('CaelumForgeStation',(-4128,1600,0));Actor.Spawn('CaelumAnvilStation',(-3872,1600,0));
    }
    void PositionUsers()
    {
        Port.EnsureDirector();Port.Military=new('CaelumMilitaryCommand');Port.Military.Initialize(Port);
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let user=CaelumPlayer(players[p].mo);
            vector3 start=SCENE==2?Gun.Pos+(0,64,0):SCENE==4?(-448,0,0):First.Pos-(64,0,0);
            user.SetOrigin(start+(0,p*96,0),false);user.Angle=SCENE==2?270:0;user.Pitch=0;
            CaelumPoiKnowledge.Record(user,"ca515_review_point",CaelumPoiData.ROOM,"CA_MILITARY_HERE",(512,256,0));
            CA515AuthorSetup.Report(user);
        }
        Ready=true;Console.Printf("CA515 AUTHOR READY issue=%d scene=%d",SCENE==0?447:SCENE==1?448:SCENE==2?449:SCENE==3?450:451,SCENE);
    }
    void Fall(CaelumPortDefender body)
    {
        if(body!=null && body.health>0){body.health=0;body.Die(null,null,0,'None');CaelumBattleDirector.DefenderChanged(body);}
    }
    override void WorldTick()
    {
        if(level.MapName!="MAP03")return;
        if(!Seeded && level.time>=90 && CaelumWorldClockTicker.Ready(CaelumPlayer(players[0].mo)))Seed();
        if(Seeded && !Ready && level.time>=110)PositionUsers();
        if(Ready){Port.ObserveBattle();if(Port.Military!=null)Port.Military.Tick();}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);if(user==null)return;
        if(e.Name=="ca515_return"){Level.ChangeLevel('MAP03',0,CHANGELEVEL_NOINTERMISSION);return;}
        if(!Ready)return;let record=user.GetPersistentCharacterState(false);
        if(e.Name=="ca515_setup"){CA515AuthorSetup.Report(user);return;}
        if(e.Name=="ca515_materials" && SCENE==2){CA515AuthorSetup.Materials(user);CA515AuthorSetup.Report(user);return;}
        if(e.Name=="ca515_refill_probe" && SCENE==2)
        {
            let wood=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_WOOD,1);
            int before=wood.Amount;wood.Amount-=1;
            CA515AuthorSetup.Materials(user);CA515AuthorSetup.Materials(user);
            Console.Printf("CA515 AUTHOR REFILL %s",wood.Amount==before?"PASS":"FAIL");return;
        }
        if(e.Name=="ca515_walk_start"){WalkStart=user.Pos;return;}
        if(e.Name=="ca515_walk_end")
        {
            double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA515 AUTHOR WALK %s distance=%.4f",distance>1?"PASS":"FAIL",distance);return;
        }
        if(e.Name=="ca515_probe")
        {
            bool okay=true;
            if(SCENE==0)okay=Port.Director.Defeated && !Port.Victory && Port.Reinforcements.Remaining==6600;
            if(SCENE==1)okay=CaelumMilitaryCommand.Access(user)=="" && (First==null || First.health<=0) && Second.health>0;
            if(SCENE==2)okay=Gun.Structure.health<Gun.Structure.StructuralMaximum && user.MagicBoxOwned;
            if(SCENE==3)
            {
                String result=CaelumBattleTactics.Prepare(user);
                okay=result=="CA_TACTICS_PREPARED" && Port.Reinforcements.Withheld==100;
                Console.Printf("CA515 PREPARATION %s",result);
            }
            if(SCENE==4)
            {
                let outcome=CaelumBattleConsequences.View(user);
                okay=outcome!=null && outcome.Won && outcome.Defeated && outcome.DeadShop[1] && !CaelumBattleConsequences.Closed(user) && record.FactionReputation[0]==150;
            }
            Console.Printf("CA515 AUTHOR CHECK %s scene=%d",okay?"PASS":"FAIL",SCENE);return;
        }
        if(e.Name=="ca515_hub"){Level.ChangeLevel('T451',0,CHANGELEVEL_NOINTERMISSION);return;}
        if(SCENE==0)
        {
            if(e.Name=="ca515_a"){if(First!=null && First.health>0)Fall(First);else Fall(Second);}
            if(e.Name=="ca515_b")Port.ConfirmBossRetreat(Port.Boss);
            if(e.Name=="ca515_c" && NextMachine<Port.Machines.Size())Port.Machines[NextMachine++].DestroyByTarot();
            if(e.Name=="ca515_d")Port.Reinforcements.Opportunity(Port);
        }
        if(SCENE==1)
        {
            if(e.Name=="ca515_a")record.FactionMember[0]=!record.FactionMember[0];
            if(e.Name=="ca515_b")record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]=record.QuestState[CaelumConstants.QUEST_GUARD_CAPTAIN]==CaelumConstants.QUEST_STATE_COMPLETED?CaelumConstants.QUEST_STATE_UNDISCOVERED:CaelumConstants.QUEST_STATE_COMPLETED;
            if(e.Name=="ca515_c")record.FactionReputation[0]=record.FactionReputation[0]>=50?49:50;
            if(e.Name=="ca515_d")Fall(First);
        }
        if(SCENE==2)
        {
            if(e.Name=="ca515_a"){Gun.Structure.health=Max(1,Gun.Structure.health-Gun.Structure.StructuralMaximum/10);Gun.health=Gun.Structure.health;}
            if(e.Name=="ca515_b")user.SetOrigin((-4000,1536,0),false);
            if(e.Name=="ca515_c" && user.CraftingTaskActive){user.CraftingTaskRemainingSeconds=0;CaelumMachineWork.Advance(user);}
            if(e.Name=="ca515_d"){user.SetOrigin(Gun.Pos+(0,64,0),false);user.Angle=270;}
        }
        if(SCENE==3)
        {
            if(e.Name=="ca515_a")CaelumFactionCondition.OpenDialogue(user,First,CaelumPortStoryData.GUARD_REPEAT);
            if(e.Name=="ca515_b"){Port.SiegeStarted=true;Port.RosterSealed=true;}
            if(e.Name=="ca515_c")CaelumMachineOwnership.Capture(Gun,user,0);
            if(e.Name=="ca515_d"){user.SetOrigin(First.Pos-(64,0,0),false);user.Angle=0;}
        }
        if(SCENE==4)
        {
            if(e.Name=="ca515_a"){Fall(First);Fall(Second);}
            if(e.Name=="ca515_b")
            {
                Port.ConfirmBossRetreat(Port.Boss);
                for(int i=0;i<Port.Machines.Size();i++)Port.Machines[i].DestroyByTarot();
            }
            if(e.Name=="ca515_c")
            {
                let outcome=CaelumBattleConsequences.View(user);
                if(outcome!=null && outcome.RecoveryCivil>=0)ClockTo(outcome.RecoveryCivil+1);
            }
            if(e.Name=="ca515_d"){Vendor=CaelumCityMerchant.Find(0);CaelumCityTradeSession.Open(user,Vendor);}
            if(e.Name=="ca515_e" && LostVendor!=null && LostVendor.health>0){LostVendor.health=0;LostVendor.Die(null,null,0,'None');}
        }
        Port.ObserveBattle();user.RefreshSocialJournalSnapshot();user.PersistCharacterState();
        Console.Printf("CA515 REVIEW scene=%d member=%d reputation=%d alive=%d reserve=%d won=%d closed=%d",SCENE,record.FactionMember[0],record.FactionReputation[0],int(First!=null && First.health>0)+int(Second!=null && Second.health>0),Port.Reinforcements.Remaining,Port.Victory,CaelumBattleConsequences.Closed(user));
    }
}
