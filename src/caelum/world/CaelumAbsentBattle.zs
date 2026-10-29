// #415: una fila por participante real, guardada con su encuentro de mapa.
// Las fracciones de dano y desgaste sobreviven a viajes y guardados.
class CaelumAbsentCombatant : Object play
{
    CaelumAbsentBattle Battle;
    CaelumCombatActor Body;
    CaelumAbsentCombatant Opponent;
    CaelumAbsentAttack Attack;
    CaelumThermalState Thermal;
    Actor Killer;
    int Identity,Shots;
    bool Friendly,Retreated,Preparing,Recovering,RoundShield,Participating;
    double RoundFacing,NextFacing;
    double Remaining,LifeFraction,ArmorFraction[4],ShieldFraction,SwordFraction,GunFraction,ActiveTicFraction;
    double PendingLife,PendingArmor[4],PendingShield,PendingSword,PendingGun,PendingLucidity;
    double PendingFire,PendingFirePower;
    double PendingHeat,PendingActionHeat;
    CaelumCombatActor FireSource;
    double PainRemaining;
    double PendingWakeHits,SleepHitFraction;
    CaelumSpellSleepState SleepHitState;
    State CapturedPose;
    bool CapturedPreparation;
    double CapturedFrame,CapturedReleaseClock,CapturedCycleClock,ActionHold;
    bool PendingSelfFire;
    Array<CaelumCombatActor> BreathSources;
    Array<double> BreathWatts;
    int SpatialNext,SpatialX,SpatialY;
    bool TravelingResident,NativeResumePending;
    int ResidentIdentity;
    int RosterKind,RosterIndex;

    bool Alive(){return Participating && Body!=null && !Body.bDestroyed && Body.health>0 && !Retreated;}
    bool Enemy(CaelumAbsentCombatant other)
    {return other!=null && other!=self && other.Battle==Battle && other.Alive() && other.Friendly!=Friendly;}

    void Capture()
    {
        if(Battle!=null)Battle.TargetCacheReady=false;
        Participating=true;
        Friendly=Body.bFriendly;Recovering=Body.RecoveryPhase!=0;
        let entry=Body.SiegeCombatant;
        if(entry!=null && entry.Encounter==Battle.Encounter){RosterKind=1;RosterIndex=entry.StableIdentity;}
        Retreated=entry!=null && entry.Exited;
        State pose=Body.CurState;int poseTics=Body.tics;
        let sleep=CaelumSleepRules.Status(Body);
        if(sleep!=null && sleep.SavedState!=null){pose=sleep.SavedState;poseTics=sleep.SavedTics;}
        PainRemaining=Body.FindState('Pain')!=null && Body.InStateSequence(pose,Body.FindState('Pain'))
            ?Max(0,poseTics)/double(TICRATE):0;
        bool melee=Body.MeleeState!=null && Body.InStateSequence(pose,Body.MeleeState);
        bool ranged=Body.MissileState!=null && Body.InStateSequence(pose,Body.MissileState);
        if(Attack==null)Attack=new('CaelumAbsentAttack');
        Thermal=CaelumThermalService.CaptureForecast(Body);
        Preparing=false;Remaining=0;CapturedPreparation=false;ActionHold=0;
        let soldier=CaelumPortDefender(Body);
        TravelingResident=soldier!=null && soldier.Residence!=null && !soldier.Residence.Delegated;
        ResidentIdentity=TravelingResident?soldier.HomeIdentity:-1;
        if(soldier!=null && soldier.Carbine!=null && soldier.Carbine.Held && soldier.Carbine.NextShotTic>level.time)
            Remaining=double(soldier.Carbine.NextShotTic-level.time)/TICRATE;
        else if((melee || ranged) && Attack.Configure(Body,ranged))
        {
            State recovery=(ranged?Body.FindState('AbsentMagicRecovery'):Body.FindState('AbsentMeleeRecovery'));
            if(Attack.Kind==CaelumAbsentAttack.SLAM)
            {Preparing=pose!=recovery;Remaining=Max(0,poseTics)/double(TICRATE);ClearPending();return;}
            int elapsed=Max(0,level.time-Body.WeaponCycleStartTic);
            Preparing=pose!=recovery;
            double fraction=Attack.Kind==CaelumAbsentAttack.EXPLOSIVE?CaelumAttackRules.ZUPAY_MAGIC_RELEASE
                :Attack.Kind==CaelumAbsentAttack.MAGIC?CaelumAttackRules.MANDINGA_MAGIC_RELEASE
                :Body is 'CaelumMandinga'?CaelumAttackRules.MANDINGA_MELEE_RELEASE:CaelumAttackRules.SWING_IMPACT;
            Attack.NativeCycleTics=Body.WeaponCycleTics;Attack.Cycle=Ceil(Body.WeaponCycleTics)/TICRATE;
            Attack.Preparation=Ceil(Body.WeaponCycleTics*fraction)/TICRATE;
            Remaining=Max(0,poseTics)/double(TICRATE);
            if(Preparing)
            {
                // El sueño y las cuerdas congelan la pose, no el reloj de sus
                // límites posteriores. Conserva ambos sin repetir la entrada.
                CapturedPreparation=true;CapturedPose=pose;CapturedFrame=Remaining;
                CapturedReleaseClock=Attack.Preparation-double(elapsed)/TICRATE;
                CapturedCycleClock=Attack.Cycle-double(elapsed)/TICRATE;
                if(Attack.Kind==CaelumAbsentAttack.EXPLOSIVE)Remaining=Max(Remaining,CapturedReleaseClock);
            }
        }
        ClearPending();
    }

    void ClearPending()
    {
        PendingWakeHits=0;
        PendingLife=PendingShield=PendingSword=PendingGun=PendingLucidity=PendingFire=PendingFirePower=0;
        Killer=null;FireSource=null;PendingHeat=PendingActionHeat=0;
        PendingSelfFire=false;BreathSources.Clear();BreathWatts.Clear();
        for(int i=0;i<4;i++)PendingArmor[i]=0;
    }

    void Choose()
    {
        if(Enemy(Opponent))return;
        Opponent=Battle.FirstOpponent(Friendly);
    }

    bool Blocking(CaelumCombatActor source)
    {
        let soldier=CaelumPortDefender(Body);
        if(soldier==null || soldier.Shield==null || soldier.Shield.Durability<=0 || source==null)return false;
        return RoundShield
            && Abs(Body.DeltaAngle(RoundFacing,Body.AngleTo(source)))<=soldier.Shield.GetCoverageDegrees()/2;
    }

