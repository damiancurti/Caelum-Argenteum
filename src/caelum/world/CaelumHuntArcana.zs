// #616: progreso compartido de la partida, sin modificar una campaña.
class CaelumHuntArcana : Object play
{
    int Revision;
    CaelumHuntOpportunities Places;
    bool Choosing[MAXPLAYERS],Armed[MAXPLAYERS];
    bool WaitingJustice[MAXPLAYERS];
    int Selected[MAXPLAYERS],Pending[MAXPLAYERS],SearchIndex[MAXPLAYERS];
    vector3 Origin[MAXPLAYERS];

    void Initialize(CaelumTarotHunt hunt,CaelumStandaloneMatch match)
    {
        if(Revision>=1)return;Revision=1;
        if(CaelumHuntArcanaData.Present()){Places=new('CaelumHuntOpportunities');Places.Initialize();}
        for(int i=0;i<MAXPLAYERS;i++)if(match.Seeker(i))
        {
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            // También migrar una partida ya empezada: los cautivos reciben
            // el kit al salir, sin permitir acciones materiales desde cautiverio.
            if(!hunt.Captive(i))Supply(user);
            let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
            if(record!=null)
            {
                record.TarotOrderCount=0;record.TarotEffectTics=0;record.TarotCooldownTics=0;record.UnifiedTarotTics=0;
                for(int card=0;card<78;card++)
                {
                    record.TarotOwned[card]=hunt.Found[card];record.TarotSelected[card]=false;
                    record.TarotActive[card]=false;record.TarotRemaining[card]=0;
                }
            }
            Refresh(user);
        }
    }
    static void Supply(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        if(!user.MagicBoxOwned)CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);
        CaelumTarotDeckRules.Grant(user,false);
    }
    static void Refresh(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        user.ApplyCharacterProfile();user.RefreshSocialJournalSnapshot();
        user.RefreshFormalInventorySnapshot();user.PersistCharacterState();
    }
    void Grant(CaelumStandaloneMatch match,int card)
    {
        for(int i=0;i<MAXPLAYERS;i++)if(match.Seeker(i))
        {
            let user=CaelumPlayer(players[i].mo);if(user==null)continue;
            let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
            if(record==null)continue;
            record.TarotOwned[card]=true;Refresh(user);
        }
    }
    static bool BeforeActivation(CaelumPlayer user,CaelumPersistentCharacterState record)
    {
        let hunt=CaelumTarotHunt.View();if(hunt==null || hunt.Arcana==null)return true;
        bool direct=record.TarotSelected[0];
        if(!direct && !(record.TarotSelected[21] && record.HasTarotCard(0)))return true;
        int slot=user.PlayerNumber();
        if(hunt.Arcana.Armed[slot])return true;
        if(hunt.CaptiveMask==0)
        {if(direct){CaelumTarotService.Feedback(user,"CA_HUNT_RESCUE_NONE");return false;}return true;}
        hunt.Arcana.Choosing[slot]=true;return false;
    }
    void Choose(CaelumPlayer user,int target)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        int slot=user.PlayerNumber();if(!Choosing[slot])return;
        Choosing[slot]=false;
        let hunt=CaelumTarotHunt.View();
        if(target<0 || hunt==null || !hunt.Captive(target))return;
        Selected[slot]=target;Armed[slot]=true;
        CaelumTarotService.Activate(user);Armed[slot]=false;
    }
    static void Fool(CaelumPlayer user)
    {
        let hunt=CaelumTarotHunt.View();if(hunt==null || hunt.Arcana==null)return;
        let arcana=hunt.Arcana;int slot=user.PlayerNumber();
        if(!arcana.Armed[slot] || !hunt.Captive(arcana.Selected[slot]))return;
        arcana.Pending[slot]=arcana.Selected[slot]+1;arcana.SearchIndex[slot]=0;arcana.Origin[slot]=user.Pos;
        arcana.WaitingJustice[slot]=false;
    }
    bool Search(CaelumTarotHunt hunt,CaelumPlayer user,int slot)
    {
        int victimSlot=Pending[slot]-1;
        if(!hunt.Captive(victimSlot) || !CaelumPlayerAuthority.CanMutate(user) || user.health<=0)return true;
        // Nadie rescatado queda sin retorno en la arena aislada de Justicia.
        if(CaelumJusticeLink.Bound(user)){WaitingJustice[slot]=true;return false;}
        if(WaitingJustice[slot]){WaitingJustice[slot]=false;Origin[slot]=user.Pos;SearchIndex[slot]=0;}
        let victim=CaelumPlayer(players[victimSlot].mo);if(victim==null)return true;
        double step=Clamp(victim.Radius/2,4.0,16.0);
        int extent=int(Ceil(CaelumMajorArcanaData.JUSTICE_RETURN_MU/step)),width=extent*2+1;
        for(int work=0;work<CaelumMajorArcanaData.JUSTICE_SEARCH_BUDGET;work++)
        {
            if(SearchIndex[slot]>=width*width)
            {CaelumTarotService.Feedback(user,"CA_HUNT_RESCUE_BLOCKED");return true;}
            int at=SearchIndex[slot]++;
            vector3 point=Origin[slot]+(((at%width)-extent)*step,((at/width)-extent)*step,0);
            if((point-user.Pos).Length()>CaelumMajorArcanaData.JUSTICE_RETURN_MU || !CaelumTarotJustice.Fits(victim,point)
                || !CaelumTarotJustice.ClearSegment(victim,user.Pos,point))continue;
            CaelumTarotJustice.Move(victim,point,user.Angle);hunt.Rescue(victimSlot);return true;
        }
        return false;
    }
    void Tick(CaelumTarotHunt hunt,CaelumStandaloneMatch match)
    {
        for(int i=0;i<MAXPLAYERS;i++)if(match.Seeker(i))
        {
            let user=CaelumPlayer(players[i].mo);
            if(hunt.Captive(i))CaelumTarotService.Advance(user);
            if(!CaelumPlayerAuthority.CanMutate(user))Choosing[i]=false;
            if(Pending[i]>0 && Search(hunt,user,i))Pending[i]=0;
        }
    }
}

