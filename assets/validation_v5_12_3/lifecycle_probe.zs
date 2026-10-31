class CA437ClockProbe : EventHandler
{
    const DISCONNECT = -1;
    int Phase,Victim,Start;
    bool SawUse,Voted,Reloaded,Verified,RecoveryRequested;
    ui bool Sent,Saved;
    CaelumPlayer Body;
    CaelumPersistentCharacterState Record;
    CaelumCooperativeTime Vote;
    double Wallet;
    CaelumPlayer Members[MAXPLAYERS];
    CaelumPersistentCharacterState Records[MAXPLAYERS];
    double Wallets[MAXPLAYERS];
    int RosterMask;
    void Check(bool okay,String label){Console.Printf("CA437 %s %s",okay?"PASS":"FAIL",label);}
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame){Reloaded=true;Verified=false;RecoveryRequested=false;}}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL)return;
        if(Phase==1 && consoleplayer==Victim && !Sent && !Reloaded)
        {Sent=true;SendNetworkEvent("ca437_dead_vote");}
        if(Phase==2 && consoleplayer==0 && !Saved && !Reloaded)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA437 preserved dead character");}
        if(Phase==4 && consoleplayer==0 && !Saved && !Reloaded)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA437 common checkpoint before departure");}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_session_recover" && e.Player==0)RecoveryRequested=true;
        if(e.Name=="ca437_verify_reload" && e.Player==0){Reloaded=true;Verified=false;return;}
        if(e.Name!="ca437_dead_vote" || Phase!=1 || e.Player!=Victim || Voted)return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true);
        Voted=Vote.Request(user,CaelumCooperativeTime.ACCEPT,Vote.Serial);
    }
    override void WorldTick()
    {
        if(Verified || level.time<TICRATE*3)return;
        let a=CaelumPlayer(players[0].mo);
        if(DISCONNECT>=0 && Phase==4 && !playeringame[0])a=CaelumWorldClockTicker.CampaignOwner();
        if(!CaelumWorldClockTicker.Ready(a))return;
        if(Reloaded)
        {
            if(DISCONNECT>=0)
            {
                if(!RecoveryRequested)return;
                bool roster=true,identity=true,money=true;
                for(int i=0;i<MAXPLAYERS;i++)
                {
                    roster=roster && playeringame[i]==((RosterMask&(1<<i))!=0);
                    if(playeringame[i])
                    {
                        let user=CaelumPlayer(players[i].mo);
                        identity=identity && user==Members[i] && user.GetPersistentCharacterState(false)==Records[i];
                        money=money && user.GetOwnedMoneyCopperValue()==Wallets[i];
                    }
                }
                Check(roster,"common checkpoint restores the complete original native roster");
                Check(identity,"coordinated restart preserves each character and pawn identity");
                Check(money,"common recovery preserves every personal wallet");
                Check(!Vote.Opened && !Vote.Running,"recovery invalidates consent from the disconnected session");
                Verified=true;Console.Printf("CA437 RESULT peer=%d disconnect-recovered",consoleplayer);return;
            }
            Check(players[Victim].mo==Body && Body.health<=0 && Body.player.playerstate==PST_DEAD,"common native save preserves the same dead pawn");
            Check(Body.GetPersistentCharacterState(false)==Record,"dead character identity survives common restart");
            Check(Body.GetOwnedMoneyCopperValue()==Wallet,"dead character wallet survives without duplication");
            Check(CaelumSessionLifecycle.Waiting(Body),"saved death remains waiting rather than native respawn");
            Check(CaelumResurrection.Restore(Body,Body.Pos),"existing Redemption restoration can revive the original body");
            Check(players[Victim].mo==Body && Body.health>0 && Body.player.playerstate==PST_LIVE
                && Body.GetPersistentCharacterState(false)==Record && Body.GetOwnedMoneyCopperValue()==Wallet,
                "explicit resurrection retains body identity and owned money");
            Verified=true;Console.Printf("CA437 RESULT peer=%d recovered",consoleplayer);return;
        }
        if(Phase==0)
        {
            Victim=-1;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(user))return;
                if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
                user.player.ConversationNPC=null;user.player.ConversationPC=null;Victim=i;
                Members[i]=user;Records[i]=user.GetPersistentCharacterState(false);Wallets[i]=user.GetOwnedMoneyCopperValue();RosterMask|=1<<i;
            }
            if(DISCONNECT==0)Victim=0;
            Body=CaelumPlayer(players[Victim].mo);Record=Body.GetPersistentCharacterState(false);Wallet=Body.GetOwnedMoneyCopperValue();
            Check(CaelumCooperativeTime.Open(a),"living group can open a pending time proposal");
            Vote=CaelumCooperativeTime.View(a);
            if(DISCONNECT>=0)
            {
                Check(Vote!=null && Vote.Opened && !Vote.Running,"common checkpoint has uncommitted consent before real departure");
                Phase=4;return;
            }
            Body.health=Body.player.health=0;Body.Die(null,null,0,'None');
            Check(Body.bCorpse && Body.player.playerstate==PST_DEAD,"real native death creates the persistent corpse state");
            Check(Vote!=null && !Vote.Opened,"death immediately cancels pending shared consent");
            Check(CaelumCooperativeTime.Safety(Members[Victim-1])=="CA_REST_COMBAT","nearby ally death retains the ordinary combat rest restriction");
            // Start the independent post-combat consent case without waiting
            // out an unrelated accepted cooldown in every native client.
            a.CombatTimeRemaining=0;
            Check(CaelumCooperativeTime.Open(a),"post-combat survivor can ask the dead waiting player for new consent");
            Vote=CaelumCooperativeTime.View(a);if(Vote==null){Verified=true;return;}
            Start=level.time;Phase=1;return;
        }
        if(Phase==4 && !playeringame[Victim])
        {
            Check(Vote==null || (!Vote.Opened && !Vote.Running),"actual native disconnection cancels pending consent");
            bool identity=true,money=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);
                identity=identity && user==Members[i] && user.GetPersistentCharacterState(false)==Records[i];
                money=money && user.GetOwnedMoneyCopperValue()==Wallets[i];
            }
            Check(identity,"remaining native clients retain their original characters");
            Check(money,"departure does not transfer or duplicate survivor money");
            let owner=CaelumWorldClockTicker.CampaignOwner();
            Check(owner!=null && CaelumWorldClock.Get(owner).SharedRevision>0,"survivors retain an initialized shared campaign clock");
            Verified=true;Console.Printf("CA437 RESULT peer=%d disconnect",consoleplayer);
        }
        if(Phase==1)
        {
            if((Body.player.cmd.buttons&BT_USE)!=0)SawUse=true;
            if(level.time<Start+TICRATE*6)return;
            Check(SawUse,"dead native client actually presses Use");
            Check(players[Victim].mo==Body && Body.health<=0 && Body.player.playerstate==PST_DEAD,"Use cannot create a new pawn or respawn the dead character");
            Check(Body.GetPersistentCharacterState(false)==Record && Body.GetOwnedMoneyCopperValue()==Wallet,"waiting preserves personal identity and wallet");
            Check(Voted && (Vote.Accepted&(1<<Victim))!=0,"dead client can accept through its actual network identity");
            Check(!Vote.Running,"dead consent alone cannot accelerate the group");
            CaelumSessionLifecycle.CancelConsent();Check(!Vote.Opened,"shared cancellation releases pending dead-player consent");
            Phase=2;Verified=true;Console.Printf("CA437 RESULT peer=%d death",consoleplayer);
        }
    }
}
