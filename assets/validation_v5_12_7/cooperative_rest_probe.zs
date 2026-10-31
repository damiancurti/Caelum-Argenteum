// Aceptaciones nativas; el avance sólo lo ejecutan los Tick reales del jugador.
class CA435RestProbe : StaticEventHandler
{
    int Phase,Started,ClockStart,RestStart[2];
    ui int SentPhase;
    CaelumCooperativeTime Vote;
    void Check(bool okay,String label)
    {Console.Printf("CA435REST %s %s",okay?"PASS":"FAIL",label);}
    override void UiTick()
    {
        if(gamestate!=GS_LEVEL || consoleplayer<0 || Vote==null || SentPhase==Phase)return;
        if((Phase==1 && consoleplayer==0) || Phase==3)
        {SentPhase=Phase;EventHandler.SendNetworkEvent("ca_cooperative_time",CaelumCooperativeTime.ACCEPT,Vote.Serial);}
        if(Phase==2 && consoleplayer==1)
        {SentPhase=Phase;EventHandler.SendNetworkEvent("ca_cooperative_time",CaelumCooperativeTime.CANCEL,Vote.Serial);}
        if(Phase==5 && consoleplayer==1)
        {SentPhase=Phase;EventHandler.SendNetworkEvent("ca512_secondary");}
    }
    override void WorldTick()
    {
        if(level.time<175 || Phase==6)return;
        let scene=CA512AuthorScene(StaticEventHandler.Find('CA512AuthorScene'));
        if(scene==null || !scene.Ready)return;
        let a=CaelumPlayer(players[0].mo);let b=CaelumPlayer(players[1].mo);
        if(Phase==0)
        {
            for(int i=0;i<2;i++)
            {
                let user=CaelumPlayer(players[i].mo);
                Check(CaelumRestState.Begin(user,CaelumRestRules.MODE_WAIT,480,scene.Chairs[i]),"seat with real furniture");
            }
            Check(CaelumCooperativeTime.Open(a),"open shared vote");
            Vote=CaelumCooperativeTime.View(a);Phase=1;Started=level.time;return;
        }
        if(Phase==1 && Vote.Accepted==1 && level.time-Started>=35)
        {Check(!Vote.Running && CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b),"one vote leaves both resting without acceleration");Phase=2;return;}
        if(Phase==2 && !Vote.Opened)
        {
            Check(CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b),"rejection preserves individual rest");
            Check(CaelumCooperativeTime.Open(a),"reopen after rejection");
            Vote=CaelumCooperativeTime.View(a);Phase=3;Started=level.time;return;
        }
        if(Phase==3 && Vote.Accepted==Vote.Mask)
        {
            Check(Vote.Running,"both native votes begin acceleration");
            ClockStart=CaelumWorldClock.Get(a).DayTics;
            for(int i=0;i<2;i++)RestStart[i]=CaelumRestState.Get(CaelumPlayer(players[i].mo)).ElapsedTics;
            Phase=4;Started=level.time;return;
        }
        if(Phase==4 && level.time-Started>=10)
        {
            int delta=CaelumWorldClock.Get(a).DayTics-ClockStart;
            Check(Vote.Running && CaelumRestState.IsActive(a) && CaelumRestState.IsActive(b),"real player ticks preserve both rests during acceleration");
            Check(delta==105*(level.time-Started),"one accelerated world clock independent of peer count");
            Check(CaelumWorldClock.Get(b).DayTics==CaelumWorldClock.Get(a).DayTics,"clock replicas match");
            for(int i=0;i<2;i++)Check(CaelumRestState.Get(CaelumPlayer(players[i].mo)).ElapsedTics-RestStart[i]==delta,"each body receives exactly the elapsed rest tics");
            Console.Printf("CA435REST DIAG elapsed=%d clock=%d",level.time-Started,delta);
            Phase=5;Started=level.time;return;
        }
        if(Phase==5 && level.time-Started>=10)
        {
            Check(!Vote.Running && CaelumRestState.IsActive(a) && !CaelumRestState.IsActive(b),"one player standing stops acceleration without waking the other");
            let clock=CaelumWorldClock.Get(a);clock.AdvanceTics(2);CaelumWorldClockTicker.Mirror(a);
            CaelumRestState.Validate(a);
            Check(!CaelumRestState.IsActive(a) && CaelumRestState.Get(a).ResultKey=="CA_REST_TIME_CHANGED","external clock jump still interrupts rest");
            Phase=6;Console.Printf("CA435REST RESULT real-tick cooperative regression complete");
        }
    }
}
