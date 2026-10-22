// Claves compartidas de nombres de estaciones; no cambian recetas.
class CaelumCartographyServiceData : Object
{
    static String StationName(int stationType)
    {
        switch (stationType)
        {
            case CaelumConstants.CRAFTING_STATION_FORGE:
                return "CA_CRAFTING_STATION_FORGE";
            case CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP:
                return "CA_CRAFTING_STATION_RANGED_WORKSHOP";
            case CaelumConstants.CRAFTING_STATION_ARMOR_WORKSHOP:
                return "CA_CRAFTING_STATION_ARMOR_WORKSHOP";
            case CaelumConstants.CRAFTING_STATION_ESSENCE_ALTAR:
                return "CA_CRAFTING_STATION_ESSENCE_ALTAR";
            case CaelumConstants.CRAFTING_STATION_WORKBENCH:
                return "CA_CRAFTING_STATION_WORKBENCH";
            case CaelumConstants.CRAFTING_STATION_ANVIL:
                return "CA_CRAFTING_STATION_ANVIL";
            case CaelumConstants.CRAFTING_STATION_SAWMILL:
                return "CA_CRAFTING_STATION_SAWMILL";
            case CaelumConstants.CRAFTING_STATION_SEWING_MACHINE:
                return "CA_CRAFTING_STATION_SEWING_MACHINE";
            case CaelumConstants.CRAFTING_STATION_GLOBE:
                return "CA_CRAFTING_STATION_GLOBE";
            case CaelumConstants.CRAFTING_STATION_JEWELER_BENCH:
                return "CA_CRAFTING_STATION_JEWELER_BENCH";
            case CaelumConstants.CRAFTING_STATION_FINE_TOOLS_BENCH:
                return "CA_CRAFTING_STATION_FINE_TOOLS_BENCH";
            case CaelumConstants.CRAFTING_STATION_MASTER_BENCH:
                return "CA_CRAFTING_STATION_MASTER_BENCH";
            case CaelumConstants.CRAFTING_STATION_ALCHEMY:
                return "CA_CRAFTING_STATION_ALCHEMY";
            default:
                return "CA_CRAFTING_STATION_NONE";
        }
    }

}
