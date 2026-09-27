// #20: el cabezal visible es el actor que barre el contacto nativo.
class CaelumRamPoint : Object { vector3 Position; }
class CaelumRamFrameVisual : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: CRFR A -1; Stop; }
}
class CaelumRamSuspension : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: CRSP A -1; Stop; }
}
class CaelumRamBlock : Actor
{
    Default { Radius 10; Height 30; +SOLID +NOGRAVITY +NODAMAGETHRUST }
    States { Spawn: TNT1 A -1; Stop; }
}
class CaelumRamHead : CaelumRamBlock
{
    // El controlador mueve el actor con TryMove; no hay un segundo avance.
    override void Tick() { }
    States { Spawn: CRHD A -1; Stop; }
}

class CaelumBatteringRam : CaelumHostileMachine
{
    const READY = 0;
    const APPROACH = 1;
    const STRIKE = 2;
    const CONTACT = 3;
    const RECOVERY = 4;
    bool Initialized, Large, Enabled, Obstructed;
    double SizeFactor, AssemblyMass, StrokeOffset, ApproachSpeed;
    double FinalAngle;
    int Phase, RecoveryLeft, StrikeSerial, ImpactCount;
    bool SpentImpact;
    vector3 LastContactVelocity;
    Actor LastContact;
    int LastDamage;
    Array<CaelumRamPoint> Route;
    int RouteIndex;
    CaelumBreakableGate TargetGate;
    CaelumRamFrameVisual FrameVisual;
    CaelumRamHead Head;
    Array<CaelumRamBlock> FrameBlocks;
    Array<CaelumRamPoint> FrameOffsets;
    Array<CaelumRamSuspension> Rods;
    Array<CaelumRamBlock> FaceBlocks;

    vector3 LocalPosition(vector3 origin, double facing, vector3 local)
    {
        return origin + ((Cos(facing)*local.X-Sin(facing)*local.Y)*SizeFactor,
            (Sin(facing)*local.X+Cos(facing)*local.Y)*SizeFactor, local.Z*SizeFactor);
    }

    void InitializeRam()
    {
        if (Initialized) return;
        Initialized = true;
        SizeFactor = Large ? CaelumRamData.LARGE_SCALE : 1.0;
        RequiredCrew = Large ? CaelumRamData.LARGE_CREW : CaelumRamData.SMALL_CREW;
        AssemblyMass = CaelumRamData.MOVING_MASS * SizeFactor*SizeFactor*SizeFactor;
        Mass = int((CaelumRamData.FRAME_MASS + CaelumRamData.MOVING_MASS)
            * SizeFactor*SizeFactor*SizeFactor);
        GuardRadius = CaelumRamData.GUARD_RADIUS * SizeFactor;
        ApproachSpeed = CaelumRamData.APPROACH_SPEED;
        StrokeOffset = CaelumRamData.RETRACT;
        FrameVisual = CaelumRamFrameVisual(Spawn("CaelumRamFrameVisual", Pos, NO_REPLACE));
        FrameVisual.master = self;
        FrameVisual.Scale = (SizeFactor, SizeFactor);
        Head = CaelumRamHead(Spawn("CaelumRamHead", Pos, NO_REPLACE));
        Head.master = self;
        Head.Scale = (SizeFactor, SizeFactor);
        Head.A_SetSize(CaelumRamData.HEAD_RADIUS*SizeFactor, CaelumRamData.HEAD_HEIGHT*SizeFactor);
        Head.Mass = int(AssemblyMass);
        for (int i=0; i<CaelumRamData.FACE_BLOCKS; i++)
        {
            let block=CaelumRamBlock(Spawn("CaelumRamBlock",Pos,NO_REPLACE));
            block.master=self;
            block.A_SetSize(CaelumRamData.HEAD_RADIUS*SizeFactor,CaelumRamData.HEAD_HEIGHT*SizeFactor);
            FaceBlocks.Push(block);
        }
        // Cobertura finita del chasis; dimensiones de la referencia visual.
        for (int x = 0; x < CaelumRamData.FRAME_COLUMNS; x++)
            for (int y = 0; y < CaelumRamData.FRAME_ROWS; y++)
            {
                vector3 local = (CaelumRamData.FRAME_REAR + CaelumRamData.BLOCK_RADIUS + x*CaelumRamData.FRAME_STEP_X,
                    -CaelumRamData.FRAME_HALF_WIDTH + CaelumRamData.BLOCK_RADIUS + y*CaelumRamData.FRAME_STEP_Y, 0);
                let block = CaelumRamBlock(Spawn("CaelumRamBlock", Pos, NO_REPLACE));
                block.master = self;
                block.A_SetSize(CaelumRamData.BLOCK_RADIUS*SizeFactor, CaelumRamData.FRAME_HEIGHT*SizeFactor);
                let point = new("CaelumRamPoint"); point.Position=local;
                FrameBlocks.Push(block); FrameOffsets.Push(point);
            }
        for (int i = 0; i < 4; i++)
        {
            let rod = CaelumRamSuspension(Spawn("CaelumRamSuspension", Pos, NO_REPLACE));
            rod.master = self; Rods.Push(rod);
        }
        PlaceComponents();
    }

