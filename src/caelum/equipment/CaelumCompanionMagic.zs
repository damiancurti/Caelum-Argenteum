// #430: el implemento nativo conserva coste, preparacion, proyectiles y desgaste.
// No se adquieren enemigos aqui: la percepcion compartida entrega el objetivo.
class CaelumCompanionMagic : Object play
{
    CaelumCompanionLoadout Loadout;
    CaelumEquipmentItem Pending;
    CaelumWeaponModel Weapon;
    Actor Recipient;
    double Remaining,Cost;
    int Releases;

    void Cancel()
    {
        let body=Loadout.Body;
        if(body.CombatActiveTool==Pending)body.CombatActiveTool=null;
        Pending=null;Recipient=null;Remaining=0;Cost=0;
        if(body.health>0 && body.InStateSequence(body.CurState,body.FindState("ResidentToolUse")))
            body.SetState(body.SeeState);
    }

    double Range()
    {
        let body=Loadout.Body;
        return CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS*body.CalculateActorType4Percent(
            body.CombatEloquence+body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_ELOQUENCE))/100;
    }

    bool ValidRecipient(Actor candidate,int type)
    {
        let body=Loadout.Body;
        if(candidate==null || candidate.health<=0 || body.Distance3D(candidate)>Range()
            || !body.CheckSight(candidate))return false;
        if(CaelumSupportImplementData.IsSupport(type))
        {
            int role=CaelumSupportImplementData.RoleForWeapon(type);
            if(!CaelumSupportMagic.Eligible(body,candidate,role))return false;
            if(CaelumSupportImplementData.Beneficial(role))return true;
        }
        return CaelumVisualPerception.Identify(body,candidate);
    }

    bool TryAttack()
    {
        let body=Loadout.Body;let item=Loadout.SelectedWeapon;
        if(body==null || body.health<=0 || CaelumBolas.Interrupted(body) || CaelumBolas.Restrained(body)
            || item==null || item.Owner!=body || item.Durability<=0 || CaelumBattleCry.Active(body))return false;
        if(Pending!=null)return true;
        if(!CaelumSupportImplementData.ValidEssence(item.ItemType,item.EssenceType))return false;
        Actor receiver=body.target;
        int role=CaelumSupportImplementData.RoleForWeapon(item.ItemType);
        if(CaelumSupportImplementData.ValidRole(role) && CaelumSupportImplementData.Beneficial(role))receiver=body;
        if(!ValidRecipient(receiver,item.ItemType))return false;
        if(Weapon==null){Weapon=new("CaelumWeaponModel");Weapon.InitializeDefaults();}
        Weapon.SourceItem=item;Weapon.WeaponType=item.ItemType;Weapon.Tier=item.Tier;Weapon.Size=item.EquipmentSize;
        Weapon.EssenceType=item.EssenceType;Weapon.Durability=item.Durability;Weapon.ContaminationState=item.ContaminationState;
        double tierCost=item.Tier<=1 ? 1 : item.Tier==2 ? CaelumSupportImplementData.TIER_TWO_COST : CaelumSupportImplementData.TIER_THREE_COST;
        double price=body.GetMagicAnimaCost(Weapon.GetAnimaCostFor(item.ItemType)*tierCost);
        double duration=Loadout.Tools.AttackDuration(item,true);
        if(body.CurrentCombatAnima<price || duration<=0)return false;
        Pending=item;Recipient=receiver;Cost=price;Remaining=duration/TICRATE;
        body.CombatActiveTool=item;body.Vel.X=body.Vel.Y=0;body.SetStateLabel("ResidentToolUse");return true;
    }

    void Tick()
    {
        if(Pending==null)return;
        let body=Loadout.Body;
        if(Pending!=Loadout.SelectedWeapon || Pending.Owner!=body || Pending.Durability<=0
            || body.health<=0 || CaelumBolas.Interrupted(body) || CaelumBolas.Restrained(body)
            || CaelumBattleCry.Active(body)){Cancel();return;}
        Remaining=Max(0,Remaining-1.0/TICRATE);
        if(Remaining>0)return;
        if(body.CurrentCombatAnima>=Cost && ValidRecipient(Recipient,Pending.ItemType) && Release())
        {
            body.CurrentCombatAnima=Max(0,body.CurrentCombatAnima-Cost);Releases++;
            body.MarkActorCombatActivity();CaelumNoise.Emit(body,CaelumNoiseData.MAGIC);
        }
        Cancel();
    }

    bool Release()
    {
        let body=Loadout.Body;int type=Pending.ItemType;
        body.UpdateCombatHealthEffects();body.UpdateActorOffensiveStatistics();
        int role=CaelumSupportImplementData.RoleForWeapon(type);
        if(CaelumSupportImplementData.ValidRole(role))
        {
            if(CaelumSupportImplementData.Area(role))
                return CaelumSupportMagic.ApplyArea(body,Recipient.Pos+(0,0,Recipient.Height/2),role,
                    CaelumSupportImplementData.BaseRadius()*Range()/CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS)>0;
            return CaelumSupportMagic.Apply(body,Recipient,role);
        }
        body.Angle=body.AngleTo(Recipient);
        vector3 aim=Recipient.Pos+(0,0,Recipient.Height/2)-body.Pos-(0,0,body.Height*CaelumAttackRules.NPC_MAGIC_LAUNCH_HEIGHT);
        body.Pitch=-VectorAngle(aim.XY.Length(),aim.Z);
        double accuracy=CaelumCombatAim.Accuracy(body,true);
        double minimum=Weapon.GetMinimumSpreadFor(type,body.CurrentCombatLucidity)*100/accuracy;
        double maximum=Weapon.GetMaximumSpreadFor(type,body.CurrentCombatLucidity)*100/accuracy;
        double chance=CaelumAttackRules.CriticalChance(Weapon.GetBaseCriticalChanceFor(type),
            CaelumConstants.BASE_CRITICAL_CHANCE_PERCENT+body.CalculateActorType2Percent(body.CombatEffectiveInsight),
            1,CaelumPersonalityRules.Critical(body));
        int damage=Max(1,int(Weapon.GetDamage()*body.CombatMagicalPushMultiplier*body.CombatHealthPerformanceMultiplier+0.5));
        double push=body.CombatMagicalPushMultiplier;
        if(Pending.EssenceType==CaelumConstants.ESSENCE_WATER)push*=CaelumConstants.ELEMENTAL_EXTREME_PUSH_MULTIPLIER;
        else if(Pending.EssenceType==CaelumConstants.ESSENCE_WIND)push*=CaelumConstants.ELEMENTAL_MODERATE_PUSH_MULTIPLIER;
        int count=type==CaelumConstants.WEAPON_TYPE_BELL ? CaelumConstants.WEAPON_BELL_PROJECTILE_COUNT : 1;
        int spawned=0;
        for(int i=0;i<count;i++)
        {
            int yawRoll=Random[CaelumStaffAccuracyYaw](-100000,100000);
            int pitchRoll=Random[CaelumStaffAccuracyPitch](-100000,100000);
            double yaw=body.Angle+(yawRoll<0 ? -1 : 1)*(minimum+(maximum-minimum)*Abs(yawRoll)/100000.0);
            double pitch=body.Pitch+(pitchRoll<0 ? -1 : 1)*(minimum+(maximum-minimum)*Abs(pitchRoll)/100000.0);
            Name projectileType=type==CaelumConstants.WEAPON_TYPE_BOOK ? 'CaelumHomingMagicProjectile'
                : type==CaelumConstants.WEAPON_TYPE_STATUETTE ? 'CaelumExplosiveMagicProjectile' : 'CaelumPlayerMagicProjectile';
            let shot=CaelumPlayerMagicProjectile(Actor.Spawn(projectileType,
                body.Pos+(Cos(yaw)*32,Sin(yaw)*32,body.Height*CaelumAttackRules.NPC_MAGIC_LAUNCH_HEIGHT),NO_REPLACE));
            if(shot==null)continue;
            spawned++;shot.Target=body;shot.Angle=yaw;shot.Pitch=pitch;
            double speed=type==CaelumConstants.WEAPON_TYPE_BOOK ? CaelumConstants.PROJECTILE_SPEED_FAST
                : type==CaelumConstants.WEAPON_TYPE_BELL ? CaelumConstants.PROJECTILE_SPEED_SLOW : CaelumConstants.PROJECTILE_SPEED_NORMAL;
            shot.Vel=(Cos(pitch)*Cos(yaw),Cos(pitch)*Sin(yaw),-Sin(pitch))*speed;
            double roll=Random[CaelumMagicalCritical](0,999999)/10000.0;
            shot.StoreCaelumAttackResult(damage,true,roll<chance,true,push);
            shot.StoreCaelumCriticalRoll(chance,roll);shot.StoreCaelumWeaponWearIdentity(type,Pending.Tier,Pending.EquipmentSize);
            shot.StoreCaelumElementalPayload(Pending.EssenceType,false,
                body.CalculateActorType4Percent(body.CombatCharisma+body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_CHARISMA)),
                body.CalculateActorType4Percent(body.CombatEmpathy+body.GetCombatArmorAttributeBonus(CaelumConstants.ATTRIBUTE_EMPATHY)));
            shot.UpdateCaelumElementalWorldSprite();shot.ConfigureCaelumTravelDistance(Range());
            let homing=CaelumHomingMagicProjectile(shot);
            if(homing!=null)homing.ConfigureCaelumSeeking(Range(),body.Angle,body.Pitch,maximum);
            let explosive=CaelumExplosiveMagicProjectile(shot);
            if(explosive!=null)explosive.ConfigureCaelumExplosion(damage,
                CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS*Range()/CaelumConstants.ESSENCE_BASE_RANGE_MAP_UNITS);
        }
        return spawned>0;
    }
}
