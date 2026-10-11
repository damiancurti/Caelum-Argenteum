class CA194Siege : CA194Combat
{
    CaelumBreakableGate Gate(int material)
    {
        let gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",(1600,1024,0)));
        gate.args[1]=material;gate.Angle=90;gate.InitializeGate();
        gate.StructuralMaximum=gate.health=1000000000;
        return gate;
    }
    void Gates()
    {
        double reduction[]={935,2015,5720};
        let source=Fresh(200);
        for(int material=0;material<3;material++)
        {
            let gate=Gate(material);int before=gate.health;
            int actual=gate.ApplySiegeImpact(source,1,200,(8*32.0/35.0,0,0),(1,0,0));
            double expected=Max(0,6400*(0.9-0.1*material)-reduction[material]);
            Check("anchored gate 6400J one R",before-gate.health,int(expected+0.5));
            Check("gate same strike serial no repeat",gate.ApplySiegeImpact(source,1,200,(8*32.0/35.0,0,0),(1,0,0)),0);
            before=gate.health;
            gate.ApplySiegeImpact(source,2,4.3,(500*32.0/35.0,0,0),(1,0,0));
            Check("cannon anchored structural defenses",before-gate.health,int(537500*(0.9-0.1*material)-reduction[material]+0.5));
            Console.Printf("CA194 COMPARE gate=%d cannon energy=537500 raw=537500 final=%d",material,before-gate.health);
            gate.Destroy();
        }
        source.Destroy();
        for(int order=0;order<2;order++)
        {
            let gate=Gate(0);let body=Fresh(200);body.AnatomyProfile.InitializeHumanoid();
            body.SetOrigin(gate.Pos-(body.Radius+1.28,0,0),false);body.Vel=(8*32.0/35.0,0,0);
            int before=body.health;
            for(int i=0;i<gate.Blocks.Size();i++)
                gate.ResolveBodyImpact(body,gate.Blocks[order==0?i:gate.Blocks.Size()-1-i]);
            Check("gate body anchored raw",body.LastImpactReceivedJoules,6400);
            Check("gate proxies use whole face vulnerability",body.LastImpactWeightedVulnerabilityMultiplier,1.44);
            Check("gate proxies final independent order",before-body.health,8325);
            Check("gate logical once from all proxies",1000000000-gate.health,4825);
            body.Destroy();gate.Destroy();
        }
        let gate=Gate(0);let falling=Fresh(200);
        falling.SetOrigin(gate.Pos+(0,0,96),false);falling.bOnMobj=true;
        Check("gate supports landing",CaelumImpactEnergy.BodyLanding(falling,8*32.0/35.0),1);
        Check("gate landing anchored raw",falling.LastImpactReceivedJoules,6400);
        Check("gate landing structural defenses once",1000000000-gate.health,4825);
        CaelumImpactEnergy.BodyLanding(falling,8*32.0/35.0);
        Check("gate landing deduplicates support proxies",1000000000-gate.health,4825);
        falling.Destroy();gate.Destroy();
    }
    void Cannon()
    {
        for(int direction=0;direction<3;direction++)
        {
            let victim=Fresh(200);victim.bFriendly=true;
            vector3 origin=direction==2 ? victim.Pos+(0,0,100) : victim.Pos+(-32,0,20);
            let shot=CaelumCannonProjectile(Actor.Spawn("CaelumCannonProjectile",origin));
            shot.A_SetSize(1.2,2.4);
            shot.FlightVelocity=direction==2 ? (300*32.0/35.0,0,-500*32.0/35.0)
                : (500*32.0/35.0,direction==1 ? 300*32.0/35.0 : 0,0);
            // El contacto oblicuo atraviesa la misma cara; la componente tangencial queda fuera.
            if(direction==2)shot.SetOrigin(victim.Pos+(0,0,victim.Height),false);
            int before=victim.health;shot.ResolveContact(victim);
            Check("cannon frontal/oblique/descending raw",victim.LastImpactReceivedJoules,526186.979931474,0.0001);
            Check("cannon final innate then R",before-victim.health,486523);
            int after=victim.health;shot.ResolveContact(victim);
            Check("cannon spent dedup",victim.health,after);Check("cannon one contact",shot.ContactCount,1);
            shot.Destroy();victim.Destroy();
        }
        let victim=Fresh(200);victim.bFriendly=true;
        let shot=CaelumCannonProjectile(Actor.Spawn("CaelumCannonProjectile",victim.Pos+(-128,0,20)));
        shot.FlightVelocity=(500*32.0/35.0,0,0);shot.SweepMuzzle((256,0,0));
        Check("native muzzle sweep raw once",victim.LastImpactReceivedJoules,526186.979931474,0.0001);
        Check("native muzzle sweep spent once",shot.ContactCount,1);
        shot.Destroy();victim.Destroy();
        for(int armor=0;armor<2;armor++)
        {
            victim=Fresh(armor==0 ? 200 : 70);victim.bFriendly=true;victim.CombatToughness=20;
            victim.CombatArmor.InitializeUniformLoadout(armor==0 ? CaelumConstants.ARMOR_TYPE_HEAVY : CaelumConstants.ARMOR_TYPE_MAGIC,1);
            shot=CaelumCannonProjectile(Actor.Spawn("CaelumCannonProjectile",victim.Pos+(-32,0,20)));
            shot.FlightVelocity=(500*32.0/35.0,0,0);
            double mass=armor==0 ? 240 : 75;
            double energy=0.5*4.3*mass/(4.3+mass)*500*500;
            double factor=armor==0 ? 0.4*0.575 : 0.8*0.825;
            double reduction=(armor==0 ? 200 : 70)*1.504;
            int before=victim.health;shot.ResolveContact(victim);
            Check("armored cannon received energy",victim.LastImpactReceivedJoules,energy,0.0001);
            Check("armored cannon normal armor and R",before-victim.health,int(energy*factor-reduction+0.5));
            Console.Printf("CA194 COMPARE cannon receiver=%s energy=%.6f raw=%.6f final=%d",
                armor==0?"warrior-heavyT1-200kg":"mage-magicT1-70kg",energy,victim.LastImpactReceivedJoules,before-victim.health);
            shot.Destroy();victim.Destroy();
        }
    }
    void Rams()
    {
        for(int size=0;size<2;size++)for(int armor=0;armor<2;armor++)
        {
            let ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",(1024,1024,0)));
            ram.Large=size==1;ram.Angle=0;ram.InitializeRam();
            let victim=Fresh(armor==0 ? 200 : 70);
            victim.CombatToughness=20;
            victim.CombatArmor.InitializeUniformLoadout(armor==0 ? CaelumConstants.ARMOR_TYPE_HEAVY : CaelumConstants.ARMOR_TYPE_MAGIC,1);
            victim.SetOrigin(ram.Head.Pos+(victim.Radius+ram.Head.Radius,19*ram.SizeFactor,0),false);
            ram.Head.Vel=(CaelumRamData.STRIKE_SPEED,0,0);
            double movingMass=ram.AssemblyMass,targetMass=victim.GetCollisionEffectiveMass();
            double speed=CaelumRamData.STRIKE_SPEED*35.0/32.0;
            double expected=0.5*movingMass*targetMass/(movingMass+targetMass)*speed*speed;
            int ramHealth=ram.health,headHealth=ram.Head.health,before=victim.health;
            ram.Head.bShootable=true;ram.ApplyContact(victim);
            Check("ram reduced mass energy",victim.LastImpactReceivedJoules,expected,0.00001);
            Check("ram whole face area positive",victim.CurrentImpactArea.TotalArea>0,1);
            Check("ram reaction exception controller",ram.health,ramHealth);
            Check("ram reaction exception head",ram.Head.health,headHealth);
            Console.Printf("CA194 COMPARE ram=%s receiver=%s movingKg=%.6f targetKg=%.6f energy=%.6f raw=%.6f final=%d",
                size==0?"small":"large",armor==0?"warrior-heavyT1-200kg":"mage-magicT1-70kg",movingMass,targetMass,expected,victim.LastImpactReceivedJoules,before-victim.health);
            int after=victim.health;ram.ApplyContact(victim);Check("ram strike dedup",victim.health,after);
            victim.Destroy();ram.Destroy();
        }
        let ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",(0,0,0)));
        ram.Angle=0;ram.InitializeRam();
        let victim=Fresh(80);victim.SetOrigin(ram.Head.Pos+(victim.Radius+ram.Head.Radius+10,0,0),false);
        ram.Head.Vel=(CaelumRamData.STRIKE_SPEED,0,0);
        Check("native ram sweep obstructed",ram.MoveHead(20,true),0);
        Check("native ram sweep once",ram.ImpactCount,1);
        Check("native ram sweep delivers energy",victim.LastImpactReceivedJoules>0,1);
        int after=victim.health;ram.MoveHead(20,true);Check("native ram sweep no repeat HP",victim.health,after);
        victim.Destroy();ram.Destroy();
    }
    override void WorldTick()
    {
        Age++;if(Age==3)
        {
            Gates();Cannon();Rams();
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