    void BeginRound()
    {
        if(!Alive())return;
        let soldier=CaelumPortDefender(Body);
        RoundFacing=NextFacing=Body.Angle;
        RoundShield=!Preparing && (soldier==null || soldier.Carbine==null || !soldier.Carbine.Held);
    }

    void Queue(CaelumAbsentCombatant source,CaelumAbsentDamage result)
    {
        if(result==null)return;
        PendingLife+=result.Life;PendingShield+=result.ShieldWear;PendingLucidity+=result.Lucidity;
        PendingWakeHits+=result.DamagingHitProbability;
        PendingHeat+=result.ThermalJoules;
        for(int i=0;i<4;i++)PendingArmor[i]+=result.ArmorWear[i];
        if(source!=null)
        {
            if(Killer==null && LifeFraction+PendingLife>=Body.health)Killer=source.Body;
            if(source.Attack.Kind==CaelumAbsentAttack.CARBINE)source.PendingGun+=result.WeaponWear;
            else source.PendingSword+=result.WeaponWear;
            if(result.FireDose>0 && (PendingFire<=0 || source.Attack.Debuff>PendingFirePower))
            {PendingFire=result.FireDose;PendingFirePower=source.Attack.Debuff;FireSource=source.Body;}
        }
    }

    void QueueMachine(Actor source,CaelumAbsentDamage result)
    {
        Queue(null,result);
        if(Killer==null && LifeFraction+PendingLife>=Body.health)Killer=source;
    }

    void Recover(double seconds)
    {
        if(!Alive())return;
        bool idle=Recovering && Body.RecoveryPhase==2;
        double factor=idle?CaelumRestRules.CHAIR_RESOURCE_FACTOR:1;
        Body.CurrentCombatAnima=Min(Body.MaximumCombatAnima,Body.CurrentCombatAnima+Body.CombatAnimaRegenerationPerSecond*factor*seconds);
        if(!Body.CombatAirSpending)
            Body.CurrentCombatAir=Min(Body.MaximumCombatAir,Body.CurrentCombatAir+Body.CombatAirRegenerationPerSecond*factor
                *CaelumBreathing.ActorFactor(Body)*CaelumAltitudeService.Recovery(Body)*seconds);
        Body.UpdateActorLucidityState();
        if(Recovering && Body.CurrentCombatAir>=Body.MaximumCombatAir && Body.CurrentCombatAnima>=Body.MaximumCombatAnima)
        {Recovering=false;Body.EndResourceRecovery();}
        let soldier=CaelumPortDefender(Body);
        if(soldier!=null && soldier.Carbine!=null && soldier.Carbine.ReloadRemaining>0)
        {
            let gun=soldier.Carbine;
            CaelumThermalEffects.RecordReloadProgress(Body,Min(gun.ReloadRemaining,seconds),gun.ReloadTotal);
            gun.ReloadRemaining=Max(0,gun.ReloadRemaining-seconds);
            if(gun.ReloadRemaining<=0)
            {gun.Magazine=CaelumRangedRules.MagazineCapacity(gun.Weapon.WeaponType);gun.ReloadCount++;}
        }
    }

    void Physiology(double worldEnd,double activeSeconds)
    {
        if(!Alive())return;
        let absent=Body.ContaminationAbsence;
        if(Thermal!=null && absent!=null && absent.Away)
        {
            ThermalStep(Max(0,worldEnd-absent.Stamp),activeSeconds,absent);
            if(Body.health<=0){absent.Life=Body.health;FinishRound();return;}
        }
        if(absent!=null && absent.Away)
        {
            absent.Idle=!Battle.Engaged || (Recovering && Body.RecoveryPhase==2);
            absent.Life=Body.health;absent.SyncTo(Body,worldEnd);Body.health=absent.Life;
        }
        if(Body.health<=0){FinishRound();return;}
        let effects=Body.ElementalStatus;
        if(effects!=null)
        {
            effects.Advance(Body,activeSeconds);
        }
        let support=CaelumSupportMagic.Status(Body);
        if(support!=null && Body.health>0)support.Advance(activeSeconds);
        if(Body.health<=0){FinishRound();return;}
        Body.CombatLucidityPhysicalStunRemaining=Max(0,Body.CombatLucidityPhysicalStunRemaining-activeSeconds);
        if(Body.CombatTimeRemaining>0)Body.CombatTimeRemaining=Max(0,Body.CombatTimeRemaining-activeSeconds);
        else if(!CaelumSiegeFocus.ApplyToActor(Body))
            Body.CurrentCombatAdrenaline=Max(0,Body.CurrentCombatAdrenaline-CaelumConstants.ADRENALINE_DECAY_PER_SECOND*activeSeconds);
        ActiveTicFraction+=activeSeconds*TICRATE;
        int ticks=int(ActiveTicFraction+0.000000001);ActiveTicFraction=Max(0,ActiveTicFraction-ticks);
        int asleep=CaelumSleepRules.AdvanceNPCSleep(Body,ticks);
        ActionHold=Min(activeSeconds,asleep/double(TICRATE)+PainRemaining);
        if(CapturedPreparation){CapturedReleaseClock-=activeSeconds;CapturedCycleClock-=activeSeconds;}
        Body.CurrentCombatLucidity=Min(CaelumConstants.MAXIMUM_LUCIDITY,Body.CurrentCombatLucidity
            +CaelumConstants.MAXIMUM_LUCIDITY/CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS/TICRATE*(ticks-asleep));
        Body.UpdateActorLucidityState();
        PainRemaining=Max(0,PainRemaining-Max(0,activeSeconds-asleep/double(TICRATE)));
        let binding=CaelumBolas.Binding(Body);
        if(binding!=null && binding.Phase==1)
        {
            binding.Victim=Body;
            bool interrupted=PainRemaining>0 || Body.CombatLucidityPhysicalStunRemaining>0
                || CaelumTelekinesisRules.Held(Body) || (Body.ElementalStatus!=null && Body.ElementalStatus.IsLightningStunned());
            for(int i=0;i<ticks && binding!=null && !binding.bDestroyed && binding.Phase==1;i++)
                binding.AdvanceRestraint(interrupted || i<asleep);
        }
        let cry=CaelumBattleCry.Status(Body);
        if(cry!=null){cry.RemainingTics=Max(0,cry.RemainingTics-ticks);if(cry.RemainingTics<=0)cry.Destroy();}
        // Recorre solamente el inventario propio; las dosis y sus tres
        // familias siguen siendo los Powerup originales, no otro contador.
        for(Inventory item=Body.Inv;item!=null;)
        {
            Inventory next=item.Inv;
            let dose=CaelumRegenerationPower(item);if(dose!=null)dose.AdvanceAbsent(ticks);
            item=next;
        }
        CaelumDemonService.UpdatePotions(Body);
        if(absent!=null)absent.Life=Body.health;
    }

