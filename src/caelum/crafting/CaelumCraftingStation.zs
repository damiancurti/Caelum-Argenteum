// Estaciones físicas de crafteo. Todas reutilizan el mismo menú y la misma
// transacción: la subclase solo decide qué grupo de recetas está disponible.
class CaelumCraftingStation : Actor
{
    Default
    {
        Radius 20;
        Height 48;
        Mass 1000;
        Scale 0.75;
        +SOLID
        +USESPECIAL
        Activation THINGSPEC_Switch;
    }

    virtual int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_NONE;
    }

    void OpenForActivator(Actor activator)
    {
        CaelumPlayer user = CaelumPlayer(activator);
        if (user == null) { return; }
        user.OpenCraftingStation(GetCraftingStationType());
    }

    override void Activate(Actor activator)
    {
        OpenForActivator(activator);
    }

    override void Deactivate(Actor activator)
    {
        // THINGSPEC_Switch alterna Activate/Deactivate en usos sucesivos.
        // Ambas rutas abren la misma estación para que pueda reutilizarse.
        OpenForActivator(activator);
    }
}

class CaelumForgeStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_FORGE;
    }
    States
    {
    Spawn:
        CSWD A -1;
        Stop;
    }
}

class CaelumBowWorkshopStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_BOW_WORKSHOP;
    }
    States
    {
    Spawn:
        CBOW A -1;
        Stop;
    }
}

class CaelumArmorWorkshopStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_ARMOR_WORKSHOP;
    }
    States
    {
    Spawn:
        CAHV A -1;
        Stop;
    }
}

class CaelumEssenceAltarStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_ESSENCE_ALTAR;
    }
    States
    {
    Spawn:
        CSTF A -1;
        Stop;
    }
}

class CaelumWorkbenchStation : CaelumCraftingStation
{
    override int GetCraftingStationType()
    {
        return CaelumConstants.CRAFTING_STATION_WORKBENCH;
    }
    States
    {
    Spawn:
        CAXE A -1;
        Stop;
    }
}
