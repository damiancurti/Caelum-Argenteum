// La interfaz sólo emite aceptación/rechazo de una revisión concreta.
class CaelumCooperativeTravelEvents : StaticEventHandler
{
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL || menuactive!=0)return;
        let vote=CaelumCooperativeTravel.View(CaelumPlayer(players[consoleplayer].mo));
        if(vote!=null && vote.Opened)Menu.SetMenu('CaelumCooperativeTravelMenu');
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_cooperative_travel")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true);
        let vote=CaelumCooperativeTravel.View(user);
        if(vote!=null)vote.Request(user,e.Args[0],e.Args[1]);
    }
}
class CaelumCooperativeTravelMenu : ListMenu
{
    int Focus,SentSerial,SentOperation;
    static CaelumPlayer User(){return consoleplayer<0?null:CaelumPlayer(players[consoleplayer].mo);}
    static String L(String key){return StringTable.Localize(key,false);}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;SentSerial=-1;}
    void Send(int operation)
    {
        let vote=CaelumCooperativeTravel.View(User());
        if(vote==null || (SentSerial==vote.Serial && SentOperation==operation))return;
        SentSerial=vote.Serial;SentOperation=operation;
        EventHandler.SendNetworkEvent("ca_cooperative_travel",operation,vote.Serial);
    }
    override void Ticker()
    {let vote=CaelumCooperativeTravel.View(User());if(vote==null || !vote.Opened)Close();}
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Up || key==MKEY_Down)Focus=1-Focus;
        else if(key==MKEY_Enter)Send(Focus==0?CaelumCooperativeTravel.ACCEPT:CaelumCooperativeTravel.CANCEL);
        else if(key==MKEY_Back)Send(CaelumCooperativeTravel.CANCEL);
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,L("CA_COOP_TRAVEL_TITLE"),Font.CR_GOLD);
        CaelumTrucoMenu.Wrap(22,60,730,L("CA_COOP_TRAVEL_HELP"));
        let vote=CaelumCooperativeTravel.View(User());if(vote==null)return;
        String target=vote.Kind==CaelumCooperativeTravel.ABANDON?L("CA_COOP_TRAVEL_ABANDON")
            :vote.Kind==CaelumCooperativeTravel.LIMBO?L("CA_FOOL_JOURNEY_DESTINATION")
            :vote.Kind==CaelumCooperativeTravel.LIMBO_RETURN?L("CA_FOOL_JOURNEY_RETURN")
            :vote.Kind==CaelumCooperativeTravel.TUTORIAL?L("CA_COOP_RETURN_DESTINATION")
            :vote.Kind==CaelumCooperativeTravel.HOUSE?L("CA_COOP_TRAVEL_HOUSE")
            :L(CaelumWorldCatalogue.ConnectionNameKey(vote.Connection));
        if(vote.Kind==CaelumCooperativeTravel.DISEMBARK)
        {
            int location=CaelumWorldCatalogue.LocationForMap(vote.Destination);
            target=CaelumWorldCatalogue.IsLocation(location)?L(CaelumWorldCatalogue.LocationNameKey(location))
                :String.Format(L("CA_COOP_TRAVEL_ROADSIDE"),vote.Ride!=null?vote.Ride.CoveredKm():0);
        }
        CaelumTrucoMenu.Text(22,125,String.Format(L("CA_COOP_TRAVEL_TARGET"),target));
        if(vote.Kind==CaelumCooperativeTravel.LIMBO)
            CaelumTrucoMenu.Wrap(22,155,730,String.Format(L("CA_FOOL_JOURNEY_COST"),
                CaelumConstants.TAROT_ACTIVATION_ANIMA,CaelumConstants.TAROT_COOLDOWN_SECONDS));
        if(vote.IsTransport())
        {
            int slot=vote.Slot(User());int fare=slot>=0 && (vote.AliveMask&(1<<slot))!=0?vote.Fare:0;
            CaelumTrucoMenu.Text(22,155,String.Format(L("CA_COOP_TRAVEL_FARE"),fare));
            if(vote.Kind==CaelumCooperativeTravel.DISEMBARK)
                CaelumTrucoMenu.Text(22,185,L("CA_COOP_TRAVEL_DISEMBARK"));
            else if(vote.Kind==CaelumCooperativeTravel.BOARD && vote.Ride!=null)
                CaelumTrucoMenu.Text(22,185,String.Format(L("CA_COOP_TRAVEL_DEPARTURE"),Max(0,vote.Ride.Departure-vote.Ride.Stamp)/3600));
        }
        if(vote.Elapsed>0)
        {
            CaelumTrucoMenu.Text(22,155,String.Format(L("CA_COOP_TRAVEL_PACE"),vote.Pace,CaelumJourneyRules.Duration(vote.Elapsed)));
            int slot=vote.Slot(User());let plan=slot>=0?vote.Plans[slot]:null;
            if(plan!=null)CaelumTrucoMenu.Text(22,185,String.Format(L("CA_COOP_TRAVEL_COST"),
                plan.Available.FoodSpent,plan.Available.WaterSpent,plan.Available.ContainerSpent));
        }
        if(vote.Interrupted)CaelumTrucoMenu.Wrap(22,215,730,L("CA_COOP_TRAVEL_RISK"));
        int yes=0,total=0;
        for(int i=0;i<MAXPLAYERS;i++){if((vote.Mask&(1<<i))!=0)total++;if((vote.Accepted&(1<<i))!=0)yes++;}
        CaelumTrucoMenu.Text(22,270,String.Format(L("CA_COOP_TIME_VOTES"),yes,total));
        CaelumTrucoMenu.Text(22,310,(Focus==0?"> ":"  ")..L("CA_COOP_TRAVEL_ACCEPT"));
        CaelumTrucoMenu.Text(22,340,(Focus==1?"> ":"  ")..L("CA_COOP_TIME_REJECT"));
    }
}
