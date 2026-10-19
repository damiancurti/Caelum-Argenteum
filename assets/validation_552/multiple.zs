// Diagnóstico aislado: conserva Tick, movimiento y receptores de producción.
class CA311Player : CaelumPlayer
{
    int AuditImpactHits, AuditFirstTic, AuditSecondTic, AuditFirstSource, AuditSecondSource;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        if(mod=='CaelumImpact' && LastImpactKind!=CaelumConstants.IMPACT_KIND_CRUSH)
        {
            if(AuditImpactHits==0){AuditFirstTic=level.time;AuditFirstSource=source!=null?source.tid:0;}
            if(AuditImpactHits==1){AuditSecondTic=level.time;AuditSecondSource=source!=null?source.tid:0;}
            AuditImpactHits++;
        }
        return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
}
class CA311Moving : CA194Moving
{
    int FirstSource, SecondSource, FirstTic, SecondTic, AuditPhase;
    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
    {
        if(mod=='CaelumImpact' && LastImpactKind!=CaelumConstants.IMPACT_KIND_CRUSH)
        {
            if(ImpactHits==0){FirstSource=source!=null?source.tid:0;FirstTic=level.time;}
            if(ImpactHits==1){SecondSource=source!=null?source.tid:0;SecondTic=level.time;}
        }
        return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
}

class CA311Multiple : CA194Motion
{
    CA311Moving Victim, LeftBody, RightBody, ChainA, ChainB, ChainC, TopBody, MidBody, BaseBody;
    CA311Moving SavedA, SavedB;
    CA311Moving PlayerLeft, PlayerRight;
    bool Loaded, SeparatedLoad;
    int SavedHits;
    double LoadedReleaseDistance;

