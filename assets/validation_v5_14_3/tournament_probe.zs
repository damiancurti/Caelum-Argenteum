// #446: complete native human brackets, shared checkpoint and fixed eligibility.
class CA590NetworkProbe : EventHandler
{
    const PEERS=2;
    const DISCONNECT=0;
    const TIER=0;
    int Phase,Checks,Failures,RestoreStamp,RecordedResults;
    bool Restored,Complete;
    ui int SentSerial,SentOperation,SentContext;
    ui bool Saved,SavedResult,SentAny;
    CaelumDiningTable Table;
    CaelumTrucazoTournament Tournament;
    CaelumCardDuel CheckedMatch,InspectedLobby;
    double Money[8];
    String SavedState;
    void Check(bool okay,String label){Checks++;if(!okay)Failures++;Console.Printf("CA446 %s %s",okay?"PASS":"FAIL",label);}
    String State()
    {
        let t=Tournament;String value=String.Format("%d/%d/%d/%d/%d",t.Phase,t.Round,t.Cursor,t.Champion,t.Accepted);
        for(int i=0;i<int(t.Remaining.Size());i++)value=value..String.Format("/R%d",t.Remaining[i]);
        for(int i=0;i<int(t.NextRound.Size());i++)value=value..String.Format("/N%d",t.NextRound[i]);
        for(int i=0;i<int(t.Victors.Size());i++)value=value..String.Format("/W%d:%d:%d",t.PlayedA[i],t.PlayedB[i],t.Victors[i]);
        for(int i=0;i<PEERS;i++)value=value..String.Format("/P%d:%.0f:%d",t.Slots[i],CaelumTrucazoCompetitive.Rating(t.Members[i]),t.Members[i].GetPersistentCharacterState(true).TrucazoReputation);
        return value;
    }
    void InspectLobby()
    {
        let duel=Tournament.Match;
        Check(duel.Count()==2 && duel.Ranked && duel.Consequences && duel.Tournament==Tournament,"each bracket creates an individual ranked lobby with optional stakes");
        Check(!duel.SetTeamSize(4) && !duel.Lobby(duel.Member(0),CaelumCardDuel.SELECT_GAME,duel.Serial)
            && !duel.Lobby(duel.Member(0),CaelumCardDuel.SELECT_RANKED,duel.Serial),"tournament lobby cannot become a team or unranked match");
        Check(Tournament.HasDeck(),"same-table entrant supplies the physical deck across pairings");InspectedLobby=duel;
    }
    void InspectMatch()
    {
        let duel=Tournament.Match;let game=duel.Advanced;
        Check(duel.Started && duel.Accepted==duel.FullMask() && duel.Competitive!=null && !duel.Competitive.Applied,"both current humans explicitly accept before ranked start");
        Check(game.Health[0]==game.Maximum[0] && game.Health[1]==game.Maximum[1] && game.HandNumber==1,"every tournament match starts with a fresh health reserve");
        Check(game.Seats[0].Cards.Intelligence==game.Seats[1].Cards.Intelligence && game.Seats[0].Cards.MaximumHealth==game.Seats[1].Cards.MaximumHealth,"individual ranked pairing uses shared attribute minima");
        CheckedMatch=duel;
    }
    void InspectResult()
    {
        let t=Tournament;let duel=t.Match;int size=int(t.Victors.Size());
        Check(size==RecordedResults+1 && duel!=null && duel.Competitive.Applied && duel.Wagers.Settled,"one completed bracket result follows committed rating and stake settlement");
        if(duel!=null)t.MatchEnded(duel);
        Check(t.Victors.Size()==size,"replayed match completion cannot advance the bracket twice");RecordedResults=size;
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca446_restored" && e.Player==0){Restored=true;RestoreStamp=level.time;Check(Phase==7 && Tournament.Round==1 && Tournament.Match==null,"loaded native file is the intended between-rounds checkpoint before any resumed play");}}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(Phase==9 && consoleplayer==0 && !SavedResult){SavedResult=true;SavegameManager.GetManager().DoSave(0,"CA446 completed bracket");return;}
        if(Complete)return;
        if(Phase==7 && !Restored && consoleplayer==0 && !Saved){Saved=true;SavegameManager.GetManager().DoSave(0,"CA446 bracket between rounds");return;}
        let user=CaelumPlayer(players[consoleplayer].mo);let link=CaelumCardSeat.Read(user);if(link==null)return;
        int op=-1,arg=0,serial=link.LastSerial,context=0;String eventName="ca_card_table";
        if(Phase==1 && consoleplayer==0){op=CaelumCardDuel.CREATE_TOURNAMENT;arg=TIER*16+PEERS;}
        else if(Phase==2 && Tournament!=null)
        {
            int next=0;while(next<PEERS && (Tournament.Accepted&(1<<next))!=0)next++;
            if(next<PEERS && consoleplayer==Tournament.Slots[next]){op=CaelumTrucazoTournament.ACCEPT;eventName="ca_tc4_tournament";serial=Tournament.Serial;context=1;}
        }
        else if((Phase==3 || Phase==8) && Tournament!=null && Tournament.Phase==CaelumTrucazoTournament.ACTIVE)
        {
            let duel=Tournament.Match;
            if(duel!=null && link.Duel==duel && link.Open)
            {
                if(!duel.Started && duel==InspectedLobby)
                {int next=(duel.Accepted&1)==0?0:1;if(consoleplayer==duel.MemberSlot(next))op=CaelumCardDuel.CONSENT;}
                else if(duel.Started && duel==CheckedMatch)
                {
                    eventName="ca_tc2";context=2;
                    if(duel.Finished())op=CaelumTrucazoRules.CLOSE;
                    else if(consoleplayer==duel.MemberSlot(1))op=CaelumTrucazoRules.FORFEIT;
                }
            }
            else if(duel==null && (Restored || Tournament.Victors.Size()<PEERS/2))
            {
                int next=Tournament.NextSeat(false);
                if(next>=0 && consoleplayer==Tournament.Slots[next])
                {op=CaelumTrucazoTournament.NEXT_MATCH;eventName="ca_tc4_tournament";serial=Tournament.Serial;context=1;}
            }
        }
        if(op>=0 && (!SentAny || SentSerial!=serial || SentOperation!=op || SentContext!=context))
        {SentAny=true;SentSerial=serial;SentOperation=op;SentContext=context;SendNetworkEvent(eventName,op,arg,serial);}
    }
    override void WorldTick()
    {
        if(Complete || level.maptime<105)return;
        if(DISCONNECT!=0 && Phase==7 && !Restored && !playeringame[PEERS-1])
        {Check(Tournament.Phase==CaelumTrucazoTournament.ACTIVE && Tournament.Victors.Size()==PEERS/2 && Tournament.Remaining.Size()==PEERS/2,"departing eliminated entrant neither replaces members nor awards a walkover");Complete=true;Console.Printf("CA446 RESULT %s checks=%d disconnected",Failures==0?"PASS":"FAIL",Checks);return;}
        for(int i=0;i<PEERS;i++)if(!playeringame[i] || !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        let a=CaelumPlayer(players[0].mo);
        if(Phase==0)
        {
            Check(CaelumDiningWorld.Place(2446,(0,512,0),3),"production tournament table placed");Table=CaelumDiningWorld.Find(2446);if(Table==null){Complete=true;return;}
            for(int i=0;i<PEERS;i++)
            {
                let user=CaelumPlayer(players[i].mo);let chair=Table.Chairs[i];vector3 away=chair.Pos-Table.Pos;user.SetOrigin(chair.Pos+away*(48/Max(1.0,away.Length())),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,chair) && CaelumCardSeat.Interact(user),"native entrant sits at the shared tournament table");
                let record=user.GetPersistentCharacterState(true);record.EnsureTrucazoRating();record.TrucazoRating=CaelumTrucazoData.TournamentThreshold(TIER);
                let choice=CaelumTrucazoChoice.Get(user);for(int c=0;c<22;c++)choice.Selected[c]=false;Money[i]=user.GetOwnedMoneyCopperValue();
            }
            let last=CaelumPlayer(players[PEERS-1].mo);last.GetPersistentCharacterState(true).TrucazoRating--;
            Check(!CaelumTrucazoTournament.Create(a,PEERS,TIER,CaelumCardSeat.Read(a).LastSerial),"one below-threshold entrant cannot enter the bracket");
            last.GetPersistentCharacterState(true).TrucazoRating++;last.GiveInventoryType('CaelumTarotDeck');Phase=1;return;
        }
        if(Phase==1 && CaelumCardSeat.Read(a).Tournament!=null)
        {
            Tournament=CaelumCardSeat.Read(a).Tournament;
            Check(Tournament.Count()==PEERS && Tournament.Phase==CaelumTrucazoTournament.PROPOSAL && Tournament.Accepted==0 && Tournament.Match==null,"visible fixed bracket waits for unanimous enrollment");
            Check(!Tournament.Request(a,CaelumTrucazoTournament.ACCEPT,Tournament.Serial-1) && Tournament.Accepted==0,"stale tournament acceptance cannot join");Phase=2;
        }
        else if(Phase==2 && Tournament.Phase==CaelumTrucazoTournament.ACTIVE)
        {Check(Tournament.Accepted==Tournament.FullMask(),"all original humans accept before the first pairing");Phase=3;}
        if(Phase==3 || Phase==8)
        {
            let duel=Tournament.Match;
            if(duel!=null && !duel.Started && duel!=InspectedLobby)InspectLobby();
            if(duel!=null && duel.Started && duel!=CheckedMatch)InspectMatch();
            if(Tournament.Victors.Size()>RecordedResults)InspectResult();
            if(Phase==3 && Tournament.Victors.Size()==PEERS/2 && Tournament.Match==null)
            {Check(Tournament.Round==1 && Tournament.Remaining.Size()==PEERS/2,"first round advances exactly one winner per pairing");SavedState=State();Phase=7;Console.Printf("CA446 RESULT %s checks=%d fresh",Failures==0?"PASS":"FAIL",Checks);}
            if(Tournament.Phase==CaelumTrucazoTournament.COMPLETE)
            {
                Check(Tournament.Champion==0 && Tournament.Victors.Size()==PEERS-1 && Tournament.Remaining.Size()==1,"complete knockout has one champion and exactly size-minus-one results");
                int rounds=PEERS==4?2:3;let record=a.GetPersistentCharacterState(true);
                Check(record.TrucazoRating==CaelumTrucazoData.TournamentThreshold(TIER)+16*rounds && record.TrucazoReputation==5*rounds,"champion receives only each actual ranked match result and normal victory reputation");
                bool unchanged=true;for(int i=0;i<PEERS;i++)if(Tournament.Members[i].GetOwnedMoneyCopperValue()!=Money[i])unchanged=false;
                Check(unchanged,"tournament recognition does not create money prizes");Phase=9;Complete=true;Console.Printf("CA446 RESULT %s checks=%d restored",Failures==0?"PASS":"FAIL",Checks);
            }
        }
        else if(Phase==7 && Restored && level.time>=RestoreStamp+105)
        {Check(State()==SavedState && Tournament.Match==null,"common checkpoint preserves bracket membership pairings results ratings and next round");Phase=8;}
    }
}
