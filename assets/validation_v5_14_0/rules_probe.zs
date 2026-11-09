// Isolated native assertions; values below are test fixtures, not gameplay balance.
class CA590NetworkProbe : EventHandler
{
    bool Complete;int Failures,Checks;
    CaelumCardDuel Duel;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA443 %s %s",okay?"PASS":"FAIL",label);}
    CaelumTrucazoGame Seed(bool prep=false)
    {
        let g=new('CaelumTrucazoGame');g.Duel=Duel;g.MagicEnabled=true;g.SensesEnabled=true;
        g.Phase=prep?CaelumTrucazoGame.PREPARATION:CaelumTrucazoGame.PLAYING;
        g.RootOperation=-1;g.QuerySeat=-1;g.HandNumber=1;g.TrucoValue=2;g.TrucoRight=-1;g.SuspendedCaller=-1;
        for(int i=0;i<2;i++)
        {
            let s=new('CaelumTrucazoSeatState');s.Cards=new('CaelumTrucazoSide');s.Played=-1;s.Insight=10;
            s.Cards.Hand.Push(22);s.Cards.Hand.Push(23);s.Cards.Hand.Push(24);
            s.Cards.FirstRow.Push(29);s.Cards.SecondRow.Push(30);s.Cards.Intelligence=10;
            s.BaseEnvido=s.Cards.EnvidoValue();for(int c=0;c<22;c++)s.Selected[c]=true;
            g.Seats.Push(s);g.Health[i]=100;g.Maximum[i]=100;
        }
        g.Deck.Push(31);g.Deck.Push(50);g.Deck.Push(64);return g;
    }
    void Drain(CaelumTrucazoGame g)
    {
        int limit=200;
        while(g.Window && limit-->0)if(!g.Act(g.Priority,CaelumTrucazoGame.PASS))break;
        Check(!g.Window && limit>0,"priority windows terminate without timers");
    }
    void Use(CaelumTrucazoGame g,int card,int arg=0)
    {Check(g.Act(0,CaelumTrucazoGame.MAJOR_BASE+card,arg),String.Format("Major %d legal activation",card));Drain(g);}
    void Rules()
    {
        let g=Seed(true);Use(g,0,1);Check(g.Seats[0].Cards.Hand[1]==50 && g.Discards[0]==23 && g.Seats[0].Cards.SecondRow[1]==31 && g.Drawn==2,"Fool replaces one card and routes nonplayable draw to defense");
        g=Seed(true);Use(g,1);Check(g.Seats[0].Cards.FirstRow[0]==30 && g.Seats[0].Cards.SecondRow[0]==29,"Magician exchanges exact row identities");
        g=Seed();Use(g,2);g.Turn=1;Check(!g.Act(1,CaelumTrucazoGame.SENSE,22) && !g.ValidMajor(1,9,22),"Priestess blocks both kinds of private query");
        g=Seed();g.Health[0]=50;Use(g,3);g.FinishHand(0,1);Check(g.Health[0]==60,"Empress heals only victorious surviving team by ten percent");
        g=Seed();g.Seats[0].Cards.Hand[0]=23;g.Seats[1].Cards.Hand[0]=24;Use(g,4);g.Execute(0,CaelumTrucazoRules.PLAY_CARD,0);g.Execute(1,CaelumTrucazoRules.PLAY_CARD,0);Check(g.Turn==0,"Emperor advances one rank and mano wins resulting tie");
        g=Seed();g.Turn=1;Check(g.Act(1,CaelumTrucazoGame.MAJOR_BASE+11),"enemy queues Strength");Check(g.Act(0,CaelumTrucazoGame.MAJOR_BASE+5),"Hierophant responds outside own normal turn");Drain(g);Check(!g.Seats[1].Active[11] && g.Seats[1].Spent[11],"Hierophant cancels pending effect without returning spent use");
        g=Seed();int old=g.Envido(0);Use(g,6);Check(g.Envido(0)==old+2,"Lovers adds two individual Envido points");
        g=Seed();Use(g,7);g.Execute(0,CaelumTrucazoRules.PLAY_CARD,0);g.Execute(1,CaelumTrucazoRules.PLAY_CARD,1);Check(g.Points[0]==1,"Chariot grants one point for its winning card");
        g=Seed();g.Seats[1].Active[4]=true;g.Seats[0].Cards.Hand[0]=24;g.Seats[1].Cards.Hand[0]=23;g.Mano=1;Use(g,8);g.Execute(0,CaelumTrucazoRules.PLAY_CARD,0);g.Execute(1,CaelumTrucazoRules.PLAY_CARD,0);Check(g.Turn==0,"Justice removes magical rank improvement for whole trick");
        g=Seed();Use(g,9,78+22);Check(g.Seats[0].PrivateKey=="CA_TC2_HAS" && g.Seats[1].PrivateKey=="","Hermit reveals only requested card to requesting seat");
        g=Seed(true);g.Seats[0].Cards.FirstRow.Push(31);Use(g,10);Check(g.Seats[0].Cards.FirstRow.Size()==1 && g.Seats[0].Cards.SecondRow.Size()==2,"Wheel swaps complete rows");
        g=Seed();Use(g,11);Check(g.Row(0,true)==16.25,"Strength changes only owner attack row by 25 percent");
        g=Seed(true);Use(g,12);Check(g.Seats[0].Cards.FirstRow.Size()==0 && g.Seats[0].Cards.SecondRow[1]==29,"Hanged Man moves exact card without duplication");
        g=Seed();Use(g,13);g.FinishHand(1,2);Check(g.Damage[1]==11 && g.Health[0]==89,"Death rounds reduced loss damage after base calculation");
        g=Seed();Use(g,14);g.FinishHand(1,3);Check(g.Points[1]==2,"Temperance reduces accepted Truco points by one");
        g=Seed();Use(g,15);Check(g.Health[0]==95,"Devil pays five percent of team maximum");g.FinishHand(0,2);Check(g.Damage[0]==18,"Devil outgoing damage rounds once");
        g=Seed();g.Health[0]=5;Check(!g.Act(0,CaelumTrucazoGame.MAJOR_BASE+15) && !g.Seats[0].Spent[15],"Devil refuses lethal payment without consuming use");
        g=Seed();Use(g,16);Check(g.TeamRow(1,false)==10.5,"Tower reduces opposing combined defense");
        g=Seed(true);g.Health[0]=98;Use(g,17);Check(g.Health[0]==100,"Star caps healing at original maximum");
        g=Seed();Use(g,18);g.Execute(0,CaelumTrucazoRules.PLAY_CARD,0);Check(g.HiddenPlayed(0),"Moon hides played card before other commitments");g.Execute(1,CaelumTrucazoRules.PLAY_CARD,0);Check(!g.HiddenPlayed(0),"Moon reveals before completed trick outcome");
        g=Seed();Use(g,19);g.ResolveEnvido(0,2);Check(g.Points[0]==3,"Sun adds one winning Envido point");
        g=Seed();g.Seats[1].Active[11]=true;Use(g,20,22+11);Check(!g.Seats[1].Active[11],"Judgement dispels one opposing persistent effect");
        g=Seed();Use(g,21);Check(g.Seats[0].WorldSpent,"World records once-per-match use");g.Deal();Check(!g.ValidMajor(0,21,0),"World stays spent across the next deal");
        g=Seed();Check(!g.Act(0,CaelumTrucazoGame.MAJOR_BASE+1,-1),"negative row arguments rejected");g.Phase=CaelumTrucazoGame.PREPARATION;g.Deck.Clear();Check(!g.Act(0,CaelumTrucazoGame.MAJOR_BASE,0) && !g.Seats[0].Spent[0],"empty deck does not consume Fool");
        g=Seed();Use(g,11);Check(!g.Act(0,CaelumTrucazoGame.MAJOR_BASE+11),"same card cannot be replayed within hand");
        g=Seed();g.Seats[1].Insight=0;Check(g.Act(0,CaelumTrucazoGame.SENSE,78+22),"Sense query validates exact rival and card");Check(!g.Act(0,CaelumTrucazoGame.ANSWER_NO),"query owner cannot answer for rival");Check(g.Act(1,CaelumTrucazoGame.ANSWER_NO) && g.Seats[0].PrivateKey=="CA_TC2_LIE" && g.Seats[1].PrivateKey=="","zero defending Insight detects lie privately");Check(!g.Act(0,CaelumTrucazoGame.SENSE,78+23),"Sense query is once per hand");
        g=Seed();g.Seats[0].Insight=0;g.Act(0,CaelumTrucazoGame.SENSE,78+22);g.Act(1,CaelumTrucazoGame.ANSWER_YES);Check(g.Seats[0].PrivateKey=="CA_TC2_UNCLEAR","zero attacking Insight yields inconclusive against positive defense");
        g=Seed();g.Act(0,CaelumTrucazoRules.PLAY_CARD,0);g.Act(0,CaelumTrucazoGame.SENSE,78+22);g.Act(0,CaelumTrucazoGame.AUTO_PASS);g.Act(1,CaelumTrucazoGame.AUTO_PASS);
        Check(g.Window && g.QuerySeat==0 && !g.Seats[0].Cards.Used[0],"automatic passes cannot advance a pending Insight answer");
        g.Act(1,CaelumTrucazoGame.ANSWER_YES);Check(!g.Window && g.QuerySeat<0 && g.Seats[0].Cards.Used[0],"answer resumes automatic response exactly once");
        g=Seed();g.Pending=CaelumTrucazoRules.ENVIDO_CALL;g.RealCalled=true;g.Responder=0;Check(!g.CanNormal(0,CaelumTrucazoRules.ENVIDO),"Envido cannot be raised after Real Envido");
        g=Seed();g.MagicEnabled=false;g.Seats[0].Cards.SecondRow.Clear();g.Seats[1].Cards.SecondRow.Clear();g.FinishHand(0,2);Check(g.Damage[0]==25,"unmodified one-versus-one damage retains approved rounding");
        g=Seed();g.MagicEnabled=false;g.Health[0]=1;g.Health[1]=1;g.Points[0]=3;g.Points[1]=3;g.FinishHand(0,1);Check(g.Health[0]==0 && g.Health[1]==0 && g.Winner==0,"simultaneous double knockout uses mano team");
        let a=CaelumPlayer(players[0].mo),b=CaelumPlayer(players[1].mo);
        let actual=CaelumTrucazoGame.Create(Duel);bool seen[78];bool unique=true;int total=0;
        for(int i=0;i<actual.Count();i++)
        {
            let own=actual.Seats[i].Cards;Check(own.Hand.Size()>=3,"shared deal supplies minimum playable hand");
            for(int row=0;row<3;row++)
            {
                int n=row==0?int(own.Hand.Size()):row==1?int(own.FirstRow.Size()):int(own.SecondRow.Size());
                for(int j=0;j<n;j++){int card=row==0?own.Hand[j]:row==1?own.FirstRow[j]:own.SecondRow[j];if(seen[card])unique=false;seen[card]=true;total++;}
            }
        }
        for(int i=actual.Drawn;i<int(actual.Deck.Size());i++){int card=actual.Deck[i];if(seen[card])unique=false;seen[card]=true;total++;}
        Check(unique && total==56,"all dealt and remaining cards form exactly one 56-card deck");
        Duel.Advanced=actual;Duel.Started=true;
        Check(!CaelumTarotService.Activate(a),"world Tarot activation is rejected during card match");
        int oldSerial=Duel.Serial;
        Check(!Duel.DispatchAdvanced(a,CaelumTrucazoGame.PASS,0,oldSerial-1),"stale network revision cannot mutate match");
        Duel.Suspended=true;Check(!Duel.DispatchAdvanced(a,CaelumTrucazoRules.FORFEIT,0,Duel.Serial) && !actual.Finished(),"disconnect suspension cannot settle as voluntary defeat");Duel.Suspended=false;
    }
    override void WorldTick()
    {
        if(Complete || !playeringame[0] || !playeringame[1])return;
        let a=CaelumPlayer(players[0].mo),b=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(a) || !CaelumWorldClockTicker.Ready(b) || level.maptime<105)return;
        Complete=true;Duel=CaelumCardDuel(Actor.Spawn('CaelumCardDuel',a.Pos,NO_REPLACE));Duel.AttachToOwner(a);Duel.Participants[0]=a;Duel.Participants[1]=b;Duel.Majors=true;Duel.Senses=true;
        for(int i=0;i<2;i++){let link=CaelumCardSeat.Get(CaelumPlayer(players[i].mo));link.Duel=Duel;link.Open=false;}
        Rules();Console.Printf("CA443 RESULT %s checks=%d failures=%d",Failures==0?"PASS":"FAIL",Checks,Failures);
        Duel.Started=false;Duel.Release();
    }
}
