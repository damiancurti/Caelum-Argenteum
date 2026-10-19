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

class CA313VisibleTarget : CA309Target
{
    States { Spawn: CDMY A -1; Stop; }
}

// Reutiliza preparación y selección nativa del #309; no reemplaza combate.
class CA313Probe : CA309Probe
{
    bool Baseline,TrackShots,Ready;
    int Checks,Errors,Shots,BeforeCount,BeforeMagazine;
    double BeforeWeight,SavedWeight,SavedUnit;
    CaelumCarbineProjectile SavedFlight;
    vector3 SavedVelocity;
    int FlightDamage,FlightType,FlightTier,ViewCarbine,ViewShells;
    double ViewCarbineMass,ViewShellMass;

    void Verify(String label,double actual,double expected,double tolerance=0.000001)
    {
        bool ok=Abs(actual-expected)<=tolerance;if(ok)Checks++;else Errors++;
        Console.Printf("CA194 %s %s actual=%.9f expected=%.9f",ok?"PASS":"FAIL",label,actual,expected);
    }
    double Unit(int kind)
    {
        if(kind==0)return Baseline?0.003:0.040;
        if(kind==6)return Baseline?0.003:0.045;
        return 0.050;
    }
    CaelumCarbineAmmo Stock(int kind){return CaelumCarbineAmmo(User.FindNativeAmmunition(kind));}
    void SelectStock(int kind)
    {
        User.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_AMMUNITION;
        User.EquipmentSelectionAmmunitionType=kind;User.RefreshEquipmentSelectionPreview();
    }
    void Init(bool old=false,bool manual=false)
    {
        Setup();Baseline=old;Manual=manual;Ready=true;
        User.SetOrigin((0,0,0),false);User.Angle=User.Pitch=0;
        int kinds[]={0,6,1,2};
        for(int i=0;i<4;i++){let a=Stock(kinds[i]);a.Amount=100;a.InMagicBox=false;}
        User.OnNativeInventoryChanged();
        if(manual)
        {
            CaelumInventoryService.GrantMagicBoxFromPalomo(User,false);
            Equip(2,1,0);User.SetRangedMagazineCount(2,10);
            Victim=CA309Target(Actor.Spawn("CA313VisibleTarget",(512,0,0)));
        }
    }
    void Weights()
    {
        int kinds[]={0,6,1,2};
        for(int i=0;i<4;i++)
        {
            int kind=kinds[i];let a=Stock(kind);
            Verify("native unit weight",a.GetUnitWeight(),Unit(kind));
            Verify("shared unit weight",User.GetAmmunitionUnitWeight(kind),Unit(kind));
            Verify("personal full stack",a.GetCarriedWeight(),a.Amount*Unit(kind));
            SelectStock(kind);Verify("selection full stack",User.EquipmentSelectionWeight,a.Amount*Unit(kind));
        }
    }
    void Capacity()
    {
        // Primera pila y pila existente pasan por despachos diferentes.
        for(int index=0;index<2;index++)
        {
            int kind=index==0?0:6;let old=Stock(kind);if(old!=null)old.Destroy();
            User.OnNativeInventoryChanged();User.RefreshCarriedInventorySummary();
            double limit=User.DerivedStats.CarryCapacity;
            User.DerivedStats.CarryCapacity=User.DerivedStats.CarriedWeight+10*Unit(kind)-0.001;
            let drop=CaelumCarbineAmmo(Actor.Spawn(User.GetAmmunitionClassName(kind),(512,0,0)));drop.Amount=10;
            Actor receiver=User;
            Verify("first stack rejects excess mass",drop.CallTryPickup(receiver),0);
            Verify("rejected stack remains in world",drop.Owner==null,1);
            User.DerivedStats.CarryCapacity=limit;
            Verify("first stack pickup",drop.CallTryPickup(receiver),1);
            let a=Stock(kind);Verify("first stack exact amount",a.Amount,10);
            User.RefreshCarriedInventorySummary();User.DerivedStats.CarryCapacity=User.DerivedStats.CarriedWeight+5*Unit(kind)-0.001;
            Verify("existing stack rejects excess mass",User.PrepareNativeAmmoStackPickup(a,5),0);
            Verify("rejected addition preserves count",a.Amount,10);
            User.DerivedStats.CarryCapacity=limit;
            let extra=CaelumCarbineAmmo(Actor.Spawn(User.GetAmmunitionClassName(kind),(512,0,0)));extra.Amount=5;
            Verify("existing stack pickup",extra.CallTryPickup(receiver),1);
            Verify("existing stack exact amount",Stock(kind).Amount,15);
        }
    }
    void Storage()
    {
        Verify("grant actual owned Box",CaelumInventoryService.GrantMagicBoxFromPalomo(User,false),1);
        for(int i=0;i<2;i++)
        {
            int kind=i==0?0:6;let a=Stock(kind);int amount=a.Amount;
            double raw=User.HUDMagicBoxRawContentWeight;SelectStock(kind);
            CaelumInventoryService.ToggleSelectedMagicBoxNative(User);
            Verify("native transfer to Box",a.InMagicBox,1);
            Verify("Box raw mass",User.HUDMagicBoxRawContentWeight-raw,amount*Unit(kind));
            Verify("boxed stack no personal mass",a.GetCarriedWeight(),0);
            CaelumInventoryService.ToggleSelectedMagicBoxNative(User);
            Verify("native transfer from Box",a.InMagicBox,0);
            Verify("transfer preserves count",a.Amount,amount);
            Verify("Box returns to original raw mass",User.HUDMagicBoxRawContentWeight,raw);
            // Excluir objetos previos: la animación de recogida puede conservarlos.
            Array<Actor> previousWorld;
            let iterator=ThinkerIterator.Create(User.GetAmmunitionClassName(kind));CaelumCarbineAmmo candidate;
            while((candidate=CaelumCarbineAmmo(iterator.Next()))!=null)
                if(candidate.Owner==null)previousWorld.Push(candidate);
            CaelumInventoryService.DropSelectedNativeInventoryItem(User);
            iterator=ThinkerIterator.Create(User.GetAmmunitionClassName(kind));CaelumCarbineAmmo dropped;
            while((candidate=CaelumCarbineAmmo(iterator.Next()))!=null)
            {
                if(candidate.Owner!=null || previousWorld.Find(candidate)<previousWorld.Size())continue;
                dropped=candidate;break;
            }
            Verify("drop creates world stack",dropped!=null,1);
            if(dropped!=null)
            {
                Verify("world stack mass",dropped.GetCarriedWeight(),amount*Unit(kind));
                Actor receiver=User;Verify("repickup succeeds",dropped.CallTryPickup(receiver),1);
                Verify("repickup preserves amount",Stock(kind).Amount,amount);
            }
        }
    }
    void BoxFallback()
    {
        for(int i=0;i<2;i++)
        {
            int kind=i==0?0:6;Stock(kind).Destroy();User.OnNativeInventoryChanged();
            double limit=User.DerivedStats.CarryCapacity;
            User.DerivedStats.CarryCapacity=User.DerivedStats.CarriedWeight+Unit(kind);
            double raw=User.HUDMagicBoxRawContentWeight;
            let incoming=CaelumCarbineAmmo(Actor.Spawn(User.GetAmmunitionClassName(kind),(512,0,0)));incoming.Amount=10;
            Actor receiver=User;
            Verify("first stack Box fallback pickup",incoming.CallTryPickup(receiver),1);
            Verify("first stack fallback location",Stock(kind).InMagicBox,1);
            Verify("first stack fallback raw mass",User.HUDMagicBoxRawContentWeight-raw,10*Unit(kind));
            incoming=CaelumCarbineAmmo(Actor.Spawn(User.GetAmmunitionClassName(kind),(512,0,0)));incoming.Amount=5;
            Verify("boxed existing stack pickup",incoming.CallTryPickup(receiver),1);
            Verify("boxed existing stack amount",Stock(kind).Amount,15);
            Verify("boxed existing stack raw mass",User.HUDMagicBoxRawContentWeight-raw,15*Unit(kind));
            User.DerivedStats.CarryCapacity=limit;
        }
    }
    override void WorldThingSpawned(WorldEvent e)
    {
        if(TrackShots && e.Thing is 'CaelumCarbineProjectile')Shots++;
    }
    void BeforeAction()
    {
        User.RefreshCarriedInventorySummary();int kind=User.GetRangedAmmoType(Type);
        BeforeCount=Stock(kind).Amount;BeforeMagazine=User.GetRangedMagazineCount(Type);
        BeforeWeight=User.DerivedStats.CarriedWeight;Shots=0;TrackShots=true;
        User.CurrentAir=User.DerivedStats.MaximumAir;
    }
    void AfterAction(bool shot)
    {
        TrackShots=false;User.RefreshCarriedInventorySummary();int kind=User.GetRangedAmmoType(Type);
        Verify("action ammo debit",BeforeCount-Stock(kind).Amount,shot?1:0);
        Verify("action carried mass debit",BeforeWeight-User.DerivedStats.CarriedWeight,shot?Unit(kind):0);
        Verify("native projectile count",Shots,shot?(Type==14?12:1):0);
        Verify("native magazine",User.GetRangedMagazineCount(Type),shot?BeforeMagazine-1:CaelumRangedRules.MagazineCapacity(Type));
    }
    void Checkpoint()
    {
        int kinds[]={0,6,1,2};for(int i=0;i<4;i++){Stock(kinds[i]).Amount=100;Stock(kinds[i]).InMagicBox=false;}
        Equip(2,1,0);User.SetRangedMagazineCount(2,7);User.SetRangedMagazineCount(14,1);
        User.OnNativeInventoryChanged();SavedWeight=User.DerivedStats.CarriedWeight;SavedUnit=Unit(0);
        SavedFlight=CaelumRangedRules.Fire(User,User.WeaponModel,100,false,1,0,0);
        Verify("real checkpoint projectile",SavedFlight!=null,1);
        if(SavedFlight!=null)
        {
            SavedFlight.ChangeStatNum(Thinker.STAT_STATIC);SavedVelocity=SavedFlight.Vel;
            FlightDamage=SavedFlight.CaelumPreparedDamage;FlightType=SavedFlight.CaelumWearWeaponType;FlightTier=SavedFlight.CaelumWearWeaponTier;
            Verify("checkpoint remains missile",SavedFlight.bMissile,1);
        }
    }
    void Loaded(bool oldRuntime)
    {
        Baseline=oldRuntime;User=CaelumPlayer(players[consoleplayer].mo);
        // Comprobar el resumen actualizado por Tick, sin forzar recálculo aquí.
        double delta=100*(Unit(0)+Unit(6)-(SavedUnit==0.003?0.006:0.085));
        Verify("loaded summary refreshes automatically",User.DerivedStats.CarriedWeight,SavedWeight+delta,0.00001);
        int kinds[]={0,6,1,2};for(int i=0;i<4;i++){Verify("loaded ammo count",Stock(kinds[i]).Amount,100);Verify("loaded location",Stock(kinds[i]).InMagicBox,0);}
        Verify("partial carbine magazine",User.GetRangedMagazineCount(2),7);
        Verify("partial shotgun magazine",User.GetRangedMagazineCount(14),1);
        Verify("loaded in-flight actor",SavedFlight!=null,1);
        if(SavedFlight!=null)
        {
            Verify("loaded velocity",(SavedFlight.Vel-SavedVelocity).Length(),0);
            Verify("loaded prepared damage",SavedFlight.CaelumPreparedDamage,FlightDamage);
            Verify("loaded weapon identity",SavedFlight.CaelumWearWeaponType,FlightType);
            Verify("loaded weapon tier",SavedFlight.CaelumWearWeaponTier,FlightTier);
            Verify("loaded missile state",SavedFlight.bMissile,1);
        }
        Weights();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c313_setup")Init(e.Args[0]!=0,e.Args[1]!=0);
        if(e.Name=="c313_weights")Weights();
        if(e.Name=="c313_inventory"){Weights();Capacity();Storage();BoxFallback();}
        if(e.Name=="c313_equip"){Equip(e.Args[0],1,0);if(Manual)User.SetRangedMagazineCount(Type,CaelumRangedRules.MagazineCapacity(Type));}
        if(e.Name=="c313_before")BeforeAction();
        if(e.Name=="c313_after")AfterAction(e.Args[0]!=0);
        if(e.Name=="c313_checkpoint")Checkpoint();
        if(e.Name=="c313_loaded")Loaded(e.Args[0]!=0);
        if(e.Name=="c313_box"){SelectStock(User.GetRangedAmmoType(Type));CaelumInventoryService.ToggleSelectedMagicBoxNative(User);}
        if(e.Name=="c313_done")Console.Printf("CA194 DONE failures=%d passes=%d",Errors,Checks);
    }
    override void WorldTick()
    {
        Super.WorldTick();
        if(!Ready || !Manual || User==null)return;
        let bullets=Stock(0);let shells=Stock(6);
        ViewCarbine=bullets!=null?bullets.Amount:0;ViewShells=shells!=null?shells.Amount:0;
        ViewCarbineMass=bullets!=null?bullets.Amount*bullets.GetUnitWeight():0;
        ViewShellMass=shells!=null?shells.Amount*shells.GetUnitWeight():0;
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Ready || !Manual || automapactive || menuactive!=Menu.Off)return;
        let font=Font.GetFont("CaelumText");if(font==null)return;
        String lines[]={"#313: PESO DE MUNICIONES. F6 carabina | F7 escopeta | F8 Caja | F10 reiniciar",
            "Recarga con R y dispara: cada disparo gasta 1 cartucho. Guarda/carga para comprobar.",
            String.Format("Carabina: %d cartuchos = %.3f kg | Escopeta: %d cartuchos = %.3f kg",ViewCarbine,ViewCarbineMass,ViewShells,ViewShellMass),
            "40 g y 45 g son aproximaciones aprobadas; dano y penetracion conservan sus reglas."};
        for(int i=0;i<4;i++)Screen.DrawText(font,Font.CR_WHITE,170,8+i*(font.GetHeight()+2),lines[i],DTA_SHADOW,true,DTA_VIRTUALWIDTH,1280,DTA_VIRTUALHEIGHT,720);
    }
}
