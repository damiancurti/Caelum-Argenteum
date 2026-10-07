// Datos artificiales, sólo en el complemento de pruebas; nunca se empaqueta con el juego.
class CA119Marker : Inventory
{
    int Effect, Cooldown, Visits, LastTic;
    Default { +INVENTORY.UNDROPPABLE Inventory.MaxAmount 1; }
}
class CA119Checks : StaticEventHandler
{
    int Checks, Failures;
    void Check(bool ok, String label)
    { Checks++; if(!ok){Failures++;Console.Printf("CA119 FAIL %s",label);} }
    void Dump(CaelumPlayer u, String label)
    {
        let r=u.GetPersistentCharacterState(false);
        let tc=CaelumTrucazoMatch.Get(u); let tr=CaelumTrucoMatch.Get(u);
        Console.Printf("CA119 VALUE %s map=%s cards=%d percent=%d selected=%d active=%d/%d/%d timers=%d/%d bonuses=%.3f/%.3f flight=%d tc=%d/%d/%d tr=%d/%d/%d",
            label,level.MapName,r.CountTarotCards(),r.GetTarotAttributeBonusPercent(),CaelumTarotPowers.SelectedCount(r),
            r.TarotActive[0],r.TarotActive[36],r.TarotActive[60],r.TarotEffectTics,r.TarotCooldownTics,
            r.GetTarotMinorBaseBonus(0),r.GetTarotMinorBaseBonus(6),u.FindInventory("CaelumTarotFlight")!=null,
            tc==null?-1:tc.HandNumber,tc==null?-1:tc.Drawn,tc==null?-1:tc.Serial,
            tr==null?-1:tr.HandNumber,tr==null?-1:tr.Drawn,tr==null?-1:tr.Serial);
    }
    void Capture(CaelumPlayer u, int card)
    {
        let r=u.GetPersistentCharacterState(false);
        r.TarotOwned[card]=false;
        if(card==0)
        {
            r.EnsureQuestStateInitialized();
            r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);
            r.MainM00FoolRevealed=true;
        }
        else
        {
            r.ArcanaRevealed[card]=true;r.ArcanaAvailable[card]=true;
            if(card==36)r.SewerZupayDefeated=true;
            else
            {
                r.PortSiegeNarrativeStarted=true;r.PortSiegeNarrativeComplete=true;
                let port=CaelumDemoNarrative.PortEncounter();if(port!=null)port.Victory=true;
            }
        }
        Name type=card==0?'CaelumM00FoolEssence':card==36?'CaelumCupsAceEssence':'CaelumWandsKnightEssence';
        let essence=CaelumM00FoolEssence(Actor.Spawn(type,u.Pos+(0,0,12),NO_REPLACE));
        Check(essence!=null,"capture fixture spawned");if(essence==null)return;
        essence.StoryPlaced=true;essence.CaptureUser=u;
        essence.CaptureBoxId=r.MagicBoxItemId;
        essence.CaptureImage=CaelumM00FoolCaptureImage(Actor.Spawn("CaelumM00FoolCaptureImage",u.Pos));
        essence.CaptureImage.Anchor=essence;
        if(card!=0)CaelumArcanaProgress.UpdateEssence(essence);
        essence.CaptureTics=CaelumConstants.MAIN_M00_FOOL_CAPTURE_TICS-1;
        let deck=CaelumTarotDeckRules.Owned(u);deck.InMagicBox=true;
        Check(!CaelumMainM00FoolCapture.CommitCapture(u,essence),"early capture rejected");
        essence.CaptureTics++;
        deck.InMagicBox=false;
        Check(!CaelumMainM00FoolCapture.CommitCapture(u,essence) && !r.HasTarotCard(card),"deck outside Box rejects without reward");
        deck.InMagicBox=true;essence.CaptureBoxId++;
        Check(!CaelumMainM00FoolCapture.CommitCapture(u,essence) && !r.HasTarotCard(card),"different Box identity rejects");
        essence.CaptureBoxId=r.MagicBoxItemId;
        Check(CaelumMainM00FoolCapture.CommitCapture(u,essence) && r.HasTarotCard(card),"capture commits once");
        int count=r.CountTarotCards(),bonus=r.GetTarotAttributeBonusPercent();
        Check(!CaelumMainM00FoolCapture.CommitCapture(u,essence) && r.CountTarotCards()==count && r.GetTarotAttributeBonusPercent()==bonus,"repeat capture gives no reward");
        essence.CancelCapture(false);essence.Destroy();
        Console.Printf("CA119 CAPTURE card=%d checks=%d failures=%d",card,Checks,Failures);
    }
    void Run(CaelumPlayer u)
    {
        u.InitializeDirectMapCharacter();u.bInvulnerable=true;
        let r=u.GetPersistentCharacterState(true);
        let mark=CA119Marker(u.GiveInventoryType("CA119Marker"));
        Check(u.GrantMagicBoxFromPalomo(false),"physical Box");
        Check(CaelumTarotDeckRules.Grant(u,false),"physical deck");
        Capture(u,0);
        Check(r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY),"Fool enables accepted exit");
        for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)r.TarotOwned[card]=true;
        Check(r.CountTarotCards()==78 && r.GetTarotAttributeBonusPercent()==100,"complete collection 100 percent");
        for(int a=0;a<12;a++)Check(r.GetTarotMinorBaseBonus(a)==3.0,"full Minor suit exactly three");
        for(int card=0;card<78;card++)for(int a=0;a<12;a++)
            Console.Printf("CA119 TABLE card=%d attribute=%d tenths=%d",card,a,CaelumTarotDetails.MinorTenths(card,a));
        for(int card=0;card<78;card++){r.TarotOwned[card]=card==0 || card==36 || card==60;r.TarotSelected[card]=false;r.TarotActive[card]=false;}
        r.TarotPowerRevision=0; r.TarotSelected[0]=true;
        CaelumTarotPowers.EnsureRevision(r);
        Check(CaelumTarotPowers.SelectedCount(r)==0 && r.TarotPowerRevision==1,"legacy powers initialize unselected");
        Check(!CaelumTarotPowers.Select(u,-1) && !CaelumTarotPowers.Select(u,78),"invalid selectors rejected");
        Check(!CaelumTarotPowers.Select(u,1),"unowned Major rejected");
        r.TarotOwned[1]=true;Check(!CaelumTarotPowers.Select(u,1),"unsupported owned Major rejected");r.TarotOwned[1]=false;
        Check(!CaelumTarotPowers.Activate(u),"empty activation rejected");
        Check(CaelumTarotPowers.Select(u,0) && CaelumTarotPowers.Select(u,36) && CaelumTarotPowers.Select(u,60),"three campaign selections");
        r.TarotOwned[22]=true;Check(!CaelumTarotPowers.Select(u,22),"fourth selection rejected");r.TarotOwned[22]=false;
        u.CurrentAnima=999;Check(!CaelumTarotPowers.Activate(u) && u.CurrentAnima==999,"insufficient Anima no payment");
        u.CurrentAnima=3000;u.EquipmentMenuOpen=true;
        Check(!CaelumTarotPowers.Activate(u) && u.CurrentAnima==3000,"activity gate no payment");u.EquipmentMenuOpen=false;
        let deck=CaelumTarotDeckRules.Owned(u);deck.InMagicBox=false;
        Check(CaelumTarotPowers.Activate(u),"powers do not require deck inside Box");
        Check(u.CurrentAnima==Min(2000.0,u.DerivedStats.MaximumAnima),"one payment for selected set");
        Check(r.TarotEffectTics==2100 && r.TarotCooldownTics==21000,"accepted duration and recharge");
        Check(r.GetTarotMinorBaseBonus(0)==1.2 && r.GetTarotMinorBaseBonus(6)==2.0,"active fixed bonuses doubled once");
        double anima=u.CurrentAnima;
        Check(!CaelumTarotPowers.Activate(u) && u.CurrentAnima==anima,"cooldown rejects repeated payment");
        u.CombatTarotInputReserved=false;u.ReserveTarotInput();u.ReserveTarotInput();
        Check(u.CurrentAnima==anima && u.CombatTarotInputReserved,"held input does not repay");
        Check(CaelumTarotPowers.Select(u,36) && !r.TarotSelected[36] && r.TarotActive[36],"selection affects next activation");
        u.ApplyCharacterProfile();double strength=u.Attributes.Strength;
        u.ApplyCharacterProfile();Check(u.Attributes.Strength==strength,"rebuild does not accumulate bonuses");
        CaelumTarotPowers.EnsureRevision(r);Check(r.TarotEffectTics==2100,"revision idempotent");
        u.AdvancePersonalTimeTic();Check(r.TarotEffectTics==2099 && r.TarotCooldownTics==20999,"one personal tic decrements once");
        CaelumTarotPowers.Advance(u,2099);
        Check(r.TarotEffectTics==0 && !r.TarotActive[36] && u.FindInventory("CaelumTarotFlight")==null,"expiry removes active state and flight");
        Check(r.GetTarotMinorBaseBonus(0)==0.6 && r.GetTarotMinorBaseBonus(6)==1.0,"expiry preserves passives");
        CaelumTarotPowers.Advance(u,18900);Check(r.TarotCooldownTics==0,"simulated time completes cooldown");
        u.CurrentAnima=3000;Check(CaelumTarotPowers.Activate(u),"next activation succeeds");
        Check(!r.TarotActive[36] && r.GetTarotMinorBaseBonus(6)==1.0,"new active set follows changed selection");
        deck.InMagicBox=true;
        let opponent=CaelumArgento(ThinkerIterator.Create("CaelumArgento").Next());
        Check(opponent!=null,"Argento fixture context");
        u.player.ConversationNPC=opponent;
        Check(CaelumTrucazoMatch.Open(u,opponent),"Trucazo accepted deck contract");
        let tc=CaelumTrucazoMatch.Get(u);tc.Dispatch(CaelumTrucazoRules.BEGIN,0,tc.Serial);tc.Visible=false;
        Check(tc.HandNumber==1 && tc.Sides[0].Awake[36] && tc.Sides[0].Awake[60] && !tc.Sides[0].Awake[22],"match snapshots only captured essences");
        Check(CaelumTrucoMatch.Open(u,opponent),"ordinary Truco accepted deck contract");
        let tr=CaelumTrucoMatch.Get(u);tr.Dispatch(CaelumTrucoRules.BEGIN,0,tr.Serial);tr.Visible=false;
        Check(tr.HandNumber==1 && tc.HandNumber==1 && tr.Sides[0]!=tc.Sides[0],"separate match state");
        u.player.ConversationNPC=null;
        mark.Effect=r.TarotEffectTics;mark.Cooldown=r.TarotCooldownTics;mark.LastTic=level.time;
        Dump(u,"ready");Console.Printf("CA119 CHECKS checks=%d failures=%d",Checks,Failures);
    }
    void Persistence(CaelumPlayer u,String label)
    {
        let mark=CA119Marker(u.FindInventory("CA119Marker"));if(mark==null)return;
        let r=u.GetPersistentCharacterState(false);
        Check(r.CountTarotCards()==3 && r.GetTarotAttributeBonusPercent()==4,"persistent collection");
        Check(r.TarotSelected[0] && !r.TarotSelected[36] && r.TarotSelected[60],"persistent selection");
        Check(r.TarotActive[0] && !r.TarotActive[36] && r.TarotActive[60],"persistent active set");
        Check(r.TarotCooldownTics-r.TarotEffectTics==18900,"timer separation survives load and travel");
        Check(CaelumTrucazoMatch.Get(u).HandNumber==1 && CaelumTrucoMatch.Get(u).HandNumber==1,"both matches persist");
        Dump(u,label);Console.Printf("CA119 PERSIST checks=%d failures=%d",Checks,Failures);
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.MapName=="MAP01" && level.time>=2 && u.FindInventory("CA119Marker")==null)Run(u);
    }
    override void WorldLoaded(WorldEvent e)
    { let u=CaelumPlayer(players[0].mo);if(u!=null)Persistence(u,e.IsSaveGame?"load":e.IsReopen?"hub-return":"arrival"); }
    override void WorldUnloaded(WorldEvent e)
    { let u=CaelumPlayer(players[0].mo);if(u!=null)Persistence(u,"departure"); }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca119_capture_map")Capture(u,level.MapName=="MAP02"?36:60);
        if(e.Name=="ca119_match")
        {
            let opponent=CaelumArgento(Actor.Spawn("CaelumArgento",u.Pos+(256,0,0),NO_REPLACE));
            opponent.args[0]=CaelumConstants.STORY_NPC_ANCHORED;
            opponent.StoryAnchored=true;opponent.bInvulnerable=true;
            if(e.Args[0]==0)
            {
                let match=CaelumTrucazoMatch.Get(u);match.Opponent=opponent;match.Visible=true;
                Console.Printf("CA119 MENU trucazo context=%d visible=%d",match.ContextValid(),match.Visible);
            }
            else
            {
                let match=CaelumTrucoMatch.Get(u);match.Opponent=opponent;match.Visible=true;
                Console.Printf("CA119 MENU truco context=%d visible=%d",match.ContextValid(),match.Visible);
            }
        }
        if(e.Name=="ca119_match_hide")
        { CaelumTrucazoMatch.Get(u).Visible=false;CaelumTrucoMatch.Get(u).Visible=false; }
        if(e.Name=="ca119_dump")Persistence(u,"requested");
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca119_menu_report")
        {
            let current=Menu.GetCurrentMenu();
            Console.Printf("CA119 UI handlers=%d/%d menu=%s",StaticEventHandler.Find("CaelumTrucazoEvents")!=null,
                StaticEventHandler.Find("CaelumTrucoEvents")!=null,current==null?'none':current.GetClassName());
        }
        if(e.Name=="ca119_menu_direct")Menu.SetMenu(e.Args[0]==0?'CaelumTrucazoMenu':'CaelumTrucoMenu');
    }
}