    void ThermalStep(double worldSeconds,double activeSeconds,CaelumContaminationAbsence absent)
    {
        if(Thermal==null || worldSeconds<=0 || activeSeconds<=0)return;
        let live=CaelumThermalBody.Get(Body,true);
        if(live==null)return;
        Thermal.Exposure=live.Exposure;
        CaelumThermalBody.Refresh(Body,Thermal);
        let climate=absent.Climate;
        if(climate!=null && climate.Ready)
        {
            climate.Rate(absent.Civil+worldSeconds/2);
            let sample=climate.Local;
            if(sample!=null && sample.Available)
            {
                Thermal.AirC=sample.AirTemperatureC+climate.HeatDelta;Thermal.ClimateC=Thermal.AirC;
                Thermal.Humidity=Clamp(sample.RelativeHumidityPercent+climate.HumidityDelta,0.0,100.0);
                Thermal.RainMmHour=Thermal.Roof?0:sample.PrecipitationMmPerHour;
                Thermal.WindMps=sample.WindSpeedKmh/3.6;
            }
        }
        for(int slot=0;slot<4;slot++)Thermal.Material[slot]=CaelumThermalBody.Material(Body,slot);
        double burn=Body.ElementalStatus!=null?Body.ElementalStatus.TakeBurnHeat()/activeSeconds:0;
        double dose=CaelumThermalService.Integrate(Thermal,worldSeconds,activeSeconds,
            live.PendingActivityJoules/activeSeconds,burn,Thermal.FireWatts,0,live.PendingFirearmJoules/activeSeconds);
        live.PendingActivityJoules=live.PendingFirearmJoules=0;
        CaelumThermalService.ApplyDamage(Body,Thermal,dose);
        CaelumThermalService.CommitForecast(Body,Thermal);
        live.DamageRemainder=Thermal.DamageRemainder;live.DrinkRemaining=Thermal.DrinkRemaining;
    }

    void ResumeNative()
    {
        NativeResumePending=false;
        if(!Alive())return;
        Choose();Body.target=Opponent!=null?Opponent.Body:null;
        if(CapturedPreparation)
        {
            Body.WeaponCycleTics=Attack.NativeCycleTics;
            Body.WeaponCycleStartTic=level.time-int(Floor((Attack.Cycle-CapturedCycleClock)*TICRATE+0.5));
            if(Body.ForcedSleepTics<=0)
            {Body.SetState(CapturedPose,true);Body.tics=Max(1,int(Ceil(CapturedFrame*TICRATE)));return;}
        }
        if(Body.ForcedSleepTics>0){CaelumSleepRules.MaintainPose(Body);return;}
        if(PainRemaining>0 && Body.FindState('Pain')!=null)
        {Body.SetState(Body.FindState('Pain'),true);Body.tics=Max(1,int(Ceil(PainRemaining*TICRATE)));return;}
        if(Body.DemonBreath!=null){Body.SetState(Body.FindState('RacialBreath'),true);return;}
        if(Recovering)
        {Body.SetState(Body.RecoveryPhase==2?Body.SpawnState:Body.FindState('ResourceRetreat'),true);return;}
        if(Attack==null || Attack.Kind==CaelumAbsentAttack.NONE || Remaining<=0)
        {Body.SetState(Body.SeeState,true);return;}
        let soldier=CaelumPortDefender(Body);
        if(Attack.Kind==CaelumAbsentAttack.CARBINE && soldier!=null && soldier.Carbine!=null)
        {
            soldier.Carbine.NextShotTic=level.time+int(Ceil(Remaining*TICRATE));
            Body.SetState(Body.SeeState,true);return;
        }
        bool magic=Attack.Kind==CaelumAbsentAttack.MAGIC || Attack.Kind==CaelumAbsentAttack.EXPLOSIVE;
        State next=Preparing?(magic?Body.FindState('AbsentMagicPrepare'):Body.FindState('AbsentMeleePrepare'))
            :(magic?Body.FindState('AbsentMagicRecovery'):Body.FindState('AbsentMeleeRecovery'));
        if(next==null){Body.SetState(Body.SeeState,true);return;}
        double elapsed=(Preparing?Attack.Preparation:Attack.Cycle)-Remaining;
        Body.WeaponCycleTics=Attack.NativeCycleTics;
        Body.WeaponCycleStartTic=level.time-int(elapsed*TICRATE);
        Body.WeaponCyclePreparationTics=int(Ceil(Attack.Preparation*TICRATE));
        Body.WeaponCycleWindFrame=1;
        double rest=Remaining;
        if(Preparing && Attack.Kind==CaelumAbsentAttack.EXPLOSIVE)
        {
            // Reanuda la pose correspondiente sin repetir su accion de entrada.
            while(Body.WeaponCycleWindFrame<5 && elapsed*TICRATE>=Ceil(Body.WeaponCycleTics
                *Body.WeaponCycleWindFrame*CaelumAttackRules.ZUPAY_MAGIC_WIND_STEP))
            {next=next.NextState;Body.WeaponCycleWindFrame++;}
            rest=(Ceil(Body.WeaponCycleTics*Body.WeaponCycleWindFrame*CaelumAttackRules.ZUPAY_MAGIC_WIND_STEP)-elapsed*TICRATE)/TICRATE;
        }
        Body.SetState(next,true);Body.tics=Max(1,int(Ceil(rest*TICRATE)));
    }

    bool Incapacitated()
    {
        return PainRemaining>0 || Body.ForcedSleepTics>0 || Body.CombatLucidityPhysicalStunRemaining>0
            || (Body.ElementalStatus!=null && Body.ElementalStatus.IsLightningStunned())
            || CaelumBolas.Restrained(Body) || CaelumTelekinesisRules.Held(Body) || CaelumBattleCry.Active(Body);
    }