class CaelumHuntArcanaEvents : StaticEventHandler
{
    override void UiTick()
    {
        if(consoleplayer<0 || gamestate!=GS_LEVEL || menuactive!=0)return;
        let hunt=CaelumTarotHunt.View();
        if(hunt!=null && hunt.Arcana!=null && hunt.Arcana.Choosing[consoleplayer])Menu.SetMenu('CaelumHuntRescueMenu');
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca_hunt_fool')return;
        let hunt=CaelumTarotHunt.View();if(hunt!=null && hunt.Arcana!=null)
            hunt.Arcana.Choose(CaelumPlayerAuthority.FromNetworkPlayer(e.Player),e.Args[0]);
    }
}
class CaelumHuntRescueMenu : ListMenu
{
    int Focus;
    bool Sent;
    int At(int index)
    {
        let hunt=CaelumTarotHunt.View();int count=0;
        if(hunt!=null)for(int i=0;i<MAXPLAYERS;i++)if(hunt.Captive(i))
        {if(count==index)return i;count++;}
        return -1;
    }
    override void Init(Menu parent,ListMenuDescriptor desc)
    {Super.Init(parent,desc);DontDim=true;DontBlur=true;mParentMenu=null;menuactive=Menu.OnNoPause;}
    void Send(int slot){if(!Sent){Sent=true;EventHandler.SendNetworkEvent('ca_hunt_fool',slot);}}
    override void Ticker()
    {
        let hunt=CaelumTarotHunt.View();
        if(hunt==null || hunt.Arcana==null || !hunt.Arcana.Choosing[consoleplayer]){Close();return;}
        if(At(Focus)<0)Focus=0;
    }
    override bool MenuEvent(int key,bool fromcontroller)
    {
        if(key==MKEY_Up)Focus=Max(0,Focus-1);
        else if(key==MKEY_Down && At(Focus+1)>=0)Focus++;
        else if(key==MKEY_Enter)Send(At(Focus));
        else if(key==MKEY_Back)Send(-1);
        return true;
    }
    override void Drawer()
    {
        Screen.Dim(0x080E12,0.92,0,0,Screen.GetWidth(),Screen.GetHeight());
        CaelumTrucoMenu.Text(22,24,StringTable.Localize('CA_HUNT_RESCUE_TITLE',false),Font.CR_GOLD);
        for(int i=0;i<MAXPLAYERS;i++)if(At(i)>=0)
            CaelumTrucoMenu.Text(22,85+i*35,(Focus==i?"> ":"  ")..players[At(i)].GetUserName());
        CaelumTrucoMenu.Text(22,410,StringTable.Localize('CA_TAROT_RACE_CONTROLS',false));
    }
}
