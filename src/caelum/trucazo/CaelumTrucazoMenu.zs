// El menú pausa el mundo, pero GZDoom procesa los mensajes validados en play.
// El controlador estático también existe al cargar saves anteriores al #81.
class CaelumTrucazoEvents : StaticEventHandler
{
    ui bool RestorePending;
    override void WorldLoaded(WorldEvent e)
    {
        if(e.IsSaveGame)EventHandler.SendInterfaceEvent(consoleplayer,"ca_trucazo_restore");
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_trucazo_restore")RestorePending=true;
    }
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let match=user==null?null:CaelumTrucazoMatch(user.FindInventory("CaelumTrucazoMatch"));
        // Un menú anterior no forma parte del save y puede sobrevivir a load.
        // Reponer la vista una vez también recupera la pausa nativa correcta.
        if(match!=null && match.Visible && (RestorePending || menuactive==0))Menu.SetMenu("CaelumTrucazoMenu");
        RestorePending=false;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_trucazo")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        if(user==null)return;
        let match=CaelumTrucazoMatch.Get(user);
        if(match!=null)match.Dispatch(e.Args[0],e.Args[1],e.Args[2]);
    }
}

class CaelumTrucazoMenu : ListMenu
{
    int CardCursor;
    int Focus;
    int Details;
    bool ConfirmForfeit;
    int SentSerial;
    Array<int> Operations;
    Array<String> Labels;

