// #443: la interfaz sólo consulta su mano; las solicitudes se validan en simulación.
class CaelumTrucazoGameMenu : ListMenu
{
    int Focus,CardCursor,Details,SelectedMajor,PublicSeat,SentSerial,CachedSerial;
    Array<int> Actions,Arguments;
    Array<String> Labels;
    CaelumMenuPointer Pointer;
    static String L(String key){return StringTable.Localize(key,false);}
    static CaelumPlayer User(){return consoleplayer<0?null:CaelumPlayer(players[consoleplayer].mo);}
    static CaelumTrucazoGame Game()
    {let link=CaelumCardSeat.Read(User());return link==null || !link.Open || link.Duel==null?null:link.Duel.Advanced;}
    static int Seat(){let game=Game();return game==null?-1:game.Duel.Side(User());}
    static String Person(int seat){return String.Format(L("CA_TC2_SEAT_TEAM"),seat+1,seat%2==0?"A":"B");}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;SentSerial=-1;CachedSerial=-1;Pointer=new('CaelumMenuPointer');}
    void Add(int operation,int argument,String text){Actions.Push(operation);Arguments.Push(argument);Labels.Push(text);}
    void Build()
    {
        let g=Game();int s=Seat();if(g==null || s<0)return;
        if(CachedSerial==g.Serial)return;CachedSerial=g.Serial;
        Actions.Clear();Arguments.Clear();Labels.Clear();
        if(g.Finished())
        {Details=0;Add(CaelumTrucazoRules.CLOSE,0,L("CA_CARD_CLOSE"));return;}
        if(g.Duel.Suspended || g.Duel.Paused)
        {
            Details=0;
            if(g.Duel.Connected() && g.Duel.AllSeated())Add(CaelumTrucazoGame.PAUSE_VOTE,0,L((g.Duel.ResumeVotes&(1<<s))!=0?"CA_TC2_UNVOTE":"CA_TC2_RESUME"));
            Add(CaelumTrucazoRules.CLOSE,0,L("CA_CARD_CLOSE"));return;
        }
        if(Details==4)
        {Add(CaelumTrucazoRules.FORFEIT,0,L("CA_TC_CONFIRM"));Add(-1,0,L("CA_TC_RETURN"));return;}
        if(Details==5)
        {for(int i=0;i<g.Count();i++)Add(-30,i,Person(i));Add(-1,0,L("CA_TC_RETURN"));return;}
        if(Details==1)
        {
            for(int c=0;c<22;c++)if(g.Seats[s].Selected[c] && !g.Seats[s].Spent[c] && !(c==21 && g.Seats[s].WorldSpent))Add(-20,c,CaelumTrucazoData.Name(c));
            Add(-1,0,L("CA_TC_RETURN"));return;
        }
        if(Details==2 || Details==3)
        {
            int c=SelectedMajor;let own=g.Seats[s].Cards;
            if(Details==3 || c==9)
            {
                for(int target=0;target<g.Count();target++)if(g.Team(target)!=g.Team(s))for(int card=22;card<78;card++)if(CaelumTrucazoRules.Playable(card))
                {
                    int arg=target*78+card;
                    bool legal=Details==3?g.SensesEnabled && g.MayUseMagic(s) && g.Phase==CaelumTrucazoGame.PLAYING && !g.Seats[s].SenseSpent && !g.Seats[target].Active[2]:g.ValidMajor(s,c,arg);
                    if(legal)Add(Details==3?CaelumTrucazoGame.SENSE:CaelumTrucazoGame.MAJOR_BASE+c,arg,Person(target)..": "..CaelumTrucazoRules.CardName(card));
                }
            }
            else if(c==20)
            {
                for(int target=0;target<g.Count();target++)for(int effect=0;effect<22;effect++)
                    if(g.ValidMajor(s,c,target*22+effect))Add(CaelumTrucazoGame.MAJOR_BASE+c,target*22+effect,Person(target)..": "..CaelumTrucazoData.Name(effect));
            }
            else if(c==1)
            {
                for(int a=0;a<int(own.FirstRow.Size());a++)for(int b=0;b<int(own.SecondRow.Size());b++)
                    if(g.ValidMajor(s,c,a*100+b))Add(CaelumTrucazoGame.MAJOR_BASE+c,a*100+b,CaelumTrucazoRules.CardName(own.FirstRow[a]).." / "..CaelumTrucazoRules.CardName(own.SecondRow[b]));
            }
            else if(c==0 || c==12)
            {
                int n=c==0?int(own.Hand.Size()):int(own.FirstRow.Size());
                for(int i=0;i<n;i++)if(g.ValidMajor(s,c,i))Add(CaelumTrucazoGame.MAJOR_BASE+c,i,CaelumTrucazoRules.CardName(c==0?own.Hand[i]:own.FirstRow[i]));
            }
            else if(g.ValidMajor(s,c,0))Add(CaelumTrucazoGame.MAJOR_BASE+c,0,L("CA_TC2_USE"));
            Add(-1,0,L("CA_TC_RETURN"));return;
        }
        if(g.QuerySeat>=0 && g.QueryTarget==s)
        {Add(CaelumTrucazoGame.ANSWER_YES,0,L("CA_TC2_YES"));Add(CaelumTrucazoGame.ANSWER_NO,0,L("CA_TC2_NO"));}
        if(g.Window && g.QuerySeat<0 && g.Priority==s)Add(CaelumTrucazoGame.PASS,0,L("CA_TC2_PASS"));
        if(g.CanNormal(s,CaelumTrucazoRules.PLAY_CARD,CardCursor))Add(CaelumTrucazoRules.PLAY_CARD,CardCursor,L("CA_TC_PLAY"));
        if(g.CanNormal(s,CaelumTrucazoRules.ACCEPT))Add(CaelumTrucazoRules.ACCEPT,0,L("CA_TC_ACCEPT"));
        if(g.CanNormal(s,CaelumTrucazoRules.REFUSE))Add(CaelumTrucazoRules.REFUSE,0,L("CA_TC_REFUSE"));
        if(g.CanNormal(s,CaelumTrucazoRules.TRUCO))Add(CaelumTrucazoRules.TRUCO,0,L(g.TrucoValue<2?"CA_TC_TRUCO":g.TrucoValue==2?"CA_TC_RETRUCO":"CA_TC_VALE4"));
        if(g.CanNormal(s,CaelumTrucazoRules.ENVIDO))Add(CaelumTrucazoRules.ENVIDO,0,L("CA_TC_ENVIDO"));
        if(g.CanNormal(s,CaelumTrucazoRules.REAL_ENVIDO))Add(CaelumTrucazoRules.REAL_ENVIDO,0,L("CA_TC_REAL"));
        if(g.CanNormal(s,CaelumTrucazoRules.ADVANCE))Add(CaelumTrucazoRules.ADVANCE,0,L("CA_TC_NEXT"));
        if(g.MagicEnabled && g.MayUseMagic(s))Add(-2,0,L("CA_TC2_MAJORS"));
        if(g.SensesEnabled && g.MayUseMagic(s) && !g.Seats[s].SenseSpent && g.Phase==CaelumTrucazoGame.PLAYING)Add(-3,0,L("CA_TC2_SENSES"));
        if(g.MagicEnabled)Add(CaelumTrucazoGame.AUTO_PASS,0,L(g.Seats[s].AutoPass?"CA_TC2_AUTO_ON":"CA_TC2_AUTO_OFF"));
        Add(-5,0,L("CA_TC2_PUBLIC_ROWS"));
        Add(CaelumTrucazoGame.PAUSE_VOTE,0,L((g.Duel.PauseVotes&(1<<s))!=0?"CA_TC2_UNVOTE":"CA_TC2_PAUSE"));
        Add(-4,0,L("CA_TC_FORFEIT"));Focus=Clamp(Focus,0,Max(0,int(Actions.Size())-1));
    }
    void Choose()
    {
        Build();if(Actions.Size()==0)return;Focus=Clamp(Focus,0,int(Actions.Size())-1);
        int op=Actions[Focus],arg=Arguments[Focus];
        if(op==-1)Details=0;else if(op==-2)Details=1;else if(op==-3)Details=3;else if(op==-4)Details=4;
        else if(op==-5)Details=5;else if(op==-30)PublicSeat=arg;
        else if(op==-20){SelectedMajor=arg;Details=2;}
        else
        {
            let g=Game();if(g==null || SentSerial==g.Serial)return;
            SentSerial=g.Serial;EventHandler.SendNetworkEvent("ca_tc2",op,arg,g.Serial);Details=0;
        }
        Focus=0;CachedSerial=-1;
    }
    override void Ticker()
    {
        let g=Game();if(g==null){Close();return;}
        if(g.Duel.Suspended)CachedSerial=-1;
        int s=Seat();if(s<0){Close();return;}
        CardCursor=Clamp(CardCursor,0,Max(0,int(g.Seats[s].Cards.Hand.Size())-1));Build();
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        Build();int n=Max(1,int(Actions.Size()));
        if(key==MKEY_Up)Focus=(Focus+n-1)%n;else if(key==MKEY_Down)Focus=(Focus+1)%n;
        else if(key==MKEY_Enter)Choose();
        else if(key==MKEY_Back){Details=Details==0?4:0;Focus=0;CachedSerial=-1;}
        else if(key==MKEY_Left || key==MKEY_Right)
        {
            let g=Game();if(g!=null){int count=Max(1,int(g.Seats[Seat()].Cards.Hand.Size()));CardCursor=(CardCursor+count+(key==MKEY_Left?-1:1))%count;CachedSerial=-1;}
        }
        return true;
    }
    override bool MouseEvent(int type,int x,int y)
    {
        let g=Game();if(g==null)return true;Build();Pointer.Clear();
        Pointer.Move(((x-CaelumTrucazoMenu.UILeft())/CaelumTrucazoMenu.UIScale(),(y-CaelumTrucazoMenu.UITop())/CaelumTrucazoMenu.UIScale()));
        int first=(Focus/10)*10;
        for(int i=first;i<Min(first+10,int(Actions.Size()));i++)Pointer.Add(100+i,562,110+(i-first)*27,220,27);
        if(Actions.Size()>10){Pointer.Add(5000,562,425,105,32);Pointer.Add(5001,675,425,105,32);}
        for(int i=0;i<int(g.Seats[Seat()].Cards.Hand.Size());i++)Pointer.Add(1+i,22+i*105,350,92,120);
        int hit=Pointer.Hit();if(hit>=100 && hit<5000)Focus=hit-100;else if(hit>0 && hit<100){CardCursor=hit-1;CachedSerial=-1;}
        if(type==MOUSE_Click)Pointer.Press(g.Serial);
        else if(type==MOUSE_Release)
        {int operation=Pointer.Release(g.Serial);if(operation>=5000)Focus=Clamp(first+(operation==5000?-10:10),0,int(Actions.Size())-1);else if(operation>=100){Focus=operation-100;Choose();}}
        return true;
    }
    String Status(CaelumTrucazoGame g)
    {
        if(g.Duel.Suspended)return L("CA_TC2_SUSPENDED");
        if(g.Duel.Paused)return L("CA_TC2_PAUSED");
        if(g.Finished())return L(g.Winner==g.Team(Seat())?"CA_TC_WIN":"CA_TC_LOSS");
        if(g.QuerySeat>=0)return String.Format(L("CA_TC2_QUESTION"),Person(g.QuerySeat),Person(g.QueryTarget),CaelumTrucazoRules.CardName(g.QueryCard));
        if(g.Stack.Size()>0){let effect=g.Stack[g.Stack.Size()-1];return String.Format(L("CA_TC2_RESPONSE"),Person(g.Priority),Person(effect.Seat),CaelumTrucazoData.Name(effect.Card));}
        if(g.Window)return String.Format(L(g.Phase==CaelumTrucazoGame.PREPARATION?"CA_TC2_PREPARATION":"CA_TC2_PRIORITY"),Person(g.Priority));
        if(g.Phase==CaelumTrucazoGame.HAND_RESULT)return String.Format(L("CA_TC2_DAMAGE"),g.Damage[0],g.Damage[1]);
        if(g.Phase==CaelumTrucazoGame.TRICK_RESULT)return String.Format(L("CA_TC_TRICK_WIN"),Person(g.Turn));
        if(g.Pending!=0)return String.Format(L("CA_TC2_CALL"),Person(g.Caller),L(g.Pending==CaelumTrucazoRules.ENVIDO_CALL?"CA_TC_ENVIDO":g.Bid==2?"CA_TC_TRUCO":g.Bid==3?"CA_TC_RETRUCO":"CA_TC_VALE4"),g.Bid,Person(g.Responder));
        return String.Format(L("CA_TC_TURN"),Person(g.Turn));
    }
    override void Drawer()
    {
        let g=Game();int s=Seat();if(g==null || s<0)return;Build();
        Screen.Dim(0x080E12,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucazoMenu.Text(22,18,L("CA_CARD_TRUCAZO").." — "..Person(s),Font.CR_GOLD);
        CaelumTrucazoMenu.Text(22,42,String.Format(L("CA_TC2_HEALTH"),g.Health[0],g.Maximum[0],g.Health[1],g.Maximum[1]));
        CaelumTrucazoMenu.Wrap(22,66,750,Status(g),Font.CR_YELLOW);
        int votes=0,mask=g.Duel.Paused || g.Duel.Suspended?g.Duel.ResumeVotes:g.Duel.PauseVotes;
        for(int i=0;i<g.Count();i++)if((mask&(1<<i))!=0)votes++;
        if(votes>0)CaelumTrucazoMenu.Text(566,80,String.Format(L("CA_TC2_VOTES"),votes,g.Count()),Font.CR_GOLD);
        if(Details==4)CaelumTrucazoMenu.Wrap(22,125,510,L("CA_TC2_FORFEIT"));
        else if(Details==2)CaelumTrucazoMenu.Wrap(22,125,510,L(String.Format("CA_TC2_EFFECT_%d",SelectedMajor)));
        else if(Details==5)
        {
            let shown=g.Seats[PublicSeat];
            String attack="",defense="",effects="";
            for(int i=0;i<int(shown.Cards.FirstRow.Size());i++)attack=attack..CaelumTrucazoRules.CardName(shown.Cards.FirstRow[i]).." / ";
            for(int i=0;i<int(shown.Cards.SecondRow.Size());i++)defense=defense..CaelumTrucazoRules.CardName(shown.Cards.SecondRow[i]).." / ";
            for(int c=0;c<22;c++)if(shown.Active[c])effects=effects..CaelumTrucazoData.Name(c).." / ";
            CaelumTrucazoMenu.Text(22,110,Person(PublicSeat),Font.CR_GOLD);
            CaelumTrucazoMenu.Wrap(22,140,510,L("CA_TC2_ATTACK_ROW")..attack);
            CaelumTrucazoMenu.Wrap(22,196,510,L("CA_TC2_DEFENSE_ROW")..defense);
            CaelumTrucazoMenu.Wrap(22,252,510,L("CA_TC2_ACTIVE")..effects);
        }
        else
        {
            if(g.Seats[s].PrivateKey!="")CaelumTrucazoMenu.Wrap(22,116,510,Person(g.Seats[s].PrivateTarget).." / "..CaelumTrucazoRules.CardName(g.Seats[s].PrivateCard)..": "..L(g.Seats[s].PrivateKey),Font.CR_GREEN);
            if(g.PublicKey=="CA_TC2_ANSWER")CaelumTrucazoMenu.Wrap(22,152,510,Person(g.PublicSeat).." / "..CaelumTrucazoRules.CardName(g.PublicCard)..": "..L(g.PublicAnswer!=0?"CA_TC2_YES":"CA_TC2_NO"));
            if(g.Window && g.RootOperation==CaelumTrucazoRules.PLAY_CARD)
            {
                String announced=g.Seats[g.RootSeat].Active[18]?L("CA_TC2_FACE_DOWN"):CaelumTrucazoRules.CardName(g.Seats[g.RootSeat].Cards.Hand[g.RootArgument]);
                CaelumTrucazoMenu.Wrap(22,182,510,Person(g.RootSeat)..": "..announced,Font.CR_GOLD);
            }
            else if(g.Window && g.RootOperation>=0)
            {
                String label=g.RootOperation==CaelumTrucazoRules.TRUCO?L(g.TrucoValue<2?"CA_TC_TRUCO":g.TrucoValue==2?"CA_TC_RETRUCO":"CA_TC_VALE4"):
                    L(g.RootOperation==CaelumTrucazoRules.ENVIDO?"CA_TC_ENVIDO":g.RootOperation==CaelumTrucazoRules.REAL_ENVIDO?"CA_TC_REAL":g.RootOperation==CaelumTrucazoRules.ACCEPT?"CA_TC_ACCEPT":"CA_TC_REFUSE");
                CaelumTrucazoMenu.Wrap(22,182,510,Person(g.RootSeat)..": "..label,Font.CR_GOLD);
            }
        }
        for(int i=0;Details!=5 && i<g.Count();i++)
        {
            double x=22+i*(510.0/g.Count());
            CaelumTrucazoMenu.Text(x,218,g.Count()>4?String.Format("%d %s",i+1,g.Team(i)==0?"A":"B"):Person(i),Font.CR_GRAY);
            if(g.Seats[i].Played>=0)CaelumTrucazoMenu.Card(g.HiddenPlayed(i)&&i!=s?-1:g.Seats[i].Played,x,238,55,75);
        }
        let own=g.Seats[s].Cards;
        CaelumTrucazoMenu.Text(22,328,L("CA_TC_YOUR_HAND"),Font.CR_GOLD);
        for(int i=0;i<int(own.Hand.Size());i++)
        {CaelumTrucazoMenu.Card(own.Hand[i],22+i*105,350,92,120,own.Used[i]?0.25:1);if(i==CardCursor)CaelumTrucazoMenu.Text(22+i*105,475,L("CA_TC_SELECTED"),Font.CR_GOLD);}
        CaelumTrucazoMenu.Wrap(22,505,510,String.Format(L("CA_TC2_ROWS"),g.Row(s,true),g.Row(s,false),g.Envido(s)));
        CaelumTrucazoMenu.Wrap(22,540,510,L("CA_TC2_CONTROLS"),Font.CR_GRAY);
        int first=(Focus/10)*10;
        for(int i=first;i<Min(first+10,int(Actions.Size()));i++)CaelumTrucazoMenu.Text(566,114+(i-first)*27,(Focus==i?"> ":"  ")..Labels[i],Focus==i?Font.CR_GOLD:Font.CR_WHITE);
        CaelumTrucazoMenu.Text(566,400,String.Format("%d / %d",Focus+1,int(Actions.Size())),Font.CR_GRAY);
        if(Actions.Size()>10){CaelumTrucazoMenu.Text(566,430,"<",Font.CR_GOLD);CaelumTrucazoMenu.Text(680,430,">",Font.CR_GOLD);}
    }
}
