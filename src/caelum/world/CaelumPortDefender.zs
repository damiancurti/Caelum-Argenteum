// Soldados nuevos: apariencia de Domingo sin identidad, inventario ni misiones
// del jugador. Perfil, escudo, armadura y espada usan el catálogo compartido.
class CaelumPortDefender : CaelumFolkloreCombatActor
{
    CaelumPortSiege Port;
    CaelumCannon Gun;
    Actor NavigationTarget;
    vector3 Station;
    int Lane;
    // Esquema de navegación 2: sólo se activa en el nuevo plano sur.
    // Los saves del frente norte conservan los campos por defecto y su puesto.
    bool FollowingCrewRoute;
    int CrewRouteGun, CrewRouteStep;
    CaelumShieldModel Shield;
    CaelumWeaponModel Sword;

    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if (level.MapName != "MAP06" || user == null || user.player == null
            || health <= 0 || !CaelumUseGeometry.AimedAt(user, self)) return false;
        if ((user.player.cmd.buttons & BT_USE) == 0 || user.FolkloreInteractionUseLatched)
            return true;
        user.FolkloreInteractionUseLatched = true;
        user.FolkloreInteractionReleaseGuardTics = 0;
        return CaelumGuardCaptainDialogue.Open(user, self);
    }

    override void Tick()
    {
        Super.Tick();
        // Reconstruir la primera/repetida charla desde el registro del hablante.
        // No alterar el nodo de una conversación que sigue abierta al cargar.
        if (!bInConversation && HasConversation())
            Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
                self, null, false, 0, 0);
    }

    void BeginCrewRoute(int index)
    {
        if(!CaelumPortData.IsSouth())return;
        CrewRouteGun=index;CrewRouteStep=0;FollowingCrewRoute=true;
        double best=1e30;
        if(NavigationTarget==null)NavigationTarget=Spawn("CaelumSewerEscapeTarget",Pos);
        for(int i=0;i<CaelumPortData.CrewRouteCount(index);i++)
        {
            vector3 point=CaelumPortData.CrewRoutePoint(index,i);
            if(Abs(point.Z-Pos.Z)>MaxStepHeight)continue;
            NavigationTarget.SetOrigin(point,false);
            double distance=(point-Pos).Length();
            if(distance<best && CheckSight(NavigationTarget)){best=distance;CrewRouteStep=i;}
        }
    }

    vector3 CrewPost()
    {
        if(Gun==null || !FollowingCrewRoute){FollowingCrewRoute=false;return Station;}
        int count=CaelumPortData.CrewRouteCount(CrewRouteGun);
        while(CrewRouteStep<count)
        {
            vector3 point=CaelumPortData.CrewRoutePoint(CrewRouteGun,CrewRouteStep);
            if((point.XY-Pos.XY).Length()>Radius || Abs(point.Z-Pos.Z)>MaxStepHeight)return point;
            CrewRouteStep++;
        }
        if(CrewRouteStep==count)
        {
            vector3 last=CaelumPortData.CrewRoutePoint(CrewRouteGun,count-1);
            vector3 side=Station;
            if(Station.X!=Gun.Pos.X)side.Y=last.Y;else side.X=last.X;
            side.Z=last.Z;
            if((side-Pos).Length()>Radius)return side;
            CrewRouteStep++;
        }
        if((Station-Pos).Length()>Radius)return Station;
        FollowingCrewRoute=false;return Station;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        Mass=CaelumPortData.DEFENDER_MASS_KG;
        A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
        InitializeUniformFolkloreProfile(CaelumPortData.DEFENDER_ATTRIBUTE);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MEDIUM,CaelumPortData.EQUIPMENT_TIER);
        Shield=new("CaelumShieldModel");Shield.InitializeDefaults();
        Shield.ShieldType=CaelumConstants.SHIELD_TYPE_KITE;Shield.Equipped=true;
        Shield.Tier=CaelumPortData.EQUIPMENT_TIER;Shield.Durability=Shield.GetMaximumDurability();
        Sword=new("CaelumWeaponModel");Sword.InitializeDefaults();
        Sword.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;Sword.Equipped=true;
        Sword.Tier=CaelumPortData.EQUIPMENT_TIER;Sword.Durability=Sword.GetMaximumDurability();
        MeleeRange=CaelumWeaponCatalogue.GetPrimaryRange(CaelumConstants.CATALOGUE_WEAPON_SWORD);
    }

    override double GetAttackCarriedWeight()
    {
        return Super.GetAttackCarriedWeight()+(Shield==null ? 0 : Shield.GetWeight())
            +(Sword==null ? 0 : Sword.GetWeightFor(0,CaelumPortData.EQUIPMENT_TIER,CaelumConstants.EQUIPMENT_SIZE_M));
    }

    override Sound GetCombatPainSound(){return "caelum/player/pain_male";}

    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double direction)
    {
        Actor attacker=source!=null ? source : inflictor;
        bool blocking=health>0 && !bInvulnerable && Shield!=null && Shield.Durability>0
            && attacker!=null && attacker!=self && damage>0
            && mod!='CaelumImpact' && mod!='Crush' && mod!='CaelumWeight'
            && !(mod=='Electric' && inflictor is "CaelumChannelEffect")
            && !InStateSequence(CurState,MeleeState)
            && Abs(DeltaAngle(Angle,AngleTo(attacker)))<=Shield.GetCoverageDegrees()/2.0;
        if(blocking)
        {
            int kind=mod=='CaelumMagicTest' ? CaelumConstants.SHIELD_DAMAGE_MAGICAL
                : CaelumConstants.SHIELD_DAMAGE_PHYSICAL;
            double absorbed=damage*Clamp(Shield.GetDefense(kind)/100.0,0,1);
            damage=Max(0,int(damage-absorbed+0.5));
            double wear=absorbed;
            int loss=int(wear/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY);
            double remainder=wear-loss*CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
            if(Random[CaelumShieldDurability](0,999999)/10000.0
                < remainder/CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT)loss++;
            Shield.Durability=Max(0,Shield.Durability-loss);
            if(absorbed>0)AddActorCombatAdrenaline(CaelumConstants.ADRENALINE_GAIN_ON_SHIELD_BLOCK
                *CaelumConstants.SHIELD_KITE_BLOCK_ADRENALINE_MULTIPLIER);
        }
        return Super.DamageMobj(inflictor,source,damage,mod,flags,direction);
    }

    action void A_PortSword()
    {
        let soldier=CaelumPortDefender(self);
        if(soldier==null || soldier.Sword==null || soldier.Sword.Durability<=0)return;
        if(!soldier.WithinAttackRange(false))return;
        if(!soldier.SpendPhysicalAttackAir(CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_SWORD)))return;
        if(soldier.target==null || soldier.target.bFriendly)return;
        int damage=soldier.PrepareActorOutgoingDamage(CaelumWeaponCatalogue.GetPrimaryDamage(CaelumConstants.CATALOGUE_WEAPON_SWORD)
            *soldier.CalculateActorType1Percent(soldier.CombatStrength)/100.0,false);
        int before=soldier.target.health;
        soldier.A_CustomMeleeAttack(damage,"weapons/swordhit");
        if(soldier.target.health<before)
        {
            double wear=before-soldier.target.health;
            int loss=int(wear/CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY);
            double remainder=wear-loss*CaelumConstants.ARMOR_ABSORBED_DAMAGE_PER_GUARANTEED_DURABILITY;
            if(Random[CaelumWeaponDurability](0,999999)/10000.0
                < remainder/CaelumConstants.ARMOR_DAMAGE_PER_DURABILITY_CHANCE_PERCENT)loss++;
            soldier.Sword.Durability=Max(0,soldier.Sword.Durability-loss);
            soldier.ApplyActorAttackPush(soldier.target,soldier.AngleTo(soldier.target),soldier.CombatPhysicalPushMultiplier);
        }
        soldier.PendingCombatCriticalDelivery=false;
    }

    override void OnDestroy()
    {
        if(NavigationTarget!=null)NavigationTarget.Destroy();
        Super.OnDestroy();
    }

    Default
    {
        Tag "$CA_PORT_SOLDIER";
        Monster; +FRIENDLY -COUNTKILL +LOOKALLAROUND
        Scale 0.409091;
    }
    States
    {
    Spawn:
        DOID A 10 A_CaelumBudgetedLook;
        Loop;
    See:
        DOWK AB 4 A_CaelumBudgetedChase;
        Loop;
    Melee:
        DOMI K 7 A_CaelumBeginResourceAttack(CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_SWORD),CaelumConstants.WEAPON_TYPE_SWORD,false,0.5);
        DOMI L 0 A_PortSword;
        DOMI Q 7 A_CaelumWeaponRecovery;
        Goto See;
    Pain:
        DOMI A 4 A_Pain;
        Goto See;
    Death:
        DOMI S 8 A_Scream;
        DOMI TU 8;
        DOMI V 8 A_NoBlocking;
        DOMI WXY 8;
        DOMI Z -1;
        Stop;
    LucidityStun:
        DOMI A 1;
        Goto See;
    }
}
