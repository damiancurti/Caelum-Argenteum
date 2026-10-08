class CA143Soldier : CaelumPortDefender { override void Tick() {} }
class CA143Target : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default { Radius 24; Height 80; Health 1000000; +SOLID +SHOOTABLE }
    States { Spawn:DOID A -1;Stop; }
}
class CA143Marker : Actor
{
    CaelumPortDefender Body;
    Default { +NOINTERACTION }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA143Persistence : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="CA143" || (!e.IsSaveGame && !e.IsReopen))return;
        let marker=CA143Marker(ThinkerIterator.Create("CA143Marker").Next());
        if(marker==null)return;
        let b=marker.Body;let c=b.Carbine;
        bool ok=c.Revision==2 && c.Holder==b && c.Crouched && c.Aiming && c.Magazine==9
            && Abs(b.Height-c.StandingHeight*0.5)<0.00001 && c.ReloadRemaining==1.5;
        Console.Printf("CA143 PERSISTENCE saved=%d reopened=%d failures=%d",e.IsSaveGame,e.IsReopen,int(!ok));
    }
}
class CA143Checks : EventHandler
{
    CaelumPortDefender Body;CA143Target Victim;
    int Checks,Failures;
    double FullHeight,Area,HeatHeight,CameraFov;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA143 %s %s",ok ? "PASS" : "FAIL",label);}
    void ResetPose()
    {Body.ForcedSleepTics=0;Body.CombatLucidityPhysicalStunRemaining=0;Body.RecoveryPhase=0;Body.SetStateLabel("Spawn");Body.Carbine.NextShotTic=level.time;Body.Carbine.ReloadRemaining=0;Body.Carbine.Attack(Body,Victim);}
    override void WorldTick()
    {
        if(level.MapName!="CA143")return;
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==50)
        {Body=CaelumPortDefender(Actor.Spawn("CA143Soldier",(3072,4096,0)));Victim=CA143Target(Actor.Spawn("CA143Target",(3584,4096,0)));}
        if(level.time==60)
        {
            Body.InitializeUniformFolkloreProfile(100);Body.Carbine=new("CaelumCityCarbine");Body.Carbine.Initialize(Body);
            Body.tics=-1;FullHeight=Body.Height;CameraFov=user.player.FOV;
            Check(Body.GetSpriteIndex("CAGC")>=0,"all dynamic crouched sprite frames are registered before rendering");
            let thermal=CaelumThermalBody.Get(Body,true);CaelumThermalBody.Refresh(Body,thermal);Area=thermal.SurfaceArea;HeatHeight=thermal.HeightMeters;
            Check(Body.Carbine.Revision==2 && Body.Carbine.Magazine==10 && Body.Carbine.StandingHeight==FullHeight,"revision two captures full height without altering initial magazine");
        }
        if(level.time==70)
        {
            double air=Body.CurrentCombatAir;
            Check(Body.Carbine.Attack(Body,Victim),"native aimed carbine attack accepted");
            Check(Body.Carbine.Crouched && Body.Carbine.Aiming && Abs(Body.Height-FullHeight*0.5)<0.00001,"actual shot uses half-height physical crouch and aim");
            Check(Body.Carbine.ShotCount==1 && Body.Carbine.Magazine==9 && Body.CurrentCombatAir<air,"one shot spends one round and ordinary Air");
            double accuracy=Max(1.0,Body.CombatPhysicalAccuracyPercent*Body.CombatLucidityAccuracyMultiplier*Body.ElementalStatus.GetAccuracyMultiplier()*4);
            Check(Abs(Body.Carbine.LastAccuracyPercent-accuracy)<0.00001,"crouch and aim multiply shared accuracy once each");
            Check(Abs(Body.Carbine.LastMinimumSpread-CaelumWeaponCatalogue.GetMinimumSpread(CaelumConstants.CATALOGUE_WEAPON_CARBINE)*100/accuracy)<0.00001
                && Abs(Body.Carbine.LastMaximumSpread-CaelumWeaponCatalogue.GetMaximumSpread(CaelumConstants.CATALOGUE_WEAPON_CARBINE)*100/accuracy)<0.00001,"both projectile spread bounds use the effective aimed accuracy");
            double critical=Clamp((CaelumWeaponCatalogue.GetCriticalChancePercent(CaelumConstants.CATALOGUE_WEAPON_CARBINE)
                +Max(0.0,Body.CombatPhysicalCriticalChancePercent-CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT))*2,0,100);
            Check(Abs(Body.Carbine.LastCriticalChance-critical)<0.00001,"crouch critical multiplier applies once with the existing cap");
            let bullet=CaelumCarbineProjectile(ThinkerIterator.Create("CaelumCarbineProjectile").Next());
            Check(bullet!=null && bullet.target==Body && Abs(bullet.Pos.Z-(Body.Pos.Z+CaelumRangedRules.LaunchHeight(Body,Body.Carbine.Weapon.WeaponType)))<0.00001
                && bullet.Pos.Z<FullHeight*0.65,"actual ballistic projectile originates at lowered art-aligned muzzle");
            let thermal=CaelumThermalBody.Get(Body,true);CaelumThermalBody.Refresh(Body,thermal);
            Check(Abs(thermal.SurfaceArea-Area)<0.00001 && thermal.HeightMeters==HeatHeight,"crouching preserves physiological height and thermal surface area");
            Body.Carbine.Tick(Body);
            Check(Body.sprite==Body.GetSpriteIndex("CAGC") && Body.frame==1,"actual firing uses dedicated crouched sprite without scale mutation");
            Body.Carbine.ReloadRemaining=Body.Carbine.ReloadTotal=1.5;
            let marker=CA143Marker(Actor.Spawn("CA143Marker"));marker.Body=Body;
        }
        if(level.time==100)
        {
            Check(user.player.FOV==CameraFov && !user.RangedAimModeActive,"NPC aimed shots do not alter the player camera or aim state");
            Body.Carbine.ReloadRemaining=1;Body.Carbine.PreviousPosition=Body.Pos;Body.Carbine.Tick(Body);
            double stationary=1-Body.Carbine.ReloadRemaining;
            Body.Carbine.ReloadRemaining=1;Body.SetOrigin(Body.Pos+(4,0,0),false);Body.Carbine.LastAimTic=level.time-1;Body.Carbine.Tick(Body);
            Check(Abs(stationary-1.0/TICRATE)<0.00001 && Abs((1-Body.Carbine.ReloadRemaining)-stationary*CaelumConstants.RELOAD_MOVEMENT_AND_PROGRESS_MULTIPLIER)<0.00001,"stationary and moving reload retain existing progress rates");
            Body.Carbine.ReloadRemaining=0;Body.SetOrigin(Body.Pos+(64,0,0),false);Body.Carbine.LastAimTic=level.time-1;Body.Carbine.Tick(Body);
            Check(!Body.Carbine.Crouched && !Body.Carbine.Aiming && Body.Height==FullHeight,"physical movement restores standing posture and removes aim");
            ResetPose();Body.SetStateLabel("Pain");Body.Carbine.ReloadRemaining=1;Body.Carbine.Tick(Body);
            Check(!Body.Carbine.Crouched && Body.Carbine.ReloadRemaining==0,"pain cancels reload and restores posture");
            ResetPose();Body.ForcedSleepTics=35;Body.Carbine.Tick(Body);
            Check(!Body.Carbine.Crouched && !Body.Carbine.Aiming,"forced sleep interrupts crouched aim");
            ResetPose();Body.CombatLucidityPhysicalStunRemaining=1;Body.Carbine.Tick(Body);
            Check(!Body.Carbine.Crouched,"physical stun exits crouch");
            ResetPose();Body.RecoveryPhase=1;Body.Carbine.Tick(Body);
            Check(!Body.Carbine.Crouched,"resource retreat restores standing collision");
            ResetPose();Body.Carbine.ReloadRemaining=1;int rounds=Body.Carbine.Magazine;Body.Carbine.Select(false);
            Check(!Body.Carbine.Crouched && !Body.Carbine.Aiming && Body.Carbine.ReloadRemaining==0 && Body.Carbine.Magazine==rounds,"melee selection restores height without free ammunition");
            ResetPose();Body.SetOrigin((6500,4096,0),false);Body.Carbine.SetCrouched(Body,false);
            Check(Body.Carbine.Crouched && !Body.Carbine.Aiming && Abs(Body.Height-FullHeight*0.5)<0.00001,"low native ceiling prevents standing without clipping");
            Body.SetOrigin((3072,4096,0),false);Body.Carbine.SetCrouched(Body,false);
            Check(!Body.Carbine.Crouched && Body.Height==FullHeight,"standing succeeds after returning to sufficient clearance");
            int shots=Body.Carbine.ShotCount;Victim.SetOrigin((-64,4096,0),false);
            Check(!Body.Carbine.Attack(Body,Victim) && Body.Carbine.ShotCount==shots,"native wall obstruction still prevents firing");
            Victim.SetOrigin((3584,4096,0),false);ResetPose();Body.health=0;Body.Carbine.Tick(Body);shots=Body.Carbine.ShotCount;
            Check(!Body.Carbine.Attack(Body,Victim) && Body.Carbine.ShotCount==shots && !Body.Carbine.Aiming,"death prevents further aimed fire");
        }
        if(level.time==190)Console.Printf("CA143 COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
