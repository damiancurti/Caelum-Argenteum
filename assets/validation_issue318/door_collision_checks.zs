// Compare the original actor leaf and the native replacement in the same room.
class CA318CollisionBody : Actor
{
    Default { Radius 16; Height 56; +SOLID +SHOOTABLE +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA318CollisionShot : Actor
{
    Default { Radius 2; Height 4; Speed 32; Damage 0; +MISSILE +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; Death: TNT1 A 1; Stop; }
}
class CA318CollisionChecks : EventHandler
{
    int Start,Checks,Failures;
    bool Started;
    Actor Shots[4];
    override bool InputProcess(InputEvent e){return true;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA318 %s %s",ok?"PASS":"FAIL",label);}
    void Rays()
    {
        for(int reference=0;reference<2;reference++)
        {
            double center=reference*256.0;
            let from=Actor.Spawn("CA318CollisionBody",(-16,center-64,0));
            let target=Actor.Spawn("CA318CollisionBody",(-16,center+64,0));
            Check(from.CheckSight(target),"Both door types retain existing native sight behavior");
            FLineTraceData hit;bool found=from.LineTrace(90,128,0,TRF_ABSPOSITION|TRF_THRUACTORS,32,-16,center-64,hit);
            Check(!found,"Both door types retain actor-ignoring thermal ray behavior");
            found=from.LineTrace(90,128,0,TRF_ABSPOSITION,32,-16,center-64,hit);
            Check(found && hit.HitActor==target,"Both door types retain existing hitscan behavior");
            Console.Printf("CA318 COLLISION_RAY reference=%d found=%d hit_target=%d",reference,found,hit.HitActor==target);
            from.Destroy();target.Destroy();
        }
    }
    void Shoot()
    {
        for(int reference=0;reference<2;reference++)for(int high=0;high<2;high++)
        {
            let shot=Actor.Spawn("CA318CollisionShot",(-16,reference*256-64,high==0?32:184));
            shot.Vel=(0,32,0);Shots[reference*2+high]=shot;
        }
    }
    void Results(bool open)
    {
        for(int reference=0;reference<2;reference++)
        {
            let low=Shots[reference*2];let high=Shots[reference*2+1];
            Check(open?(low!=null && low.bMissile && low.Pos.Y>reference*256+64):(low==null || !low.bMissile),
                open?"Both open door types pass low projectile":"Both closed door types stop low projectile");
            Check(high!=null && high.bMissile && high.Pos.Y>reference*256+64,"Both door types pass above-roof projectile");
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="collision_begin")
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            user.ApplyCharacterProfile();user.bInvulnerable=true;user.SetOrigin((-300,-300,0),false);
            Rays();Shoot();Started=true;Start=level.time;
        }
        if(e.Name=="collision_done")Console.Printf("CA318 DONE failures=%d checks=%d",Failures,Checks);
    }
    override void WorldTick()
    {
        if(!Started)return;int age=level.time-Start;
        if(age==6)Results(false);
        if(age==10)
        {
            let user=players[0].mo;let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
            while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            {
                if(leaf.args[1]>=0 || (leaf.args[4]!=1 && leaf.args[0]!=500))continue;
                user.SetOrigin(leaf.ClosedPosition+(0,-100,0),false);
                Check(leaf.RequestDoorGroup(user),"Reference pair opens for projectile comparison");
            }
            user.SetOrigin((-300,-300,0),false);
        }
        if(age==35)Shoot();
        if(age==41)Results(true);
    }
}
