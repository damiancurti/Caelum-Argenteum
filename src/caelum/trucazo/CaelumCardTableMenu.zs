// La interfaz sólo emite solicitudes; la simulación valida emisor, plaza y revisión.
class CaelumCardTableEvents : StaticEventHandler
{
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL || menuactive!=0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let link=CaelumCardSeat.Read(user);
        if(link!=null && link.Open && link.Duel==null && link.Tournament!=null)
        {Menu.SetMenu("CaelumTrucazoTournamentMenu");return;}
        if(link!=null && link.Open && link.Duel!=null && link.Duel.Started && link.Duel.Advanced!=null)
        {Menu.SetMenu("CaelumTrucazoGameMenu");return;}
        if(link!=null && link.Open && (link.Duel==null || !link.Duel.Started))
            Menu.SetMenu("CaelumCardTableMenu");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_tc4_tournament")
        {let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);let link=CaelumCardSeat.Read(user);if(link!=null && link.Tournament!=null)link.Tournament.Request(user,e.Args[0],e.Args[2]);return;}
        if(e.Name=="ca_tc_claim")
        {let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);let claim=CaelumTrucazoClaims.Read(user);if(claim!=null)claim.Claim(user,e.Args[0]);return;}
        if(e.Name=="ca_tc3" || e.Name=="ca_tc3_offer")
        {
            let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);let duel=CaelumCardSeat.Session(user);
            if(duel!=null)
            {if(e.Name=="ca_tc3_offer")duel.WagerRequest(user,CaelumTrucazoWagers.ADD_ITEM,e.Args[0],e.Args[2],e.Args[1]);else duel.WagerRequest(user,e.Args[0],e.Args[1],e.Args[2]);}
            return;
        }
        if(e.Name=="ca_card_open")
        {
            // El emisor real y la mesa se validan en la simulación de cada par.
            CaelumCardSeat.Interact(CaelumPlayerAuthority.FromNetworkPlayer(e.Player));
            return;
        }
        if(e.Name=="ca_tc2")
        {
            let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);let duel=CaelumCardSeat.Session(user);
            if(duel!=null)duel.DispatchAdvanced(user,e.Args[0],e.Args[1],e.Args[2]);return;
        }
        if(e.Name!="ca_card_table")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        let link=CaelumCardSeat.Read(user);
        if(link==null || !link.Open)return;
        if(link.Duel!=null){link.Duel.Lobby(user,e.Args[0],e.Args[2],e.Args[1]);return;}
        if(link.LastSerial!=e.Args[2])return;
        if(e.Args[0]==CaelumCardDuel.CREATE_TOURNAMENT)
        {CaelumTrucazoTournament.Create(user,e.Args[1]%16,e.Args[1]/16,e.Args[2]);return;}
        if(e.Args[0]==CaelumCardDuel.CANCEL){link.Open=false;link.LastSerial++;return;}
        if(e.Args[0]==CaelumCardDuel.CONSENT)
            CaelumCardDuel.Invite(user,CaelumPlayerAuthority.FromNetworkPlayer(e.Args[1]),e.Args[2]);
    }
}

