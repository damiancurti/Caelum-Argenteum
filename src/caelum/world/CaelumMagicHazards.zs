// Trampas aprobadas 4.36.0b. Sus parámetros de MAP08 son valores de ensayo.
// El mapeador asigna daño/radio/destino; no se fija un balance de campaña.
class CaelumPressureTrap : Actor
{
    bool Spent;
    int ActivationCount;
    int RetryTics;

    bool IsPressedBy(Actor body)
    {
        if (Spent || body == null || body.health <= 0 || !body.bSolid
            || body.bNoClip || body.bNoGravity || body.Vel.Z > 0
            || Abs(body.Pos.Z - (Pos.Z - 0.5)) > 1.0
            || (body.Pos.XY - Pos.XY).Length() >= Radius + body.Radius) return false;
        let user = CaelumPlayer(body);
        if (user != null)
            return user.CharacterCreationComplete && !user.CreationWizardOpen
                && !(user.player.cheats & CF_PREDICTING) && user.player.onground;
        return CaelumCombatActor(body) != null && (body.Pos.Z <= body.floorz + 0.5 || body.bOnMobj);
    }

    static void InterruptVictim(Actor body)
    {
        let user = CaelumPlayer(body);
        if (user == null) return;
        CaelumTimeAdvanceState.Halt(user);
        CaelumRestState.Interrupt(user, "CA_REST_MOVED");
    }

    virtual bool Trigger(Actor body) { return false; }

    override void Tick()
    {
        Super.Tick();
        if (Spent) return;
        if (RetryTics > 0) { RetryTics--; return; }
        let nearby = BlockThingsIterator.Create(self, Radius);
        while (nearby.Next())
            if (IsPressedBy(nearby.thing))
            {
                Trigger(nearby.thing);
                RetryTics = 7;
                break;
            }
    }

    Default { Radius 24; Height 1; +NOGRAVITY +FLATSPRITE Scale 0.375; }
    States { Spawn: CMNF A -1 Bright; Stop; }
}

class CaelumMagicMine : CaelumPressureTrap
{
    // args[0]=daño base; args[1]=radio de explosión MU. Cero deshabilita.
    double BlastRadius() { return Max(0, args[1]); }

    override bool Trigger(Actor body)
    {
        if (!IsPressedBy(body) || args[0] <= 0 || args[1] <= 0) return false;
        Spent = true; ActivationCount++;
        InterruptVictim(body);
        Alpha = 0.20;
        A_SetRenderStyle(0.20, STYLE_Translucent);
        A_StartSound("caelum/world/magic_mine", CHAN_BODY);
        let flash = Spawn("CaelumMineBurst", Pos + (0,0,16), NO_REPLACE);
        // El inflictor es la mina: no atribuir al jugador el ataque ambiental.
        A_Explode(args[0], BlastRadius(), XF_THRUSTLESS, false);
        return true;
    }
    Default { Tag "$CA_MAGIC_MINE"; DamageType "CaelumTrapMagic"; }
}

class CaelumMineBurst : Actor
{
    int Age;
    override void Tick()
    {
        Super.Tick();
        Age++;
        Scale = (0.5 + Age*0.10, 0.5 + Age*0.10);
        Alpha = Max(0.0, 1.0-Age/20.0);
        if (Age >= 20) Destroy();
    }
    Default { +NOINTERACTION +NOGRAVITY RenderStyle "Add"; }
    States { Spawn: XFIR A -1 Bright; Stop; }
}

