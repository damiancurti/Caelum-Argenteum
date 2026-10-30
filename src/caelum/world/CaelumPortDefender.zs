// Soldados nuevos: apariencia de Domingo sin identidad, inventario ni misiones
// del jugador. Perfil, escudo, armadura y espada usan el catálogo compartido.
class CaelumPortDefender : CaelumFolkloreCombatActor
{
    CaelumPortSiege Port;
    CaelumHouseResident Residence;
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
    override CaelumWeaponModel GetPossessedSidearm(){return Sword;}
    CaelumCityCarbine Carbine;
    int WardrobeRevision, WardrobeFace;
    bool WardrobeApplied;
    transient bool WardrobeCacheReady;
    transient int WardrobeCachedFace, WardrobeSprite, WardrobeCarbineSprite, WardrobeCrouchSprite, WardrobeWalkSprite, WardrobeMeleeSprite;

    void RestoreWardrobeState()
    {
        if(!WardrobeApplied || CurState==null)return;
        sprite=CurState.sprite;frame=CurState.Frame;WardrobeApplied=false;
    }

    void ApplyWardrobe()
    {
        // Los bandidos heredan combate, no el uniforme de la guardia.
        if(GetClassName()!='CaelumPortDefender' || CurState==null)return;
        if(WardrobeRevision==0 && HomeRevision>0)
        {
            WardrobeFace=Abs(HomeIdentity)%CaelumPortWardrobeData.FACE_COUNT;
            WardrobeRevision=CaelumPortWardrobeData.REVISION;
        }
        // Los índices nativos se resuelven una vez por cuerpo/carga, nunca se guardan.
        if(!WardrobeCacheReady || WardrobeCachedFace!=WardrobeFace)
        {
            WardrobeSprite=CaelumPortWardrobeData.SpriteFor(self,WardrobeFace);
            WardrobeCarbineSprite=GetSpriteIndex("CAGN");WardrobeCrouchSprite=GetSpriteIndex("CAGC");
            WardrobeWalkSprite=GetSpriteIndex("DOWK");WardrobeMeleeSprite=GetSpriteIndex("DOMI");
            WardrobeCachedFace=WardrobeFace;WardrobeCacheReady=true;
        }
        int visualFrame=CaelumPortWardrobeData.FrameFor(self);
        sprite=WardrobeSprite;
        frame=visualFrame;
        double ratio=GetPhysiologicalHeight()/CaelumAppearanceRegistry.StandingHeight(0,true);
        Scale=(ratio,ratio);WardrobeApplied=true;
    }
    virtual bool CarbineTarget(Actor victim){return victim!=null && !victim.bFriendly;}
    override double GetPhysiologicalHeight()
    { return Carbine!=null && Carbine.StandingHeight>0 ? Carbine.StandingHeight : Height; }
    int HomeRevision, HomeIdentity, DeploymentStep;
    bool DeploymentComplete;
    CaelumHingedDoorLeaf HomeDoor;
    CaelumPortDefender YieldFor;
    vector3 YieldDestination;
    bool ReturningFromYield;
    CaelumCityNavigation CityNavigation;
    int PassageRequestTic;

    void RequestFormationPassage(CaelumPortDefender arriving)
    {
        if(arriving==null || arriving==self || Gun!=null || !DeploymentComplete || health<=0
            || HomeRevision==0 || HomeIdentity<CaelumCityData.CREW_COUNT)return;
        vector2 inward=CaelumCityData.FormationInward(HomeIdentity-CaelumCityData.CREW_COUNT);
        vector3 arrival=arriving.HomeIdentity<CaelumCityData.CREW_COUNT
            ? CaelumPropertyRoutes.Point(arriving.HomeIdentity,CaelumPropertyRoutes.Count(arriving.HomeIdentity)-1) : arriving.Station;
        vector2 separation=Station.XY-arrival.XY;
        // Un puesto profundo nunca se vacía para llenar otro más superficial.
        // Los últimos en entrar ceden espacio hacia el lado abierto de la ciudad.
        if((separation Dot inward)<=0 || separation.Length()>CaelumCityData.TRANSIT_WAYPOINT_REACH*4)return;
        if(YieldFor!=null && (!YieldFor.DeploymentComplete || YieldFor.ReturningFromYield || YieldFor.FollowingCrewRoute) && YieldFor.health>0)return;
        double clear=Radius+arriving.Radius;
        vector2 side=(-inward.Y,inward.X);
        if(arriving.HomeIdentity%2==0)side=-side;
        vector2 point=Station.XY+inward*clear*4+side*clear*2;
        YieldDestination=(point.X,point.Y,Station.Z);YieldFor=arriving;ReturningFromYield=true;
    }

