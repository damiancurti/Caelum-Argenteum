// #310: observación por tic del mismo escenario antes y después de extraer.
class CA310Probe : EventHandler
{
    CaelumPlayer User;
    CA309Probe Audit;
    CA309Target Victim;
    CA309Target LeftVictim,RightVictim;
    int CaseId,StartTic,InitialSerial,InitialWear;
    bool Tracing;
    String LastTrace;
    int Projectiles,DeathProjectiles,DeathSerial,DeathWear;
    double DeathAir,DeathAnima;

    override void WorldThingSpawned(WorldEvent e)
    {if(e.Thing is 'CaelumPlayerMagicProjectile')Projectiles++;}

    void Begin(int id,int distance,bool empty)
    {
        Audit=CA309Probe(EventHandler.Find("CA309Probe"));User=Audit.User;
        if(Victim!=null)Victim.Destroy();
        User.SetOrigin((0,0,0),false);User.Angle=User.Pitch=0;
        Victim=CA309Target(Actor.Spawn("CA309Target",(distance,0,0),NO_REPLACE));
        Victim.bISMONSTER=true;
        Victim.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);Victim.health=1000000;
        Victim.ThermalState=new("CaelumThermalState");Victim.ThermalState.Initialize();
        CaelumThermalBody.Refresh(Victim,Victim.ThermalState);
        if(User.IsRangedWeaponType(Audit.Type))User.SetRangedMagazineCount(Audit.Type,2);
        User.CurrentAir=empty?0:User.DerivedStats.MaximumAir;
        User.CurrentAnima=empty?0:User.DerivedStats.MaximumAnima;
        CaseId=id;StartTic=level.time;Tracing=true;LastTrace="";
        if(id==4)
        {
            LeftVictim=CA309Target(Actor.Spawn("CA309Target",(0,128,0),NO_REPLACE));
            RightVictim=CA309Target(Actor.Spawn("CA309Target",(0,-128,0),NO_REPLACE));
            LeftVictim.bISMONSTER=RightVictim.bISMONSTER=true;
        }
        InitialSerial=User.AttackAnimationSerial;InitialWear=Audit.Item.Durability;
        Audit.Begin();Audit.Observing=false;
    }

    override void WorldTick()
    {
        if(!Tracing || User==null)return;
        let ammo=User.FindNativeAmmunition(User.GetRangedAmmoType(Audit.Type));
        String trace=String.Format("serial=%d item=%d wear=%d air=%.9f anima=%.9f mag=%d ammo=%d pending=%d cast=%d charge=%d charged=%d reload=%d aim=%d cooldown=%.9f casttime=%.9f hits=%d raw=%d lost=%d health=%d",
            User.AttackAnimationSerial-InitialSerial,User.ActiveWeaponItemId,Audit.Item.Durability,
            User.CurrentAir,User.CurrentAnima,User.GetRangedMagazineCount(Audit.Type),ammo==null?-1:ammo.Amount,
            User.PhysicalAttackPending,User.StaffCastPending,User.WeaponChargeActive,User.WeaponChargedStateActive,
            User.RangedReloadActive,User.RangedAimModeActive,User.EquippedWeaponCooldownRemaining,
            User.StaffCastCooldownRemaining,Victim.Hits,Victim.InputDamage,Victim.HealthLoss,User.health);
        if(trace!=LastTrace)Console.Printf("CA310 TRACE case=%d tic=%d %s",CaseId,level.time-StartTic,trace);
        LastTrace=trace;
    }

    void End(int expectation)
    {
        WorldTick();Tracing=false;
        if(Audit.Type==CaelumConstants.WEAPON_TYPE_BOLAS)
            Audit.Check(User.ActiveWeaponItemId==0 && Audit.Item.Owner!=User && !Audit.Item.Equipped,
                "bolas throw transfers the actual item out of the hand");
        else Audit.Check(User.ActiveWeaponItemId==Audit.Item.ItemId && Audit.Item.Owner==User,
                "dispatch retains exact owned equipment");
        if(CaseId==4)
        {
            Console.Printf("CA310 SWEEP hits=%d left=%d right=%d",User.LastMeleeSweepHitCount,LeftVictim.Hits,RightVictim.Hits);
            Audit.Check(User.LastMeleeSweepHitCount==3 && LeftVictim.Hits>0 && RightVictim.Hits>0,
                "one native sweep reaches all three eligible targets");
            LeftVictim.Destroy();RightVictim.Destroy();LeftVictim=RightVictim=null;
        }
        if(expectation==1)Audit.Check(User.AttackAnimationSerial>InitialSerial,"native attack starts");
        if(expectation==2)Audit.Check(User.AttackAnimationSerial==InitialSerial && Victim.Hits==0,
            "unavailable resources cannot start attack or deal damage");
        Console.Printf("CA310 CASE id=%d serials=%d wear=%d hits=%d lost=%d",CaseId,
            User.AttackAnimationSerial-InitialSerial,InitialWear-Audit.Item.Durability,Victim.Hits,Victim.HealthLoss);
        Victim.Destroy();Victim=null;
    }

    void Authority(bool twoPlayers)
    {
        Audit=CA309Probe(EventHandler.Find("CA309Probe"));User=Audit.User;
        int serial=User.AttackAnimationSerial;double air=User.CurrentAir,anima=User.CurrentAnima;
        int cheats=User.player.cheats;User.player.cheats=cheats|CF_PREDICTING;
        User.PerformEquippedWeaponPrimaryAttack();User.PerformEquippedWeaponSecondaryAttack();
        User.PerformLargeWeaponSweep(CaelumConstants.WEAPON_TYPE_HALBERD);
        Audit.Check(User.AttackAnimationSerial==serial && User.CurrentAir==air && User.CurrentAnima==anima
            && !User.PhysicalAttackPending && !User.StaffCastPending,"prediction rejects all three dispatch commands");
        User.player.cheats=cheats;
        let current=User.player.mo;User.player.mo=null;
        User.PerformEquippedWeaponPrimaryAttack();User.PerformEquippedWeaponSecondaryAttack();
        User.PerformLargeWeaponSweep(CaelumConstants.WEAPON_TYPE_HALBERD);
        User.player.mo=current;
        Audit.Check(User.AttackAnimationSerial==serial && User.CurrentAir==air && User.CurrentAnima==anima,
            "stale native pawn rejects commands before writes");
        let orphan=CaelumPlayer(Actor.Spawn("CaelumPlayer",(0,256,0),NO_REPLACE));
        orphan.PerformEquippedWeaponPrimaryAttack();orphan.PerformEquippedWeaponSecondaryAttack();
        orphan.PerformLargeWeaponSweep(CaelumConstants.WEAPON_TYPE_HALBERD);
        Audit.Check(orphan.AttackAnimationSerial==0,"detached pawn cannot start a combat action");orphan.Destroy();
        if(!twoPlayers)return;
        let other=CaelumPlayer(players[1].mo);
        Audit.Check(playeringame[1] && other!=null && other!=User,"two actual native player pawns exist");
        if(other==null || other==User)return;
        other.InitializeDirectMapCharacter();other.CharacterCreationComplete=true;other.CreationWizardOpen=false;
        other.ApplyCharacterProfile();other.bInvulnerable=true;other.bNOTARGET=true;
        int otherSerial=other.AttackAnimationSerial;double otherAir=other.CurrentAir,otherAnima=other.CurrentAnima;
        int otherId=other.ActiveWeaponItemId;
        User.PerformEquippedWeaponPrimaryAttack();
        Audit.Check(User.AttackAnimationSerial>serial,"explicit first pawn accepts its attack");
        Audit.Check(other.AttackAnimationSerial==otherSerial && other.CurrentAir==otherAir
            && other.CurrentAnima==otherAnima && other.ActiveWeaponItemId==otherId,
            "first pawn dispatch leaves other pawn resources and equipment untouched");
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c310_begin")Begin(e.Args[0],e.Args[1],e.Args[2]!=0);
        if(e.Name=="c310_end")End(e.Args[0]);
        if(e.Name=="c310_authority")Authority(e.Args[0]!=0);
        if(e.Name=="c310_health")User.health=e.Args[0];
        if(e.Name=="c310_switch_cast")
        {
            Audit.Check(User.StaffCastPending,"native magic preparation is pending before equipment change");
            double before=User.CurrentAnima;Audit.Equip(0,1,0,false,false);
            Audit.Check(!User.StaffCastPending && User.CurrentAnima==before,
                "changing the actual equipped item cancels the unpaid cast");
        }
        if(e.Name=="c310_death")
        {
            Tracing=false;User.bInvulnerable=false;
            User.DamageMobj(null,null,1000000,'None',DMG_FORCED,0);
            Audit.Check(User.health<=0,"native lethal damage kills the test pawn");
            DeathProjectiles=Projectiles;DeathSerial=User.AttackAnimationSerial;
            DeathAir=User.CurrentAir;DeathAnima=User.CurrentAnima;DeathWear=Audit.Item.Durability;
        }
        if(e.Name=="c310_dead_checked")
        {
            Audit.Check(User.health<=0 && Projectiles==DeathProjectiles && User.AttackAnimationSerial==DeathSerial,
                "dead pawn starts no further attack or projectile");
            Audit.Check(User.CurrentAir==DeathAir && User.CurrentAnima==DeathAnima && Audit.Item.Durability==DeathWear,
                "dead pawn neither spends resources nor wears its weapon");
            Console.Printf("CA310 DEATH physical=%d magic=%d serial=%d air=%.9f anima=%.9f shots=%d wear=%d",
                User.PhysicalAttackPending,User.StaffCastPending,User.AttackAnimationSerial,
                User.CurrentAir,User.CurrentAnima,Projectiles,Audit.Item.Durability);
        }
        if(e.Name=="c310_cancelled")Audit.Check(!User.PhysicalAttackPending && !User.StaffCastPending,
            "interrupted action has no pending commit");
        if(e.Name=="c310_no_hit")Audit.Check(Victim.Hits==0,"interruption before commit produces no target hit");
    }
}