class CaelumTrapTransitGuard : Inventory
{
    int Remaining;
    override void PostBeginPlay() { Super.PostBeginPlay(); Remaining = TICRATE; }
    override void Tick() { Super.Tick(); if (--Remaining <= 0) Destroy(); }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumTrapDestination : Actor
{
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumTeleportTrap : CaelumPressureTrap
{
    Default { Tag "$CA_TELEPORT_TRAP"; }
    // Diagnóstico persistente del último intento. Cero indica éxito.
    int LastRejection;
    int RejectedAttempts;

    // args[0]=TID de un CaelumTrapDestination del mismo mapa.
    int DestinationRejection(Actor body)
    {
        if (args[0] <= 0) return 1;
        let dest = CaelumTrapDestination(ActorIterator.Create(args[0], "CaelumTrapDestination").Next());
        if (dest == null || !level.IsPointInLevel(dest.Pos)) return 1;
        let sec = level.PointInSector(dest.Pos.XY);
        if (dest.Pos.Z < sec.floorplane.ZatPoint(dest.Pos.XY)
            || dest.Pos.Z + body.Height > sec.ceilingplane.ZatPoint(dest.Pos.XY)) return 2;
        // TeleportMove omite algunas decoraciones sólidas no disparables.
        let occupied = BlockThingsIterator.Create(dest, body.Radius);
        while (occupied.Next())
        {
            let other = occupied.thing;
            if (other == body || !other.bSolid || other.bNoClip) continue;
            if (Abs(other.Pos.X-dest.Pos.X) < other.Radius+body.Radius
                && Abs(other.Pos.Y-dest.Pos.Y) < other.Radius+body.Radius
                && other.Pos.Z < dest.Pos.Z+body.Height
                && other.Pos.Z+other.Height > dest.Pos.Z) return 3;
        }
        return 0;
    }

    bool Reject(int reason)
    {
        LastRejection = reason; RejectedAttempts++; return false;
    }

    override bool Trigger(Actor body)
    {
        if (!IsPressedBy(body)) return false;
        if (body.FindInventory("CaelumTrapTransitGuard") != null) return Reject(4);
        int reason = DestinationRejection(body);
        if (reason != 0) return Reject(reason);
        let dest = ActorIterator.Create(args[0], "CaelumTrapDestination").Next();
        // Colisión nativa, sin telefrag ni movimiento alternativo forzado.
        if (!body.TeleportMove(dest.Pos, false)) return Reject(5);
        LastRejection = 0;
        body.Vel = (0,0,0); body.Angle = dest.Angle; body.ClearInterpolation();
        body.GiveInventoryType("CaelumTrapTransitGuard");
        InterruptVictim(body);
        ActivationCount++;
        A_StartSound("caelum/world/magic_teleport", CHAN_BODY);
        body.A_StartSound("caelum/world/magic_teleport", CHAN_BODY);
        let user = CaelumPlayer(body);
        if (user != null)
        {
            user.A_SetBlend("80c8ff",0.35,12);
            user.A_Print(StringTable.Localize("CA_TRAP_TELEPORTED",false));
            user.LastImpactFallingVelocityZ = 0;
            user.ImpactGroundTrackingInitialized = false;
        }
        return true;
    }
    States { Spawn: CMNQ A -1 Bright; Stop; }
}

class CaelumCrusherTrap : CaelumPressureTrap
{
    Array<Sector> Panels;
    int StartedPanels;
    bool MovementFinished;

    // args[0]=daño nativo por pulso; args[1]=MU/tic; args[2]=muestreo XY.
    // 0 en args[2] mueve sólo el sector del actor; 32 selecciona los cuatro
    // paneles de 64 MU usados en MAP08. No toca sectores vecinos adicionales.
    bool Release()
    {
        if (Spent || args[0] <= 0 || args[1] <= 0) return false;
        Panels.Clear();
        for (int x = -1; x <= 1; x += 2)
            for (int y = -1; y <= 1; y += 2)
            {
                let sec = level.PointInSector(Pos.XY + (x*args[2], y*args[2]));
                bool found = false;
                for (int i=0; i<Panels.Size(); i++) if (Panels[i] == sec) found = true;
                if (!found) Panels.Push(sec);
            }
        for (int i=0; i<Panels.Size(); i++)
            if (Panels[i].PlaneMoving(Sector.ceiling)) return false;
        for (int i=0; i<Panels.Size(); i++)
            if (level.CreateCeiling(Panels[i], Ceiling.ceilCrushRaiseAndStay,
                null, args[1], args[1], 8, args[0], 2, 0, Ceiling.crushDoom)) StartedPanels++;
        if (StartedPanels == 0) return false;
        Spent = true; ActivationCount++;
        A_StartSound("caelum/world/crusher", CHAN_BODY);
        return true;
    }

    bool IsMoving()
    {
        for (int i=0; i<Panels.Size(); i++)
            if (Panels[i].PlaneMoving(Sector.ceiling)) return true;
        return false;
    }

    override bool Trigger(Actor body)
    {
        if (!IsPressedBy(body) || !Release()) return false;
        InterruptVictim(body); return true;
    }

    override void Tick()
    {
        Super.Tick();
        if (Spent && !MovementFinished && !IsMoving())
        {
            MovementFinished = true;
            Alpha = 0.20; A_SetRenderStyle(0.20, STYLE_Translucent);
            A_StartSound("caelum/world/crusher", CHAN_BODY);
        }
    }
    Default { Tag "$CA_CRUSHER_TRAP"; Radius 64; Scale 1.0; }
    States { Spawn: CMNE A -1; Stop; }
}

class CaelumMagicHazardWorld : Object play
{
    static void Prepare()
    {
        if (level.MapName != "MAP08") return;
        // Sólo lo llama una vez la revisión guardada del controlador existente.
        let mine = CaelumMagicMine(Actor.Spawn("CaelumMagicMine", (1728,640,0.5), NO_REPLACE));
        if (mine != null) { mine.args[0]=100; mine.args[1]=128; mine.ChangeTid(43610); }
        let dest = Actor.Spawn("CaelumTrapDestination", (1152,1664,0), NO_REPLACE);
        if (dest != null) { dest.ChangeTid(43612); dest.Angle=270; }
        let teleport = CaelumTeleportTrap(Actor.Spawn("CaelumTeleportTrap", (2048,640,0.5), NO_REPLACE));
        if (teleport != null) { teleport.args[0]=43612; teleport.ChangeTid(43611); }
        let crusher = CaelumCrusherTrap(Actor.Spawn("CaelumCrusherTrap", (2240,1216,0.5), NO_REPLACE));
        if (crusher != null) { crusher.args[0]=10; crusher.args[1]=8; crusher.args[2]=32; crusher.ChangeTid(43613); }
        let lever = CaelumHazardReleaseSwitch(Actor.Spawn("CaelumHazardReleaseSwitch", (2240,1088,0), NO_REPLACE));
        if (lever != null) { lever.args[0]=43613; lever.Angle=90; }
    }

    static void Report()
    {
        let it = ThinkerIterator.Create("CaelumPressureTrap"); CaelumPressureTrap trap;
        while ((trap = CaelumPressureTrap(it.Next())) != null)
        {
            Console.Printf("Trampa %s TID=%d gastada=%d activaciones=%d args=(%d,%d,%d)",
                trap.GetClassName(), trap.tid, trap.Spent, trap.ActivationCount,
                trap.args[0],trap.args[1],trap.args[2]);
            let portal = CaelumTeleportTrap(trap);
            if (portal != null)
                Console.Printf("  Teletransporte rechazos=%d ultimo=%d (0 correcto, 1 sin destino, 2 altura, 3 ocupado, 4 espera 35 tics, 5 colision nativa)",
                    portal.RejectedAttempts, portal.LastRejection);
        }
    }
}
