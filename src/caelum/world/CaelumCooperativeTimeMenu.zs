// Consentimientos explícitos por emisor nativo; ningún menú escribe el mundo.
class CaelumCooperativeTimeEvents : StaticEventHandler
{
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL || menuactive!=0)return;
        let vote=CaelumCooperativeTime.View(CaelumPlayer(players[consoleplayer].mo));
        if(vote!=null && vote.Opened)Menu.SetMenu('CaelumCooperativeTimeMenu');
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca_cooperative_time")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        let vote=CaelumCooperativeTime.View(user);
        if(vote!=null)vote.Request(user,e.Args[0],e.Args[1]);
    }
}

class CaelumCooperativeTimeMenu : ListMenu
{
    int Focus,SentSerial,SentOperation;
    Array<int> Actions;
    Array<String> Labels;
    static CaelumPlayer User(){return consoleplayer<0?null:CaelumPlayer(players[consoleplayer].mo);}
    static String L(String key){return StringTable.Localize(key,false);}
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;SentSerial=-1;}
    void Add(int operation,String text){Actions.Push(operation);Labels.Push(text);}
    void Choices()
    {
        Actions.Clear();Labels.Clear();let user=User();let vote=CaelumCooperativeTime.View(user);
        if(vote==null)return;
        if(!vote.Running)
        {
            if(vote.Owner==user)
            {
                Add(CaelumCooperativeTime.HOUR_DOWN,L("CA_COOP_HOUR_DOWN"));
                Add(CaelumCooperativeTime.MINUTE_DOWN,L("CA_COOP_MINUTE_DOWN"));
                Add(CaelumCooperativeTime.MINUTE_UP,L("CA_COOP_MINUTE_UP"));
                Add(CaelumCooperativeTime.HOUR_UP,L("CA_COOP_HOUR_UP"));
            }
            int slot=vote.Slot(user);
            if(slot>=0 && (vote.Accepted&(1<<slot))==0)Add(CaelumCooperativeTime.ACCEPT,L("CA_COOP_TIME_ACCEPT"));
        }
        Add(CaelumCooperativeTime.CANCEL,L("CA_COOP_TIME_REJECT"));
        Focus=Clamp(Focus,0,Max(0,int(Actions.Size())-1));
    }
    void Send(int operation)
    {
        let vote=CaelumCooperativeTime.View(User());if(vote==null || (SentSerial==vote.Serial && SentOperation==operation))return;
        SentSerial=vote.Serial;SentOperation=operation;
        EventHandler.SendNetworkEvent("ca_cooperative_time",operation,vote.Serial);
    }
    override void Ticker()
    {let vote=CaelumCooperativeTime.View(User());if(vote==null || !vote.Opened){Close();return;}Choices();}
    override bool MenuEvent(int key,bool fromcontroller)
    {
        Choices();
        if(key==MKEY_Up)Focus=(Focus-1+Actions.Size())%Max(1,int(Actions.Size()));
        else if(key==MKEY_Down)Focus=(Focus+1)%Max(1,int(Actions.Size()));
        else if(key==MKEY_Enter && Actions.Size()>0)Send(Actions[Focus]);
        else if(key==MKEY_Back)Send(CaelumCooperativeTime.CANCEL);
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,L("CA_COOP_TIME_TITLE"),Font.CR_GOLD);
        CaelumTrucoMenu.Wrap(22,60,730,L("CA_COOP_TIME_HELP"));
        let vote=CaelumCooperativeTime.View(User());if(vote==null)return;
        CaelumTrucoMenu.Text(22,140,String.Format(L("CA_COOP_TIME_DURATION"),vote.Minutes));
        int yes=0,total=0;
        for(int i=0;i<MAXPLAYERS;i++){if((vote.Mask&(1<<i))!=0)total++;if((vote.Accepted&(1<<i))!=0)yes++;}
        CaelumTrucoMenu.Text(22,170,String.Format(L("CA_COOP_TIME_VOTES"),yes,total));
        if(vote.Running)CaelumTrucoMenu.Text(22,200,L("CA_COOP_TIME_RUNNING"),Font.CR_GOLD);
        Choices();for(int i=0;i<Actions.Size();i++)
            CaelumTrucoMenu.Text(22,240+i*27,(i==Focus?"> ":"  ")..Labels[i],i==Focus?Font.CR_GOLD:Font.CR_WHITE);
    }
}
