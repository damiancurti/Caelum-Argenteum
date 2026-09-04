// Las tres mallas OBJ son estáticas. Un actor visual separado permite cambiar
// de archivo sin superponerlos como adjuntos dentro de un mismo MODELDEF.
class CaelumStashChestVisual : Actor
{
    override void Tick()
    {
        Super.Tick();
        if (master == null)
        {
            Destroy();
            return;
        }

        SetOrigin(master.Pos, false);
        Angle = master.Angle;
    }

    Default
    {
        Radius 0;
        Height 0;
        +NOGRAVITY
        +NOBLOCKMAP
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CAHC A -1;
        Stop;
    }
}

class CaelumStashChestClosedVisual : CaelumStashChestVisual {}
class CaelumStashChestOpenVisual : CaelumStashChestVisual
{
    States
    {
    Spawn:
        CAHC B -1;
        Stop;
    }
}

class CaelumStashChestLockedVisual : CaelumStashChestVisual
{
    States
    {
    Spawn:
        CAHC C -1;
        Stop;
    }
}

// Primer prototipo de alijo tridimensional. Todavía no almacena objetos: esta
// clase valida modelo, colisión, estados, interacción y cerradura reutilizable.
class CaelumStashChest : Actor
{
    bool ChestOpen;
    bool ChestUnlocked;
    bool UseLatched;
    Actor LastChestUser;
    CaelumStashChestVisual ChestVisual;

    virtual int GetChestLockNumber()
    {
        return 0;
    }

    bool IsChestLocked()
    {
        return GetChestLockNumber() > 0 && !ChestUnlocked;
    }

    void RefreshChestVisual()
    {
        if (ChestVisual != null)
        {
            ChestVisual.Destroy();
            ChestVisual = null;
        }

        String visualClass = "CaelumStashChestClosedVisual";
        if (IsChestLocked())
        {
            visualClass = "CaelumStashChestLockedVisual";
        }
        else if (ChestOpen)
        {
            visualClass = "CaelumStashChestOpenVisual";
        }

        ChestVisual = CaelumStashChestVisual(Spawn(
            visualClass,
            Pos,
            NO_REPLACE
        ));
        if (ChestVisual != null)
        {
            ChestVisual.master = self;
            ChestVisual.Angle = Angle;
        }
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        RefreshChestVisual();
    }

    override void Tick()
    {
        Super.Tick();

        // Si una partida antigua o una transición no conserva el ayudante
        // visual, se reconstruye desde el estado persistente del alijo.
        if (ChestVisual == null)
        {
            RefreshChestVisual();
        }

        // Mantener Use no puede abrir y cerrar el alijo varias veces. La
        // siguiente interacción sólo se habilita después de soltar la tecla.
        if (UseLatched)
        {
            PlayerPawn userPawn = PlayerPawn(LastChestUser);
            if (userPawn == null
                || userPawn.player == null
                || (userPawn.player.cmd.buttons & BT_USE) == 0)
            {
                UseLatched = false;
                LastChestUser = null;
            }
        }
    }

    override bool Used(Actor user)
    {
        if (UseLatched && LastChestUser == user)
        {
            return true;
        }
        UseLatched = true;
        LastChestUser = user;

        if (IsChestLocked())
        {
            int lockNumber = GetChestLockNumber();
            if (user == null || !user.CheckKeys(lockNumber, false))
            {
                A_StartSound("caelum/world/door_locked", CHAN_BODY);
                return true;
            }

            // CheckKeys sólo comprueba posesión: la llave de plata permanece
            // en el inventario y el estado desbloqueado se guarda con el actor.
            ChestUnlocked = true;
        }

        ChestOpen = !ChestOpen;
        RefreshChestVisual();
        A_StartSound("caelum/world/door_open", CHAN_BODY);
        return true;
    }

    Default
    {
        Tag "$CA_STASH_CHEST";
        Radius 32;
        Height 60;
        Mass 1000;
        +SOLID
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumLockedStashChest : CaelumStashChest
{
    override int GetChestLockNumber()
    {
        return CaelumConstants.LOCK_CAELUM_SILVER_STASH;
    }
}
