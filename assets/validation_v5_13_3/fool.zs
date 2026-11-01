// Diagnostic speaker: initialize after the native deferred PostBeginPlay.
class CA440FoolSpeaker : CaelumPalomo
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        MerchantAnchored=true;WanderEnabled=false;
        NarrativeRevealInitialized=true;NarrativeRevealRequired=false;
        NarrativeRevealed=true;DepartureDone=true;
        bInvisible=false;bSolid=true;bShootable=true;
    }
}
class CA440FoolLedger : Inventory
{
    int Phase,Edited;
    double Anima;
    vector3 Ground;
    CaelumCannon Gun;
    CaelumPalomo Speaker;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA440Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    void Check(bool ok,String label){Console.Printf("CA440F %s %s",ok?"PASS":"FAIL",label);}
    void Clear(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(false);
        for(int card=0;card<78;card++)
        {record.TarotOwned[card]=true;record.TarotSelected[card]=false;record.TarotActive[card]=false;record.TarotRemaining[card]=0;}
        record.TarotOrderCount=0;record.TarotLoadoutRevision=1;record.TarotPowerRevision=2;
        record.TarotEffectTics=0;record.TarotCooldownTics=0;
    }
    void Speaker(CaelumPlayer user,CA440FoolLedger ledger)
    {
        double y=ledger.Phase==4?256:0;
        user.SetOrigin((-256,y,0),false);user.Angle=0;user.Pitch=0;
        ledger.Speaker=CaelumPalomo(Actor.Spawn('CA440FoolSpeaker',(-208,y,0),NO_REPLACE));
        ledger.Speaker.args[0]=1;ledger.Speaker.MerchantAnchored=true;ledger.Speaker.WanderEnabled=false;
        ledger.Speaker.NarrativeRevealInitialized=true;ledger.Speaker.NarrativeRevealRequired=false;
        ledger.Speaker.NarrativeRevealed=true;ledger.Speaker.DepartureDone=true;
        ledger.Speaker.bInvisible=false;ledger.Speaker.bSolid=true;ledger.Speaker.bShootable=true;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_tarot_select")
        {
            let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true);
            let raw=CaelumPlayer(players[e.Player].mo);
            Console.Printf("CA440F INPUT slot=%d body=%d editable=%d pending=%d departed=%d predicting=%d number=%d",e.Player,user!=null,user!=null && CaelumFoolTravel.CanEditDeadLoadout(user),raw.SessionIdentityPending,raw.ProfileDeparted,(raw.player.cheats&CF_PREDICTING)!=0,raw.PlayerNumber());
        }
    }
    override void WorldUnloaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440FoolLedger(user.FindInventory('CA440FoolLedger')):null;
        if(ledger!=null && ledger.Phase==2 && level.MapName=="MAP03")
        {
            Check(ledger.Gun!=null && ledger.Gun.TarotDestroyed,"Tower executes in origin before Fool map transfer");
            Check(CaelumTarotService.IsActive(user.GetPersistentCharacterState(false),14),"later Temperance executes before map transfer");
        }
    }
    override void WorldTick()
    {
        if(level.time<105)return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        let ledger=CA440FoolLedger(user.FindInventory('CA440FoolLedger'));
        if(!Entered){Entered=true;Reloaded=ledger!=null;}
        let record=user.GetPersistentCharacterState(false);
        if(ledger==null)
        {
            ledger=CA440FoolLedger(user.GiveInventoryType('CA440FoolLedger'));
            Clear(user);Clear(other);
            user.SetOrigin((-256,0,0),false);other.SetOrigin((-600,-600,0),false);
            user.CurrentAnima=user.DerivedStats.MaximumAnima;
            CaelumTarotService.Select(user,21);
            double anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user) && CaelumCooperativeTravel.View(user)==null,"World skips Fool when no player is dead");
            Check(CaelumTarotService.IsActive(record,14) && abs(user.CurrentAnima-(anima-1000))<0.01,"World still executes other powers with one payment");
            Clear(user);CaelumTarotService.Select(user,0);user.CurrentAnima=user.DerivedStats.MaximumAnima;
            Check(!CaelumTarotService.Activate(user),"direct Fool requires a dead participant");
            other.health=other.player.health=0;other.Die(null,null,0,'None');
            Check(!CaelumTarotService.Select(other,0),"dead loadout editing is denied while a living player remains");
            Clear(user);CaelumTarotService.Select(user,9);CaelumTarotService.Select(user,16);
            CaelumTarotService.Select(user,0);CaelumTarotService.Select(user,14);
            // Tower first: a later Hermit does not repeat an instant effect.
            CaelumTarotService.Select(user,9);CaelumTarotService.Select(user,9);
            CaelumTarotService.Select(user,2);
            ledger.Gun=CaelumCannon(Actor.Spawn('CaelumCannon',(0,0,0),NO_REPLACE));ledger.Gun.InitializeCannon();
            let part=ledger.Gun.Blocks[11];vector3 delta=part.Pos+(0,0,part.Height/2)-CaelumTelekinesisRules.Eye(user);
            user.Angle=VectorAngle(delta.X,delta.Y);user.Pitch=-VectorAngle(delta.XY.Length(),delta.Z);
            ledger.Anima=user.CurrentAnima;
            Check(CaelumTarotService.Activate(user),"ordered Fool sequence creates consent proposal");
            let vote=CaelumCooperativeTravel.View(user);
            if(vote==null)return;
            Check(vote.RequiredMask()==1 && vote.Mask==3,"normal Fool requires only living votes");
            Check(user.CurrentAnima==ledger.Anima && record.TarotCooldownTics==0 && !ledger.Gun.TarotDestroyed,"proposal has no cost or premature power");
            Check(vote.Request(user,CaelumCooperativeTravel.CANCEL,vote.Serial) && user.CurrentAnima==ledger.Anima,"rejection cancels the complete sequence without cost");
            CaelumTarotService.Activate(user);vote=CaelumCooperativeTravel.View(user);
            CaelumTarotService.Select(user,14);CaelumTarotService.Select(user,14);
            Check(!vote.SourceValid(),"changed order invalidates pending consent");vote.Request(user,CaelumCooperativeTravel.CANCEL,vote.Serial);
            CaelumTarotService.Activate(user);vote=CaelumCooperativeTravel.View(user);vote.FoolSequenceRevision=1;
            Check(!vote.SourceValid() && user.CurrentAnima==ledger.Anima,"legacy unsnapshotted vote cancels without payment");vote.Request(user,CaelumCooperativeTravel.CANCEL,vote.Serial);
            CaelumTarotService.Activate(user);vote=CaelumCooperativeTravel.View(user);
            Check(vote!=null && vote.Opened && vote.TarotOrder[0]==16 && vote.TarotOrderCount==5,"new proposal retains selected order and complete sequence");
            Check(vote.TarotGround!=null && vote.TarotGround.Found && vote.TarotGround.Damage>0,"consent snapshots visible floor and spell power before payment");
            ledger.Phase=1;user.PersistCharacterState();Console.Printf("CA440F CHECKPOINT proposal");return;
        }
        if(ledger.Phase==1 && (Reloaded || level.time>120))
        {
            let vote=CaelumCooperativeTravel.View(user);
            if(Reloaded)
            {
                Check(vote==null,"recovery cancels unaccepted proposal");
                Check(CaelumTarotService.Activate(user),"recovered session can request fresh consent");
                vote=CaelumCooperativeTravel.View(user);
            }
            if(vote==null){ledger.Phase=99;return;}
            ledger.Anima=user.CurrentAnima;ledger.Phase=2;
            ledger.Ground=vote.TarotGround.Point;
            user.Angle+=90;user.Pitch=0;
            Check(vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial),"living consent commits without requiring dead vote");
            return;
        }
        if(ledger.Phase==2 && level.MapName=="MAP01")
        {
            Check(user.health>0 && CaelumSpirit.Active(other),"arrival preserves living caster and dead spirit");
            Check(record.TarotCooldownTics>0 && abs(user.CurrentAnima-(ledger.Anima-1000))<1,"accepted journey charges activator exactly once");
            let trap=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState'));
            Check((trap==null || trap.Mine==null) && record.TarotRemaining[2]==0 && !record.TarotActive[2],
                "map departure removes trap and its active window without refunding cooldown");
            Check(CaelumTarotService.IsActive(record,14) && record.TarotRemaining[16]==0,"instant and temporal results survive travel");
            Clear(user);CaelumTarotService.Select(user,21);user.CurrentAnima=user.DerivedStats.MaximumAnima;
            Check(CaelumTarotService.Activate(user) && CaelumCooperativeTravel.View(user)==null && CaelumTarotService.IsActive(record,14),"World in mansion skips only Fool journey");
            Speaker(user,ledger);
            Check(!CaelumFoolTravel.ProposeReturn(user,ledger.Speaker),"Palomo return requires equipped Fool on requester");
            CaelumTarotService.Select(user,0);
            Check(CaelumFoolTravel.ProposeReturn(user,ledger.Speaker),"equipped requester can propose group return");
            let vote=CaelumCooperativeTravel.View(user);if(vote==null)return;
            Check(vote.RequiredMask()==3,"return retains full group unanimity");
            vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial);
            Check(vote.Opened,"one return vote leaves destination pending");
            ledger.Phase=3;vote.Request(other,CaelumCooperativeTravel.ACCEPT,vote.Serial);return;
        }
        if(ledger.Phase==3 && level.MapName=="MAP03")
        {
            Check(user.health>0 && other.health<=0 && other.player.playerstate==PST_DEAD,"return does not resurrect the dead traveller");
            Clear(user);CaelumTarotService.Select(user,15);CaelumTarotService.Select(user,0);CaelumTarotService.Select(user,14);
            user.health=user.player.health=10;user.CurrentAnima=0;record.TarotCooldownTics=TICRATE*20;
            Check(CaelumTarotService.Activate(user),"Devil permits voted Fool sequence during cooldown");
            let vote=CaelumCooperativeTravel.View(user);if(vote==null)return;
            Check(vote.FoolDevilPayment && user.health==10,"lethal Health payment is deferred until consent");
            ledger.Phase=4;vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial);return;
        }
        if(ledger.Phase==4 && level.MapName=="MAP01" && ledger.Edited==0)
        {
            ledger.Edited=1;
            Console.Printf("CA440F DIAG spirit=%d allDead=%d editable=%d input=%d",CaelumSpirit.Active(user),CaelumFoolTravel.AllDead(),CaelumFoolTravel.CanEditDeadLoadout(user),StaticEventHandler.Find('CA440FoolInput')!=null);
        }
        if(ledger.Phase==4 && level.MapName=="MAP01" && !record.TarotSelected[0])
        {
            Check(CaelumSpirit.Active(user) && CaelumSpirit.Active(other) && user.CurrentAnima==0,"lethal Devil payment still delivers both spirits");
            Check(CaelumTarotService.IsActive(record,14),"paid sequence continues after caster death");
            Check(!record.TarotSelected[0] && user.health<=0,"native network action unequips a card without resurrection");
            Speaker(user,ledger);Check(!CaelumFoolTravel.ProposeReturn(user,ledger.Speaker),"dead requester still needs equipped Fool to return");
            ledger.Phase=5;return;
        }
        if(ledger.Phase==5 && record.TarotSelected[0])
        {
            Check(user.health<=0 && CaelumFoolTravel.AllDead(),"native network action equips Fool while whole group stays dead");
            Check(CaelumFoolTravel.ProposeReturn(user,ledger.Speaker),"dead group can propose return after equipping Fool");
            let vote=CaelumCooperativeTravel.View(user);if(vote==null)return;
            let visit=CaelumFoolJourney.View(user);
            Console.Printf("CA440F RETURN roster=%d source=%d owner=%d equipped=%d active=%d origin=%s destination=%s destroyed=%d gap=%.2f dz=%.2f sight=%d ready=%d/%d",
                vote.RosterValid(),vote.SourceValid(),vote.Owner==user,CaelumFoolTravel.ReturnEquipped(user),visit.Active,visit.OriginMap,vote.Destination,
                ledger.Speaker.bDestroyed,user.Distance2D(ledger.Speaker),Abs(user.Pos.Z-ledger.Speaker.Pos.Z),user.CheckSight(ledger.Speaker),CaelumWorldClockTicker.Ready(user),CaelumWorldClockTicker.Ready(other));
            Check(vote.SourceValid() && vote.RosterValid(),"dead return has a visible speaker and admitted roster");
            Check(vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial),"first dead traveller accepts return");ledger.Phase=6;
            Check(vote.Request(other,CaelumCooperativeTravel.ACCEPT,vote.Serial),"second dead traveller accepts return");return;
        }
        if(ledger.Phase==7 && Reloaded)
        {
            Check(user.health<=0 && other.health<=0,"common save keeps both dead participants");
            Check(record.TarotSelected[0] && record.TarotCooldownTics>0,"common save keeps spiritual choice and paid recharge");
            Check(CaelumCooperativeTravel.View(user)==null,"common save cannot repeat committed travel");
            ledger.Phase=8;Console.Printf("CA440F RESULT reload");return;
        }
        if(ledger.Phase==6 && level.MapName=="MAP03")
        {
            Check(user.health<=0 && other.health<=0 && !CaelumSpirit.Active(user),"second return preserves normal death in campaign");
            Check(record.TarotSelected[0] && record.TarotCooldownTics>0,"spiritual loadout and paid cooldown survive return");
            ledger.Phase=7;Console.Printf("CA440F RESULT capture");
        }
    }
}

