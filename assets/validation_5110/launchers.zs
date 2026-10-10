class CA154LauncherTarget : CaelumCombatActor
{
    override void PostBeginPlay(){Super.PostBeginPlay();InitializeCombatProfile(0,0,100,0,0,0,0,0,0,0,0,0);}
    Default {Radius 16;Height 56;Mass 80;Health 800; +SOLID +SHOOTABLE +NOGRAVITY}
    States {Spawn: TNT1 A -1;Stop;}
}
class CA154Launchers : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    CaelumCannon Guns[3];
    CA154LauncherTarget Victims[3];
    CaelumPortDefender Soldier;
    CA154LauncherTarget RifleTarget;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA154 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        Elapsed++;
        if(Elapsed==20)
        {
            for(int i=0;i<3;i++)
            {
                double y=1000+i*2000;
                Guns[i]=CaelumCannon(Actor.Spawn("CaelumCannon",(0,y,0)));Guns[i].InitializeCannon(false);
                let operator=CaelumCombatActor(Actor.Spawn("CA154LauncherTarget",(-50,y,0)));operator.bFriendly=false;
                // Isolate ballistics from siege recruitment; keep actual crew/range preconditions.
                Guns[i].Operators.Push(operator);Guns[i].Armed=true;Guns[i].Ammunition=1;Guns[i].Phase=CaelumCannon.LOADED;
                Victims[i]=CA154LauncherTarget(Actor.Spawn("CA154LauncherTarget",(3200*(i+1),y,i*64)));Victims[i].bFriendly=true;
            }
            Soldier=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(0,-6000,0)));
            RifleTarget=CA154LauncherTarget(Actor.Spawn("CA154LauncherTarget",(800,-6000,0)));
        }
        if(Elapsed==23)
        {
            for(int i=0;i<3;i++)
            {
                let gun=Guns[i];gun.RequestShot(Victims[i].Pos+(0,0,Victims[i].Height/2),Victims[i]);gun.Fire();
                Check(String.Format("cannon controller launch %d",i),gun.Shots==1 && gun.Ammunition==0 && Abs(gun.LastLaunchVelocity.Length()-CaelumCannonData.SPEED)<0.000001);
            }
            Soldier.Carbine=new("CaelumCityCarbine");Soldier.Carbine.Initialize(Soldier);
            Soldier.Carbine.Select(true);double air=Soldier.CurrentCombatAir;
            bool attacked=Soldier.Carbine.Attack(Soldier,RifleTarget);
            Check("soldier launch retains crouch aim magazine and air",attacked && Soldier.Carbine.ShotCount==1 && Soldier.Carbine.Magazine==9 && Soldier.Carbine.Crouched && Soldier.Carbine.Aiming && Soldier.CurrentCombatAir<air);
            let it=ThinkerIterator.Create("CaelumCarbineProjectile");CaelumCarbineProjectile shot;
            bool found=false;while((shot=CaelumCarbineProjectile(it.Next()))!=null)
                if(shot.Target==Soldier){found=true;Check(String.Format("soldier physical shot has gravity and muzzle speed speed=%.12f noGravity=%d",shot.Vel.Length(),shot.bNoGravity),!shot.bNoGravity && Abs(shot.Vel.Length()-80)<0.000001);}
            Check("soldier projectile exists",found);
        }
        if(Elapsed==65)
        {
            for(int i=0;i<3;i++)Check(String.Format("cannon controller actual contact %d damage=%d",i,Guns[i].LastDamage),Guns[i].Contacts==1 && Guns[i].LastContact==Victims[i] && Guns[i].LastDamage>0);
            Console.Printf("CA154 LAUNCHERS COMPLETE pass=%d fail=%d",Passed,Failed);
        }
    }
}
