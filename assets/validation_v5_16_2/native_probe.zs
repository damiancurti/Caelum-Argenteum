// #454: diagnóstico aislado. No forma parte del paquete distribuido.
class CA454Probe : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_probe")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);
        let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();
        bool ok=level.MapName=="MAP02" && user!=null && user.health>0
            && user.CharacterCreationComplete && marker!=null;
        if(ok)
        {
            let boss=ActorIterator.Create(43799,"CaelumZupayColossus").Next();
            let extraction=ActorIterator.Create(44830,"CaelumMazeLayoutMarker").Next();
            ok=boss!=null && extraction!=null && boss.Pos.Z+boss.Height<=boss.CeilingZ
                && user.Pos.Z+user.Height<=user.CeilingZ;
            Console.Printf("CA454 layout=%d checksum=%s player=(%.1f,%.1f,%.1f) clearance=%.1f boss_clearance=%.1f justice=%d",
                marker.args[0],level.GetChecksum(),user.Pos.X,user.Pos.Y,user.Pos.Z,
                user.CeilingZ-user.FloorZ,boss!=null?boss.CeilingZ-boss.FloorZ:0,
                CaelumJusticeGeometry.Get()!=null);
            ok=ok && CaelumJusticeGeometry.Get()!=null;
        }
        Console.Printf("CA454 NATIVE %s map=%s",ok?"PASS":"FAIL",level.MapName);
    }
}
