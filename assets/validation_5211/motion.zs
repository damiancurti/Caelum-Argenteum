// This actor keeps the production Tick, collision callbacks and native movement.
class CA194Moving : CaelumCombatActor
{
    int ImpactHits;
    int CrushHits;
    double DamageEnergy;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        if(mod=='CaelumImpact'){ImpactHits++;DamageEnergy=LastImpactReceivedJoules;if(LastImpactKind==CaelumConstants.IMPACT_KIND_CRUSH)CrushHits++;}
        return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
    Default { Radius 16; Height 56; Mass 80; Health 10000000; +SHOOTABLE; +SOLID; +CANPASS; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA194Motion : CA194Combat
{
    CA194Moving Falling,FloorBody,Pusher,Pressed;
    CaelumCombatActor Support,CannonVictim;
    CaelumCannonProjectile Shot;
    CaelumHazardRock Rock;
    CaelumCombatActor RockVictim;
    CA194Moving GateFaller;
    CaelumBreakableGate Gate;
    int RockHealth;
    double MaximumPending;
    int ShotContacts;
    CA194Moving Moving(vector3 position)
    {
        let b=CA194Moving(Actor.Spawn("CA194Moving",position));
        b.CombatToughness=0;b.CombatMaximumHealth=b.health=10000000;
        b.CombatLucidityPhysicalStunRemaining=100;b.CollisionEffectiveMassMultiplier=b.CollisionDamageMultiplier=1;
        b.CombatArmor=new("CaelumArmorModel");b.CombatArmor.InitializeDefaults();
        b.AnatomyProfile=new("CaelumAnatomyProfile");b.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
        return b;
    }
    override void WorldTick()
    {
        Age++;
        if(Shot!=null)ShotContacts=Max(ShotContacts,Shot.ContactCount);
        if(Age==5)
        {
            Support=Fresh(70);Support.SetOrigin((0,0,0),false);
            Falling=Moving((0,0,200));Falling.Vel=(0,0,-8*32.0/35.0);
            FloorBody=Moving((256,0,200));FloorBody.Vel=Falling.Vel;
            CannonVictim=Fresh(200);CannonVictim.SetOrigin((512,512,0),false);CannonVictim.bFriendly=true;
            Shot=CaelumCannonProjectile(Actor.Spawn("CaelumCannonProjectile",(0,512,20)));
            Shot.Vel=(500*32.0/35.0,0,0);Shot.Gravity=0;
            Pusher=Moving((-512,0,0));Pressed=Moving((-480,0,0));
            Pusher.bNoGravity=Pressed.bNoGravity=true;
            RockVictim=Fresh(80);RockVictim.SetOrigin((-512,512,0),false);
            Rock=CaelumHazardRock(Actor.Spawn("CaelumHazardRock",(-512,512,220)));
            Rock.Release();Rock.Vel=(0,0,-8*32.0/35.0);RockHealth=Rock.health;
            Gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",(0,-512,0)));
            Gate.Angle=90;Gate.InitializeGate();Gate.StructuralMaximum=Gate.health=1000000000;
            GateFaller=Moving((0,-512,246));GateFaller.Vel=(0,0,-8*32.0/35.0);
        }
        if(Age>=6 && Age<48)
        {
            Pusher.SetOrigin((-512,0,0),false);Pressed.SetOrigin((-480,0,0),false);
            Pusher.Vel=(4*32.0/35.0,0,0);Pressed.Vel=(-4*32.0/35.0,0,0);
            let c=Pusher.GetImpactContactState(Pressed);
            if(c!=null)MaximumPending=Max(MaximumPending,c.PendingWorkJoules);
        }
        if(Age==70)
        {
            Check("native falling rests on actor",Falling.bOnMobj,1);
            Check("native falling raw bilateral",Falling.DamageEnergy,Support.LastImpactReceivedJoules,0.0001);
            Check("native falling one hit",Falling.ImpactHits,1);
            Check("native falling finite energy positive",Falling.DamageEnergy>0,1);
            Check("native floor anchored hit once",FloorBody.ImpactHits,1);
            Check("native floor raw positive",FloorBody.DamageEnergy>Falling.DamageEnergy,1);
            Check("native fastprojectile hit",CannonVictim.LastImpactReceivedJoules,526186.979931474,0.0001);
            Check("native fastprojectile one contact",ShotContacts,1);
            Check("native pressure accumulated",MaximumPending>0,1);
            Check("native pressure delivered pulse",Pusher.CrushHits>0 && Pressed.CrushHits>0,1);
            Check("native rock vertical single impact",Rock.VerticalImpactCount,1);
            Check("native rock target raw positive",RockVictim.LastImpactReceivedJoules>0,1);
            Check("native rock existing invulnerability retained",Rock.health,RockHealth);
            Check("native gate landing single body hit",GateFaller.ImpactHits,1);
            Check("native gate landing structural R once",1000000000-Gate.health,int(Max(0,GateFaller.DamageEnergy*0.9-935)+0.5));
            Console.Printf("CA194 TRACE motion falling=%.6f support=%.6f floor=%.6f pressure=%.6f hits=%d/%d",
                Falling.DamageEnergy,Support.LastImpactReceivedJoules,FloorBody.DamageEnergy,MaximumPending,Pusher.ImpactHits,Pressed.ImpactHits);
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
