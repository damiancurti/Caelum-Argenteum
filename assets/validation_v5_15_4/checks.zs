class CA451Port : CaelumPortSiege replaces CaelumPortSiege { override void Tick(){} }
class CA451Defender : CaelumPortDefender { override void Tick(){} }
class CA451Commander : CaelumPortCommander { override void Tick(){} }
class CA451Checks : EventHandler
{
    CA451Port Port;
    CA451Defender First,Second;
    CaelumCityMerchant Vendor,LostVendor;
    CaelumTransportTicket Ticket;
    int Failures,Checks,Wallet;
    int Reputation[MAXPLAYERS];
    double LostAt,WonAt,Reopens;
    vector3 WalkStart;
    void Check(bool passed,String label)
    {Checks++;if(!passed)Failures++;Console.Printf("CA451 %s %s",passed?"PASS":"FAIL",label);}
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
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let member=CaelumPlayer(players[p].mo);
            let record=member.GetPersistentCharacterState(false);
            record.PortSiegeNarrativeStarted=true;
            record.DemoNarrativeDelivered|=1<<CaelumDemoNarrative.PORT_START;
            record.DemoNarrativePending&=~(1<<CaelumDemoNarrative.PORT_START);
            member.PersistCharacterState();
        }
        Port=CA451Port(CaelumPortSiege.Get());
        if(Port==null)Port=CA451Port(Actor.Spawn('CA451Port',(0,256,0)));
        Port.args[0]=CaelumCityData.LAYOUT_REVISION;Port.SetupRevision=CaelumCityData.LAYOUT_REVISION;Port.SiegeStarted=true;
        for(int i=0;i<6;i++)
        {
            let exitNode=CaelumSiegeRouteNode(Actor.Spawn('CaelumSiegeRouteNode',(CaelumPortData.GateX(i),-22528,0)));
            exitNode.IsExit=true;Port.Exits.Push(exitNode);
        }
        let commander=CA451Commander(Actor.Spawn('CA451Commander',Port.Exits[0].Pos));
        Port.Boss=Port.RegisterAttacker(commander);Port.Boss.ExitNode=Port.Exits[0];
        for(int i=0;i<12;i++)
        {
            let gun=CaelumCannon(Actor.Spawn('CaelumCannon',(-4000+i*256,2000,0)));
            gun.InitializeCannon(false);Port.RegisterMachine(gun);
        }
        First=CA451Defender(Actor.Spawn('CA451Defender',(-256,256,0)));
        Second=CA451Defender(Actor.Spawn('CA451Defender',(256,256,0)));
        First.Port=Second.Port=Port;Port.Defenders.Push(First);Port.Defenders.Push(Second);Port.RosterSealed=true;
        Port.Reinforcements=new('CaelumSiegeReinforcements');Port.Reinforcements.Revision=CaelumReinforcementData.REVISION;
        Port.Reinforcements.Enabled=true;Port.Reinforcements.Successful=600;Port.Reinforcements.Remaining=5900;
        Port.Reinforcements.Withheld=100;Port.Reinforcements.TacticsRevision=1;
        let user=CaelumPlayer(players[0].mo);user.MagicBoxOwned=true;
        Vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',user.Pos+(64,0,0)));Vendor.ShopIdentity=0;Vendor.Category=0;
        LostVendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',user.Pos+(64,128,0)));LostVendor.ShopIdentity=1;LostVendor.Category=1;
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])Reputation[p]=CaelumPlayer(players[p].mo).GetPersistentCharacterState(false).FactionReputation[0];
        Port.EnsureDirector();Console.Printf("CA451 SEEDED");
    }
    void Initial()
    {
        Port.EnsureDirector();
        let user=CaelumPlayer(players[0].mo);let outcome=CaelumBattleConsequences.View(user);
        let record=user.GetPersistentCharacterState(false);
        // Terminar la conversación de inicio de la escena y conservar la Caja del perfil de prueba.
        if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
        user.player.ConversationNPC=null;user.player.ConversationPC=null;
        user.MagicBoxOwned=true;record.MagicBoxOwned=true;user.PersistCharacterState();
        Console.Printf("CA451 DIAG ready=%d mutable=%d health=%d complete=%d wizard=%d committed=%d departed=%d pending=%d cheats=%d port=%d director=%d clock=%d",CaelumWorldClockTicker.Ready(user),CaelumPlayerAuthority.CanMutate(user),user.health,user.CharacterCreationComplete,user.CreationWizardOpen,record!=null && record.ProfileCommitted,user.ProfileDeparted,user.SessionIdentityPending,user.player.cheats,CaelumPortSiege.Get()==Port,Port.Director!=null,CaelumWorldClock.Get(user)!=null);
        Check(outcome!=null && outcome.Revision==1 && outcome.Observed && !outcome.Defeated,"fresh campaign consequences initialize before outcome");
        if(outcome==null){Console.Printf("CA451 RESULT FAIL missing campaign consequences");return;}
        Console.Printf("CA451 ACCESS box=%d vendor=%d distance=%.2f state=%d live=%d busy=%d/%d/%d/%d/%d/%d pending=%d leave=%d coast=%d sewers=%d",user.MagicBoxOwned,Vendor!=null?Vendor.health:-1,Vendor!=null?user.Distance3D(Vendor):-1,user.player.playerstate,PST_LIVE,user.HasActiveConversation(),user.PalomoMerchantMenuOpen,user.CraftingMenuOpen,user.CraftingTaskActive,user.EquipmentMenuOpen,user.CombatChannelModeActive,record.WorldPendingConnection,CaelumSewerMaze.CanLeave(user),LevelInfo.MapExists("TCOAST"),LevelInfo.MapExists("MAP02"));
        Check(CaelumTravelService.CanDepart(user,10,true),"transport departure is valid before occupation");
        CaelumCityTradeSession.Open(user,Vendor);
        Check(user.IsActivePalomoMerchantSessionValid(),"real civilian shop session opens before occupation");
        Vendor.ChangeTid(45101);Vendor.WalletCopper=12345;
        First.health=0;First.Die(null,null,0,'None');CaelumBattleDirector.DefenderChanged(First);Port.ObserveBattle();
        Check(!CaelumBattleConsequences.Closed(user),"one surviving defender prevents occupation");
        Second.health=0;Second.Die(null,null,0,'None');CaelumBattleDirector.DefenderChanged(Second);Port.ObserveBattle();
        LostAt=outcome.DefeatCivil;
        Check(outcome.Defeated && !outcome.Won && CaelumBattleConsequences.Closed(user),"actual last defender death occupies Barracas once");
        Check(!user.IsActivePalomoMerchantSessionValid(),"an already open merchant session cannot evade closure");
        Wallet=Vendor.WalletCopper;user.ExecutePalomoMerchantTransaction();
        Check(Vendor.WalletCopper==Wallet,"closed merchant confirmation cannot commit money");user.ClosePalomoMerchant();
        CaelumCityTradeSession.Open(user,Vendor);
        Check(!user.PalomoMerchantMenuOpen,"closed civilian service cannot reopen its menu");
        Check(!CaelumTravelService.CanDepart(user,10,true),"departing transport closes before ticket payment");
        Check(user.health>0 && Port.Reinforcements.Stopped && Port.Reinforcements.Remaining==5900,"surviving player and finite reserves persist after defeat");
        Check(user.GetPersistentCharacterState(false).FactionReputation[0]==Reputation[0],"defeat has no automatic reputation penalty");
        Ticket=CaelumTransportTicket.Create(17,CaelumJourneyState.MODE_CART,1,LostAt+1,CaelumTransportBooking.Epoch());
        Check(CaelumBattleConsequences.HoldDeparture(user,Ticket,LostAt+3600) && Ticket.Elapsed==0,"already purchased waiting ticket remains at origin without consuming distance");
        LostVendor.health=0;LostVendor.Die(null,null,0,'None');
        Check(CaelumBattleConsequences.MerchantDead(1),"real merchant death creates a persistent identity tombstone");
        if(LostVendor!=null)LostVendor.Destroy();CaelumCityMerchant.Prepare();
        Check(CaelumCityMerchant.Find(1)==null && CaelumCityMerchant.Find(0)==Vendor,"preparing city preserves survivors and never replaces the dead merchant");
        Check(outcome.ClosedAt(LostAt+3600) && !outcome.ClosedAt(LostAt-1),"historical service checks respect the actual defeat boundary");
        WalkStart=user.Pos;user.Angle=180;
        Console.Printf("CA451 CHECKPOINT READY failures=%d",Failures);
    }
    void VerifyWalking()
    {
        let user=CaelumPlayer(players[0].mo);
        Check((user.Pos-WalkStart).Length()>64 && CaelumBattleConsequences.Closed(user),"native walking remains available during occupation");
        Console.Printf("CA451 WALK %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
        user.SetOrigin(WalkStart,false);
    }
    void Restored()
    {
        let user=CaelumPlayer(players[0].mo);let outcome=CaelumBattleConsequences.View(user);
        Check(outcome.Defeated && !outcome.Won && outcome.DeadShop[1],"saved occupation and actual merchant death survive reload");
        int serial=outcome.Serial;Port.ObserveBattle();
        Check(outcome.Serial==serial && Port.Reinforcements.Remaining==5900,"replaying observed defeat does not repeat consequences or reserves");
        Port.ConfirmBossRetreat(Port.Boss);
        Check(Port.BossRetreated && !Port.Boss.ConfirmedDead,"living Zupay retreat remains explicitly confirmed");
        for(int i=0;i<11;i++)Port.Machines[i].DestroyByTarot();Port.ObserveBattle();
        Check(!outcome.Won && CaelumBattleConsequences.Closed(user),"eleven original machines do not liberate the city");
        Port.Machines[11].DestroyByTarot();Port.ObserveBattle();
        WonAt=outcome.VictoryCivil;Reopens=outcome.RecoveryCivil;
        Check(outcome.Won && outcome.Defeated && Reopens==WonAt+86400,"original twelve plus retreat liberate with exact twenty-four-world-hour recovery");
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let member=CaelumPlayer(players[p].mo);CaelumBattleConsequences.Update(member);
            Check(member.GetPersistentCharacterState(false).FactionReputation[0]==Reputation[p]+100,"each eligible native participant receives one hundred once");
        }
        Check(CaelumBattleConsequences.Closed(user) && !CaelumBattleConsequences.MerchantAvailable(user,Vendor),"liberation does not reopen services prematurely");
        ClockTo(Reopens-1);Check(CaelumBattleConsequences.Closed(user),"shared world calendar still closes services just before recovery");
        Check(outcome.ClosedAt(Reopens-0.01) && !outcome.ClosedAt(Reopens),"recovery boundary is exact and independent of observation frequency");
        ClockTo(Reopens+1);CaelumBattleConsequences.Update(user);
        Check(!CaelumBattleConsequences.Closed(user) && outcome.Recovered,"calendar catch-up reopens surviving services");
        CaelumCityTradeSession.Open(user,Vendor);
        Check(user.IsActivePalomoMerchantSessionValid(),"same surviving merchant reopens with its actual inventory");user.ClosePalomoMerchant();
        Check(CaelumTravelService.CanDepart(user,10,true),"transport departures resume after recovery");
        Check(!CaelumBattleConsequences.HoldDeparture(user,Ticket,Reopens+3600) && Ticket.Stamp==Reopens,"waiting ticket excludes the closed interval when observation crosses recovery");
        Ticket.Observe(Reopens+3600);
        Check(Abs(Ticket.Elapsed-3600)<0.01,"only post-recovery time advances the waiting journey");
        CaelumCityMerchant.Prepare();
        Check(CaelumCityMerchant.Find(1)==null && Vendor.health>0 && Vendor.WalletCopper==Wallet,"recovery neither replaces dead merchants nor resets survivor money");
        Port.ObserveBattle();CaelumBattleConsequences.Update(user);
        Check(user.GetPersistentCharacterState(false).FactionReputation[0]==Reputation[0]+100 && Port.Reinforcements.Remaining==5900,"recovery and repeated observation do not add rewards or soldiers");
        Port.Calendar(user);let agenda=CaelumScheduleState.Get(user);
        Check(agenda.FindKey("port451_recovery")!=null,"Journal calendar records the authored reopening date");
        Console.Printf("CA451 RESULT %s checks=%d failures=%d",Failures==0?"PASS":"FAIL",Checks,Failures);
    }
    void VerifyTravel()
    {
        let user=CaelumPlayer(players[0].mo);let outcome=CaelumBattleConsequences.View(user);
        Check(outcome!=null && outcome.Defeated && outcome.DeadShop[1] && CaelumBattleConsequences.Closed(user),"unloaded return retains occupation and real casualty identity");
        Check(Port.Reinforcements.Remaining==5900 && Port.Reinforcements.Stopped,"unloaded defeated city never regenerates finite reserves");
        Check(user.GetPersistentCharacterState(false).FactionReputation[0]==Reputation[0],"travel through defeat never fabricates a reward");
        Console.Printf("CA451 TRAVEL %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    void LegacyRestored(){}
    void Liberate()
    {
        Port.ConfirmBossRetreat(Port.Boss);
        for(int i=0;i<Port.Machines.Size();i++)Port.Machines[i].DestroyByTarot();
        Port.ObserveBattle();
    }
    void NormalVictory()
    {
        Port.EnsureDirector();let user=CaelumPlayer(players[0].mo);
        let outcome=CaelumBattleConsequences.View(user);Liberate();
        Check(outcome!=null && outcome.Won && !outcome.Defeated && !CaelumBattleConsequences.Closed(user),"victory without prior defeat keeps civilian services open");
        Check(outcome.RecoveryCivil<0 && First.health>0 && Second.health>0,"normal victory invents neither a recovery delay nor defender deaths");
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
        {
            let member=CaelumPlayer(players[p].mo);let record=member.GetPersistentCharacterState(false);
            CaelumBattleConsequences.Update(member);
            Check(record.FactionReputation[0]==Reputation[p]+100,"normal victory pays each eligible identity once");
            let identity=record.LawfulIdentity;int other=record.FactionReputation[1];
            record.LawfulIdentity=new('CaelumLawfulIdentity');record.LawfulIdentity.Token="ca451-new-character";
            int paid=record.FactionReputation[0];CaelumBattleConsequences.Update(member);
            Check(record.FactionReputation[0]==paid && !outcome.Reward.Contains(record),"a new identity in the same player slot cannot inherit eligibility");
            record.LawfulIdentity.Token=identity.Token;CaelumBattleConsequences.Update(member);
            Check(record.FactionReputation[0]==paid && outcome.RewardPaid.Contains(record),"reimported identity cannot collect the same reward again");
            record.LawfulIdentity=identity;member.PersistCharacterState();
            Check(record.FactionReputation[1]==other,"victory does not alter unrelated faction reputation");
        }
        int serial=outcome.Serial;Port.ObserveBattle();Port.EnsureDirector();
        Check(outcome.Serial==serial && Port.Reinforcements.Remaining==5900,"replayed victory is idempotent and preserves spent reserves");
        Console.Printf("CA451 VICTORY %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    void PrepareAway()
    {
        Liberate();let outcome=CaelumBattleConsequences.View(CaelumPlayer(players[0].mo));
        Reopens=outcome.RecoveryCivil;
        Check(outcome.Won && outcome.Defeated && Reopens>=0,"liberated city starts recovery before leaving");
    }
    void ShowUI(bool transport)
    {
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(false);
        record.QuestState[CaelumConstants.QUEST_INVESTIGATE_SIEGE]=CaelumConstants.QUEST_STATE_ACTIVE;
        user.RefreshSocialJournalSnapshot();user.PersistCharacterState();
        if(transport)
        {
            let booking=CaelumTransportBooking(user.GiveInventoryType('CaelumTransportBooking'));
            booking.Revision=2;booking.Ticket=Ticket;booking.StopMap=level.MapName;
            Check(CaelumTransportSession.Show(user,null,Vendor),"actual transport menu displays the closed departure status");
        }
        else
        {
            let session=CaelumTransportSession.Find(user);if(session!=null)session.Open=false;
            Console.Printf("CA451 UI %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
        }
    }
    void AdvanceAway()
    {
        let outcome=CaelumBattleConsequences.View(CaelumPlayer(players[0].mo));
        Check(level.MapName=="T451" && outcome!=null && outcome.Defeated && outcome.Won,"shared consequence state is available while city is unloaded");
        ClockTo(outcome.RecoveryCivil+1);CaelumBattleConsequences.Update(CaelumPlayer(players[0].mo));
    }
    void VerifyAway()
    {
        let user=CaelumPlayer(players[0].mo);let outcome=CaelumBattleConsequences.View(user);
        Check(outcome.Recovered && !CaelumBattleConsequences.Closed(user),"return after recovery observes reopened services without replaying the battle");
        CaelumCityMerchant.Prepare();
        let survivor=CaelumCityMerchant.Find(0);
        Check(CaelumCityMerchant.Find(1)==null && survivor!=null && survivor.TID==45101 && survivor.WalletCopper==Wallet,"unloaded recovery preserves actual survivor and casualty identities");
        for(int p=0;p<MAXPLAYERS;p++)if(playeringame[p])
            Check(CaelumPlayer(players[p].mo).GetPersistentCharacterState(false).FactionReputation[0]==Reputation[p]+100,"unloaded recovery never pays a second liberation reward");
        Check(Port.Reinforcements.Remaining==5900 && Port.Reinforcements.Stopped,"unloaded recovery does not regenerate battle reserves");
        Console.Printf("CA451 AWAY %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }
    void Catchup(){Restored();Console.Printf("CA451 CATCHUP %s failures=%d",Failures==0?"PASS":"FAIL",Failures);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca451_seed")Seed();
        else if(e.Name=="ca451_initial")Initial();
        else if(e.Name=="ca451_walk")VerifyWalking();
        else if(e.Name=="ca451_victory")NormalVictory();
        else if(e.Name=="ca451_prepareaway")PrepareAway();
        else if(e.Name=="ca451_advanceaway")AdvanceAway();
        else if(e.Name=="ca451_verifyaway")VerifyAway();
        else if(e.Name=="ca451_transportui")ShowUI(true);
        else if(e.Name=="ca451_journalui")ShowUI(false);
        else if(e.Name=="ca451_restored")Restored();
        else if(e.Name=="ca451_catchup")Catchup();
        else if(e.Name=="ca451_travel")Level.ChangeLevel('T451',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca451_return")Level.ChangeLevel('MAP03',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca451_verifytravel")VerifyTravel();
    }
}
