// Isolated diagnostics. No test controls enter the production package.
class CA152Observer : StaticEventHandler
{
    int Elapsed, Checks, Failures, Transitions, LastStage;
    bool LastAim;
    CaelumCarbineAmmo Rejected;
    CaelumShotgunAmmo FloorShells;
    void Check(bool ok,String label)
    { Checks++;if(!ok)Failures++;Console.Printf("CA152 %s %s",ok ? "PASS" : "FAIL",label); }
    override void WorldLoaded(WorldEvent e)
    {Elapsed=0;Checks=0;Failures=0;Transitions=0;LastStage=-1;}
    void Report(CaelumPlayer u)
    {
        let it=ThinkerIterator.Create("CaelumCarbineAmmo");CaelumCarbineAmmo a;
        while((a=CaelumCarbineAmmo(it.Next()))!=null)
            Console.Printf("CA152 AMMO class=%s owner=%d amount=%d special=%d nosector=%d noblockmap=%d scale=%.3f pos=%.2f,%.2f,%.2f",a.GetClassName(),a.Owner==u,a.Amount,a.bSpecial,a.bNoSector,a.bNoBlockmap,a.Scale.X,a.Pos.X,a.Pos.Y,a.Pos.Z);
        let t=CaelumThermalBody.Get(u,true);
        Console.Printf("CA152 THERMAL mass=%.6f moved=%.6f gravity=%.6f E=%.6f inertia=%.6f jumpJ=%.6f sweat=%.9f wet=%.6f",t.BodyMassKg,t.MovedMassKg,CaelumThermalMotion.Gravity(u),t.Exposure,t.Inertia,t.ReferenceJumpHeat,t.SweatRateKgHour,t.WetnessPercent);
    }
    void Pickup(CaelumPlayer u)
    {
        Actor toucher=u;
        let source=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",u.Pos+(100,0,0)));
        source.Amount=20;
        Check(source.CallTryPickup(toucher),"first shell pickup succeeds");
        let held=u.FindNativeAmmunition(6);
        Check(held!=null && held.Amount==20 && held.Owner==u,"first shell stack owned with exact amount");
        Check(held!=null && held.bNoSector && held.bNoBlockmap && !held.bSpecial,"owned shell is removed from rendering collision and pickup");
        source=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",u.Pos+(100,0,0)));source.Amount=20;
        Check(source.CallTryPickup(toucher) && held.Amount==40,"repeat source increments once");
        u.GiveInventory("CaelumCarbineAmmo",31);
        Check(u.FindNativeAmmunition(0).Amount==31 && held.Amount==40,"carbine and shotgun stacks stay distinct");
        Check(u.AcquireJavelinAmmunition(3,2),"shared javelin acquisition succeeds");
        let j=u.FindNativeAmmunition(3);
        Check(j!=null && j.bNoSector && j.bNoBlockmap && !j.bSpecial,"shared javelin stack is held");
        let bullets=u.FindNativeAmmunition(0);bullets.Amount=100000000;u.OnNativeInventoryChanged();
        Rejected=CaelumCarbineAmmo(Actor.Spawn("CaelumShotgunAmmo",u.Pos+(100,0,0)));Rejected.Amount=20;
        Check(!Rejected.CallTryPickup(toucher) && Rejected.Owner==null && held.Amount==40,"full inventory rejects without consuming source");
        bullets.Amount=31;u.OnNativeInventoryChanged();
        Check(Rejected.CallTryPickup(toucher) && held.Amount==60,"rejected source can be retried once capacity returns");
        Report(u);
    }
    void ThermalDiagnostic(CaelumPlayer u)
    {
        let t=CaelumThermalBody.Get(u,true);CaelumThermalBody.Refresh(u,t);
        double vertical=CaelumThermalRules.PositiveWorkHeat(t.MovedMassKg*CaelumThermalMotion.Gravity(u)*8.25);
        Console.Printf("CA152 THERMAL_DIAG vertical_8.25m_J=%.6f jump_J=%.6f vertical_deltaE=%.6f jump_deltaE=%.6f ratio=%.6f",vertical,t.ReferenceJumpHeat,vertical/t.Inertia,t.ReferenceJumpHeat/t.Inertia,vertical/t.ReferenceJumpHeat);
        for(int wet=0;wet<2;wet++)
        {
            let copy=t.CopyForForecast();copy.Exposure=CaelumThermalRules.Threshold(1,copy.Toughness)-0.01;
            if(wet==0)for(int slot=0;slot<4;slot++){copy.BaseWaterKg[slot]=0;copy.ActorWaterKg[slot]=0;copy.WorkWaterKg[slot]=0;}
            Console.Printf("CA152 REGULATION wet=%d seconds=0 E=%.6f severity=%d sweat_rate_rule=%.9f",wet,copy.Exposure,CaelumThermalRules.Severity(copy.Exposure,copy.Toughness),CaelumThermalRules.SweatRate(copy.Exposure,copy.SurfaceArea,copy.Hydration));
            for(int step=1;step<=60;step++)
            {
                CaelumThermalService.Integrate(copy,30,30.0/60.0);
                if(step==2 || step==10 || step==60)Console.Printf("CA152 REGULATION wet=%d seconds=%d E=%.6f sweat=%.9f hydration=%.6f",wet,step*30,copy.Exposure,copy.SweatRateKgHour,copy.Hydration);
            }
            copy.Destroy();
        }
        Console.Printf("CA152 THERMAL_DIAG COMPLETE isolated forecast copies; production state unchanged");
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;Elapsed++;
        int mode=CVar.GetCVar("ca152_mode").GetInt();
        if(Elapsed==10 && level.MapName=="CA152")
        {u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;u.bINVULNERABLE=true;}
        if(Elapsed==60 && level.MapName=="CA152" && mode!=1)
        {
            let h=new("CA136Checks");h.Equip(u,CVar.GetCVar("ca152_weapon").GetInt());u.GiveInventory("CaelumShotgunAmmo",20);
            u.SetRangedMagazineCount(14,2);u.Angle=90;u.Pitch=0;u.SetOrigin((2300,4310,0),false);
        }
        if(mode==1 && Elapsed==60)Pickup(u);
        if(mode==1 && Elapsed==65)Console.Printf("CA152 COMPLETE checks=%d failures=%d",Checks,Failures);
        if(mode==0 && (Elapsed==1 || Elapsed==35))Report(u);
        if(mode==4 && Elapsed==35)ThermalDiagnostic(u);
        if(mode==5 && Elapsed==65)
        {
            FloorShells=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",u.Pos+(20,80,0)));
            Actor.Spawn("CaelumCarbineAmmo",u.Pos+(-20,80,0));u.Pitch=35;
            Console.Printf("CA152 WORLD before=%d scale=%.6f",u.FindNativeAmmunition(6).Amount,FloorShells.Scale.X);
        }
        if(mode==5 && Elapsed==125){u.SetOrigin((2320,4350,0),false);u.Pitch=0;}
        if(mode==5 && Elapsed==170)
        {
            Check(u.FindNativeAmmunition(6).Amount==40,"native touch collects exactly twenty floor cartridges");
            Check(FloorShells==null,"native touch destroys the source actor");
            Check(u.FindNativeAmmunition(6).bNoSector && !u.FindNativeAmmunition(6).bSpecial,"native touch keeps only a held stack");
            Console.Printf("CA152 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
        if(mode==2 && Elapsed>=80)
        {
            if(u.RangedAimModeActive!=LastAim)
            {Transitions++;LastAim=u.RangedAimModeActive;Console.Printf("CA152 AIM tic=%d stage=%d aim=%d transitions=%d alt=%d zoom=%d",Elapsed,CVar.GetCVar("ca152_stage").GetInt(),LastAim,Transitions,(u.player.cmd.buttons&BT_ALTATTACK)!=0,(u.player.cmd.buttons&BT_ZOOM)!=0);}
            int stage=CVar.GetCVar("ca152_stage").GetInt();
            if(stage!=LastStage)
            {
                LastStage=stage;
                if(stage>=1 && stage<=4)Check(Transitions==stage,String.Format("input checkpoint %d has exactly %d transitions",stage,stage));
                if(stage==5)Console.Printf("CA152 COMPLETE checks=%d failures=%d transitions=%d",Checks,Failures,Transitions);
            }
        }
    }
}
