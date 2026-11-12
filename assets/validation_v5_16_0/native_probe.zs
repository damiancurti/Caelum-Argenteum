// #452: comprobación aislada de arranque y etiquetas; no concede progreso.
class CA452Probe : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca452_probe")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        bool ok=level.MapName=="MAP02" && user!=null && user.health>0
            && user.CharacterCreationComplete && user.GetPersistentCharacterState(false)!=null;
        CaelumHazardDiagnostics.Report();
        CaelumSewerMaze.Report();
        Console.Printf("CA452 NATIVE %s map=%s",ok?"PASS":"FAIL",level.MapName);
    }
}