class CA440FoolInput : StaticEventHandler
{
    ui int EditStep;
    override void UiTick()
    {
        if(consoleplayer!=0 || gamestate!=GS_LEVEL)return;
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440FoolLedger(user.FindInventory('CA440FoolLedger')):null;
        if(ledger==null || ledger.Edited==0 || level.MapName!="MAP01" || !CaelumSpirit.Active(user))return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let member=CaelumPlayer(players[i].mo);
            if(member==null || member.SessionIdentityPending || member.ProfileDeparted
                || !member.CharacterCreationComplete || member.CreationWizardOpen)return;
        }
        if(ledger.Phase==4 && EditStep==0)
        {EditStep=1;Console.Printf("CA440F UI unequip");EventHandler.SendNetworkEvent("ca_tarot_select",0);}
        else if(ledger.Phase==5 && EditStep==1)
        {EditStep=2;Console.Printf("CA440F UI equip");EventHandler.SendNetworkEvent("ca_tarot_select",0);}
    }
}

// Observe the departing world before production cleanup, without moving startup earlier.
class CA440FoolBeforeUnload : StaticEventHandler
{
    override void OnRegister(){SetOrder(1);}
    override void WorldUnloaded(WorldEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA440FoolLedger(user.FindInventory('CA440FoolLedger')):null;
        if(ledger==null || ledger.Phase!=2 || level.MapName!="MAP03")return;
        let trap=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState'));
        bool okay=trap!=null && trap.Mine!=null && (trap.Mine.Pos-ledger.Ground-(0,0,0.5)).Length()<0.02;
        Console.Printf("CA440F %s accepted trap uses saved floor even after looking away",okay?"PASS":"FAIL");
    }
}