    void Act(double seconds)
    {
        if(!Alive())return;
        if(Body.SiegeCombatant!=null && Body.SiegeCombatant.Withdrawing
            && !CaelumRedemption.PreviouslyRaised(Body))return;
        Choose();
        if(CaelumAbsentBreath.Advance(self,seconds))return;
        if(Opponent==null)return;
        if(Recovering || Incapacitated())return;
        double budget=Max(0,seconds-ActionHold);
        while(budget>0 && Enemy(Opponent))
        {
            bool captured=CapturedPreparation;
            double capturedRecovery=0;
            if(captured)
            {
                double delay=Max(CapturedFrame,Attack.Kind==CaelumAbsentAttack.EXPLOSIVE?CapturedReleaseClock+budget:0);
                if(delay>budget+0.000000001)
                {
                    CapturedFrame=Max(0,CapturedFrame-budget);
                    Remaining=Max(CapturedFrame,Attack.Kind==CaelumAbsentAttack.EXPLOSIVE?CapturedReleaseClock:0);
                    while(CapturedFrame<=0 && Attack.Kind==CaelumAbsentAttack.EXPLOSIVE && Body.WeaponCycleWindFrame<5)
                    {
                        CapturedPose=CapturedPose.NextState;Body.WeaponCycleWindFrame++;
                        CapturedFrame=Max(0,Ceil(Attack.NativeCycleTics*Body.WeaponCycleWindFrame
                            *CaelumAttackRules.ZUPAY_MAGIC_WIND_STEP)/TICRATE-Attack.Cycle+CapturedCycleClock);
                    }
                    return;
                }
                budget=Max(0,budget-delay);CapturedPreparation=false;
                capturedRecovery=Max(0,CapturedCycleClock+budget);Remaining=0;
            }
            else
            {
                if(Remaining>budget){Remaining-=budget;return;}
                budget-=Remaining;Remaining=0;
            }
            if(!Preparing)
            {
                bool distant=(Body.Pos.XY-Opponent.Body.Pos.XY).Length()>Body.MeleeRange+Opponent.Body.Radius
                    || Opponent.Body.Pos.Z>Body.Pos.Z+Body.Height || Opponent.Body.Pos.Z+Opponent.Body.Height<Body.Pos.Z;
                if(!Attack.Configure(Body,distant))return;
                NextFacing=Body.AngleTo(Opponent.Body);
                let soldier=CaelumPortDefender(Body);
                if(soldier!=null && soldier.Carbine!=null)
                {
                    bool ranged=Attack.Kind==CaelumAbsentAttack.CARBINE;
                    // Cambia la seleccion logica sin mover ni redimensionar el cuerpo.
                    soldier.Carbine.Held=ranged;if(soldier.Carbine.Weapon!=null)soldier.Carbine.Weapon.Equipped=ranged;
                    if(ranged)
                    {
                        let gun=soldier.Carbine;
                        if(gun.ReloadRemaining>0)return;
                        if(gun.Magazine<=0)
                        {
                            int dexterity=Body.CombatDexterity+Body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY);
                            gun.ReloadTotal=CaelumRangedRules.BaseReloadSeconds(gun.Weapon.WeaponType)
                                *100/Max(1.0,Body.CalculateActorType4Percent(dexterity));
                            gun.ReloadRemaining=gun.ReloadTotal;
                            CaelumThermalEffects.BeginFirearmReload(Body);return;
                        }
                    }
                }
                if(!Attack.CanPay(Body)){StartRecovery();return;}
                Preparing=true;Remaining=Attack.Preparation;
                if(Remaining>0)continue;
            }
            Attack.Refresh(Body);
            if(!Attack.Pay(Body)){StartRecovery();return;}
            Release();Shots++;Preparing=false;
            Remaining=captured?capturedRecovery:Max(1.0/TICRATE,Attack.Cycle-Attack.Preparation);
        }
    }

    void StartRecovery()
    {
        Preparing=false;CapturedPreparation=false;Recovering=true;Body.AttackResourceWaiting=true;
        Body.AttackResourceWeapon=Attack.Weapon;Body.AttackResourceMagical=Attack.Kind==CaelumAbsentAttack.MAGIC || Attack.Kind==CaelumAbsentAttack.EXPLOSIVE;
        Body.AttackResourceBaseCost=Attack.Air;Body.RecoveryThreat=Opponent!=null?Opponent.Body:null;
        Body.RecoveryPhase=1;Body.CombatAirSpending=false;
        if(Body.RecoveryThreat==null || Body.Distance2D(Body.RecoveryThreat)>Body.RecoveryThreatRange()+Body.Radius)Body.RecoveryPhase=2;
    }

    void Release()
    {
        if(Attack.Kind==CaelumAbsentAttack.CARBINE)CaelumThermalEffects.RecordFirearmShot(Body);
        else if(Attack.Kind==CaelumAbsentAttack.MELEE || Attack.Kind==CaelumAbsentAttack.SLAM)
        {
            double work=Attack.Kind==CaelumAbsentAttack.SLAM?CaelumThermalData.GROUND_SLAM_WORK_JOULES
                :Body is 'CaelumPortDefender'?CaelumThermalData.WeaponWork(CaelumConstants.WEAPON_TYPE_SWORD):CaelumThermalData.NATURAL_ATTACK_WORK_JOULES;
            PendingActionHeat+=CaelumThermalRules.PositiveWorkHeat(work,CaelumThermalBody.Efficiency(Body));
        }
        let direct=Attack.Direct(Body,Opponent.Body,Opponent.Blocking(Body));Opponent.Queue(self,direct);
        if(Attack.Area>0)
        {
            vector3 origin=Attack.Kind==CaelumAbsentAttack.SLAM?Body.Pos:Opponent.Body.Pos+(0,0,Opponent.Body.Height/2);
            double probability=1;
            if(Attack.Kind==CaelumAbsentAttack.EXPLOSIVE)
                probability=CaelumMeanAim.BodyProbability(Attack.Origin,Opponent.Body.Pos,Opponent.Body.Radius,
                    Opponent.Body.Height,Attack.ProjectileRadius,Attack.Minimum,Attack.Maximum,Attack.SignedOffsets);
            for(int i=0;i<Battle.Rows.Size();i++)
            {
                let row=Battle.Rows[i];
                if(row==self || !row.Alive() || (Attack.Kind==CaelumAbsentAttack.SLAM && !Enemy(row)))continue;
                row.Queue(self,Attack.Splash(Body,row.Body,origin,probability,row.Blocking(Body)));
            }
        }
        let soldier=CaelumPortDefender(Body);
        if(Attack.Kind==CaelumAbsentAttack.CARBINE && soldier!=null && soldier.Carbine!=null)
        {soldier.Carbine.Magazine--;soldier.Carbine.ShotCount++;}
    }

    void Commit()
    {
        if(!Alive())return;
        Body.Angle=NextFacing;
        LifeFraction+=PendingLife;
        int loss=int(LifeFraction+0.000000001);LifeFraction=Max(0,LifeFraction-loss);
        int old=Body.health;Body.health=Max(Body.bBuddha?1:0,Body.health-loss);
        CommitSleep(old);
        bool armorBroken=false;
        if(Body.CombatArmor!=null)for(int i=0;i<4;i++)
        {
            ArmorFraction[i]+=PendingArmor[i];int wear=int(ArmorFraction[i]+0.000000001);
            ArmorFraction[i]=Max(0,ArmorFraction[i]-wear);
            int oldDurability=Body.CombatArmor.Durability[i];
            Body.CombatArmor.Durability[i]=Max(0,oldDurability-wear);
            armorBroken=armorBroken || (oldDurability>0 && Body.CombatArmor.Durability[i]<=0);
        }
        if(armorBroken)Body.RecalculateCombatStatistics();
        let soldier=CaelumPortDefender(Body);
        if(soldier!=null)
        {
            ShieldFraction+=PendingShield;SwordFraction+=PendingSword;GunFraction+=PendingGun;
            if(soldier.Shield!=null)soldier.Shield.Durability=Max(0,soldier.Shield.Durability-int(ShieldFraction));
            if(soldier.Sword!=null)soldier.Sword.Durability=Max(0,soldier.Sword.Durability-int(SwordFraction));
            if(soldier.Carbine!=null && soldier.Carbine.Weapon!=null)
                soldier.Carbine.Weapon.Durability=Max(0,soldier.Carbine.Weapon.Durability-int(GunFraction));
            ShieldFraction-=int(ShieldFraction);SwordFraction-=int(SwordFraction);GunFraction-=int(GunFraction);
        }
        Body.CurrentCombatLucidity=Max(0,Body.CurrentCombatLucidity-PendingLucidity);
        if(Body.health<old && Body.health>0)
        {
            Body.AddActorCombatAdrenaline(CaelumConstants.ADRENALINE_GAIN_ON_DAMAGE);
            if(PendingFire>0 && Body.ElementalStatus!=null)
                Body.ElementalStatus.ApplyDamageOverTime(CaelumConstants.ELEMENTAL_EFFECT_BURN,
                    CaelumConstants.ELEMENTAL_BASE_DURATION_SECONDS*PendingFirePower,PendingFirePower,
                    Max(1,int(PendingFire*CaelumConstants.ELEMENTAL_DOT_DAMAGE_RATIO*PendingFirePower+0.5)),FireSource,Body);
        }
        if(Body.health>0)CaelumAbsentBreath.Commit(self);
        if(Body.ContaminationAbsence!=null)Body.ContaminationAbsence.Life=Body.health;
        let thermal=CaelumThermalBody.Get(Body,true);
        if(thermal!=null && thermal.Inertia>0)
        {
            thermal.Exposure+=(PendingHeat+PendingActionHeat)/thermal.Inertia;
            thermal.AbsorbedImpactJoules+=PendingHeat;thermal.ActionJoules+=PendingActionHeat;
            thermal.Severity=CaelumThermalRules.Severity(thermal.Exposure,thermal.Toughness);
        }
        if(Body.health>0){Body.UpdateCombatHealthEffects();Body.UpdateActorLucidityState();}
    }

    void CommitSleep(int before)
    {
        if(SleepHitState!=Body.SpellSleep)
        {SleepHitState=Body.SpellSleep;SleepHitFraction=0;}
        if(Body.ForcedSleepTics<=0){SleepHitFraction=0;return;}
        SleepHitFraction+=PendingWakeHits;
        if(Body.health>=before)return;
        if(Body.health<=0)
        {CaelumSleepRules.HealthLost(Body,before);SleepHitFraction=0;return;}
        // Cada impacto aporta su probabilidad de dano, no un golpe seguro por
        // tener dano medio positivo. El umbral sigue siendo el del hechizo.
        int hits=int(SleepHitFraction+0.000000001);
        SleepHitFraction=Max(0,SleepHitFraction-hits);
        for(int i=0;i<hits && Body.ForcedSleepTics>0;i++)CaelumSleepRules.HealthLost(Body,before);
        if(Body.ForcedSleepTics<=0){SleepHitState=null;SleepHitFraction=0;}
    }

    void FinishRound()
    {
        if(!Participating || Body==null || Body.bDestroyed || Retreated)return;
        if(Body.health<=0)
        {
            if(!Body.bCorpse)Body.Die(null,Killer,DMG_NO_ARMOR,'CaelumRangedTest');
            let binding=CaelumBolas.Binding(Body);
            if(binding!=null && binding.Phase==1){binding.Victim=Body;binding.Resolve(false);}
            let resident=CaelumPortDefender(Body);
            if(TravelingResident && resident!=null && resident.Residence!=null && resident.Residence.Suspended)
            {
                let home=resident.Residence;
                home.Solid=Body.bSolid;home.Shootable=Body.bShootable;home.Invisible=Body.bInvisible;
                home.NoInteraction=Body.bNoInteraction;home.NoBlock=Body.bNoBlockmap;home.NoSector=Body.bNoSector;
                home.Velocity=Body.Vel;
            }
            return;
        }
        if(CaelumRedemption.PreviouslyRaised(Body) || CaelumBolas.Restrained(Body)
            || CaelumTelekinesisRules.Held(Body))return;
        let boss=CaelumZupayColossus(Body);
        let entry=Body.SiegeCombatant;
        bool wounded=boss!=null && boss.IsRetreatBoss()
            && double(Body.health)/Max(1,Body.CombatMaximumHealth)<=CaelumConstants.HEALTH_WOUNDED_THRESHOLD;
        if(wounded || (entry!=null && entry.Withdrawing))
        {
            Retreated=true;if(boss!=null)boss.SewerFleeing=true;
            if(entry!=null)
            {
                entry.Exited=true;entry.Withdrawing=true;
                if(entry.Encounter!=null && entry.Encounter.Boss==entry)entry.Encounter.BossRetreated=true;
            }
            // Retiene cuerpo e inventario en el grafo del mapa; no genera botin.
            CaelumDemonService.StopBreath(Body,true,false);
            Body.target=null;Body.Vel=(0,0,0);Body.bDormant=true;Body.bInvisible=true;
            Body.bSolid=false;Body.bShootable=false;Body.bNoInteraction=true;
            Body.A_ChangeLinkFlags(1,1);Body.A_StopAllSounds();
            Body.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            for(Inventory item=Body.Inv;item!=null;item=item.Inv)item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
        }
    }
}

