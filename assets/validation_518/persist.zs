class CA137SavedScene : Actor
{
    CaelumCombatActor Body;
    CaelumActorProjectile MagicShot,Arrow;
    int Age;
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
    override void Tick()
    {
        Super.Tick();Age++;
        if(Age==1)
        {
            Body=CaelumCombatActor(Spawn("CaelumMandinga",(2250,4096,0)));Body.bDORMANT=true;
            MagicShot=CaelumActorProjectile(Spawn("CaelumActorSimpleElementalProjectile",(2300,4200,60)));
            MagicShot.StoreCaelumElementalPayload(1,true,100,100);MagicShot.Vel=(0,.5,0);MagicShot.ConfigureCaelumTravelDistance(1000);
            Arrow=CaelumActorProjectile(Spawn("CaelumArrowProjectile",(2350,4200,60)));Arrow.Vel=(0,.5,0);
        }
        if(Age==3)
        {
            Body.ElementalStatus.BurnRemaining=100;Body.ElementalStatus.PoisonRemaining=100;
            Body.ElementalStatus.FreezeRemaining=100;Body.ElementalStatus.LightningStunRemaining=100;
            Body.ElementalStatus.UpdateVisualEffects(Body);
        }
    }
}
class CA137Persist : StaticEventHandler
{
    int SinceLoad;
    override void WorldLoaded(WorldEvent e){SinceLoad=0;Console.Printf("CA137 PERSIST map=%s save=%d reopen=%d",level.MapName,e.IsSaveGame,e.IsReopen);}
    override void WorldTick()
    {
        SinceLoad++;let u=CaelumPlayer(players[0].mo);if(u==null || level.MapName!="CA137")return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        let scene=CA137SavedScene(ThinkerIterator.Create("CA137SavedScene").Next());
        if(scene==null && level.time==70)scene=CA137SavedScene(Actor.Spawn("CA137SavedScene"));
        if(scene!=null && scene.Age>=5 && (SinceLoad==5 || level.time==90 || SinceLoad==15))
        {
            int visuals=0;let it=ThinkerIterator.Create("CaelumAttachedElementalVisual");while(it.Next()!=null)visuals++;
            bool valid=scene.Body!=null && scene.MagicShot!=null && scene.Arrow!=null
                && scene.Body.ElementalStatus!=null && visuals==4;
            Console.Printf("CA137 %s persistence states=%d scene_age=%d ice_remaining=%.6f arrow_y=%.6f magic_y=%.6f",valid ? "PASS" : "FAIL",visuals,scene.Age,scene.Body.ElementalStatus.FreezeRemaining,scene.Arrow.Pos.Y,scene.MagicShot.Pos.Y);
            Console.Printf("CA137 PERSIST COMPLETE failures=%d",int(!valid));
        }
    }
}
