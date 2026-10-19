// #314: sala privada; prepara cuerpos y observa las rutas térmicas compartidas.
class CA314Probe : EventHandler
{
    CaelumPlayer User;
    int Passed,Failed;
    bool Manual;
    int DisplayKind;
    double DisplayExposure;
    CaelumBull Subject;
    double ExpectedExposure;
    int ExpectedHealth;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA314 %s %s",ok?"PASS":"FAIL",label);}
    void Number(double actual,double expected,String label,double epsilon=0.000001)
    {Check(Abs(actual-expected)<epsilon,String.Format("%s actual=%.9f expected=%.9f",label,actual,expected));}
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        if(!Manual || User==null)return;
        let t=CaelumThermalBody.Get(User);
        if(t!=null){DisplayKind=t.SurfaceKind;DisplayExposure=t.Exposure;}
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Manual || User==null)return;
        String key=DisplayKind==1 ? "C314_ICE" : DisplayKind==2 ? "C314_LAVA" : "C314_NONE";
        let font=Font.GetFont("SmallFont");
        Screen.DrawText(font,Font.CR_WHITE,12,12,StringTable.Localize(key,false),DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(font,Font.CR_WHITE,12,24,StringTable.Localize("C314_KEYS",false),DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
        Screen.DrawText(font,Font.CR_WHITE,12,36,String.Format("E %.2f | HP %d",DisplayExposure,User.health),DTA_VIRTUALWIDTHF,640.0,DTA_VIRTUALHEIGHTF,360.0);
    }
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);User.InitializeDirectMapCharacter();
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.bNOTARGET=true;User.CurrentHunger=User.CurrentThirst=75;
        User.CurrentLucidity=User.CurrentSleep=100;
        Move(0);
    }
    void Move(int zone)
    {
        User.bNoClip=false;User.bNoGravity=false;
        User.SetOrigin(CA314Data.Position(zone),false);User.Vel=(0,0,0);
        User.Angle=User.Pitch=0;
    }
    void Geometry(int zone)
    {
        Check(CaelumThermalWorld.Get().HasThermalSurfaces,"map load discovers authored surface tags");
        int expected[]={0,1,2,0,1,1,0,2};
        Check(CaelumThermalSurface.KindAt(User)==expected[zone],String.Format("native supporting floor zone %d kind %d water %d floor %.2f z %.2f",zone,expected[zone],User.WaterLevel,User.FloorZ,User.Pos.Z));
        let live=CaelumThermalBody.Get(User);
        Check(live!=null && live.Available,"fixture supplies existing climate service");
        Check(live.SurfaceKind==expected[zone],String.Format("live player contact zone %d",zone));
        if(zone!=7)return;
        Move(1);User.bNoGravity=true;
        Check(CaelumThermalSurface.KindAt(User)==0,"flight excludes ground contact");
        User.bNoGravity=false;User.bNoClip=true;
        Check(CaelumThermalSurface.KindAt(User)==0,"noclip excludes ground contact");
        User.bNoClip=false;User.SetOrigin(User.Pos+(0,0,32),false);
        Check(CaelumThermalSurface.KindAt(User)==0,"airborne body excludes ground contact");
        Move(1);User.Vel.Z=1;
        Check(CaelumThermalSurface.KindAt(User)==0,"upward jump excludes ground contact immediately");
        Move(0);
    }
    CaelumThermalState Prepared(int kind)
    {
        let t=new("CaelumThermalState");t.Initialize();CaelumThermalBody.Refresh(User,t);
        t.Available=true;t.AirC=t.ClimateC=t.ComfortC;t.Humidity=50;
        t.WindMps=CaelumThermalData.NATURAL_WIND_MPS;t.Hydration=100;
        t.Sweats=false;t.CanShiver=false;t.CanBreathe=true;t.BreathingAirRatio=1;
        CaelumThermalBody.SampleCoverage(User,t,0);
        for(int i=0;i<4;i++)t.Material[i]=CaelumThermalData.LIGHT_CLOTH;
        CaelumThermalSurface.Sample(User,t,kind);
        return t;
    }
    void Solver()
    {
        Move(1);
        let dry=Prepared(1);let coefficients=CaelumThermalCoefficients.Get(dry);coefficients.Prepare(dry);
        double area=0,contact=0,air=0;
        for(int i=0;i<4;i++)
        {area+=dry.SurfaceCoverage[i];contact+=coefficients.ContactConductance[i];air+=coefficients.ExposedArea[i];}
        Number(area,1.0/16,"approved anatomical contact fraction");
        Number(air,dry.SurfaceArea*(15.0/16),"contact area replaces air area exactly once");
        Number(contact,dry.SurfaceArea/16/(0.155*0.5+1.0/100),"approved conductance through base clothing");
        let insulated=Prepared(1);
        for(int i=0;i<4;i++)insulated.Material[i]=CaelumThermalData.THICK_LEATHER;
        let insulatedCoefficients=CaelumThermalCoefficients.Get(insulated);insulatedCoefficients.Prepare(insulated);
        double insulatedContact=0;for(int i=0;i<4;i++)insulatedContact+=insulatedCoefficients.ContactConductance[i];
        Check(insulatedContact>0 && insulatedContact<contact,"existing stronger clothing insulates contact");
        let neutral=Prepared(0);let hot=Prepared(2);let cold=Prepared(1);
        CaelumThermalService.Integrate(neutral,60,1);
        CaelumThermalService.Integrate(hot,60,1);
        CaelumThermalService.Integrate(cold,60,1);
        Check(hot.Exposure>neutral.Exposure && cold.Exposure<neutral.Exposure,"authored temperatures heat and cool through shared solver");
        let split=Prepared(2);
        for(int i=0;i<60;i++)CaelumThermalService.Integrate(split,1,1.0/60);
        Number(split.Exposure,hot.Exposure,"world-time integration partition is equivalent");
        let wet=Prepared(1);for(int i=0;i<4;i++)wet.WorkWaterKg[i]=0.01;
        CaelumThermalCoefficients.Get(wet).Prepare(wet);
        for(int i=0;i<4;i++)Number(CaelumThermalCoefficients.Get(wet).ContactConductance[i],coefficients.ContactConductance[i],"wet contact does not add a second water exchange multiplier");
        double before=hot.Exposure;
        for(int i=0;i<10;i++)CaelumThermalSurface.Sample(User,hot,2);
        Number(hot.Exposure,before,"repeated contact sampling does not add energy or damage");
        CaelumThermalSurface.Clear(hot);CaelumThermalCoefficients.Get(hot).Prepare(hot);
        double cleared=0;for(int i=0;i<4;i++)cleared+=CaelumThermalCoefficients.Get(hot).ContactConductance[i];
        Number(cleared,0,"leaving contact invalidates cached conductance");
        Move(0);
    }
    void Damage()
    {
        let damageState=CaelumThermalBody.Get(User,true);
        damageState.DamageRemainder=0;damageState.Toughness=User.Attributes.Toughness;
        int before=User.health;
        double dose=CaelumThermalRules.Severity(40,damageState.Toughness);
        int expected=int(dose*User.CaelumMaximumHealth/100.0*(1-CaelumThermalRules.DamageResistance(damageState.Toughness))+CaelumThermalData.THRESHOLD_EPSILON);
        CaelumThermalService.ApplyDamage(User,damageState,dose);
        Number(before-User.health,expected,"shared temperature damage retains Toughness mitigation");
        int after=User.health;CaelumThermalService.Advance(User,0,0);
        Number(User.health,after,"zero interval adds no direct floor damage");
    }
    void CreateSubject()
    {
        Subject=CaelumBull(Actor.Spawn("CaelumBull",CA314Data.Position(0)+(0,100,0),ALLOW_REPLACE));
        Subject.bDormant=true;Subject.SetStateLabel("RestLying");
    }
    void MoveSubject(int zone)
    {Subject.SetOrigin(CA314Data.Position(zone)+(0,100,0),false);Subject.Vel=(0,0,0);}
    void CheckSubject(int kind)
    {
        let t=Subject.ThermalState;
        Check(t!=null && t.Available,"native NPC initializes shared physiology");
        if(t==null)return;
        Check(t.SurfaceKind==kind,"NPC updates contact on entry and exit");
        if(kind!=0)Check(t.LastRealTic>=level.maptime-1,"contact NPC closes intervals every tic");
        double before=t.Exposure;int hp=Subject.health;
        CaelumThermalRuntime.NPCStep(Subject,true);
        double once=t.Exposure;int onceHP=Subject.health;
        for(int i=0;i<10;i++)CaelumThermalRuntime.NPCStep(Subject,true);
        Number(t.Exposure,once,"repeated same-tic NPC callbacks add no energy");
        Number(Subject.health,onceHP,"repeated same-tic NPC callbacks add no damage");
        Check(Abs(t.Exposure-before)<1 && hp-Subject.health<Subject.CombatMaximumHealth/100,"entry closes only elapsed time");
    }
    void Mark()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        ExpectedExposure=CaelumThermalBody.Get(User).Exposure;ExpectedHealth=User.health;
        Check(ExpectedHealth>0,"checkpoint is alive");
    }
    void Restored(int kind)
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        let t=CaelumThermalBody.Get(User);
        Check(User.health>0 && Abs(t.Exposure-ExpectedExposure)<2,"save restores accumulated exposure without catch-up");
        Check(t.SurfaceKind==kind,"save rebuilds transient ground contact");
        Check(t.Revision==CaelumThermalData.REVISION,"thermal schema remains current");
    }
    void Hub(int kind)
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        let t=CaelumThermalBody.Get(User);
        Check(t!=null && t.SurfaceKind==kind,"hub arrival samples destination support");
        Check(User.health>0 && Abs(t.Exposure)<100,"hub transfer has finite exposure and no lethal catch-up");
        if(Subject!=null)CheckSubject(2);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c314_setup")Setup();
        else if(e.Name=="c314_move")Move(e.Args[0]);
        else if(e.Name=="c314_geometry")Geometry(e.Args[0]);
        else if(e.Name=="c314_contact")Check(CaelumThermalBody.Get(User).SurfaceKind==e.Args[0],"native input changes ground contact");
        else if(e.Name=="c314_solver")Solver();
        else if(e.Name=="c314_damage")Damage();
        else if(e.Name=="c314_npc")CreateSubject();
        else if(e.Name=="c314_npcmove")MoveSubject(e.Args[0]);
        else if(e.Name=="c314_npccheck")CheckSubject(e.Args[0]);
        else if(e.Name=="c314_mark")Mark();
        else if(e.Name=="c314_restored")Restored(e.Args[0]);
        else if(e.Name=="c314_hub")Hub(e.Args[0]);
        else if(e.Name=="c314_manual")Manual=true;
        else if(e.Name=="c314_reset")
        {let t=CaelumThermalBody.Get(User);if(t!=null)t.Exposure=0;User.health=User.CaelumMaximumHealth;User.player.health=User.health;}
        else if(e.Name=="c314_done")Console.Printf("CA314 DONE passes=%d failures=%d",Passed,Failed);
    }
}