    void RequestApproachPassage(vector3 destination)
    {
        if(Port==null || level.time<PassageRequestTic
            || (Pos.XY-destination.XY).Length()>CaelumCityData.TRANSIT_WAYPOINT_REACH*4)return;
        PassageRequestTic=level.time+TICRATE;
        // Abrir la columna de acceso desde la ciudad antes de quedar rodeado
        // por puestos ya ocupados. Sólo se apartan filas más superficiales.
        for(int i=CaelumCityData.CREW_COUNT;i<Port.Defenders.Size();i++)
        {
            let other=Port.Defenders[i];if(other==null || !other.DeploymentComplete)continue;
            vector2 inward=CaelumCityData.FormationInward(other.HomeIdentity-CaelumCityData.CREW_COUNT);
            vector2 side=(-inward.Y,inward.X);
            if(Abs((other.Station.XY-destination.XY) Dot side)<Radius+other.Radius)
                other.RequestFormationPassage(self);
        }
    }

    bool FormationPassage()
    {
        if(!ReturningFromYield)return false;
        if(Gun!=null){ReturningFromYield=false;YieldFor=null;return false;}
        if(YieldFor!=null && (YieldFor.health<=0 || (YieldFor.DeploymentComplete && !YieldFor.ReturningFromYield && !YieldFor.FollowingCrewRoute)))YieldFor=null;
        vector3 point=YieldFor==null ? Station : YieldDestination;
        if(YieldFor==null)RequestApproachPassage(Station);
        if((Pos-point).Length()<=1)
        {if(YieldFor==null)ReturningFromYield=false;return true;}
        if(NavigationTarget==null)NavigationTarget=Spawn("CaelumSewerEscapeTarget",point);
        if(!InStateSequence(CurState,SeeState))SetState(SeeState);
        else CaelumPortSiege.WalkTo(self,NavigationTarget,point);
        return true;
    }

    void AssignHome(int identity)
    {
        HomeIdentity=identity;HomeRevision=CaelumCityData.PERSISTENCE_REVISION;
        if(Carbine==null)Carbine=new("CaelumCityCarbine");Carbine.Initialize(self);
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            if(leaf.args[0]==CaelumCityData.DoorGroup(CaelumPropertyData.ResidentHouse(identity)))
            {HomeDoor=leaf;break;}
    }

