// Una propuesta guarda participantes y duración. La UI no decide quién consiente.
class CaelumCooperativeTime : Inventory
{
    enum Operation { MINUTE_DOWN, MINUTE_UP, HOUR_DOWN, HOUR_UP, ACCEPT, CANCEL }
    CaelumPlayer Members[MAXPLAYERS];
    CaelumRestState Rests[MAXPLAYERS];
    Actor Tasks[MAXPLAYERS];
    bool HadTask[MAXPLAYERS];
    int Mask,AliveMask,Accepted,Serial,Minutes,Remaining,EndDays,EndTics,Seen,SeenTic,LastPumpTic;
    bool Opened,Running,RestOnly;
    String OriginMap;

    static clearscope CaelumCooperativeTime View(CaelumPlayer user)
    {
        let clock=user!=null?CaelumWorldClock(user.FindInventory('CaelumWorldClock')):null;
        return clock!=null?clock.TimeVote:null;
    }
    clearscope int Slot(CaelumPlayer user)
    {
        if(user==null || user.player==null)return -1;
        int slot=user.PlayerNumber();
        return slot>=0 && slot<MAXPLAYERS && Members[slot]==user?slot:-1;
    }
    bool NextSerial()
    {
        let source=CaelumWorldClockTicker.CampaignOwner();
        let clock=CaelumWorldClock.Get(source);
        if(clock==null || clock.CooperativeSerial==2147483647)return false;
        Serial=++clock.CooperativeSerial;
        CaelumWorldClockTicker.Mirror(source);return true;
    }
    bool RosterValid()
    {
        if(OriginMap!=level.MapName)return false;
        for(int i=0;i<MAXPLAYERS;i++)
        {
            if(playeringame[i]!=(Members[i]!=null))return false;
            if(Members[i]!=null && (players[i].mo!=Members[i] || !CaelumWorldClockTicker.Ready(Members[i])))return false;
        }
        return true;
    }
    static String Safety(CaelumPlayer user,bool scan=true)
    {
        bool working=CaelumTimeSkipState.TaskActive(user) || CaelumRecipeSession.Working(user);
        return CaelumRestSafety.BlockReason(user,CaelumRestState.IsActive(user)
            || CaelumCleaningTask.Timeless(user),working,scan,true);
    }
    static clearscope bool Living(CaelumPlayer user)
    {return user!=null && user.player!=null && user.health>0 && user.player.playerstate==PST_LIVE;}
    static bool Open(CaelumPlayer user)
    {
        if(!multiplayer || !CaelumPlayerAuthority.CanMutate(user))return false;
        let existing=View(user);
        if(existing!=null && existing.Opened)
        {existing.FinishVote("CA_COOP_TIME_CANCELLED");return true;}
        String reason=Safety(user);
        if(reason!=""){CaelumNotifications.Notify(user,StringTable.Localize(reason,false));return false;}
        let source=CaelumWorldClockTicker.CampaignOwner();
        let clock=CaelumWorldClock.Get(source);if(clock==null)return false;
        if(clock.TravelVote!=null && clock.TravelVote.Opened)return false;
        if(clock.TimeVote!=null && clock.TimeVote.Opened)return false;
        let vote=CaelumCooperativeTime(user.FindInventory('CaelumCooperativeTime'));
        if(vote==null)vote=CaelumCooperativeTime(user.GiveInventoryType('CaelumCooperativeTime'));
        vote.Mask=0;vote.Accepted=0;vote.Running=false;vote.Opened=false;
        for(int i=0;i<MAXPLAYERS;i++)
        {
            vote.Members[i]=null;vote.Rests[i]=null;vote.Tasks[i]=null;vote.HadTask[i]=false;
            if(!playeringame[i])continue;
            let member=CaelumPlayer(players[i].mo);
            if(!CaelumWorldClockTicker.Ready(member))return false;
            vote.Members[i]=member;vote.Mask|=1<<i;
        }
        vote.Minutes=60;vote.Remaining=0;vote.OriginMap=level.MapName;
        vote.RestOnly=CaelumRestState.IsActive(user);vote.LastPumpTic=-1;vote.SeenTic=-1;vote.Seen=0;
        clock.TimeVote=vote;
        if(!vote.NextSerial()){clock.TimeVote=null;return false;}
        vote.Opened=true;return true;
    }
    bool Request(CaelumPlayer user,int operation,int expected)
    {
        int slot=Slot(user);
        if(!Opened || slot<0 || expected!=Serial || !RosterValid())return false;
        if(operation==CANCEL){FinishVote("CA_COOP_TIME_CANCELLED");return true;}
        if(Running)return false;
        if(operation>=MINUTE_DOWN && operation<=HOUR_UP)
        {
            if(user!=Owner)return false;
            int delta=operation==MINUTE_DOWN?-1:operation==MINUTE_UP?1:operation==HOUR_DOWN?-60:60;
            Minutes=Clamp(Minutes+delta,1,CaelumTimeSkipRules.MAX_DAYS*1440);
            Accepted=0;return NextSerial();
        }
        if(operation!=ACCEPT || (Accepted&(1<<slot))!=0)return false;
        String reason=Living(user)?Safety(user):"";
        if(reason!=""){CaelumNotifications.Notify(user,StringTable.Localize(reason,false));return false;}
        if(RestOnly && Living(user) && !CaelumRestState.IsActive(user))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_COOP_TIME_REST_ALL",false));return false;}
        Accepted|=1<<slot;
        // Aceptaciones simultáneas de la misma oferta son válidas. El bit
        // impide duplicados; sólo editar/cancelar cambia la revisión ofrecida.
        if(Accepted==Mask)Begin();
        return true;
    }
    void Begin()
    {
        if(!RosterValid()){FinishVote("CA_COOP_TIME_CANCELLED");return;}
        AliveMask=0;
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {
            let user=Members[i];
            if(!Living(user)){Rests[i]=null;HadTask[i]=false;Tasks[i]=null;continue;}
            AliveMask|=1<<i;String reason=Safety(user);
            if(reason!="" || (RestOnly && !CaelumRestState.IsActive(user)))
            {FinishVote(reason!=""?reason:"CA_COOP_TIME_REST_ALL");return;}
            Rests[i]=CaelumRestState.IsActive(user)?CaelumRestState.Get(user):null;
            HadTask[i]=CaelumTimeSkipState.TaskActive(user);
            Tasks[i]=HadTask[i]?CaelumTimeSkipState.TaskAnchor(user):null;
        }
        Remaining=Minutes*(CaelumWorldClock.TicsPerHour()/60);
        let clock=CaelumWorldClock.Get(CaelumWorldClockTicker.CampaignOwner());
        EndDays=clock.CompletedDays+Remaining/CaelumWorldClock.TicsPerDay();
        EndTics=clock.DayTics+Remaining%CaelumWorldClock.TicsPerDay();
        if(EndTics>=CaelumWorldClock.TicsPerDay()){EndDays++;EndTics-=CaelumWorldClock.TicsPerDay();}
        Running=true;
    }
    void FinishVote(String reason)
    {
        if(!Opened)return;
        Opened=false;Running=false;NextSerial();
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {
            let clock=CaelumWorldClock.Get(Members[i]);
            if(clock!=null && clock.TimeVote==self)clock.TimeVote=null;
            let advance=CaelumTimeAdvanceState.Get(Members[i]);if(advance!=null)advance.Pumping=false;
            CaelumNotifications.Notify(Members[i],StringTable.Localize(reason,false));
        }
    }
    bool SafeGroup(bool scan)
    {
        if(!RosterValid()){FinishVote("CA_COOP_TIME_CANCELLED");return false;}
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {
            let user=Members[i];
            if(Living(user)!=((AliveMask&(1<<i))!=0)){FinishVote("CA_REST_UNAVAILABLE");return false;}
            if(!Living(user))continue;
            String reason=Safety(user,scan);
            if(reason!=""){FinishVote(reason);return false;}
            if((Rests[i]!=null && (!CaelumRestState.IsActive(user) || CaelumRestState.Get(user)!=Rests[i]))
                || (HadTask[i] && (!CaelumTimeSkipState.TaskActive(user) || CaelumTimeSkipState.TaskAnchor(user)!=Tasks[i])))
            {FinishVote("CA_COOP_TIME_CANCELLED");return false;}
        }
        return true;
    }
    static void AfterPlayerStep(CaelumPlayer user)
    {
        // La predicción local también ejecuta Tick. No cuenta como un paso
        // compartido: adelantar el grupo antes del cuerpo remoto desincroniza
        // su reloj y hace que el descanso detecte un salto externo.
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let vote=View(user);if(vote==null || !vote.Running)return;
        int slot=vote.Slot(user);if(slot<0)return;
        if(vote.SeenTic!=level.maptime){vote.SeenTic=level.maptime;vote.Seen=0;}
        vote.Seen|=1<<slot;
        if((vote.Seen&vote.AliveMask)==vote.AliveMask)vote.Pump();
    }
    void Pump()
    {
        if(!Running || LastPumpTic==level.maptime)return;
        LastPumpTic=level.maptime;if(!SafeGroup(true))return;
        let source=CaelumWorldClockTicker.CampaignOwner();let clock=CaelumWorldClock.Get(source);
        Remaining=(EndDays-clock.CompletedDays)*CaelumWorldClock.TicsPerDay()+EndTics-clock.DayTics;
        if(Remaining<=0){FinishVote("CA_COOP_TIME_COMPLETE");return;}
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)CaelumTimeAdvanceState.Get(Members[i],true).Pumping=true;
        // El mismo límite de x105 que el avance individual. Un reloj mundial,
        // seguido de todos los cuerpos, impide adelantos multiplicados por N.
        for(int step=1;step<CaelumWorldClock.TicsPerHour()/60 && Running;step++)
        {
            if(!SafeGroup(false))break;
            int before=clock.DayTics;int day=clock.CompletedDays;
            clock.AdvanceOnMap(level.MapName);
            CaelumWorldClockTicker.Mirror(source);
            CaelumHousekeepingWork.AdvanceSkippedTic(source);CaelumCampWorld.AdvanceFires();
            for(int i=0;i<MAXPLAYERS;i++)if((AliveMask&(1<<i))!=0)
                CaelumTimeAdvanceState.SimulatePersonalTic(Members[i],false);
            if(before!=clock.DayTics || day!=clock.CompletedDays)Remaining--;
            if(Remaining<=0)FinishVote("CA_COOP_TIME_COMPLETE");
        }
        for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null)
        {let advance=CaelumTimeAdvanceState.Get(Members[i]);if(advance!=null)advance.Pumping=false;}
    }
    override void Tick()
    {
        Super.Tick();
        if(Opened && !RosterValid())FinishVote("CA_COOP_TIME_CANCELLED");
        if(Opened && Running)for(int i=0;i<MAXPLAYERS;i++)if(Members[i]!=null && Living(Members[i])!=((AliveMask&(1<<i))!=0))
        {FinishVote("CA_REST_UNAVAILABLE");break;}
    }
    Default
    {
        Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