    void DistinctEvents()
    {
        let a=Fresh(200),b=Fresh(200);
        let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",(1200,-1000,0)));
        gate.InitializeGate();gate.StructuralMaximum=gate.health=1000000000;
        Check("first gate source serial seven",gate.ApplySiegeImpact(a,7,200,(8*32.0/35.0,0,0),(1,0,0)),4825);
        Check("second gate source same serial distinct",gate.ApplySiegeImpact(b,7,200,(8*32.0/35.0,0,0),(1,0,0)),4825);
        Check("first source duplicate after second rejected",gate.ApplySiegeImpact(a,7,200,(8*32.0/35.0,0,0),(1,0,0)),0);
        gate.Destroy();a.Destroy();b.Destroy();
        a=Fresh(80);b=Fresh(80);b.SetOrigin(a.Pos+(32,0,0),false);a.AnatomyProfile.ClearRegions();
        for(int i=0;i<4;i++)a.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_LEGS,3,i*0.25,(i+1)*0.25,0,1);
        a.CombatArmor.ArmorType[3]=CaelumConstants.ARMOR_TYPE_HEAVY;a.CombatArmor.Durability[3]=1;
        a.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,b,1,80,80,10,800,0,1,false,100000);
        Check("first event four regions share intact armor",a.LastImpactFinalDamage,22920);
        Check("first event commits armor break",a.CombatArmor.Durability[3],0);
        a.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,b,1,80,80,10,800,0,1,false,100000);
        Check("second same-tic event sees broken armor",a.LastImpactFinalDamage,92420);
        a.Destroy();b.Destroy();
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c311_split_checkpoint")
        {
            let c=SavedA!=null?SavedA.GetImpactContactState(SavedB):null;
            Check("save during partial separation countdown",c!=null && c.Active && c.SeparatedTics>0 && c.SeparatedTics<5,1);
            Console.Printf("CA194 DONE failures=%d passes=%d separation-checkpoint",Failures,Passes);
            return;
        }
        if(e.Name=="c311_rollback")
        {
            Check("original runtime loads original zero-distance save",SavedA!=null && SavedB!=null && LoadedReleaseDistance==0,1);
            Console.Printf("CA194 DONE failures=%d passes=%d original-rollback",Failures,Passes);
            return;
        }
        if(e.Name!="c311_checkpoint")return;
        Check("early native contact exists",SavedA!=null && SavedB!=null && SavedA.GetImpactContactState(SavedB)!=null,1);
        Console.Printf("CA194 DONE failures=%d passes=%d early-checkpoint",Failures,Passes);
    }

    CA311Moving Body(Vector3 position, int id)
    {
        let b=CA311Moving(Actor.Spawn("CA311Moving",position));
        b.ChangeTid(id);b.CombatToughness=0;b.CombatMaximumHealth=b.health=10000000;
        b.CombatLucidityPhysicalStunRemaining=100;b.CollisionEffectiveMassMultiplier=b.CollisionDamageMultiplier=1;
        b.CombatArmor=new("CaelumArmorModel");b.CombatArmor.InitializeDefaults();
        b.AnatomyProfile=new("CaelumAnatomyProfile");
        b.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
        b.bNoGravity=true;
        return b;
    }
    override void WorldLoaded(WorldEvent e) { Loaded=e.IsSaveGame;Age=0; }
    override void WorldTick()
    {
        Age++;
        if(Loaded)
        {
            if(Age==1)
            {
                SavedA=CA311Moving(ActorIterator.Create(45311,"CA311Moving").Next());
                SavedB=CA311Moving(ActorIterator.Create(45312,"CA311Moving").Next());
                Check("saved pair exists",SavedA!=null && SavedB!=null,1);
                if(SavedA==null || SavedB==null)return;
                SeparatedLoad=SavedA.AuditPhase==1;
                let contact=SavedA.GetImpactContactState(SavedB);
                LoadedReleaseDistance=contact!=null?contact.ReleaseDistance:-1;
                Check("saved shared contact identity",contact!=null && contact==SavedB.GetImpactContactState(SavedA),1);
                SavedHits=SavedA.ImpactHits;
                SavedA.Vel=SavedB.Vel=(0,0,0);
                if(!SeparatedLoad){SavedA.CollidedWith(SavedB,false);SavedB.CollidedWith(SavedA,true);}
                else Check("saved partial separation countdown",contact!=null && contact.SeparatedTics>0 && contact.SeparatedTics<5,1);
                Check("loaded callbacks cannot replay hit",SavedA.ImpactHits,SavedHits);
            }
            if(Age<10 && !SeparatedLoad && SavedA!=null && SavedB!=null){SavedA.CollidedWith(SavedB,false);SavedB.CollidedWith(SavedA,true);}
            if(Age==9 && SavedA!=null && SavedB!=null)
            {
                let c=SavedA.GetImpactContactState(SavedB);
                if(!SeparatedLoad)
                {
                    Check("resting loaded contact survives",c!=null,1);
                    if(c!=null)Check("loaded release distance restored",c.ReleaseDistance,48);
                }
                else Check("loaded separation finishes without callbacks",c==null,1);
                Check("resting loaded contact no repeated damage",SavedA.ImpactHits,SavedHits);
                SavedB.SetOrigin(SavedA.Pos+(256,0,0),false);SavedA.AuditPhase=1;
            }
            if(Age==20 && SavedA!=null && SavedB!=null)
            {
                Check("separation removes both saved edges",SavedA.GetImpactContactState(SavedB)==null && SavedB.GetImpactContactState(SavedA)==null,1);
                SavedB.SetOrigin(SavedA.Pos+(40,0,0),false);
                SavedA.Vel=(10,0,0);SavedB.Vel=(0,0,0);SavedA.AuditPhase=0;
            }
            if(Age==40 && SavedA!=null)
            {
                Check("native recontact is a new hit",SavedA.ImpactHits,SavedHits+1);
                Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
            }
            return;
        }
        if(Age==5)
        {
            DistinctEvents();
            let u=CaelumPlayer(players[0].mo);
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.bInvulnerable=false;u.ChangeTid(45350);
            u.Attributes.Toughness=0;u.DerivedStats.BaseMass=u.DerivedStats.TotalMass=80;
            u.CaelumMaximumHealth=u.health=u.player.health=10000000;u.EffectiveEvasionChance=0;
            u.CombatBlockModeActive=false;u.DebugShieldBlocking=false;u.LucidityPhysicalStunRemaining=100;
            u.SetOrigin((0,-500,0),false);u.Vel=(0,0,0);
            PlayerLeft=Body((-u.Radius-24,-500,0),45351);PlayerRight=Body((u.Radius+24,-500,0),45352);
            PlayerLeft.Vel=(10,0,0);PlayerRight.Vel=(-10,0,0);
            Victim=Body((0,0,0),45100);LeftBody=Body((-40,0,0),45101);RightBody=Body((40,0,0),45102);
            LeftBody.Vel=(10,0,0);RightBody.Vel=(-10,0,0);
            ChainA=Body((-600,400,0),45200);ChainB=Body((-560,400,0),45201);ChainC=Body((-520,400,0),45202);
            ChainA.Vel=(24,0,0);
            BaseBody=Body((500,500,0),45210);MidBody=Body((500,500,56),45211);TopBody=Body((500,500,220),45212);
            BaseBody.bNoGravity=MidBody.bNoGravity=TopBody.bNoGravity=false;TopBody.Vel=(0,0,-8);
        }
        if(Age==45)
        {
            let user=CA311Player(players[0].mo);
            Check("player receives exactly two impact events",user!=null && user.AuditImpactHits==2,1);
            if(user!=null)Check("player receives distinct sources in same tic",user.AuditFirstTic==user.AuditSecondTic && user.AuditFirstSource!=user.AuditSecondSource,1);
            Check("player native two incoming contacts",PlayerLeft.ImpactHits==1 && PlayerRight.ImpactHits==1,1);
            Check("player sources both identify pawn",PlayerLeft.FirstSource==45350 && PlayerRight.FirstSource==45350,1);
            Check("player incoming contacts same tic",PlayerLeft.FirstTic,PlayerRight.FirstTic);
            Check("two native sources both hit",Victim.ImpactHits,2);
            Check("same tic distinct sources",Victim.FirstTic==Victim.SecondTic && Victim.FirstSource!=Victim.SecondSource,1);
            Check("chain first contact delivered",ChainA.ImpactHits>=1,1);
            Check("chain middle receives two distinct contacts",ChainB.ImpactHits>=2,1);
            Check("chain reaches third body",ChainC.ImpactHits>=1,1);
            Check("stack top rests on middle",TopBody.bOnMobj,1);
            Check("stack middle rests on base",MidBody.bOnMobj,1);
            Check("stack landing delivered once",TopBody.ImpactHits,1);
            Console.Printf("CA311 TRACE simultaneous=%d/%d sources=%d/%d chain=%d/%d/%d stack=%d/%d/%d",
                Victim.FirstTic,Victim.SecondTic,Victim.FirstSource,Victim.SecondSource,
                ChainA.ImpactHits,ChainB.ImpactHits,ChainC.ImpactHits,TopBody.ImpactHits,MidBody.ImpactHits,BaseBody.ImpactHits);
            SavedA=Body((-1000,-1000,0),45311);SavedB=Body((-960,-1000,0),45312);SavedA.Vel=(10,0,0);
        }
        if(Age>=46 && SavedA!=null && SavedB!=null)
        {
            if(Age<=52)Console.Printf("CA311 TRACE checkpoint age=%d hits=%d/%d kind=%d source=%d edge=%d/%d created=%d removed=%d xyz=(%.3f,%.3f,%.3f)/(%.3f,%.3f,%.3f) height=%.3f/%.3f",
                Age,SavedA.ImpactHits,SavedB.ImpactHits,SavedA.LastImpactKind,SavedA.FirstSource,
                SavedA.GetImpactContactCount(),SavedB.GetImpactContactCount(),SavedA.ImpactDiagnosticContactsCreated,SavedA.ImpactDiagnosticContactsRemoved,
                SavedA.Pos.X,SavedA.Pos.Y,SavedA.Pos.Z,SavedB.Pos.X,SavedB.Pos.Y,SavedB.Pos.Z,SavedA.Height,SavedB.Height);
            if(SavedA.ImpactHits>0)
            {
                SavedA.Vel=SavedB.Vel=(0,0,0);SavedB.SetOrigin(SavedA.Pos+(32,0,0),false);
                SavedA.CollidedWith(SavedB,false);SavedB.CollidedWith(SavedA,true);
                let c=SavedA.GetImpactContactState(SavedB);
                if(Age<=52 && c!=null)Console.Printf("CA311 TRACE edge release=%.3f separated=%d updated=%d current=%d distance=%.3f radii=%.3f/%.3f",
                    c.ReleaseDistance,c.SeparatedTics,c.LastUpdatedTick,level.time,(c.FirstActor.Pos-c.SecondActor.Pos).Length(),SavedA.Radius,SavedB.Radius);
                if(Age<=52)Console.Printf("CA311 TRACE after callbacks health=%d/%d disable=%d/%d count=%d/%d last=%d",
                    SavedA.health,SavedB.health,SavedA.DisableCaelumImpactContacts,SavedB.DisableCaelumImpactContacts,
                    SavedA.ImpactDiagnosticCollisionCallbacks,SavedB.ImpactDiagnosticCollisionCallbacks,
                    SavedA.GetImpactContactState(SavedB)!=null?SavedA.GetImpactContactState(SavedB).LastCollisionTick:-1);
            }
        }
        if(Age==100)
        {
            Check("save checkpoint one original native impact",SavedA.ImpactHits,1);
            Check("save checkpoint live shared edge",SavedA.GetImpactContactState(SavedB)!=null && SavedA.GetImpactContactState(SavedB)==SavedB.GetImpactContactState(SavedA),1);
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