class CaelumAbsentBattle : Object play
{
    const REVISION=1;
    const SPATIAL_CELL=128.0; // Celda nativa del blockmap, no alcance de combate.
    const SPATIAL_BUCKETS=2048;
    int SchemaRevision,Rounds;
    bool Away,Busy,Engaged;
    String SourceMap;
    double Stamp,Fraction,ActiveScale,ReinforcementDelay,SimulationTime;
    CaelumPlayer Observer;
    CaelumSiegeEncounter Encounter;
    Array<CaelumAbsentCombatant> Rows;
    Array<CaelumAbsentMachine> Machines;
    Array<CaelumAbsentShot> Flights;
    Array<CaelumAbsentStructureHit> StructureHits;
    Array<int> SpatialHeads;
    bool SpatialDirty;
    double LargestRadius;
    CaelumAbsentCombatant FirstFriendly,FirstHostile;
    bool TargetCacheReady;
    bool ScheduleWaiting;
    double ScheduledCivil,DeploymentTicFraction;
    CaelumAbsentWork Work;

    void RefreshFirstTargets()
    {
        FirstFriendly=FirstHostile=null;
        for(int i=0;i<Rows.Size();i++)
        {
            let row=Rows[i];if(!row.Alive())continue;
            if(row.Friendly){if(FirstFriendly==null)FirstFriendly=row;}
            else if(FirstHostile==null)FirstHostile=row;
            if(FirstFriendly!=null && FirstHostile!=null)break;
        }
        TargetCacheReady=true;
    }