    void PlaceComponents()
    {
        FrameVisual.SetOrigin(Pos, false); FrameVisual.Angle = Angle;
        Head.SetOrigin(LocalPosition(Pos, Angle,
            (CaelumRamData.HEAD_X+StrokeOffset, 0, CaelumRamData.HEAD_Z)), false);
        Head.Angle = Angle;
        for (int i=0; i<FaceBlocks.Size(); i++)
            FaceBlocks[i].SetOrigin(LocalPosition(Pos,Angle,
                (CaelumRamData.HEAD_X+StrokeOffset,CaelumRamData.FACE_START_Y+i*CaelumRamData.FACE_STEP_Y,CaelumRamData.HEAD_Z)),false);
        for (int i = 0; i < FrameBlocks.Size(); i++)
            FrameBlocks[i].SetOrigin(LocalPosition(Pos, Angle, FrameOffsets[i].Position), false);
        for (int i = 0; i < Rods.Size(); i++)
        {
            double x = i < 2 ? CaelumRamData.ROD_REAR_X : CaelumRamData.ROD_FRONT_X;
            double y = (i%2 == 0 ? -1 : 1)*CaelumRamData.ROD_Y;
            vector3 bottom = LocalPosition(Pos, Angle, (x+StrokeOffset,y,CaelumRamData.ROD_BOTTOM_Z));
            vector3 top = LocalPosition(Pos, Angle, (x,y,CaelumRamData.ROD_TOP_Z));
            vector3 delta = top-bottom;
            Rods[i].SetOrigin(bottom,false);
            Rods[i].Angle = VectorAngle(delta.X,delta.Y);
            Rods[i].Pitch = VectorAngle(delta.XY.Length(),delta.Z);
            Rods[i].Scale = (delta.Length(),delta.Length());
        }
    }

    void SetOwnSolidity(bool solid)
    {
        Head.bSolid = solid;
        for (int i=0; i<FaceBlocks.Size(); i++) FaceBlocks[i].bSolid=solid;
        for (int i = 0; i < FrameBlocks.Size(); i++) FrameBlocks[i].bSolid = solid;
    }

    bool MoveFrame(vector3 destination, double facing)
    {
        SetOwnSolidity(false);
        bool clear = true;
        for (int i = 0; i < FrameBlocks.Size(); i++)
        {
            vector3 desired = LocalPosition(destination,facing,FrameOffsets[i].Position);
            FrameBlocks[i].bSolid=true;
            clear=FrameBlocks[i].TryMove(desired.XY,false);
            if (clear && Abs(FrameBlocks[i].FloorZ-destination.Z)>0.01) clear=false;
            FrameBlocks[i].bSolid=false;
            if (!clear) break;
        }
        if (clear)
        {
            vector3 desired = LocalPosition(destination,facing,
                (CaelumRamData.HEAD_X+StrokeOffset,0,CaelumRamData.HEAD_Z));
            Head.bSolid=true;
            clear = Head.TryMove(desired.XY,false);
            Head.bSolid=false;
        }
        for (int i=0; clear && i<FaceBlocks.Size(); i++)
        {
            vector3 desired=LocalPosition(destination,facing,
                (CaelumRamData.HEAD_X+StrokeOffset,CaelumRamData.FACE_START_Y+i*CaelumRamData.FACE_STEP_Y,CaelumRamData.HEAD_Z));
            FaceBlocks[i].bSolid=true;
            clear=FaceBlocks[i].TryMove(desired.XY,false);
            FaceBlocks[i].bSolid=false;
        }
        if (clear) { SetOrigin(destination,false); Angle=facing; }
        PlaceComponents();
        SetOwnSolidity(true);
        Obstructed = !clear;
        return clear;
    }

