// Infraestructura física de crafting conectada por proximidad.
// Cada actor es una estación real del escenario y queda preparado para heredar
// movilidad cuando se implemente el sistema ambiental de objetos empujables.
class CaelumCraftingStation : CaelumMovableProp
{
    int LastCraftingNetworkScanToken;
    Actor LastCraftingNetworkScanPlayer;

    Default
    {
        Radius 20;
        Height 48;
        Scale 0.5;
        // args[0] queda en 0: la movilidad existe por herencia, pero se
        // mantiene desactivada hasta definir masa y requisito físico.
        +USESPECIAL
        Activation THINGSPEC_Switch;
    }

    virtual int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    bool IsNetworkNeighbor(CaelumCraftingStation other)
    {
        if (other == null || other == self) { return false; }

        double dx = other.Pos.X - Pos.X;
        double dy = other.Pos.Y - Pos.Y;
        double dz = other.Pos.Z - Pos.Z;
        double distance = sqrt((dx * dx) + (dy * dy) + (dz * dz));
        return distance <= CaelumConstants.CRAFTING_NETWORK_LINK_DISTANCE;
    }

    void CollectCraftingNetwork(CaelumPlayer user, int scanToken)
    {
        if (user == null) { return; }

        // Token + jugador evita ciclos sin mezclar escaneos simultáneos de
        // jugadores distintos en multijugador.
        if (LastCraftingNetworkScanPlayer == user
            && LastCraftingNetworkScanToken == scanToken)
        {
            return;
        }
        LastCraftingNetworkScanPlayer = user;
        LastCraftingNetworkScanToken = scanToken;

        user.CraftingNetworkCapabilities |=
            CaelumCraftingRules.GetStationCapabilityBit(
                GetCraftingStationType()
            );

        // La red sólo se recalcula al interactuar. Con pocas estaciones es más
        // robusto que mantener enlaces persistentes cada tic.
        let iterator = ThinkerIterator.Create('CaelumCraftingStation');
        CaelumCraftingStation other;
        while ((other = CaelumCraftingStation(iterator.Next())))
        {
            if (other != self && IsNetworkNeighbor(other))
            {
                other.CollectCraftingNetwork(user, scanToken);
            }
        }
    }

    void OpenForActivator(Actor activator)
    {
        CaelumPlayer user = CaelumPlayer(activator);
        if (user == null || user.player == null) { return; }

        // Una estación sólo puede abrirse por una pulsación REAL de Use.
        // Al cerrar crafting con Q, GZDoom puede volver a invocar la ruta
        // Activate/Deactivate de la estación que sigue bajo la mira; como Q
        // no contiene BT_USE, esa reentrada se descarta aquí.
        if ((user.player.cmd.buttons & BT_USE) == 0) { return; }

        // Además conservamos el latch para evitar múltiples aperturas durante
        // una misma pulsación física de Use.
        if (user.CraftingStationUseLatched) { return; }
        user.CraftingStationUseLatched = true;

        int scanToken = user.BeginCraftingNetworkScan();
        CollectCraftingNetwork(user, scanToken);
        user.OpenCraftingNetwork();

        // Si la red no era válida y el menú no llegó a abrirse, permitimos
        // rearmar al soltar Use mediante la misma lógica del jugador.
    }

    override void Activate(Actor activator)
    {
        OpenForActivator(activator);
    }

    override void Deactivate(Actor activator)
    {
        // THINGSPEC_Switch alterna Activate/Deactivate en usos sucesivos.
        // Ambas rutas vuelven a calcular la red y abren el mismo menú.
        OpenForActivator(activator);
    }
}

class CaelumForgeStation : CaelumCraftingStation
{
    // Además del equipo metálico, procesa minerales y aleaciones.
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_FORGE;
    }
    States { Spawn: CFRG A -1; Stop; }
}

class CaelumRangedWorkshopStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP;
    }
    States { Spawn: CRNG A -1; Stop; }
}

// Alias para mapas/builds de desarrollo anteriores.
class CaelumBowWorkshopStation : CaelumRangedWorkshopStation {}

class CaelumArmorWorkshopStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_ARMOR_WORKSHOP;
    }
    States { Spawn: CARM A -1; Stop; }
}

class CaelumEssenceAltarStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_ESSENCE_ALTAR;
    }
    States { Spawn: CESA A -1; Stop; }
}

class CaelumWorkbenchStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_WORKBENCH;
    }
    States { Spawn: CWBK A -1; Stop; }
}

class CaelumAnvilStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_ANVIL;
    }
    States { Spawn: CANV A -1; Stop; }
}

class CaelumSawmillStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_SAWMILL;
    }
    States { Spawn: CSAW A -1; Stop; }
}

class CaelumSewingMachineStation : CaelumCraftingStation
{
    // Refina fibras, tejidos, cuerdas y pieles de las recetas básicas.
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_SEWING_MACHINE;
    }
    States { Spawn: CSEW A -1; Stop; }
}

class CaelumGlobeStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_GLOBE;
    }
    States { Spawn: CGLB A -1; Stop; }
}

class CaelumJewelerBenchStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_JEWELER_BENCH;
    }
    States { Spawn: CJWL A -1; Stop; }
}

class CaelumFineToolsBenchStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH;
    }
    States { Spawn: CFIN A -1; Stop; }
}

class CaelumMasterBenchStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_MASTER_BENCH;
    }
    States { Spawn: CMST A -1; Stop; }
}
