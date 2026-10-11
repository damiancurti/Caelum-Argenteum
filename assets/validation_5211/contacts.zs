class CA194Contacts : CA194Combat
{
    bool Loaded;
    override void WorldLoaded(WorldEvent event) { Loaded=event.IsSaveGame;Age=0; }
    override void WorldTick()
    {
        Age++;
        if(Age!=10)return;
        if(!Loaded)
        {
            let a=Fresh(200),b=Fresh(70);a.ChangeTid(44940);b.ChangeTid(44941);
            b.SetOrigin(a.Pos+(32,0,0),false);
            let contact=a.LatchImpactContact(b);contact.BeginResolutionTick(level.time);
            CaelumImpactEnergy.AddWork(contact,1000,500);contact.PendingWorkJoules=1000;
            Check("shared contact before save",contact==b.GetImpactContactState(a),1);
            Check("checkpoint raw work",contact.PendingWorkJoules,1000);
            Console.Printf("CA194 DONE failures=%d passes=%d checkpoint-ready",Failures,Passes);
            return;
        }
        let a=CaelumCombatActor(ActorIterator.Create(44940,"CA194Target").Next());
        let b=CaelumCombatActor(ActorIterator.Create(44941,"CA194Target").Next());
        Check("saved first actor",a!=null,1);Check("saved second actor",b!=null,1);
        if(a==null || b==null)return;
        let contact=a.GetImpactContactState(b);
        Check("saved shared contact identity",contact!=null && contact==b.GetImpactContactState(a),1);
        if(contact==null)return;
        Check("saved pending energy",contact.PendingWorkJoules,1000);
        let snapshot=CaelumImpactWorkSnapshot(contact.PendingGeometry);
        Check("saved geometry",snapshot!=null && snapshot.FirstArea!=null && snapshot.SecondArea!=null,1);
        int hpA=a.health,hpB=b.health;
        a.Vel=b.Vel=(0,0,0);a.CollidedWith(b,false);b.CollidedWith(a,true);
        Check("loaded resting contact no new impact first",a.health,hpA);
        Check("loaded resting contact no new impact second",b.health,hpB);
        CaelumImpactEnergy.ConsumeWork(contact);
        Check("loaded pending work first final",hpA-a.health,725);
        Check("loaded pending work second final",hpB-b.health,855);
        CaelumImpactEnergy.ConsumeWork(contact);
        Check("loaded consumed once",hpA-a.health,725);
        Check("loaded accumulator empty",contact.PendingWorkJoules,0);
        Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
    }
}
