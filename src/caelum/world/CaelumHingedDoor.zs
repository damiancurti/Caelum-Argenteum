// Variante de MAP01: conserva grupos, llaves y bloqueo de Rulo de la puerta
// original; la hoja de madera gira sobre el mismo vano y no es destructible.
class CaelumHingedDoorLeaf : CaelumSlidingDoorLeaf
{
    int LastProgress;
    int SwingSide;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        SwingSide = 1;
        Angle = (args[2] == 0 ? 0 : 90) + (args[1] > 0 ? 180 : 0);
        bWallSprite = false;
        Scale = (1, 1);
    }

    override bool RequestDoorGroup(Actor user)
    {
        if (!Super.RequestDoorGroup(user)) return false;
        // Las conexiones indicadas abren hacia los cuartos centrales para
        // evitar las camas. Las otras hojas abren al lado opuesto al usuario.
        // Una reapertura conserva su sentido hasta completar el cierre.
        double across = args[2] == 0
            ? user.Pos.Y - ClosedPosition.Y : ClosedPosition.X - user.Pos.X;
        int groupSide = across > 0 ? -1 : 1;
        int fixedSide = level.MapName == "MAP01"
            ? CaelumMansionDoorData.FixedSwingSide(args[0]) : 0;
        if (fixedSide != 0) groupSide = fixedSide;
        let it = ThinkerIterator.Create("CaelumHingedDoorLeaf");
        CaelumHingedDoorLeaf leaf;
        while ((leaf = CaelumHingedDoorLeaf(it.Next())) != null)
            if (IsGroupPeer(leaf) && leaf.SlideProgress > 0) { groupSide = leaf.SwingSide; break; }
        it = ThinkerIterator.Create("CaelumHingedDoorLeaf");
        while ((leaf = CaelumHingedDoorLeaf(it.Next())) != null)
        {
            if (!IsGroupPeer(leaf) || leaf.SlideProgress != 0) continue;
            leaf.SwingSide = groupSide;
        }
        return true;
    }

    vector3 PositionAt(int progress, double offset)
    {
        double baseAngle = args[2] == 0 ? 0 : 90;
        double turn = baseAngle - args[1] * SwingSide
            * CaelumMansionDoorData.OPEN_DEGREES * progress / 64.0;
        vector3 pivot = ClosedPosition + (Cos(baseAngle), Sin(baseAngle), 0)
            * args[1] * CaelumMansionDoorData.HALF_WIDTH;
        return pivot + (Cos(turn), Sin(turn), 0)
            * (offset - args[1] * CaelumMansionDoorData.HALF_WIDTH);
    }

    override vector3 BlockerPosition(double offset)
    {
        return PositionAt(SlideProgress, offset);
    }

    bool SweepOccupied(int progress)
    {
        let it = BlockThingsIterator.Create(self, CaelumMansionDoorData.SWEEP_RADIUS);
        while (it.Next())
        {
            Actor body = it.thing;
            if (!body.bSolid || body.bNoClip || body == self) continue;
            let door = CaelumSlidingDoorLeaf(body);
            let blocker = CaelumSlidingDoorBlocker(body);
            if (door != null && IsGroupPeer(door)) continue;
            if (blocker != null && IsGroupPeer(CaelumSlidingDoorLeaf(blocker.master))) continue;
            if (body.Pos.Z >= ClosedPosition.Z + Height || body.Pos.Z + body.Height <= ClosedPosition.Z) continue;
            for (int offset = -28; offset <= 28; offset += 8)
            {
                vector3 point = PositionAt(progress, offset);
                if (Abs(body.Pos.X - point.X) < body.Radius + 4
                    && Abs(body.Pos.Y - point.Y) < body.Radius + 4) return true;
            }
        }
        return false;
    }

    override void PlaceAtProgress()
    {
        // Examinar todos los pasos intermedios: la hoja nunca empuja ni aplasta
        // un jugador/NPC. El cierre bloqueado vuelve a solicitar el grupo.
        int step = SlideProgress > LastProgress ? 1 : -1;
        for (int p = LastProgress + step; p != SlideProgress + step; p += step)
        {
            if (!RuloArenaLocked && SweepOccupied(p))
            {
                bool closing = SlideProgress < LastProgress;
                SlideProgress = LastProgress;
                if (closing) HoldOccupiedGroup();
                return;
            }
        }
        LastProgress = SlideProgress;
        Angle = (args[2] == 0 ? 0 : 90) + (args[1] > 0 ? 180 : 0) - args[1] * SwingSide
            * CaelumMansionDoorData.OPEN_DEGREES * SlideProgress / 64.0;
        SetOrigin(PositionAt(SlideProgress, 0), true);
        // Actualizar también en este tic, sin depender del orden de pensadores.
        let it = ThinkerIterator.Create("CaelumSlidingDoorBlocker");
        CaelumSlidingDoorBlocker block;
        while ((block = CaelumSlidingDoorBlocker(it.Next())) != null)
            if (block.master == self) block.SetOrigin(BlockerPosition(block.args[0]), true);
    }
}
