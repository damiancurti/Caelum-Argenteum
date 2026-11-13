// #454: escolta real en corredores despejados, con un líder de prueba.
class CA454EscortProbe : EventHandler
{
    int Age,Stage,Step,StageStart,EndpointWait;
    bool Ready,Done;
    CaelumPlayer User;
    CaelumAnchoredResident Prisoner;
    Vector3 PreviousPrisoner;
    double LargestStep;

    override void WorldTick()
    {
        if(Done)return;
        Age++;
        if(!Ready)
        {
            if(Age<140)return;
            User=CaelumPlayer(players[0].mo);
            if(User==null)return;
            User.bInvulnerable=true;
            User.A_SetSize(CA454EscortData.RADIUS,CA454EscortData.HEIGHT);
            // Simula rutas ya despejadas. Se conserva la geometría, cubiertas
            // de fosos, IA de escolta, recursos y puerta cerrada del jefe.
            let enemies=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor enemy;
            while((enemy=CaelumCombatActor(enemies.Next()))!=null)
                if(enemy is "CaelumMandinga" || enemy is "CaelumGiantRat")enemy.Destroy();
            CA454EscortData.ClearHazards();
            CA454EscortData.GiveKeys(User);
            for(int tag=44700;tag<=44727;tag++)
            {
                if(tag==44703)continue;
                let gate=CaelumMazeBarredGate(ActorIterator.Create(tag,"CaelumMazeBarredGate").Next());
                if(gate!=null && !gate.Open(User)){Fail("gate");return;}
            }
            Ready=true;BeginStage();
        }
        if(Done)return;
        if(User.GetPrisonerRescueState(Stage)==CaelumConstants.PRISONER_STATE_EXTRACTED)
        {
            Console.Printf("CA454 ESCORT stage=%d PASS tics=%d largest_step=%.3f",Stage,Age-StageStart,LargestStep);
            Stage++;
            if(Stage==4){Done=true;User.Vel=(0,0,0);Console.Printf("CA454 ESCORT PASS all_four");return;}
            BeginStage();return;
        }
        if(Prisoner==null || Prisoner.health<=0){Fail("prisoner unavailable");return;}
        double moved=(Prisoner.Pos-PreviousPrisoner).Length();
        LargestStep=Max(LargestStep,moved);PreviousPrisoner=Prisoner.Pos;
        if(moved>64){Fail("unexpected prisoner relocation");return;}
        if(Age-StageStart>35000){Fail("route timeout");return;}
        if((Age-StageStart)%350==0)
            Console.Printf("CA454 ESCORT progress stage=%d waypoint=%d/%d leader=(%.1f,%.1f,%.1f) follower=(%.1f,%.1f,%.1f)",
                Stage,Step,CA454EscortData.Count(Stage),User.Pos.X,User.Pos.Y,User.Pos.Z,Prisoner.Pos.X,Prisoner.Pos.Y,Prisoner.Pos.Z);
        if(Step>=CA454EscortData.Count(Stage))
        {
            User.Vel=(0,0,0);EndpointWait++;
            if(EndpointWait>700)Fail("extraction endpoint timeout");
            return;
        }
        if(User.Distance2D(Prisoner)>256){User.Vel=(0,0,0);return;}
        vector3 target=CA454EscortData.Point(Stage,Step);
        vector2 delta=target.XY-User.Pos.XY;
        if(delta.Length()<4){Step++;User.Vel=(0,0,0);return;}
        User.Angle=VectorAngle(delta.X,delta.Y);
        double speed=Min(4.0,delta.Length());
        User.Vel.X=delta.X/delta.Length()*speed;User.Vel.Y=delta.Y/delta.Length()*speed;
    }

    void BeginStage()
    {
        Prisoner=CaelumAnchoredResident(ActorIterator.Create(44820+Stage,"CaelumAnchoredResident").Next());
        if(Prisoner==null){Fail("missing original prisoner");return;}
        User.SetOrigin(CA454EscortData.Point(Stage,0),false);User.FindFloorCeiling();User.Vel=(0,0,0);
        Prisoner.ReleaseEscortPrisoner(User);Prisoner.bInvulnerable=true;
        PreviousPrisoner=Prisoner.Pos;StageStart=Age;Step=1;LargestStep=0;EndpointWait=0;
        Console.Printf("CA454 ESCORT begin stage=%d prisoner=%s radius=%.3f height=%.3f",Stage,Prisoner.GetClassName(),Prisoner.Radius,Prisoner.Height);
    }

    void Fail(String reason)
    {
        Done=true;if(User!=null)User.Vel=(0,0,0);
        Console.Printf("CA454 ESCORT FAIL stage=%d step=%d reason=%s",Stage,Step,reason);
    }
}
