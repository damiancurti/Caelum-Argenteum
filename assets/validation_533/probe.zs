// Comprobaciones aisladas, separadas de la aceptación y de la entrada nativa.
class CA258Probe : StaticEventHandler
{
    int Failures,Stage,Ticks,StartTic;
    vector3 StartPos;
    double StartSleep;
    int StartHealth;
    CaelumRestFurniture Support;
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name!="c258_ui")return;
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        let r=CaelumRestState(u.FindInventory("CaelumRestState"));
        Console.Printf("CA258 UI sleep=%.9f active=%d locked=%d pose=%d elapsed=%d tic=%d menu=%d",u.CurrentSleep,CaelumExhaustion.Active(u),CaelumExhaustion.Locked(u),u.InStateSequence(u.CurState,u.FindState("RestLying")),r==null?0:r.ElapsedTics,level.maptime,menuactive);
    }
    void Check(bool ok,String label)
    {Console.Printf("CA258 %s %s",ok?"PASS":"FAIL",label);if(!ok)Failures++;}
    void Reset(CaelumPlayer u)
    {
        let rest=CaelumRestState.Get(u,true);rest.Exhaustion=false;
        rest.Finish(u,CaelumRestRules.STATUS_CANCELLED,"");rest.ReleaseView(u);rest.ViewInitialized=false;
        if(Support!=null){Support.Destroy();Support=null;}
        Inventory item=u.Inv;
        while(item!=null)
        {let next=item.Inv;if(CaelumTimeSkipRules.Kind(CaelumConsumableItem(item))!=0 || item is "CaelumRegenerationPower")item.Destroy();item=next;}
        u.CurrentHunger=u.CurrentThirst=u.CurrentSleep=80;
        u.CurrentAnima=u.DerivedStats.MaximumAnima;u.CurrentAir=u.DerivedStats.MaximumAir;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.ForcedSleepTics=0;u.CombatTimeRemaining=0;u.PainImmobilizationRemaining=0;
        u.LucidityPhysicalStunRemaining=0;u.CurrentLucidity=CaelumConstants.MAXIMUM_LUCIDITY;
        u.SurvivalDamageAccumulator=0;u.Vel=(0,0,0);u.SetOrigin((0,0,0),false);
        CaelumDiningSession.Invalidate(u);
    }
    void Collapse(CaelumPlayer u)
    {u.CurrentSleep=0;CaelumExhaustion.Sync(u);}
    void Core(CaelumPlayer u)
    {
        Reset(u);vector3 origin=u.Pos;Collapse(u);
        let rest=CaelumRestState.Get(u);
        Check(CaelumExhaustion.Locked(u) && rest.ExhaustionRevision==1 && rest.Untimed,"zero-enters-revisioned-involuntary-sleep");
        Check(u.Pos==origin && u.CurrentSleep==0 && rest.Furniture==null && CaelumRestState.ResourceFactor(u)==1,"no-relocation-refill-or-fabricated-bed");
        Check(u.InStateSequence(u.CurState,u.FindState("RestLying")),"immediate-lying-pose");
        for(int i=0;i<4;i++)
        {
            u.CurrentSleep=i==0?0:i==1?5:i==2?10:10.001;
            if(i<3)
            {
                CaelumRestState.Cancel(u);CaelumRestState.Interrupt(u,"CA_REST_DAMAGE");
                rest.Finish(u,CaelumRestRules.STATUS_COMPLETE,"");
                Check(CaelumExhaustion.Locked(u),String.Format("cancel-interrupt-complete-locked-%.3f",u.CurrentSleep));
                Check(!CaelumTimeSkipState.OpenMenu(u),String.Format("skip-cannot-escape-%.3f",u.CurrentSleep));
                u.ToggleEquipmentMenu();Check(!u.EquipmentMenuOpen,"equipment-cannot-escape-lock");
                rest.InputArmed=true;u.player.cmd.forwardmove=100;u.player.cmd.sidemove=100;u.player.cmd.upmove=100;
                u.player.cmd.buttons=BT_ATTACK|BT_ALTATTACK|BT_USE|BT_JUMP|BT_CROUCH|BT_ZOOM|BT_RELOAD|BT_USER1|BT_USER2|BT_USER3|BT_USER4;
                u.PlayerThink();
                Check(CaelumExhaustion.Locked(u) && u.player.cmd.forwardmove==0 && u.player.cmd.sidemove==0
                    && u.player.cmd.upmove==0 && u.player.cmd.buttons==0,"movement-and-all-action-commands-cleared");
            }
            else
            {
                Check(CaelumExhaustion.Active(u) && !CaelumExhaustion.Locked(u),"strictly-above-ten-unlocks-without-auto-wake");
                CaelumRestState.Cancel(u);
                Check(!CaelumRestState.IsActive(u) && !rest.Exhaustion && u.player.camera==u,"eligible-cancel-restores-control-camera");
            }
        }
        Reset(u);u.CombatTimeRemaining=10;u.CurrentHunger=u.CurrentThirst=0;Collapse(u);
        int oldHealth=u.health;u.ForcedSleepTics=20;u.DamageMobj(null,null,1,'CaelumImpact',DMG_FORCED,0);
        CaelumRestState.Validate(u);
        Check(u.health<oldHealth && CaelumExhaustion.Locked(u),"combat-critical-needs-and-real-damage-preserve-lock-without-immunity");
        Check(u.ForcedSleepTics==0,"damage-cancels-spell-only");
        u.SurvivalDamageAccumulator=0.999;u.ApplyCriticalSurvivalDamage();
        Check(CaelumExhaustion.Locked(u),"critical-needs-do-not-loop-begin-finish");
        u.ForcedSleepTics=1;u.AdvancePersonalTimeTic();
        Check(u.ForcedSleepTics==0 && CaelumExhaustion.Locked(u),"spell-expiry-does-not-release-exhaustion");
        int elapsed=rest.ElapsedTics;CaelumExhaustion.Sync(u);CaelumExhaustion.Sync(u);
        Check(rest.ElapsedTics==elapsed && rest.ExhaustionRevision==1,"sync-and-migration-idempotent");
        Check(!CaelumTimeAdvanceState.IsSewerBagSleep(u),"ground-does-not-inherit-sewer-bag-permission");
        Reset(u);u.CurrentHunger=u.CurrentThirst=40;
        let food=CaelumConsumableItem(Actor.Spawn("CaelumFoodRation"));food.Amount=2;food.AttachToOwner(u);
        let water=CaelumWaterContainer(Actor.Spawn("CaelumCanteenLarge"));water.WaterLiters=1;water.AttachToOwner(u);
        Collapse(u);CaelumDiningSession.Advance(u);int units=food.Amount;double liters=water.WaterLiters;
        CaelumDiningSession.Advance(u);
        Check(units==1 && liters<1 && food.Amount==units && water.WaterLiters==liters,"automatic-provisions-charge-once-with-in-flight-guard");
        for(int mode=1;mode<=3;mode++)
        {
            Reset(u);rest=CaelumRestState.Get(u);
            class<CaelumRestFurniture> kind=mode==1?"CaelumRestChair":mode==2?"CaelumRestBed":"CaelumRestBag";
            Support=CaelumRestFurniture(Actor.Spawn(kind,u.Pos));Support.bSolid=false;Support.Occupant=u;
            let bag=CaelumRestBag(Support);if(bag!=null)bag.Bag=CaelumSleepingBag(u.GiveInventoryType("CaelumSleepingBag"));
            rest.Status=CaelumRestRules.STATUS_ACTIVE;rest.Mode=mode==1?CaelumRestRules.MODE_WAIT:CaelumRestRules.MODE_SLEEP;
            rest.OriginMap=level.MapName;rest.Furniture=Support;rest.UsesFurniture=true;rest.OriginPosition=u.Pos;
            origin=u.Pos;Collapse(u);
            Check(u.Pos==origin && CaelumRestState.ResourceFactor(u)==(mode==1?1:Support.ComfortFactor())
                && (mode==1?rest.Furniture==null:rest.Furniture==Support),String.Format("support-truthful-chair-bed-bag-%d",mode));
        }
        Reset(u);Collapse(u);u.Vel=(3,2,-1);u.ApplyPhysicalMovement();
        Check(u.Vel==(3,2,-1) && u.ForwardMove1==0 && u.JumpZ==0,"immobilization-preserves-external-physics");
        Reset(u);Collapse(u);
        for(int tic=0;tic<35;tic++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        Check(Abs(u.CurrentSleep-35*CaelumRestRules.RecoverSleep(0,CaelumWorldClock.MapTimeScale(level.MapName)))<0.000001
            && CaelumRestState.Get(u).ElapsedTics==35,"shared-accelerated-steps-recover-once-per-serial");
        Reset(u);Console.Printf("CA258 DONE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca_rest_cancel" || e.Name=="ca_skip_open" || e.Name=="ca_table_eat" || e.Name=="ca_table_drink")
            Console.Printf("CA258 INPUT %s sleep=%.9f locked=%d",e.Name,u.CurrentSleep,CaelumExhaustion.Locked(u));
        if(e.Name=="c258_core")Core(u);
        if(e.Name=="c258_physics")
        {Reset(u);u.SetOrigin((0,0,24),false);u.Vel=(2,0,-1);StartPos=u.Pos;Collapse(u);Stage=1;Ticks=0;}
        if(e.Name=="c258_lock")
        {Reset(u);Collapse(u);u.CurrentSleep=e.Args[0];StartSleep=u.CurrentSleep;StartTic=level.maptime;}
        if(e.Name=="c258_load")
        {
            let r=CaelumRestState.Get(u);
            Check(CaelumExhaustion.Locked(u) && r.ExhaustionRevision==1 && u.CurrentSleep<1,"load-reconstructs-lock-without-offline-refill");
            Check(u.CurrentHunger>79 && u.CurrentThirst>69,"load-preserves-unrelated-resources");
            double before=u.CurrentSleep;CaelumExhaustion.Sync(u);CaelumExhaustion.Sync(u);
            Check(u.CurrentSleep==before && r.Exhaustion,"load-idempotent");
            Console.Printf("CA258 DONE failures=%d",Failures);
        }
        if(e.Name=="c258_ui_report")
        {Console.Printf("CA258 UI sleep=%.9f active=%d locked=%d pose=%d tic=%d",u.CurrentSleep,CaelumExhaustion.Active(u),CaelumExhaustion.Locked(u),u.InStateSequence(u.CurState,u.FindState("RestLying")),level.maptime);}
        if(e.Name=="c258_hub_seed")
        {u.CurrentSleep=0;CaelumExhaustion.Sync(u);u.PersistCharacterState();}
        if(e.Name=="c258_sewer")
        {
            u.CurrentSleep=0;CaelumExhaustion.Sync(u);
            Check(level.MapName=="MAP02" && CaelumExhaustion.Locked(u) && !CaelumTimeAdvanceState.IsSewerBagSleep(u)
                && CaelumRestState.Get(u).Furniture==null,"native-map02-ground-has-no-bag-exception");
            Console.Printf("CA258 DONE failures=%d",Failures);
        }
        if(e.Name=="c258_hub_check")
        {
            let r=CaelumRestState.Get(u);
            Check(CaelumExhaustion.Locked(u) && r.OriginMap==level.MapName,"native-hub-preserves-lock-and-reanchors-map");
            Check(r.ViewCamera!=null && u.player.camera==r.ViewCamera && r.Furniture==null,"native-hub-camera-no-stale-support");
            Console.Printf("CA258 DONE failures=%d",Failures);
        }
        if(e.Name=="c258_dead")
        {
            Reset(u);Collapse(u);u.DamageMobj(null,null,1000000,'CaelumImpact',DMG_FORCED,0);
            CaelumExhaustion.Sync(u);
            Check(u.health<=0 && u.player.playerstate==PST_DEAD && !CaelumRestState.IsActive(u)
                && u.player.camera==u,"death-cleans-lock-camera-without-resurrection");
            Console.Printf("CA258 DONE failures=%d",Failures);
        }
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || Stage==0)return;
        Ticks++;
        if(Stage==1 && Ticks==2)
        {
            Console.Printf("CA258 PHYS air x=%f z=%f vx=%f vz=%f floor=%f onground=%d gravity=%f nogravity=%d height=%f active=%d",u.Pos.X,u.Pos.Z,u.Vel.X,u.Vel.Z,u.FloorZ,u.player.onground,u.Gravity,u.bNOGRAVITY,u.Height,CaelumExhaustion.Active(u));
            Check(CaelumExhaustion.Active(u) && !u.player.onground && u.Pos.Z<StartPos.Z && u.Pos.X>StartPos.X,"native-airborne-fall-and-momentum");
        }
        if(Stage==1 && Ticks==45)
        {
            Console.Printf("CA258 PHYS land x=%f z=%f vx=%f vz=%f onground=%d health=%d active=%d",u.Pos.X,u.Pos.Z,u.Vel.X,u.Vel.Z,u.player.onground,u.health,CaelumExhaustion.Active(u));
            Check(CaelumExhaustion.Active(u) && u.player.onground && u.Pos.Z<StartPos.Z,"native-collision-lands-while-lying");
            Reset(u);u.SetOrigin((1024,0,64),false);u.CurrentSleep=0;CaelumExhaustion.Sync(u);Stage=2;Ticks=0;
        }
        if(Stage==2 && Ticks==10)
        {Check(u.WaterLevel==3 && CaelumExhaustion.Active(u),"native-swimmable-volume-keeps-lying");u.CurrentAir=0;u.UnderwaterDrowningTics=34;StartHealth=u.health;}
        if(Stage==2 && Ticks==50)
        {
            Check(u.health<StartHealth && CaelumExhaustion.Active(u),"native-drowning-still-damages");
            Reset(u);u.SetOrigin((2048,0,0),false);Collapse(u);StartPos=u.Pos;
            Level.ExecuteSpecial(23,u,null,false,3,8,64,0,0);Stage=3;Ticks=0;
        }
        if(Stage==3 && Ticks==70)
        {
            Check(u.Pos.Z>StartPos.Z && CaelumExhaustion.Active(u),"native-moving-floor-carries-lying-body");
            Reset(u);Collapse(u);StartSleep=u.CurrentSleep;StartTic=level.maptime;Stage=4;Ticks=0;
        }
        if(Stage==4 && Ticks==35)
        {
            // El tic de entrada sólo ancla la sesión; los restantes recuperan una vez.
            double expected=(Ticks-1)*CaelumRestRules.RecoverSleep(0,CaelumWorldClock.MapTimeScale(level.MapName));
            Console.Printf("CA258 RECOVERY actual=%.9f expected=%.9f delta=%d elapsed=%d",u.CurrentSleep-StartSleep,expected,level.maptime-StartTic,CaelumRestState.Get(u).ElapsedTics);
            Check(CaelumRestState.Get(u).ElapsedTics==Ticks-1 && Abs(u.CurrentSleep-StartSleep-expected)<0.000001,"native-recovery-exactly-one-shared-tick-no-free-ten");
            Reset(u);u.CurrentSleep=0.000001;Stage=5;Ticks=0;
        }
        if(Stage==5 && Ticks==3)
        {
            Check(CaelumExhaustion.Locked(u) && u.CurrentSleep<1,"native-passive-loss-triggers-exhaustion-without-direct-begin");
            Stage=0;Console.Printf("CA258 DONE failures=%d",Failures);
        }
    }
}
