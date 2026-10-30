// Una sola autoridad de marcha. Las poses no buscan blancos ni ejecutan Chase.
// El recorrido se limita al alcance de recuperación ya aprobado y usa consultas
// locales del motor; jamás enumera la población completa del mapa.
class CaelumPrisonerEscort : Object play
{
    const REVISION=1;
    int SchemaRevision;
    CaelumPlayer Leader;
    Array<double> TrailX,TrailY,TrailZ;

    int TrailSize(){return TrailX.Size();}
    Vector3 TrailPoint(int i){return (TrailX[i],TrailY[i],TrailZ[i]);}
    void ClearTrail(){TrailX.Clear();TrailY.Clear();TrailZ.Clear();}
    void PushTrail(Vector3 p){TrailX.Push(p.X);TrailY.Push(p.Y);TrailZ.Push(p.Z);}
    void PopTrail(){TrailX.Delete(0);TrailY.Delete(0);TrailZ.Delete(0);}
    CaelumEscortNavigation Path;
    double Acceleration;
    int RecoveryRetry;
    bool Controlled;
    Vector3 PreviousLeader;
    Vector2 LeaderStep,LeaderDirection,YieldPoint;
    bool GivingWay;
    bool LeaderIntendsMove;

    void Observe(CaelumCombatActor body,CaelumPlayer leader)
    {
        if(SchemaRevision<REVISION || Leader!=leader)
        {
            SchemaRevision=REVISION;Leader=leader;ClearTrail();Path=null;
            Acceleration=0;Controlled=false;RecoveryRetry=0;GivingWay=false;
            PreviousLeader=leader!=null?leader.Pos:(0,0,0);
            LeaderDirection=(0,0);
        }
        if(leader==null)return;
        LeaderStep=leader.Pos.XY-PreviousLeader.XY;PreviousLeader=leader.Pos;
        LeaderIntendsMove=leader.player!=null && (leader.player.cmd.forwardmove!=0 || leader.player.cmd.sidemove!=0);
        if(LeaderIntendsMove)
            LeaderDirection=(Cos(leader.Angle)*leader.player.cmd.forwardmove+Cos(leader.Angle-90)*leader.player.cmd.sidemove,
                Sin(leader.Angle)*leader.player.cmd.forwardmove+Sin(leader.Angle-90)*leader.player.cmd.sidemove).Unit();
        else if(LeaderStep.Length()>0.001)LeaderDirection=LeaderStep.Unit();
        LeaderIntendsMove=LeaderIntendsMove || LeaderStep.Length()>0.001;
        double spacing=Max(1.0,Min(body.Radius,leader.Radius)/2);
        if(TrailSize()==0 || (leader.Pos-TrailPoint(TrailSize()-1)).Length()>=spacing)
        {
            PushTrail(leader.Pos);
            int capacity=int(Ceil(CaelumConstants.PRISONER_FOLLOW_TELEPORT_DISTANCE/spacing))+1;
            if(TrailSize()>capacity){PopTrail();Path=null;}
        }
    }

    bool Immobilized(CaelumCombatActor body)
    {
        return body.ForcedSleepTics>0 || body.CombatLucidityPhysicalStunRemaining>0
            || CaelumBolas.Restrained(body) || CaelumTelekinesisRules.Held(body)
            || (body.ElementalStatus!=null && body.ElementalStatus.GetMovementMultiplier()<=0);
    }

    void SetPose(CaelumCombatActor body,bool moving)
    {
        State pose=body.Companion!=null ? (moving ? body.FindState("CompanionWalk") : body.FindState("CompanionIdle"))
            : moving ? body.FindState("EscortFollow") : body.FindState("EscortIdle");
        if(pose==null)return;
        if(!body.InStateSequence(body.CurState,pose))body.SetState(pose);
    }

    void Hold(CaelumCombatActor body,bool showPose=true)
    {
        body.Vel.X=0;body.Vel.Y=0;Acceleration=0;Controlled=true;
        CaelumThermalMotion.SetVelocity(body);
        if(showPose)SetPose(body,false);
    }

    void Yield(CaelumCombatActor body)
    {
        if(Controlled){body.Vel.X=0;body.Vel.Y=0;}
        Controlled=false;Acceleration=0;
    }

