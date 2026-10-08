class CA143MiniPort : CaelumPortSiege { override void Tick() {} }
class CA143LiveTarget : Actor
{
    int Hits;
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {Hits++;return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);}
    Default { Radius 24; Height 80; Health 1000000; +SOLID +SHOOTABLE }
    States { Spawn:DOID A -1;Stop; }
}
class CA143Live : EventHandler
{
    CaelumPortDefender Body;CA143LiveTarget Victim;CA143MiniPort Port;
    int Checks,Failures,LastShots,LastShotTic;
    bool SawReload;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA143 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==60)
        {Port=CA143MiniPort(Actor.Spawn("CA143MiniPort"));Body=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(3072,4096,0)));Victim=CA143LiveTarget(Actor.Spawn("CA143LiveTarget",(3584,4096,0)));}
        if(level.time==70)
        {
            Body.Carbine=new("CaelumCityCarbine");Body.Carbine.Initialize(Body);
            Body.Port=Port;Body.Station=Body.Pos;Body.HomeRevision=1;Body.DeploymentComplete=true;Body.Lane=0;
            Port.RosterSealed=true;Port.SiegeStarted=true;Port.DefendingTarget[0]=Victim;
            Body.target=Victim;Body.SetState(Body.SeeState);
        }
        if(Body!=null && level.time>70 && level.time<1500)
        {
            if(Body.Carbine.ReloadRemaining>0)SawReload=true;
            if(Body.Carbine.ShotCount>LastShots)
            {
                if(!Body.Carbine.Crouched || !Body.Carbine.Aiming)Check(false,"ordinary AI shot must be crouched and aimed");
                if(LastShots>0 && level.time-LastShotTic<int(Ceil(Body.GetProfileWeaponDuration(CaelumConstants.WEAPON_TYPE_CARBINE))))Check(false,"posture does not accelerate shot cadence");
                LastShots=Body.Carbine.ShotCount;LastShotTic=level.time;
            }
        }
        if(level.time==1500)
        {
            Check(Body.Carbine.ShotCount>20 && Body.Carbine.ReloadCount>=2 && SawReload,"ordinary siege AI fires and reloads multiple crouched magazines");
            Check(Body.health>0 && Victim.Hits>0 && Victim.health<1000000,"native projectiles hit while the physiological soldier remains alive");
            Check(Body.Carbine.Weapon.Durability<Body.Carbine.Weapon.GetMaximumDurability() && Body.FindInventory("CaelumCarbineAmmo")==null,"ordinary wear and virtual reserve remain active");
            Port.DefendingTarget[0]=null;Body.target=null;
        }
        if(level.time==1510)
        {
            Check(!Body.Carbine.Crouched && !Body.Carbine.Aiming && Body.Height==Body.Carbine.StandingHeight,"ordinary target loss releases crouched aim");
            Console.Printf("CA143 LIVE shots=%d reloads=%d hits=%d health=%d air=%.6f exposure=%.6f",Body.Carbine.ShotCount,Body.Carbine.ReloadCount,Victim.Hits,Body.health,Body.CurrentCombatAir,Body.ThermalState.Exposure);
            Console.Printf("CA143 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
