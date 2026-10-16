// #243: escenarios aislados; sin cambios de balance en producción.
class CA243Body : CaelumCombatActor
{
    int Received,ProjectileHits,PeriodicHits;
    override void Tick(){Vel=(0,0,0);Super.Tick();}
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        Received++;if(inflictor is "CaelumActorProjectile")ProjectileHits++;
        if(mod=='CaelumElementalDOT')PeriodicHits++;
        return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
    Default { Radius 16; Height 96; Mass 100; Health 100000; +SOLID +SHOOTABLE +NOGRAVITY +ISMONSTER }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA243Equipment : CA259Session
{override int Kind(){return Choice==9?CaelumConstants.WEAPON_TYPE_JAVELIN:Choice==10?CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS:Super.Kind();}}
class CA243Probe : StaticEventHandler
{
    CaelumPlayer User;
    CA243Body EnemyBody,FriendBody,FarBody,HiddenBody;
    int Passed,Failed,Marked,PreviousRemaining;
    CA243Equipment Equipment;
    Array<Actor> Seen;
    bool Watching,FlightTest;
    int Shots;
    Vector3 BeforePosition;
    bool Manual;
    int ManualKind;
    CaelumCombatActor ManualBody;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA243 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Stats()
    {
        User.DerivedStats.AnimaRegenerationPerSecond=0;
        User.DerivedStats.MaximumAnima=10000;
        User.DerivedStats.AnimaCostReductionPercent=0;
        User.DerivedStats.AbilityRangePercent=100;
        User.DerivedStats.DebuffPowerPercent=100;
        User.DerivedStats.PhysicalAccuracyPercent=100000;
        User.DerivedStats.MagicalAccuracyPercent=100000;
    }
    void Clear(Actor body)
    {let effect=CaelumBattleCry.Status(body);if(effect!=null)effect.Destroy();}
    void Reset()
    {
        CaelumClassAbilityRules.Cancel(User);Clear(User);CaelumSleepRules.Wake(User);
        User.ClassSleepInputLatched=false;User.ClassSleepCooldownRemaining=0;
        User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        User.CharacterProfile.FirstClass=User.CharacterProfile.SecondClass=CaelumConstants.CLASS_WARRIOR;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;
        User.ApplyCharacterProfile();Stats();User.CurrentAnima=1000;User.CurrentAir=1000;
        User.LucidityPhysicalStunRemaining=User.PainImmobilizationRemaining=0;
        User.ForcedSleepTics=0;User.CurrentSleep=100;User.CurrentLucidity=100;
        User.CombatChannelModeActive=false;User.EquipmentMenuOpen=false;User.bInvulnerable=true;
        User.player.ConversationNPC=null;User.player.ConversationPC=null;
        User.SetOrigin((0,0,0),false);User.Angle=0;User.Pitch=0;
        if(EnemyBody!=null)EnemyBody.Destroy();if(FriendBody!=null)FriendBody.Destroy();if(FarBody!=null)FarBody.Destroy();
        if(HiddenBody!=null)HiddenBody.Destroy();
        EnemyBody=CA243Body(Actor.Spawn("CA243Body",(256,0,0),NO_REPLACE));EnemyBody.ChangeTid(2430);
        FriendBody=CA243Body(Actor.Spawn("CA243Body",(256,256,0),NO_REPLACE));FriendBody.bFriendly=true;
        FarBody=CA243Body(Actor.Spawn("CA243Body",(1600,-512,0),NO_REPLACE));
        HiddenBody=CA243Body(Actor.Spawn("CA243Body",(256,800,0),NO_REPLACE));
    }
    void Contracts()
    {
        Check(CaelumClassAbilityRules.CanCast(User),"Warrior can begin shared preparation");
        Check(!CaelumSleepRules.CanCast(User),"Sleep admission still requires Arcanist");
        CaelumBattleCry.Release(User);
        Check(CaelumBattleCry.Active(EnemyBody),"visible enemy receives effect");
        Check(!CaelumBattleCry.Active(FriendBody) && !CaelumBattleCry.Active(FarBody) && !CaelumBattleCry.Active(User),"allies outside-radius and caster excluded");
        Check(!User.CheckSight(HiddenBody,SF_IGNOREVISIBILITY) && !CaelumBattleCry.Active(HiddenBody),"native solid wall excludes hidden enemy");
        Check(CaelumBattleCry.Status(EnemyBody).RemainingTics==350,"base effect is ten seconds");
        CaelumBattleCry.Apply(EnemyBody,10);Check(CaelumBattleCry.Status(EnemyBody).RemainingTics==350,"shorter renewal does not shorten or add");
        CaelumBattleCry.Apply(EnemyBody,700);Check(CaelumBattleCry.Status(EnemyBody).RemainingTics==700,"longer renewal replaces remaining time");
        Check(!EnemyBody.WithinAttackRange(false) && !EnemyBody.WithinAttackRange(true),"melee and magical execution reject intimidation");
        Check(!EnemyBody.BeginCaelumDiagnosticAttack(),"shared NPC attack path rejects intimidation");
        EnemyBody.SetOrigin((2000,0,0),false);Check(CaelumBattleCry.Active(EnemyBody),"effect remains outside original area");
        Clear(EnemyBody);EnemyBody.SetOrigin((256,0,0),false);
        User.DerivedStats.DebuffPowerPercent=200;CaelumBattleCry.Release(User);
        Check(CaelumBattleCry.Status(EnemyBody).RemainingTics==700,"Charisma harmful power scales duration");Stats();Clear(EnemyBody);
        User.DerivedStats.AbilityRangePercent=200;CaelumBattleCry.Release(User);
        Check(CaelumBattleCry.Active(FarBody),"Eloquence range reaches farther visible enemy");Stats();Clear(FarBody);
        CaelumBattleCry.Apply(User,70);
        Check(!CaelumClassAbilityRules.CanCast(User) && !User.BeginPhysicalAttackCycle(false),"recipient cannot start offensive class or physical attack");
        Check(!User.CanStartSealChannel(),"recipient cannot start Seal channel");
        Check(!CaelumTelekinesisEffect(new("CaelumTelekinesisEffect")).CanStart(User),"recipient cannot start Telekinesis");
        Check(!User.IsPhysicallyImmobilized(),"intimidation does not immobilize recipient");
        Clear(User);
    }
    void Arm(int kind)
    {
        Clear(User);User.CurrentAnima=10000;User.CurrentAir=10000;
        Equipment=new("CA243Equipment");Equipment.Choice=kind;Equipment.Tier=1;Equipment.Equip(User);
        User.SetRangedMagazineCount(Equipment.Kind(),User.GetRangedMagazineCapacity(Equipment.Kind()));
        Observe();
    }
    void Observe()
    {
        Watching=false;let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile shot;
        while((shot=CaelumActorProjectile(it.Next()))!=null)if(shot.Target==User)shot.Destroy();
        Shots=0;Seen.Clear();Watching=true;if(EnemyBody!=null)EnemyBody.Received=0;
        User.CurrentAnima=10000;User.CurrentAir=10000;
        if(Equipment!=null)User.SetRangedMagazineCount(Equipment.Kind(),User.GetRangedMagazineCapacity(Equipment.Kind()));
    }
    void Boundaries()
    {
        Arm(10);
        User.PhysicalAttackPending=true;User.StaffCastPending=true;User.PendingStaffAnimaCost=100;
        User.WeaponChargeActive=true;User.ClassCastActive=true;
        User.ClassCastProfession=CaelumConstants.PROFESSION_WARRIOR;User.ClassPreparationTics=80;
        User.ClassCastPaid=125;double anima=User.CurrentAnima;
        let channel=CaelumChannelEffect(Actor.Spawn("CaelumChannelEffect",User.Pos,NO_REPLACE));
        channel.ChannelOwner=User;channel.SealType=CaelumConstants.SEAL_QUINTESSENCE;channel.TrappedMass=1000;
        channel.EffectRadius=1280;User.CombatChannelModeActive=true;User.CombatChannelEffectActor=channel;
        EnemyBody.Vel=(0,0,0);
        let binding=CaelumTelekinesisEffect(new("CaelumTelekinesisEffect"));
        binding.Caster=User;binding.Body=EnemyBody;binding.MapName=level.MapName;
        User.RacialAbility=binding;User.RacialAbilityActive=true;CaelumTelekinesisRules.Bind(EnemyBody,binding);
        CaelumBattleCry.Apply(User,700);
        Check(!User.PhysicalAttackPending && !User.StaffCastPending && !User.WeaponChargeActive && !User.ClassCastActive,"preparing attacks and offensive class cancel immediately");
        Check(User.ClassCastPaid==125 && User.CurrentAnima==anima,"interruption does not refund paid preparation");
        Check(!User.CombatChannelModeActive && User.CombatChannelEffectActor==null && EnemyBody.Vel.Length()==0,"Seal channel stops without Quintessence release attack");
        Check(User.RacialAbility==null && !CaelumTelekinesisRules.Held(EnemyBody),"active Telekinesis releases its held body");
        User.CancelCombatBlockMode();Check(User.CanEnterCombatBlockMode(),"weapon defense remains eligible");
        User.ToggleCombatBlockMode();Check(User.CombatBlockModeActive,"defense still activates while intimidated");User.CancelCombatBlockMode();
        let record=User.GetPersistentCharacterState(true);CaelumTarotService.EnsureRevision(record);
        for(int i=0;i<CaelumConstants.TAROT_CARD_COUNT;i++)record.TarotSelected[i]=false;
        record.TarotOwned[CaelumConstants.TAROT_THE_FOOL]=true;record.TarotSelected[CaelumConstants.TAROT_THE_FOOL]=true;
        record.TarotCooldownTics=record.TarotEffectTics=0;
        Check(CaelumTarotService.Activate(User),"implemented Tarot flight remains a permitted nonattack");
        EnemyBody.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_POISON,10,100,1000,User,EnemyBody);
        EnemyBody.Received=EnemyBody.ProjectileHits=EnemyBody.PeriodicHits=0;
        BeforePosition=User.Pos;
    }
    void NPCContracts()
    {
        static const Name kinds[]={"CaelumGiantRat","CaelumBull","CaelumMandinga","CaelumZupayColossus"};
        for(int i=0;i<4;i++)
        {
            let npc=CaelumCombatActor(Actor.Spawn(kinds[i],(-512-i*256,-512,0),NO_REPLACE));
            npc.bDormant=true;npc.CaelumDiagnosticPassiveAI=true;
            let victim=CA243Body(Actor.Spawn("CA243Body",npc.Pos+(32,0,0),NO_REPLACE));
            npc.target=victim;npc.CurrentCombatAir=100000;npc.CurrentCombatAnima=100000;
            npc.CombatDexterity=1000;npc.CombatInsight=1000;
            double air=npc.CurrentCombatAir;
            npc.A_CaelumMeleeAttack(100);
            Check(npc.CurrentCombatAir<air,"real creature melee executes before intimidation");
            int calls=victim.Received;air=npc.CurrentCombatAir;
            Check(CaelumBattleCry.Apply(npc,350),"creature or boss accepts intimidation without immunity");
            npc.A_CaelumMeleeAttack(100);
            Check(victim.Received==calls && npc.CurrentCombatAir==air,"creature melee neither impacts nor spends while intimidated");
            Clear(npc);npc.target=victim;npc.A_CaelumMeleeAttack(100);
            Check(npc.CurrentCombatAir<air,"real creature melee resumes after intimidation");
            if(i>=2)
            {
                npc.CurrentCombatAnima=100000;double anima=npc.CurrentCombatAnima;
                npc.A_CaelumSpawnSimpleElementalProjectile("CaelumActorSimpleElementalProjectile",npc.Height*0.65,100,CaelumConstants.ESSENCE_FIRE);
                Check(npc.CurrentCombatAnima<anima,"real demon magic executes before intimidation");
                CaelumBattleCry.Apply(npc,350);anima=npc.CurrentCombatAnima;
                npc.A_CaelumSpawnSimpleElementalProjectile("CaelumActorSimpleElementalProjectile",npc.Height*0.65,100,CaelumConstants.ESSENCE_FIRE);
                Check(npc.CurrentCombatAnima==anima,"real demon magic spends nothing while intimidated");Clear(npc);
                npc.A_CaelumSpawnSimpleElementalProjectile("CaelumActorSimpleElementalProjectile",npc.Height*0.65,100,CaelumConstants.ESSENCE_FIRE);
                Check(npc.CurrentCombatAnima<anima,"real demon magic resumes after intimidation");
                npc.CaelumDiagnosticPassiveAI=false;CaelumDemonService.UpdateBreath(npc);
                Check(npc.DemonBreath!=null,"actual demon channel starts normally");
                CaelumBattleCry.Apply(npc,350);anima=npc.CurrentCombatAnima;CaelumDemonService.UpdateBreath(npc);
                Check(npc.DemonBreath==null && npc.CurrentCombatAnima==anima,"intimidation stops demon channel and its further payments");
            }
            let bull=CaelumBull(npc);
            if(bull!=null)
            {
                Clear(bull);bull.BeginBullCharge();Check(bull.BullChargeActive,"Bull starts actual charge");
                CaelumBattleCry.Apply(bull,350);Check(!bull.BullChargeActive,"intimidation interrupts ongoing Bull charge");
                bull.BeginBullCharge();Check(!bull.BullChargeActive,"intimidated Bull cannot restart charge");
            }
            npc.Destroy();victim.Destroy();
        }
    }
    void SiegeContracts()
    {
        let gun=CaelumCannon(Actor.Spawn("CaelumCannon",(-2048,-2048,0),NO_REPLACE));gun.InitializeCannon(true);
        gun.Armed=true;gun.Phase=gun.LOADED;gun.Ammunition=10;
        let op=CA243Body(Actor.Spawn("CA243Body",gun.Pos+(0,64,0),NO_REPLACE));op.bFriendly=true;gun.Operators.Push(op);
        Check(gun.RequestShot(gun.Pos+(1024,0,64)),"staffed cannon accepts native shot request");gun.Fire();
        Check(gun.Shots==1 && gun.ActiveShot!=null,"cannon actually fires with eligible operator");
        CaelumBattleCry.Apply(op,350);
        Check(gun.OperatorsPresent()==1 && gun.OperatorsPresent(true)==0,"intimidated operator remains available only for nonattack work");
        Check(!gun.RequestShot(gun.Pos+(1024,0,64)),"intimidated crew cannot request another shot");gun.Fire();
        Check(gun.Shots==1 && gun.ActiveShot!=null,"intimidation preserves existing cannon shot without launching another");
        let other=CA243Body(Actor.Spawn("CA243Body",gun.Pos+(0,-64,0),NO_REPLACE));other.bFriendly=true;gun.Operators.Push(other);
        Check(gun.OperatorsPresent(true)==1 && gun.RequestShot(gun.Pos+(1024,0,64)),"remaining eligible operator retains cannon's original one-operator minimum");
        let ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",(2048,-2048,0),NO_REPLACE));ram.InitializeRam();ram.Enabled=true;
        for(int i=0;i<ram.RequiredCrew;i++)
        {
            let body=CA243Body(Actor.Spawn("CA243Body",ram.Pos+(0,64+i*32,0),NO_REPLACE));
            let entry=CaelumSiegeCombatant(new("CaelumSiegeCombatant"));entry.Body=body;ram.Crew.Push(entry);
        }
        Check(ram.FullCrewPresent() && ram.FullCrewPresent(true),"full ram crew initially permits work and attack");
        CaelumBattleCry.Apply(ram.Crew[0].Body,350);ram.Phase=ram.STRIKE;ram.Tick();
        Check(ram.FullCrewPresent() && !ram.FullCrewPresent(true),"ram preserves nonattack staffing while excluding intimidated attacker");
        Check(ram.Phase==ram.RECOVERY && ram.ImpactCount==0,"ongoing ram strike cancels without delivering impact");
        ram.Crew[ram.Crew.Size()-1].Body.SetOrigin((3000,3000,0),false);ram.Phase=ram.STRIKE;ram.Tick();
        Check(!ram.FullCrewPresent() && ram.Phase==ram.RECOVERY && ram.ImpactCount==0,"absent crew member cannot leave an intimidated ram strike pending");
    }
    void ManualReset()
    {
        Manual=true;Reset();Arm(10);User.CurrentAnima=1000;
        EnemyBody.Destroy();EnemyBody=null;FriendBody.Destroy();FriendBody=null;
        FarBody.Destroy();FarBody=null;HiddenBody.Destroy();HiddenBody=null;
        if(ManualBody!=null)ManualBody.Destroy();
        static const Name kinds[]={"CaelumMandinga","CaelumGiantRat","CaelumBull","CaelumZupayColossus"};
        ManualBody=CaelumCombatActor(Actor.Spawn(kinds[ManualKind],(800,0,0),NO_REPLACE));
        ManualBody.target=User;ManualBody.bBuddha=true;
        ManualBody.CurrentCombatAir=ManualBody.CurrentCombatAnima=100000;
        ManualBody.SetState(ManualBody.SeeState);Watching=false;
        Console.Printf("CA243 MANUAL ready creature=%s",ManualBody.GetClassName());
    }
    override void RenderOverlay(RenderEvent e)
    {
        let user=CaelumPlayer(players[consoleplayer].mo);if(!Manual || user==null)return;
        let own=CaelumBattleCryEffect(user.FindInventory("CaelumBattleCryEffect"));
        let foe=ManualBody==null?null:CaelumBattleCryEffect(ManualBody.FindInventory("CaelumBattleCryEffect"));
        String line=String.Format("Grito: prepara %.1fs | Anima %.0f | Reutilizacion %.1fs",user.ClassPreparationTics/35.0,user.CurrentAnima,user.ClassSleepCooldownRemaining);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,8,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        String kind="-";if(ManualBody!=null)kind=String.Format("%s",ManualBody.GetClassName());
        line=String.Format("Intimidado: tu %.1fs | enemigo %.1fs (%s)",own==null?0:own.RemainingTics/35.0,foe==null?0:foe.RemainingTics/35.0,kind);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,20,line,DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,32,"F lanzar/cancelar | F6 reiniciar | F7 intimidarte | F8 arma | F9 criatura",DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(SmallFont,Font.CR_WHITE,88,44,"Ensayo: invulnerable, enemigo inmortal, radio 40m, duracion 10s. B bloquear.",DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
    override void WorldTick()
    {
        if(User==null)return;Stats();if(Manual && ManualBody!=null)
            ManualBody.CurrentCombatAir=ManualBody.CurrentCombatAnima=100000;
        if(!Watching)return;
        let it=ThinkerIterator.Create("CaelumActorProjectile");CaelumActorProjectile shot;
        while((shot=CaelumActorProjectile(it.Next()))!=null)
            if(shot.Target==User && Seen.Find(shot)>=Seen.Size())
            {
                Seen.Push(shot);Shots++;
                if(FlightTest){shot.Vel*=0.1;CaelumBattleCry.Apply(User,700);}
            }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumPlayer(players[e.Player].mo);if(User==null)return;
        if(e.Name=="c243_setup")Reset();
        if(e.Name=="c243_manual")ManualReset();
        if(e.Name=="c243_next"){ManualKind=(ManualKind+1)%4;ManualReset();}
        if(e.Name=="c243_self")CaelumBattleCry.Apply(User,350);
        if(e.Name=="c243_weapon")
        {Arm(Equipment.Choice==10?0:10);User.CurrentAnima=1000;Watching=false;}
        if(e.Name=="c243_manual_check")
        {
            Check(ManualBody!=null && CaelumBattleCry.Active(ManualBody),"native User4 intimidates autonomous creature");
            Check(ManualBody.DemonBreath==null && !ManualBody.InStateSequence(ManualBody.CurState,ManualBody.MeleeState)
                && !ManualBody.InStateSequence(ManualBody.CurState,ManualBody.MissileState),"autonomous enemy leaves all attack states while intimidated");
            BeforePosition=ManualBody.Pos;
        }
        if(e.Name=="c243_manual_walk")Check((ManualBody.Pos-BeforePosition).Length()>1 && CaelumBattleCry.Active(ManualBody),"autonomous intimidated enemy keeps moving");
        if(e.Name=="c243_dead_caster")
        {User.health=0;Check(CaelumBattleCry.Active(ManualBody),"caster death does not clear recipient status");}
        if(e.Name=="c243_contract")Contracts();
        if(e.Name=="c243_boundaries")Boundaries();
        if(e.Name=="c243_npcs")NPCContracts();
        if(e.Name=="c243_siege")SiegeContracts();
        if(e.Name=="c243_moved")Check((User.Pos-BeforePosition).Length()>1,"native movement continues while intimidated");
        if(e.Name=="c243_retained")
            Check(EnemyBody.PeriodicHits>0,"already applied periodic damage continues");
        if(e.Name=="c243_flight"){Observe();FlightTest=true;EnemyBody.ProjectileHits=0;}
        if(e.Name=="c243_flight_check")Check(Shots==1 && CaelumBattleCry.Active(User) && EnemyBody.ProjectileHits>0,"native projectile already released still impacts after source intimidation");
        if(e.Name=="c243_melee_position"){EnemyBody.SetOrigin((56,0,0),false);User.Pitch=0;Observe();}
        if(e.Name=="c243_unarmed")
        {
            User.EquipmentSelectionItemId=Equipment.TestItem.ItemId;User.RefreshEquipmentSelectionPreview();
            User.UnequipSelectedNativeEquipment();User.EnsureUnarmedFallback();User.player.PendingWeapon=Weapon(User.FindInventory("CaelumUnarmedWeapon"));Observe();
        }
        if(e.Name=="c243_melee_hits")
        {Check(e.Args[0]!=0 ? EnemyBody.Received>0 : EnemyBody.Received==0,"native melee impact before during or after intimidation");Console.Printf("CA243 MELEE actual=%d expected-positive=%d",EnemyBody.Received,e.Args[0]);}
        if(e.Name=="c243_arm")Arm(e.Args[0]);
        if(e.Name=="c243_block"){CaelumBattleCry.Apply(User,350);Observe();}
        if(e.Name=="c243_unblock"){Clear(User);Observe();}
        if(e.Name=="c243_shots")
        {
            Check(e.Args[0]==0 ? Shots==0 : Shots==e.Args[0],"native weapon projectile count before during or after intimidation");
            Console.Printf("CA243 SHOTS actual=%d expected=%d",Shots,e.Args[0]);Watching=false;
        }
        if(e.Name=="c243_save_effect")
        {
            CaelumBattleCry.Apply(User,700);CaelumBattleCry.Apply(EnemyBody,700);
            Check(CaelumBattleCry.Active(User) && CaelumBattleCry.Active(EnemyBody),"save contains player and NPC effects");
        }
        if(e.Name=="c243_loaded_effect")
        {
            EnemyBody=CA243Body(ActorIterator.Create(2430).Next());
            Check(CaelumBattleCry.Active(User) && CaelumBattleCry.Active(EnemyBody),"save reload restores both recipients");
            let effect=CaelumBattleCry.Status(User);
            Check(effect!=null && effect.Revision==1 && effect.Owner==User && effect.RemainingTics<700,"saved inventory retains schema owner and elapsed time");
            PreviousRemaining=effect==null?0:effect.RemainingTics;
        }
        if(e.Name=="c243_saved_clock")
        {let effect=CaelumBattleCry.Status(User);Check(effect!=null && PreviousRemaining-effect.RemainingTics==35,"loaded effect charges one duration tic per simulation tic");}
        if(e.Name=="c243_hub")Check(CaelumBattleCry.Active(User),"native hub travel retains player prohibition");
        if(e.Name=="c243_hub_return")
        {EnemyBody=CA243Body(ActorIterator.Create(2430).Next());Check(CaelumBattleCry.Active(User) && CaelumBattleCry.Active(EnemyBody),"hub return restores original NPC and player effects");}
        if(e.Name=="c243_loaded_prep")
        {
            EnemyBody=CA243Body(ActorIterator.Create(2430).Next());
            Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000 && User.ClassCastProfession==CaelumConstants.PROFESSION_WARRIOR,"saved preparation resumes paid Warrior cast");
        }
        if(e.Name=="c243_mark"){Clear(EnemyBody);CaelumBattleCry.Apply(EnemyBody,70);Marked=level.time;}
        if(e.Name=="c243_tick")
        {let effect=CaelumBattleCry.Status(EnemyBody);Check(effect!=null && effect.RemainingTics==70-(level.time-Marked),"native inventory clock advances once per tic");}
        if(e.Name=="c243_expired")Check(!CaelumBattleCry.Active(EnemyBody) && CaelumBattleCry.Status(EnemyBody)==null,"native expiry clears effect without residue");
        if(e.Name=="c243_preparing")Check(User.ClassCastActive && User.ClassCastPaid>0 && User.ClassCastPaid<1000 && User.ClassSleepCooldownRemaining==0,"native partial preparation pays without starting cooldown");
        if(e.Name=="c243_cancelled")Check(!User.ClassCastActive && User.CurrentAnima<1000 && User.ClassSleepCooldownRemaining==0,"native second press cancels without refund or cooldown");
        if(e.Name=="c243_released")Check(!User.ClassCastActive && Abs(User.ClassCastPaid-1000)<1e-6 && User.ClassSleepCooldownRemaining>59 && CaelumBattleCry.Active(EnemyBody),"native release pays full cost applies effect and starts reuse");
        if(e.Name=="c243_done")Console.Printf("CA243 DONE failures=%d passed=%d",Failed,Passed);
    }
}
