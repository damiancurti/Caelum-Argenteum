// Puerta lateral finita para construcciones apiladas. Cada hoja visible usa
// WALLSPRITE y varios bloqueadores pequeños, evitando la colisión circular
// sobredimensionada de un único actor ancho.
class CaelumSlidingDoorBlocker : Actor
{
    override bool Used(Actor user)
    {
        CaelumSlidingDoorLeaf leaf = CaelumSlidingDoorLeaf(master);
        if (leaf == null)
        {
            return false;
        }

        return leaf.RequestDoorGroup(user);
    }

    override void Tick()
    {
        Super.Tick();

        if (master == null)
        {
            Destroy();
            return;
        }

        CaelumSlidingDoorLeaf leaf = CaelumSlidingDoorLeaf(master);
        if (leaf == null)
        {
            Destroy();
            return;
        }

        vector3 blockerPos = leaf.Pos;
        if (leaf.args[2] == 0)
        {
            blockerPos.X += args[0];
        }
        else
        {
            blockerPos.Y += args[0];
        }
        SetOrigin(blockerPos, true);
    }

    Default
    {
        Radius 4;
        Height 120;
        +SOLID
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "None";
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumSlidingDoorLeaf : Actor
{
    vector3 ClosedPosition;
    int SlideProgress;
    int HoldTimer;
    bool DoorRequested;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        ClosedPosition = Pos;

        // El actor visible ocupa el centro; estos ocho cilindros completan
        // una hoja de 64 MU sin invadir innecesariamente sus alrededores.
        for (int offset = -28; offset <= 28; offset += 8)
        {
            Actor blocker = Spawn("CaelumSlidingDoorBlocker", Pos);
            if (blocker != null)
            {
                blocker.master = self;
                blocker.args[0] = offset;
            }
        }
    }

    bool RequestDoorGroup(Actor user)
    {
        // args[3] conserva el número de LOCKDEFS. CheckKeys presenta el
        // mensaje localizado del bloqueo y no consume la llave reutilizable.
        if (args[3] > 0 && (user == null || !user.CheckKeys(args[3], false)))
        {
            return false;
        }

        int groupLeafCount = 0;
        bool groupWasRequested = false;
        let iterator = ThinkerIterator.Create("CaelumSlidingDoorLeaf");
        CaelumSlidingDoorLeaf leaf;
        while ((leaf = CaelumSlidingDoorLeaf(iterator.Next())))
        {
            if (leaf.args[0] == args[0])
            {
                groupLeafCount++;
                groupWasRequested = groupWasRequested || leaf.DoorRequested;
                leaf.DoorRequested = true;
                leaf.HoldTimer = 105;
            }
        }
        // Una hoja de 64 MU usa puerta común; dos o más hojas forman una
        // abertura grande. El sonido se emite una sola vez al iniciar el grupo.
        if (!groupWasRequested && groupLeafCount > 0)
        {
            if (groupLeafCount > 1)
            {
                A_StartSound("caelum/world/door_large_open", CHAN_BODY);
            }
            else
            {
                A_StartSound("caelum/world/door_open", CHAN_BODY);
            }
        }
        return true;
    }

    override bool Used(Actor user)
    {
        return RequestDoorGroup(user);
    }

    bool PlayerOccupiesDoorway()
    {
        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex] || players[playerIndex].mo == null)
            {
                continue;
            }

            Actor playerActor = players[playerIndex].mo;
            bool overlapsZ = playerActor.Pos.Z < Pos.Z + Height
                && playerActor.Pos.Z + playerActor.Height > Pos.Z;
            if (overlapsZ && Distance2D(playerActor) < 80.0)
            {
                return true;
            }
        }
        return false;
    }

    void PlaceAtProgress()
    {
        vector3 newPosition = ClosedPosition;
        double displacement = SlideProgress * args[1];
        if (args[2] == 0)
        {
            newPosition.X += displacement;
        }
        else
        {
            newPosition.Y += displacement;
        }
        SetOrigin(newPosition, true);
    }

    override void Tick()
    {
        Super.Tick();

        if (DoorRequested && SlideProgress < 64)
        {
            SlideProgress = Min(64, SlideProgress + 4);
            PlaceAtProgress();
            return;
        }

        if (DoorRequested)
        {
            if (HoldTimer > 0)
            {
                HoldTimer--;
                return;
            }
            if (PlayerOccupiesDoorway())
            {
                HoldTimer = 18;
                return;
            }
            DoorRequested = false;
        }

        if (SlideProgress > 0)
        {
            SlideProgress = Max(0, SlideProgress - 4);
            PlaceAtProgress();
        }
    }

    Default
    {
        Radius 4;
        Height 120;
        XScale 1.0;
        YScale 0.9375;
        +SOLID
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        +WALLSPRITE
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CDLS A -1;
        Stop;
    }
}
