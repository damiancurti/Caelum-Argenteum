// El menú local no modifica la elección: envía una acción validada por la sesión.
class CaelumTarotRaceEvents : StaticEventHandler
{
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL || menuactive!=0)return;
        let user=CaelumPlayer(players[consoleplayer].mo);
        let record=user!=null?CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState')):null;
        if(record!=null && record.TarotRaceMenuOpen)Menu.SetMenu('CaelumTarotRaceMenu');
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca_tarot_race")
            CaelumHangedMan.Choose(CaelumPlayerAuthority.FromNetworkPlayer(e.Player,true),e.Args[0]);
    }
}
class CaelumTarotRaceMenu : ListMenu
{
    int Focus;
    bool Sent;
    static CaelumPlayer User(){return consoleplayer<0?null:CaelumPlayer(players[consoleplayer].mo);}
    static String L(String key){return StringTable.Localize(key,false);}
    int RaceAt(int index)
    {
        int count=0;
        for(int race=CaelumConstants.RACE_BEAST_MAN;race<=CaelumConstants.RACE_GOBLIN;race++)
            if(CaelumHangedMan.ValidRace(User(),race)){if(count==index)return race;count++;}
        return -1;
    }
    override void Init(Menu parent,ListMenuDescriptor desc)
    {
        Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;
        menuactive=Menu.OnNoPause;
        let user=User();let record=user!=null?CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState')):null;
        if(record!=null)for(int i=0;i<3;i++)if(RaceAt(i)==record.TarotHangedRace)Focus=i;
    }
    void Send(int race)
    {if(!Sent){Sent=true;EventHandler.SendNetworkEvent("ca_tarot_race",race);}}
    override void Ticker()
    {
        let user=User();let record=user!=null?CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState')):null;
        if(record==null || !record.TarotRaceMenuOpen)Close();
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Up)Focus=(Focus+2)%3;
        else if(key==MKEY_Down)Focus=(Focus+1)%3;
        else if(key==MKEY_Enter)Send(RaceAt(Focus));
        else if(key==MKEY_Back)Send(-1);
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,L("CA_TAROT_RACE_TITLE"),Font.CR_GOLD);
        CaelumTrucoMenu.Wrap(22,62,730,L("CA_TAROT_RACE_HELP"));
        for(int i=0;i<3;i++)
            CaelumTrucoMenu.Text(22,175+i*35,(Focus==i?"> ":"  ")..L(CaelumHangedMan.RaceKey(RaceAt(i))));
        CaelumTrucoMenu.Wrap(22,310,730,L("CA_TAROT_RACE_CONTROLS"));
    }
}
