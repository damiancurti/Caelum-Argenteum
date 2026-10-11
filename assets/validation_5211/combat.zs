class CA194Combat : CA194Energy
{
    CaelumCombatActor Fresh(double mass=80)
    {
        let body=CaelumCombatActor(Actor.Spawn("CA194Target",(1024,1024,32)));
        body.Mass=mass;body.CombatToughness=0;body.CombatMaximumHealth=1000000;body.health=1000000;
        body.CollisionEffectiveMassMultiplier=1;body.CollisionDamageMultiplier=1;
        body.CombatArmor=new("CaelumArmorModel");body.CombatArmor.InitializeDefaults();
        body.CombatLucidityPhysicalStunRemaining=100;
        body.AnatomyProfile=new("CaelumAnatomyProfile");
        body.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
        body.Angle=0;
        return body;
    }
    void Receptors()
    {
        let source=Fresh();source.SetOrigin((1056,1024,32),false);
        for(int h=100;h<=10000;h*=10)for(int energy=100;energy<=10000;energy*=10)
        {
            let body=Fresh(1);body.CombatMaximumHealth=h;
            body.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,source,1,1,80,10,10,0,1,false,energy);
            Check("raw independent Hmax",body.LastImpactReceivedJoules,energy);
            Check("final independent Hmax/one R",body.LastImpactFinalDamage,int(energy*0.925-1+0.5));
            body.Destroy();
        }
        let body=Fresh();body.AnatomyProfile.InitializeHumanoid();
        body.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,source,1,80,80,10,10,0,1,false,1000);
        Check("native humanoid vulnerability",body.LastImpactWeightedVulnerabilityMultiplier,1.44);
        Check("native humanoid final",body.LastImpactFinalDamage,1252);
        body.Destroy();body=Fresh();body.AnatomyProfile.ClearRegions();
        body.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_LEGS,3,0,0.75,0,1);
        body.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_HEAD,0,0.75,1,0,1);
        body.CombatArmor.ArmorType[3]=CaelumConstants.ARMOR_TYPE_HEAVY;
        body.CombatArmor.Durability[3]=10000;
        body.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,source,1,80,80,10,10,0,1,false,1000);
        Check("correlated area armor/vulnerability",body.LastImpactFinalDamage,555);
        body.Destroy();body=Fresh();body.AnatomyProfile.ClearRegions();
        for(int i=0;i<4;i++)body.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_LEGS,3,i*0.25,(i+1)*0.25,0,1);
        body.CombatArmor.ArmorType[3]=CaelumConstants.ARMOR_TYPE_HEAVY;body.CombatArmor.Durability[3]=1;
        body.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,source,1,80,80,10,10,0,1,false,100000);
        Check("four regions same armor snapshot",body.LastImpactFinalDamage,22920);
        Check("wear deferred to end",body.CombatArmor.Durability[3],0);
        body.Destroy();body=Fresh();
        body.ReceiveCaelumImpact(10,CaelumConstants.IMPACT_KIND_ACTOR,source,1,80,80,10,10,0.6,0.6,false,1000);
        Check("neutral fallback retains innate defense",body.LastImpactFinalDamage,845);
        Check("neutral fallback no critical lucidity",body.LastImpactHeadContactWeight,0);
        body.Destroy();source.Destroy();
    }
    void Pairs()
    {
        for(int order=0;order<2;order++)
        {
            let a=Fresh(200),b=Fresh(70);b.SetOrigin(a.Pos+(32,0,0),false);
            a.Vel=(8*32.0/35.0,0,0);b.Vel=(0,0,0);
            if(order==0)a.CollidedWith(b,false);else b.CollidedWith(a,true);
            Check("pair first same raw",a.LastImpactReceivedJoules,1659.259259259);
            Check("pair second same raw",b.LastImpactReceivedJoules,1659.259259259);
            int firstHealth=a.health,secondHealth=b.health;
            b.CollidedWith(a,false);a.CollidedWith(b,true);
            Check("passive callback no repeat first",a.health,firstHealth);
            Check("passive callback no repeat second",b.health,secondHealth);
            a.Vel=b.Vel=(0,0,0);a.CollidedWith(b,false);
            Check("rest no energy",a.GetImpactContactState(b).PendingWorkJoules,0);
            a.Destroy();b.Destroy();
        }
        let a=Fresh(200),b=Fresh(70);b.SetOrigin(a.Pos+(32,0,0),false);
        let contact=a.LatchImpactContact(b);
        CaelumImpactEnergy.CaptureWork(contact);contact.PendingWorkJoules=1000;
        int beforeA=a.health,beforeB=b.health;
        b.SetOrigin(b.Pos+(256,0,0),false);
        CaelumImpactEnergy.ConsumeWork(contact);
        Check("pending work first",a.LastImpactReceivedJoules,1000);
        Check("pending work second",b.LastImpactReceivedJoules,1000);
        Check("separation keeps first patch",beforeA-a.health,725);
        Check("separation keeps second patch",beforeB-b.health,855);
        CaelumImpactEnergy.ConsumeWork(contact);
        Check("consume work once",beforeA-a.health,725);
        a.Destroy();b.Destroy();
        a=Fresh(200);b=Fresh(70);b.SetOrigin(a.Pos+(32,0,0),false);a.health=1;
        a.Vel=(8*32.0/35.0,0,0);a.CollidedWith(b,false);
        Check("first death keeps other raw snapshot",b.LastImpactReceivedJoules,1659.259259259);
        a.Destroy();b.Destroy();
    }
    void WorkSamples()
    {
        let a=Fresh(),b=Fresh();b.A_SetSize(16,28);b.SetOrigin(a.Pos+(32,0,0),false);
        a.AnatomyProfile.ClearRegions();
        a.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,0.5,0,1);
        a.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_HEAD,0,0.5,1,0,1);
        let c=a.LatchImpactContact(b);
        CaelumImpactEnergy.AddWork(c,100,800);c.PendingWorkJoules+=100;
        b.SetOrigin(b.Pos+(0,0,28),false);
        CaelumImpactEnergy.AddWork(c,100,800);c.PendingWorkJoules+=100;
        CaelumImpactEnergy.ConsumeWork(c);
        Check("pressure keeps both contacted regions",a.LastImpactWeightedVulnerabilityMultiplier,1.5);
        Check("pressure applies R once after mixed samples",a.LastImpactFinalDamage,198);
        a.Destroy();b.Destroy();
        a=Fresh(200);
        let wall=Actor.Spawn("CA194Scenery",a.Pos+(32,0,0));
        a.Vel=(8*32.0/35.0,0,0);a.CollidedWith(wall,false);
        Check("healthless scenery still hurts moving body",a.LastImpactReceivedJoules,6400);
        Check("healthless scenery keeps no health",wall.health,0);
        int after=a.health;a.CollidedWith(wall,true);
        Check("healthless scenery contact resolves once",a.health,after);
        a.Destroy();wall.Destroy();
        a=Fresh();a.CombatLucidityPhysicalStunRemaining=0;
        let rock=Actor.Spawn("CaelumHazardRock",a.Pos+(64,0,0));
        Check("hazard rock pressure cannot gain landing cushion",CaelumImpactEnergy.CushionWork(a,rock,1000,800,80),1000);
        a.Destroy();rock.Destroy();
    }
    override void WorldTick()
    {
        Age++;
        if(Age==3)
        {
            Receptors();Pairs();WorkSamples();
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
