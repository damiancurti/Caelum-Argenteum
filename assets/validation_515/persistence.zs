class CA135Marker : Actor
{
    CaelumCombatActor Body;
    double Anima,Exposure;
    int SavedHealth,PowerTics;
    override void Tick()
    {
        if(Body==null)return;
        SavedHealth=Body.health;Anima=Body.CurrentCombatAnima;
        if(Body.ThermalState!=null)Exposure=Body.ThermalState.Exposure;
        let power=Powerup(Body.FindInventory("CaelumLifeRegeneration"));PowerTics=power!=null ? power.EffectTics : 0;
    }
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA135Seed : StaticEventHandler
{
    override void WorldTick()
    {
        if(level.MapName!="CA135")return;
        if(level.time==1 && ThinkerIterator.Create("CA135Marker").Next()==null)
        {
            let user=CaelumPlayer(players[0].mo);user.InitializeDirectMapCharacter();user.CreationWizardOpen=true;
            let marker=CA135Marker(Actor.Spawn("CA135Marker"));
            marker.Body=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(7000,7000,0)));
            marker.Body.CaelumDiagnosticPassiveAI=true;marker.Body.tics=-1;
        }
        if(level.time!=50)return;
        let marker=CA135Marker(ThinkerIterator.Create("CA135Marker").Next());
        marker.Body.health=200;marker.Body.CurrentCombatAnima=234.5;
        let s=CaelumThermalBody.Get(marker.Body,true);s.Exposure=2.25;
        s.RuntimeReady=true;s.RuntimeMap=level.MapName;s.LastRealTic=level.maptime;s.NextUpdateTic=2147480000;
        let item=CaelumConsumableItem(Actor.Spawn("CaelumLifePotion",marker.Body.Pos,NO_REPLACE));
        item.Amount=1;item.AttachToOwner(marker.Body);marker.Body.UseInventory(item);
        Console.Printf("CA135 SEED failures=0");
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let marker=CA135Marker(ThinkerIterator.Create("CA135Marker").Next());
        let body=marker!=null ? marker.Body : null;
        let effect=body!=null ? Powerup(body.FindInventory("CaelumLifeRegeneration")) : null;
        bool ok=body!=null && body.health==marker.SavedHealth && body.CurrentCombatAnima==marker.Anima
            && body.ThermalState.Exposure==marker.Exposure && effect!=null && effect.EffectTics==marker.PowerTics;
        Console.Printf("CA135 ORIGINAL_LOAD failures=%d",int(!ok));
    }
}
