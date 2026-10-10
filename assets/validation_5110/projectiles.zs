class CA154Target : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    { Hits++; return Super.DamageMobj(inflictor,source,damage,mod,flags,angle); }
    Default { Radius 8; Height 16; Health 100000; +SHOOTABLE +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA154Projectiles : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    Array<Actor> Shots;
    Array<CA154Target> Targets;
    vector3 Velocities[54],Origins[54];
    int Contacts[54];
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA154 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        Elapsed++;
        if(Elapsed==20)
        {
            Name types[]={"CaelumArrowProjectile","CaelumBoltProjectile","CaelumCarbineProjectile","CaelumShotgunPellet","CaelumJavelinProjectile","CaelumCannonProjectile"};
            double speeds[]={60,60,80,80,15,CaelumCannonData.SPEED};
            for(int kind=0;kind<6;kind++)for(int range=0;range<3;range++)for(int elevation=0;elevation<3;elevation++)
            {
                int index=Shots.Size();double speed=speeds[kind];
                vector3 origin=(0,1000+index*400,1500);
                vector3 delta=(speed*(6+range*6),0,(elevation-1)*64);
                let target=CA154Target(Actor.Spawn("CA154Target",origin+delta-(0,0,8)));
                let shot=Actor.Spawn(types[kind],origin);shot.Vel=(speed,0,0);
                bool solved=CaelumBallistics.AimProjectile(shot,target.Pos+(0,0,8),0,0,kind==5);
                Check(String.Format("trajectory setup type=%s range=%d elevation=%d speed=%.9f",types[kind],range,elevation,CaelumPhysicsUnits.VelocitySI(shot.Vel.Length())),solved && Abs(shot.Vel.Length()-speed)<0.000001 && !shot.bNoGravity);
                Shots.Push(shot);Targets.Push(target);Velocities[index]=shot.Vel;Origins[index]=origin;
            }
            Check("unreachable shot returns no solution",CaelumBallistics.Velocity((100000,0,0),15,CaelumPhysicsUnits.EARTH_GRAVITY_ENGINE).Length()==0);
            let magic=Actor.Spawn("CaelumPlayerMagicProjectile",(-1000,-1000,1000));
            Check("elemental no-gravity policy preserved",magic.bNoGravity);magic.Destroy();
            let angled=Actor.Spawn("CaelumCarbineProjectile",(-1000,-1000,1000));angled.Vel=(80,0,0);
            vector3 point=angled.Pos+(800,0,0);
            CaelumBallistics.AimProjectile(angled,point,3,2);
            vector3 solution=CaelumBallistics.Velocity((800,0,0),80,angled.GetGravity());
            double ballisticPitch=-VectorAngle(solution.XY.Length(),solution.Z);
            Check("dispersion reapplied after ballistic aim",Abs(angled.Angle-3)<0.000001 && Abs(angled.Pitch-ballisticPitch-2)<0.000001);
            angled.Destroy();
        }
        if(Elapsed==21)
            for(int i=0;i<Shots.Size();i++)
            {
                let shot=Shots[i];double g=shot.GetGravity();bool fast=shot is "CaelumCannonProjectile";
                vector3 predicted=Origins[i]+Velocities[i]-(0,0,fast ? g : 0);
                Check(String.Format("single gravity integration shot=%d displacementError=%.9f velocityError=%.9f",i,(shot.Pos-predicted).Length(),Abs(shot.Vel.Z-(Velocities[i].Z-g))),
                    (shot.Pos-predicted).Length()<0.001 && Abs(shot.Vel.Z-(Velocities[i].Z-g))<0.000001);
            }
        for(int i=0;i<Shots.Size();i++)
        {let cannon=CaelumCannonProjectile(Shots[i]);if(cannon!=null && cannon.Contact==Targets[i] && cannon.ContactCount==1)Contacts[i]=1;}
        if(Elapsed==65)
        {
            for(int i=0;i<Targets.Size();i++)
            {
                let cannon=CaelumCannonProjectile(Shots[i]);
                bool hit=Targets[i].Hits==1 || Contacts[i]==1;
                Check(String.Format("native collision shot=%d hits=%d",i,Targets[i].Hits),hit);
            }
            Console.Printf("CA154 PROJECTILES COMPLETE pass=%d fail=%d",Passed,Failed);
        }
    }
}
