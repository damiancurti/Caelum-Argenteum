// #446: reglas consultables aun cuando el panel lateral muestra la selección de Mayores.
class CaelumTrucazoRankedMenu : ListMenu
{
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;}
    override bool MenuEvent(int key,bool controller)
    {if(key==MKEY_Back || key==MKEY_Enter)Close();return true;}
    override bool MouseEvent(int type,int x,int y)
    {if(type==MOUSE_Release)Close();return true;}
    override void Ticker()
    {let duel=CaelumCardSeat.Session(CaelumCardTableMenu.User());if(duel==null || duel.Started)Close();}
    override void Drawer()
    {
        Screen.Dim(0x080E12,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucazoMenu.Text(22,24,CaelumCardTableMenu.L("CA_TC4_RANKED"),Font.CR_GOLD);
        CaelumTrucazoMenu.Wrap(22,90,730,CaelumCardTableMenu.L("CA_TC4_RULES"));
        CaelumTrucazoMenu.Wrap(22,240,730,CaelumCardTableMenu.L("CA_TC4_RATING_HELP"));
        CaelumTrucazoMenu.Text(22,520,CaelumCardTableMenu.L("CA_TC_RETURN"),Font.CR_GOLD);
    }
}
// #446: cuadro público; la elección de cartas continúa siendo privada e individual.
class CaelumTrucazoTournamentMenu : ListMenu
{
    int Focus,SentSerial;
    Array<int> Actions;
    Array<String> Labels;
    CaelumMenuPointer Pointer;
    static String L(String key){return StringTable.Localize(key,false);}
    static CaelumPlayer User(){return CaelumCardTableMenu.User();}
    static CaelumTrucazoTournament Tournament()
    {let link=CaelumCardSeat.Read(User());return link==null?null:link.Tournament;}
    static String Player(CaelumTrucazoTournament t,int seat)
    {return seat<0?"":String.Format(L("CA_TC4_PLAYER"),t.Slots[seat]+1);}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;SentSerial=-1;Pointer=new('CaelumMenuPointer');}
    void Add(int op,String key){Actions.Push(op);Labels.Push(L(key));}
    void Build()
    {
        Actions.Clear();Labels.Clear();let t=Tournament();if(t==null)return;int seat=t.Side(User());
        if(t.Phase==CaelumTrucazoTournament.PROPOSAL)
        {
            if((t.Accepted&(1<<seat))==0)Add(CaelumTrucazoTournament.ACCEPT,"CA_CARD_CONSENT");
            Add(CaelumTrucazoTournament.CANCEL_PROPOSAL,"CA_CARD_CLOSE");
        }
        else
        {
            if(t.Phase==CaelumTrucazoTournament.ACTIVE && (t.Match==null || t.MatchRecorded) && (seat==t.NextSeat(false) || seat==t.NextSeat(true)))Add(CaelumTrucazoTournament.NEXT_MATCH,"CA_TC4_NEXT_MATCH");
            Add(CaelumTrucazoTournament.CLOSE_VIEW,"CA_CARD_CLOSE");
        }
        Focus=Clamp(Focus,0,Max(0,int(Actions.Size())-1));
    }
    void Choose()
    {
        Build();let t=Tournament();if(t==null || Actions.Size()==0)return;
        SentSerial=t.Serial;EventHandler.SendNetworkEvent("ca_tc4_tournament",Actions[Focus],0,t.Serial);
    }
    override void Ticker()
    {let link=CaelumCardSeat.Read(User());if(link==null || !link.Open || link.Duel!=null || link.Tournament==null){Close();return;}Build();}
    override bool MenuEvent(int key,bool controller)
    {
        Build();int n=Max(1,int(Actions.Size()));
        if(key==MKEY_Up)Focus=(Focus+n-1)%n;else if(key==MKEY_Down)Focus=(Focus+1)%n;
        else if(key==MKEY_Enter)Choose();else if(key==MKEY_Back){Focus=int(Actions.Size())-1;Choose();}
        return true;
    }
    override bool MouseEvent(int type,int x,int y)
    {
        let t=Tournament();if(t==null)return true;Build();Pointer.Clear();
        Pointer.Move(((x-CaelumTrucazoMenu.UILeft())/CaelumTrucazoMenu.UIScale(),(y-CaelumTrucazoMenu.UITop())/CaelumTrucazoMenu.UIScale()));
        for(int i=0;i<int(Actions.Size());i++)Pointer.Add(100+i,566,136+i*30,216,30);
        int hit=Pointer.Hit();if(hit>=100)Focus=hit-100;
        if(type==MOUSE_Click)Pointer.Press(t.Serial);else if(type==MOUSE_Release){int chosen=Pointer.Release(t.Serial);if(chosen>=100){Focus=chosen-100;Choose();}}
        return true;
    }
    override void Drawer()
    {
        let t=Tournament();if(t==null)return;Build();Screen.Dim(0x080E12,1,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucazoMenu.Text(22,22,String.Format(L("CA_TC4_TOURNAMENT_TITLE"),L(t.Tier==0?"CA_TC4_OPEN":"CA_TC4_MASTERS"),t.Count()),Font.CR_GOLD);
        CaelumTrucazoMenu.Wrap(22,52,750,L("CA_TC4_TOURNAMENT_RULES"));
        if(t.Phase==CaelumTrucazoTournament.PROPOSAL)
        {
            int accepted=0;for(int i=0;i<t.Count();i++)if((t.Accepted&(1<<i))!=0)accepted++;
            CaelumTrucazoMenu.Text(22,130,String.Format(L("CA_TC2_CONSENTS"),accepted,t.Count()),Font.CR_YELLOW);
            for(int i=0;i<t.Count();i+=2)CaelumTrucazoMenu.Wrap(22,185+(i/2)*62,510,String.Format(L("CA_TC4_PAIR"),Player(t,i),CaelumTrucazoCompetitive.Rating(t.Members[i]),Player(t,i+1),CaelumTrucazoCompetitive.Rating(t.Members[i+1])));
        }
        else
        {
            if(t.Phase==CaelumTrucazoTournament.COMPLETE)CaelumTrucazoMenu.Wrap(22,130,510,String.Format(L("CA_TC4_CHAMPION"),Player(t,t.Champion)),Font.CR_GOLD);
            else CaelumTrucazoMenu.Wrap(22,130,510,String.Format(L("CA_TC4_NEXT_PAIR"),t.Round+1,Player(t,t.NextSeat(false)),Player(t,t.NextSeat(true))),Font.CR_YELLOW);
            for(int i=0;i<int(t.Victors.Size());i++)CaelumTrucazoMenu.Wrap(22,220+i*35,510,String.Format(L("CA_TC4_RESULT_PAIR"),Player(t,t.PlayedA[i]),Player(t,t.PlayedB[i]),Player(t,t.Victors[i])));
        }
        if(t.Status!="")CaelumTrucazoMenu.Wrap(22,500,750,L(t.Status),Font.CR_RED);
        CaelumTrucazoMenu.Wrap(22,550,750,L("CA_TC4_TOURNAMENT_WAIT"),Font.CR_GRAY);
        for(int i=0;i<int(Actions.Size());i++)CaelumTrucazoMenu.Text(566,140+i*30,(i==Focus?"> ":"  ")..Labels[i],i==Focus?Font.CR_GOLD:Font.CR_WHITE);
    }
}
