// Trabajo por desplazamiento voluntario. Los impulsos ajenos y el transporte
// del soporte no son pasos; la natación y el esfuerzo inmóvil usan su perfil.
class CaelumThermalMotion : Object play
{
    static double Gravity(Actor body)
    { return CaelumPhysicsUnits.AccelerationSI(body.GetGravity()); }

    static void Path(Actor body,vector3 before,vector3 after,bool running)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null)return;
        double distance=(after.XY-before.XY).Length();
        if(distance<=0)return;
        CaelumThermalBody.Refresh(body,thermal);
        double grade=(after.Z-before.Z)/distance;
        thermal.PendingActivityJoules+=CaelumThermalRules.PositiveWorkHeat(CaelumThermalRules.LocomotionWork(
            thermal.MovedMassKg,CaelumPhysicsUnits.Meters(distance),grade,running,Gravity(body)),thermal.MuscularEfficiency);
    }

    static void PlayerInput(CaelumPlayer user,vector2 oldVelocity)
    {
        if(user.player==null || (user.player.cheats & CF_PREDICTING))return;
        let thermal=CaelumThermalBody.Get(user,true);
        if(thermal==null)return;
        // La diferencia alrededor de MovePlayer sólo contiene la propulsión
        // nativa del comando. No reconstruirla desde el balance de Aire.
        if(oldVelocity.Length()<=0)thermal.PropelledVelocity=(0,0);
        thermal.PropelledVelocity+=user.Vel.XY-oldVelocity;
    }

    static F3DFloor Support(Actor body)
    {
        for(int i=0;i<body.CurSector.Get3DFloorCount();i++)
        {
            let floor=body.CurSector.Get3DFloor(i);
            if((floor.flags&(F3DFloor.FF_EXISTS|F3DFloor.FF_SOLID))==(F3DFloor.FF_EXISTS|F3DFloor.FF_SOLID)
                && Abs(floor.top.ZatPoint(body.Pos.XY)-body.FloorZ)<0.01)return floor;
        }
        return null;
    }

    static double SupportHeight(Sector sector,F3DFloor floor,vector2 point)
    {return floor!=null ? floor.top.ZatPoint(point) : sector.floorplane.ZatPoint(point);}

    static void Physics(Actor body,vector3 before,vector3 velocity,bool grounded,vector2 propelled,
        Sector supportSector,F3DFloor supportFloor,double supportHeight)
    {
        let npc=CaelumCombatActor(body);
        if(npc!=null && body.Pos==before && propelled==(0,0))
        {if(npc.ThermalState!=null)npc.ThermalState.LocalMotionMps=0;return;}
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal==null)return;
        vector3 delta=body.Pos-before;
        thermal.LocalMotionMps=delta.XY.Length()*TICRATE/CaelumJourneyRules.MAP_UNITS_PER_METER;
        let user=CaelumPlayer(body);
        bool intent=user!=null && user.player!=null
            && (user.player.cmd.forwardmove!=0 || user.player.cmd.sidemove!=0 || user.player.cmd.upmove!=0)
            && !user.IsPhysicallyImmobilized();
        if(user!=null && intent && user.WaterLevel>=2)
        {
            if(thermal.SurfaceArea<=0)CaelumThermalBody.Refresh(user,thermal);
            thermal.PendingActivityJoules+=CaelumThermalEffects.SwimmingWatts(thermal.SurfaceArea,
                (user.player.cmd.buttons & BT_RUN)!=0,CaelumThermalBody.Efficiency(user))/TICRATE;
        }
        else if(grounded && body.Pos.Z<=body.FloorZ+0.01 && !body.bNoGravity && (intent || user==null))
        {
            vector2 own=propelled;
            // Se resta la velocidad externa previa; se limita al avance propio.
            // Un cambio discontinuo de posición no es locomoción.
            vector2 moved=delta.XY-(velocity.XY-own);
            double length=own.Length();
            double along=length>0 ? Clamp(moved.X*own.X/length+moved.Y*own.Y/length,0.0,length) : 0;
            if(delta.XY.Length()<=0.01 || delta.XY.Length()>velocity.XY.Length()+body.MaxStepHeight)along=0;
            if(along>0)
            {
                // Se sigue el mismo soporte anterior: su traslación vertical
                // no es una subida, pero cruzar un escalón sí requiere trabajo.
                double supportRise=SupportHeight(supportSector,supportFloor,before.XY)-supportHeight;
                bool running=user!=null ? (user.player.cmd.buttons & BT_RUN)!=0
                    : body is 'CaelumBull' && CaelumBull(body).BullChargeActive;
                Path(body,(0,0,0),(along,0,delta.Z-supportRise),running);
            }
            else if(intent && length>0 && delta.XY.Length()<=0.01)
            {
                if(thermal.SurfaceArea<=0)CaelumThermalBody.Refresh(user,thermal);
                thermal.PendingActivityJoules+=CaelumThermalEffects.PushingWatts(thermal.SurfaceArea)/TICRATE;
            }
        }
        if(user!=null)
        {
            double friction,moveFactor;[friction,moveFactor]=body.GetFriction();
            thermal.PropelledVelocity*=friction;
            if(!grounded || body.WaterLevel>=2)thermal.PropelledVelocity=(0,0);
        }
    }

    static void SetVelocity(CaelumCombatActor body)
    {
        let thermal=CaelumThermalBody.Get(body,true);
        if(thermal!=null)thermal.PropelledVelocity=body.Vel.XY;
    }
}
