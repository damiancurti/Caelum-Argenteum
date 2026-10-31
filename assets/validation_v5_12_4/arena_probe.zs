class CA438Ledger : Inventory
{
    int Phase,Round,Mask;
    int CoinAmounts[MAXPLAYERS];
    CaelumPlayer Members[MAXPLAYERS];
    CaelumPersistentCharacterState Records[MAXPLAYERS];
    Inventory Coins[MAXPLAYERS];
    vector3 Positions[MAXPLAYERS];
    CaelumArenaMatch MatchState;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA438Probe : EventHandler
{
    const HOLD_MATCH=0;
    bool Done;
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca438_verify_reload" && e.Player==0)Done=false;}
    ui int SentSerial;
    ui bool Saved;
    void Check(bool ok,String text){Console.Printf("CA438 %s %s",ok?"PASS":"FAIL",text);}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);let vote=CaelumCooperativeTravel.View(user);
        if(vote!=null && vote.Opened && SentSerial!=vote.Serial)
        {SentSerial=vote.Serial;SendNetworkEvent("ca_cooperative_travel",CaelumCooperativeTravel.ACCEPT,vote.Serial);}
        if(!Done)Saved=false;
        if(Done && consoleplayer==0 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA438 native arenas and return");}
    }
    override void WorldTick()
    {
        if(Done || level.time<105)return;
        let user=CaelumPlayer(players[0].mo);if(!CaelumWorldClockTicker.Ready(user))return;
        let ledger=CA438Ledger(user.FindInventory('CA438Ledger'));
        if(ledger==null)
        {
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
            ledger=CA438Ledger(user.GiveInventoryType('CA438Ledger'));
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let member=CaelumPlayer(players[i].mo);
                if(member.player.ConversationNPC!=null)member.player.ConversationNPC.bInConversation=false;
                member.player.ConversationNPC=null;member.player.ConversationPC=null;
                ledger.Members[i]=member;ledger.Records[i]=member.GetPersistentCharacterState(false);
                member.GiveInventory('CaelumCopperCoin',7);ledger.Coins[i]=member.FindInventory('CaelumCopperCoin');
                ledger.CoinAmounts[i]=ledger.Coins[i].Amount;
                ledger.Records[i].SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
                ledger.Positions[i]=member.Pos;ledger.Mask|=1<<i;
            }
        }
        if(level.MapName=="MAP03" && ledger.Phase==0)
        {
            let speaker=CaelumPalomo(Actor.Spawn('CaelumPalomo',user.Pos+(48,0,0),NO_REPLACE));
            speaker.args[0]=1;speaker.MerchantAnchored=true;speaker.WanderEnabled=false;
            Check(!CaelumArena.Open(user,user),"an arbitrary actor cannot grant arena access");
            speaker.SetOrigin(user.Pos+(400,0,0),false);
            Check(!CaelumArena.Open(user,speaker),"a distant organizer cannot start a session");
            speaker.SetOrigin(user.Pos+(48,0,0),false);
            Check(CaelumArena.Open(user,speaker),"nearby Palomo opens the organizer session");
            let session=CaelumArenaState.View(user);session.Venue=ledger.Round;session.Mode=ledger.Round==0?1:0;
            Check(CaelumArena.Propose(user),"organizer proposes the selected venue and mode");
            let vote=CaelumCooperativeTravel.View(user);if(vote==null){Done=true;return;}
            Check(session.MatchState==null || session.MatchState.Status==CaelumArenaMatch.RETURNED,"proposal does not start combat before unanimous consent");
            Check(!vote.Request(user,CaelumCooperativeTravel.ACCEPT,vote.Serial-1),"stale consent cannot start an arena");
            if(ledger.Round==0)
            {
                int serial=vote.Serial;
                Check(vote.Request(user,CaelumCooperativeTravel.ACCEPT,serial) && CaelumArena.ChangeTeam(vote,user,serial)
                    && vote.Accepted==0 && vote.Serial!=serial,"a team change invalidates every earlier acceptance");
                Check(CaelumArena.ChangeTeam(vote,user,vote.Serial),"the player can restore the balanced proposed teams");
                int originalTeams[MAXPLAYERS];
                for(int i=0;i<MAXPLAYERS;i++){originalTeams[i]=vote.ArenaTeams[i];vote.ArenaTeams[i]=0;}
                Check(!CaelumArena.Commit(vote) && session.MatchState==null,"invalid empty opposing team cannot commit entry");
                for(int i=0;i<MAXPLAYERS;i++)vote.ArenaTeams[i]=originalTeams[i];
            }
            ledger.Phase=1;return;
        }
        if(CaelumArenaData.IsMap(level.MapName) && ledger.Phase==1)
        {
            let session=CaelumArenaState.View(user);let match=session!=null?session.MatchState:null;
            Check(match!=null && match.Status==CaelumArenaMatch.FIGHTING,"unanimous arrival starts the real selected arena");
            if(match==null){Done=true;return;}ledger.MatchState=match;
            bool bodies=true,items=true,starts=true;
            for(int i=0;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null)
            {
                let member=CaelumPlayer(players[i].mo);
                bodies=bodies && member==ledger.Members[i] && member.GetPersistentCharacterState(false)==ledger.Records[i];
                items=items && member.FindInventory('CaelumCopperCoin')==ledger.Coins[i];
                starts=starts && (member.Pos-CaelumArenaData.Start(match.Venue,i)).Length()<0.1;
            }
            Check(bodies && items,"entry preserves every character record and original material item");
            Check(starts,"actual venue geometry receives every player at a separate authored start");
            let victim=ledger.Members[2]!=null?ledger.Members[2]:ledger.Members[1];int before=victim.health;
            victim.DamageMobj(user,user,10,'None',DMG_NO_ARMOR,0);
            Check(victim.health<before,"native friendly fire damages another real player, including team allies");
            ledger.Phase=3;
            if(HOLD_MATCH==1 && ledger.Round==0){Done=true;Console.Printf("CA438 RESULT peer=%d active-save",consoleplayer);}
            return;
        }
        if(CaelumArenaData.IsMap(level.MapName) && ledger.Phase==3)
        {
            let match=ledger.MatchState;
            Check(CaelumArenaState.View(user).MatchState==match && match.Status==CaelumArenaMatch.FIGHTING
                && match.Members[0]==ledger.Members[0],"active match retains its shared roster and status across the checkpoint");
            if(ledger.Round==0)
            {
                let empty=CaelumArenaMatch(new('CaelumArenaMatch'));
                empty.Status=CaelumArenaMatch.FIGHTING;empty.Venue=match.Venue;
                empty.Evaluate();
                Check(empty.Status==CaelumArenaMatch.FINISHED && empty.Winner==-1,"no surviving entrant produces no winner");
                Check(match.Surrender(ledger.Members[1]) && (match.Withdrawn&2)!=0
                    && !match.Surrender(ledger.Members[1]),"surrender withdraws once without granting a second result");
            }
            // Fixture death leaves team zero, or player zero in individual mode, as the winner.
            for(int i=1;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null && (match.Mode==0 || match.Teams[i]!=match.Teams[0]))
            {let member=ledger.Members[i];member.health=member.player.health=0;member.Die(null,null,0,'None');}
            match.Evaluate();
            Check(match.Status==CaelumArenaMatch.FINISHED && match.Winner==0,"last surviving player or team wins without a time limit");
            bool dead=true;for(int i=1;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null && (match.Mode==0 || match.Teams[i]!=match.Teams[0]))
                dead=dead && ledger.Members[i].health<=0 && ledger.Members[i].player.playerstate==PST_DEAD;
            Check(dead,"arena deaths retain the ordinary dead session without automatic respawn");
            Check(CaelumArena.ProposeReturn(user),"completed combat requests a unanimous return");
            ledger.Phase=2;return;
        }
        if(level.MapName=="MAP03" && ledger.Phase==2)
        {
            bool bodies=true,items=true,positions=true,deaths=true;
            let match=ledger.MatchState;
            for(int i=0;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null)
            {
                let member=CaelumPlayer(players[i].mo);
                bodies=bodies && member==ledger.Members[i] && member.GetPersistentCharacterState(false)==ledger.Records[i];
                items=items && member.FindInventory('CaelumCopperCoin')==ledger.Coins[i] && ledger.Coins[i].Amount==ledger.CoinAmounts[i];
                positions=positions && (member.Pos-ledger.Positions[i]).Length()<0.1;
                if(i>0 && (match.Mode==0 || match.Teams[i]!=match.Teams[0]))deaths=deaths && member.health<=0;
            }
            Check(bodies && items,"return preserves original bodies and wallets without prizes or duplicate items");
            Check(positions,"living players and original corpses return to individual departure positions");
            Check(deaths && match.Status==CaelumArenaMatch.RETURNED,"return closes the event without reviving defeated participants");
            if(ledger.Round==0)
            {
                for(int i=1;i<MAXPLAYERS;i++)if(ledger.Members[i]!=null && ledger.Members[i].health<=0)
                    CaelumResurrection.Restore(ledger.Members[i],ledger.Members[i].Pos);
                ledger.Round=1;ledger.Phase=0;
            }
            else{Done=true;Console.Printf("CA438 RESULT peer=%d arenas",consoleplayer);}
        }
    }
}
