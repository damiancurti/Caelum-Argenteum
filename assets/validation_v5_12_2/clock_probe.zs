// Native multi-peer clock/rest checks; no fabricated occupied-seat state.
class CA436ClockProbe : EventHandler
{
    int Received[MAXPLAYERS],TotalRequests,Phase,Started,ClockStart,RestStart;
    ui bool Sent;
    ui int VoteSent;
    bool Sampled;
    CaelumCooperativeTime Proposal;
    double Hunger[MAXPLAYERS];
    CaelumRestChair Chairs[2];
    void Check(bool okay,String label)
    {Console.Printf("CA436 %s %s",okay?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0)return;
        if(!Sent && level.time>=TICRATE && players[consoleplayer].mo)
        {Sent=true;SendNetworkEvent("ca436_native_probe",consoleplayer,436,1);}
        if(Phase==4 && Proposal!=null && VoteSent!=Proposal.Serial)
        {VoteSent=Proposal.Serial;SendNetworkEvent("ca_cooperative_time",CaelumCooperativeTime.ACCEPT,Proposal.Serial);}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca436_native_probe")return;
        Received[e.Player]++;TotalRequests++;
        Console.Printf("CA436 EVENT peer=%d sender=%d serial=%d",consoleplayer,e.Player,TotalRequests);
    }
    bool Synchronized()
    {
        let source=CaelumWorldClockTicker.CampaignOwner();
        let clock=CaelumWorldClock.Get(source);let cal=CaelumCalendarState.Get(source);
        let weather=CaelumWeatherState.Get(source);
        if(clock==null || cal==null || weather==null)return false;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {
            let user=CaelumPlayer(players[i].mo);let other=CaelumWorldClock.Get(user);
            let calendar=CaelumCalendarState.Get(user);let climate=CaelumWeatherState.Get(user);
            if(other==null || calendar==null || climate==null || other.SharedRevision!=1
                || other.CompletedDays!=clock.CompletedDays || other.DayTics!=clock.DayTics
                || calendar.DateSerial(other)!=cal.DateSerial(clock)
                || calendar.CivilDayTics(other)!=cal.CivilDayTics(clock) || climate.Seed!=weather.Seed)return false;
        }
        return true;
    }
    override void WorldTick()
    {
        if(Phase==6 || level.time<TICRATE*3)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && Received[i]==0)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(Phase==0)
        {
            Check(CaelumWorldClockTicker.Ready(a) && CaelumWorldClockTicker.Ready(b),"committed native characters ready");
            Check(Synchronized(),"all peers share time date and weather seed");
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);
                user.SetOrigin((i*256-128,400,0),false);user.Vel=(0,0,0);
                user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=50;
                Chairs[i]=CaelumRestChair(Actor.Spawn('CaelumRestChair',(i*256-128,448,0),NO_REPLACE));
            }
            String reason=CaelumRestState.BlockReason(a);
            Check(reason=="","individual rest allowed with connected peers");
            if(reason!="")Console.Printf("CA436 DIAG rest=%s",reason);
            Check(CaelumRestState.Begin(a,CaelumRestRules.MODE_WAIT,5,Chairs[0]),"ordinary seat transaction succeeds");
            Check(Chairs[0].Occupant==a && CaelumRestState.Get(a).Furniture==Chairs[0],"real seat owns only first player");
            Check(!CaelumRestState.IsActive(b),"second player remains active");
            bool proposed=CaelumTimeAdvanceState.Toggle(a);
            let proposal=CaelumCooperativeTime.View(a);
            Check(proposed && proposal!=null && !proposal.Running,"proposal alone does not accelerate");
            if(proposal!=null)proposal.FinishVote("CA_COOP_TIME_CANCELLED");
            Check(!CaelumRestState.Begin(b,CaelumRestRules.MODE_WAIT,5,Chairs[0]),"occupied chair cannot be stolen");
            ClockStart=CaelumWorldClock.Get(a).DayTics;RestStart=CaelumRestState.Get(a).ElapsedTics;
            Started=level.time;Phase=1;return;
        }
        if(Phase==1 && !Sampled && level.time>Started)
        {
            ClockStart=CaelumWorldClock.Get(a).DayTics;RestStart=CaelumRestState.Get(a).ElapsedTics;
            Started=level.time;Sampled=true;return;
        }
        if(Phase==1 && Sampled && level.time-Started>=TICRATE)
        {
            Check(CaelumWorldClock.Get(a).DayTics-ClockStart==TICRATE,"one world second independent of player count");
            Check(Synchronized(),"replicas stay identical after normal simulation");
            Check(CaelumRestState.IsActive(a) && CaelumRestState.Get(a).ElapsedTics-RestStart==TICRATE,"rest progresses without acceleration");
            Check(CaelumRestState.Begin(b,CaelumRestRules.MODE_WAIT,5,Chairs[1]),"second player can sit independently");
            CaelumRestState.Cancel(a);
            Check(!CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b),"standing does not wake other player");
            Started=level.time;Phase=2;return;
        }
        if(Phase==2 && level.time-Started>=TICRATE)
        {
            Check(CaelumRestState.IsActive(b) && Chairs[1].Occupant==b,"remaining player stays seated through native tics");
            CaelumRestState.Cancel(b);
            Check(Chairs[0].Occupant==null && Chairs[1].Occupant==null,"cancel releases both seat collisions");
            let clock=CaelumWorldClock.Get(a);let cal=CaelumCalendarState.Get(a);
            int before=clock.DayTics;int date=cal.DateSerial(clock);int civil=cal.CivilDayTics(clock);
            for(int i=0;i<20;i++)clock.AdvanceOnMap("MAP01");
            CaelumWorldClockTicker.Mirror(a);
            Check(clock.DayTics==before+1 && cal.DateSerial(clock)==date && cal.CivilDayTics(clock)==civil && Synchronized(),"Limbo fraction and frozen civil date are shared");
            clock.SharedRevision=0;
            Check(CaelumWorldClockTicker.CampaignOwner()==b,"initialized replica precedes a fresh lower slot");
            CaelumWorldClockTicker.Mirror(b);
            int saved=CaelumWorldClock.Get(b).DayTics;
            a.CreationWizardOpen=true;
            bool successor=CaelumWorldClockTicker.CampaignOwner()==b && CaelumWorldClock.Get(b).DayTics==saved;
            a.CreationWizardOpen=false;
            Check(successor,"unavailable owner election preserves synchronized time");
            Check(CaelumCooperativeTime.Open(a),"exact-duration proposal opens");
            Proposal=CaelumCooperativeTime.View(a);
            Check(Proposal!=null && !Proposal.Request(b,CaelumCooperativeTime.HOUR_DOWN,Proposal.Serial),"only proposer edits duration");
            int old=Proposal.Serial;
            Check(Proposal.Request(a,CaelumCooperativeTime.HOUR_DOWN,old) && Proposal.Minutes==1,"duration uses existing one-minute minimum");
            Check(!Proposal.Request(a,CaelumCooperativeTime.ACCEPT,old),"stale duration consent rejected");
            Check(Proposal.Request(a,CaelumCooperativeTime.ACCEPT,Proposal.Serial) && !Proposal.Running,"one consent cannot start shared time");
            Check(!Proposal.Request(a,CaelumCooperativeTime.ACCEPT,Proposal.Serial),"duplicate consent rejected");
            Proposal.Request(a,CaelumCooperativeTime.MINUTE_UP,Proposal.Serial);
            Check(Proposal.Accepted==0 && Proposal.Minutes==2,"editing duration clears prior consent");
            Proposal.Request(a,CaelumCooperativeTime.HOUR_DOWN,Proposal.Serial);
            Phase=3;Started=level.time;ClockStart=clock.DayTics;
        }
        if(Phase==3 && level.time-Started>=TICRATE)
        {
            Check(!Proposal.Running && CaelumWorldClock.Get(a).DayTics-ClockStart==TICRATE,"silence advances only normal world time");
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Hunger[i]=CaelumPlayer(players[i].mo).CurrentHunger;
            Phase=4;return;
        }
        if(Phase==4 && Proposal!=null && !Proposal.Opened)
        {
            Check(Proposal.Accepted==Proposal.Mask && Proposal.Remaining<=0,"real peer consents complete shared duration");
            let clock=CaelumWorldClock.Get(a);
            Check(clock.CompletedDays==Proposal.EndDays && clock.DayTics>=Proposal.EndTics && clock.DayTics<=Proposal.EndTics+1,"duration counts native and extra clock tics exactly");
            bool costs=true;bool released=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);costs=costs && user.CurrentHunger<Hunger[i];
                released=released && CaelumCooperativeTime.View(user)==null;
            }
            Check(costs,"each participant pays personal survival costs");
            Check(released && Synchronized(),"completion releases all votes with synchronized clocks");
            int old=Proposal.Serial;
            CaelumCooperativeTime.Open(a);Proposal=CaelumCooperativeTime.View(a);
            Check(!Proposal.Request(b,CaelumCooperativeTime.ACCEPT,old),"previous proposal replay cannot consent again");
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Proposal.Request(CaelumPlayer(players[i].mo),CaelumCooperativeTime.ACCEPT,Proposal.Serial);
            int before=clock.DayTics;
            Check(Proposal.Running && Proposal.Request(b,CaelumCooperativeTime.CANCEL,Proposal.Serial) && !Proposal.Running
                && clock.DayTics==before,"any participant cancels before another extra tic");
            // Policy unit check: restore the fixture body before native death
            // handling. Full death/respawn integration belongs to #437.
            int health=b.health;int state=b.player.playerstate;
            b.health=0;b.player.playerstate=PST_DEAD;
            CaelumCooperativeTime.Open(a);Proposal=CaelumCooperativeTime.View(a);
            Proposal.Request(a,CaelumCooperativeTime.HOUR_DOWN,Proposal.Serial);
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Proposal.Request(CaelumPlayer(players[i].mo),CaelumCooperativeTime.ACCEPT,Proposal.Serial);
            Check(Proposal.Running && (Proposal.Accepted&2)!=0 && (Proposal.AliveMask&2)==0,"dead participant votes without joining physiology");
            double deadHunger=b.CurrentHunger;Proposal.Pump();
            Check(b.CurrentHunger==deadHunger && b.health==0,"shared substeps do not simulate dead body resources");
            Proposal.FinishVote("CA_COOP_TIME_CANCELLED");b.health=health;b.player.playerstate=state;
            CaelumCooperativeTime.Open(a);Proposal=CaelumCooperativeTime.View(a);
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Proposal.Request(CaelumPlayer(players[i].mo),CaelumCooperativeTime.ACCEPT,Proposal.Serial);
            b.health=0;b.player.playerstate=PST_DEAD;Proposal.Tick();
            Check(!Proposal.Running && !Proposal.Opened,"new death interrupts ongoing shared advance");
            b.health=health;b.player.playerstate=state;
            CaelumRestState.Begin(a,CaelumRestRules.MODE_WAIT,5,Chairs[0]);
            CaelumCooperativeTime.Open(a);Proposal=CaelumCooperativeTime.View(a);
            Check(Proposal.RestOnly && !Proposal.Request(b,CaelumCooperativeTime.ACCEPT,Proposal.Serial),"rest-origin proposal requires all living participants to rest");
            Proposal.FinishVote("CA_COOP_TIME_CANCELLED");CaelumRestState.Cancel(a);
            Phase=6;Console.Printf("CA436 RESULT peer=%d requests=%d",consoleplayer,TotalRequests);
        }
    }
}
