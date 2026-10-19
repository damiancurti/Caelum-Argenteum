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
        User.EquipmentSelectionItemId=0;
        User.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_AMMUNITION;
        User.EquipmentSelectionAmmunitionType=kind;User.RefreshEquipmentSelectionPreview();
    }
    void Init(bool old=false,bool manualPreview=false)
    {
        Setup();Baseline=old;Manual=manualPreview;Ready=true;
        User.SetOrigin((0,0,0),false);User.Angle=User.Pitch=0;
        int kinds[]={0,6,1,2};
        for(int i=0;i<4;i++){let a=Stock(kinds[i]);a.Amount=100;a.InMagicBox=false;}
        User.OnNativeInventoryChanged();
        if(manualPreview)
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
    void Loaded(bool oldRuntime,bool hubInventoryOnly=false)
    {
        Baseline=oldRuntime;User=CaelumPlayer(players[consoleplayer].mo);
        // Comprobar el resumen actualizado por Tick, sin forzar recálculo aquí.
        double delta=100*(Unit(0)+Unit(6)-(SavedUnit==0.003?0.006:0.085));
        Verify("loaded summary refreshes automatically",User.DerivedStats.CarriedWeight,SavedWeight+delta,0.00001);
        int kinds[]={0,6,1,2};for(int i=0;i<4;i++){Verify("loaded ammo count",Stock(kinds[i]).Amount,100);Verify("loaded location",Stock(kinds[i]).InMagicBox,0);}
        Verify("partial carbine magazine",User.GetRangedMagazineCount(2),7);
        Verify("partial shotgun magazine",User.GetRangedMagazineCount(14),1);
        // El hub comprueba inventario; el misil congelado se audita en save/load.
        if(!hubInventoryOnly)Verify("loaded in-flight actor",SavedFlight!=null,1);
        if(!hubInventoryOnly && SavedFlight!=null)
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
        if(e.Name=="c313_loaded")Loaded(e.Args[0]!=0,e.Args[1]!=0);
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
    override void RenderOverlay(RenderEvent e) {}
}

// El HUD vive en el controlador estático; el estado de la prueba sí se guarda.
class CA313HUD : StaticEventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        let probe=CA313Probe(EventHandler.Find("CA313Probe"));
        if(probe==null || !probe.Ready || !probe.Manual || automapactive || menuactive!=Menu.Off)return;
        let font=Font.GetFont("CaelumText");if(font==null)return;
        String lines[]={"#313: PESO DE MUNICIONES. F6 carabina | F7 escopeta | F8 Caja | F10 reiniciar",
            "Recarga con R y dispara: cada disparo gasta 1 cartucho. Guarda/carga para comprobar.",
            String.Format("Carabina: %d cartuchos = %.3f kg | Escopeta: %d cartuchos = %.3f kg",probe.ViewCarbine,probe.ViewCarbineMass,probe.ViewShells,probe.ViewShellMass),
            "40 g y 45 g son aproximaciones aprobadas; dano y penetracion conservan sus reglas."};
        for(int i=0;i<4;i++)Screen.DrawText(font,Font.CR_WHITE,170,8+i*(font.GetHeight()+2),lines[i],DTA_SHADOW,true,DTA_VIRTUALWIDTH,1280,DTA_VIRTUALHEIGHT,720);
    }
}
