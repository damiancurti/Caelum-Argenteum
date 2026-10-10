class CA154FallBody : CaelumCombatActor
{
    override void PostBeginPlay()
    {Super.PostBeginPlay();InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);}
    Default {Radius 16;Height 56;Mass 80;Health 800; +SOLID +SHOOTABLE +CANPASS}
    States {Spawn: TNT1 A -1;Stop;}
}
class CA154Hazards : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    CA154FallBody Bodies[6];
    double Peaks[6];
    bool Landed[6];
    CaelumTrapdoor Trap;
    CaelumHazardRock Rock;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA154 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        Elapsed++;
        if(Elapsed==20)
        {
            for(int i=0;i<6;i++)Bodies[i]=CA154FallBody(Actor.Spawn("CA154FallBody",(1000+i*500,1000,0)));
            Trap=CaelumTrapdoor(Actor.Spawn("CaelumTrapdoor",(5000,0,320)));
            Rock=CaelumHazardRock(Actor.Spawn("CaelumHazardRock",(6000,0,400)));
        }
        if(Elapsed==22)
        {
            for(int i=0;i<6;i++)
            {
                let body=Bodies[i];body.Mass=i%3==0 ? 50 : i%3==1 ? 80 : 200;
                body.InitializeCombatProfile(0,0,0,0,0,0,0,0,0,0,0,0);
                if(i>=3)body.Gravity=0.5;
                body.SetOrigin((body.Pos.X,body.Pos.Y,320),false);body.Vel=(0,0,0);
                Check(String.Format("local gravity body=%d SI=%.9f",i,CaelumPhysicsUnits.AccelerationSI(body.GetGravity())),Abs(CaelumPhysicsUnits.AccelerationSI(body.GetGravity())-(i>=3 ? 4.905 : 9.81))<0.000001);
            }
            let user=CaelumPlayer(players[0].mo);user.SetOrigin(Trap.Pos+(0,0,Trap.Height),false);user.Vel=(0,0,0);
            Check("trap support retains intentional no-gravity",Trap.bNoGravity);
            Check("hazard rock releases only once",Rock.Release() && !Rock.Release());
        }
        if(Elapsed>22 && Elapsed<140)
        {
            for(int i=0;i<6;i++)
            {
                let body=Bodies[i];if(Landed[i])continue;
                Peaks[i]=Max(Peaks[i],-body.Vel.Z);
                if(body.Pos.Z<=body.floorz && body.Vel.Z<=0)
                {
                    Landed[i]=true;
                    double expected=Sqrt(2*body.GetGravity()*320);
                    double raw=body.LastImpactRawDeltaSpeed;
                    // RegisterWorldImpact supplies an already-absorbed delta;
                    // ReceiveCaelumImpact resets the legacy diagnostic field.
                    double absorbed=body.GetBiologicalLandingAbsorptionSpeed();
                    double equivalent=ImpactPhysics.EquivalentTics(body.Height,raw)*Sqrt(CaelumPhysicsUnits.GRAVITY_RATIO);
                    double percent=ImpactPhysics.EnergyPercent(equivalent);
                    Check(String.Format("fall body=%d mass=%d speed=%.9f continuous=%.9f absorbed=%.9f severity=%.9f expected=%.9f HP=%d",i,body.Mass,Peaks[i],expected,absorbed,body.LastImpactDamagePercent,percent,body.health),Abs(Peaks[i]-expected)<body.GetGravity()*1.1 && Abs(raw-Max(0.0,Peaks[i]-absorbed))<body.GetGravity()*1.1 && Abs(body.LastImpactDamagePercent-percent)<0.000001 && body.health>0);
                }
            }
        }
        if(Elapsed==140)
        {
            let user=CaelumPlayer(players[0].mo);
            Check("trap opens once and permits native fall",Trap.Opened && Trap.ActivationCount==1 && !Trap.bSolid && user.Pos.Z==0);
            Check("falling rock reaches floor under gravity",Rock.Released && Rock.Pos.Z<=Rock.floorz+0.01 && Rock.Vel.Z==0);
            Console.Printf("CA154 HAZARDS COMPLETE pass=%d fail=%d",Passed,Failed);
        }
    }
}
