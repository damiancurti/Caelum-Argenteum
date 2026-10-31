class CA437FoolLedger : Inventory
{
    int Phase,Mask,Serial;
    CaelumPlayer Members[MAXPLAYERS];
    CaelumPersistentCharacterState Records[MAXPLAYERS];
    Inventory Coins[MAXPLAYERS];
    vector3 Origins[MAXPLAYERS];
    double AnimaBefore[MAXPLAYERS];
    vector3 SpiritOrigin[MAXPLAYERS];
    CaelumPalomo Speaker;
    CaelumArgento KeyKeeper;
    Inventory OriginalKey;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA437ClockProbe : EventHandler
{
    const HOLD_SPIRIT = 0;
    bool Done;
    override void WorldLoaded(WorldEvent e) { Done=false; Watch=0; }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca437_verify_reload" && e.Player==0){Done=false;Watch=0;}}
    int Watch;
    ui int SentSerial;
    ui bool Saved;
    Inventory SceneToken;
    void Check(bool okay,String label){Console.Printf("CA437 %s %s",okay?"PASS":"FAIL",label);}
    void CompanionBoundary(CaelumPlayer user)
    {
        let party=CaelumCompanionParty.Get(user,true);let clock=CaelumWorldClock.Get(user);
        let bond=CaelumCompanionBond(new('CaelumCompanionBond'));
        bond.Party=party;bond.Body=CaelumCombatActor(Actor.Spawn('CaelumRonnie',(700,700,0),NO_REPLACE));
        bond.Enlisted=true;bond.DeathRecorded=true;bond.Body.health=0;
        bond.DeathDay=clock.CompletedDays-CaelumCompanionData.DEAD_SLOT_DAYS;bond.DeathTic=clock.DayTics;
        party.Roster.Push(bond);bond.Reconcile();
        Check(!bond.SlotReleased && party.Occupied()==2,"dead companion retains a place at exactly three world days");
        bond.DeathTic--;bond.Reconcile();
        Check(bond.SlotReleased && party.Occupied()==1 && bond.Body.health==0,
            "one world tic beyond three days releases only the slot, without resurrection");
        for(int i=1;i<CaelumFormationData.PARTY_CAPACITY;i++)
        {let other=CaelumCompanionBond(new('CaelumCompanionBond'));other.Enlisted=true;party.Roster.Push(other);}
        bond.Body.health=1;bond.Reconcile();
        Check(!bond.Enlisted && bond.Order==CaelumCompanionData.DISMISSED && party.Occupied()==CaelumFormationData.PARTY_CAPACITY,
            "a revived companion waits when the released place has been filled");
        Check(bond.Body!=null && bond.Body.health==1,"slot maintenance never deletes or replaces the returning body");
        bond.Body.Destroy();party.Roster.Clear();
    }
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);let vote=CaelumCooperativeTravel.View(user);
        if(vote!=null && vote.Opened && SentSerial!=vote.Serial)
        {Console.Printf("CA437 SEND peer=%d serial=%d",consoleplayer,vote.Serial);SentSerial=vote.Serial;SendNetworkEvent("ca_cooperative_travel",CaelumCooperativeTravel.ACCEPT,vote.Serial);}
        if(Done && consoleplayer==0 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA437 Fool round trip with all players dead");}
    }
    override void WorldTick()
    {
        if(Done || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(a))return;
        let ledger=CA437FoolLedger(a.FindInventory('CA437FoolLedger'));
        if(ledger==null)
        {
            if(level.MapName!="MAP03")return;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
            ledger=CA437FoolLedger(a.GiveInventoryType('CA437FoolLedger'));
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let record=user.GetPersistentCharacterState(false);
                if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
                user.player.ConversationNPC=null;user.player.ConversationPC=null;
                ledger.Members[i]=user;ledger.Records[i]=record;ledger.Origins[i]=user.Pos;ledger.Mask|=1<<i;
                user.GiveInventory('CaelumCopperCoin',7);ledger.Coins[i]=user.FindInventory('CaelumCopperCoin');
                user.CurrentAnima=user.DerivedStats.MaximumAnima;
                ledger.AnimaBefore[i]=user.CurrentAnima;
                record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
                record.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;
                record.TarotSelected[CaelumConstants.TAROT_THE_FOOL]=true;
            }
            CompanionBoundary(a);
            let r=ledger.Records[0];r.TarotPowerRevision=1;r.TarotActive[CaelumConstants.TAROT_THE_FOOL]=true;
            r.TarotEffectTics=35;r.TarotCooldownTics=70;a.GiveInventoryType('CaelumTarotFlight');
            CaelumTarotService.EnsureRevision(r);
            Check(r.TarotPowerRevision==2 && r.TarotCooldownTics==70 && r.TarotSelected[CaelumConstants.TAROT_THE_FOOL]
                && !r.TarotActive[CaelumConstants.TAROT_THE_FOOL] && a.FindInventory('CaelumTarotFlight')==null,"old Fool flight migrates without resetting ownership, selection or cooldown");
            r.TarotCooldownTics=0;
            Check(CaelumTarotService.Activate(a),"living Fool activation creates a unanimous proposal");
            let vote=CaelumCooperativeTravel.View(a);
            Check(vote!=null && vote.Opened && a.CurrentAnima==ledger.AnimaBefore[0] && r.TarotCooldownTics==0,"proposal charges neither Anima nor cooldown");
            if(vote==null){Done=true;return;}
            Check(vote.Request(a,CaelumCooperativeTravel.CANCEL,vote.Serial) && a.CurrentAnima==ledger.AnimaBefore[0]
                && r.TarotCooldownTics==0,"rejection leaves the activator's payment untouched");
            Check(!CaelumFoolTravel.Propose(a,true),"exceptional activation is rejected while any player lives");
            SceneToken=Inventory(Actor.Spawn('CaelumCopperCoin',(500,500,0),NO_REPLACE));SceneToken.Amount=4;
            for(int i=0;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null)
            {let user=ledger.Members[i];user.health=user.player.health=0;user.Die(null,null,0,'None');}
            Check(CaelumFoolTravel.Propose(a,true),"all-dead group may propose the exceptional Fool journey");
            Check(a.health<=0 && a.player.playerstate==PST_DEAD,"proposing The Fool never revives its dead activator");
            ledger.Phase=1;return;
        }
        if(level.MapName=="MAP01" && ledger.Phase==1)
        {
            bool bodies=true,items=true,payment=true;
            for(int i=0;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null)
            {
                let user=CaelumPlayer(players[i].mo);
                if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
                user.player.ConversationNPC=null;user.player.ConversationPC=null;
                bodies=bodies && user==ledger.Members[i] && user.health<=0 && user.GetPersistentCharacterState(false)==ledger.Records[i];
                items=items && user.FindInventory('CaelumCopperCoin')==ledger.Coins[i];
                payment=payment && Abs(user.CurrentAnima-(ledger.AnimaBefore[i]-(i==0?CaelumConstants.TAROT_ACTIVATION_ANIMA:0)))<0.01;
            }
            Check(bodies,"unanimous all-dead travel preserves every corpse and personal identity");
            Check(items,"mansion arrival preserves the exact material inventories");
            Check(payment && ledger.Records[0].TarotCooldownTics>0,"only the activator pays exactly once after unanimous consent");
            Check(a.FindInventory('CaelumTarotFlight')==null,"Fool journey grants no legacy flight power");
            for(int i=0;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null)ledger.SpiritOrigin[i]=ledger.Members[i].Pos;
            ledger.Phase=10;return;
        }
        if(level.MapName=="MAP01" && ledger.Phase==10)
        {
            Watch++;
            if(Watch<350)return;
            bool moving=true,dead=true;
            for(int i=0;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null)
            {moving=moving && (ledger.Members[i].Pos-ledger.SpiritOrigin[i]).Length()>1;
             dead=dead && ledger.Members[i].health<=0 && ledger.Members[i].player.playerstate==PST_DEAD && CaelumSpirit.Active(ledger.Members[i]);}
            if(!moving && Watch<2000)return;
            Check(moving && dead,"native held movement controls the spirit while every character stays dead");
            Check(!a.CanTouchItem(ledger.Coins[0]) && !a.UseInventory(ledger.Coins[0]),"spirit cannot pick up or use material inventory");
            let record=a.GetPersistentCharacterState(false);record.TarotDeckGranted=false;
            Check(CaelumTarotDeckRules.Grant(a,false) && record.SpiritDeckPending && !record.TarotDeckGranted,"material deck reward remains pending while dead");
            CaelumSpiritRewards.Deliver(a);
            Check(record.SpiritDeckPending && !record.TarotDeckGranted,"repeated delivery cannot grant material rewards to a spirit");
            ledger.Speaker=CaelumPalomo(Actor.Spawn('CaelumPalomo',a.Pos+(48,0,0),NO_REPLACE));
            ledger.Speaker.args[0]=1;ledger.Speaker.MerchantAnchored=true;ledger.Speaker.WanderEnabled=false;
            ledger.Speaker.NarrativeRevealRequired=true;ledger.Speaker.DepartureDone=true;
            a.Angle=0;a.Pitch=0;
            // Fixture: completed physical trials, pending final conversation.
            record.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
            record.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE;
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE);
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE);
            record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED);
            let rulo=CaelumRulo(Actor.Spawn('CaelumRulo',a.Pos+(0,48,0),NO_REPLACE));
            a.player.ConversationNPC=rulo;
            Check(CaelumMainM00RuloTrial.Complete(a) && record.QuestStage[0]==CaelumConstants.MAIN_M00_STATE_RULO_COMPLETE,
                "spirit may complete an already-earned narrative objective");
            a.player.ConversationNPC=ledger.Speaker;ledger.Speaker.bInConversation=true;
            Check(CaelumMainM00PalomoFinal.AcceptMagicBox(a) && record.SpiritBoxPending && !record.MagicBoxOwned
                && record.QuestStage[0]==CaelumConstants.MAIN_M00_STATE_BOX_RECEIVED,
                "final conversation advances the mission without handing material Box to a spirit");
            Check(CaelumMainM00PalomoFinal.AcceptMagicBox(a) && record.SpiritBoxPending && !record.MagicBoxOwned,
                "repeated final dialogue keeps one pending Box reward");
            ledger.KeyKeeper=CaelumArgento(Actor.Spawn('CaelumArgento',a.Pos+(0,-48,0),NO_REPLACE));
            ledger.KeyKeeper.StoryAnchored=true;
            ledger.OriginalKey=Inventory(Actor.Spawn('CaelumSilverKey',ledger.KeyKeeper.Pos,NO_REPLACE));
            ledger.OriginalKey.AttachToOwner(ledger.KeyKeeper);
            a.player.ConversationNPC=ledger.KeyKeeper;
            Check(CaelumMainM00SocialDialogue.GiveSilverKey(a) && record.SpiritSilverKeyPending
                && ledger.OriginalKey.Owner==ledger.KeyKeeper && a.FindInventory('CaelumSilverKey')==null,
                "promised unique key remains with its living keeper");
            a.player.ConversationNPC=null;ledger.Speaker.bInConversation=false;
            ledger.Phase=11;return;
        }
        if(level.MapName=="MAP01" && ledger.Phase==11)
        {
            if(HOLD_SPIRIT==1){Done=true;Console.Printf("CA437 RESULT peer=%d spirit-pending",consoleplayer);return;}
            let record=a.GetPersistentCharacterState(false);
            Check(record.SpiritBoxPending && record.SpiritDeckPending && record.SpiritSilverKeyPending
                && !record.MagicBoxOwned && !record.TarotDeckGranted && a.health<=0,
                "pending promises and death survive until return or native reload");
            a.Angle=0;a.Pitch=0;
            Check(a.OpenPalomoDialogue(ledger.Speaker) && a.player.ConversationNPC==ledger.Speaker,"spirit opens Palomo's native return conversation");
            a.GiveInventoryType('CaelumFoolReturnAction');
            Check(CaelumFoolJourney.View(a).PendingReturn,"native dialogue action queues the agreed return");
            ledger.Speaker.bInConversation=false;a.player.ConversationNPC=null;a.player.ConversationPC=null;
            ledger.Phase=2;return;
        }
        if(level.MapName=="MAP03" && ledger.Phase==2)
        {
            bool bodies=true,items=true,position=true,closed=true;
            for(int i=0;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null)
            {
                let user=CaelumPlayer(players[i].mo);let visit=CaelumFoolJourney.View(user);
                bodies=bodies && user==ledger.Members[i] && user.health<=0 && user.player.playerstate==PST_DEAD;
                items=items && user.FindInventory('CaelumCopperCoin')==ledger.Coins[i];
                position=position && (user.Pos-CaelumDeadTraveler.View(user).BodyPosition).Length()<0.1;
                closed=closed && visit!=null && !visit.Active && !visit.Returning;
            }
            Check(bodies,"return preserves all deaths without automatic resurrection");
            Check(items,"return preserves the original material items");
            Check(position,"each corpse returns to its own recorded position");
            Check(closed,"return consumes the visit without leaving a second free journey");
            Check(SceneToken!=null && SceneToken.Amount==4,"mansion visit preserves unrelated campaign hub stock");
            Check(Abs(a.CurrentAnima-(ledger.AnimaBefore[0]-CaelumConstants.TAROT_ACTIVATION_ANIMA))<0.01,"Palomo return does not charge again");
            Check(CaelumResurrection.Restore(a,a.Pos) && a.health>0,"explicit resurrection restores the original body after the return");
            let record=a.GetPersistentCharacterState(false);
            Check(record.TarotDeckGranted && !record.SpiritDeckPending,"resurrection delivers the pending deck reward");
            Check(record.MagicBoxOwned && !record.SpiritBoxPending && record.SpiritSilverKeyPending,
                "resurrection grants the promised Box once and retains unique-key claim for its keeper");
            let deck=CaelumTarotDeckRules.Owned(a);CaelumSpiritRewards.Deliver(a);
            Check(deck!=null && CaelumTarotDeckRules.Owned(a)==deck,"repeating pending delivery preserves the same reward instance");
            ledger.Phase=3;Done=true;Console.Printf("CA437 RESULT peer=%d fool",consoleplayer);
        }
    }
}
