// Fixture compatible con el paquete anterior; jamás se distribuye en src.
class CA471AmmoChecks : CA380Checks
{
    int LiveAmmo;
    void RecoverStations(CaelumPlayer u)
    {
        // Censo único de la escena privada: sólo hay dos estaciones.
        let scan=ThinkerIterator.Create("CaelumWorkbenchStation");Bench=CaelumCraftingStation(scan.Next());
        scan=ThinkerIterator.Create("CaelumRangedWorkshopStation");Ranged=CaelumCraftingStation(scan.Next());
        if(Ranged==null){scan=ThinkerIterator.Create("CaelumAlchemyStation");Ranged=CaelumCraftingStation(scan.Next());}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca471_suite')Suite(u);
        if(e.Name=='ca471_save')Save(u);
        if(e.Name=='ca471_verify')Verify(u);
        // CURRENT_ONLY
    }
}
