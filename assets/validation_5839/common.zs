class CA415AimSoldier : CaelumPortDefender {override void Tick(){}}
class CA415AimTarget : CaelumMandinga {override void Tick(){}}
class CA415AimChecks : EventHandler
{
    CA415AimSoldier Soldier;
    CA415AimTarget Victim;
    int Passed,Failed;
    void Check(bool ok,String text)
    {if(ok)Passed++;else Failed++;Console.Printf("CA415A %s %s",ok?"PASS":"FAIL",text);}
    bool Near(double a,double b,double tolerance=0.00000001){return Abs(a-b)<tolerance;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
    }
    void Prepare(CaelumPlayer u)
    {
        Soldier=CA415AimSoldier(Actor.Spawn('CA415AimSoldier',(128,48,0),NO_REPLACE));
        Victim=CA415AimTarget(Actor.Spawn('CA415AimTarget',(128,208,0),NO_REPLACE));
        Soldier.ChangeTid(915039);Victim.ChangeTid(915040);
    }
    void NativeShots()
    {
        if(Soldier!=null && Soldier.Carbine==null)
        {Soldier.Carbine=new('CaelumCityCarbine');Soldier.Carbine.Initialize(Soldier);}
        Check(Soldier!=null && Soldier.Carbine!=null && Victim!=null,"native actors and carbine initialized");
        if(Soldier==null || Soldier.Carbine==null || Victim==null)return;
        Soldier.CurrentCombatAir=Soldier.MaximumCombatAir;Soldier.RecoveryPhase=0;
        Soldier.CombatLucidityPhysicalStunRemaining=0;Soldier.ForcedSleepTics=0;
        Soldier.Carbine.Weapon.Durability=Soldier.Carbine.Weapon.GetMaximumDurability();
        Soldier.target=Victim;Victim.target=Soldier;
        for(int i=0;i<12;i++)
        {
            Soldier.Carbine.Weapon.Tier=1+i%3;
            Soldier.CurrentCombatLucidity=CaelumConstants.MAXIMUM_LUCIDITY*(1.0-(i/3)*.2);
            Soldier.Carbine.NextShotTic=level.time;Soldier.Carbine.Magazine=10;
            Soldier.CurrentCombatAir=Soldier.MaximumCombatAir;Soldier.Carbine.ReloadRemaining=0;
            int before=Soldier.Carbine.ShotCount;
            Soldier.Carbine.Attack(Soldier,Victim);
            Check(Soldier.Carbine.ShotCount==before+1,"real carbine projectile fired");
            let iterator=ThinkerIterator.Create('CaelumCarbineProjectile');CaelumCarbineProjectile shot;
            while((shot=CaelumCarbineProjectile(iterator.Next()))!=null)
            {
                Console.Printf("CA415A SAMPLE carbine %d %.12f %.12f %.12f %.12f %.12f %.12f %.12f %.12f %d %d %d",
                    i,shot.Vel.X,shot.Vel.Y,shot.Vel.Z,Soldier.Carbine.LastAccuracyPercent,
                    Soldier.Carbine.LastMinimumSpread,Soldier.Carbine.LastMaximumSpread,
                    Soldier.Carbine.LastCriticalChance,Soldier.CurrentCombatAir,Soldier.Carbine.Magazine,
                    shot.CaelumCriticalHit,shot.CaelumPreparedDamage);
                shot.Destroy();
            }
            let missile=CaelumActorProjectile(Actor.Spawn('CaelumActorSimpleElementalProjectile',Victim.Pos+(0,0,48),NO_REPLACE));
            missile.Vel=(10,20,3);missile.Angle=VectorAngle(10,20);
            // Mandinga conserva su opt-out vigente; la segunda aplicación
            // ejercita la distribución de un actor que sí la utiliza.
            Victim.ApplyWeaponProjectileDispersion(missile,CaelumConstants.WEAPON_TYPE_STAFF);
            Console.Printf("CA415A SAMPLE mandinga %d %.12f %.12f %.12f",i,missile.Vel.X,missile.Vel.Y,missile.Vel.Z);
            Soldier.ApplyWeaponProjectileDispersion(missile,CaelumConstants.WEAPON_TYPE_STATUETTE);
            Console.Printf("CA415A SAMPLE spell %d %.12f %.12f %.12f",i,missile.Vel.X,missile.Vel.Y,missile.Vel.Z);
            missile.Destroy();
        }
        Check(Soldier.Carbine.Magazine==9,"actual magazine remains authoritative");
    }
    void Saved()
    {
        Soldier=CA415AimSoldier(ActorIterator.Create(915039).Next());
        Victim=CA415AimTarget(ActorIterator.Create(915040).Next());
        Check(Soldier!=null && Victim!=null,"save/hub retains original actor identities");
        if(Soldier==null)return;
        Check(Soldier.Carbine!=null && Soldier.Carbine.ShotCount==12 && Soldier.Carbine.Magazine==9,
            "save/hub retains actual magazine and shots");
    }
    virtual void Math(){}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca415a_prepare'){Prepare(u);return;}
        if(e.Name=='ca415a_native')NativeShots();
        else if(e.Name=='ca415a_saved')Saved();
        else if(e.Name=='ca415a_math')Math();
        else return;
        Console.Printf("CA415A RESULT passed=%d failed=%d",Passed,Failed);
    }
}
