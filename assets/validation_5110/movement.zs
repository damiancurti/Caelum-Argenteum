// Isolated input/friction and jump observations; no user save is modified.
class CA154Movement : StaticEventHandler
{
    int Stage,Elapsed,FlightTics;
    bool Started,Landed;
    double Peak,Launch,StartHeat,StartAir,FirstHeat,PreviousX;
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || u.DerivedStats==null)return;
        int requested=CVar.GetCVar("ca154_stage").GetInt();
        bool change=Elapsed==0 || requested!=Stage;
        if(change){Stage=requested;Elapsed=0;Started=false;Landed=false;Peak=0;FlightTics=0;}
        Elapsed++;
        double distanceSpeed=CaelumPhysicsUnits.VelocitySI(u.Pos.X-PreviousX);PreviousX=u.Pos.X;
        int attribute=Stage==2 || Stage==3 || Stage==6 || Stage==7 || Stage==9 ? 100 : 0;
        u.Attributes.SetAllForDebug(attribute);
        u.DerivedStats.Recalculate(u.Attributes,u.CharacterProfile);
        let d=u.DerivedStats;
        d.BaseMass=Stage==7 ? 50 : Stage==9 ? 200 : 80;
        d.DebugWeight=Stage==5 || Stage==9 ? 80 : Stage==7 ? 20 : 0;
        d.RefreshCarriedWeightTotals();
        d.LoadRatio=0; // Unpenalized input reference; jump still uses real fixture load.
        if(change){u.health=u.CaelumMaximumHealth;u.player.health=u.health;}
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
        u.SurvivalPerformanceMultiplier=1;u.HealthPerformanceMultiplier=1;
        if(Elapsed<5)u.CurrentAir=d.MaximumAir*(Stage==8 ? 0.2 : 1.0);
        if(Stage<4)u.CurrentAir=d.MaximumAir;
        let thermal=CaelumThermalBody.Get(u,true);thermal.Exposure=0;
        u.UpdateAirStateEffects();u.ApplyPhysicalMovement();
        if(change)
        {
            u.SetOrigin((0,0,0),false);u.Vel=(0,0,0);u.Angle=0;u.Pitch=0;
            u.bNOGRAVITY=false;u.bNOTARGET=true;u.MovementAccelerationFactor=0;
            StartHeat=thermal.ActionJoules;StartAir=u.CurrentAir;Launch=u.JumpZ;
            Console.Printf("CA154 MOVEMENT setup stage=%d mass=%.6f total=%.6f agility=%d jump=%.9f eta=%.6f",Stage,double(d.BaseMass),d.TotalMass,attribute,Launch,CaelumPhysicsUnits.MuscularEfficiency(attribute,attribute));
        }
        if(Stage<4 && (Elapsed==105 || Elapsed==350))
        {
            double expected=(Stage%2==1 ? 8.0 : 4.0)*(attribute==100 ? 4.0 : 1.0);
            double actual=CaelumPhysicsUnits.VelocitySI(u.Vel.XY.Length());
            Console.Printf("CA154 MOVEMENT %s stage=%d tic=%d speed=%.9f distanceSpeed=%.9f target=%.6f acceleration=%.9f forward=%.9f load=%.6f",Elapsed!=350 || (Abs(actual-expected)<0.02 && Abs(distanceSpeed-expected)<0.02) ? "PASS" : "FAIL",Stage,Elapsed,actual,distanceSpeed,expected,u.MovementAccelerationFactor,u.ForwardMove1,d.LoadRatio);
        }
        if(Stage<4)return;
        if(!Started && u.Vel.Z>0)
        {
            Started=true;FirstHeat=thermal.ActionJoules-StartHeat;
            Console.Printf("CA154 JUMP takeoff stage=%d vel=%.9f airDebit=%.9f actionJ=%.9f",Stage,u.Vel.Z,StartAir-u.CurrentAir,FirstHeat);
        }
        if(Started && !Landed)
        {
            FlightTics++;Peak=Max(Peak,u.Pos.Z);
            if(u.Pos.Z<=u.floorz && u.Vel.Z<=0)
            {
                Landed=true;
                double gravity=u.GetGravity();double ideal=Launch*Launch/(2*gravity);
                double work=d.TotalMass*CaelumPhysicsUnits.VelocitySI(Launch)**2/2;
                double expected=CaelumThermalRules.PositiveWorkHeat(work,CaelumPhysicsUnits.MuscularEfficiency(attribute,attribute));
                double heat=thermal.ActionJoules-StartHeat;
                Console.Printf("CA154 JUMP %s stage=%d peakMU=%.9f idealMU=%.9f flightTics=%d heat=%.9f expected=%.9f HP=%d maxHP=%d impact=%.9f",Abs(Peak-ideal)<=Launch && Abs(heat-expected)<0.001 && u.health==u.CaelumMaximumHealth ? "PASS" : "FAIL",Stage,Peak,ideal,FlightTics,heat,expected,u.health,u.CaelumMaximumHealth,u.LastImpactDeltaSpeed);
            }
        }
    }
}
