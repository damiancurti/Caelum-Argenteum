class CA411FireChecks : EventHandler
{
    int Passed,Failed;
    override void WorldTick()
    {
        if(level.maptime>2)return;let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let record=u.GetPersistentCharacterState(true);record.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.A_SetBlend("Black",0,1);
    }
    void Check(bool yes,String label)
    {if(yes)Passed++;else Failed++;Console.Printf("CA411F %s %s",yes?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA411F RESULT passes=%d failures=%d",Passed,Failed);}
    bool Near(double a,double b){return Abs(a-b)<0.00001;}
    void Setup(CaelumPlayer u)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.CombatTimeRemaining=0;u.SetOrigin((64,128,0),false);u.Vel=(0,0,0);u.Angle=0;
        u.DerivedStats.CarryCapacity=1000;u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        CaelumThermalWorld.Get().ReferenceClock=CaelumWorldClock.Get(u,true);
        let persistent=u.GetPersistentCharacterState(true);persistent.ProfileCommitted=true;persistent.WorldPendingConnection=0;
    }
    void GiveWood(CaelumPlayer u,int grams)
    {
        let existing=u.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_WOOD,1);
        if(existing!=null){existing.Amount+=grams;u.OnNativeInventoryChanged();return;}
        let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos,NO_REPLACE));
        item.args[0]=CaelumConstants.MATERIAL_WOOD;item.args[1]=1;item.Amount=grams;
        item.InMagicBox=false;item.AttachToOwner(u);item.UpdateMaterialVisuals();u.OnNativeInventoryChanged();
    }
    int Wood(CaelumPlayer u){return u.CountCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1);}
    void Finish(CaelumPlayer u)
    {u.CraftingTaskRemainingSeconds=CaelumThermalRuntime.WorldTicSeconds();u.UpdateCraftingTask();}
    void Advance(CaelumCampFire fire,double seconds)
    {fire.Advance();fire.Stamp-=seconds;fire.Advance();}
    CaelumCampFire Fire()
    {let world=CaelumCampWorld.Get();return world.Fires.Size()>0?world.Fires[0]:null;}
    void Core(CaelumPlayer u)
    {
        Setup(u);GiveWood(u,20000);int initial=Wood(u);
        Check(!CaelumCampFireWork.Begin(u,null,99,1000),"reject unsupported action");
        Check(!CaelumCampFireWork.Begin(u,null,1,10001),"reject excess capacity");
        u.SetOrigin((384,128,16),false);
        Check(!CaelumCampFireWork.Begin(u,null,1,1000),"paving permission rejected");
        u.SetOrigin((64,128,0),false);
        double distance=u.Radius+CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_DIAMETER_M)/2+CaelumPlacementGeometry.SUPPORT_TOLERANCE_MU;
        vector3 point=u.Pos+(distance,0,0);
        Console.Printf("CA411F DIAG wood=%d available=%d fits=%d land=%d radius=%g point=%g,%g,%g",Wood(u),CaelumCampTask.Available(u),CaelumCampFireWork.Fits(u,point),CaelumCampLand.Allows(u,point,CaelumPhysicsUnits.MapUnits(0.3)),u.Radius,point.X,point.Y,point.Z);
        Console.Printf("CA411F DIAG authority=%d health=%d state=%d frozen=%d talk=%d combat=%g craft=%d recipe=%d sleep=%d",CaelumPlayerAuthority.CanMutate(u),u.health,u.player.playerstate,u.isFrozen(),u.HasActiveConversation(),u.CombatTimeRemaining,u.CraftingTaskActive,CaelumRecipeSession.Working(u),CaelumSleepRules.IsSleeping(u));
        Check(CaelumCampFireWork.Begin(u,null,1,10000),"assemble on permitted clear ground");
        Check(Near(u.CraftingTaskRemainingSeconds,60),"one world minute to assemble and ignite");
        Check(u.CountRawCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)==initial,"reserved fuel not consumed early");
        u.CancelCraftingTask();Check(Wood(u)==initial && Fire()==null,"cancel preserves wood and no fire");
        Check(CaelumCampFireWork.Begin(u,null,1,10000),"assembly restarts");
        u.Attributes.Dexterity=100;u.UpdateCraftingTask();
        Check(Near(u.CraftingTaskRemainingSeconds,60-1.0/TICRATE),"Dexterity does not shorten assembly");
        Finish(u);let fire=Fire();Check(fire!=null,"native completion deploys campfire");
        if(fire==null){Result();return;}
        Check(!CaelumCampFireWork.Begin(u,null,1,1000),"occupied fire footprint rejects overlapping camp placement");
        Check(Wood(u)==initial-10000 && Near(fire.Fuel.FuelGrams,10000),"fuel transferred once");
        Check(fire.Fuel.Lit && Near(fire.Watts(),8000),"lit fire exposes approved heat source");
        Check(CaelumThermalWorld.Get().FireSources.Find(fire)<CaelumThermalWorld.Get().FireSources.Size(),"thermal event registry sees spawn immediately");
        Advance(fire,3600);Check(Near(fire.Fuel.FuelGrams,8080),"one world hour burns 1.92 kg");
        Check(!fire.RecoverWood(u),"cannot recover burning wood");
        fire.Extinguish();double fuel=fire.Fuel.FuelGrams;Advance(fire,3600);
        Check(Near(fire.Fuel.FuelGrams,fuel) && Near(fire.Watts(),0),"extinguished fire has no fuel loss or heat");
        Check(fire.LoadWood(u,10000) && Near(fire.Fuel.FuelGrams,10000),"refill limited by 10 kg capacity");
        Check(!fire.LoadWood(u,1),"full fire rejects extra fuel");
        Check(CaelumCampFireWork.Begin(u,fire,2),"relight starts");Finish(u);
        Check(fire.Fuel.Lit,"relight completes");Advance(fire,1);fire.Extinguish();
        double remaining=fire.Fuel.FuelGrams;int before=Wood(u);
        Check(fire.RecoverWood(u),"unburned fuel recovered");
        let credit=CaelumCampFuelCredit.Get(u);
        Console.Printf("CA411F DIAG recovery before=%d after=%d fraction=%g remaining=%g",before,Wood(u),credit.Grams,remaining);
        Check(credit!=null && Near(Wood(u)-before+credit.Grams,remaining),"fractional recovery conserves fuel exactly");
        Check(Near(CaelumCampFuelCredit.Weight(u),credit.Grams/1000),"fractional fuel retains carried mass");
        Check(!CaelumCampFireWork.Begin(u,fire,2),"empty fire cannot relight");
        before=Wood(u);double fractional=credit.Grams;
        Check(fire.LoadWood(u,1) && Near(fire.Fuel.FuelGrams,1+fractional) && Near(credit.Grams,0) && Wood(u)==before-1,"refill reuses fractional wood without duplication");
        Check(CaelumCampFireWork.Begin(u,fire,2),"small fuel charge relights");Finish(u);Advance(fire,3600);
        Check(Near(fire.Fuel.FuelGrams,0) && !fire.Fuel.Lit && Near(fire.Watts(),0),"exhaustion extinguishes at zero");
        Check(CaelumCampFireWork.Begin(u,fire,3),"dismantle begins when out");
        Check(Near(u.CraftingTaskRemainingSeconds,60),"dismantle takes one world minute");
        u.CancelCraftingTask();Check(Fire()==fire && fire.Busy==null,"cancel dismantle keeps fire and releases ownership lock");
        Check(CaelumCampFireWork.Begin(u,fire,3),"dismantle restarts");Finish(u);
        Check(Fire()==null,"dismantle removes camp registry entry");
        Check(CaelumThermalWorld.Get().FireSources.Find(fire)==CaelumThermalWorld.Get().FireSources.Size(),"destroy removes thermal source immediately");
        Result();
    }
    void Seed(CaelumPlayer u,bool taskOnly)
    {
        Setup(u);GiveWood(u,10000);Check(CaelumCampFireWork.Begin(u,null,1,10000),"persistent assembly begins");
        if(!taskOnly){Finish(u);Check(Fire()!=null && Fire().Fuel.Lit,"persistent fire lit");}
        Result();
    }
    CaelumCampPot Pot(CaelumPlayer u)
    {
        let pot=CaelumCampPot(Actor.Spawn('CaelumCampPot',u.Pos,NO_REPLACE));pot.AttachToOwner(u);
        pot.WaterLiters=1;pot.WaterQuality=CaelumWaterQuality.BIOLOGICAL|CaelumWaterQuality.CHEMICAL|CaelumWaterQuality.SALT;
        pot.WaterTemperatureC=20;pot.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;pot.StampTemperature(u);
        return pot;
    }
    void PotChecks(CaelumPlayer u)
    {
        Seed(u,false);let fire=Fire();if(fire==null)return;let pot=Pot(u);
        Check(fire.MountPot(u,pot) && fire.Pot==pot && pot.Owner==fire,"mount keeps original pot identity");
        Check(!CaelumCampFireWork.Begin(u,fire,3),"cannot dismantle with attached pot");
        double total=CaelumCampPhysics.BoilingSeconds(1,20);
        Advance(fire,total-1);
        Check(Near(pot.WaterTemperatureC,100) && (pot.WaterQuality&CaelumWaterQuality.BIOLOGICAL)!=0,"water reaches boil but needs full 60 seconds");
        Advance(fire,1.001);
        Check((pot.WaterQuality&CaelumWaterQuality.BIOLOGICAL)==0 && (pot.WaterQuality&CaelumWaterQuality.CHEMICAL)!=0 && (pot.WaterQuality&CaelumWaterQuality.SALT)!=0,"boil removes only biological contamination");
        Check(Abs(pot.WaterLiters-(1-120000.0/2257000))<0.00001,"approved useful heat determines evaporation");
        fire.Extinguish();double volume=pot.WaterLiters;Advance(fire,600);
        Check(pot.WaterTemperatureC<100 && pot.WaterTemperatureC>=0 && Near(pot.WaterLiters,volume),"extinguished mounted pot cools without invented refills");
        double retained=pot.WaterTemperatureC;Check(fire.TakePot(u) && pot.Owner==u && fire.Pot==null,"take returns original pot");
        Check(Near(pot.WaterLiters,volume) && Near(pot.WaterTemperatureC,retained),"take preserves water state");
        pot.InMagicBox=true;Check(!fire.MountPot(u,pot),"boxed pot cannot mount");pot.InMagicBox=false;
        Check(fire.MountPot(u,pot),"remount same pot");
        u.DerivedStats.CarryCapacity=0;Check(!fire.TakePot(u) && pot.Owner==fire,"overloaded pickup preserves mounted pot");u.DerivedStats.CarryCapacity=1000;
        Check(fire.TakePot(u),"pickup succeeds after capacity restored");Result();
    }
    void PotSeed(CaelumPlayer u)
    {Seed(u,false);Check(Fire().MountPot(u,Pot(u)),"persistent pot mounted");Fire().Extinguish();Result();}
    void PotLoad(CaelumPlayer u)
    {Setup(u);let fire=Fire();Check(fire!=null && fire.Pot!=null && fire.Pot.Owner==fire,"native save preserves mounted pot ownership");if(fire!=null && fire.Pot!=null){Check(Near(fire.Pot.WaterLiters,1) && fire.Pot.WaterQuality==7,"native save preserves volume and contamination");Check(fire.TakePot(u),"native saved pot can be retrieved");}Result();}
    void WaitCheck(CaelumPlayer u)
    {
        Seed(u,false);let fire=Fire();if(fire==null)return;double before=fire.Fuel.FuelGrams;
        let forecast=new('CaelumTimeSkipModel');forecast.CaptureSkip(u,false);
        Check(forecast.Done && forecast.Reason=="CA_SKIP_FORECAST_EFFECT","mutable fire prevents stale exact-date forecast");
        let clock=CaelumWorldClock.Get(u);double stamp=CaelumThermalRuntime.Stamp(clock);
        for(int i=0;i<TICRATE*10;i++)CaelumTimeAdvanceState.SimulatePersonalTic(u);
        double elapsed=CaelumThermalRuntime.Stamp(clock)-stamp;
        Check(Near(elapsed,10),"accelerated personal steps advance ten Limbo world seconds");
        Check(Abs(fire.Fuel.FuelGrams-(before-10*1920.0/3600))<0.0001,"accelerated wait burns world-time fuel once");Result();
    }
    void UIStart(CaelumPlayer u)
    {Setup(u);if(Wood(u)<20000)GiveWood(u,20000-Wood(u));Check(CaelumCampFireSession.Show(u,null),"wood action opens real live menu");Result();}
    void UIComplete(CaelumPlayer u)
    {
        Check(CaelumCampTask.Active(u) && CaelumCampTask.Find(u).FireAction==1,"network menu action begins production assembly");
        Check(CaelumTimeAdvanceState.Toggle(u),"attended camp assembly supports native accelerated time");
        for(int i=0;i<32 && u.CraftingTaskActive;i++){CaelumTimeAdvanceState.Get(u).LastPumpTic=-1;CaelumTimeAdvanceState.Pump(u);}
        Check(Fire()!=null && !u.CraftingTaskActive,"accelerated assembly completes without force-finishing");
        if(Fire()!=null)Check(Fire().Used(u) && CaelumCampFireSession.Find(u).Open,"world Use opens management panel");Result();
    }
    void Report(CaelumPlayer u)
    {
        let fire=Fire();if(fire==null){Console.Printf("CA411F RESULT no deployed fire");return;}
        fire.Advance();Console.Printf("CA411F RESULT wood=%.6f g lit=%d carried=%d g heat=%.0f W",fire.Fuel.FuelGrams,fire.Fuel.Lit,Wood(u),fire.Watts());
        if(fire.Pot!=null)Console.Printf("CA411F POT volume=%.6f L temperature=%.3f C quality=%d boiling=%.3f s",fire.Pot.WaterLiters,fire.Pot.WaterTemperatureC,fire.Pot.WaterQuality,fire.Pot.CampBoilSeconds);
    }
    void Loaded(CaelumPlayer u,bool returned)
    {
        Setup(u);let fire=Fire();Check(fire!=null,"campfire restored");
        if(fire==null){Result();return;}
        Check(fire.CanManage(u),"lawful ownership restored");
        Check(fire.Fuel.Lit!=returned,"save preserves burning; hub departure extinguishes");
        Check(fire.Fuel.FuelGrams>9990 && fire.Fuel.FuelGrams<=10000,"fuel retained across native persistence");
        Check(CaelumThermalWorld.Get().FireSources.Find(fire)<CaelumThermalWorld.Get().FireSources.Size(),"thermal registry rebuilt on load");
        Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca411f_core")Core(u);
        else if(e.Name=="ca411f_seed")Seed(u,false);
        else if(e.Name=="ca411f_taskseed")Seed(u,true);
        else if(e.Name=="ca411f_pot")PotChecks(u);
        else if(e.Name=="ca411f_potseed")PotSeed(u);
        else if(e.Name=="ca411f_potload")PotLoad(u);
        else if(e.Name=="ca411f_wait")WaitCheck(u);
        else if(e.Name=="ca411f_ui_start")UIStart(u);
        else if(e.Name=="ca411f_ui_complete")UIComplete(u);
        else if(e.Name=="ca411f_manual"){Setup(u);GiveWood(u,20000);Pot(u);Console.Printf("CA411F RESULT manual ready: wood and full pot supplied");}
        else if(e.Name=="ca411f_read")Report(u);
        else if(e.Name=="ca411f_minute"){if(Fire()!=null)Advance(Fire(),60);Report(u);}
        else if(e.Name=="ca411f_boiled"){if(Fire()!=null && Fire().Pot!=null)Advance(Fire(),CaelumCampPhysics.BoilingSeconds(Fire().Pot.WaterLiters,Fire().Pot.WaterTemperatureC)+1);Report(u);}
        else if(e.Name=="ca411f_camera"){Setup(u);u.SetOrigin((30,92,0),false);u.Angle=30;u.Pitch=30;}
        else if(e.Name=="ca411f_visual_lit"){if(Fire()!=null){Fire().Advance();Fire().Fuel.Lit=true;Fire().RefreshVisual();}}
        else if(e.Name=="ca411f_menu"){Setup(u);CaelumCampFireSession.Show(u,Fire());Result();}
        else if(e.Name=="ca411f_load")Loaded(u,false);
        else if(e.Name=="ca411f_return")Loaded(u,true);
        else if(e.Name=="ca411f_away"){Check(Fire()==null,"no campfire clone on away map");Result();}
        else if(e.Name=="ca411f_taskload")
        {Setup(u);Check(CaelumCampTask.Active(u),"assembly task survives native save");Finish(u);Check(Fire()!=null && Fire().Fuel.Lit && Wood(u)==0,"restored task consumes reserved fuel once");Result();}
    }
}
