// Real seats and production network requests; suspend a response window in a common save.
class CA590NetworkProbe : EventHandler
{
    int Phase,Checks,Failures,RootSeat,RootSerial,RestoreStamp;
    bool Restored,Complete;
    ui int SentSerial,SentPhase;
    ui bool Saved,SentAny;
    CaelumPortableSmallTable Table;
    CaelumCardDuel Duel;
    String SavedState;
    void Check(bool okay,String label){Checks++;if(!okay)Failures++;Console.Printf("CA443 %s %s",okay?"PASS":"FAIL",label);}
    String State()
    {
        let g=Duel.Advanced;
        String s=String.Format("%d/%d/%d/%d/%d/%d/%d/%d/%d/%d/%f/%f",Duel.Serial,g.Phase,g.HandNumber,g.Turn,g.Mano,g.Drawn,g.RootOperation,g.RootSeat,g.RootArgument,g.PassMask,g.Health[0],g.Health[1]);
        s=s..String.Format("/%d/%d/%d",g.QuerySeat,g.QueryTarget,g.QueryCard);
        for(int i=0;i<g.Count();i++)
        {
            for(int j=0;j<int(g.Seats[i].Cards.Hand.Size());j++)s=s..String.Format("/%d:%d",g.Seats[i].Cards.Hand[j],int(g.Seats[i].Cards.Used[j]));
            for(int c=0;c<22;c++)s=s..String.Format("/%d:%d:%d",int(g.Seats[i].Selected[c]),int(g.Seats[i].Spent[c]),int(g.Seats[i].Active[c]));
            s=s..String.Format("/%d:%d",int(g.Seats[i].SenseSpent),int(g.Seats[i].WorldSpent));
        }
        for(int i=0;i<int(g.Deck.Size());i++)s=s..String.Format("/%d",g.Deck[i]);
        return s;
    }
    override void WorldLoaded(WorldEvent e){if(e.IsSaveGame){Restored=true;RestoreStamp=level.time;}}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca443_restored" && e.Player==0){Restored=true;RestoreStamp=level.time;}
        if(e.Name=="ca_card_table" || e.Name=="ca_tc2")Console.Printf("CA443 EVENT phase=%d sender=%d op=%d serial=%d",Phase,e.Player,e.Args[0],e.Args[2]);
    }
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0 || Complete)return;
        let user=CaelumPlayer(players[consoleplayer].mo);let link=CaelumCardSeat.Read(user);if(link==null)return;
        if(Phase==13 && !Restored && consoleplayer==0 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA443 pending response window");return;}
        int serial=link.LastSerial;if(SentAny && SentSerial==serial)return;
        int op=-1,arg=0;String eventName="ca_card_table";
        if(Phase==1 && consoleplayer==0){op=CaelumCardDuel.CONSENT;arg=1;}
        else if(Phase==2 && consoleplayer==0)op=CaelumCardDuel.SELECT_GAME;
        else if(Phase==3 && consoleplayer==0)op=CaelumCardDuel.SELECT_MAJORS;
        else if(Phase==4 && consoleplayer==0)op=CaelumCardDuel.SELECT_SENSES;
        else if((Phase==5 && consoleplayer==0)||(Phase==6 && consoleplayer==1)){op=CaelumCardDuel.SELECT_MAJOR;arg=18;}
        else if((Phase==7 && consoleplayer==0)||(Phase==8 && consoleplayer==1))op=CaelumCardDuel.CONSENT;
        else if(Duel!=null && Duel.Advanced!=null)
        {
            eventName="ca_tc2";let g=Duel.Advanced;
            if(Phase==14 && g.QuerySeat>=0 && g.QueryTarget==consoleplayer)op=CaelumTrucazoGame.ANSWER_YES;
            else if((Phase==9 || Phase==11 || Phase==14 || Phase==16) && g.Window && g.QuerySeat<0 && g.Priority==consoleplayer)op=CaelumTrucazoGame.PASS;
            else if(Phase==17 && g.Priority==consoleplayer){op=CaelumTrucazoGame.SENSE;arg=(1-consoleplayer)*78+22;}
            else if(Phase==10 && g.Turn==consoleplayer)op=CaelumTrucazoGame.MAJOR_BASE+18;
            else if((Phase==12 || Phase==15) && g.Turn==consoleplayer){op=CaelumTrucazoRules.PLAY_CARD;arg=0;}
        }
        if(op>=0 && (op==CaelumTrucazoGame.PASS || SentPhase!=Phase))
        {SentAny=true;SentPhase=Phase;SentSerial=serial;Console.Printf("CA443 SEND phase=%d op=%d serial=%d",Phase,op,serial);SendNetworkEvent(eventName,op,arg,serial);}
    }
    override void WorldTick()
    {
        if(Complete || !playeringame[0] || !playeringame[1] || level.maptime<105)return;
        let a=CaelumPlayer(players[0].mo),b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b))return;
        if(Phase==0)
        {
            Table=CaelumPortableSmallTable(Actor.Spawn('CaelumPortableSmallTable',(0,512,0),NO_REPLACE));
            Check(Table.ConfigureParts(),"production table creates real chairs");
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);let chair=Table.Chairs[i];user.SetOrigin(chair.Pos+(0,i==0?-48:48,0),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
                Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,chair),"production sitting succeeds");
                Check(CaelumCardSeat.Interact(user),"production interaction opens lobby");
                let record=user.GetPersistentCharacterState(true);record.TarotOwned[18]=true;
                let choice=CaelumTrucazoChoice.Get(user);for(int c=0;c<22;c++)choice.Selected[c]=false;
            }
            b.GiveInventoryType('CaelumTarotDeck');Phase=1;return;
        }
        if(Phase==1 && CaelumCardSeat.Session(a)!=null){Duel=CaelumCardSeat.Session(a);Check(Duel==CaelumCardSeat.Session(b),"native invitation shares one lobby");Phase=2;}
        else if(Phase==2 && Duel.Game==CaelumCardDuel.GAME_TRUCAZO)Phase=3;
        else if(Phase==3 && Duel.Majors)Phase=4;
        else if(Phase==4 && Duel.Senses)Phase=5;
        else if(Phase==5 && CaelumTrucazoChoice.Read(a).Selected[18])Phase=6;
        else if(Phase==6 && CaelumTrucazoChoice.Read(b).Selected[18])Phase=7;
        else if(Phase==7 && Duel.Accepted==1){Check(!Duel.Started,"first consent cannot start magical match");Phase=8;}
        else if(Phase==8 && Duel.Started)
        {Check(Duel.Advanced!=null && Duel.Trucazo==null && Duel.Advanced.Seats[0].Selected[18] && Duel.Advanced.Seats[1].Selected[18],"native consent snapshots separate magical ruleset and personal loadouts");Phase=9;}
        else if(Phase==9 && !Duel.Advanced.Window){Check(Duel.Advanced.Phase==CaelumTrucazoGame.PLAYING,"native passes finish preparation");Phase=10;}
        else if(Phase==10 && Duel.Advanced.Stack.Size()==1)Phase=11;
        else if(Phase==11 && !Duel.Advanced.Window){Check(Duel.Advanced.Seats[Duel.Advanced.Turn].Active[18],"native priority resolves Moon");Phase=12;}
        else if(Phase==12 && Duel.Advanced.Window)
        {
            let g=Duel.Advanced;RootSeat=g.RootSeat;RootSerial=Duel.Serial;
            Check(g.RootOperation==CaelumTrucazoRules.PLAY_CARD && g.Seats[RootSeat].Played<0,"native play waits for response before committing card");
            Check(!Duel.DispatchAdvanced(a,CaelumTrucazoGame.PASS,0,Duel.Serial-1),"stale revision is rejected with live open seats");
            Phase=17;
        }
        else if(Phase==17 && Duel.Advanced.QuerySeat>=0)
        {
            Check(Duel.Advanced.Seats[Duel.Advanced.QuerySeat].SenseSpent,"native Insight question suspends the pending Moon response");
            SavedState=State();Phase=13;
            Console.Printf("CA443 RESULT %s checks=%d fresh",Failures==0?"PASS":"FAIL",Checks);
        }
        else if(Phase==13 && Restored && level.time>=RestoreStamp+105)
        {
            Check(State()==SavedState,"common checkpoint restores exact hand deck effects and response window");
            Check(CaelumCardSeat.Session(a)==Duel && CaelumCardSeat.Session(b)==Duel && Duel.Seated(0) && Duel.Seated(1),"restored native participants retain occupied table and match identity");
            Check(!Duel.DispatchAdvanced(a,CaelumTrucazoRules.PLAY_CARD,0,RootSerial-1),"pre-save replay cannot commit a second card");Phase=14;
        }
        else if(Phase==14 && !Duel.Advanced.Window)
        {
            let g=Duel.Advanced;
            Check(g.Seats[RootSeat].Cards.Used[0] && g.HiddenPlayed(RootSeat),"restored response commits original Moon card once and conceals it");
            Check(g.QuerySeat<0 && g.Seats[g.Mano].PrivateKey!="" && g.Seats[1-g.Mano].PrivateKey=="","restored Insight answer is delivered only to its requester");Phase=15;
        }
        else if(Phase==15 && Duel.Advanced.Window)Phase=16;
        else if(Phase==16 && !Duel.Advanced.Window)
        {
            Check(Duel.Advanced.Phase==CaelumTrucazoGame.TRICK_RESULT && !Duel.Advanced.HiddenPlayed(RootSeat),"second native commitment reveals Moon and resolves trick");
            Check(Duel.Advanced.Seats[0].Cards.Used[0] && Duel.Advanced.Seats[1].Cards.Used[0],"each player controls only their own card");
            Complete=true;Console.Printf("CA443 RESULT %s checks=%d restored",Failures==0?"PASS":"FAIL",Checks);
        }
    }
}