class CaelumCardTableMenu : ListMenu
{
    int Focus;
    int MajorCursor;
    int SentSerial;
    CaelumMenuPointer Pointer;
    Array<int> Actions;
    Array<int> Targets;
    Array<String> Labels;
    static CaelumPlayer User()
    { return consoleplayer<0?null:CaelumPlayer(players[consoleplayer].mo); }
    static String L(String key){return StringTable.Localize(key,false);}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;SentSerial=-1;Pointer=new('CaelumMenuPointer');
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
            for(int tier=0;tier<2;tier++)for(int size=4;size<=8;size*=2)
                Add(CaelumCardDuel.CREATE_TOURNAMENT,String.Format(L("CA_TC4_TOURNAMENT_OPTION"),L(tier==0?"CA_TC4_OPEN":"CA_TC4_MASTERS"),size),tier*16+size);
        }
        else
        {
            if(duel.Side(user)==0)
            {
                if(duel.Count()==2 && duel.Tournament==null)Add(CaelumCardDuel.SELECT_GAME,L(duel.Game==CaelumCardDuel.GAME_TRUCO?"CA_CARD_SELECT_TRUCO":"CA_CARD_SELECT_TRUCAZO"));
                if(duel.Game==CaelumCardDuel.GAME_TRUCO)Add(CaelumCardDuel.SELECT_FLOR,L(duel.Flor?"CA_TT_FLOR_ON":"CA_TT_FLOR_OFF"));
                else
                {
                    Add(CaelumCardDuel.SELECT_MAJORS,L(duel.Majors?"CA_TC2_MAJORS_ON":"CA_TC2_MAJORS_OFF"));Add(CaelumCardDuel.SELECT_SENSES,L(duel.Senses?"CA_TC2_SENSES_ON":"CA_TC2_SENSES_OFF"));
                    if(!duel.Ranked)Add(CaelumCardDuel.SELECT_CONSEQUENCES,L(duel.Consequences?"CA_TC4_CASUAL":"CA_TC4_PRACTICE"));
                    if(duel.Tournament==null)Add(CaelumCardDuel.SELECT_RANKED,L(duel.Ranked?"CA_TC4_RANKED_ON":"CA_TC4_RANKED_OFF"));
                    int available=duel.Available();
                    for(int n=2;duel.Tournament==null && n<=Min(CaelumTrucazoData.MAX_SEATS,available);n+=2)
                        if(!duel.TeamMode || duel.Count()!=n)Add(CaelumCardDuel.SELECT_TEAM_SIZE,String.Format(L("CA_TC2_SIZE"),n/2,n/2),n);
                }
            }
            if(duel.Game==CaelumCardDuel.GAME_TRUCAZO && duel.Majors)
            {
                let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));let choice=CaelumTrucazoChoice.Read(user);
                bool selected=choice!=null && choice.Selected[MajorCursor];
                if(CaelumTarotService.HasTarotCard(record,MajorCursor)
                    && (selected || (choice==null?0:choice.Count())<CaelumTarotLoadout.Capacity(record)))
                    Add(CaelumCardDuel.SELECT_MAJOR,(selected?"- ":"+ ")..CaelumTarotArt.DisplayName(MajorCursor),MajorCursor);
            }
            if(duel.Ranked)Add(-11,L("CA_TC4_VIEW_RULES"));
            if((duel.Accepted & (1<<duel.Side(user)))==0)Add(CaelumCardDuel.CONSENT,L("CA_CARD_CONSENT"));
            if(duel.Consequences)Add(-10,L("CA_TC3_REVIEW"));
        }
        Add(CaelumCardDuel.CANCEL,L("CA_CARD_CLOSE"));
        Focus=Clamp(Focus,0,Max(0,int(Actions.Size())-1));
    }
    void Send(int operation,int target=0)
    {
        if(operation==-10){Menu.SetMenu('CaelumTrucazoWagerMenu');return;}
        if(operation==-11){Menu.SetMenu('CaelumTrucazoRankedMenu');return;}
        let link=CaelumCardSeat.Read(User());
        // Una solicitud rechazada sin cambio de estado no debe bloquear el menú.
        if(link==null)return;
        SentSerial=link.LastSerial;
        EventHandler.SendNetworkEvent("ca_card_table",operation,target,link.LastSerial);
    }
    override void Ticker()
    {
        let link=CaelumCardSeat.Read(User());
        if(link==null || !link.Open){Close();return;}
        if(link.Tournament!=null && link.Duel==null){Close();return;}
        if(link.Duel!=null && link.Duel.Started)
        {Close();return;}
        Choices();
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        Choices();
        if(key==MKEY_Left)MajorCursor=(MajorCursor+21)%22;
        else if(key==MKEY_Right)MajorCursor=(MajorCursor+1)%22;
        else if(key==MKEY_Up)Focus=(Focus-1+Actions.Size())%Max(1,int(Actions.Size()));
        else if(key==MKEY_Down)Focus=(Focus+1)%Max(1,int(Actions.Size()));
        else if(key==MKEY_Enter && Actions.Size()>0)Send(Actions[Focus],Targets[Focus]);
        else if(key==MKEY_Back)Send(CaelumCardDuel.CANCEL);
        return true;
    }
    override bool MouseEvent(int type,int x,int y)
    {
        let link=CaelumCardSeat.Read(User());if(link==null)return true;Choices();Pointer.Clear();
        Pointer.Move(((x-CaelumTrucazoMenu.UILeft())/CaelumTrucazoMenu.UIScale(),(y-CaelumTrucazoMenu.UITop())/CaelumTrucazoMenu.UIScale()));
        int first=(Focus/11)*11;for(int i=first;i<Min(first+11,int(Actions.Size()));i++)Pointer.Add(100+i,22,226+(i-first)*27,270,27);
        if(Actions.Size()>11){Pointer.Add(9000,22,532,100,28);Pointer.Add(9001,160,532,100,28);}
        int hit=Pointer.Hit();if(hit>=100 && hit<9000)Focus=hit-100;
        if(type==MOUSE_Click)Pointer.Press(link.LastSerial);
        else if(type==MOUSE_Release){int choice=Pointer.Release(link.LastSerial);if(choice>=9000)Focus=Clamp(first+(choice==9000?-11:11),0,int(Actions.Size())-1);else if(choice>=100){Focus=choice-100;Send(Actions[Focus],Targets[Focus]);}}
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,L("CA_CARD_TABLE_TITLE"),Font.CR_GOLD);
        let link=CaelumCardSeat.Read(User());
        if(link==null)return;
        let duel=link.Duel;
        CaelumTrucoMenu.Wrap(22,60,730,L(duel!=null && duel.Game==CaelumCardDuel.GAME_TRUCAZO?"CA_TC4_TABLE_HELP":"CA_CARD_TABLE_HELP"));
        if(duel!=null)
        {
            CaelumTrucoMenu.Text(22,130,L(duel.Game==CaelumCardDuel.GAME_TRUCO?"CA_CARD_TRUCO":"CA_CARD_TRUCAZO"),Font.CR_GOLD);
            if(duel.Game==CaelumCardDuel.GAME_TRUCO)CaelumTrucoMenu.Text(22,154,L(duel.Flor?"CA_CARD_WITH_FLOR":"CA_CARD_WITHOUT_FLOR"));
            int accepted=0;for(int i=0;i<duel.Count();i++)if((duel.Accepted&(1<<i))!=0)accepted++;
            CaelumTrucoMenu.Text(22,180,String.Format(L("CA_TC2_CONSENTS"),accepted,duel.Count()));
            if(duel.Game==CaelumCardDuel.GAME_TRUCAZO)CaelumTrucoMenu.Text(22,154,String.Format(L("CA_TC2_SIZE"),duel.Count()/2,duel.Count()/2));
            if(duel.Game==CaelumCardDuel.GAME_TRUCAZO)CaelumTrucoMenu.Text(22,205,L(duel.Ranked?"CA_TC4_RANKED":duel.Consequences?"CA_TC4_CASUAL":"CA_TC4_PRACTICE"),Font.CR_GOLD);
        }
        if(duel!=null && duel.Game==CaelumCardDuel.GAME_TRUCAZO && duel.Majors)
        {
            CaelumTrucoMenu.Wrap(300,180,450,L("CA_TC2_SELECT_HELP"));
            if(duel.Ranked)CaelumTrucoMenu.Text(300,210,String.Format(L("CA_TC4_MAJOR_LIMIT"),CaelumTrucazoCompetitive.MajorLimit(duel)),Font.CR_YELLOW);
            CaelumTrucoMenu.Wrap(300,230,450,L(String.Format("CA_TC2_EFFECT_%d",MajorCursor)));
        }
        if(duel!=null)
        {
            for(int i=0;i<duel.Count();i++)
            {
                let choice=CaelumTrucazoChoice.Read(duel.Member(i));
                String chosen=String.Format(L("CA_TC2_MEMBER"),i+1,duel.MemberSlot(i)+1,i%2==0?"A":"B");
                if(duel.Ranked)chosen=chosen..String.Format(" [%.0f]",CaelumTrucazoCompetitive.Rating(duel.Member(i)));
                if(duel.Game==CaelumCardDuel.GAME_TRUCAZO && duel.Majors)
                    for(int c=0;c<22;c++)if(choice!=null && choice.Selected[c])chosen=chosen.." / "..CaelumTarotArt.DisplayName(c);
                CaelumTrucoMenu.Wrap(300,310+i*34,450,chosen,Font.CR_GOLD);
            }
        }
        if(duel!=null && duel.Game==CaelumCardDuel.GAME_TRUCAZO)
        {CaelumTrucoMenu.Text(300,130,L(duel.Majors?"CA_TC2_MAJORS_ON":"CA_TC2_MAJORS_OFF"));CaelumTrucoMenu.Text(300,154,L(duel.Senses?"CA_TC2_SENSES_ON":"CA_TC2_SENSES_OFF"));}
        if(duel!=null && duel.Ranked && !duel.Majors)CaelumTrucoMenu.Wrap(300,180,450,L("CA_TC4_RULES"));
        if(duel==null)CaelumTrucoMenu.Wrap(300,130,450,L("CA_TC4_TOURNAMENT_ACCESS"));
        if(duel!=null && duel.Consequences)CaelumTrucoMenu.Wrap(22,580,730,L("CA_TC3_REVIEW_HELP"),Font.CR_GOLD);
        Choices();
        if(duel==null && Actions.Size()==1)CaelumTrucoMenu.Text(22,180,L("CA_CARD_NO_PARTNER"));
        int first=(Focus/11)*11;
        for(int i=first;i<Min(first+11,int(Actions.Size()));i++)
            CaelumTrucoMenu.Text(22,230+(i-first)*27,(i==Focus?"> ":"  ")..Labels[i],i==Focus?Font.CR_GOLD:Font.CR_WHITE);
        if(Actions.Size()>11){CaelumTrucoMenu.Text(22,536,"<",Font.CR_GOLD);CaelumTrucoMenu.Text(160,536,">",Font.CR_GOLD);}
    }
}
