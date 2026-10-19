// Blanco controlado: movimiento y AI detenidos, receptor de daño de producción.
class CA309Target : CaelumCombatActor
{
    int Hits,InputDamage,HealthLoss;
    bool Blunt;
    override void Tick() {}
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        let user=CaelumPlayer(source);
        if(user!=null)
        {
            Hits++;Blunt=user.ThermalBluntDelivery;InputDamage=damage;
        }
        int before=health;
        int result=Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
        HealthLoss+=before-health;
        return result;
    }
    Default { Radius 64; Height 256; Health 1000000; Mass 100; +SHOOTABLE; +SOLID; +NOGRAVITY; }
    States { Spawn: TNT1 A -1; Stop; }
}

// #309: entradas nativas, sin reemplazar la lógica de combate del jugador.
class CA309Probe : EventHandler
{
    CaelumPlayer User;
    CaelumEquipmentItem Item;
    CaelumEquipmentItem SwitchingOriginal;
    int Passed,Failed,Type;
    int BeganAt,CompletedAt,Resets,Transitions;
    int MagazineMaximum;
    bool Observing,PreviousActive,Completed,ObservedShot;
    double PreviousRemaining;
    CA309Target Victim;
    int InputSide;
    int SavedItemId,SavedDurability,SavedAmmo,SavedMagazine;
    double SavedRemaining;
    bool Manual;
    bool MagicObserving;
    int MagicShots,MagicExpectedShots;
    double MagicStartingAnima,MagicExpectedCost;

    override void WorldThingSpawned(WorldEvent e)
    {
        if(!MagicObserving || !(e.Thing is 'CaelumPlayerMagicProjectile'))return;
        MagicShots++;
        // El pago ocurre antes de Spawn, sin regeneración intercalada entre
        // proyectiles. Comprobar cada uno descubre pagos repetidos por perdigón.
        double spent=MagicStartingAnima-User.CurrentAnima;
        Console.Printf("CA309 MAGIC_PAYMENT shot=%d spent=%.9f expected=%.9f",MagicShots,spent,MagicExpectedCost);
        Check(Abs(spent-MagicExpectedCost)<0.000001,"native cast pays exactly one authored Anima cost");
    }

    void BeginMagic(bool charged)
    {
        Begin();Observing=false;MagicShots=0;
        Check(User.WeaponChargedStateActive==charged,"native charged state matches requested test case");
        MagicExpectedShots=Type==CaelumConstants.WEAPON_TYPE_BELL?12:1;
        MagicStartingAnima=User.DerivedStats.MaximumAnima;
        User.CurrentAnima=MagicStartingAnima;
        MagicExpectedCost=User.WeaponModel.GetAnimaCostFor(Type)
            *User.DerivedStats.StaffAnimaCost/CaelumConstants.DEBUG_STAFF_ANIMA_COST;
        if(Item.Tier==2)MagicExpectedCost*=1.6;else if(Item.Tier==3)MagicExpectedCost*=2.5;
        if(charged)MagicExpectedCost*=CaelumConstants.WEAPON_CHARGED_COST_MULTIPLIER;
        Check(MagicStartingAnima>=MagicExpectedCost,"fixture has sufficient authored resources");
        MagicObserving=true;
    }

    void CheckMagic()
    {
        MagicObserving=false;
        Console.Printf("CA309 MAGIC type=%d tier=%d essence=%d shots=%d",Type,Item.Tier,Item.EssenceType,MagicShots);
        Check(MagicShots==MagicExpectedShots && User.LastStaffCastCompleted,"native cast completes with authored projectile count");
        Check(User.ActiveWeaponItemId==Item.ItemId && Item.Owner==User,"cast keeps actual equipment identity");
    }

