class CA140Marker : Actor
{
    CaelumCombatActor Body;
    double Exposure,Acclimation,Damage,Water,Hydration,Sweat,Thirst,Hunger;
    override void Tick()
    {
        if(Body==null)return;
        let s=Body.ThermalState;if(s==null)return;
        Exposure=s.Exposure;Acclimation=s.Acclimation;Damage=s.DamageRemainder;
        Water=s.ActorWaterKg[0];Hydration=s.Hydration;Sweat=s.SweatKg;
        let user=CaelumPlayer(players[0].mo);
        if(user!=null){Thirst=user.CurrentThirst;Hunger=user.CurrentHunger;}
    }
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA140Seed : StaticEventHandler
{
    override void WorldTick()
    {
        if(level.MapName!="CA140")return;
        if(level.time==1)
        {
            if(ThinkerIterator.Create("CA140Marker").Next()!=null)return;
            let user=CaelumPlayer(players[0].mo);user.InitializeDirectMapCharacter();user.CreationWizardOpen=true;
            let marker=CA140Marker(Actor.Spawn("CA140Marker"));
            marker.Body=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(7000,7000,0)));marker.Body.tics=-1;
        }
        if(level.time!=50)return;
        let marker=CA140Marker(ThinkerIterator.Create("CA140Marker").Next());
        let s=CaelumThermalBody.Get(marker.Body,true);
        s.Exposure=2.25;s.Acclimation=3;s.DamageRemainder=0.375;s.ActorWaterKg[0]=0.007;
        s.Hydration=43.25;s.SweatKg=0.123;
        s.RuntimeReady=true;s.RuntimeMap=level.MapName;s.LastRealTic=level.maptime;s.NextUpdateTic=2147480000;
        let user=CaelumPlayer(players[0].mo);user.CurrentThirst=37;user.CurrentHunger=61;user.PersistCharacterState();
        Console.Printf("CA140 SAVE_SEED revision=%d",s.Revision);
    }
    static bool Preserved(CA140Marker marker,bool includePlayer=true)
    {
        if(marker==null || marker.Body==null)return false;
        let s=marker.Body.ThermalState;let user=CaelumPlayer(players[0].mo);
        return s.Exposure==marker.Exposure && s.Acclimation==marker.Acclimation && s.DamageRemainder==marker.Damage
            && s.ActorWaterKg[0]==marker.Water && s.Hydration==marker.Hydration && s.SweatKg==marker.Sweat
            && (!includePlayer || (user.CurrentThirst==marker.Thirst && user.CurrentHunger==marker.Hunger));
    }
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let marker=CA140Marker(ThinkerIterator.Create("CA140Marker").Next());
        Console.Printf("CA140 ORIGINAL_LOAD failures=%d",int(!Preserved(marker)));
    }
}
