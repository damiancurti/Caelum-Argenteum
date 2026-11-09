// #446: native modal authority and recovery plus isolated production-rule boundary checks.
class CA590NetworkProbe : EventHandler
{
    const PEERS=2;
    const DISCONNECT=0;
    const MODE=2;
    int Phase,Checks,Failures,RestoreStamp;
    bool Complete,Restored;
    ui int SentSerial,SentPhase;
    ui bool SentAny,Saved,SavedResult;
    CaelumDiningTable Table;
    CaelumCardDuel Duel;
    String SavedState;
    double Money[8],OriginalRating[8];
    void Check(bool okay,String label){Checks++;if(!okay)Failures++;Console.Printf("CA446 %s %s",okay?"PASS":"FAIL",label);}
    String State()
    {
        let g=Duel.Advanced;String s=String.Format("%d/%d/%d/%f/%f",g.Mano,g.Turn,g.HandNumber,g.Health[0],g.Health[1]);
        for(int i=0;i<PEERS;i++)
        {
            s=s..String.Format("/%f/%f/%f/%f",g.Seats[i].Cards.Intelligence,g.Seats[i].Cards.MaximumHealth,g.Seats[i].Insight,CaelumTrucazoCompetitive.Rating(Duel.Member(i)));
            for(int c=0;c<int(g.Seats[i].Cards.Hand.Size());c++)s=s..String.Format("/%d:%d",g.Seats[i].Cards.Hand[c],int(g.Seats[i].Cards.Used[c]));
        }
        for(int i=0;i<int(g.Deck.Size());i++)s=s..String.Format("/%d",g.Deck[i]);return s;
    }
    void Rules()
    {
        Check(CaelumTrucazoCompetitive.Award(1000,1000)==16,"equal-rating Elo award is sixteen");
        Check(CaelumTrucazoCompetitive.Award(1200,1600)==29 && CaelumTrucazoCompetitive.Award(1600,1200)==3,"upsets gain more than expected victories");
        Check(CaelumTrucazoCompetitive.Award(5000000000.0,0)==1 && CaelumTrucazoCompetitive.Award(0,5000000000.0)==32,"extreme ratings keep positive finite integer awards without a rating cap");
        Check(CaelumTrucazoData.Rank(999)==0 && CaelumTrucazoData.Rank(1000)==1 && CaelumTrucazoData.Rank(1200)==2 && CaelumTrucazoData.Rank(1400)==3 && CaelumTrucazoData.Rank(1600)==4,"recognition thresholds match the approved ranks");
        if(MODE==2)
        {
            let record=Duel.Member(0).GetPersistentCharacterState(true);bool owned=record.TarotOwned[0];record.TarotOwned[0]=true;
            let choice=CaelumTrucazoChoice.Get(Duel.Member(0));choice.Selected[0]=true;Duel.Majors=true;
            Check(!CaelumTrucazoCompetitive.Eligible(Duel) && !Duel.Start() && !Duel.Wagers.Reserved,"unequal personal Major counts reject before any stake debit");
            choice.Selected[0]=false;record.TarotOwned[0]=owned;Duel.Majors=false;
            Check(CaelumTrucazoCompetitive.Eligible(Duel),"equal personal choices restore ranked eligibility");
        }
        double intelligence[8],patience[8],insight[8];bool awake[8];
        for(int i=0;i<PEERS;i++)
        {
            let user=Duel.Member(i);intelligence[i]=user.Attributes.Intelligence;patience[i]=user.Attributes.Patience;insight[i]=user.Attributes.Insight;
            user.Attributes.Intelligence=13+i;user.Attributes.Patience=11+i;user.Attributes.Insight=7+i;
            let record=user.GetPersistentCharacterState(true);awake[i]=record.TarotOwned[23];record.TarotOwned[23]=true;
        }
        let game=CaelumTrucazoGame.Create(Duel);bool attributes=true,minors=true,world=true;double health[2];
        for(int i=0;i<PEERS;i++)
        {
            let user=Duel.Member(i);let seat=game.Seats[i];double expected=CaelumTrucazoRules.Health(MODE==2?11:11+i);health[i%2]+=expected;
            if(seat.Cards.Intelligence!=(MODE==2?13:13+i) || seat.Cards.MaximumHealth!=expected || seat.Insight!=(MODE==2?7:7+i))attributes=false;
            seat.Cards.FirstRow.Clear();seat.Cards.FirstRow.Push(23);
            if(seat.Cards.Awake[23]!=(MODE!=2) || game.Row(i,true)!=CaelumTrucazoRules.ROW_BASE+CaelumTrucazoRules.Number(23)*(MODE==2?1:2))minors=false;
            if(user.Attributes.Intelligence!=13+i || user.Attributes.Patience!=11+i || user.Attributes.Insight!=7+i)world=false;
            user.Attributes.Intelligence=intelligence[i];user.Attributes.Patience=patience[i];user.Attributes.Insight=insight[i];user.GetPersistentCharacterState(true).TarotOwned[23]=awake[i];
        }
        Check(attributes && game.Maximum[0]==health[0] && game.Maximum[1]==health[1],"ranked normalizes to global minima while casual and practice retain individual attributes");
        Check(minors,"only ranked disables awakened Minor row bonuses");Check(world,"match normalization never writes the world character attributes");
    }
    void Result()
    {
        bool rating=true,reputation=true,coinsUnchanged=true;
        for(int i=0;i<PEERS;i++)
        {
            let user=Duel.Member(i);let record=user.GetPersistentCharacterState(true);
            if(CaelumTrucazoCompetitive.Rating(user)!=OriginalRating[i]+(MODE==2?(i%2==0?16:-16):0))rating=false;
            if(record.TrucazoReputation!=(MODE!=0 && i%2==0?5:0))reputation=false;
            if(user.GetOwnedMoneyCopperValue()!=Money[i])coinsUnchanged=false;
        }
        Check(rating,"individual ranked winners and losers receive equal team deltas; other modes leave ratings unchanged");
        Check(reputation,"casual and ranked retain winner reputation; practice has no consequences");Check(coinsUnchanged,"ranking creates no coin rewards");
        double before=CaelumTrucazoCompetitive.Rating(Duel.Member(0));Duel.SettleResults();Duel.SettleResults();
        Check(CaelumTrucazoCompetitive.Rating(Duel.Member(0))==before,"repeated result delivery cannot apply rating twice");
        if(MODE==2)
        {
            double actual[8];for(int i=0;i<PEERS;i++){let r=Duel.Member(i).GetPersistentCharacterState(true);actual[i]=r.TrucazoRating;r.TrucazoRating=1;}
            let isolated=CaelumTrucazoCompetitive.Create(Duel);isolated.Settle();bool floorOkay=true;
            for(int i=0;i<PEERS;i++)if(CaelumTrucazoCompetitive.Rating(Duel.Member(i))!=(i%2==0?17:0) || isolated.Delta[i]!=(i%2==0?16:-1))floorOkay=false;
            Check(floorOkay,"isolated production settlement floors losses at zero and records the actual delta");
            let repeated=CaelumTrucazoCompetitive.Create(Duel);repeated.Settle();
            Check(CaelumTrucazoCompetitive.Rating(Duel.Member(0))>17,"a new result ledger against the same rival remains eligible");
            for(int i=0;i<PEERS;i++){let user=Duel.Member(i);user.GetPersistentCharacterState(true).TrucazoRating=actual[i];user.PersistCharacterState();}
        }
        Phase=9;Complete=true;Console.Printf("CA446 RESULT %s checks=%d restored mode=%d",Failures==0?"PASS":"FAIL",Checks,MODE);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca446_restored" || e.Player!=0)return;Restored=true;RestoreStamp=level.time;
        if(Complete && Phase==9)
        {
            bool exact=true;for(int i=0;i<PEERS;i++)if(CaelumTrucazoCompetitive.Rating(Duel.Member(i))!=OriginalRating[i]+(MODE==2?(i%2==0?16:-16):0))exact=false;
            double before=CaelumTrucazoCompetitive.Rating(Duel.Member(0));Duel.SettleResults();
            Check(exact && CaelumTrucazoCompetitive.Rating(Duel.Member(0))==before && (MODE!=2 || Duel.Competitive.Applied),"completed native checkpoint retains applied rating without paying again");
            Console.Printf("CA446 RESULT %s checks=%d completed checkpoint",Failures==0?"PASS":"FAIL",Checks);
        }
    }
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(Phase==9 && consoleplayer==0 && !SavedResult){SavedResult=true;SavegameManager.GetManager().DoSave(0,"CA446 persisted rating result");return;}
        if(Complete)return;
        if(Phase==7 && !Restored && consoleplayer==0 && !Saved){Saved=true;SavegameManager.GetManager().DoSave(0,"CA446 active ranked match");return;}
        let user=CaelumPlayer(players[consoleplayer].mo);let link=CaelumCardSeat.Read(user);if(link==null)return;int serial=link.LastSerial;
        if(SentAny && SentSerial==serial)return;int op=-1,arg=0;String eventName="ca_card_table";
        if(Phase==1 && consoleplayer==0){op=CaelumCardDuel.CONSENT;arg=1;}
        else if(Phase==2 && consoleplayer==0)op=CaelumCardDuel.SELECT_GAME;
        else if(Phase==3 && consoleplayer==0){op=CaelumCardDuel.SELECT_TEAM_SIZE;arg=PEERS;}
        else if(Phase==4 && consoleplayer==0)op=MODE==2?CaelumCardDuel.SELECT_RANKED:CaelumCardDuel.SELECT_CONSEQUENCES;
        else if(Phase==6 && Duel!=null)
        {int next=0;while(next<PEERS && (Duel.Accepted&(1<<next))!=0)next++;if(consoleplayer==next)op=CaelumCardDuel.CONSENT;}
        else if(Phase==8 && consoleplayer==1){op=CaelumTrucazoRules.FORFEIT;eventName="ca_tc2";}
        if(op>=0 && SentPhase!=Phase){SentAny=true;SentSerial=serial;SentPhase=Phase;SendNetworkEvent(eventName,op,arg,serial);}
    }
    override void WorldTick()
    {
        if(Complete || level.maptime<105)return;
        if(DISCONNECT!=0 && Phase==7 && !Restored && !playeringame[PEERS-1])
        {if(!Duel.Suspended)return;Check(!Duel.Finished() && (Duel.Competitive==null || !Duel.Competitive.Applied),"disconnect never awards a ranked victory or loss");Complete=true;Console.Printf("CA446 RESULT %s checks=%d disconnected",Failures==0?"PASS":"FAIL",Checks);return;}
        for(int i=0;i<PEERS;i++)if(!playeringame[i] || !CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        let a=CaelumPlayer(players[0].mo);
        if(Phase==0)
        {
            Check(CaelumDiningWorld.Place(1446,(0,512,0),3),"production large table placed");Table=CaelumDiningWorld.Find(1446);if(Table==null){Complete=true;return;}
            for(int i=0;i<PEERS;i++)
            {
                let user=CaelumPlayer(players[i].mo);let chair=Table.Chairs[i];vector3 away=chair.Pos-Table.Pos;user.SetOrigin(chair.Pos+away*(48/Max(1.0,away.Length())),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,60,chair) && CaelumCardSeat.Interact(user),"native player sits and opens table");
                let record=user.GetPersistentCharacterState(true);Check(record.TrucazoRatingRevision==0 && CaelumTrucazoCompetitive.Rating(user)==1000,"legacy personal record reads initial rating without changing itself");
                record.EnsureTrucazoRating();record.TrucazoRating=1037;record.EnsureTrucazoRating();Check(record.TrucazoRating==1037,"rating migration is idempotent");record.TrucazoRating=1000;
                let choice=CaelumTrucazoChoice.Get(user);for(int c=0;c<22;c++)choice.Selected[c]=false;
                Money[i]=user.GetOwnedMoneyCopperValue();OriginalRating[i]=CaelumTrucazoCompetitive.Rating(user);
            }
            CaelumPlayer(players[PEERS-1].mo).GiveInventoryType('CaelumTarotDeck');Phase=1;return;
        }
        if(Phase==1 && CaelumCardSeat.Session(a)!=null){Duel=CaelumCardSeat.Session(a);Phase=2;}
        else if(Phase==2 && Duel.Game==CaelumCardDuel.GAME_TRUCAZO)Phase=3;
        else if(Phase==3 && Duel.TeamMode){if(MODE==0){Rules();Phase=6;}else Phase=4;}
        else if(Phase==4 && (MODE==2?Duel.Ranked:Duel.Consequences)){Rules();Phase=6;}
        else if(Phase==6 && Duel.Started)
        {Check(Duel.Accepted==Duel.FullMask() && (Duel.Competitive!=null)==(MODE==2),"every native member consents to the exact mode before its result ledger exists");SavedState=State();Phase=7;Console.Printf("CA446 RESULT %s checks=%d fresh mode=%d",Failures==0?"PASS":"FAIL",Checks,MODE);}
        else if(Phase==7 && Restored && level.time>=RestoreStamp+105)
        {Check(State()==SavedState && (Duel.Competitive==null || !Duel.Competitive.Applied),"common checkpoint retains exact ranked attributes hands deck and unapplied rating result");Phase=8;}
        else if(Phase==8 && Duel.Finished())Result();
    }
}