    CaelumAbsentCombatant FirstOpponent(bool friendly)
    {
        if(!TargetCacheReady || (FirstFriendly!=null && (!FirstFriendly.Alive() || !FirstFriendly.Friendly))
            || (FirstHostile!=null && (!FirstHostile.Alive() || FirstHostile.Friendly)))RefreshFirstTargets();
        return friendly?FirstHostile:FirstFriendly;
    }

    int SpatialHash(int x,int y){return ((x*37+y*73)&0x7fffffff)%SPATIAL_BUCKETS;}

    void RebuildSpatial()
    {
        if(!SpatialDirty && SpatialHeads.Size()==SPATIAL_BUCKETS)return;
        SpatialHeads.Resize(SPATIAL_BUCKETS);
        for(int i=0;i<SpatialHeads.Size();i++)SpatialHeads[i]=-1;
        LargestRadius=0;
        for(int i=0;i<Rows.Size();i++)
        {
            let row=Rows[i];row.SpatialNext=-1;
            if(!row.Alive())continue;
            row.SpatialX=int(Floor(row.Body.Pos.X/SPATIAL_CELL));row.SpatialY=int(Floor(row.Body.Pos.Y/SPATIAL_CELL));
            int h=SpatialHash(row.SpatialX,row.SpatialY);row.SpatialNext=SpatialHeads[h];SpatialHeads[h]=i;
            LargestRadius=Max(LargestRadius,row.Body.Radius);
        }
        SpatialDirty=false;
    }

    void Nearby(vector3 origin,double reach,out Array<CaelumAbsentCombatant> result)
    {
        result.Clear();RebuildSpatial();
        double radius=reach+LargestRadius;
        int left=int(Floor((origin.X-radius)/SPATIAL_CELL)),right=int(Floor((origin.X+radius)/SPATIAL_CELL));
        int low=int(Floor((origin.Y-radius)/SPATIAL_CELL)),high=int(Floor((origin.Y+radius)/SPATIAL_CELL));
        for(int x=left;x<=right;x++)for(int y=low;y<=high;y++)
            for(int i=SpatialHeads[SpatialHash(x,y)];i>=0;i=Rows[i].SpatialNext)
            {
                let row=Rows[i];
                if(row.SpatialX==x && row.SpatialY==y && row.Alive()
                    && (row.Body.Pos.XY-origin.XY).Length()<=reach+row.Body.Radius)result.Push(row);
            }
    }

    CaelumAbsentCombatant Add(CaelumCombatActor body,bool admitted=false)
    {
        if(body==null || body.health<=0 || !body.CombatProfileInitialized)return null;
        let resident=CaelumPortDefender(body);
        if(resident!=null && resident.Residence!=null && resident.Residence.Suspended && !admitted)return null;
        let row=body.AbsentCombatant;
        if(row==null || row.Battle!=self)
        {
            row=new('CaelumAbsentCombatant');row.Battle=self;row.Body=body;row.Identity=Rows.Size();
            body.AbsentCombatant=row;Rows.Push(row);
        }
        row.Capture();SpatialDirty=true;TargetCacheReady=false;return row;
    }

