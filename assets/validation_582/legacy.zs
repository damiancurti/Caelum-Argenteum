// Compatible con 5.8.1: sin referencias a clases añadidas por #414.
class CA414LegacyChecks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca414r_quiet'){u.RecordMainM00UnknownVoiceHeard();return;}
        if(e.Name!='ca414r_legacy')return;
        bool ok=u.CharacterCreationComplete && u.health>0;
        Console.Printf("CA414R %s original mansion campaign remains playable",ok?"PASS":"FAIL");
        Console.Printf("CA414R LEGACY map=%s playable=%d health=%d sectors=%d old_geometry=%d",level.MapName,ok,u.health,level.Sectors.Size(),level.Sectors.Size()==7712);
        if(level.MapName=="MAP01" && level.Sectors.Size()!=7712)Console.Printf("CA414R FAIL legacy mansion geometry changed");
        if(level.MapName=="MAP01")
        {
            u.CreationWizardOpen=false;
            let record=u.GetPersistentCharacterState(false);
            u.SetOrigin(CaelumCartographyCatalogueData.MansionPosition(0),false);
            CaelumAuthoredCartography.Update(u,record);
            bool known=CaelumPoiKnowledge.Find(record,"MAP01","mansion-room-"..CaelumCartographyCatalogueData.MansionId(0))!=null;
            Console.Printf("CA414R %s legacy mansion preserves authored room discovery",known?"PASS":"FAIL");
        }
    }
}
