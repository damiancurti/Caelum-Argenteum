// Recorrido de geometría real con combate y activadores de trampas aislados.
// El conductor usa colisión nativa; no reubica a los acompañantes liberados.
class CA322Campaign : CA282Probe
{
    Array<CaelumAnchoredResident> Bodies;
    Array<double> LastX,LastY;
    bool Running,Finished,QuitQueued,Overlap,Relocated;
    int Cursor,Age,Still,Settling;
    Vector3 LastPlayer;

    void Release(int id)
    {
        let body=CaelumAnchoredResident(ActorIterator.Create(CaelumConstants.PRISONER_TID_BASE+id).Next());
        Check(body!=null,"campaign retains original captive at its authored cell");
        if(body==null)return;
        User.player.ConversationNPC=body;
        let action=User.GiveInventoryType("CaelumPrisonerReleaseAction");
        Check(action.Use(false),"native dialogue release action succeeds");
        User.player.ConversationNPC=null;body.bInConversation=false;
        Bodies.Push(body);LastX.Push(body.Pos.X);LastY.Push(body.Pos.Y);
        Check(User.GetPrisonerRescueState(id)==CaelumConstants.PRISONER_STATE_FOLLOWING,"campaign release progression is following");
    }

    void Start()
    {
        Setup();
        // Census is diagnostic-only, performed once before route timing.
        let actors=ThinkerIterator.Create("Actor");Actor actor;
        while((actor=Actor(actors.Next()))!=null)
        {
            let combat=CaelumCombatActor(actor);
            let escort=CaelumAnchoredResident(actor);
            if(combat!=null && (escort==null || !escort.IsEscortPrisoner())){actor.Destroy();continue;}
            let plate=CaelumPressureTrap(actor);if(plate!=null)plate.Spent=true;
            let hatch=CaelumTrapdoor(actor);if(hatch!=null)hatch.Opened=true;
        }
        Class<Inventory> keys[]={"CaelumMazeSluiceKey","CaelumMazeCryptKey","CaelumMazeSanctumKey",
            "CaelumMazeSouthCellKey","CaelumMazeWestCellKey","CaelumMazeEastCellKey","CaelumMazeNorthCellKey"};
        foreach(key:keys)User.GiveInventoryType(key);
        let gates=ThinkerIterator.Create("CaelumMazeBarredGate");CaelumMazeBarredGate gate;
        while((gate=CaelumMazeBarredGate(gates.Next()))!=null)
            if(gate.tid!=CaelumConstants.PRISONER_BOSS_GATE_TID)Check(gate.Open(User),"production gate opens with retained native key");
        User.SetOrigin(CA322RouteData.Point(0),false);User.Vel=(0,0,0);
        LastPlayer=User.Pos;Running=true;
    }

    override void WorldTick()
    {
        if(!Running)return;
        Age++;User.Vel=(0,0,0);User.player.cmd.forwardmove=0;User.player.cmd.sidemove=0;
        bool waitForEscort=false;
        for(int i=0;i<Bodies.Size();i++)
        {
            let body=Bodies[i];if(body==null)continue;
            if((body.Pos.XY-(LastX[i],LastY[i])).Length()>body.Radius*4)Relocated=true;
            LastX[i]=body.Pos.X;LastY[i]=body.Pos.Y;
            if(body.Distance2D(User)>CaelumConstants.PRISONER_FOLLOW_TELEPORT_DISTANCE/2)waitForEscort=true;
            double r=body.Radius+User.Radius;
            if(abs(body.Pos.X-User.Pos.X)<r-0.001 && abs(body.Pos.Y-User.Pos.Y)<r-0.001)Overlap=true;
            for(int j=i+1;j<Bodies.Size();j++)if(Bodies[j]!=null)
            {
                let other=Bodies[j];r=body.Radius+other.Radius;
                if(abs(body.Pos.X-other.Pos.X)<r-0.001 && abs(body.Pos.Y-other.Pos.Y)<r-0.001)Overlap=true;
            }
        }
        if(Cursor<CA322RouteData.COUNT && !waitForEscort)
        {
            vector3 destination=CA322RouteData.Point(Cursor);
            vector2 delta=destination.XY-User.Pos.XY;
            if(delta.Length()<=3)
            {int id=CA322RouteData.ReleaseAt(Cursor);if(id>=0)Release(id);Cursor++;}
            else
            {
                User.Angle=VectorAngle(delta.X,delta.Y);User.player.cmd.forwardmove=1;
                User.TryMove(User.Pos.XY+delta.Unit()*Min(3.0,delta.Length()),0);
            }
        }
        bool allExtracted=Bodies.Size()==4;
        for(int i=0;i<4;i++)if(User.GetPrisonerRescueState(i)!=CaelumConstants.PRISONER_STATE_EXTRACTED)allExtracted=false;
        if(Cursor==CA322RouteData.COUNT && allExtracted)Finish();
        if((User.Pos-LastPlayer).Length()<0.001)Still++;else Still=0;
        LastPlayer=User.Pos;
        if(Still>35*60 || Age>35*1200){Check(false,"campaign driver reached timeout");Finish();}
        if(Age%350==0)
        {
            Console.Printf("CA322 CAMPAIGN tic=%d point=%d/%d player=(%.2f,%.2f,%.2f) waiting=%d",Age,Cursor,CA322RouteData.COUNT,User.Pos.X,User.Pos.Y,User.Pos.Z,waitForEscort);
            foreach(body:Bodies)if(body!=null)Console.Printf("CA322 CAMPAIGNFOLLOW id=%d pos=(%.2f,%.2f,%.2f) gap=%.2f trail=%d path=%d",body.EscortPrisonerId,body.Pos.X,body.Pos.Y,body.Pos.Z,body.Distance2D(User),body.EscortControl.TrailSize(),body.EscortControl.Path!=null);
        }
    }
    void Finish()
    {
        Running=false;User.player.cmd.forwardmove=0;
        Check(Cursor==CA322RouteData.COUNT,"player walked the entire four-cell to extraction itinerary");
        Check(!Overlap && !Relocated,"campaign escort used physical movement without overlap or recovery teleport");
        for(int i=0;i<4;i++)Check(User.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_EXTRACTED,"original prisoner reached extraction with native progression");
        Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);Finished=true;
    }
    override void UiTick()
    {
        Super.UiTick();
        if(Finished && !QuitQueued){QuitQueued=true;ConsoleCommand("save campaign-finish.zds; wait 10; quit");}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c322_campaign")Start();
    }
}
