// Sonda aislada #121: nunca se incluye en el paquete distribuible.
class CA121Profiler : StaticEventHandler
{
    double Total[48], Own[48], Started[64], Children[64];
    int Calls[48], Keys[64], Depth;
    int Candidates, Sight, Decisions, Commands;
    static CA121Profiler Get() { return CA121Profiler(StaticEventHandler.Find("CA121Profiler")); }
    void Begin(int key)
    {
        if(Depth>=64)ThrowAbortException("CA121 profile stack overflow");
        Keys[Depth]=key;Children[Depth]=0;Started[Depth]=MSTimeF();Depth++;
    }
    void End(int key)
    {
        double now=MSTimeF();Depth--;
        if(Depth<0 || Keys[Depth]!=key)ThrowAbortException("CA121 unbalanced profile stack");
        double elapsed=now-Started[Depth];
        Total[key]+=elapsed;Own[key]+=elapsed-Children[Depth];Calls[key]++;
        if(Depth>0)Children[Depth-1]+=elapsed;
    }
    static void Candidate(int count=1) { if(level.time%37==0)Get().Candidates+=count; }
    static bool LOS(Actor body,Actor other)
    {
        if(level.time%37!=0)return body.CheckSight(other);
        let p=Get();p.Sight++;p.Begin(12);bool result=body.CheckSight(other);p.End(12);return result;
    }
    override void WorldTick()
    {
        if(level.time%37!=1)return;
        for(int i=0;i<48;i++)
        {
            if(Calls[i]>0)Console.Printf("CA121 COST tic=%d id=%d calls=%d inclusive=%.6f exclusive=%.6f",level.time-1,i,Calls[i],Total[i],Own[i]);
            Calls[i]=0;Total[i]=0;Own[i]=0;
        }
        Console.Printf("CA121 COUNT tic=%d candidates=%d sight=%d decisions=%d commands=%d",level.time-1,Candidates,Sight,Decisions,Commands);
        Candidates=0;Sight=0;Decisions=0;Commands=0;
    }
}

class CA121Observer : EventHandler
{
    Array<double> PreviousX, PreviousY;
    override void WorldTick()
    {
        if(level.time%35!=0)return;
        let port=CaelumPortSiege.Get();if(port==null || !port.RosterSealed)return;
        int alive=0,defenders=0,moving=0,blocked=0,displaced=0,contacts=0;
        double displacement=0;
        bool initialized=PreviousX.Size()==port.Attackers.Size();
        if(!initialized){PreviousX.Resize(port.Attackers.Size());PreviousY.Resize(port.Attackers.Size());}
        for(int i=0;i<port.Attackers.Size();i++)
        {
            let b=port.Attackers[i].Body;if(b==null || b.health<=0)continue;
            alive++;if(b.Vel.XY.Length()>0.01)moving++;
            if(initialized)
            {
                vector2 delta=(b.Pos.X-PreviousX[i],b.Pos.Y-PreviousY[i]);
                if(delta.Length()>0.01)displaced++;displacement+=delta.Length();
            }
            PreviousX[i]=b.Pos.X;PreviousY[i]=b.Pos.Y;contacts+=b.ImpactContacts.Size();
            if(b.BlockingMobj!=null || b.MovementBlockingLine!=null)blocked++;
        }
        for(int i=0;i<port.Defenders.Size();i++)if(port.Defenders[i]!=null && port.Defenders[i].health>0)defenders++;
        let user=players[0].mo;
        Console.Printf("CA121 SIM tic=%d ms=%.6f roster=%d attackers=%d defenders=%d groups=%d moving=%d blocked=%d x=%.3f y=%.3f z=%.3f angle=%.3f",level.time,MSTimeF(),port.Attackers.Size(),alive,defenders,port.Groups,moving,blocked,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
        Console.Printf("CA121 MOTION tic=%d displaced=%d distance=%.6f contacts=%d",level.time,displaced,displacement,contacts);
        if(level.time==35)Console.Printf("CA121 SETTINGS pause=%d lower=%d render=%d sound=%d volume=%.6f",CVar.GetCVar("i_pauseinbackground").GetInt(),CVar.GetCVar("vid_lowerinbackground").GetInt(),CVar.GetCVar("vid_activeinbackground").GetInt(),CVar.GetCVar("i_soundinbackground").GetInt(),CVar.GetCVar("snd_mastervolume").GetFloat());
        if(level.time==3500)Console.Printf("CA121 COMPLETE tic=%d",level.time);
    }
    ui double LastFrame;
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(LastFrame>0)Console.Printf("CA121 FRAME tic=%d ms=%.6f interval=%.6f",level.time,now,now-LastFrame);
        LastFrame=now;
    }
    override bool InputProcess(InputEvent e) { return true; }
}
