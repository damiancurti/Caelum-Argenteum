// Console waits continue during native menu pause. Wait for the actual job,
// then allow the original 35 native tics for resident collision-safe placement.
class CA415ArrivalHarness : EventHandler
{
    int Pending,VerifyAfter,StartNative,StartWorld;
    bool SawRunning,RetainedClocks;
    ui bool Sent;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca415_await")
        {
            Pending=e.Args[0];VerifyAfter=level.maptime+35;
            let job=CaelumAbsentArrival.Find();SawRunning=job!=null && job.Running;
            RetainedClocks=true;StartNative=level.time;
            let user=CaelumPlayer(players[0].mo);StartWorld=CaelumWorldClock.Get(user).DayTics;
            Console.Printf("CA415A BEGIN pending=%d running=%d native=%d verify=%d",Pending,SawRunning,StartNative,VerifyAfter);
        }
        else if(e.Name=="ca415_awaitdone")
        {
            let job=CaelumAbsentArrival.Find();
            bool passed=job!=null && !job.Running && job.Pulses>0 && RetainedClocks;
            Console.Printf("CA415A %s production arrival completes before native play resumes",passed?"PASS":"FAIL");
            Console.Printf("CA415A DETAIL observedRunning=%d pulses=%d native=%d/%d",SawRunning,job!=null?job.Pulses:0,StartNative,level.time);
            Console.Printf("CA415A RESULT passed=%d failed=%d",passed?1:0,passed?0:1);
            Pending=0;
        }
        else if(e.Name=="ca_absent_arrival" && Pending>0 && SawRunning)
        {
            let job=CaelumAbsentArrival.Find();let user=CaelumPlayer(players[0].mo);
            if(job!=null && job.Running)
                RetainedClocks=RetainedClocks && level.time==StartNative && CaelumWorldClock.Get(user).DayTics==StartWorld;
            if(job!=null && (job.Pulses%100==0 || !job.Running))Console.Printf("CA415A PROGRESS pulse=%d battle=%d/%d body=%d/%d running=%d",job.Pulses,job.BattleCursor,job.Battles.Size(),job.BodyCursor,job.Bodies.Size(),job.Running);
        }
    }
    override void UiTick()
    {
        if(Pending<=0 || Sent || level.maptime<VerifyAfter)return;
        let events=CaelumAbsentArrivalEvents(StaticEventHandler.Find('CaelumAbsentArrivalEvents'));
        if(events!=null && events.Job!=null && events.Job.Running)return;
        Sent=true;
        String names[]={"","ca415r_hub","ca415r_residenthome","ca415r_residentdeath","ca415r_flighthome","ca415r_calendarhome","ca415r_workarrival","ca415r_firsthome","ca415t_hubdone","ca415t_dispatchloaded"};
        EventHandler.SendNetworkEvent(names[Pending]);EventHandler.SendNetworkEvent("ca415_awaitdone");
    }
}
