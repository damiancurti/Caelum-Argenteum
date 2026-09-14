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
    int LockedSoundCooldown;
    bool DoorRequested;
    bool RuloArenaLocked;
    CaelumFactionCondition AccessCondition;

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
        // La petición valida la hoja antes de consultar llaves o emitir sonido.
        if (user == null || Abs(user.Pos.Z - Pos.Z) > 64
            || user.Pos.Z >= Pos.Z + Height || user.Pos.Z + user.Height <= Pos.Z
            || !user.CheckSight(self)) return false;
        if (user.player != null && (user.health <= 0 || (user.player.cheats & CF_PREDICTING))) return false;

        // Prevalidar todas las hojas antes de cambiar peticiones o temporizadores.
        // Una hoja libre no elude la llave, bloqueo de arena o condición de otra.
        let conditions = ThinkerIterator.Create("CaelumSlidingDoorLeaf");
        CaelumSlidingDoorLeaf guardedLeaf;
        while ((guardedLeaf = CaelumSlidingDoorLeaf(conditions.Next())) != null)
        {
            if (!IsGroupPeer(guardedLeaf)) continue;
            if (guardedLeaf.RuloArenaLocked) return false;
            // LOCKDEFS nativo comprueba posesión y no consume la llave.
            if (guardedLeaf.args[3] > 0 && !user.CheckKeys(guardedLeaf.args[3], false, true))
            {
                if (LockedSoundCooldown <= 0)
                {
                    // El motor muestra el motivo y usa el sonido de LOCKDEFS.
                    user.CheckKeys(guardedLeaf.args[3], false);
                    LockedSoundCooldown = 7;
                }
                return false;
            }
            if (!CaelumFactionCondition.Require(CaelumPlayer(user), guardedLeaf.AccessCondition)) return false;
        }

        int groupLeafCount = 0;
        bool groupWasRequested = false;
        let iterator = ThinkerIterator.Create("CaelumSlidingDoorLeaf");
        CaelumSlidingDoorLeaf leaf;
        while ((leaf = CaelumSlidingDoorLeaf(iterator.Next())))
        {
            if (IsGroupPeer(leaf))
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

    bool IsGroupPeer(CaelumSlidingDoorLeaf leaf)
    {
        // Un id positivo enlaza hojas. Sin id, la puerta funciona sola: cero
        // no debe convertir todas las puertas sin configurar en un mismo grupo.
        return leaf == self || (leaf != null && args[0] > 0 && leaf.args[0] == args[0]);
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
            bool overlapsZ = playerActor.Pos.Z < ClosedPosition.Z + Height
                && playerActor.Pos.Z + playerActor.Height > ClosedPosition.Z;
            vector2 offset = playerActor.Pos.XY - ClosedPosition.XY;
            double along = args[2] == 0 ? Abs(offset.X) : Abs(offset.Y);
            double across = args[2] == 0 ? Abs(offset.Y) : Abs(offset.X);
            // Medir el hueco cerrado, no la hoja que se apartó 64 MU. Incluir
            // el radio real del personaje y la profundidad de los bloqueadores.
            if (overlapsZ && along < 32.0 + playerActor.Radius
                && across < 4.0 + playerActor.Radius)
            {
                return true;
            }
        }
        return false;
    }

    bool GroupDoorwayOccupied()
    {
        let iterator = ThinkerIterator.Create("CaelumSlidingDoorLeaf");
        CaelumSlidingDoorLeaf leaf;
        while ((leaf = CaelumSlidingDoorLeaf(iterator.Next())) != null)
            if (IsGroupPeer(leaf) && leaf.PlayerOccupiesDoorway()) return true;
        return false;
    }

    void HoldOccupiedGroup()
    {
        let iterator = ThinkerIterator.Create("CaelumSlidingDoorLeaf");
        CaelumSlidingDoorLeaf leaf;
        while ((leaf = CaelumSlidingDoorLeaf(iterator.Next())) != null)
        {
            if (!IsGroupPeer(leaf) || leaf.RuloArenaLocked) continue;
            leaf.DoorRequested = true;
            leaf.HoldTimer = 18;
        }
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

        if (RuloArenaLocked)
        {
            DoorRequested = false; HoldTimer = 0; SlideProgress = 0;
            PlaceAtProgress(); return;
        }
        if (LockedSoundCooldown > 0) { LockedSoundCooldown--; }

        // Una puerta que ya abrió no encierra al personaje por perder una
        // llave. Reabrir durante el cierre protege también a quien entra tarde.
        // El bloqueo explícito de la arena conserva su prioridad anterior.
        if (SlideProgress > 0 && (!DoorRequested || HoldTimer <= 0) && GroupDoorwayOccupied())
            HoldOccupiedGroup();

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
