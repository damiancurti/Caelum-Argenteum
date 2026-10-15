// Laboratorio aislado: masas/defensas controladas, sin cambios al balance.
class CA252Body : Actor
{
    int Raw,Hits;
    override void Tick(){}
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {if(mod=='CaelumEarthquake'){Raw=damage;Hits++;}return 0;}
    Default {Radius 8;Height 0;Mass 80;Health 100000;+SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA252Fixed : CaelumMovableProp {States {Spawn:TNT1 A -1;Stop;}}
class CA252Faller : Actor
{
    Default {Radius 8;Height 16;Mass 80;Health 100000;+SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA252Combat : CaelumCombatActor
{
    override void Tick(){}
    Default {Radius 16;Height 56;Mass 80;Health 100000;+SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA252Checkpoint : Inventory
{
    double Power,Total,Direction;
    Actor Body;
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA252Probe : StaticEventHandler
{
    CaelumPlayer User;
    CaelumEquipmentItem Seal;
    double Power;
    int Passed,Failed;
    bool Pin,Manual;
    CA252Faller Faller,Flyer;
    double FallStart;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA252 %s %s",ok?"PASS":"FAIL",label);}
    void Number(double actual,double expected,String label,double epsilon=0.00001)
    {Check(abs(actual-expected)<epsilon,String.Format("%s actual=%.6f expected=%.6f",label,actual,expected));}
    override void UiTick(){if(!Manual && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Stats()
    {
        User.DerivedStats.MagicalPowerMultiplier=Power;
        User.DerivedStats.MagicalPushMultiplier=Power;
        User.DerivedStats.MaximumAdrenaline=100000;
        User.DerivedStats.AbilityRangePercent=100;
        User.CurrentAdrenaline=90000;User.CombatTimeRemaining=2;
    }
    override void WorldTick()
    {
        if(Pin && User!=null)Stats();
        if(Manual && User!=null)
        {
            // La escena visual no mata al autor mientras compara los sellos.
            User.health=User.CaelumMaximumHealth;User.player.health=User.health;
            let thermal=CaelumThermalBody.Get(User);if(thermal!=null)thermal.Exposure=0;
        }
    }
    void Setup()
    {
        User=CaelumPlayer(players[consoleplayer].mo);
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;User.ApplyCharacterProfile();
        User.StopSealChannel(false,false);User.CombatChannelCooldownRemaining=0;
        User.CurrentSleep=User.CurrentLucidity=100;User.bInvulnerable=true;
        User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);User.Angle=User.Pitch=0;
        for(Inventory i=User.Inv;i!=null;i=i.Inv)
            if(i is "CaelumEquipmentItem" && CaelumEquipmentItem(i).EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SEAL)
                CaelumEquipmentItem(i).Equipped=false;
        let equipment=new("CA259Session");equipment.Choice=0;equipment.Tier=1;equipment.Equip(User);
        Seal=CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup",User.Pos,NO_REPLACE));
        Seal.PickupDataInitialized=Seal.AcquisitionResolved=true;
        Seal.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SEAL;Seal.Tier=1;
        Seal.ItemType=CaelumConstants.SEAL_FIRE;Seal.Equipped=true;Seal.AttachToOwner(User);
        User.EquipmentMenuOpen=false;User.CombatChannelInputLatched=false;
        Power=1.7;Pin=true;Stats();
    }
    CaelumChannelEffect Start(int type)
    {
        User.StopSealChannel(false,false);User.CombatChannelCooldownRemaining=0;
        Seal.ItemType=type;User.RequestCombatChannelInput();
        let effect=CaelumChannelEffect(User.CombatChannelEffectActor);
        Check(effect!=null,"native channel lifecycle starts");return effect;
    }
    CA252Body Body(vector3 pos)
    {return CA252Body(Actor.Spawn("CA252Body",pos,NO_REPLACE));}
    void Formulas()
    {
        let body=Body((128,0,0));let hidden=Body((768,0,0));let outside=Body((2048,0,0));
        for(int s=0;s<3;s++)
        {
            int type=s==0?CaelumConstants.SEAL_FIRE:s==1?CaelumConstants.SEAL_AIR:CaelumConstants.SEAL_WATER;
            let effect=Start(type);
            for(int n=1;n<=3;n++)
            {
                effect.ClimatePulse();Number(effect.ClimatePower,1.7*n,"linear internal power");
                double total=1.7*n*(n+1)/2;
                Number(effect.ClimateTotal,total,"growing climate increments");
                double heat,humidity,wind,direction;
                [heat,humidity,wind,direction]=CaelumSealClimate.Delta(body,12,73);
                Number(heat,type==CaelumConstants.SEAL_FIRE?total:0,"local heat");
                Number(humidity,type==CaelumConstants.SEAL_WATER?total*3:0,"local humidity");
                Number(wind,type==CaelumConstants.SEAL_AIR?total*2:0,"local wind");
                Number(direction,73,"ambient direction retained");
            }
            Check(!CaelumSealClimate.ClearPath(effect,hidden),"native wall blocks effect");
            double h,r,w,d;
            [h,r,w,d]=CaelumSealClimate.Delta(hidden,0,0);Number(h+r+w,0,"wall excludes all weather additions");
            [h,r,w,d]=CaelumSealClimate.Delta(outside,0,0);Number(h+r+w,0,"radius excludes all weather additions");
            [h,r,w,d]=CaelumSealClimate.Delta(User,0,0);
            Check(h+r+w>0,"caster receives local weather");
            if(type==CaelumConstants.SEAL_AIR)Number(d,effect.CalmWindDirection,"calm wind chooses saved bearing");
            User.StopSealChannel(false,false);
            [h,r,w,d]=CaelumSealClimate.Delta(body,0,0);Number(h+r+w,0,"stop removes overlay immediately");
        }
        let effect=Start(CaelumConstants.SEAL_WATER);effect.ClimatePulse();
        let sample=new("CaelumWeatherSample");sample.Available=true;sample.RelativeHumidityPercent=98;
        CaelumSealClimate.ApplyWeather(body,sample);Number(sample.RelativeHumidityPercent,100,"humidity caps at 100");
        User.StopSealChannel(false,false);body.Destroy();hidden.Destroy();outside.Destroy();
    }
    void Earth()
    {
        let effect=Start(CaelumConstants.SEAL_EARTH);effect.EffectRadius=1280;
        let center=Body((0,0,0));let half=Body((640,512,0));half.SetOrigin((0,640,0),false);
        let border=Body((0,1280,0));let hidden=Body((768,0,0));let airborne=Body((128,0,128));
        let fixed=Actor.Spawn("CA252Fixed",(64,0,0),NO_REPLACE);
        Check(!CaelumSealClimate.EarthTarget(effect,User),"earth excludes caster");
        Check(!CaelumSealClimate.EarthTarget(effect,fixed),"fixed infrastructure protected");
        for(int n=1;n<=3;n++)
        {
            effect.ClimatePulse();Number(center.Raw,136*n,"linear center damage");
            Number(half.Raw,68*n,"linear half-radius damage");
            Number(border.Hits,0,"zero damage at radius");Number(hidden.Hits,0,"wall protects target");
            Number(airborne.Hits,0,"airborne target protected");
            half.Vel=(0,0,0);CaelumSealClimate.PushEarth(effect,half);
            Number(half.Vel.Y,850.0*n/80*32/(35*35),"force uses N kg meters and native tics");
        }
        fixed.args[0]=100;Check(CaelumSealClimate.EarthTarget(effect,fixed),"configured movable object eligible");
        center.bFriendly=true;Check(CaelumSealClimate.EarthTarget(effect,center),"friendly body eligible");
        User.StopSealChannel(false,false);
        center.Destroy();half.Destroy();border.Destroy();hidden.Destroy();airborne.Destroy();fixed.Destroy();
    }
    void Gravity()
    {
        let effect=Start(CaelumConstants.SEAL_QUINTESSENCE);let body=Body((128,0,0));
        body.Gravity=0.5;
        let binding=CaelumSealGravity.Get(body,true);binding.Hold(effect);Number(body.Gravity,0,"channel suppresses gravity");
        binding.Amplify(3.4);Number(body.Gravity,0,"channel wins over release aftereffect");
        binding.Release(effect);Number(body.Gravity,1.7,"factor scales original body gravity");
        binding.Amplify(1.7);Number(body.Gravity,1.7,"overlap retains strongest factor");
        binding.RemainingTics=3;binding.Amplify(5.1);Number(binding.RemainingTics,35,"overlap renews longest duration");
        for(int i=0;i<35;i++)binding.Tick();Number(body.Gravity,0.5,"expiry restores exact original gravity");
        effect.ClimatePulse();effect.ClimatePulse();effect.ClimatePulse();
        effect.ApplyContinuousEffect();User.StopSealChannel(false,true);
        binding=CaelumSealGravity.Get(body);Check(binding!=null,"release snapshots body inside radius");
        Number(binding.Factor,5.1,"quintessence grows linearly");
        binding.Destroy();Number(body.Gravity,0.5,"destroy restores base");
        effect=Start(CaelumConstants.SEAL_QUINTESSENCE);User.StopSealChannel(false,true);
        binding=CaelumSealGravity.Get(body);Number(binding.Factor,1.7,"early release keeps initial magic power");
        binding.Destroy();body.Destroy();
    }
    void Environment()
    {
        let effect=Start(CaelumConstants.SEAL_FIRE);effect.ClimatePulse();
        let body=Body((0,128,0));
        let sample=new("CaelumWeatherSample");sample.Available=true;
        sample.AirTemperatureC=20;sample.RelativeHumidityPercent=50;sample.WindSpeedKmh=18;
        let thermal=new("CaelumThermalState");thermal.Available=true;
        thermal.SealClimateRevision=1;thermal.AmbientAirC=20;thermal.AmbientHumidity=50;
        thermal.AmbientWindKmh=18;thermal.LocalMotionMps=0;
        CaelumSealClimate.ApplyWeather(body,sample);CaelumSealClimate.ApplyThermal(body,thermal);
        Number(thermal.AirC,sample.AirTemperatureC,"weather and physiology share ambient heat");
        for(int i=0;i<35;i++)CaelumSealClimate.ApplyThermal(body,thermal);
        Number(thermal.AirC,21.7,"repeated sampling does not re-add total");
        let overlap=CaelumChannelEffect(Actor.Spawn("CaelumChannelEffect",User.Pos,NO_REPLACE));
        overlap.ConfigureChannel(User,Seal,effect.EffectRadius);overlap.ClimatePulse();overlap.ClimatePulse();
        CaelumSealClimate.ApplyThermal(body,thermal);Number(thermal.AirC,26.8,"overlapping heat areas add");
        overlap.Destroy();CaelumSealClimate.ApplyThermal(body,thermal);Number(thermal.AirC,21.7,"one source ends independently");
        User.StopSealChannel(false,false);CaelumSealClimate.ApplyThermal(body,thermal);
        Number(thermal.AirC,20,"thermal cache loses ended source immediately");
        effect=Start(CaelumConstants.SEAL_AIR);effect.ClimatePulse();
        CaelumSealClimate.ApplyThermal(body,thermal);Number(thermal.WindMps,21.4/3.6,"thermal wind uses kmh conversion");
        thermal.AmbientWindKmh=0;CaelumSealClimate.ApplyThermal(body,thermal);
        Number(thermal.WindMps,3.4/3.6,"generated local wind works inside shelter");
        let wall=Actor.Spawn("CaelumFiniteWallBlocker",(0,64,0),NO_REPLACE);
        wall.A_SetSize(16,128,false);
        Check(!CaelumSealClimate.ClearPath(effect,body),"actor-built wall blocks local wind");
        CaelumSealClimate.ApplyThermal(body,thermal);Number(thermal.WindMps,0,"thermal overlay respects modeled wall");
        wall.Destroy();
        let floor=Actor.Spawn("CaelumFiniteFloorBlocker",(0,0,96),NO_REPLACE);
        body.SetOrigin((0,0,128),false);
        Check(!CaelumSealClimate.ClearPath(effect,body),"actor-built floor blocks vertical propagation");
        floor.Destroy();User.StopSealChannel(false,false);body.Destroy();
    }
    void Defenses()
    {
        let effect=Start(CaelumConstants.SEAL_EARTH);
        let npc=CA252Combat(Actor.Spawn("CA252Combat",(0,256,0),NO_REPLACE));
        npc.CombatArmor=new("CaelumArmorModel");npc.CombatArmor.InitializeDefaults();
        npc.CombatMaximumHealth=npc.health=100000;npc.CombatToughness=0;
        npc.DamageMobj(effect,User,1000,'CaelumEarthquake',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
        Number(100000-npc.health,920,"earth bypasses armor and retains zero-stat mass toughness");
        npc.health=100000;npc.CombatToughness=25;
        double reduction=CaelumToughnessRules.Apply(npc,1000);
        npc.DamageMobj(effect,User,1000,'CaelumEarthquake',DMG_NO_ARMOR|DMG_THRUSTLESS,0);
        Number(100000-npc.health,int(reduction+0.5),"earth applies physical toughness once");
        Check(!npc.LastCombatEvasionAttempted,"ground quake does not roll an attack evade");
        npc.Destroy();User.StopSealChannel(false,false);
    }
    void Presentation()
    {
        User.player.cheats&=~CF_CHASECAM;
        static const String marks[]={"CMNF","CMNW","CMNE","CMNA","CMNQ"};
        for(int i=0;i<5;i++)
        {
            int index=Actor.GetSpriteIndex(marks[i]);
            Check(index>=0,"seal sprite is registered before rendering");
            let effect=Start(i);CaelumSealPresentation.Update(effect);
            Check((User.player.cheats&CF_CHASECAM)!=0 && User.player.camera==User,"channel owns native chasecam");
            Check(effect.ChannelMark!=null && effect.ChannelMark.bFlatSprite,"flat seal mark exists");
            Number(effect.ChannelMark.Scale.X,0.75,"seal is double trap scale");
            Number(effect.ChannelMark.sprite,index,"correct registered seal image");
            Number(effect.ChannelMark.Pos.Z-User.FloorZ,0.5,"mark lies on ground");
            Check(effect.ChannelOrb!=null,"visual orb exists");
            let orb=effect.ChannelOrb;
            Check(!orb.bSolid && !orb.bMissile && !orb.bShootable && orb.bNoInteraction,"orb has no gameplay body");
            Number(orb.Scale.X,GetDefaultByType("CaelumArcaneSunOrb").Scale.X,"orb matches Arcane Sun size");
            Number(orb.sprite,Actor.GetSpriteIndex(CaelumElementalVFXData.SpriteName(i*2)),"orb matches seal element");
            Number(orb.Pos.Z-orb.VisualHalfHeight,User.Pos.Z+User.Height,"orb bottom floats above head");
            let mark=effect.ChannelMark;User.StopSealChannel(false,false);
            Check(mark==null || mark.bDestroyed,"stopping removes seal mark");
            Check(orb==null || orb.bDestroyed,"stopping removes visual orb");
            Check((User.player.cheats&CF_CHASECAM)==0,"prior first-person camera restored");
        }
        User.player.cheats|=CF_CHASECAM;
        let effect=Start(CaelumConstants.SEAL_FIRE);CaelumSealPresentation.Update(effect);
        User.StopSealChannel(false,false);Check((User.player.cheats&CF_CHASECAM)!=0,"existing chasecam preserved");
        User.player.cheats&=~CF_CHASECAM;
        User.SetOrigin((0,0,192),false);User.FindFloorCeiling();
        effect=Start(CaelumConstants.SEAL_WATER);CaelumSealPresentation.Update(effect);
        Number(effect.ChannelMark.Pos.Z,0.5,"airborne user leaves mark on ground");
        let floor=Actor.Spawn("CaelumFiniteFloorBlocker",(0,0,64),NO_REPLACE);
        CaelumSealPresentation.Update(effect);
        Number(effect.ChannelMark.Pos.Z,64+floor.Height+0.5,"actor floor supports projected seal");
        floor.Destroy();User.StopSealChannel(false,false);User.SetOrigin((0,0,0),false);
    }
    void Falling()
    {
        Faller=CA252Faller(Actor.Spawn("CA252Faller",(0,256,512),NO_REPLACE));
        Flyer=CA252Faller(Actor.Spawn("CA252Faller",(0,-256,512),NO_REPLACE));Flyer.bNoGravity=true;
        FallStart=Faller.Pos.Z;
        CaelumSealGravity.Get(Faller,true).Amplify(3.4);
        CaelumSealGravity.Get(Flyer,true).Amplify(3.4);
    }
    void Roof()
    {
        let effect=Start(CaelumConstants.SEAL_FIRE);effect.ClimatePulse();
        let body=Body((0,0,192));
        Check(!CaelumSealClimate.ClearPath(effect,body),"native 3D floor blocks vertical propagation");
        double h,r,w,d;[h,r,w,d]=CaelumSealClimate.Delta(body,0,0);
        Number(h,0,"no heat through native 3D floor");body.Destroy();User.StopSealChannel(false,false);
        User.SetOrigin((0,0,192),false);User.FindFloorCeiling();
        effect=Start(CaelumConstants.SEAL_WATER);CaelumSealPresentation.Update(effect);
        Number(effect.ChannelMark.Pos.Z,160.5,"3D floor supports projected seal");
        User.StopSealChannel(false,false);
    }
    void Seed()
    {
        let effect=Start(CaelumConstants.SEAL_AIR);
        effect.ClimatePulse();effect.ClimatePulse();effect.ClimatePulse();
        CaelumSealPresentation.Update(effect);
        let checkpoint=CA252Checkpoint(User.GiveInventoryType("CA252Checkpoint"));
        checkpoint.Power=effect.ClimatePower;checkpoint.Total=effect.ClimateTotal;
        checkpoint.Direction=effect.CalmWindDirection;
        checkpoint.Body=Body((0,128,0));
        Check(effect.ClimateRevision==1,"revision stored on active channel");
    }
    void Loaded()
    {
        User=CaelumPlayer(players[consoleplayer].mo);Seal=User.GetEquippedSeal();
        let effect=CaelumChannelEffect(User.CombatChannelEffectActor);
        let checkpoint=CA252Checkpoint(User.FindInventory("CA252Checkpoint"));
        Check(effect!=null && checkpoint!=null,"active source and checkpoint load");
        if(effect==null || checkpoint==null)return;
        Number(effect.ClimatePower,checkpoint.Power,"load preserves accumulated power");
        Number(effect.ClimateTotal,checkpoint.Total,"load does not replay climate increments");
        Number(effect.CalmWindDirection,checkpoint.Direction,"load preserves calm wind bearing");
        Check(effect.ChannelCameraCaptured && effect.ChannelMark!=null,"saved presentation retained");
        Check((User.player.cheats&CF_CHASECAM)!=0,"loaded channel remains third person");
        CaelumSealPresentation.Update(effect);
        Check(effect.ChannelOrb!=null && effect.ChannelOrb.Source==effect,"loaded or migrated channel owns one orb");
        Check(CaelumSealClimate.ClearPath(effect,checkpoint.Body),"transient geometry tracer rebuilds on load");
    }
    void GravitySeed()
    {
        let effect=Start(CaelumConstants.SEAL_QUINTESSENCE);
        effect.ClimatePulse();effect.ClimatePulse();effect.ClimatePulse();
        let checkpoint=CA252Checkpoint(User.GiveInventoryType("CA252Checkpoint"));
        checkpoint.Body=Actor.Spawn("CA252Faller",(128,0,256),NO_REPLACE);
        effect.ApplyContinuousEffect();User.StopSealChannel(false,true);
        let binding=CaelumSealGravity.Get(checkpoint.Body);
        Check(binding!=null && binding.Factor==5.1,"released gravity snapshot ready for save");
    }
    void ManualSetup()
    {
        Setup();Manual=true;
        let marker=Actor.Spawn("CaelumClimateRegion",User.Pos,NO_REPLACE);marker.args[0]=1;marker.args[1]=5;
        for(int i=0;i<3;i++)
        {
            let npc=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(192+i*96,192,0),NO_REPLACE));
            npc.bFriendly=true;npc.bInvulnerable=true;
        }
        CaelumNotifications.Notify(User,"#252 | F: canalizar/parar | F6: siguiente | F7: esfera | F8: suelo | J: Clima");
    }
    void NextSeal()
    {
        User.StopSealChannel(false,false);User.CombatChannelCooldownRemaining=0;
        Seal.ItemType=(Seal.ItemType+1)%5;
        static const String names[]={"Fuego","Agua","Tierra","Aire","Quintaesencia"};
        CaelumNotifications.Notify(User,String.Format("Sello: %s | F: canalizar/parar | F6: siguiente",names[Seal.ItemType]));
    }
    void Interruptions()
    {
        let effect=Start(CaelumConstants.SEAL_FIRE);effect.ClimatePulse();
        CaelumSealPresentation.Update(effect);
        User.CurrentAdrenaline=0;User.UpdateSealChannel();
        Check(!User.CombatChannelModeActive,"exhaustion stops channel");
        Check((User.player.cheats&CF_CHASECAM)==0,"exhaustion restores camera");
        Stats();effect=Start(CaelumConstants.SEAL_FIRE);effect.ClimatePulse();
        Seal.Equipped=false;effect.Tick();
        Check(effect==null || effect.bDestroyed,"invalid exact equipment removes source");
        User.UpdateSealChannel();Seal.Equipped=true;Stats();
        effect=Start(CaelumConstants.SEAL_FIRE);CaelumSealPresentation.Update(effect);
        User.LucidityPhysicalStunRemaining=1;User.UpdateSealChannel();
        Check(!User.CombatChannelModeActive,"stun stops channel");
        User.LucidityPhysicalStunRemaining=0;
        Stats();effect=Start(CaelumConstants.SEAL_FIRE);effect.PulseAccumulator=0.5;
        effect.ClimateRevision=0;effect.ClimatePower=effect.ClimateTotal=0;
        effect.EnsureClimateState();effect.EnsureClimateState();
        Number(effect.PulseAccumulator,0.5,"idempotent migration preserves pulse phase");
        Number(effect.ClimatePower,0,"migration does not replay historical pulses");
        User.StopSealChannel(false,false);
    }
    void Performance()
    {
        Array<CA252Combat> bodies;
        for(int i=0;i<500;i++)
        {
            let body=CA252Combat(Actor.Spawn("CA252Combat",(-800+(i%25)*64,-800+(i/25)*64,0),NO_REPLACE));
            body.CombatArmor=new("CaelumArmorModel");body.CombatArmor.InitializeDefaults();
            body.CombatMaximumHealth=body.health=1000000;body.bInvulnerable=true;bodies.Push(body);
        }
        let thermal=new("CaelumThermalState");thermal.SealClimateRevision=1;thermal.Available=true;
        thermal.AmbientAirC=20;thermal.AmbientHumidity=50;thermal.AmbientWindKmh=5;
        double begin=MSTimeF();
        for(int i=0;i<bodies.Size();i++)CaelumSealClimate.ApplyThermal(bodies[i],thermal);
        double baseline=MSTimeF()-begin;
        let effect=Start(CaelumConstants.SEAL_FIRE);effect.ClimatePulse();begin=MSTimeF();
        for(int i=0;i<bodies.Size();i++)CaelumSealClimate.ApplyThermal(bodies[i],thermal);
        double climate=MSTimeF()-begin;
        effect=Start(CaelumConstants.SEAL_EARTH);effect.ClimatePower=1.7;
        begin=MSTimeF();for(int tic=0;tic<TICRATE;tic++)effect.ApplyContinuousEffect();
        double earth=MSTimeF()-begin;
        Console.Printf("CA252 PERF bodies=500 baselineSamplesMs=%.3f climateSamplesMs=%.3f earth35TicsMs=%.3f",baseline,climate,earth);
        Check(bodies.Size()==500,"500 living combatant service benchmark completed");
        User.StopSealChannel(false,false);for(int i=0;i<bodies.Size();i++)bodies[i].Destroy();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c252_setup")Setup();
        else if(e.Name=="c252_formulas")Formulas();
        else if(e.Name=="c252_earth")Earth();
        else if(e.Name=="c252_gravity")Gravity();
        else if(e.Name=="c252_environment")Environment();
        else if(e.Name=="c252_defenses")Defenses();
        else if(e.Name=="c252_presentation")Presentation();
        else if(e.Name=="c252_roof")Roof();
        else if(e.Name=="c252_seed")Seed();
        else if(e.Name=="c252_loaded")Loaded();
        else if(e.Name=="c252_gravity_seed")GravitySeed();
        else if(e.Name=="c252_gravity_loaded" || e.Name=="c252_gravity_load_expired")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let checkpoint=CA252Checkpoint(User.FindInventory("CA252Checkpoint"));
            let binding=checkpoint!=null?CaelumSealGravity.Get(checkpoint.Body):null;
            if(e.Name=="c252_gravity_loaded")
            {
                Check(binding!=null,"body-bound aftereffect survives save/load");
                if(binding!=null){Number(binding.Factor,5.1,"gravity factor preserved");Check(binding.RemainingTics>0 && binding.RemainingTics<35,"remaining native tics preserved");}
            }
            else {Check(binding==null,"loaded aftereffect expires");Number(checkpoint.Body.Gravity,1,"loaded aftereffect restores original gravity");}
        }
        else if(e.Name=="c252_manual")ManualSetup();
        else if(e.Name=="c252_next")NextSeal();
        else if(e.Name=="c252_overview")User.Pitch=0;
        else if(e.Name=="c252_groundview")User.Pitch=35;
        else if(e.Name=="c252_interruptions")Interruptions();
        else if(e.Name=="c252_performance")Performance();
        else if(e.Name=="c252_upgrade")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let effect=CaelumChannelEffect(User.CombatChannelEffectActor);
            Check(effect!=null,"authentic 5.4.20 active channel loads");
            if(effect!=null)
            {
                effect.EnsureClimateState();
                Number(effect.ClimateRevision,1,"legacy source upgrades once");
                Number(effect.ClimatePower,0,"legacy source has no retroactive power");
                Number(effect.ClimateTotal,0,"legacy source has no retroactive weather");
                Check(effect.PulseAccumulator>=0.5 && effect.PulseAccumulator<0.9,"legacy pulse phase continues");
                double phase=effect.PulseAccumulator;effect.EnsureClimateState();
                Number(effect.PulseAccumulator,phase,"repeat upgrade is inert");
                User.StopSealChannel(false,false);
                Check((User.player.cheats&CF_CHASECAM)==0,"upgraded stop restores first person");
            }
        }
        else if(e.Name=="c252_travelled")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            Check(!User.CombatChannelModeActive && User.CombatChannelEffectActor==null,"travel stops old-map channel");
            Check((User.player.cheats&CF_CHASECAM)==0,"travel restores prior camera");
            Check(ThinkerIterator.Create("CaelumChannelSealMark").Next()==null,"travel leaves no old seal mark");
            Check(ThinkerIterator.Create("CaelumChannelSealOrb").Next()==null,"travel leaves no old elemental orb");
        }
        else if(e.Name=="c252_falling")Falling();
        else if(e.Name=="c252_fallen")
        {
            Check(Faller.Pos.Z<FallStart,"amplified body falls under native physics");
            Number(Flyer.Pos.Z,512,"natural flight ignores gravity amplification");
        }
        else if(e.Name=="c252_gravity_expired")
        {Number(Faller.Gravity,1,"native tics expire gravity once");Check(CaelumSealGravity.Get(Faller)==null,"expired inventory removed");}
        else if(e.Name=="c252_early")
        {let f=CaelumChannelEffect(User.CombatChannelEffectActor);Check(f!=null && f.ClimatePower==0,"native User2 no early pulse");}
        else if(e.Name=="c252_first" || e.Name=="c252_second" || e.Name=="c252_third")
        {
            int n=e.Name=="c252_first"?1:e.Name=="c252_second"?2:3;
            let f=CaelumChannelEffect(User.CombatChannelEffectActor);
            Check(f!=null,"native User2 channel remains active");
            if(f!=null)
            {
                Number(f.ClimateTotal,1.7*n*(n+1)/2,"native timed cumulative temperature");
                Check(f.ChannelMark!=null && (User.player.cheats&CF_CHASECAM)!=0,"native input enables mark and chasecam");
            }
        }
        else if(e.Name=="c252_stopped")
        {Check(!User.CombatChannelModeActive && User.CombatChannelEffectActor==null,"native User2 stops channel");Check(User.CombatChannelCooldownRemaining>59,"existing cooldown starts");Check((User.player.cheats&CF_CHASECAM)==0,"native input restores original camera");}
        else if(e.Name=="c252_done")Console.Printf("CA252 DONE passes=%d failures=%d",Passed,Failed);
    }
}
