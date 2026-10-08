// Compiles unchanged on the accepted 5.1.2 source and the geometry-compatible
// 5.1.3 package. Original saves/packages remain separate rollback evidence.
class CA133LegacyMarker : Actor
{
    CaelumPortDefender Body;
    int Health,Roster,Revision;
    vector3 Position,Post;
    override void Tick()
    {
        let port=CaelumPortSiege.Get();if(port==null || Body==null)return;
        Health=Body.health;Position=Body.Pos;Post=Body.Station;Roster=port.Defenders.Size();Revision=port.SetupRevision;
    }
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}

class CA133Legacy : StaticEventHandler
{
    bool Restored;
    override void WorldLoaded(WorldEvent e)
    {
        Restored=e.IsSaveGame || e.IsReopen;
        Console.Printf("CA133 LEGACY_LOAD map=%s save=%d reopen=%d sectors=%d",level.MapName,e.IsSaveGame,e.IsReopen,level.sectors.Size());
        if(!Restored || level.MapName!="MAP06")return;
        let marker=CA133LegacyMarker(ThinkerIterator.Create("CA133LegacyMarker").Next());
        let port=CaelumPortSiege.Get();
        bool valid=marker!=null && port!=null && marker.Body==port.Defenders[0]
            && marker.Body.health==marker.Health && marker.Body.Pos==marker.Position && marker.Body.Station==marker.Post
            && port.Defenders.Size()==marker.Roster && port.SetupRevision==marker.Revision;
        Console.Printf("CA133 %s legacy roster, identity, health, assignment and progress",valid ? "PASS" : "FAIL");
        Console.Printf("CA133 LEGACY_COMPLETE");
    }
    override void WorldTick()
    {
        if(Restored || level.MapName!="MAP06" || level.time!=75)return;
        let port=CaelumPortSiege.Get();let marker=CA133LegacyMarker(Actor.Spawn("CA133LegacyMarker"));
        marker.Body=port.Defenders[0];port.Victory=true;
        Console.Printf("CA133 LEGACY_SEEDED roster=%d revision=%d",port.Defenders.Size(),port.SetupRevision);
    }
}
