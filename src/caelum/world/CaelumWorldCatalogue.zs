// Identidades de contenido, independientes del orden de presentación y del
// nombre traducido. El cero no identifica una ubicación ni una conexión.
class CaelumWorldCatalogue : Object
{
    const LOCATION_CAPACITY = 32;
    const CONNECTION_CAPACITY = 32;
    const LOCATION_UNKNOWN = 0;
    const LOCATION_MANSION = 1;
    const LOCATION_SEWERS = 2;
    const LOCATION_RESERVOIR = 3;
    const LOCATION_TAROT_CHAMBERS = 4;
    const LOCATION_MAINTENANCE = 5;
    const LOCATION_DEFINED_COUNT = 6;
    const CONNECTION_NONE = 0;
    const CONNECTION_RETURN = 1;
    // Cada sentido tiene su identidad: recorrer la ida no inventa la vuelta.
    const CONNECTION_TO_RESERVOIR = 2;
    const CONNECTION_FROM_RESERVOIR = 3;
    const CONNECTION_TO_TAROT = 4;
    const CONNECTION_FROM_TAROT = 5;
    const CONNECTION_TO_MAINTENANCE = 6;
    const CONNECTION_FROM_MAINTENANCE = 7;
    const CONNECTION_DEFINED_COUNT = 8;

    static clearscope bool IsLocation(int id)
    {
        return id > LOCATION_UNKNOWN && id < LOCATION_DEFINED_COUNT;
    }

    static clearscope bool IsConnection(int id)
    {
        return id > CONNECTION_NONE && id < CONNECTION_DEFINED_COUNT;
    }

    static clearscope int LocationForMap(String mapName)
    {
        if (mapName ~== "MAP01") return LOCATION_MANSION;
        if (mapName ~== "MAP02") return LOCATION_SEWERS;
        if (mapName ~== "MAP03") return LOCATION_RESERVOIR;
        if (mapName ~== "MAP04") return LOCATION_TAROT_CHAMBERS;
        if (mapName ~== "MAP05") return LOCATION_MAINTENANCE;
        return LOCATION_UNKNOWN;
    }

    static clearscope String MapForLocation(int id)
    {
        if (id == LOCATION_MANSION) return "MAP01";
        if (id == LOCATION_SEWERS) return "MAP02";
        if (id == LOCATION_RESERVOIR) return "MAP03";
        if (id == LOCATION_TAROT_CHAMBERS) return "MAP04";
        if (id == LOCATION_MAINTENANCE) return "MAP05";
        return "";
    }

    static clearscope bool IsTimelessMap(String mapName)
    {
        // La mansión de MAP01 pertenece al Limbo. Toda otra ubicación,
        // incluso un mapa de prueba aún sin catalogar, usa el ritmo común.
        return LocationForMap(mapName) == LOCATION_MANSION;
    }

    static clearscope String LocationNameKey(int id)
    {
        if (id == LOCATION_MANSION) return "CA_MAP01_NAME";
        if (id == LOCATION_SEWERS) return "CA_MAP02_SEWER_NAME";
        if (id == LOCATION_RESERVOIR) return "CA_MAP03_NAME";
        if (id == LOCATION_TAROT_CHAMBERS) return "CA_MAP04_NAME";
        if (id == LOCATION_MAINTENANCE) return "CA_MAP05_NAME";
        return "CA_WORLD_UNREGISTERED";
    }

    static clearscope int ConnectionOrigin(int id)
    {
        if (id == CONNECTION_RETURN) return LOCATION_MANSION;
        if (id == CONNECTION_TO_RESERVOIR || id == CONNECTION_TO_TAROT
            || id == CONNECTION_TO_MAINTENANCE) return LOCATION_SEWERS;
        if (id == CONNECTION_FROM_RESERVOIR) return LOCATION_RESERVOIR;
        if (id == CONNECTION_FROM_TAROT) return LOCATION_TAROT_CHAMBERS;
        if (id == CONNECTION_FROM_MAINTENANCE) return LOCATION_MAINTENANCE;
        return LOCATION_UNKNOWN;
    }

    static clearscope int ConnectionDestination(int id)
    {
        if (id == CONNECTION_RETURN || id == CONNECTION_FROM_RESERVOIR
            || id == CONNECTION_FROM_TAROT || id == CONNECTION_FROM_MAINTENANCE)
            return LOCATION_SEWERS;
        if (id == CONNECTION_TO_RESERVOIR) return LOCATION_RESERVOIR;
        if (id == CONNECTION_TO_TAROT) return LOCATION_TAROT_CHAMBERS;
        if (id == CONNECTION_TO_MAINTENANCE) return LOCATION_MAINTENANCE;
        return LOCATION_UNKNOWN;
    }

    static clearscope String ConnectionNameKey(int id)
    {
        if (id == CONNECTION_RETURN) return "CA_WORLD_RETURN";
        if (IsSewerConnection(id)) return LocationNameKey(ConnectionDestination(id));
        return "CA_WORLD_UNKNOWN_CONNECTION";
    }

    static clearscope bool IsSewerConnection(int id)
    {
        return id >= CONNECTION_TO_RESERVOIR && id < CONNECTION_DEFINED_COUNT;
    }
}
