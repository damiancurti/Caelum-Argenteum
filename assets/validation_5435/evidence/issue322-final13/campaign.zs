// Recorrido de geometría real con combate y activadores de trampas aislados.
// El conductor usa colisión nativa; no reubica a los acompañantes liberados.
class CA322PortSnapshot : Actor
{
    double Money;
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA322Campaign : CA322Probe
{
    Array<CaelumAnchoredResident> Bodies;
    Array<double> LastX,LastY;
    bool Running,Finished,Relocated;
    int Cursor,Still;
    Vector3 LastPlayer;

    void Release(int id)
    {
        let body=CaelumAnchoredResident(ActorIterator.Create(CaelumConstants.PRISONER_TID_BASE+id).Next());
        Check(body!=null,"campaign retains original captive at its authored cell");
        if(body==null)return;
        User.player.ConversationNPC=body;
        let releaseItem=Inventory(Actor.Spawn("CaelumPrisonerReleaseAction"));
        releaseItem.AttachToOwner(User);
        Check(releaseItem.Use(false),"native dialogue release action succeeds");
        releaseItem.Destroy();
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
        Super.WorldTick();
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
                if(!User.TryMove(User.Pos.XY+delta.Unit()*Min(3.0,delta.Length()),0))
                {
                    // El itinerario geométrico no conoce los cofres sólidos.
                    // El jugador conductor rodea su borde con pasos nativos.
                    vector2 forward=delta.Unit(),side=(-forward.Y,forward.X);
                    let blocker=User.BlockingMobj;
                    if(blocker!=null && (blocker.Pos.XY-User.Pos.XY) dot side>0)side=-side;
                    if(Sidesteps%35==0)Console.Printf("CA322 CAMPAIGNBLOCK point=%d actor=%s player=(%.2f,%.2f,%.2f)",Cursor,blocker==null ? 'line' : blocker.GetClassName(),User.Pos.X,User.Pos.Y,User.Pos.Z);
                    if(User.TryMove(User.Pos.XY+side*3,0) || User.TryMove(User.Pos.XY-side*3,0))Sidesteps++;
                }
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
            foreach(body:Bodies)if(body!=null && body.EscortControl.TrailSize()>0)
            {
                let control=body.EscortControl;vector3 point=control.TrailPoint(0);
                Console.Printf("CA322 CAMPAIGNGOAL id=%d goal=(%.2f,%.2f,%.2f) radius=%.3f cursor=%d count=%d",body.EscortPrisonerId,point.X,point.Y,point.Z,body.Radius,control.Path==null ? 0 : control.Path.Cursor,control.Path==null ? 0 : control.Path.PointX.Size());
            }
        }
    }
    void Finish()
    {
        Running=false;User.player.cmd.forwardmove=0;
        Check(Cursor==CA322RouteData.COUNT,"player walked the entire four-cell to extraction itinerary");
        Check(!Overlap && !Relocated,"campaign escort used physical movement without overlap or recovery teleport");
        for(int i=0;i<4;i++)Check(User.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_EXTRACTED,"original prisoner reached extraction with native progression");
        Console.Printf("CA322 CAMPAIGNRESULT points=%d sidesteps=%d",Cursor,Sidesteps);
        Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);Finished=true;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c322_resume")
        {
            User=CaelumPlayer(players[consoleplayer].mo);Running=true;Finished=false;
            Still=0;Passed=0;Failed=0;Age=0;Cursor=e.Args[0];LastPlayer=User.Pos;
            for(int i=0;i<4;i++)if(User.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_FOLLOWING)
            {
                let body=CaelumAnchoredResident(ActorIterator.Create(CaelumConstants.PRISONER_TID_BASE+i).Next());
                if(body!=null){Bodies.Push(body);LastX.Push(body.Pos.X);LastY.Push(body.Pos.Y);}
            }
            Console.Printf("CA322 RESUME bodies=%d player=(%.3f,%.3f)",Bodies.Size(),User.Pos.X,User.Pos.Y);
            foreach(body:Bodies)if(body.EscortControl!=null && body.EscortControl.TrailSize()>0)
            {
                let control=body.EscortControl;vector3 point=control.TrailPoint(0);
                Console.Printf("CA322 RESUMEGOAL id=%d body=(%.3f,%.3f) goal=(%.3f,%.3f) gap=%.3f radius=%.3f",body.EscortPrisonerId,body.Pos.X,body.Pos.Y,point.X,point.Y,(point.XY-body.Pos.XY).Length(),body.Radius);
            }
        }
        if(e.Name=="c322_chestcheck")
        {
            Running=false;Check(Cursor>51,"wider followers pass the original solid campaign chest");
            Check(!Overlap && !Relocated,"chest detour retains collision and does not relocate followers");
            Console.Printf("CA322 CHESTRESULT age=%d point=%d bodies=%d",Age,Cursor,Bodies.Size());
            Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
        }
        if(e.Name=="c322_campaign")Start();
        if(e.Name=="c322_campaigncheck" && Running)Finish();
        if(e.Name=="c322_port")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            double before=User.GetOwnedMoneyCopperValue();
            for(int i=0;i<4;i++)
            {
                let body=CaelumAnchoredResident(ActorIterator.Create(CaelumConstants.PRISONER_PORT_TID_BASE+i).Next());
                Check(body!=null && body.EscortPrisonerPort && body.EscortPrisonerId==i,"correct extracted prisoner is present at native port destination");
                if(body==null)continue;
                User.player.ConversationNPC=body;
                let claimItem=Inventory(Actor.Spawn("CaelumPrisonerClaimAction"));claimItem.AttachToOwner(User);
                Check(claimItem.Use(false),"native destination dialogue pays rescue reward");
                double paid=User.GetOwnedMoneyCopperValue();
                Check(!claimItem.Use(false) && User.GetOwnedMoneyCopperValue()==paid,"repeated dialogue cannot duplicate reward");
                claimItem.Destroy();User.player.ConversationNPC=null;
            }
            Check(User.GetOwnedMoneyCopperValue()==before+4*CaelumConstants.PRISONER_RESCUE_COPPER_REWARD,"four rescues pay exactly four authored rewards");
            let saved=CA322PortSnapshot(Actor.Spawn("CA322PortSnapshot",User.Pos,NO_REPLACE));saved.Money=User.GetOwnedMoneyCopperValue();
            Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
        }
        if(e.Name=="c322_portreload")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let saved=CA322PortSnapshot(ThinkerIterator.Create("CA322PortSnapshot").Next());
            Check(saved!=null && saved.Money==User.GetOwnedMoneyCopperValue(),"destination save retains exact rescued reward total");
            for(int i=0;i<4;i++)
            {
                int count=0;let it=ActorIterator.Create(CaelumConstants.PRISONER_PORT_TID_BASE+i);Actor body;
                while((body=it.Next())!=null)if(body is "CaelumAnchoredResident")count++;
                Check(count==1 && User.IsPlayerPrisonerRewardClaimed(i),"load or hub return retains one destination body and paid state");
                Check(!User.ClaimPrisonerPortReward(i,CaelumPrisonerRescue.FactionFor(i)),"saved paid reward cannot be claimed twice");
            }
            Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
        }
        if(e.Name=="c322_sewerreturn")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            for(int i=0;i<4;i++)Check(ActorIterator.Create(CaelumConstants.PRISONER_TID_BASE+i).Next()==null
                && User.GetPrisonerRescueState(i)==CaelumConstants.PRISONER_STATE_EXTRACTED,"return to sewer does not recreate extracted prisoner");
        }
    }
}
