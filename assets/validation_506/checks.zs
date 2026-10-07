// Pruebas aisladas #128: los cuerpos conservan Tick/RPG/colisión normales.
class CA128Body : CaelumMandinga
{
    States { Spawn: TNT1 A -1; Stop; }
}
class CA128Unlinked : CA128Body
{
    Default { +NOBLOCKMAP }
}
class CA128Defender : CaelumPortDefender
{
    States { Spawn: TNT1 A -1; Stop; }
}
class CA128Port : CaelumPortSiege
{
    override void Tick() { }
}
class CA128Lifecycle : StaticEventHandler
{
    int ObservedTics;
    override void WorldLoaded(WorldEvent e)
    {
        ObservedTics=0;
        Console.Printf("CA128 LIFECYCLE map=%s save=%d reopen=%d",level.MapName,e.IsSaveGame,e.IsReopen);
    }
    override void WorldTick()
    {
        ObservedTics++;
        if(ObservedTics!=2)return;
        let population=CaelumPopulationState.Get();
        let checks=CA128Checks(EventHandler.Find("CA128Checks"));
        Console.Printf("CA128 LOADED_STATE map=%s tic=%d alive=%d active=%d bodies=%d",level.MapName,level.time,population.LivingCombatants,population.HighDensity,checks==null ? -1 : checks.Bodies.Size());
        if(checks!=null && level.MapName=="QA128B")checks.Check(population.LivingCombatants==1 && !population.HighDensity,"travel clears previous map population");
        if(checks!=null && level.MapName=="QA128A" && checks.Bodies.Size()==500)checks.Check(population.LivingCombatants==500 && population.HighDensity,"save or hub return restores population from actors");
    }
}
class CA128Checks : EventHandler
{
    int Checks, Failures;
    Array<CaelumCombatActor> Bodies;
    CaelumPortSiege Port;
    CaelumHostileMachine Machine;
    CaelumSiegeCombatant Leader, Follower;
    CaelumPortDefender NearLeader, NearFollower, Hidden;

    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="QA128A" && level.MapName!="QA128B")return;
        Console.Printf("CA128 LOAD map=%s save=%d reopen=%d tic=%d",level.MapName,e.IsSaveGame,e.IsReopen,level.time);
        if(e.IsSaveGame || e.IsReopen)
        {
            let population=CaelumPopulationState.Get();
            Check(population!=null && population.Revision==1,"saved population object rebuilt on load/reopen");
            Console.Printf("CA128 LOAD_POPULATION alive=%d active=%d bodies=%d",population.LivingCombatants,population.HighDensity,Bodies.Size());
        }
    }

    void Check(bool ok,String label)
    {
        Checks++;
        Console.Printf("CA128 %s tic=%d %s",ok ? "PASS" : "FAIL",level.time,label);
        if(!ok)Failures++;
    }
    CaelumCombatActor AddBody(int i)
    {
        let body=CaelumCombatActor(Actor.Spawn("CA128Body",(4096+(i%25)*128,4096+(i/25)*128,0),NO_REPLACE));
        Bodies.Push(body);return body;
    }
    void SetupTargets()
    {
        Port=CaelumPortSiege(Actor.Spawn("CA128Port",(0,0,0),NO_REPLACE));
        Port.SetupRevision=1;Port.RosterSealed=false;
        Bodies[0].SetOrigin((0,0,0),false);Bodies[1].SetOrigin((800,0,0),false);
        Leader=Port.RegisterAttacker(Bodies[0]);Follower=Port.RegisterAttacker(Bodies[1]);
        Leader.CommandGroup=0;Follower.CommandGroup=0;Leader.CommandLeader=Leader;Follower.CommandLeader=Leader;
        NearLeader=CaelumPortDefender(Actor.Spawn("CA128Defender",(100,0,0),NO_REPLACE));
        NearFollower=CaelumPortDefender(Actor.Spawn("CA128Defender",(700,0,0),NO_REPLACE));
        Hidden=CaelumPortDefender(Actor.Spawn("CA128Defender",(100,18000,0),NO_REPLACE));
        Port.Defenders.Push(NearLeader);Port.Defenders.Push(NearFollower);Port.Defenders.Push(Hidden);
        Port.EnsureTargetingRevision();
        Check(Port.TargetingRevision==2,"idempotent derived perception revision");
        Port.HighDensity=false;
        Check(Port.AttackerTarget(Follower)==NearFollower,"under threshold keeps individual nearest visible target");
        Port.HighDensity=true;
        Check(Port.AttackerTarget(Follower)==NearLeader,"high density adopts leader instead of nearer member target");
        Follower.Body.target=NearLeader;
        Check(!Follower.Body.WithinAttackRange(false),"shared target does not grant out-of-range melee");
        Follower.Body.target=Hidden;
        Check(!Follower.Body.WithinAttackRange(true),"shared target does not bypass individual magic visibility/range");
        Check(!Follower.Body.CaelumMassAIScheduleActive && Follower.Body.AnatomyProfile!=null
            && Follower.Body.CombatArmor!=null && Follower.Body.ElementalStatus!=null,"ordinary body retains full RPG objects and native AI path");
        Check(!Leader.Body.CheckSight(Hidden),"fixture has a physically occluded opponent");
        Port.EnsureTargetingRevision();
        Check(Leader.SharedTargetValid && Port.Attackers.Size()==2,"repeat migration preserves roster and current derived cache");
        int due=Leader.NextSharedTargetTic;
        Check(due>level.time && due<=level.time+CaelumPortData.TARGET_UPDATE_TICS,"stagger deadline within one authored period");
        NearLeader.health=0;
        Check(Port.AttackerTarget(Follower)==null,"dead shared target rejected immediately");
        Leader.NextSharedTargetTic=0;
        Check(Port.AttackerTarget(Follower)==NearFollower,"next perception turn acquires remaining visible opponent");
        Bodies[0].health=0;
        Check(Port.AttackerTarget(Follower)==NearFollower,"dead leader falls back to live member");
        Bodies[0].health=Bodies[0].SpawnHealth();
        Port.ResetPerception();
        Leader.CommandGroup=1000;
        Port.UpdateSharedTarget(Leader);
        Check(Leader.NextSharedTargetTic>level.time && Leader.NextSharedTargetTic<=level.time+8,"large group ID cannot extend period");
        Leader.CommandGroup=0;
        Follower.CommandGroup=1;Follower.CommandLeader=Follower;
        Port.UpdateSharedTarget(Follower);
        Check(Leader.NextSharedTargetTic==level.time+8 && Follower.NextSharedTargetTic==level.time+8,"demand cache uses authored interval without background queries");

        Machine=CaelumHostileMachine(Actor.Spawn("CaelumHostileMachine",(0,0,0),NO_REPLACE));
        Machine.Encounter=Port;Machine.GuardRadius=256;Machine.Armed=true;
        let unlinked=CaelumCombatActor(Actor.Spawn("CA128Unlinked",(0,128,0),NO_REPLACE));
        let extra=Port.RegisterAttacker(unlinked);
        Machine.ObserveGuards();
        Check((extra.NearbyMachines&1)!=0,"NOBLOCKMAP registration after census is observed in the same tic");
        let elevated=Port.RegisterAttacker(Bodies[3]);
        Bodies[3].SetOrigin((0,0,384),false);
        CaelumPopulationState.Get().Refresh();
        Machine.ObserveGuards();
        Check((Leader.NearbyMachines&1)!=0 && (extra.NearbyMachines&1)!=0,"spatial broad phase includes NOBLOCKMAP fallback");
        Check((Follower.NearbyMachines&1)==0,"3D guard radius excludes far member");
        Check((elevated.NearbyMachines&1)==0,"XY candidate outside vertical guard radius rejected");
        Bodies[3].SetOrigin((4480,4096,0),false);
        let gun=CaelumCannon(Actor.Spawn("CaelumCannon",(1000,0,0),NO_REPLACE));
        gun.Defending=true;gun.Armed=true;gun.Phase=CaelumCannon.LOADED;
        Port.Guns.Push(gun);Port.OrderGuns();
        Check(!gun.Requested && gun.NextTargetQuery==level.time+8,"negative cannon query waits one authored interval");
        gun.Barrel=CaelumCannonBarrel(Actor.Spawn("CaelumCannonBarrel",gun.Pos,NO_REPLACE));
        Leader.CrewMachine=Machine;
        Port.OrderGuns();
        Check(!gun.Requested,"negative cache defers newly available cannon target before deadline");
        Port.HighDensity=false;Port.OrderGuns();
        Check(gun.Requested && gun.IntendedTarget==Leader.Body && gun.NextTargetQuery==0,"ordinary mode ignores retry cache and preserves crew priority");
        Port.HighDensity=true;gun.CancelShot();gun.NextTargetQuery=0;Port.OrderGuns();
        Check(gun.Requested && gun.IntendedTarget==Leader.Body,"expired retry acquires a valid crew target");
        let intended=gun.IntendedTarget;Port.OrderGuns();
        Check(gun.Requested && gun.IntendedTarget==intended,"pending positive cannon order retained");
        Follower.CrewMachine=Machine;
        Check(Port.CannonTarget(gun)==Follower.Body,"equally prioritized cannon crews retain nearest selection");
        Bodies[0].SetOrigin((1000,200,0),false);Bodies[1].SetOrigin((1000,-200,0),false);
        Check(Port.CannonTarget(gun)==Leader.Body,"equal-distance cannon tie retains original roster order");
        Bodies[0].SetOrigin((0,0,0),false);Bodies[1].SetOrigin((800,0,0),false);
        Follower.CrewMachine=null;
        gun.Destroy();Leader.CrewMachine=null;
        Bodies[0].SetOrigin((2048,0,0),false);unlinked.SetOrigin((2048,128,0),false);
        Machine.ObserveGuards();
        Check(Machine.LocalGuards.Size()==2 && !Machine.Neutralized,"living remembered guards retained after leaving radius");
        Leader.ConfirmedDead=true;extra.ConfirmedDead=true;
        Machine.ObserveGuards();Machine.ObserveGuards();
        Check(Machine.Neutralized && Machine.NeutralizationCount==1,"all confirmed guards neutralize machine exactly once");
        unlinked.Destroy();Machine.Destroy();
        NearLeader.Destroy();NearFollower.Destroy();Hidden.Destroy();
        Bodies[2].health=0;CaelumPopulationState.Get().Refresh();Port.RefreshDensity();
        Check(!Port.HighDensity && !Leader.SharedTargetValid && Port.Attackers.Size()==4,"real downward threshold clears only perception caches");
        Bodies[2].health=Bodies[2].SpawnHealth();CaelumPopulationState.Get().Refresh();Port.RefreshDensity();
        Check(Port.HighDensity && Port.CommandDirty,"real upward threshold rebuilds commands");
        Port.Destroy();
    }
    override void WorldTick()
    {
        if(level.MapName=="QA128B" && level.time==2)
        {
            let population=CaelumPopulationState.Get();
            Check(population.LivingCombatants==1 && !population.HighDensity,"travel clears previous map population");
        }
        if(level.MapName!="QA128A")return;
        let population=CaelumPopulationState.Get();
        if(level.time==2)
        {
            Check(population!=null && population.LivingCombatants==1,"fresh map counts one living player");
            players[0].mo.SetOrigin((-4096,0,0),false);
            for(int i=0;i<498;i++)AddBody(i);
        }
        if(level.time==3)
        {
            Check(population.LivingCombatants==499 && !population.HighDensity,"499 remains ordinary");
            AddBody(498);
        }
        if(level.time==4)
        {
            Check(population.LivingCombatants==500 && population.HighDensity,"500 activates including offscreen combatants");
            AddBody(499);
        }
        if(level.time==5)
        {
            Check(population.LivingCombatants==501 && population.HighDensity,"501 remains active");
            Bodies[499].DamageMobj(null,null,10000000,'None',DMG_FORCED);
        }
        if(level.time==6)
        {
            Check(population.LivingCombatants==500 && population.HighDensity,"native death excludes corpse");
            Bodies[498].Destroy();
        }
        if(level.time==7)
        {
            Check(population.LivingCombatants==499 && !population.HighDensity,"removal crosses down on next tic");
            Bodies[499].Revive();
        }
        if(level.time==8)
        {
            Check(population.LivingCombatants==500 && population.HighDensity,"native revival reactivates without spawn registration");
            Bodies[499].bShootable=false;
        }
        if(level.time==9)
        {
            Check(population.LivingCombatants==499 && !population.HighDensity,"noncombatant flag excluded");
            Bodies[499].bShootable=true;
        }
        if(level.time==10)SetupTargets();
        if(level.time==11)
        {
            Check(population.Revision==1 && population.LivingCombatants==500,"derived population recomputes after fixture cleanup");
            Console.Printf("CA128 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
