// Observador comun sobre los paquetes completos: no altera las reglas de IA.
class CA510Performance : EventHandler
{
    const SIEGE=1;
    const GROUND=0;
    int Age,StartTic;
    bool Started,Finished;
    double CandidateMS,NoiseMS,CommunicationMS,AcquireMS;
    int CandidateCalls,NoiseCalls,CommunicationCalls,AcquireCalls;
    Array<double> TicMS;
    double PreviousTic;
    ui Array<double> FrameMS;
    ui double PreviousFrame;
    ui bool FrameWindow;
    ui Array<int> FrameTics;
    ui Array<double> FrameStamps;
    Array<double> TicStamps;

    override bool InputProcess(InputEvent e) { return true; }

    void Census(String label){CA435CampaignCensus.Report(label);}

    override void WorldTick()
    {
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(Age==5) for(int slot=0;slot<MAXPLAYERS;slot++) if(playeringame[slot])
        {
            let user=CaelumPlayer(players[slot].mo);if(user==null)continue;
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;
            let record=user.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
        }
        if(Age==135 && SIEGE) for(int slot=0;slot<MAXPLAYERS;slot++) if(playeringame[slot])
        {
            let user=CaelumPlayer(players[slot].mo);if(user==null)continue;
            let clock=CaelumWorldClock.Get(user,true);let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
        }
        if(Age==(SIEGE ? 3600 : 350))
        {
            for(int slot=0;slot<MAXPLAYERS;slot++) if(playeringame[slot])
            {
                let user=CaelumPlayer(players[slot].mo);if(user==null)continue;
                if(level.MapName=="MAP03")
                {
                vector3 point=SIEGE ? (-14464,-14000,0) : (0,320,0);
                if(CaelumBarracasData.IsCurrent())
                {
                    if(SIEGE)
                    {
                        int gate=CaelumBarracasFrontData.GateForLane(0);
                        double outward=CaelumBarracasFrontData.GateOutward(gate);
                        point=CaelumBarracasFrontData.GatePoint(gate)-(Cos(outward),Sin(outward),0)*CaelumPortData.ROUTE_RADIUS*2;
                    }
                    else point=CaelumBarracasData.CurrentPortPoint(point);
                }
                user.SetOrigin(point,false);user.FindFloorCeiling();user.SetOrigin((point.X,point.Y,user.FloorZ),false);
                user.Angle=SIEGE ? 270 : CaelumBarracasData.CurrentPortAngle(180);
            }
            user.Pitch=GROUND ? 75 : 0;user.Vel=(0,0,0);
            }
            Started=true;StartTic=level.time;Census("start");
            Console.Printf("CA510 BEGIN map=%s tic=%d ms=%.6f",level.MapName,level.time,MSTimeF());
        }
        if(!Started || Finished)return;
        double now=MSTimeF();TicStamps.Push(now);if(PreviousTic>0)TicMS.Push(now-PreviousTic);PreviousTic=now;
        if(level.time-StartTic>=700)
        {
            Finished=true;Census("end");
            Console.Printf("CA510 PROFILE candidate_ms=%.6f candidate_calls=%d noise_ms=%.6f noise_calls=%d communication_ms=%.6f communication_calls=%d acquire_ms=%.6f acquire_calls=%d",
                CandidateMS,CandidateCalls,NoiseMS,NoiseCalls,CommunicationMS,CommunicationCalls,AcquireMS,AcquireCalls);
            Console.Printf("CA510 END tic=%d ms=%.6f",level.time,now);
            for(int i=0;i<TicMS.Size();i++)Console.Printf("CA510 TIC %.6f",TicMS[i]);
            for(int i=0;i<TicStamps.Size();i++)Console.Printf("CA873 TICK_TIME i=%d ms=%.6f",i,TicStamps[i]);
            Console.Printf("CA510 RESULT normal campaign window complete");
        }
    }

    override void RenderOverlay(RenderEvent e)
    {
        if(!Started || Finished || level.time-StartTic<70)return;
        double now=MSTimeF();if(PreviousFrame>0 && FrameMS.Size()<8192)FrameMS.Push(now-PreviousFrame);
        FrameTics.Push(level.time);FrameStamps.Push(now);
        PreviousFrame=now;FrameWindow=true;
    }

    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca873_mark"){Console.Printf("CA873 NATIVE_MARK tic=%d ms=%.6f",level.time,MSTimeF());return;}
        if(e.Name!="ca510_frames")return;
        for(int i=0;i<FrameMS.Size();i++)Console.Printf("CA510 FRAME %.6f",FrameMS[i]);
        Console.Printf("CA510 FRAMES_END count=%d",FrameMS.Size());
        for(int i=0;i<FrameTics.Size();i++)Console.Printf("CA873 FRAME_TIME i=%d tic=%d ms=%.6f",i,FrameTics[i],FrameStamps[i]);
    }
}