    static CaelumTrucazoMatch Match()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL)return null;
        let user=CaelumPlayer(players[consoleplayer].mo);
        return user==null?null:CaelumTrucazoMatch(user.FindInventory("CaelumTrucazoMatch"));
    }
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;SentSerial=-1;
        // La conversación ha terminado: cerrar Trucazo vuelve al mundo.
        mParentMenu=null;menuactive=Menu.On;
    }
    static String L(String key) { return StringTable.Localize(key,false); }
    static String Person(int side) {return L(side==0?"CA_TC_YOU":"CA_ARGENTO_NAME");}
    void Send(int operation,int index=0)
    {
        let match=Match();
        if(match==null || SentSerial==match.Serial)return;
        SentSerial=match.Serial;
        EventHandler.SendNetworkEvent("ca_trucazo",operation,index,match.Serial);
    }
    void Add(int operation,String label)
    {
        let match=Match();
        if(operation>=0 && !match.CanAct(0,operation,CardCursor))return;
        Operations.Push(operation);Labels.Push(label);
    }
    void Choices()
    {
        Operations.Clear();Labels.Clear();
        let match=Match();if(match==null)return;
        if(ConfirmForfeit)
        {Add(CaelumTrucazoRules.FORFEIT,L("CA_TC_CONFIRM"));Add(-4,L("CA_TC_RETURN"));return;}
        if(Details>0){Add(-1,L("CA_TC_RETURN"));return;}
        Add(CaelumTrucazoRules.BEGIN,L("CA_TC_BEGIN"));
        Add(CaelumTrucazoRules.ACCEPT,L("CA_TC_ACCEPT"));
        Add(CaelumTrucazoRules.REFUSE,L("CA_TC_REFUSE"));
        Add(CaelumTrucazoRules.PLAY_CARD,L("CA_TC_PLAY"));
        int bid=match.Pending==CaelumTrucazoRules.TRUCO_CALL?match.Bid:match.TrucoValue;
        Add(CaelumTrucazoRules.TRUCO,L(bid<2?"CA_TC_TRUCO":bid==2?"CA_TC_RETRUCO":"CA_TC_VALE4"));
        Add(CaelumTrucazoRules.ENVIDO,L("CA_TC_ENVIDO"));
        Add(CaelumTrucazoRules.REAL_ENVIDO,L("CA_TC_REAL"));
        Add(CaelumTrucazoRules.ADVANCE,L("CA_TC_NEXT"));
        Add(-1,L("CA_TC_RULES"));
        if(match.HandNumber>0)Add(-2,L("CA_TC_ROWS"));
        Add(-5,L("CA_TC_SAVE"));Add(-6,L("CA_TC_LOAD"));
        if(match.Active())Add(-3,L("CA_TC_FORFEIT"));
        else Add(CaelumTrucazoRules.CLOSE,L("CA_TC_CLOSE"));
        Focus=Clamp(Focus,0,Max(0,int(Operations.Size())-1));
    }
    override void Ticker()
    {
        let match=Match();
        if(match==null || !match.Visible){Close();return;}
        menuactive=Menu.On;
        if(match.HandNumber>0)
        {
            CardCursor=Clamp(CardCursor,0,Max(0,int(match.Sides[0].Hand.Size())-1));
            if(match.Sides[0].Used[CardCursor])MoveCard(1);
        }
        Choices();
        // Sólo un paso pendiente por revisión evita dobles jugadas por FPS.
        if(match.Phase==CaelumTrucazoRules.PLAYING
            && (match.Pending!=0?match.Caller==0:match.Turn==1))Send(CaelumTrucazoRules.NPC_STEP);
    }
    void MoveCard(int direction)
    {
        let match=Match();if(match==null || match.HandNumber==0)return;
        int count=match.Sides[0].Hand.Size();
        for(int step=0;step<count;step++)
        {
            CardCursor=(CardCursor+direction+count)%count;
            if(!match.Sides[0].Used[CardCursor])break;
        }
    }
    void Choose()
    {
        Choices();if(Operations.Size()==0)return;
        int operation=Operations[Focus];
        if(operation==-1){Details=Details>0?0:1;Focus=0;}
        else if(operation==-2){Details=2;Focus=0;}
        else if(operation==-3){ConfirmForfeit=true;Focus=0;}
        else if(operation==-4){ConfirmForfeit=false;Focus=0;}
        else if(operation==-5)Menu.SetMenu("SaveGameMenu");
        else if(operation==-6)Menu.SetMenu("LoadGameMenu");
        else {ConfirmForfeit=false;Send(operation,CardCursor);Focus=0;}
    }
    override bool MenuEvent(int mkey,bool fromcontroller)
    {
        Choices();
        if(mkey==MKEY_Left)MoveCard(-1);
        else if(mkey==MKEY_Right)MoveCard(1);
        else if(mkey==MKEY_Up)Focus=(Focus-1+Operations.Size())%Max(1,int(Operations.Size()));
        else if(mkey==MKEY_Down)Focus=(Focus+1)%Max(1,int(Operations.Size()));
        else if(mkey==MKEY_Enter)Choose();
        else if(mkey==MKEY_Back)
        {
            if(Details>0){Details=0;Focus=0;}
            else if(ConfirmForfeit){ConfirmForfeit=false;Focus=0;}
            else if(Match()!=null && Match().Active()){ConfirmForfeit=true;Focus=0;}
            else Send(CaelumTrucazoRules.CLOSE);
        }
        return true;
    }
    override bool OnUIEvent(UIEvent e)
    {
        if(e.Type==UIEvent.Type_KeyDown)
        {
            if(e.KeyChar==113 || e.KeyChar==81)return MenuEvent(MKEY_Back,false);
            if(e.KeyChar>=49 && e.KeyChar<=53)
            {
                let match=Match();int index=e.KeyChar-49;
                if(match!=null && match.HandNumber>0 && index<int(match.Sides[0].Hand.Size())
                    && !match.Sides[0].Used[index])CardCursor=index;
                return true;
            }
        }
        return Super.OnUIEvent(e);
    }
    // Dibujo en coordenadas virtuales: las cartas nunca se deforman para llenar
    // una relación de pantalla distinta. La entrada usa menú/teclado nativos.
    static double UIScale() {return Min(Screen.GetWidth()/800.0,Screen.GetHeight()/600.0);}
    static double UILeft() {return (Screen.GetWidth()-800*UIScale())/2;}
    static double UITop() {return (Screen.GetHeight()-600*UIScale())/2;}
    static void Text(double x,double y,String value,int color=Font.CR_WHITE)
    {
        Screen.DrawText(Font.GetFont("CaelumSmall"),color,UILeft()+x*UIScale(),UITop()+y*UIScale(),value,
            DTA_SCALEX,UIScale(),DTA_SCALEY,UIScale(),DTA_SHADOW,true);
    }
    static void Wrap(double x,double y,double width,String value,int color=Font.CR_WHITE)
    {
        let lines=Font.GetFont("CaelumSmall").BreakLines(value,int(width));
        for(int line=0;line<lines.Count();line++)Text(x,y+line*16,lines.StringAt(line),color);
        lines.Destroy();
    }
    static void Card(int card,double x,double y,double width,double height,double alpha=1)
    {
        let texture=TexMan.CheckForTexture(card<0?CaelumTarotArt.BackPath():CaelumTarotArt.FrontPath(card),TexMan.Type_Any);
        if(!texture.IsValid())return;
        let size=TexMan.GetScaledSize(texture);
        double scale=Min(width/size.X,height/size.Y);
        Screen.DrawTexture(texture,true,UILeft()+(x+(width-size.X*scale)/2)*UIScale(),UITop()+y*UIScale(),
            DTA_DESTWIDTHF,size.X*scale*UIScale(),DTA_DESTHEIGHTF,size.Y*scale*UIScale(),DTA_ALPHA,alpha);
    }
    String Status(CaelumTrucazoMatch match)
    {
        if(match.Phase==CaelumTrucazoRules.INTRO)return L("CA_TC_INTRO");
        if(match.Phase==CaelumTrucazoRules.MATCH_RESULT)return L(match.Abandoned?"CA_TC_ABANDONED":match.Winner==0?"CA_TC_WIN":"CA_TC_LOSS");
        if(match.Phase==CaelumTrucazoRules.HAND_RESULT)return String.Format(L("CA_TC_HAND_WIN"),Person(match.Winner));
        if(match.Phase==CaelumTrucazoRules.TRICK_RESULT)return String.Format(L("CA_TC_TRICK_WIN"),Person(match.TrickVictors[match.Trick]));
        if(match.Pending!=0)return String.Format(L("CA_TC_PENDING"),Person(match.Caller),
            L(match.Pending==CaelumTrucazoRules.ENVIDO_CALL?"CA_TC_ENVIDO":match.Bid==2?"CA_TC_TRUCO":match.Bid==3?"CA_TC_RETRUCO":"CA_TC_VALE4"),match.Bid,match.RefusalPoints);
        return String.Format(L("CA_TC_TURN"),Person(match.Turn));
    }
    void DrawRows(CaelumTrucazoMatch match)
    {
        for(int side=0;side<2;side++)for(int row=0;row<2;row++)
        {
            double y=100+(side*2+row)*106;
            let own=match.Sides[side];
            Text(22,y,String.Format(L(row==0?"CA_TC_ROW_ATTACK":"CA_TC_ROW_DEFENSE"),Person(side),own.RowValue(row==0)),Font.CR_GOLD);
            int count=row==0?own.FirstRow.Size():own.SecondRow.Size();
            if(count==0)Text(22,y+26,L("CA_TC_EMPTY"));
            for(int i=0;i<count;i++)Card(row==0?own.FirstRow[i]:own.SecondRow[i],22+i*Min(70.0,510.0/Max(1,count)),y+20,60,78);
        }
    }
    override void Drawer()
    {
        let match=Match();if(match==null)return;
        Screen.Dim(0x080E12,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        Text(22,18,L("CA_TC_TITLE"),Font.CR_GOLD);
        Text(22,40,L("CA_TC_PRACTICE"),Font.CR_GRAY);
        Wrap(22,62,750,Status(match),Font.CR_YELLOW);
        Choices();
        if(ConfirmForfeit)Wrap(22,130,510,L("CA_TC_FORFEIT_HELP"));
        else if(Details==1 || match.Phase==CaelumTrucazoRules.INTRO)
        {
            Wrap(22,112,440,L("CA_TC_RULES_TEXT"));
            Wrap(22,374,440,L("CA_TC_RANKING"),Font.CR_GRAY);
        }
        else if(Details==2)DrawRows(match);
        else
        {
            let own=match.Sides[0];let other=match.Sides[1];
            Text(22,96,String.Format(L("CA_TC_HP"),Person(0),own.Health,own.MaximumHealth),Font.CR_GREEN);
            Text(294,96,String.Format(L("CA_TC_HP"),Person(1),other.Health,other.MaximumHealth),Font.CR_ORANGE);
            Text(22,118,String.Format(L("CA_TC_HAND_INFO"),match.HandNumber,match.Trick+1,Person(match.Mano),int(match.Deck.Size())-match.Drawn),Font.CR_GRAY);
            // Sólo el número de cartas rivales se usa; ni índice ni frente.
            for(int i=0;i<other.Remaining();i++)Card(-1,22+i*68,145,60,86);
            Text(370,153,String.Format(L("CA_TC_TRICKS"),own.Tricks,other.Tricks));
            Text(370,175,String.Format(L("CA_TC_STAKES"),match.TrucoValue));
            if(match.EnvidoSettled)
            {
                Text(370,197,String.Format(L("CA_TC_ENVIDO_AWARD"),Person(match.EnvidoWinner),match.EnvidoAward));
                if(match.EnvidoRevealed)Text(370,219,String.Format(L("CA_TC_ENVIDO_VALUES"),own.EnvidoValue(),other.EnvidoValue()));
            }
            Text(22,234,L("CA_TC_TABLE"),Font.CR_GRAY);
            for(int side=0;side<2;side++)
            {
                Text(80+side*212,248,Person(side),Font.CR_GRAY);
                if(match.Played[side]>=0)
                {
                    Card(match.Played[side],72+side*212,267,66,84);
                    Wrap(146+side*212,286,128,CaelumTrucazoRules.CardName(match.Played[side]));
                }
            }
            Text(22,368,L("CA_TC_YOUR_HAND"),Font.CR_GOLD);
            for(int i=0;i<int(own.Hand.Size());i++)
            {
                double x=22+i*105;
                Card(own.Hand[i],x,390,92,120,own.Used[i]?0.24:1);
                Text(x+37,513,String.Format("%d",i+1),i==CardCursor?Font.CR_GOLD:Font.CR_GRAY);
                if(i==CardCursor && !own.Used[i])Text(x+12,377,L("CA_TC_SELECTED"),Font.CR_GOLD);
            }
            Wrap(22,537,525,CaelumTrucazoRules.CardName(own.Hand[CardCursor]),Font.CR_GOLD);
            if(match.Phase==CaelumTrucazoRules.HAND_RESULT || match.Phase==CaelumTrucazoRules.MATCH_RESULT)
                Wrap(22,560,525,String.Format(L("CA_TC_DAMAGE"),own.Points,own.LastDamage,other.Points,other.LastDamage));
        }
        for(int i=0;i<int(Operations.Size());i++)
            Text(566,114+i*27,(Focus==i?"> ":"  ")..Labels[i],Focus==i?Font.CR_GOLD:Font.CR_WHITE);
        if(Details==0 && !ConfirmForfeit && match.HandNumber>0)
        {
            int first=Max(0,match.EventCount-3);
            for(int i=first;i<match.EventCount;i++)
                Wrap(566,410+(i-first)*42,212,EventText(match,i),Font.CR_GRAY);
        }
        Text(22,585,L("CA_TC_CONTROLS"),Font.CR_GRAY);
    }
    static String EventText(CaelumTrucazoMatch match,int index)
    {
        int kind=match.EventKind[index],who=match.EventSide[index],value=match.EventValue[index];
        if(kind==CaelumTrucazoRules.CARD_EVENT)return String.Format(L("CA_TC_EVENT_CARD"),Person(who),CaelumTrucazoRules.CardName(value));
        return String.Format(L(String.Format("CA_TC_EVENT_%d",kind)),Person(who),value);
    }
}
