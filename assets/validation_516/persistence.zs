class CA143LegacySoldier : CaelumPortDefender { override void Tick() {} }
class CA143LegacyMarker : Actor
{
    CaelumPortDefender Body;
    double FullHeight,Durability;
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA143Seed : StaticEventHandler
{
    override void WorldTick()
    {
        if(level.MapName!="CA143")return;
        if(level.time==1)
        {
            let user=CaelumPlayer(players[0].mo);user.InitializeDirectMapCharacter();user.bNOTARGET=true;
            let marker=CA143LegacyMarker(Actor.Spawn("CA143LegacyMarker"));
            marker.Body=CaelumPortDefender(Actor.Spawn("CA143LegacySoldier",(3072,4096,0)));
        }
        if(level.time!=60)return;
        let marker=CA143LegacyMarker(ThinkerIterator.Create("CA143LegacyMarker").Next());
        let body=marker.Body;body.Carbine=new("CaelumCityCarbine");body.Carbine.Initialize(body);
        let carbine=body.Carbine;carbine.Magazine=3;carbine.ReloadRemaining=1.25;carbine.ReloadTotal=2.5;
        carbine.ShotCount=4;carbine.ReloadCount=2;carbine.NextShotTic=200;carbine.Weapon.Durability-=7;
        marker.Durability=carbine.Weapon.Durability;marker.FullHeight=body.Height;
        body.health=1234;body.CurrentCombatAir=231.5;body.CurrentCombatAnima=123.5;
        let thermal=CaelumThermalBody.Get(body,true);thermal.Exposure=1.25;
        Console.Printf("CA143 SEED revision=%d failures=0",carbine.Revision);
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="CA143" || (!e.IsSaveGame && !e.IsReopen))return;
        let marker=CA143LegacyMarker(ThinkerIterator.Create("CA143LegacyMarker").Next());
        let body=marker!=null ? marker.Body : null;let carbine=body!=null ? body.Carbine : null;
        bool ok=carbine!=null && carbine.Magazine==3 && carbine.ReloadRemaining==1.25 && carbine.ReloadTotal==2.5
            && carbine.ShotCount==4 && carbine.ReloadCount==2 && carbine.NextShotTic==200 && carbine.Held
            && carbine.Weapon.Durability==marker.Durability && body.health==1234 && body.CurrentCombatAir==231.5
            && body.CurrentCombatAnima==123.5 && body.ThermalState.Exposure==1.25;
        Console.Printf("CA143 SNAPSHOT saved=%d reopened=%d failures=%d",e.IsSaveGame,e.IsReopen,int(!ok));
    }
}
