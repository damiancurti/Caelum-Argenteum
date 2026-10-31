// La interfaz sólo emite solicitudes; la simulación valida emisor, plaza y revisión.
class CaelumCardTableEvents : StaticEventHandler
{
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL || menuactive!=0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let link=CaelumCardSeat.Read(user);
        if(link!=null && link.Open && (link.Duel==null || !link.Duel.Started))
            Menu.SetMenu("CaelumCardTableMenu");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_card_open")
        {
            // El emisor real y la mesa se validan en la simulación de cada par.
            CaelumCardSeat.Interact(CaelumPlayerAuthority.FromNetworkPlayer(e.Player));
            return;
        }
        if(e.Name!="ca_card_table")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        let link=CaelumCardSeat.Read(user);
        if(link==null || !link.Open)return;
        if(link.Duel!=null){link.Duel.Lobby(user,e.Args[0],e.Args[2]);return;}
        if(link.LastSerial!=e.Args[2])return;
        if(e.Args[0]==CaelumCardDuel.CANCEL){link.Open=false;link.LastSerial++;return;}
        if(e.Args[0]==CaelumCardDuel.CONSENT)
            CaelumCardDuel.Invite(user,CaelumPlayerAuthority.FromNetworkPlayer(e.Args[1]),e.Args[2]);
    }
}

class CaelumCardTableMenu : ListMenu
{
    int Focus;
    int SentSerial;
    Array<int> Actions;
    Array<int> Targets;
    Array<String> Labels;
    static CaelumPlayer User()
    { return consoleplayer<0?null:CaelumPlayer(players[consoleplayer].mo); }
    static String L(String key){return StringTable.Localize(key,false);}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;SentSerial=-1;
    }
    void Add(int operation,String text,int target=0)
    {Actions.Push(operation);Labels.Push(text);Targets.Push(target);}
    void Choices()
    {
        Actions.Clear();Targets.Clear();Labels.Clear();
        let user=User();let link=CaelumCardSeat.Read(user);
        if(link==null)return;
        let duel=link.Duel;
        if(duel==null)
        {
            let table=CaelumCardSeat.Table(user);
            // Ocho jugadores como máximo; nunca se recorre la población del mapa.
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let other=CaelumPlayer(players[i].mo);
                if(other!=user && table!=null && CaelumCardSeat.Table(other)==table
                    && CaelumCardSeat.Session(other)==null)
                    Add(CaelumCardDuel.CONSENT,String.Format(L("CA_CARD_INVITE_PLAYER"),i+1),i);
            }
        }
        else
        {
            if(duel.Side(user)==0)
            {
                Add(CaelumCardDuel.SELECT_GAME,L(duel.Game==CaelumCardDuel.GAME_TRUCO?"CA_CARD_SELECT_TRUCO":"CA_CARD_SELECT_TRUCAZO"));
                if(duel.Game==CaelumCardDuel.GAME_TRUCO)Add(CaelumCardDuel.SELECT_FLOR,L(duel.Flor?"CA_TT_FLOR_ON":"CA_TT_FLOR_OFF"));
            }
            if((duel.Accepted & (1<<duel.Side(user)))==0)Add(CaelumCardDuel.CONSENT,L("CA_CARD_CONSENT"));
        }
        Add(CaelumCardDuel.CANCEL,L("CA_CARD_CLOSE"));
        Focus=Clamp(Focus,0,Max(0,int(Actions.Size())-1));
    }
    void Send(int operation,int target=0)
    {
        let link=CaelumCardSeat.Read(User());
        if(link==null || SentSerial==link.LastSerial)return;
        SentSerial=link.LastSerial;
        EventHandler.SendNetworkEvent("ca_card_table",operation,target,link.LastSerial);
    }
    override void Ticker()
    {
        let link=CaelumCardSeat.Read(User());
        if(link==null || !link.Open){Close();return;}
        if(link.Duel!=null && link.Duel.Started)
        {Close();return;}
        Choices();
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        Choices();
        if(key==MKEY_Up)Focus=(Focus-1+Actions.Size())%Max(1,int(Actions.Size()));
        else if(key==MKEY_Down)Focus=(Focus+1)%Max(1,int(Actions.Size()));
        else if(key==MKEY_Enter && Actions.Size()>0)Send(Actions[Focus],Targets[Focus]);
        else if(key==MKEY_Back)Send(CaelumCardDuel.CANCEL);
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,L("CA_CARD_TABLE_TITLE"),Font.CR_GOLD);
        CaelumTrucoMenu.Wrap(22,60,730,L("CA_CARD_TABLE_HELP"));
        let link=CaelumCardSeat.Read(User());
        if(link==null)return;
        let duel=link.Duel;
        if(duel!=null)
        {
            CaelumTrucoMenu.Text(22,130,L(duel.Game==CaelumCardDuel.GAME_TRUCO?"CA_CARD_TRUCO":"CA_CARD_TRUCAZO"),Font.CR_GOLD);
            if(duel.Game==CaelumCardDuel.GAME_TRUCO)CaelumTrucoMenu.Text(22,154,L(duel.Flor?"CA_CARD_WITH_FLOR":"CA_CARD_WITHOUT_FLOR"));
            CaelumTrucoMenu.Text(22,180,String.Format(L("CA_CARD_ACCEPTED"),int((duel.Accepted&1)!=0)+int((duel.Accepted&2)!=0)));
        }
        Choices();
        if(duel==null && Actions.Size()==1)CaelumTrucoMenu.Text(22,180,L("CA_CARD_NO_PARTNER"));
        for(int i=0;i<Actions.Size();i++)
            CaelumTrucoMenu.Text(22,230+i*27,(i==Focus?"> ":"  ")..Labels[i],i==Focus?Font.CR_GOLD:Font.CR_WHITE);
    }
}