    double WalkingSpeed(CaelumCombatActor body)
    {
        // Misma marcha base, curva, carga, Aire y penalizaciones del jugador.
        // Los NPC no tienen hambre/sed/sueño metabólico: no crear esos recursos.
        int agility=body.CombatAgility+body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_AGILITY);
        int strength=body.CombatStrength+body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_STRENGTH);
        double capacity=body.Mass*CaelumGrowthRules.Multiplier(strength,2);
        double load=capacity>0?body.GetAttackCarriedWeight()/capacity:0;
        double air=body.MaximumCombatAir>0?body.CurrentCombatAir/body.MaximumCombatAir:0;
        double airFactor=air<=CaelumConstants.AIR_BREATHLESS_THRESHOLD?CaelumConstants.BREATHLESS_PERFORMANCE_MULTIPLIER
            :air<=CaelumConstants.AIR_TIRED_THRESHOLD?CaelumConstants.TIRED_PERFORMANCE_MULTIPLIER:1;
        return CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED*CaelumGrowthRules.Multiplier(agility,2)
            *(1-Clamp(load,0.0,1.0))*airFactor*body.CombatHealthPerformanceMultiplier
            *CaelumThermalEffects.Speed(body)*(body.ElementalStatus!=null?body.ElementalStatus.GetMovementMultiplier():1);
    }

    // Sólo para trayectos cortos de igual nivel. Los desniveles y esquinas
    // conservan su ruta local y el control de suelo del motor en cada paso.
    bool ClearSegment(CaelumCombatActor body,Vector3 goal,double stopDistance=CaelumConstants.PRISONER_FOLLOW_DISTANCE,bool geometryOnly=false)
    {
        vector2 delta=goal.XY-body.Pos.XY;
        double distance=delta.Length();
        if(distance<=stopDistance)return true;
        delta*=Max(0.0,distance-stopDistance)/distance;
        int steps=Max(1,int(Ceil(delta.Length()/Max(1.0,body.Radius))));
        for(int i=1;i<=steps;i++)
        {
            FCheckPosition fit;
            // Sólo el atajo del rastro distingue geometría de otros peatones.
            // Restaurar el flag antes de decidir; cada desplazamiento real y
            // la ruta local conservan la colisión completa con los cuerpos.
            bool through=body.bTHRUACTORS;
            if(geometryOnly)body.bTHRUACTORS=true;
            bool fits=body.CheckPosition(body.Pos.XY+delta*i/steps,false,fit);
            body.bTHRUACTORS=through;
            if(!fits
                || fit.ceilingz-fit.floorz<body.Height
                || abs(fit.floorz-body.FloorZ)>body.MaxStepHeight
                || (body.Companion==null && fit.floorz-fit.dropoffz>body.MaxDropOffHeight))return false;
        }
        return true;
    }

    bool MoveTowards(CaelumCombatActor body,vector2 destination,double speed,double limit)
    {
        vector2 delta=destination-body.Pos.XY;double distance=delta.Length();
        if(distance<=0.001)return false;
        double mass=Max(1.0,body.Mass+body.GetAttackCarriedWeight());
        double duration=CaelumConstants.MOVEMENT_ACCELERATION_SECONDS*mass/CaelumConstants.MOVEMENT_ACCELERATION_REFERENCE_KG;
        if(body.Pos.Z<=body.FloorZ || body.bNoGravity || body.WaterLevel>0)
            Acceleration=Min(1.0,Acceleration+1/(duration*TICRATE));
        double step=Min(distance,speed*Acceleration);
        if(limit>=0)step=Min(step,limit);
        vector2 next=body.Pos.XY+delta/distance*step;
        if(!body.CheckMove(next,0))
        {
            // Un cuerpo ancho puede pisar varios peldaños a la vez. El desnivel
            // bajo el borde no es la caída del próximo paso: validar el suelo
            // que sostendrá el cuerpo, sin permitir saltar desde un precipicio.
            if(body.Companion==null)return false;
            FCheckPosition fit;
            if(!body.CheckPosition(next,false,fit)
                || fit.ceilingz-fit.floorz<body.Height
                || fit.floorz-body.FloorZ>body.MaxStepHeight
                || body.FloorZ-fit.floorz>body.MaxDropOffHeight
                || !body.CheckMove(next,PCM_DROPOFF))return false;
        }
        body.Angle=VectorAngle(delta.X,delta.Y);
        body.Vel.X=delta.X/distance*step;body.Vel.Y=delta.Y/distance*step;
        CaelumThermalMotion.SetVelocity(body);Controlled=true;SetPose(body,true);return true;
    }

    bool GiveWay(CaelumCombatActor body,CaelumPlayer leader,double speed)
    {
        if(body.Pos.Z>=leader.Pos.Z+leader.Height || leader.Pos.Z>=body.Pos.Z+body.Height)
        {GivingWay=false;return false;}
        vector2 separation=body.Pos.XY-leader.Pos.XY;
        double width=body.Radius+leader.Radius;
        vector2 side=(-LeaderDirection.Y,LeaderDirection.X);
        if(!GivingWay && LeaderIntendsMove && separation.Length()<width+body.Radius
            && LeaderDirection dot separation>0 && abs(side dot separation)<width)
        {
            vector2 forward=LeaderDirection;
            if(side dot separation<0)side=-side;
            for(int choice=0;choice<3;choice++)
            {
                // Si el lateral está cerrado, avanzar despeja una escalera;
                // alternar antes al otro lado hacía oscilar delante del líder.
                vector2 direction=choice==0?side:choice==1?forward:-side;
                // En un corredor no siempre cabe el desplazamiento completo.
                // Apartarse hasta donde quepa permite que el jugador también
                // se aparte, sin suprimir la colisión de ninguno de los dos.
                for(double distance=width+body.Radius;distance>=body.Radius/2;distance-=body.Radius/2)
                {
                    vector3 candidate=(body.Pos.XY+direction*distance,body.Pos.Z);
                    if(ClearSegment(body,candidate,0)
                        && body.CheckMove(body.Pos.XY+direction*Min(speed,distance),body.Companion!=null?PCM_DROPOFF:0))
                    {GivingWay=true;YieldPoint=candidate.XY;Path=null;break;}
                }
                if(GivingWay)break;
            }
        }
        if(!GivingWay)return false;
        if((YieldPoint-body.Pos.XY).Length()<=0.001)
        {GivingWay=false;Hold(body);return true;}
        if(!MoveTowards(body,YieldPoint,speed,-1)){GivingWay=false;Hold(body);}
        return true;
    }

    void Follow(CaelumCombatActor body,CaelumPlayer leader)
    {
        if(Immobilized(body)) {Yield(body);return;}
        double speed=WalkingSpeed(body);
        if(speed<=0){Hold(body);return;}
        if(GiveWay(body,leader,speed))return;
        if(body.Distance2D(leader)>CaelumConstants.PRISONER_FOLLOW_TELEPORT_DISTANCE)
        {
            if(level.time>=RecoveryRetry)
            {
                RecoveryRetry=level.time+TICRATE;
                if(Recover(body,leader)){ClearTrail();Observe(body,leader);Path=null;}
            }
            if(body.Distance2D(leader)>CaelumConstants.PRISONER_FOLLOW_TELEPORT_DISTANCE)
            {Hold(body);return;}
        }
        double gap=body.Distance2D(leader)-CaelumConstants.PRISONER_FOLLOW_DISTANCE;
        bool sameFloor=abs(body.FloorZ-leader.FloorZ)<0.001;
        if(gap<=0 && sameFloor && body.CheckSight(leader))
        {Hold(body);ClearTrail();PushTrail(leader.Pos);Path=null;return;}
        if(TrailSize()==0)PushTrail(leader.Pos);
        // El atajo es geométrico, no un único rayo de visión. Evita rodear una
        // ruta vieja cuando el jugador invierte el sentido en un pasillo libre.
        if(TrailSize()>1 && level.time%CaelumConstants.PRISONER_WALK_STATE_TICS==0
            && sameFloor && body.CheckSight(leader)
            && ClearSegment(body,leader.Pos,CaelumConstants.PRISONER_FOLLOW_DISTANCE,true))
        {ClearTrail();PushTrail(leader.Pos);Path=null;}
        Vector3 first=TrailPoint(0);
        // El rastro tiene el ancho del jugador. Un cuerpo más ancho puede
        // rodear un cofre sin pisar exactamente su punto de paso; aceptar la
        // misma precisión de medio radio que usa la cuadrícula local.
        double trailPrecision=Max(speed,body.Radius/2);
        while(TrailSize()>1 && (first.XY-body.Pos.XY).Length()<=trailPrecision
            && abs(first.Z-body.FloorZ)<=body.MaxStepHeight)
        {PopTrail();Path=null;first=TrailPoint(0);}
        Vector3 goal=TrailSize()==1?leader.Pos:TrailPoint(0);
        vector2 destination=goal.XY;
        if(Path!=null)
        {
            // Si el líder ya espera, acercarse hasta donde cabe y quedarse
            // quieto detrás de sus compañeros; no oscilar buscando un hueco
            // lateral inexistente. El movimiento/intento de paso lo reactiva.
            Path.AllowLateralEscape=LeaderIntendsMove || TrailSize()>1;
            destination=Path.Next(body,goal);
        }
        double limit=TrailSize()==1 && Path==null && sameFloor && gap>0?gap:-1;
        if(!MoveTowards(body,destination,speed,limit))
        {
            if(Path==null)Path=new("CaelumEscortNavigation");
            Path.AllowLateralEscape=LeaderIntendsMove || TrailSize()>1;
            if(level.time>=Path.RetryTic)Path.Build(body,goal);
            Hold(body);return;
        }
    }

    bool Recover(CaelumCombatActor body,CaelumPlayer leader)
    {
        if(leader==null || Immobilized(body) || WalkingSpeed(body)<=0)return false;
        // Los doce candidatos y su margen proceden del recuperador anterior.
        // El radio del jugador ahora también forma parte de la separación.
        double spacing=body.Radius+leader.Radius+CaelumConstants.PRISONER_RECOVERY_CLEARANCE;
        for(int attempt=0;attempt<CaelumConstants.PRISONER_RECOVERY_CANDIDATES;attempt++)
        {
            double angle=leader.Angle+180+(attempt%CaelumConstants.PRISONER_RECOVERY_DIRECTIONS)
                *(360.0/CaelumConstants.PRISONER_RECOVERY_DIRECTIONS);
            double distance=spacing*(1+attempt/CaelumConstants.PRISONER_RECOVERY_DIRECTIONS);
            vector3 point=(leader.Pos.X+Cos(angle)*distance,leader.Pos.Y+Sin(angle)*distance,leader.Pos.Z);
            let probe=Actor.Spawn("CaelumSummoningProbe",point,NO_REPLACE);
            if(probe==null)continue;
            probe.A_SetSize(body.Radius,body.Height);probe.FindFloorCeiling();
            bool supported=probe.FloorZ-point.Z<=body.MaxStepHeight
                && point.Z-probe.FloorZ<=body.MaxDropOffHeight;
            point.Z=probe.FloorZ;probe.SetOrigin(point,false);probe.FindFloorCeiling();
            // Fuera del contorno del mapa, el BSP puede devolver el sector
            // vecino aunque TestMobjLocation no encuentre ninguna pared cerca.
            // Exigir visión desde el líder descarta esos candidatos en el vacío.
            bool free=supported && leader.CheckSight(probe) && probe.TestMobjLocation() && probe.Pos.Z>=probe.FloorZ
                && probe.Pos.Z+body.Height<=probe.CeilingZ;
            // La consulta nativa del teletransporte omite sólidos no disparables.
            // TestMobjLocation y la separación explícita los comprueban antes.
            let nearby=BlockThingsIterator.Create(probe,body.Radius);
            while(free && nearby.Next())
            {
                let other=nearby.thing;
                if(other==null || other==probe || other==body || !other.bSolid)continue;
                double reach=body.Radius+other.Radius;
                if(abs(point.X-other.Pos.X)<reach && abs(point.Y-other.Pos.Y)<reach
                    && point.Z<other.Pos.Z+other.Height && point.Z+body.Height>other.Pos.Z)free=false;
            }
            probe.Destroy();
            if(free && body.TeleportMove(point,false))
            {body.Vel=(0,0,0);body.ClearInterpolation();Acceleration=0;return true;}
        }
        return false;
    }
}