    void Capture(CaelumSiegeEncounter encounter,CaelumPlayer user,double at=-1)
    {
        if(Away || encounter==null || user==null)return;
        self.Encounter=encounter;SourceMap=level.MapName;Stamp=at>=0?at:CaelumContaminationAbsence.Clock(user,SourceMap);
        Observer=user;
        if(Stamp<0)return;
        ActiveScale=CaelumWorldClock.SecondsPerGameHour(SourceMap)/3600.0;SchemaRevision=REVISION;
        SpatialDirty=true;TargetCacheReady=false;
        for(int i=0;i<Rows.Size();i++)Rows[i].Participating=false;
        for(int i=0;i<encounter.Attackers.Size();i++)
        {let e=encounter.Attackers[i];if(e!=null && !e.Exited && !e.ConfirmedDead)Add(e.Body);}
        let port=CaelumPortSiege(encounter);
        ScheduleWaiting=port!=null && !port.SiegeStarted && CaelumCityData.Enabled();
        if(ScheduleWaiting)ScheduledCivil=Max(Stamp,CaelumCityWorld.SiegeCivilSeconds());
        if(port!=null)for(int i=0;i<port.Defenders.Size();i++)
        {let row=Add(port.Defenders[i]);if(row!=null){row.RosterKind=2;row.RosterIndex=i;}}
        if(port!=null && port.Reinforcements!=null)
            ReinforcementDelay=Max(0,port.Reinforcements.NextOpportunity-level.time)/double(TICRATE);
        Machines.Clear();
        for(int i=0;i<encounter.Machines.Size();i++)AddMachine(encounter.Machines[i]);
        if(port!=null)for(int i=0;i<port.Guns.Size();i++)AddMachine(port.Guns[i]);
        for(int i=0;i<Rows.Size();i++)
        {
            let row=Rows[i];let target=row.Body!=null?CaelumCombatActor(row.Body.target):null;
            row.Opponent=target!=null?target.AbsentCombatant:null;
            if(!row.Enemy(row.Opponent))row.Opponent=null;
            if(row.Participating)
            {
                bool captured=row.Body.ContaminationAbsence!=null && row.Body.ContaminationAbsence.Away;
                CaelumContaminationAbsence.Capture(row.Body,user);
                if(!captured && at>=0 && row.Body.ContaminationAbsence!=null)
                {row.Body.ContaminationAbsence.Stamp=at;row.Body.ContaminationAbsence.Civil=at;}
            }
        }
        CaelumAbsentShot.Capture(self);
        Away=true;
    }

    void Round(double worldSeconds=1)
    {
        if(Work==null)Work=new('CaelumAbsentWork');
        Work.Begin(self,SimulationTime,worldSeconds,false);
        while(!Work.Advance(2147483647)){}
    }

    void AddMachine(CaelumHostileMachine machine)
    {
        if(machine==null)return;
        for(int i=0;i<Machines.Size();i++)if(Machines[i].Machine==machine)return;
        let row=machine.AbsentMachine;
        if(row==null){row=new('CaelumAbsentMachine');machine.AbsentMachine=row;}
        row.Battle=self;row.Machine=machine;row.Capture();Machines.Push(row);
    }

    bool Opposed()
    {
        FirstOpponent(true);
        return FirstFriendly!=null && FirstHostile!=null;
    }

    bool MachineWork()
    {
        if(Flights.Size()>0)return true;
        for(int i=0;i<Machines.Size();i++)if(Machines[i].CanWork())return true;
        for(int i=0;i<Rows.Size();i++)if(CaelumAbsentBreath.Needed(Rows[i]))return true;
        return false;
    }

    void Reinforce(double seconds)
    {
        let port=CaelumPortSiege(Encounter);
        if(port==null || !port.SiegeStarted || port.Reinforcements==null)return;
        let reserve=port.Reinforcements;
        if(!reserve.Enabled || reserve.Stopped || reserve.Remaining==0)return;
        if(port.Victory){reserve.Stopped=true;return;}
        ReinforcementDelay-=seconds;
        if(ReinforcementDelay>0)return;
        int first=port.Attackers.Size();reserve.Opportunity(port);
        ReinforcementDelay+=double(CaelumReinforcementData.INTERVAL)/TICRATE;
        for(int i=first;i<port.Attackers.Size();i++)
        {
            let entry=port.Attackers[i];let body=entry.Body;if(body==null)continue;
            Add(body);CaelumContaminationAbsence.Capture(body,Observer);
            let absent=body.ContaminationAbsence;
            if(absent!=null){absent.Civil+=SimulationTime-absent.Stamp;absent.Stamp=SimulationTime;}
            for(int m=0;m<port.Machines.Size();m++)if(port.Machines[m].IsNearby(entry))port.Machines[m].RememberGuard(entry);
        }
    }

    void Interval(double end,double worldSeconds)
    {
        if(Work==null)Work=new('CaelumAbsentWork');
        Work.Begin(self,end,worldSeconds,true);
        while(!Work.Advance(2147483647)){}
    }

    void SyncTo(double end)
    {
        if(!Away || Busy || SchemaRevision!=REVISION || end<=Stamp)return;
        Busy=true;
        if(ScheduleWaiting)
        {
            double before=Min(end,ScheduledCivil);
            if(Rows.Size()==0){Stamp=before;SimulationTime=before;Fraction=0;}
            else ResolveUntil(before);
            if(end<ScheduledCivil){Busy=false;return;}
            StartScheduled();
        }
        ResolveUntil(end);Busy=false;
    }

    void ResolveUntil(double end)
    {
        double elapsed=end-Stamp+Fraction;
        int whole=int(Floor(elapsed+0.000000001));
        double first=Stamp-Fraction;
        Fraction=Max(0,elapsed-whole);
        for(int second=0;second<whole;second++)
        {
            if(Terminal())break;
            Interval(first+second+1,1);
        }
        SimulationTime=end;
        Stamp=end;
    }

    void StartScheduled()
    {
        let port=CaelumPortSiege(Encounter);
        if(!ScheduleWaiting || port==null)return;
        ScheduleWaiting=false;
        if(!port.SiegeStarted)port.Deploy(true,ScheduledCivil);
        // Spawn difiere PostBeginPlay; el resumen necesita el perfil real ya
        // inicializado. Las guardas impiden duplicarlo en el siguiente tic.
        for(int i=0;i<port.Attackers.Size();i++)
        {
            let body=port.Attackers[i].Body;
            if(body!=null && !body.CombatProfileInitialized)body.PostBeginPlay();
        }
        port.ActivateDeployment(true);
        Away=false;Capture(port,Observer,ScheduledCivil);
        SimulationTime=Stamp;Fraction=0;
    }

    void DeployResidents(double seconds)
    {
        let port=CaelumPortSiege(Encounter);
        if(port==null || !port.SiegeStarted || !CaelumHouseHub.IsCity(port))return;
        let roster=CaelumHouseResidents.Get();if(roster==null || !roster.DeploymentPending)return;
        DeploymentTicFraction+=seconds*TICRATE;
        int attempts=int(DeploymentTicFraction+0.000000001);
        DeploymentTicFraction=Max(0,DeploymentTicFraction-attempts);
        for(int i=0;i<attempts && roster.DeploymentPending;i++)
        {
            let body=roster.DeploymentOpportunity(port,SimulationTime,true);
            if(body==null)continue;
            let row=Add(body,true);
            if(row!=null){row.RosterKind=2;row.RosterIndex=body.HomeIdentity;}
        }
    }