    bool AdvanceDeployment()
    {
        if(HomeRevision==0 || DeploymentComplete)return false;
        int house=CaelumPropertyData.ResidentHouse(HomeIdentity);
        if(DeploymentStep<=1 && HomeDoor!=null
            && (Pos-CaelumCityData.DoorInside(house)).Length()<=128
            && (!HomeDoor.DoorRequested || HomeDoor.HoldTimer<18))HomeDoor.RequestDoorGroup(self);
        int count=CaelumPropertyRoutes.Count(HomeIdentity)+3;
        // El último centro de celda puede caer sobre el puesto de otro guardia.
        // Cerca del destino real, pasar a él y resolver la colisión local allí.
        vector3 destination=CaelumPropertyRoutes.Point(HomeIdentity,count-4);
        RequestApproachPassage(destination);
        if(DeploymentStep>=3 && (Pos.XY-destination.XY).Length()<=CaelumCityData.TRANSIT_WAYPOINT_REACH*2)
            DeploymentStep=count-1;
        while(DeploymentStep<count)
        {
            vector3 point=DeploymentStep==0 ? CaelumCityData.DoorInside(house)
                : DeploymentStep==1 ? CaelumCityData.DoorOutside(house)
                : DeploymentStep==2 ? CaelumCityData.HouseRoad(house)
                : CaelumPropertyRoutes.Point(HomeIdentity,DeploymentStep-3);
            // Los puntos compartidos son pasos, no puestos de formación:
            // dos cuerpos pueden cruzarlos sin exigir ocupar el mismo centro.
            double reach=DeploymentStep<=1 ? Radius : Max(Radius,CaelumCityData.TRANSIT_WAYPOINT_REACH);
            if(DeploymentStep>=3)reach=Radius*2;
            if(DeploymentStep==count-1)reach=Gun==null ? 1 : Radius*2;
            if(DeploymentStep>=3 && DeploymentStep<count-1
                && (Pos.XY-point.XY).Length()<=CaelumCityData.TRANSIT_WAYPOINT_REACH*2
                && !CheckMove(point.XY,PCM_DROPOFF) && BlockingMobj is "CaelumPortDefender")
            {DeploymentStep++;continue;}
            if((Pos.XY-point.XY).Length()<=reach && Abs(Pos.Z-point.Z)<=MaxStepHeight)
            {DeploymentStep++;continue;}
            if(NavigationTarget==null)NavigationTarget=Spawn("CaelumSewerEscapeTarget",point);
            if(!InStateSequence(CurState,SeeState))SetState(SeeState);
            else CaelumPortSiege.WalkTo(self,NavigationTarget,point);
            return true;
        }
        DeploymentComplete=true;
        if(Gun!=null && Port!=null)
            for(int i=0;i<Port.Guns.Size();i++)
                if(Port.Guns[i]==Gun){BeginCrewRoute(i-6);break;}
        return false;
    }

    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if ((level.MapName != "MAP03" && CaelumHouseHubData.HouseForMap(level.MapName)<0) || user == null || user.player == null
            || health <= 0 || !CaelumUseGeometry.AimedAt(user, self)) return false;
        if ((user.player.cmd.buttons & BT_USE) == 0 || user.FolkloreInteractionUseLatched)
            return true;
        user.FolkloreInteractionUseLatched = true;
        user.FolkloreInteractionReleaseGuardTics = 0;
        return CaelumGuardCaptainDialogue.Open(user, self);
    }

    override void Tick()
    {
        if(Companion!=null && Companion.Parked)return;
        // Un nacimiento que cruzó un mapa aún debe recibir PostBeginPlay nativo.
        // Después se archiva sin ejecutar combate en una casa que no está cargada.
        if(Residence!=null && Residence.Suspended)
        {
            if(HomeRevision>0 && Carbine==null){Carbine=new("CaelumCityCarbine");Carbine.Initialize(self);}
            bInvisible=true;bSolid=false;bShootable=false;bNoInteraction=true;
            A_ChangeLinkFlags(1,1);ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            for(Inventory item=Inv;item!=null;item=item.Inv)item.ChangeStatNum(CaelumHouseResidents.PARKED_STAT);
            return;
        }
        RestoreWardrobeState();
        CaelumCarbineWorld.Restore(self);
        Super.Tick();
        if(HomeRevision>0 && Carbine==null){Carbine=new("CaelumCityCarbine");Carbine.Initialize(self);}
        if(Carbine!=null)Carbine.Tick(self);
        ApplyWardrobe();
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
            double reach=HomeRevision>0 && CrewRouteStep==0 ? Radius*2 : Radius;
            if((point.XY-Pos.XY).Length()>reach || Abs(point.Z-Pos.Z)>MaxStepHeight)return point;
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

    virtual int BirthAttribute(){return CaelumPortData.DEFENDER_ATTRIBUTE;}

    override void PostBeginPlay()
    {
        if(DefenderBirthInitialized)return;
        DefenderBirthInitialized=true;
        Super.PostBeginPlay();
        Mass=CaelumPortData.DEFENDER_MASS_KG;
        A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
        InitializeUniformFolkloreProfile(BirthAttribute());
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_MEDIUM,CaelumPortData.EQUIPMENT_TIER);
        Shield=new("CaelumShieldModel");Shield.InitializeDefaults();
        Shield.ShieldType=CaelumConstants.SHIELD_TYPE_KITE;Shield.Equipped=true;
        Shield.Tier=CaelumPortData.EQUIPMENT_TIER;Shield.Durability=Shield.GetMaximumDurability();
        Sword=new("CaelumWeaponModel");Sword.InitializeDefaults();
        Sword.WeaponType=CaelumConstants.WEAPON_TYPE_SWORD;Sword.Equipped=true;
        Sword.Tier=CaelumPortData.EQUIPMENT_TIER;Sword.Durability=Sword.GetMaximumDurability();
        MeleeRange=CaelumWeaponCatalogue.GetPrimaryRange(CaelumConstants.CATALOGUE_WEAPON_SWORD);
    }

    bool DefenderBirthInitialized;

    override double GetAttackCarriedWeight()
    {
        let loadout=Companion!=null ? Companion.Loadout : null;
        return Super.GetAttackCarriedWeight()+(Shield==null || (loadout!=null && loadout.ShieldItem!=null) ? 0 : Shield.GetWeight())
            +(Sword==null || (loadout!=null && loadout.SidearmItem!=null) ? 0 : Sword.GetWeightFor(0,CaelumPortData.EQUIPMENT_TIER,CaelumConstants.EQUIPMENT_SIZE_M))
            +(Carbine==null || Carbine.Weapon==null ? 0 : Carbine.Weapon.GetWeightFor(Carbine.Weapon.WeaponType,Carbine.Weapon.Tier,Carbine.Weapon.Size));
    }

    override Sound GetCombatPainSound(){return "caelum/player/pain_male";}

    override double ResolveActorShieldDamage(Actor inflictor,Actor source,double damage,Name mod,int flags)
    {return CaelumActorShield.Resolve(self,Shield,Carbine!=null && Carbine.Held,inflictor,source,damage,mod,flags);}

    action void A_PortSword()
    {
        let soldier=CaelumPortDefender(self);
        if(soldier==null || soldier.Sword==null || soldier.Sword.Durability<=0)return;
        if(!soldier.WithinAttackRange(false))return;
        if(!soldier.SpendPhysicalAttackAir(CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_SWORD),
            CaelumThermalData.WeaponWork(CaelumConstants.WEAPON_TYPE_SWORD)))return;
        if(soldier.target==null || soldier.target.bFriendly)return;
        int damage=soldier.PrepareActorOutgoingDamage(CaelumWeaponCatalogue.GetPrimaryDamage(CaelumConstants.CATALOGUE_WEAPON_SWORD)
            *soldier.CalculateActorType1Percent(soldier.CombatStrength)/100.0,false,true);
        if(damage<=0 || !soldier.WeaponMeleeAimHits(soldier.Sword))
        {soldier.PendingCombatCriticalDelivery=false;return;}
        int before=soldier.target.health;
        soldier.DeliverContactMelee(damage,"weapons/swordhit");
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
    AbsentMeleePrepare:
        DOMI K 7 A_CaelumBeginResourceAttack(CaelumWeaponCatalogue.GetPrimaryAirCost(CaelumConstants.CATALOGUE_WEAPON_SWORD),CaelumConstants.WEAPON_TYPE_SWORD,false,CaelumAttackRules.SWING_IMPACT);
    AbsentMeleeRelease:
        DOMI L 0 A_PortSword;
    AbsentMeleeRecovery:
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