    bool SetRoute(CaelumBreakableGate gate, double facing)
    {
        InitializeRam();
        if (Neutralized || Phase == STRIKE || Phase == CONTACT || Phase == RECOVERY) return false;
        TargetGate = gate; FinalAngle = facing; Route.Clear(); RouteIndex = 0;
        return true;
    }

    bool ActivateRam()
    {
        InitializeRam();
        if (!ArmMachine()) return false;
        Enabled = true;
        return true;
    }

    void AddRoutePoint(vector3 position)
    {
        let point = new("CaelumRamPoint"); point.Position=position; Route.Push(point);
    }

    void ApplyContact(Actor hit)
    {
        if (SpentImpact) return;
        SpentImpact = true; ImpactCount++; LastContact = hit; LastDamage = 0;
        LastContactVelocity = Head.Vel;
        Phase = CONTACT;
        if (hit == null) return;
        vector3 normal = (Cos(Angle),Sin(Angle),0);
        let gateBlock = CaelumGateBlocker(hit);
        if (gateBlock != null)
        {
            let gate = CaelumBreakableGate(gateBlock.master);
            if (gate != null)
            {
                normal=(-Sin(gate.Angle),Cos(gate.Angle),0);
                if (normal.X*Head.Vel.X+normal.Y*Head.Vel.Y<0)normal=-normal;
                LastDamage = gate.ApplySiegeImpact(Head,StrikeSerial,AssemblyMass,Head.Vel,normal);
            }
            return;
        }
        let user = CaelumPlayer(hit);
        let npc = CaelumCombatActor(hit);
        if (user == null && npc == null) return;
        if (npc!=null && npc.DisableCaelumImpactContacts) return;
        ImpactBody body = user != null ? user.BuildImpactPhysicsBody() : npc.BuildImpactPhysicsBody();
        let moving = new("ImpactBody");
        moving.Mass=AssemblyMass; moving.Height=Head.Height; moving.Position=Head.Pos;
        moving.Velocity=Head.Vel; moving.Restitution=CaelumConstants.IMPACT_RESTITUTION;
        moving.SurfaceMultiplier=1;
        let result = new("ImpactResult");
        ImpactPhysics.ResolveBodies(moving,body,normal,result);
        if (!result.Valid) return;
        hit.Vel.X+=result.Normal.X*result.TargetDeltaSpeed;
        hit.Vel.Y+=result.Normal.Y*result.TargetDeltaSpeed;
        int before = hit.health;
        if (user != null)
            user.ReceiveCaelumImpact(result.TargetDeltaSpeed,CaelumConstants.IMPACT_KIND_ENVIRONMENT,
                Head,1,body.Mass,AssemblyMass,result.ClosingSpeed,result.Impulse,
                result.TargetContactMinimumHeightRatio,result.TargetContactMaximumHeightRatio);
        else
            npc.ReceiveCaelumImpact(result.TargetDeltaSpeed,CaelumConstants.IMPACT_KIND_ENVIRONMENT,
                Head,1,body.Mass,AssemblyMass,result.ClosingSpeed,result.Impulse,
                result.TargetContactMinimumHeightRatio,result.TargetContactMaximumHeightRatio);
        LastDamage = before-hit.health;
    }

