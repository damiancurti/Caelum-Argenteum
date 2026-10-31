// Consulta acotada al roster nativo; el organizador se crea una vez por mapa.
class CaelumArenaEvents : StaticEventHandler
{
    CaelumArenaOrganizer Organizer;
    bool Prepared;
    override void WorldLoaded(WorldEvent e){Prepared=false;Organizer=null;}
    override void WorldTick()
    {
        if(!Prepared && level.MapName==CaelumArenaData.OrganizerMap() && level.time>0)
        {
            Prepared=true;
            vector3 point=CaelumArenaData.OrganizerPosition();
            // Una consulta local al entrar/cargar conserva al organizador existente.
            let shape=GetDefaultByType('CaelumArenaOrganizer');
            let nearby=BlockThingsIterator.CreateFromPos(point.X,point.Y,point.Z,shape.Height,shape.Radius,false);
            while(nearby.Next())if(nearby.thing is 'CaelumArenaOrganizer')
            {Organizer=CaelumArenaOrganizer(nearby.thing);break;}
            if(Organizer==null)Organizer=CaelumArenaOrganizer(Actor.Spawn('CaelumArenaOrganizer',point,NO_REPLACE));
            if(Organizer!=null)Organizer.Angle=CaelumArenaData.ORGANIZER_ANGLE;
        }
        // Todos comparten la misma partida; una sola evaluación para los ocho.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let session=CaelumArenaState.View(CaelumPlayer(players[i].mo));
            if(session!=null && session.MatchState!=null){session.MatchState.Evaluate();break;}
        }
    }
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL || menuactive!=0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);let session=CaelumArenaState.View(user);
        let vote=CaelumCooperativeTravel.View(user);
        if(session!=null && session.Open && (vote==null || !vote.Opened))Menu.SetMenu('CaelumArenaMenu');
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_arena_action")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true);if(user==null)return;
        let session=CaelumArenaState.View(user);if(session==null)return;
        int operation=e.Args[0];
        if(operation==CaelumArena.CLOSE){session.Open=false;return;}
        if(operation==CaelumArena.GO_BACK){CaelumArena.ProposeReturn(user);return;}
        if(operation==CaelumArena.SURRENDER)
        {if(session.MatchState!=null)session.MatchState.Surrender(user);return;}
        if(!CaelumArena.OrganizerValid(user,session.Organizer))return;
        if(operation==CaelumArena.VENUE)session.Venue=1-session.Venue;
        else if(operation==CaelumArena.MODE)session.Mode=1-session.Mode;
        else if(operation==CaelumArena.INVITE && !CaelumArena.Propose(user))
            CaelumNotifications.Notify(user,StringTable.Localize("CA_ARENA_NOT_READY",false));
    }
}

class CaelumArenaMenu : ListMenu
{
    int Focus;
    static String L(String key){return StringTable.Localize(key,false);}
    static CaelumPlayer User(){return consoleplayer>=0?CaelumPlayer(players[consoleplayer].mo):null;}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;}
    override void Ticker()
    {let vote=CaelumCooperativeTravel.View(User());if(vote!=null && vote.Opened)Close();}
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Back){EventHandler.SendNetworkEvent("ca_arena_action",CaelumArena.CLOSE);Close();return true;}
        let session=CaelumArenaState.View(User());if(session==null)return true;
        let match=session.MatchState;bool playing=match!=null && match.Status!=CaelumArenaMatch.RETURNED;
        int rows=playing?2:4;
        if(key==MKEY_Up)Focus=(Focus+rows-1)%rows;
        else if(key==MKEY_Down)Focus=(Focus+1)%rows;
        else if(key==MKEY_Enter)
        {
            int operation=CaelumArena.CLOSE;
            if(playing && Focus==0)operation=match.Status==CaelumArenaMatch.FINISHED?CaelumArena.GO_BACK:CaelumArena.SURRENDER;
            else if(!playing)operation=Focus==0?CaelumArena.VENUE:Focus==1?CaelumArena.MODE:Focus==2?CaelumArena.INVITE:CaelumArena.CLOSE;
            EventHandler.SendNetworkEvent("ca_arena_action",operation);
            if(operation==CaelumArena.CLOSE)Close();
        }
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,L("CA_ARENA_TITLE"),Font.CR_GOLD);
        CaelumTrucoMenu.Wrap(22,60,730,L("CA_ARENA_RULES"));
        let session=CaelumArenaState.View(User());
        if(session==null){CaelumTrucoMenu.Wrap(22,190,730,L("CA_ARENA_NEED_ORGANIZER"));return;}
        let match=session.MatchState;bool playing=match!=null && match.Status!=CaelumArenaMatch.RETURNED;
        if(playing)
        {
            String result=L("CA_ARENA_FIGHTING");
            if(match.Status==CaelumArenaMatch.FINISHED)
                result=match.Winner<0?L("CA_ARENA_NO_WINNER"):match.Mode==0
                    ?String.Format(L("CA_ARENA_WINNER"),players[match.Winner].GetUserName())
                    :String.Format(L("CA_ARENA_TEAM_WINNER"),match.Winner+1);
            CaelumTrucoMenu.Text(22,190,result,Font.CR_GOLD);
            CaelumTrucoMenu.Text(22,260,(Focus==0?"> ":"  ")..L(match.Status==CaelumArenaMatch.FINISHED?"CA_ARENA_RETURN":"CA_ARENA_SURRENDER"));
            CaelumTrucoMenu.Text(22,300,(Focus==1?"> ":"  ")..L("CA_ARENA_CLOSE"));
        }
        else
        {
            CaelumTrucoMenu.Text(22,190,(Focus==0?"> ":"  ")..L(CaelumArenaData.NameKey(session.Venue)));
            CaelumTrucoMenu.Text(22,230,(Focus==1?"> ":"  ")..L(session.Mode==0?"CA_ARENA_INDIVIDUAL":"CA_ARENA_TEAMS"));
            CaelumTrucoMenu.Text(22,270,(Focus==2?"> ":"  ")..L("CA_ARENA_PROPOSE"));
            CaelumTrucoMenu.Text(22,310,(Focus==3?"> ":"  ")..L("CA_ARENA_CLOSE"));
        }
    }
}