    bool Terminal()
    {
        if(ScheduleWaiting)return false;
        let roster=CaelumHouseResidents.Get();
        if(CaelumHouseHub.IsCity(CaelumPortSiege(Encounter)) && roster!=null && roster.DeploymentPending)return false;
        FirstOpponent(true);
        if(FirstFriendly!=null || FirstHostile!=null || Flights.Size()>0)return false;
        let port=CaelumPortSiege(Encounter);
        let reserve=port!=null?port.Reinforcements:null;
        if(reserve!=null && reserve.Enabled && !reserve.Stopped && reserve.Remaining>0 && !port.Victory)return false;
        if(port!=null && port.Victory && reserve!=null)reserve.Stopped=true;
        // Sin vivos, reservas ni trabajo de maquinas no queda una accion que
        // resolver. No iterar los segundos vacios de semanas o meses ausentes.
        return !MachineWork();
    }

    bool RebindResidents()
    {
        let roster=CaelumHouseResidents.Get();
        let port=CaelumPortSiege(Encounter);
        for(int i=0;i<Rows.Size();i++)
        {
            let row=Rows[i];if(!row.Participating || !row.TravelingResident)continue;
            if(roster==null || row.ResidentIdentity<0 || row.ResidentIdentity>=roster.Residents.Size())return false;
            let entry=roster.Residents[row.ResidentIdentity];let body=entry.Body;
            if(body==null || !body.CombatProfileInitialized)return false;
            // El cuerpo original viaja con el registro domestico. Nunca se
            // combate con una copia del hub ni con sus coordenadas de viaje.
            if(entry.Delegated || entry.ResidentMap!=SourceMap){row.Participating=false;continue;}
            row.Body=body;body.AbsentCombatant=row;
            body.SetOrigin(entry.Position,false);body.FindFloorCeiling();
            if(entry.Suspended)body.bShootable=entry.Shootable;
            if(port!=null)
            {
                if(port.Defenders.Size()<=row.ResidentIdentity)port.Defenders.Resize(row.ResidentIdentity+1);
                port.Defenders[row.ResidentIdentity]=body;body.Port=port;
                if(entry.GunIndex>=0 && entry.GunIndex<port.Guns.Size() && entry.GunSlot>=0)
                {
                    let gun=port.Guns[entry.GunIndex];body.Gun=gun;
                    if(gun!=null)
                    {
                        if(gun.Operators.Size()<=entry.GunSlot)gun.Operators.Resize(entry.GunSlot+1);
                        gun.Operators[entry.GunSlot]=body;
                    }
                }
            }
        }
        SpatialDirty=true;TargetCacheReady=false;return true;
    }

    void Reanchor(CaelumSiegeEncounter encounter,CaelumPlayer user)
    {
        self.Encounter=encounter;Observer=user;
        let port=CaelumPortSiege(encounter);
        for(int i=0;i<Rows.Size();i++)
        {
            let row=Rows[i];row.Battle=self;
            if(!row.Participating || row.TravelingResident)continue;
            if(row.RosterKind==1 && row.RosterIndex>=0 && row.RosterIndex<encounter.Attackers.Size())
                row.Body=encounter.Attackers[row.RosterIndex].Body;
            else if(row.RosterKind==2 && port!=null && row.RosterIndex>=0 && row.RosterIndex<port.Defenders.Size())
                row.Body=port.Defenders[row.RosterIndex];
            if(row.Body!=null)row.Body.AbsentCombatant=row;
        }
    }

    void Restore(CaelumPlayer user)
    {
        if(!Away || Busy || user==null || SourceMap!=level.MapName)return;
        double end=CaelumContaminationAbsence.Clock(user,SourceMap);if(end<0)return;
        if(!RebindResidents())return;
        SyncTo(end);
        // El resto final pertenece a esta ausencia. Se resuelve una sola vez
        // antes de reanudar los tics nativos; no se arrastra al proximo viaje.
        if(Fraction>0){Busy=true;Interval(end,Fraction);Fraction=0;Busy=false;}
        FinishRestore();
    }

    void FinishRestore()
    {
        Away=false;
        Busy=false;
        let port=CaelumPortSiege(Encounter);
        if(port!=null && port.Reinforcements!=null)
            port.Reinforcements.NextOpportunity=level.time+int(Ceil(Max(0,ReinforcementDelay)*TICRATE));
        for(int i=0;i<Rows.Size();i++)
        {
            let row=Rows[i];let resident=CaelumPortDefender(row.Body);
            if(row.Body!=null && row.Body.ThermalState!=null)
            {
                row.Body.ThermalState.RuntimeReady=false;row.Body.ThermalState.SourceMap="";
                row.Body.ThermalState.PendingActivityJoules=0;row.Body.ThermalState.PropelledVelocity=(0,0);
            }
            if(row.TravelingResident && resident!=null && resident.Residence!=null && resident.Residence.Suspended)
            {
                resident.bShootable=false;row.NativeResumePending=row.Alive();
            }
            else row.ResumeNative();
        }
    }
}

// Censo solo en las fronteras de carga del mapa, acotado a controladores de
// encuentros. Ningun NPC busca adversarios recorriendo actores globales.
class CaelumAbsentBattles : Object play
{
    static void Capture(CaelumPlayer user)
    {
        if(user==null)return;
        let iterator=ThinkerIterator.Create('CaelumSiegeEncounter');CaelumSiegeEncounter encounter;
        while((encounter=CaelumSiegeEncounter(iterator.Next()))!=null)
        {
            if(encounter.AbsentBattle==null)encounter.AbsentBattle=new('CaelumAbsentBattle');
            encounter.AbsentBattle.Capture(encounter,user);
        }
    }
    static void Restore(CaelumPlayer user)
    {
        if(user==null)return;
        let iterator=ThinkerIterator.Create('CaelumSiegeEncounter');CaelumSiegeEncounter encounter;
        while((encounter=CaelumSiegeEncounter(iterator.Next()))!=null)
            if(encounter.AbsentBattle!=null)
            {encounter.AbsentBattle.Reanchor(encounter,user);encounter.AbsentBattle.Restore(user);}
    }
}
