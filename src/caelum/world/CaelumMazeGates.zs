// Las rejas usan colisión y trazas nativas de líneas; no una pared de actores.
// Sus llaves no se consumen y la apertura se conserva con el estado del mapa.
class CaelumMazeLayoutMarker : Actor
{
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumMazeBarredGate : Actor
{
    bool Opened;
    int Revision;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        if (level.MapName != "MAP02") return;
        // Mientras la reja permanece cerrada tambien bloquea la vista: el
        // Zupay no puede alertarse ni hostigar la escolta a traves de los barrotes.
        for (int i = 0; i < level.lines.Size(); i++)
        {
            let barrier = level.lines[i];
            if (barrier.special != 13 || barrier.args[0] != args[0]) continue;
            barrier.flags |= Line.ML_BLOCKSIGHT;
        }
    }

    bool Open(CaelumPlayer user)
    {
        if(user==null || user.player==null || user.health<=0)return false;
        if(Opened)return true;
        if(args[1]!=0 && !user.CheckKeys(args[1],false,false))return false;
        Opened=true;Revision=1;
        ApplyOpening();
        A_StartSound("caelum/world/door_open",CHAN_BODY);
        return true;
    }
    void ApplyOpening()
    {
        for(int i=0;i<level.lines.Size();i++)
        {
            let barrier=level.lines[i];
            if(barrier.special!=13 || barrier.args[0]!=args[0])continue;
            barrier.flags &= ~(Line.ML_BLOCKING | Line.ML_BLOCKPROJECTILE
                | Line.ML_BLOCKHITSCAN | Line.ML_BLOCKUSE | Line.ML_BLOCKSIGHT);
            for(int sideIndex=0;sideIndex<2;sideIndex++)
                if(barrier.sidedef[sideIndex]!=null)
                    barrier.sidedef[sideIndex].SetTexture(Side.mid,TexMan.CheckForTexture("-",TexMan.Type_Wall));
        }
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

// Estático para que exista también al restaurar partidas anteriores.
class CaelumMazeGateEvents : StaticEventHandler
{
    override void WorldLinePreActivated(WorldEvent e)
    {
        if(level.MapName!="MAP02" || e.ActivatedLine==null)return;
        let barrier=e.ActivatedLine;
        if(barrier.special==13 && CaelumMazeLayout.IsFloodedReturn()
            && CaelumMazeLayout.IsReturnGrate(barrier.args[0]))
        {
            e.ShouldActivate=false;
            let grate=CaelumMazeReturnGrate(ActorIterator.Create(barrier.args[0],"CaelumMazeReturnGrate").Next());
            if(grate!=null)grate.UseReturn(CaelumPlayer(e.Thing));
            return;
        }
        if(barrier.special!=13 || barrier.args[0]<44700 || barrier.args[0]>44723)return;
        e.ShouldActivate=false;
        let gate=CaelumMazeBarredGate(ActorIterator.Create(barrier.args[0],"CaelumMazeBarredGate").Next());
        if(gate!=null)gate.Open(CaelumPlayer(e.Thing));
    }
}

// La reja es un piso 3D sólido cuyo plano inferior sube hasta el techo del
// túnel. Su parte superior sostiene el vestíbulo sin bloquearlo ni moverlo.
class CaelumMazeReturnGrate : Actor
{
    bool Opened;
    int Revision;

    bool UseReturn(CaelumPlayer user)
    {
        if(user==null || user.health<=0 || !CaelumMazeLayout.IsFloodedReturn())return false;
        let lift=CaelumMazeReturnElevator(ActorIterator.Create(CaelumMazeLayout.RETURN_ELEVATOR_TAG,"CaelumMazeReturnElevator").Next());
        bool lower=user.Pos.Z<CaelumMazeLayout.RETURN_CEILING;
        if(lower && !Opened)
        {
            // Descender desde el inicio nunca encierra al jugador: puede
            // volver a subir desde dentro, sin abrir ninguna reja al revés.
            if(!CaelumMazeLayout.IsGrateExterior(args[1],user.Pos.XY))
                return CaelumMazeLayout.IsInsideElevator(user.Pos.XY) && lift!=null && lift.Call(user);
            if(!Floor_MoveToValue(args[0],CaelumMazeLayout.RETURN_SPEED,
                -CaelumMazeLayout.RETURN_CEILING,1))return false;
            Opened=true;Revision=1;
            A_StartSound("caelum/world/door_open",CHAN_BODY);
        }
        if(lift!=null)lift.Call(user);
        return true;
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

// El motor conserva y restaura el pensador del piso móvil. Las llamadas son
// idempotentes desde un rellano; desde la plataforma piden el otro nivel.
class CaelumMazeReturnElevator : Actor
{
    int Calls;
    bool Call(CaelumPlayer user)
    {
        if(user==null || user.health<=0 || CurSector==null)return false;
        double floor=CurSector.floorplane.ZatPoint(Pos.XY);
        bool inside=CaelumMazeLayout.IsInsideElevator(user.Pos.XY);
        bool goUp=inside?floor<CaelumMazeLayout.RETURN_CEILING:user.Pos.Z>=CaelumMazeLayout.RETURN_CEILING;
        bool moved=Floor_MoveToValue(CaelumMazeLayout.RETURN_ELEVATOR_TAG,
            CaelumMazeLayout.RETURN_SPEED,goUp?0:-CaelumMazeLayout.RETURN_FLOOR,goUp?0:1);
        if(moved)Calls++;
        return moved;
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumMazeNorthKey : CaelumMazeKey
{
    override int GetKeyType(){return 4;}
    Default { Tag "$CA_MAZE_KEY_4"; }
}
class CaelumMazeSouthCellKey : CaelumMazeKey
{
    override int GetKeyType(){return 5;}
    Default { Tag "$CA_MAZE_KEY_5"; }
}
class CaelumMazeWestCellKey : CaelumMazeKey
{
    override int GetKeyType(){return 6;}
    Default { Tag "$CA_MAZE_KEY_6"; }
}
class CaelumMazeEastCellKey : CaelumMazeKey
{
    override int GetKeyType(){return 7;}
    Default { Tag "$CA_MAZE_KEY_7"; }
}
class CaelumMazeNorthCellKey : CaelumMazeKey
{
    override int GetKeyType(){return 8;}
    Default { Tag "$CA_MAZE_KEY_8"; }
}