    bool MoveHead(double distance, bool striking)
    {
        // Subpasos menores que el espesor mínimo: velocidad física en MU/tic,
        // dt=paso/velocidad. Un último subpaso no desacelera el golpe.
        SetOwnSolidity(false);
        double remaining=Abs(distance);
        double sign=distance < 0 ? -1 : 1;
        bool clear=true;
        while (remaining > 0.00001)
        {
            double step=Min(remaining,CaelumRamData.SWEEP_STEP);
            vector2 desired=Head.Pos.XY+(Cos(Angle)*step*sign,Sin(Angle)*step*sign);
            Actor obstacle=null;
            Head.bSolid=true;
            if (!Head.TryMove(desired,false))
            {
                clear=false; obstacle=Head.BlockingMobj;
            }
            Head.bSolid=false;
            for (int i=0; clear && i<FaceBlocks.Size(); i++)
            {
                desired=FaceBlocks[i].Pos.XY+(Cos(Angle)*step*sign,Sin(Angle)*step*sign);
                FaceBlocks[i].bSolid=true;
                if (!FaceBlocks[i].TryMove(desired,false))
                { clear=false; obstacle=FaceBlocks[i].BlockingMobj; }
                FaceBlocks[i].bSolid=false;
            }
            if (!clear)
            {
                PlaceComponents();
                if (striking) ApplyContact(obstacle);
                break;
            }
            StrokeOffset+=step*sign/SizeFactor;
            remaining-=step;
        }
        PlaceComponents();
        SetOwnSolidity(true);
        Obstructed=!clear;
        return clear;
    }

    override void Tick()
    {
        InitializeRam();
        Super.Tick();
        Head.Vel=(0,0,0);
        if (Neutralized || !Enabled || !FullCrewPresent()) return;
        if (Phase == CONTACT)
        {
            Phase=RECOVERY; RecoveryLeft=CaelumRamData.RECOVERY_TICS;
        }
        if (Phase == RECOVERY)
        {
            double distance=(CaelumRamData.RETRACT-StrokeOffset)*SizeFactor/Max(1,RecoveryLeft);
            if (!MoveHead(distance,false)) return;
            RecoveryLeft--;
            if (RecoveryLeft<=0) Phase=READY;
            return;
        }
        if (Phase == STRIKE)
        {
            Head.Vel=(Cos(Angle)*CaelumRamData.STRIKE_SPEED,Sin(Angle)*CaelumRamData.STRIKE_SPEED,0);
            double distance=Min(CaelumRamData.STRIKE_SPEED,(CaelumRamData.EXTENDED_OFFSET-StrokeOffset)*SizeFactor);
            MoveHead(distance,true);
            Head.Vel=(0,0,0);
            if (Phase==STRIKE && StrokeOffset>=CaelumRamData.EXTENDED_OFFSET-0.00001)
            { Phase=RECOVERY; RecoveryLeft=CaelumRamData.RECOVERY_TICS; }
            return;
        }
        if (RouteIndex < Route.Size())
        {
            Phase=APPROACH;
            vector2 offset=Route[RouteIndex].Position.XY-Pos.XY;
            if (offset.Length()<0.001) { RouteIndex++; return; }
            double direction=VectorAngle(offset.X,offset.Y);
            double distance=Min(Min(ApproachSpeed,CaelumRamData.SWEEP_STEP),offset.Length());
            MoveFrame(Pos+(Cos(direction)*distance,Sin(direction)*distance,0),Angle);
            return;
        }
        double turn=DeltaAngle(Angle,FinalAngle);
        if (Abs(turn)>0.001)
        {
            Phase=APPROACH;
            double step=VectorAngle(-CaelumRamData.FRAME_REAR*SizeFactor,
                Min(ApproachSpeed,CaelumRamData.SWEEP_STEP));
            MoveFrame(Pos,Angle+Clamp(turn,-step,step));
            return;
        }
        Phase=READY;
        if (TargetGate==null || TargetGate.Broken || TargetGate.Opened) return;
        // La ruta tiene que terminar frente al portón; no golpear a distancia.
        vector3 tip=LocalPosition(Pos,Angle,(CaelumRamData.HEAD_X+CaelumRamData.EXTENDED_OFFSET
            +CaelumRamData.HEAD_RADIUS,0,CaelumRamData.HEAD_Z));
        if ((tip.XY-TargetGate.Pos.XY).Length()>CaelumGateData.WIDTH/2) return;
        StrikeSerial++; SpentImpact=false; Phase=STRIKE;
    }

    Default { +NOBLOCKMAP }
}