    override void RenderOverlay(RenderEvent e)
    {
        if(!Manual || automapactive || menuactive!=Menu.Off)return;
        let font=Font.GetFont("CaelumText");if(font==null)return;
        String lines[]={"#309: F6 espada | F7 varita | F8 escopeta | F9 guanteletes",
            "Manten R: una sola carga. Suelta y pulsa para iniciar otra.",
            "Escopeta vacia: manten disparo. Debe recargar y disparar.",
            "Boton izquierdo/derecho: ataques. F10: reiniciar la prueba."};
        for(int i=0;i<4;i++)Screen.DrawText(font,Font.CR_WHITE,16,8+i*(font.GetHeight()+2),lines[i],DTA_SHADOW,true);
    }

    void Check(bool ok,String label)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA309 %s type=%d %s",ok?"PASS":"FAIL",Type,label);
    }

    override void UiTick()
    {
        if(Manual)return;
        if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }

    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.InitializeDirectMapCharacter();User.CharacterCreationComplete=true;
        User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.bInvulnerable=true;User.bNOTARGET=true;
        User.CurrentSleep=User.CurrentLucidity=100;
        User.CurrentHunger=User.CurrentThirst=75;
        Name ammo[]={"CaelumCarbineAmmo","CaelumShotgunAmmo","CaelumArrowAmmo","CaelumBoltAmmo"};
        for(int i=0;i<4;i++)
        {
            let stock=Inventory(Actor.Spawn(ammo[i]));stock.Amount=100;
            stock.AttachToOwner(User);
        }
        User.OnNativeInventoryChanged();
    }

    void Equip(int kind,int tier,int essence,bool isolated=true)
    {
        Observing=false;Type=kind;
        if(isolated)
        {
            User.CancelWeaponCharge();User.CancelRangedReload();User.CancelRangedAim();
            User.CancelCombatBlockMode();User.CancelPendingStaffCast(false);
        }
        if(Item!=null){Item.Equipped=false;if(isolated)Item.Destroy();}
        Item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",User.Pos,NO_REPLACE));
        Item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Item.ItemType=kind;
        Item.Tier=tier;Item.EssenceType=essence;Item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        Item.Durability=User.WeaponModel.GetMaximumDurabilityFor(kind,tier,Item.EquipmentSize);
        Item.UnitWeight=User.WeaponModel.GetWeightFor(kind,tier,Item.EquipmentSize);
        Item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        Item.PickupDataInitialized=true;Item.AcquisitionResolved=true;Item.Equipped=true;
        Item.AttachToOwner(User);User.EnsureEquipmentItemId(Item);
        User.ActivateExactEquippedWeapon(Item);User.EnsureWeaponFamilySelectors();
        User.SelectNativeWeaponConfiguration(kind,essence,tier);
        User.SetRangedMagazineCount(kind,0);
        User.CurrentAir=User.DerivedStats.MaximumAir;User.CurrentAnima=User.DerivedStats.MaximumAnima;
        User.OnNativeInventoryChanged();
    }

    void Begin()
    {
        Check(User.ActiveWeaponItemId==Item.ItemId && User.WeaponModel.WeaponType==Type,
            "native selector retains exact item");
        Check(User.player.ReadyWeapon!=null
            && User.player.ReadyWeapon.GetClassName()==User.GetNativeWeaponSelectorClass(Type,Item.EssenceType,Item.Tier),
            "requested selector is ready");
        Observing=true;PreviousActive=false;PreviousRemaining=0;
        BeganAt=level.time;CompletedAt=-1;Resets=Transitions=0;Completed=false;
        MagazineMaximum=0;ObservedShot=false;User.LastCarbineFired=false;
        Console.Printf("CA309 BEGIN type=%d charge=%.6f reload=%.6f",Type,
            CaelumConstants.WEAPON_CHARGE_BASE_SECONDS*(User.WeaponModel.IsMagical()?User.DerivedStats.CastingDurationMultiplier:User.DerivedStats.AttackDurationMultiplier),
            User.GetRangedEffectiveReloadSeconds(Type));
    }

    override void WorldTick()
    {
        if(!Observing || User==null)return;
        ObservedShot=ObservedShot || User.LastCarbineFired;
        bool ranged=User.IsRangedWeaponType(Type);
        bool active=ranged?User.RangedReloadActive:User.WeaponChargeActive;
        double remaining=ranged?User.RangedReloadRemainingSeconds:User.WeaponChargeRemainingSeconds;
        if(active && !PreviousActive)Transitions++;
        if(active && PreviousActive && remaining>PreviousRemaining+0.000001)Resets++;
        bool ready=ranged?User.GetRangedMagazineCount(Type)>0:User.WeaponChargedStateActive;
        MagazineMaximum=Max(MagazineMaximum,User.GetRangedMagazineCount(Type));
        if(ready && !Completed){Completed=true;CompletedAt=level.time;}
        PreviousActive=active;PreviousRemaining=remaining;
    }

    void Verify(bool held)
    {
        bool baseline=CVar.FindCVar("ca309_baseline").GetBool();
        Console.Printf("CA309 OBSERVED type=%d held=%d complete=%d elapsed=%d transitions=%d resets=%d remaining=%.6f",
            Type,held,Completed,Completed?CompletedAt-BeganAt:-1,Transitions,Resets,PreviousRemaining);
        Check(Completed==!(baseline && held),"completion agrees with declared baseline/fixed expectation");
        if(!(baseline && held))Check(Transitions==1,"one request starts exactly one action");
        Observing=false;
    }

    void Catalogue()
    {
        let model=new("CaelumWeaponModel");model.InitializeDefaults();int rows=0;
        for(int kind=0;kind<CaelumConstants.WEAPON_TYPE_COUNT;kind++)
        for(int tier=1;tier<=(CaelumWeaponModel.IsSingleTierType(kind)?1:3);tier++)
        for(int essence=0;essence<(model.IsMagicalType(kind)?CaelumConstants.ESSENCE_TYPE_COUNT:1);essence++)
        {
            Type=kind;model.WeaponType=kind;model.Tier=tier;model.EssenceType=essence;
            let selector=Actor.Spawn(User.GetNativeWeaponSelectorClass(kind,essence,tier));
            let physical=CaelumPhysicalSelectorWeapon(selector);let magic=CaelumMagicSelectorWeapon(selector);
            bool identity=physical!=null && physical.GetCaelumWeaponType()==kind;
            if(magic!=null)identity=magic.GetCaelumWeaponType()==kind
                && magic.GetCaelumTier()==tier && magic.GetCaelumEssenceType()==essence;
            Check(identity,String.Format("selector type/tier/essence %d/%d/%d",kind,tier,essence));
            int id=CaelumCraftingRules.GetCatalogueWeaponForPlayableType(kind);
            Console.Printf("CA309 ROW type=%d tier=%d essence=%d catalogue=%d damage=%.9f weight=%.9f durability=%d anima=%.9f air=%.9f selector=%s",
                kind,tier,essence,id,model.GetDamage(),model.GetWeight(),model.GetMaximumDurability(),
                model.GetAnimaCostFor(kind),model.GetAirCostFor(kind),selector==null?'None':selector.GetClassName());
            if(id>=0)Console.Printf("CA309 PHYSICAL type=%d tier=%d primaryType=%d secondaryType=%d secondaryBase=%.9f primaryRange=%.9f secondaryRange=%.9f secondaryAir=%.9f baseTics=%d",
                kind,tier,CaelumWeaponCatalogue.GetPrimaryDamageType(id),CaelumWeaponCatalogue.GetSecondaryDamageType(id),
                CaelumWeaponCatalogue.GetSecondaryDamage(id),CaelumWeaponCatalogue.GetPrimaryRange(id),
                CaelumWeaponCatalogue.GetSecondaryRange(id),CaelumWeaponCatalogue.GetSecondaryAirCost(id),CaelumWeaponCatalogue.GetAttackTics(id));
            rows++;if(selector!=null)selector.Destroy();
        }
        Check(rows==111,"all 51 physical/tool and 60 magical configurations inventoried");
    }

    void Gauntlet(int side,bool cold)
    {
        Equip(CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS,1,0);InputSide=side;
        if(Victim!=null)Victim.Destroy();
        User.Angle=User.Pitch=0;User.SetOrigin((0,0,0),false);
        Victim=CA309Target(Actor.Spawn("CA309Target",(80,0,0),NO_REPLACE));
        Victim.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
        Victim.health=1000000;
        // El blanco base no crea fisiología automáticamente; dar estado vigente
        // al adaptador evita introducir AI o inventarios de un residente real.
        Victim.ThermalState=new("CaelumThermalState");
        let thermal=Victim.ThermalState;thermal.Initialize();CaelumThermalBody.Refresh(Victim,thermal);
        thermal.Exposure=cold?-CaelumThermalData.ExposureThreshold(2)*CaelumThermalRules.ThresholdScale(thermal.Toughness):0;
        Console.Printf("CA309 GAUNTLET side=%d cold=%d exposure=%.6f",side,cold,thermal.Exposure);
    }

    void CheckGauntlet()
    {
        Console.Printf("CA309 GAUNTLET_RESULT side=%d hits=%d blunt=%d raw=%d lost=%d",InputSide,Victim.Hits,Victim.Blunt,Victim.InputDamage,Victim.HealthLoss);
        Check(Victim.Hits==1 && Victim.HealthLoss>0,"one native gauntlet hit reaches production receiver");
        bool old=CVar.FindCVar("ca309_baseline").GetBool();
        Check(Victim.Blunt==!(old && InputSide!=0),"native impact classification matches baseline/fixed expectation");
        Victim.Destroy();Victim=null;
    }

    void Snapshot()
    {
        SavedItemId=Item.ItemId;SavedDurability=Item.Durability;
        SavedMagazine=User.GetRangedMagazineCount(Type);
        let ammo=User.FindNativeAmmunition(User.GetRangedAmmoType(Type));
        SavedAmmo=ammo==null?-1:ammo.Amount;
        SavedRemaining=User.IsRangedWeaponType(Type)?User.RangedReloadRemainingSeconds:User.WeaponChargeRemainingSeconds;
        Check(SavedRemaining>0,"snapshot contains an in-progress native action");
        Console.Printf("CA309 SNAPSHOT id=%d durability=%d ammo=%d magazine=%d remaining=%.9f buttons=%d old=%d",
            SavedItemId,SavedDurability,SavedAmmo,SavedMagazine,SavedRemaining,User.player.cmd.buttons,User.player.oldbuttons);
    }

    void Restored(bool away=false)
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        let active=User.FindNativeEquipmentItemById(User.ActiveWeaponItemId);
        Check(active!=null && active.Owner==User && active.Equipped,"travel/load retains an owned equipped item");
        if(away)return;
        // El pawn viaja; una referencia guardada en el handler del mapa puede
        // quedar nula. Recuperar el mismo ItemId desde su propietario real.
        Check(active.ItemId==SavedItemId && (Item==null || active==Item)
            && active.ItemType==Type,"same serialized item identity survives");
        Item=active;
        Check(active.Durability==SavedDurability,"transition does not wear equipment");
        let ammo=User.FindNativeAmmunition(User.GetRangedAmmoType(Type));
        Check((ammo==null?-1:ammo.Amount)==SavedAmmo && User.GetRangedMagazineCount(Type)==SavedMagazine,"transition preserves ammunition");
        double remaining=User.IsRangedWeaponType(Type)?User.RangedReloadRemainingSeconds:User.WeaponChargeRemainingSeconds;
        Check(remaining>0 && remaining<=SavedRemaining,"active timer resumes without restarting");
        Console.Printf("CA309 RESTORED id=%d remaining=%.9f buttons=%d old=%d",active.ItemId,remaining,User.player.cmd.buttons,User.player.oldbuttons);
    }

    void Switched()
    {
        // Conservar el objeto original y cambiar a otro mediante la autoridad real.
        SwitchingOriginal=Item;
        Check(User.WeaponChargeActive || User.RangedReloadActive,"real switch starts during an active action");
        Equip(Type==0?1:0,2,0,false);
        Check(!User.WeaponChargeActive && !User.RangedReloadActive,"switch cancels pending action");
    }

    void SwitchBack()
    {
        let original=SwitchingOriginal;
        Check(User.player.ReadyWeapon.GetClassName()==User.GetNativeWeaponSelectorClass(Type,Item.EssenceType,Item.Tier),"intermediate native weapon finishes switching");
        original.Equipped=true;
        User.ActivateExactEquippedWeapon(original);
        User.EnsureWeaponFamilySelectors();
        User.SelectNativeWeaponConfiguration(original.ItemType,original.EssenceType,original.Tier);
        Check(User.ActiveWeaponItemId==original.ItemId && original.Owner==User,"switch back retains original owned item");
        Check(!User.WeaponChargeActive && !User.WeaponChargedStateActive && !User.RangedReloadActive,"switch back does not revive cancelled action");
        Item.Equipped=false;Item.Destroy();Item=original;Type=Item.ItemType;SwitchingOriginal=null;
    }

    void ManualSetup()
    {
        Setup();Manual=true;User.SetOrigin((0,0,0),false);User.Angle=User.Pitch=0;
        Actor.Spawn("CaelumTrainingDummy",(100,0,0),NO_REPLACE);
        Actor.Spawn("CaelumTrainingDummy",(320,-160,0),NO_REPLACE);
        Actor.Spawn("CaelumTrainingDummy",(320,160,0),NO_REPLACE);
        Equip(0,1,0);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c309_setup")Setup();
        if(e.Name=="c309_equip")Equip(e.Args[0],e.Args[1],e.Args[2]);
        if(e.Name=="c309_begin")Begin();
        if(e.Name=="c309_check")Verify(e.Args[0]!=0);
        if(e.Name=="c309_catalogue")Catalogue();
        if(e.Name=="c309_gauntlet")Gauntlet(e.Args[0],e.Args[1]!=0);
        if(e.Name=="c309_gauntlet_check")CheckGauntlet();
        if(e.Name=="c309_snapshot")Snapshot();
        if(e.Name=="c309_restored")Restored(e.Args[0]!=0);
        if(e.Name=="c309_switched")Switched();
        if(e.Name=="c309_switch_back")SwitchBack();
        if(e.Name=="c309_manual")ManualSetup();
        if(e.Name=="c309_magic_begin")BeginMagic(e.Args[0]!=0);
        if(e.Name=="c309_magic_check")CheckMagic();
        if(e.Name=="c309_stun")User.LucidityPhysicalStunRemaining=2;
        if(e.Name=="c309_cancelled")Check(!User.WeaponChargeActive && !User.WeaponChargedStateActive && !User.RangedReloadActive,"immobilization cancels action");
        if(e.Name=="c309_empty")
        {
            let ammo=User.FindNativeAmmunition(User.GetRangedAmmoType(Type));if(ammo!=null)ammo.Destroy();
            User.SetRangedMagazineCount(Type,0);User.OnNativeInventoryChanged();
        }
        if(e.Name=="c309_empty_check")Check(!User.RangedReloadActive && !User.LastCarbineFired && User.GetRangedMagazineCount(Type)==0,"empty reserve cannot reload or fire");
        if(e.Name=="c309_auto")
        {
            Console.Printf("CA309 AUTO type=%d complete=%d maximum=%d fired=%d",Type,Completed,MagazineMaximum,ObservedShot);
            Check(Completed==!CVar.FindCVar("ca309_baseline").GetBool(),"held Fire permits automatic reload progress");
            if(!CVar.FindCVar("ca309_baseline").GetBool())Check(ObservedShot,"held Fire eventually delivers native shot");
            Observing=false;
        }
        if(e.Name=="c309_done")Console.Printf("CA309 DONE passes=%d failures=%d",Passed,Failed);
    }
}
