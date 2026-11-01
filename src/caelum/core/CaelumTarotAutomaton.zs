// El equipo mecÃ¡nico pertenece al cuerpo: no se materializa como botÃ­n retirable.
class CaelumAutomatonMace : CaelumWeaponModel
{
    override double GetWeightFor(int weaponType,int tier,int equipmentSize)
    {return CaelumMajorArcanaData.AUTOMATON_MACE_KG;}
    override double GetTierOneDamageFor(int weaponType)
    {return CaelumMajorArcanaData.AUTOMATON_MACE_DAMAGE;}
    override double GetBaseCriticalChanceFor(int weaponType)
    {return CaelumMajorArcanaData.AUTOMATON_MACE_CRITICAL;}
}

class CaelumAutomatonLink : Inventory
{
    int Revision;
    CaelumTarotAutomaton Body;
    void End(){if(Body!=null)Body.Sleep();}
    override void PreTravelled(){End();}
    override void OnDestroy(){End();Super.OnDestroy();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotAutomaton : CaelumFolkloreCombatActor
{
    int Revision,RemainingTics,VisualPose,LastMotionTic;
    double AttackProgress,AttackDuration;
    bool StrikeResolved;
    CaelumAutomatonLink Binding;
    CaelumPlayer Caster;
    CaelumAutomatonModelBody Look;
    CaelumAutomatonMace Mace;
    CaelumShieldModel Shield;

    override bool EquipmentCanWear(){return false;}
    override CaelumWeaponModel GetPossessedSidearm(){return Mace;}
    override double GetAttackCarriedWeight()
    {return CaelumMajorArcanaData.AUTOMATON_EQUIPMENT_KG;}
    override double ResolveActorShieldDamage(Actor inflictor,Actor source,double damage,Name mod,int flags)
    {return CaelumActorShield.Resolve(self,Shield,false,inflictor,source,damage,mod,flags);}

    void Prepare()
    {
        if(Revision>=CaelumMajorArcanaData.AUTOMATON_REVISION)return;
        Revision=CaelumMajorArcanaData.AUTOMATON_REVISION;
        Mass=CaelumMajorArcanaData.AUTOMATON_BODY_KG;
        InitializeUniformFolkloreProfile(CaelumMajorArcanaData.AUTOMATON_ATTRIBUTE);
        CombatArmor.InitializeUniformLoadout(CaelumConstants.ARMOR_TYPE_HEAVY,1);
        for(int slot=0;slot<4;slot++)
        {
            CombatArmor.Size[slot]=CaelumConstants.EQUIPMENT_SIZE_XL;
            CombatArmor.Durability[slot]=CombatArmor.GetMaximumDurability(slot);
        }
        Shield=new("CaelumShieldModel");Shield.InitializeDefaults();
        Shield.ShieldType=CaelumConstants.SHIELD_TYPE_TOWER;Shield.Tier=1;
        Shield.Size=CaelumConstants.EQUIPMENT_SIZE_XL;Shield.Equipped=true;
        Shield.Durability=Shield.GetMaximumDurability();
        Mace=new("CaelumAutomatonMace");Mace.InitializeDefaults();
        // El mangual aporta Ãºnicamente la familia de dispersiÃ³n contundente normal.
        Mace.WeaponType=CaelumConstants.WEAPON_TYPE_FLAIL;
        Mace.Size=CaelumConstants.EQUIPMENT_SIZE_XL;Mace.Equipped=true;
        Mace.Durability=Mace.GetMaximumDurability();
        MeleeRange=CaelumMajorArcanaData.AUTOMATON_MACE_RANGE_MU;
        RecalculateCombatStatistics();health=CombatMaximumHealth;
        CurrentCombatAir=MaximumCombatAir;CurrentCombatAnima=MaximumCombatAnima;
        Look=CaelumAutomatonModelBody(Spawn('CaelumAutomatonModelBody',Pos,NO_REPLACE));
        if(Look!=null)Look.master=self;
        bDormant=true;UpdateVisual();
    }

    bool Wake(CaelumPlayer user,int duration)
    {
        Prepare();
        if(user==null || duration<=0 || health<=0 || Caster!=null)return false;
        let link=CaelumTarotAutomata.View(user);
        if(link!=null && link.Body!=null)return false;
        if(link==null)link=CaelumAutomatonLink(user.GiveInventoryType('CaelumAutomatonLink'));
        if(link==null)return false;
        Binding=link;link.Revision=1;link.Body=self;
        Caster=user;master=user;SetFriendPlayer(user.player);RemainingTics=duration;
        bDormant=false;target=null;LastEnemy=null;VisualEvidence=null;
        SetStateLabel("See");CaelumMajorWorldEvents.TimeSourcesChanged();UpdateVisual();return true;
    }

    void Sleep()
    {
        if(Binding!=null && Binding.Body==self)Binding.Body=null;
        Binding=null;Caster=null;master=null;FriendPlayer=0;RemainingTics=0;
        target=null;LastEnemy=null;AttackProgress=0;StrikeResolved=false;
        if(VisualEvidence!=null && VisualEvidence.Memory!=null)VisualEvidence.Memory.ClearGoal(self);
        VisualEvidence=null;Vel.X=Vel.Y=0;bDormant=true;
        if(!bDestroyed && health>0)SetStateLabel("Inactive");
        CaelumMajorWorldEvents.TimeSourcesChanged();UpdateVisual();
    }

    void AdvanceEffect()
    {
        if(Caster==null)return;
        if(Caster.SessionIdentityPending)return;
        if(Binding==null || Caster.bDestroyed || --RemainingTics<=0)Sleep();
    }

    void UpdateVisual()
    {
        if(Look==null)return;
        Look.SetOrigin(Pos,false);Look.Angle=Angle;Look.bInvisible=bInvisible;
        int pose=health<=0?19:Caster==null?0:1;
        if(health>0 && Caster!=null)
        {
            if(InStateSequence(CurState,MeleeState))pose=10+Min(5,int(6*AttackProgress/Max(1,AttackDuration)));
            else if(level.time-LastMotionTic<4)pose=2+(level.time/4)%8;
        }
        if(VisualPose!=pose || Look.CurState==null)
        {
            VisualPose=pose;
            switch(pose)
            {
                case 0:Look.SetStateLabel("F0");break;
                case 1:Look.SetStateLabel("F1");break;
                case 2:Look.SetStateLabel("F2");break;
                case 3:Look.SetStateLabel("F3");break;
                case 4:Look.SetStateLabel("F4");break;
                case 5:Look.SetStateLabel("F5");break;
                case 6:Look.SetStateLabel("F6");break;
                case 7:Look.SetStateLabel("F7");break;
                case 8:Look.SetStateLabel("F8");break;
                case 9:Look.SetStateLabel("F9");break;
                case 10:Look.SetStateLabel("F10");break;
                case 11:Look.SetStateLabel("F11");break;
                case 12:Look.SetStateLabel("F12");break;
                case 13:Look.SetStateLabel("F13");break;
                case 14:Look.SetStateLabel("F14");break;
                case 15:Look.SetStateLabel("F15");break;
                case 16:Look.SetStateLabel("F16");break;
                case 17:Look.SetStateLabel("F17");break;
                case 18:Look.SetStateLabel("F18");break;
                case 19:Look.SetStateLabel("F19");break;
            }
        }
    }

    override void Tick()
    {
        Prepare();AdvanceEffect();vector3 before=Pos;Super.Tick();
        if((Pos.XY-before.XY).Length()>0.01)LastMotionTic=level.time;
        UpdateVisual();
    }

    double MaceDuration()
    {
        double factor=100.0/CalculateActorType4Percent(CombatDexterity+GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_DEXTERITY));
        double capacity=Mass*CalculateActorType4Percent(CombatStrength)/100.0;
        return CaelumAttackRules.Duration(factor,Mace.GetWeight(),CombatArmor.GetWeight(CaelumConstants.ARMOR_SLOT_HANDS),capacity)
            /CaelumThermalEffects.Speed(self);
    }

    action void A_AutomatonChase()
    {
        let body=CaelumTarotAutomaton(self);if(body==null || body.Caster==null){SetStateLabel("Inactive");return;}
        body.target=CaelumVisualPerception.Acquire(body,body.target);
        let evidence=CaelumVisualPerception.Evidence(body);
        if(body.target==null && evidence.VisibleNow && CaelumVisualPerception.Opponent(body,evidence.Subject)
            && CaelumVisualPerception.CanSee(body,evidence.Subject))
        {body.Angle=body.AngleTo(evidence.Subject);body.Vel.X=body.Vel.Y=0;return;}
        if(body.target!=null && CaelumVisualPerception.Identify(body,body.target) && body.CheckMeleeRange())
        {
            double duration=body.MaceDuration();
            double cost=body.GetEffectiveAttackAir(CaelumMajorArcanaData.AUTOMATON_MACE_AIR)
                *CaelumThermalEffects.HeatCost(body)*CaelumAltitudeService.Effort(body);
            if(duration>0 && body.CurrentCombatAir>=cost)
            {body.AttackDuration=duration;body.AttackProgress=0;body.StrikeResolved=false;body.SetStateLabel("Melee");return;}
        }
        body.ThermalChase(null,null);
    }

    void Strike()
    {
        if(!CaelumVisualPerception.Identify(self,target) || !CheckMeleeRange()
            || !SpendPhysicalAttackAir(CaelumMajorArcanaData.AUTOMATON_MACE_AIR))return;
        A_CaelumFacePerceivedTarget();CaelumNoise.Emit(self,CaelumNoiseData.SWING);
        int damage=PrepareActorOutgoingDamage(Mace.GetDamage()*CalculateActorType1Percent(CombatStrength)/100.0,false,true);
        if(damage>0 && WeaponMeleeAimHits(Mace))
        {
            Actor victim=target;int before=victim.health;
            ThermalBluntDelivery=true;DeliverContactMelee(damage,"weapons/swordhit");ThermalBluntDelivery=false;
            if(victim.health<before)ApplyActorAttackPush(victim,AngleTo(victim),CombatPhysicalPushMultiplier);
        }
        PendingCombatCriticalDelivery=false;
    }

    action void A_AutomatonAttack()
    {
        let body=CaelumTarotAutomaton(self);if(body==null || body.Caster==null)return;
        body.Vel.X=body.Vel.Y=0;
        if(CaelumBolas.Interrupted(body) || CaelumBolas.Restrained(body)
            || !CaelumVisualPerception.Identify(body,body.target)){body.SetStateLabel("See");return;}
        body.AttackProgress++;
        if(!body.StrikeResolved && body.AttackProgress>=body.AttackDuration/2)
        {body.StrikeResolved=true;body.Strike();}
        if(body.AttackProgress>=body.AttackDuration)body.SetStateLabel("See");
    }

    override void Die(Actor source,Actor inflictor,int flags,Name mod)
    {Sleep();Super.Die(source,inflictor,flags,mod);UpdateVisual();}
    override void OnDestroy(){Sleep();if(Look!=null)Look.Destroy();Super.OnDestroy();}
    Default {Tag "$CA_TAROT_AUTOMATON";Health 1;Mass 1000;Radius 26.666667;Height 93.333333;PainChance 0;RenderRadius 112;+ISMONSTER +FRIENDLY +SOLID +SHOOTABLE -COUNTKILL}
    States
    {
        Spawn:Inactive:TNT1 A -1;Stop;
        See:TNT1 A 4 A_AutomatonChase;Loop;
        Melee:TNT1 A 1 A_AutomatonAttack;Loop;
        Pain:TNT1 A 0;Goto See;
        Death:TNT1 A 0 A_NoBlocking;TNT1 A -1;Stop;
    }
}

class CaelumTarotAutomata : Object play
{
    static clearscope CaelumAutomatonLink View(CaelumPlayer user)
    {return user!=null?CaelumAutomatonLink(user.FindInventory('CaelumAutomatonLink')):null;}
    static bool Start(CaelumPlayer user,Actor aimed,int duration)
    {
        let body=CaelumTarotAutomaton(aimed);
        return body!=null && CaelumMajorTargets.Visible(user,body) && body.Wake(user,duration);
    }
    static bool Command(CaelumPlayer user,Actor aimed)
    {
        let link=View(user);let body=link!=null?link.Body:null;
        if(body==null || body.Caster!=user || !CaelumTarotService.ValidUser(user)
            || CaelumRacialAbilityRules.Interrupted(user) || CaelumRacialAbilityRules.MenuBlocked(user)
            || user.CraftingTaskActive || user.StaffCastPending
            || !CaelumMajorTargets.Visible(user,aimed) || !CaelumMajorTargets.Enemy(user,aimed))return false;
        let evidence=CaelumVisualPerception.Evidence(body);
        evidence.GetMemory().Remember(aimed,aimed.Pos,level.time,body);
        evidence.GetMemory().Focus=aimed;body.target=null;
        CaelumTarotService.Feedback(user,"CA_TAROT_AUTOMATON_ORDER");return true;
    }
    static bool Input(CaelumPlayer user)
    {let link=View(user);return link!=null && link.Body!=null && Command(user,CaelumMajorTargets.Aim(user));}
}
