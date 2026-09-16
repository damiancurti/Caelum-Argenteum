// Mobiliario fijo: usa la interacción nativa y la sesión de descanso existente.
// La colisión se presta al ocupante y se restituye cuando queda libre.
class CaelumRestFurniture : Actor abstract
{
    CaelumPlayer Occupant;
    int TrialSlot;
    CaelumDiningTable DiningTable;
    int DiningSeat;

    virtual double PoseAngle() { return Angle + 180; }
    virtual int RestMode() { return CaelumRestRules.MODE_WAIT; }
    virtual clearscope int ComfortFactor() { return 2; }
    virtual bool SupportsRest(CaelumPlayer user) { return Occupant == user; }
    // Ajuste gráfico a las poses RSDO; el volumen físico conserva sus medidas.
    virtual vector3 PoseOffset() { return (Cos(Angle)*-16, Sin(Angle)*-16, 0); }

    bool CanReach(CaelumPlayer user)
    {
        return user != null && user.player != null && user.health > 0
            && (Occupant == null || Occupant == user)
            && user.Distance2D(self) <= user.UseRange + Radius
            && Abs(user.Pos.Z - Pos.Z) <= 8
            && user.CheckSight(self);
    }

    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if (!CanReach(user) || !CaelumUseGeometry.AimedAt(user, self)
            || (user.player.cmd.buttons & BT_USE) == 0) return false;
        return CaelumRestTrial.Open(user, self);
    }

    bool Seat(CaelumPlayer user)
    {
        if (!CanReach(user) || Occupant != null) return false;
        vector3 entry = user.Pos;
        bSolid = false;
        user.SetOrigin(Pos, false);
        // Se comprueba el volumen REAL del personaje, sin telefrag ni cambio
        // de altura/radio. Un mueble cerca de una pared puede no ser apto.
        if (!user.TestMobjLocation() || Abs(user.FloorZ - Pos.Z) > 1
            || user.WaterLevel != 0)
        {
            user.SetOrigin(entry, false);
            RestoreSolid();
            return false;
        }
        Occupant = user;
        return true;
    }

    bool ExitFits(CaelumPlayer user, vector3 position)
    {
        let probe = Actor.Spawn("CaelumRestPlacementProbe", position, NO_REPLACE);
        if (probe == null) return false;
        probe.A_SetSize(user.Radius, user.Height, false);
        bool fits = probe.TestMobjLocation() && Abs(probe.FloorZ - position.Z) <= 1
            && probe.WaterLevel == 0 && user.CheckSight(probe, SF_IGNOREVISIBILITY)
            && probe.Distance2D(self) > Radius + user.Radius + 1;
        probe.Destroy();
        return fits;
    }

    virtual void Release(CaelumPlayer user, vector3 entry)
    {
        if (Occupant != user) return;
        // No deshace un desplazamiento externo, una caída ni una muerte.
        if (user != null && user.health > 0 && user.Distance2D(self) <= 4
            && Abs(user.Pos.Z - Pos.Z) <= 4)
        {
            bool moved = false;
            if (ExitFits(user, entry)) { user.SetOrigin(entry, false); moved = true; }
            double distance = Radius + user.Radius + 12;
            for (int i = 0; i < 8 && !moved; i++)
            {
                double direction = Angle + i*45;
                vector3 candidate = Pos + (Cos(direction)*distance, Sin(direction)*distance, 0);
                if (ExitFits(user, candidate)) { user.SetOrigin(candidate, false); moved = true; }
            }
            // Si todo está ocupado, se levanta aquí y puede salir caminando.
            // El mueble sigue sin bloquear hasta que su volumen quede libre.
        }
        Occupant = null;
        RestoreSolid();
    }

    void RestoreSolid()
    {
        if (Occupant != null) return;
        bSolid = true;
        if (!TestMobjLocation()) bSolid = false;
    }

    override void Tick()
    {
        Super.Tick();
        if (Occupant != null)
        {
            let rest = CaelumRestState.Get(Occupant);
            if (rest == null || rest.Status != CaelumRestRules.STATUS_ACTIVE
                || rest.Furniture != self || rest.OriginMap != level.MapName)
                Occupant = null;
        }
        if (Occupant == null && !bSolid) RestoreSolid();
    }

    Default
    {
        Radius 24; Height 64;
        +SOLID +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE
        +CANPASS
    }
}

class CaelumRestChair : CaelumRestFurniture
{
    Default { Tag "$CA_REST_CHAIR_TITLE"; }
    States { Spawn: CAHC A -1; Stop; }
}

class CaelumRestBed : CaelumRestFurniture
{
    override int RestMode() { return CaelumRestRules.MODE_SLEEP; }
    override int ComfortFactor() { return 4; }
    override vector3 PoseOffset() { return (0, 0, 10); }
    Default { Radius 56; Height 24; Tag "$CA_REST_BED_TITLE"; }
    States { Spawn: CAHC A -1; Stop; }
}

class CaelumRestPlacementProbe : Actor
{
    Default { Radius 16; Height 56; +NOGRAVITY +NOBLOCKMAP +SOLID +CANPASS RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

// Una pareja por alcantarilla; no modifica los WAD ni entrega recursos.
class CaelumRestFurnitureTrial : Object play
{
    static CaelumRestFurniture Find(int slot)
    {
        let it = ThinkerIterator.Create("CaelumRestFurniture");
        CaelumRestFurniture furniture;
        while ((furniture = CaelumRestFurniture(it.Next())) != null)
            if (furniture.TrialSlot == slot) return furniture;
        return null;
    }

    static bool Place(int slot, vector3 position)
    {
        if (Find(slot) != null) return true;
        class<CaelumRestFurniture> kind = "CaelumRestChair";
        if (slot == 2) kind = "CaelumRestBed";
        let furniture = CaelumRestFurniture(Actor.Spawn(kind, position, NO_REPLACE));
        if (furniture == null) return false;
        if (!furniture.TestMobjLocation() || Abs(furniture.FloorZ-position.Z) > 1)
        { furniture.Destroy(); return false; }
        furniture.Angle = 180;
        furniture.TrialSlot = slot;
        return true;
    }

    static bool PrepareWorld()
    {
        if (!CaelumSewerTrialSupport.IsTrialMap()) return true;
        vector3 chair = level.MapName == "MAP02" ? (-160,64,0) : (144,224,0);
        vector3 bed = level.MapName == "MAP02" ? (-144,232,0) : (144,400,0);
        bool chairReady = Place(1, chair);
        bool bedReady = Place(2, bed);
        return chairReady && bedReady;
    }
}

// SpectatorCamera aplica el recorte nativo contra paredes/techos. No permite
// salir del mapa y no sustituye ni modifica la configuración de chasecam.
class CaelumRestCamera : SpectatorCamera
{
    CaelumPlayer Subject;

    void UpdateView(CaelumRestState rest)
    {
        tracer = Subject;
        SetOrigin(Subject.Pos, true);
        CameraFOV = Subject.player.FOV;
        Init(Max(112.0, Subject.Height*2.4), rest.CameraYaw, rest.CameraPitch, VPSF_ABSOLUTEOFFSET);
    }

    override void Tick()
    {
        let rest = CaelumRestState.Get(Subject);
        if (Subject == null || Subject.player == null || rest == null
            || rest.Status != CaelumRestRules.STATUS_ACTIVE || rest.ViewCamera != self
            || rest.OriginMap != level.MapName || Subject.player.camera != self)
        {
            if (Subject != null && Subject.player != null && Subject.player.camera == self)
                Subject.player.camera = Subject;
            Destroy();
            return;
        }
        UpdateView(rest);
    }
}
