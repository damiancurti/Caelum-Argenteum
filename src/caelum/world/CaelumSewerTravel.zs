// Red de pruebas dentro de un hub nativo. MAP01 queda fuera del catálogo de
// accesos: salir del Limbo conserva su confirmación y limpieza exclusivas.
class CaelumSewerTravel : Object play
{
    static vector3 GatePosition(int id)
    {
        if (id == CaelumWorldCatalogue.CONNECTION_TO_RESERVOIR) return (-236,1104,0);
        if (id == CaelumWorldCatalogue.CONNECTION_TO_TAROT) return (236,1104,0);
        if (id == CaelumWorldCatalogue.CONNECTION_TO_MAINTENANCE) return (344,448,0);
        if (id == CaelumWorldCatalogue.CONNECTION_TO_PORT) return (0,3424,0);
        if (id == CaelumWorldCatalogue.CONNECTION_TO_COAST) return (0,2080,0);
        if (id == CaelumWorldCatalogue.CONNECTION_TO_HAZARD_GALLERY) return (640,704,0);
        return (0,96,0);
    }

    static void PrepareWorld()
    {
        int location = CaelumWorldCatalogue.LocationForMap(level.MapName);
        for (int id = 2; id < CaelumWorldCatalogue.CONNECTION_DEFINED_COUNT; id++)
        {
            if (CaelumWorldCatalogue.ConnectionOrigin(id) != location) continue;
            // También admite la reconstrucción de un guardado anterior de
            // MAP02. No necesita cambiar su geometría ni sus PlayerStarts.
            bool found = false;
            let existing = ThinkerIterator.Create("CaelumSewerTravelGate");
            CaelumSewerTravelGate gate;
            while ((gate = CaelumSewerTravelGate(existing.Next())) != null)
                if (gate.Placed && gate.ConnectionId == id) { found = true; break; }
            if (found) continue;
            gate = CaelumSewerTravelGate(Actor.Spawn("CaelumSewerTravelGate", GatePosition(id), NO_REPLACE));
            if (gate == null) continue;
            gate.ConnectionId = id;
            gate.Placed = true;
            gate.Angle = (id == CaelumWorldCatalogue.CONNECTION_TO_MAINTENANCE
                || id == CaelumWorldCatalogue.CONNECTION_TO_HAZARD_GALLERY) ? 180
                : location == CaelumWorldCatalogue.LOCATION_SEWERS
                    || id == CaelumWorldCatalogue.CONNECTION_TO_PORT
                    || id == CaelumWorldCatalogue.CONNECTION_TO_COAST ? 270 : 90;
        }
    }

    static bool Begin(CaelumPlayer user, CaelumSewerTravelGate gate)
    {
        if (user == null || user.player == null || gate == null || !gate.Placed
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || user.health <= 0 || user.player.playerstate != PST_LIVE
            || (user.player.cheats & CF_PREDICTING)) return false;
        int id = gate.ConnectionId;
        if (!CaelumWorldCatalogue.IsSewerConnection(id)
            || CaelumWorldCatalogue.ConnectionOrigin(id) != CaelumWorldCatalogue.LocationForMap(level.MapName)
            || user.Distance2D(gate) > user.UseRange + gate.Radius
            || Abs(user.Pos.Z-gate.Pos.Z) > 64 || !user.CheckSight(gate)) return false;
        return CaelumTravelService.Begin(user, id, CaelumJourneyState.MODE_FOOT);
    }
}

class CaelumSewerTravelGate : Actor
{
    int ConnectionId;
    bool Placed;
    int VisibleToPlayers;

    override void Tick()
    {
        Super.Tick();
        VisibleToPlayers = 0;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i] || players[i].mo == null) continue;
            let user = players[i].mo;
            if (user.Distance2D(self) <= 256 && Abs(user.Pos.Z-Pos.Z) <= 64
                && user.CheckSight(self)) VisibleToPlayers |= 1 << i;
        }
    }

    override bool Used(Actor activator)
    {
        return CaelumSewerTravel.Begin(CaelumPlayer(activator), self);
    }

    Default
    {
        Radius 20;
        Height 128;
        +SOLID
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        +WALLSPRITE
    }
    States
    {
    Spawn:
        CSGT A -1;
        Stop;
    }
}
