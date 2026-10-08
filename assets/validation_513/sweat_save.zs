// Uses only revision-two APIs so the same seed works in the original package.
class CA133SweatMarker : Actor
{
    CaelumCombatActor Body;
    double Exposure,Acclimation,Damage,Water,Thirst;
    int Revision;
    override void Tick()
    {
        if(Body==null)return;
        let s=Body.ThermalState;if(s==null)return;
        Exposure=s.Exposure;Acclimation=s.Acclimation;Damage=s.DamageRemainder;Water=s.ActorWaterKg[0];Revision=s.Revision;
        let user=CaelumPlayer(players[0].mo);if(user!=null)Thirst=user.CurrentThirst;
    }
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA133SweatSeed : StaticEventHandler
{
    override void WorldTick()
    {
        if(level.time==1)
        {
            let user=CaelumPlayer(players[0].mo);user.InitializeDirectMapCharacter();user.CreationWizardOpen=true;
            let marker=CA133SweatMarker(Actor.Spawn("CA133SweatMarker"));
            marker.Body=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(7000,7000,0)));marker.Body.tics=-1;
        }
        if(level.time!=50)return;
        let marker=CA133SweatMarker(ThinkerIterator.Create("CA133SweatMarker").Next());
        let s=CaelumThermalBody.Get(marker.Body,true);s.Exposure=2.25;s.Acclimation=3;s.DamageRemainder=0.375;s.ActorWaterKg[0]=0.007;
        s.RuntimeReady=true;s.RuntimeMap=level.MapName;s.LastRealTic=level.maptime;s.NextUpdateTic=2147480000;
        let user=CaelumPlayer(players[0].mo);user.CurrentThirst=37;user.PersistCharacterState();
        Console.Printf("CA133 SWEAT_SEED revision=%d",s.Revision);
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let marker=CA133SweatMarker(ThinkerIterator.Create("CA133SweatMarker").Next());
        bool ok=marker!=null && marker.Body!=null && marker.Body.ThermalState.Exposure==marker.Exposure
            && marker.Body.ThermalState.Acclimation==marker.Acclimation && marker.Body.ThermalState.DamageRemainder==marker.Damage
            && marker.Body.ThermalState.ActorWaterKg[0]==marker.Water && CaelumPlayer(players[0].mo).CurrentThirst==marker.Thirst;
        Console.Printf("CA133 %s original thermal state and player Thirst survive native load",ok ? "PASS" : "FAIL");
        Console.Printf("CA133 SWEAT_OLD_LOAD failures=%d",int(!ok));
    }
}
