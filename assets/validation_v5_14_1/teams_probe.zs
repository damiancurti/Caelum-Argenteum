// #445: native production seating/events plus bounded isolated rule assertions.
class CA590NetworkProbe : EventHandler
{
    const PEERS=2;
    const DISCONNECT=0;
    int Phase,Checks,Failures,RestoreStamp;
    bool Restored,Complete;
    ui int SentSerial,SentPhase;
    ui bool SentAny,Saved;
    CaelumDiningTable Table;
    CaelumCardDuel Duel;
    String SavedState;
    void Check(bool okay,String label){Checks++;if(!okay)Failures++;Console.Printf("CA445 %s %s",okay?"PASS":"FAIL",label);}
    String State()
    {
        let g=Duel.Advanced;String s=String.Format("%d/%d/%d/%d/%f/%f",g.Mano,g.Turn,g.HandNumber,g.Phase,g.Health[0],g.Health[1]);
        for(int i=0;i<g.Count();i++)
        {
            s=s..String.Format("/%d/%d/%f",Duel.MemberSlot(i),g.Seats[i].Played,g.Seats[i].Cards.MaximumHealth);
            for(int c=0;c<int(g.Seats[i].Cards.Hand.Size());c++)s=s..String.Format("/%d:%d",g.Seats[i].Cards.Hand[c],int(g.Seats[i].Cards.Used[c]));
        }
        for(int i=0;i<int(g.Deck.Size());i++)s=s..String.Format("/%d",g.Deck[i]);
        return s;
    }
    void Rules()
    {
        let actual=Duel.Advanced;double maximum[2];bool seen[78];int total=0;bool unique=true;
        for(int i=0;i<PEERS;i++)
        {
            maximum[i%2]+=CaelumTrucazoRules.Health(Duel.Member(i).Attributes.Patience);
            let own=actual.Seats[i].Cards;Check(own.Hand.Size()>=3,"every team member has three playable cards");
            for(int row=0;row<3;row++)
            {
                int n=row==0?int(own.Hand.Size()):row==1?int(own.FirstRow.Size()):int(own.SecondRow.Size());
                for(int c=0;c<n;c++){int card=row==0?own.Hand[c]:row==1?own.FirstRow[c]:own.SecondRow[c];if(seen[card])unique=false;seen[card]=true;total++;}
            }
        }
        for(int i=actual.Drawn;i<int(actual.Deck.Size());i++){int card=actual.Deck[i];if(seen[card])unique=false;seen[card]=true;total++;}
        Check(unique && total==56,"one shared deck retains all identities for full team size");
        Check(actual.Health[0]==maximum[0] && actual.Health[1]==maximum[1],"team reserves equal sum of individual Patience squared");
        Check(!Duel.SetTeamSize(2),"membership cannot change after start");
        Check(!Duel.Dispatch(Duel.Member(0),CaelumCardDuel.GAME_TRUCAZO,CaelumTrucazoRules.PLAY_CARD,0,Duel.Serial),"legacy two-seat protocol cannot mutate a team match");
        int turn=actual.Turn;
        for(int i=0;i<PEERS;i++)if(i!=turn)Check(!Duel.DispatchAdvanced(Duel.Member(i),CaelumTrucazoRules.PLAY_CARD,0,Duel.Serial),"other seats cannot play for the active member");
        let g=CaelumTrucazoGame.Create(Duel);g.Mano=0;g.Turn=0;g.Phase=CaelumTrucazoGame.PLAYING;
        g.Execute(0,CaelumTrucazoRules.TRUCO,0);
        Check(g.Responder==1 && g.Pending==CaelumTrucazoRules.TRUCO_CALL,"next opposing seat answers the call without a captain");
        for(int i=0;i<PEERS;i++)if(i!=1)Check(!g.CanNormal(i,CaelumTrucazoRules.ACCEPT),"call answer belongs only to designated opposing member");
        g.Execute(1,CaelumTrucazoRules.ACCEPT,0);
        Check(g.TrucoRight==1,"accepted Truco transfers raise right to the responding team");
        for(int i=0;i<PEERS;i++){g.Seats[i].BaseEnvido=10+i;g.Seats[i].Cards.FirstRow.Clear();g.Seats[i].Cards.SecondRow.Clear();}
        Check(g.BestEnvidoSeat(0)==PEERS-2 && g.BestEnvidoSeat(1)==PEERS-1,"each team uses its best individual Envido");
        double before0=g.Health[0],before1=g.Health[1];
        int expected=CaelumTrucazoRules.Damage(CaelumTrucazoRules.ROW_BASE*PEERS/2,CaelumTrucazoRules.ROW_BASE*PEERS/2,2,g.Intelligence(0));
        g.FinishHand(0,2);
        Check(g.Health[0]==before0 && g.Health[1]==Max(0.0,before1-expected),"team damage sums rows and averages attacker Intelligence once");
        double ended=g.Health[1];g.FinishHand(0,2);Check(g.Health[1]==ended,"duplicate hand resolution cannot repeat shared damage");
        if(!g.Finished()){g.Execute(0,CaelumTrucazoRules.ADVANCE,0);Check(g.Health[1]==ended && g.Maximum[1]==maximum[1],"next hand preserves team reserve and original maximum");}
        g=CaelumTrucazoGame.Create(Duel);g.Mano=PEERS-1;g.Turn=g.Mano;
        for(int i=0;i<PEERS;i++)g.Seats[i].Cards.Hand[0]=22;
        for(int i=0;i<PEERS;i++)g.Execute((g.Mano+i)%PEERS,CaelumTrucazoRules.PLAY_CARD,0);
        // Identical test cards deliberately isolate mano arbitration; production uniqueness is checked above.
        Check(g.Turn==g.Mano && g.Tricks[1]==1,"equal strongest cards follow mano priority across both teams");
        if(PEERS>2)
        {
            g=CaelumTrucazoGame.Create(Duel);g.MagicEnabled=true;g.Turn=2;
            g.Seats[0].Active[3]=true;g.Seats[2].Selected[3]=true;
            Check(!g.ValidMajor(2,3,0),"allied Empress cannot stack on the same shared reserve");
            g.Seats[0].Active[11]=true;g.Seats[2].Selected[11]=true;
            Check(g.ValidMajor(2,11,0),"allied Strength can modify its own distinct row");
            g.Seats[0].Active[2]=true;g.SensesEnabled=true;
            Check(!g.Act(2,CaelumTrucazoGame.SENSE,22),"Insight cannot query a teammate private hand");
        }
        int revision=Duel.RosterRevision,count=Duel.Count();Duel.EnsureRoster();Duel.EnsureRoster();
        Check(Duel.RosterRevision==revision && Duel.Count()==count,"roster migration is idempotent");
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=="ca445_restored" && e.Player==0){Restored=true;RestoreStamp=level.time;}}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0 || Complete)return;
        if(Phase==8 && !Restored && consoleplayer==0 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA445 shared team pause");return;}
        let user=CaelumPlayer(players[consoleplayer].mo);let link=CaelumCardSeat.Read(user);if(link==null)return;
        int serial=link.LastSerial;if(SentAny && SentSerial==serial)return;
        int op=-1,arg=0;String eventName="ca_card_table";
        if(Phase==1 && consoleplayer==0){op=CaelumCardDuel.CONSENT;arg=1;}
        else if(Phase==2 && consoleplayer==0)op=CaelumCardDuel.SELECT_GAME;
        else if(Phase==3 && consoleplayer==0){op=CaelumCardDuel.SELECT_TEAM_SIZE;arg=PEERS;}
        else if(Phase==4 && Duel!=null)
        {int next=0;while(next<PEERS && (Duel.Accepted&(1<<next))!=0)next++;if(consoleplayer==next)op=CaelumCardDuel.CONSENT;}
        else if(Duel!=null && Duel.Advanced!=null)
        {
            eventName="ca_tc2";let g=Duel.Advanced;
            if(Phase==6 || Phase==7)
            {
                int votes=Phase==6?Duel.PauseVotes:Duel.ResumeVotes,next=0;
                while(next<PEERS && (votes&(1<<next))!=0)next++;
                if(next<(Phase==6?PEERS:PEERS-1) && consoleplayer==next)op=CaelumTrucazoGame.PAUSE_VOTE;
            }
            else if(Phase==9 && consoleplayer==PEERS-1)op=CaelumTrucazoGame.PAUSE_VOTE;
            else if(Phase==10)
            {
                if(g.Phase==CaelumTrucazoGame.TRICK_RESULT && consoleplayer==0)op=CaelumTrucazoRules.ADVANCE;
                else if(g.Phase==CaelumTrucazoGame.PLAYING && g.Turn==consoleplayer)
                {op=CaelumTrucazoRules.PLAY_CARD;while(arg<int(g.Seats[consoleplayer].Cards.Hand.Size()) && g.Seats[consoleplayer].Cards.Used[arg])arg++;}
            }
        }
        if(op>=0 && (Phase==10 || SentPhase!=Phase))
        {SentAny=true;SentSerial=serial;SentPhase=Phase;SendNetworkEvent(eventName,op,arg,serial);}
    }
    override void WorldTick()
    {
        if(Complete || level.maptime<105)return;
        if(DISCONNECT!=0 && Phase==8 && !Restored && !playeringame[PEERS-1])
        {
            if(!Duel.Suspended)return;
            Check(State()==SavedState && !Duel.Finished(),"disconnect preserves shared health cards deck turn and fixed membership");
            Complete=true;Console.Printf("CA445 RESULT %s checks=%d disconnected",Failures==0?"PASS":"FAIL",Checks);return;
        }
        for(int i=0;i<PEERS;i++)if(!playeringame[i] || !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        let a=CaelumPlayer(players[0].mo);
        if(Phase==0)
        {
            Check(CaelumDiningWorld.Place(1445,(0,512,0),3),"production large table supplies collision blocks and real chairs");
            Table=CaelumDiningWorld.Find(1445);if(Table==null){Complete=true;return;}
            for(int i=0;i<PEERS;i++)
            {
                let user=CaelumPlayer(players[i].mo);let chair=Table.Chairs[i];vector3 away=chair.Pos-Table.Pos;
                user.SetOrigin(chair.Pos+away*(48/Max(1.0,away.Length())),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
                Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,chair),"native member sits at shared table");
                Check(CaelumCardSeat.Interact(user),"native member opens table menu");
            }
            CaelumPlayer(players[PEERS-1].mo).GiveInventoryType('CaelumTarotDeck');Phase=1;return;
        }
        if(Phase==1 && CaelumCardSeat.Session(a)!=null){Duel=CaelumCardSeat.Session(a);Phase=2;}
        else if(Phase==2 && Duel.Game==CaelumCardDuel.GAME_TRUCAZO)Phase=3;
        else if(Phase==3 && Duel.TeamMode)
        {Check(Duel.Count()==PEERS && Duel.Accepted==0,"proposed roster binds all seats and requires fresh unanimous consent");Phase=4;}
        else if(Phase==4 && Duel.Started)
        {Check(Duel.Accepted==Duel.FullMask() && Duel.Advanced.Count()==PEERS,"only every native member consent starts equal teams");Rules();Phase=6;}
        else if(Phase==6 && Duel.Paused)
        {Check(Duel.PauseVotes==0,"all votes pause once");SavedState=State();Check(!Duel.DispatchAdvanced(Duel.Member(Duel.Advanced.Turn),CaelumTrucazoRules.PLAY_CARD,0,Duel.Serial),"paused match rejects a legal card request");Phase=7;}
        else if(Phase==7 && Duel.ResumeVotes==((1<<(PEERS-1))-1))
        {Check(Duel.Paused && State()==SavedState,"partial resume consent cannot change or unpause the hand");SavedState=State();Phase=8;Console.Printf("CA445 RESULT %s checks=%d fresh",Failures==0?"PASS":"FAIL",Checks);}
        else if(Phase==8 && Restored && level.time>=RestoreStamp+105)
        {Check(State()==SavedState && Duel.Paused && Duel.ResumeVotes==((1<<(PEERS-1))-1),"common checkpoint preserves all fixed seats shared state and pending resume votes");Check(Duel.Connected() && Duel.AllSeated(),"every original member restores at the same production table");Phase=9;}
        else if(Phase==9 && !Duel.Paused)
        {Check(State()==SavedState,"last native consent resumes without resetting any reserve or cards");Phase=10;}
        else if(Phase==10 && (Duel.Advanced.Phase==CaelumTrucazoGame.HAND_RESULT || Duel.Finished()))
        {Check(Duel.Advanced.HandWinner>=0,"all independent native turns complete a team hand");Complete=true;Console.Printf("CA445 RESULT %s checks=%d restored",Failures==0?"PASS":"FAIL",Checks);}
    }
}
