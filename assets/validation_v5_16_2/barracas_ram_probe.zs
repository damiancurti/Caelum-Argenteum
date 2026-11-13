// Sondas aisladas: se repite el paso fisico normal sin acelerar sus constantes.
class CA454RamProbe : EventHandler
{
    CaelumBatteringRam Ram;
    CaelumBreakableGate Gate;
    int CaseIndex,Steps,Failures,Passed;
    bool Running;

    void StartCase()
    {
        if(CaseIndex>=10)
        {
            Running=false;
            Console.Printf("CA454 RAM COMPLETE passed=%d failures=%d",Passed,Failures);
            return;
        }
        bool legacy=CaseIndex>=8;
        int index=legacy?3:CaseIndex/2;
        vector3 p=CA454RamData.GatePoint(index);
        double outward=CA454RamData.GateAngle(index);
        vector3 normal=(Cos(outward),Sin(outward),0);
        vector3 tangent=(-Sin(outward),Cos(outward),0);
        Gate=CaelumBreakableGate(Actor.Spawn("CaelumBreakableGate",p,NO_REPLACE));
        Gate.Angle=outward+90;Gate.args[1]=CA454RamData.GateMaterial(index);Gate.args[2]=1;Gate.InitializeGate();
        Ram=CaelumBatteringRam(Actor.Spawn("CaelumBatteringRam",p+normal*512+tangent*256,NO_REPLACE));
        Ram.Angle=outward+180;Ram.Large=CaseIndex%2==1;Ram.InitializeRam();
        Ram.SetRoute(Gate,outward+180,!legacy);
        Ram.AddRoutePoint(p+normal*512);
        Ram.AddRoutePoint(p+normal*CaelumRamData.TRIAL_CONTACT_DISTANCE*Ram.SizeFactor);
        Steps=0;
        Console.Printf("CA454 RAM START case=%d large=%d legacy=%d",CaseIndex,Ram.Large,legacy);
    }

    void FinishCase(bool ok)
    {
        if(ok)Passed++;else Failures++;
        Console.Printf("CA454 RAM CASE %s case=%d steps=%d impacts=%d damage=%d position=(%.3f,%.3f) angle=%.3f",ok?"PASS":"FAIL",CaseIndex,Steps,Ram.ImpactCount,Ram.LastDamage,Ram.Pos.X,Ram.Pos.Y,Ram.Angle);
        Ram.Destroy();Gate.Destroy();CaseIndex++;StartCase();
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_ram_start")
        {
            let user=players[0].mo;user.bInvulnerable=true;
            Running=true;StartCase();
        }
        if(e.Name=="ca454_ram_resume")
            Console.Printf("CA454 RAM RESUME case=%d steps=%d revision=%d heading=%d",CaseIndex,Steps,Ram==null?-1:Ram.RouteRevision,Ram!=null && Ram.FollowRouteHeading);
    }

    override void WorldTick()
    {
        if(!Running)return;
        for(int n=0;n<32 && Running;n++)
        {
            vector3 before=Ram.Pos;double angle=Ram.Angle;
            bool moving=Ram.AdvanceRoute();Steps++;
            double turn=Abs(Ram.DeltaAngle(angle,Ram.Angle));
            bool ok=(Ram.Pos-before).Length()<=CaelumRamData.APPROACH_SPEED+0.00001
                && turn<=VectorAngle(-CaelumRamData.FRAME_REAR*Ram.SizeFactor,CaelumRamData.APPROACH_SPEED)+0.00001;
            if(Ram.FollowRouteHeading && turn>0.001 && (Ram.Pos-before).Length()>0.00001)ok=false;
            if(!Ram.FollowRouteHeading && Ram.RouteIndex<Ram.Route.Size() && turn>0.001)ok=false;
            if(Ram.Obstructed || !ok || Steps>10000){FinishCase(false);continue;}
            if(moving)continue;
            Ram.StrikeSerial++;Ram.SpentImpact=false;
            Ram.Head.Vel=(Cos(Ram.Angle),Sin(Ram.Angle),0)*CaelumRamData.STRIKE_SPEED;
            Ram.MoveHead((CaelumRamData.EXTENDED_OFFSET-Ram.StrokeOffset)*Ram.SizeFactor,true);
            let block=CaelumGateBlocker(Ram.LastContact);
            FinishCase(Ram.ImpactCount==1 && block!=null && block.master==Gate && Ram.LastDamage>0);
        }
    }
}
