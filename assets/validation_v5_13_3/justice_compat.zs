// El fixture conserva las clases del guardado previo; no cambia la geometría.
class CA440JusticeCompatibility : StaticEventHandler
{
    bool Done;
    void Check(bool okay,String label){Console.Printf("CA440J %s %s",okay?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        if(Done)return;
        let user=CaelumPlayer(players[0].mo),other=CaelumPlayer(players[1].mo);
        if(!CaelumWorldClockTicker.Ready(user) || !CaelumWorldClockTicker.Ready(other))return;
        Done=true;
        Check(level.MapName=="MAP01" && level.Sectors.Size()==7749,"pre-arena mansion save retains exact geometry");
        Check(CaelumJusticeGeometry.Get()==null,"compatibility package reports no Justice arena");
        let ledger=CA440IndexLedger(user.FindInventory('CA440IndexLedger'));
        Check(ledger!=null && ledger.Phase==2,"pre-arena inventory ledger is preserved");
        Check(user!=other && user.health>0 && other.health>0,"both original live characters recover");
        Check(CaelumCartographyCatalogueData.MatchesMansionGeometry(level.GetChecksum())
            && CaelumCartographyCatalogueData.MatchesMansionGeometry(CaelumCartographyCatalogueData.MAP01_CHECKSUM),
            "mansion cartography accepts original and appended geometry");
        Check(CaelumCartographyCatalogueData.MatchesCityGeometry(CaelumCartographyCatalogueData.MAP06_PREJUSTICE_CHECKSUM)
            && CaelumCartographyCatalogueData.MatchesCityGeometry(CaelumCartographyCatalogueData.MAP06_CHECKSUM),
            "city cartography accepts original and appended geometry");
        Console.Printf("CA440J RESULT compatibility");
    }
}
