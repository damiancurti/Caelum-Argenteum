// Reinicio transaccional de la galería: conserva geometría, inventarios y
// contadores históricos. Nunca arma un peligro ocupado ni duplica un techo.
class CaelumHazardResetSwitch : CaelumHazardReleaseSwitch
{
    int ResetCount;
    int FaceTics;

    static bool Occupied(vector3 origin,double radius,double bottom,double top,Actor ignored=null)
    {
        let nearby=BlockThingsIterator.CreateFromPos(origin.X,origin.Y,bottom,top-bottom,radius,false);
        while(nearby.Next())
        {
            let body=nearby.thing;
            if(body==ignored || !body.bSolid || body.bNoClip || body is 'CaelumHazardRock'
                || body is 'CaelumTrapdoor')continue;
            if(Abs(body.Pos.X-origin.X)<radius+body.Radius && Abs(body.Pos.Y-origin.Y)<radius+body.Radius
                && body.Pos.Z<top && body.Pos.Z+body.Height>bottom)return true;
        }
        return false;
    }

    static String BlockReason()
    {
        let crushing=ThinkerIterator.Create("CaelumCrusherTrap");CaelumCrusherTrap crusher;
        while((crusher=CaelumCrusherTrap(crushing.Next()))!=null)
            if(crusher.IsMoving())return "CA_TRAPS_RESET_MOVING";
        // El foso se comprueba hasta el fondo; no cerrar sobre su ocupante.
        if(Occupied((1408,896,0),128,-192,96)
            || Occupied((1280,1344,0),48,0,96)
            || Occupied((2048,1600,256),48,256,352)
            || Occupied((1728,640,0),24,0,96)
            || Occupied((2048,640,0),24,0,96)
            || Occupied((2240,1216,0),64,0,384))return "CA_TRAPS_RESET_OCCUPIED";
        return "";
    }

    static void ResetRock(int id,vector3 position,double heading)
    {
        let rock=CaelumHazardRock(ActorIterator.Create(id,"CaelumHazardRock").Next());
        if(rock==null)return;
        rock.UpdateRollingSound(false);rock.Released=false;rock.bNoGravity=true;
        rock.Vel=(0,0,0);rock.SetOrigin(position,false);rock.Angle=heading;rock.Roll=0;
        rock.BeforeMove=position;rock.BeforeVelocity=(0,0,0);rock.LastVerticalVictim=null;
        rock.ClearInterpolation();
    }

    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(level.MapName!="MAP08" || user==null || user.player==null || user.health<=0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || (user.player.cheats & CF_PREDICTING) || !CaelumUseGeometry.AimedAt(user,self)
            || !user.CheckSight(self,SF_IGNOREVISIBILITY))return false;
        String reason=BlockReason();
        if(reason!=""){user.A_Print(StringTable.Localize(reason,false));return true;}
        let covers=ThinkerIterator.Create("CaelumTrapdoor");CaelumTrapdoor trap;
        while((trap=CaelumTrapdoor(covers.Next()))!=null)
        {
            trap.Opened=false;trap.bSolid=true;
            if(trap.Cover==null)
                trap.Cover=CaelumTrapdoorCover(Spawn("CaelumTrapdoorCover",trap.Pos+(0,0,trap.Height),NO_REPLACE));
            if(trap.Cover!=null){trap.Cover.master=trap;trap.Cover.Scale=(trap.Radius/64.0,trap.Radius/64.0);}
        }
        ResetRock(43602,(1280,1344,0),0);
        ResetRock(43603,(2048,1600,256),0);
        let pressure=ThinkerIterator.Create("CaelumPressureTrap");CaelumPressureTrap plate;
        while((plate=CaelumPressureTrap(pressure.Next()))!=null)
        {
            plate.Spent=false;plate.RetryTics=0;plate.A_SetRenderStyle(1.0,STYLE_Normal);
            let crusher=CaelumCrusherTrap(plate);
            if(crusher!=null){crusher.MovementFinished=false;crusher.StartedPanels=0;crusher.Panels.Clear();}
            let portal=CaelumTeleportTrap(plate);if(portal!=null)portal.LastRejection=0;
        }
        let switches=ThinkerIterator.Create("CaelumHazardReleaseSwitch");CaelumHazardReleaseSwitch lever;
        while((lever=CaelumHazardReleaseSwitch(switches.Next()))!=null)
        {lever.Spent=false;if(lever.LeverVisual!=null)lever.LeverVisual.frame=0;}
        ResetCount++;Spent=true;FaceTics=TICRATE;
        A_StartSound("caelum/world/lever_activate",CHAN_BODY);
        user.A_Print(StringTable.Localize("CA_TRAPS_RESET_DONE",false));return true;
    }

    override void Tick()
    { if(FaceTics>0 && --FaceTics==0)Spent=false;Super.Tick(); }
    Default { Tag "$CA_TRAPS_RESET_NAME"; }
}

class CaelumHazardGallery : Object play
{
    static void Prepare()
    {
        if(level.MapName!="MAP08")return;
        if(ThinkerIterator.Create("CaelumHazardResetSwitch").Next()==null)
        {
            let lever=Actor.Spawn("CaelumHazardResetSwitch",(1088,1088,0),NO_REPLACE);
            if(lever!=null){lever.Angle=180;lever.ChangeTid(43620);}
        }
        // Aro receptor visible: emplea la misma runa que la placa de origen.
        if(ThinkerIterator.Create("CaelumTeleportArrivalMarker").Next()==null)
            Actor.Spawn("CaelumTeleportArrivalMarker",(1152,1664,0.5),NO_REPLACE);
    }
}

class CaelumTeleportArrivalMarker : Actor
{
    Default { +NOINTERACTION +NOGRAVITY +FLATSPRITE Scale 0.375; }
    States { Spawn: CMNQ A -1 Bright; Stop; }
}
