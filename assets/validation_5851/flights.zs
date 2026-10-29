class CA415FlightChecks : EventHandler
{
    int Passed,Failed,SavedLife;
    double Expected,OldFraction;
    CaelumAbsentBattle Battle;
    CaelumPortDefender Soldier;
    CaelumMandinga Demon;
    CaelumPortCommander Boss;
    void Check(bool yes,String label)
    {if(yes)Passed++;else Failed++;Console.Printf("CA415F %s %s",yes?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}

    void Setup(CaelumPlayer user)
    {
        Soldier=CaelumPortDefender(ThinkerIterator.Create('CA415RoundSoldier').Next());
        Demon=CaelumMandinga(ThinkerIterator.Create('CA415RoundDemon').Next());
        Boss=CaelumPortCommander(ThinkerIterator.Create('CA415RoundBoss').Next());
        Soldier.health=Soldier.CombatMaximumHealth=Demon.health=Demon.CombatMaximumHealth=Boss.health=Boss.CombatMaximumHealth=10000000;
        Soldier.bFriendly=true;Demon.bFriendly=Boss.bFriendly=false;
        Soldier.target=Demon;Demon.target=Soldier;Boss.target=Soldier;
        Soldier.Carbine=new('CaelumCityCarbine');Soldier.Carbine.Initialize(Soldier);
        Soldier.CaelumDiagnosticPassiveAI=Demon.CaelumDiagnosticPassiveAI=Boss.CaelumDiagnosticPassiveAI=true;
        let encounter=CA415RoundEncounter(Actor.Spawn('CA415RoundEncounter',(512,512,0),NO_REPLACE));
        encounter.SiegeStarted=true;encounter.SetupRevision=1;encounter.Defenders.Push(Soldier);Soldier.Port=encounter;
        encounter.RegisterAttacker(Demon);encounter.RegisterAttacker(Boss);
        Battle=new('CaelumAbsentBattle');encounter.AbsentBattle=Battle;Battle.Capture(encounter,user);
        for(int i=0;i<Battle.Rows.Size();i++){Battle.Rows[i].Preparing=true;Battle.Rows[i].Remaining=1000;}
    }

    CaelumActorProjectile Bullet(bool legacy=false)
    {
        let shot=CaelumCarbineProjectile(Actor.Spawn('CaelumCarbineProjectile',Soldier.Pos+(0,0,Soldier.Height/2),NO_REPLACE));
        shot.target=Soldier;shot.Vel=(0,0,0);shot.bNoGravity=true;shot.StoreCaelumAttackResult(300,true,false,false,0);
        shot.StoreCaelumWeaponWearIdentity(CaelumConstants.WEAPON_TYPE_CARBINE,1,CaelumConstants.EQUIPMENT_SIZE_M);
        if(!legacy)shot.StoreSummaryAim(Demon,CaelumConstants.WEAPON_TYPE_CARBINE,1,0,0,false);
        return shot;
    }

    void SaveChecks(CaelumPlayer user)
    {
        Setup(user);let shot=Bullet();Soldier.target=Boss;CaelumAbsentShot.Capture(Battle);
        Check(Battle.Flights.Size()==1 && Battle.Flights[0].Recipient.Body==Demon,"pending projectile retains launch target after shooter retargets");
        CaelumAbsentShot.Capture(Battle);Check(Battle.Flights.Size()==1,"repeated capture does not duplicate paid projectile");
        SavedLife=Demon.health;OldFraction=Demon.AbsentCombatant.LifeFraction;
        Expected=Battle.Flights[0].Attack.Direct(Soldier,Demon,Demon.AbsentCombatant.Blocking(Soldier)).Life;
        Check(Expected>0 && Battle.Flights[0].Attack.Damage==300,"pending projectile preserves stored damage and launch dispersion");
    }

    void LoadChecks()
    {
        Console.Printf("CA415F DETAIL load away=%d flights=%d life=%d saved=%d fraction=%.9f expected=%.9f",Battle.Away,Battle.Flights.Size(),Demon.health,SavedLife,Demon.AbsentCombatant.LifeFraction,Expected);
        Check(Battle!=null && Battle.Flights.Size()==1 && Battle.Flights[0].Shot!=null,"save retains the actual pending projectile and encounter");
        let shot=Battle.Flights[0].Shot;
        int magazine=Soldier.Carbine.Magazine,shots=Soldier.Carbine.ShotCount;
        double air=Soldier.CurrentCombatAir,anima=Soldier.CurrentCombatAnima;
        Battle.Round();
        Check(Near(SavedLife-Demon.health+Demon.AbsentCombatant.LifeFraction-OldFraction,Expected),"paid projectile applies its mean damage once");
        Check(Battle.Flights.Size()==0 && (shot==null || shot.bDestroyed),"resolved projectile cannot resume a second native flight");
        Check(Soldier.Carbine.Magazine==magazine && Soldier.Carbine.ShotCount==shots
            && Soldier.CurrentCombatAir>=air && Soldier.CurrentCombatAnima>=anima,"pending hit spends no second cartridge Air or Anima");
        int health=Demon.health;double fraction=Demon.AbsentCombatant.LifeFraction;
        Battle.Round();CaelumAbsentShot.Capture(Battle);
        Check(Demon.health==health && Near(fraction,Demon.AbsentCombatant.LifeFraction) && Battle.Flights.Size()==0,"second round and capture cannot repeat the resolved hit");
    }

    void MoreChecks()
    {
        Soldier.target=Demon;let legacy=Bullet(true);CaelumAbsentShot.Capture(Battle);
        Check(legacy.CaelumSummaryRevision==1 && Battle.Flights.Size()==1,"old flight metadata migrates exactly once without relaunching");
        CaelumAbsentShot.Capture(Battle);Check(Battle.Flights.Size()==1,"old-flight migration is idempotent");
        Battle.Round();
        let magic=CaelumActorExplosiveElementalProjectile(Actor.Spawn('CaelumActorExplosiveElementalProjectile',Boss.Pos+(0,0,Boss.Height/2),NO_REPLACE));
        magic.target=Boss;magic.Vel=(0,0,0);magic.StoreCaelumAttackResult(100,true,false,true,0);
        magic.StoreSummaryAim(Soldier,CaelumConstants.WEAPON_TYPE_STATUETTE,1,0,0,true);
        magic.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_EARTH,false,100,100);
        magic.ConfigureCaelumActorExplosion(100,Boss.GetTierOneStatuetteExplosionRadius(),Boss.GetCombatAbilityRange());
        CaelumAbsentShot.Capture(Battle);Check(Battle.Flights.Size()==1,"prepared explosive flight joins the same saved queue");
        int before=Soldier.health,other=Demon.health;
        Battle.Round();
        Check(Soldier.health<before && Demon.health<other,"pending explosion retains its direct victim and nearby secondary body");
        before=Soldier.health;other=Demon.health;Battle.Round();
        Check(Soldier.health==before && Demon.health==other,"pending explosion has no repeated native Death explosion");
        Soldier.health=0;Soldier.bCorpse=true;Soldier.bShootable=false;Soldier.AbsentCombatant=null;
        let posthumous=Bullet();CaelumAbsentShot.Capture(Battle);other=Demon.health;
        Check(Battle.Flights.Size()==1 && !Soldier.AbsentCombatant.Alive(),"dead launch owner is retained only as the projectile source");
        Battle.Round();
        Check(Demon.health<other,"already launched projectile survives its owner's death");
        let obsolete=Bullet();CaelumAbsentShot.Capture(Battle);int bossLife=Boss.health;
        Demon.health=0;Battle.Round();
        Check(Boss.health==bossLife && Battle.Flights.Size()==0,"projectile whose recorded target died is consumed without retargeting");
    }

    void TravelingSetup(CaelumPlayer user)
    {
        SaveChecks(user);
        let roster=CaelumHouseResidents.Get(true);roster.EnsureRecords();
        let home=roster.Residents[0];home.Body=Soldier;home.Created=true;home.Emitted=true;
        home.ResidentMap=level.MapName;home.Position=Soldier.Pos;home.AssignmentInitialized=true;
        home.GunIndex=-1;home.GunSlot=-1;Soldier.Residence=home;Soldier.HomeIdentity=0;
        Soldier.HomeRevision=CaelumCityData.PERSISTENCE_REVISION;
        Battle.Encounter.ChangeTid(915061);Demon.ChangeTid(915063);
        for(int i=0;i<Battle.Rows.Size();i++)Battle.Rows[i].Body.ForcedSleepTics=100000;
        Battle.Away=false;
    }

    void TravelingHome(CaelumPlayer user)
    {
        let port=CA415RoundEncounter(ActorIterator.Create(915061).Next());
        Soldier=CaelumHouseResidents.Get().Residents[0].Body;
        Demon=CaelumMandinga(ActorIterator.Create(915063).Next());Battle=port.AbsentBattle;
        Check(!Battle.Away && Battle.Flights.Size()==0,"hub return automatically resolves the pending flight");
        Check(Soldier.AbsentCombatant.Body==Soldier && port.Defenders[0]==Soldier,"pending projectile source uses the original traveling resident");
        Check(Near(SavedLife-Demon.health+Demon.AbsentCombatant.LifeFraction-OldFraction,Expected),"traveling shooter's pending hit applies exactly once after return");
        int before=Demon.health;double fraction=Demon.AbsentCombatant.LifeFraction;
        CaelumAbsentBattles.Restore(user);
        Check(Demon.health==before && Near(fraction,Demon.AbsentCombatant.LifeFraction),"repeated return does not duplicate a traveling shooter's hit");
    }

    void AreaChecks(CaelumPlayer user)
    {
        Setup(user);Soldier.CombatArmor=null;Soldier.Shield=null;
        Soldier.CombatToughness=0;Soldier.EffectiveCombatEvasionChance=0;
        vector3 positions[]={(160,128,0),(160,160,0),(192,160,0),(128,128,0)};
        for(int critical=0;critical<2;critical++)for(int i=0;i<positions.Size();i++)
        {
            Soldier.SetOrigin(positions[i],false);Soldier.ThermalState=null;
            vector3 origin=(128,128,64);
            let shot=CaelumActorExplosiveElementalProjectile(Actor.Spawn('CaelumActorExplosiveElementalProjectile',origin,NO_REPLACE));
            shot.target=Boss;shot.StoreCaelumAttackResult(100,true,critical==1,true,0);
            shot.StoreCaelumElementalPayload(CaelumConstants.ESSENCE_EARTH,false,100,100);
            shot.ConfigureCaelumActorExplosion(100,Boss.GetTierOneStatuetteExplosionRadius(),Boss.GetCombatAbilityRange());
            let attack=new('CaelumAbsentAttack');attack.Configure(Boss,true);
            attack.Damage=100;attack.Critical=critical;attack.Accuracy=1;attack.Debuff=1;attack.Push=0;
            let predicted=attack.Splash(Boss,Soldier,origin,1,false);
            int before=Soldier.health;shot.A_Explode(100,attack.Area,0,false);
            Check(Near(predicted.Life,before-Soldier.health),"area damage matches native radius attack at recorded body position");
            if(!Near(predicted.Life,before-Soldier.health))Console.Printf("CA415F DETAIL area case=%d critical=%d predicted=%.9f actual=%d",i,critical,predicted.Life,before-Soldier.health);
            shot.Destroy();
        }
        Boss.SetOrigin((128,128,0),false);
        for(int critical=0;critical<2;critical++)for(int i=0;i<positions.Size();i++)
        {
            Soldier.SetOrigin(positions[i],false);Soldier.ThermalState=null;
            let attack=new('CaelumAbsentAttack');attack.Configure(Boss,false);
            attack.Damage=100;attack.Critical=critical;attack.Accuracy=1;
            let predicted=attack.Splash(Boss,Soldier,Boss.Pos,1,false);
            Boss.LastCombatAttackCriticalHit=critical==1;Boss.PendingCombatCriticalDelivery=critical==1;
            Boss.ThermalBluntDelivery=true;Boss.BeginCombatAreaExplosion(attack.Area);
            int before=Soldier.health;
            Boss.A_Explode(100,attack.Area,XF_NOTMISSILE|XF_THRUSTLESS|XF_NOALLIES|XF_CIRCULAR,false);
            Boss.EndCombatAreaExplosion();Boss.ThermalBluntDelivery=false;Boss.PendingCombatCriticalDelivery=false;
            Check(Near(predicted.Life,before-Soldier.health),"ground slam matches native circular radius attack");
            if(!Near(predicted.Life,before-Soldier.health))Console.Printf("CA415F DETAIL slam case=%d critical=%d predicted=%.9f actual=%d",i,critical,predicted.Life,before-Soldier.health);
        }
    }

    void TerminalChecks(CaelumPlayer user)
    {
        Setup(user);let shot=Bullet();CaelumAbsentShot.Capture(Battle);
        for(int i=0;i<Battle.Rows.Size();i++)Battle.Rows[i].Participating=false;
        Battle.TargetCacheReady=false;double end=Battle.Stamp+365*86400.0;
        int life=Demon.health;double begin=MSTimeF();Battle.SyncTo(end);
        Console.Printf("CA415F TIMING terminal_year_ms=%.6f",MSTimeF()-begin);
        Check(Battle.Rounds==1 && Battle.Flights.Size()==0,"terminal catch-up consumes remaining flights before skipping empty time");
        Check(Near(Battle.Stamp,end) && Near(Battle.SimulationTime,end) && Demon.health==life,"terminal year advances timestamps without changing parked bodies");
        int rounds=Battle.Rounds;Battle.SyncTo(end);
        Check(Battle.Rounds==rounds,"repeated terminal catch-up remains idempotent");
        let port=CaelumPortSiege(Battle.Encounter);port.Reinforcements=new('CaelumSiegeReinforcements');
        port.Reinforcements.Enabled=true;port.Reinforcements.Remaining=1;port.Victory=false;
        Check(!Battle.Terminal(),"finite live reserves prevent terminal skipping");
        port.Victory=true;
        Check(Battle.Terminal() && port.Reinforcements.Stopped,"existing victory stops reserves before terminal skipping");
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca415r_flightsave")SaveChecks(user);
        else if(e.Name=="ca415r_flightload")LoadChecks();
        else if(e.Name=="ca415r_flights"){SaveChecks(user);LoadChecks();MoreChecks();}
        else if(e.Name=="ca415r_area")AreaChecks(user);
        else if(e.Name=="ca415r_flighttravel")TravelingSetup(user);
        else if(e.Name=="ca415r_flighthome")TravelingHome(user);
        else if(e.Name=="ca415r_terminal")TerminalChecks(user);
        else return;
        Console.Printf("CA415F RESULT passed=%d failed=%d",Passed,Failed);
    }
}
