// Muestreo continuo con colisión nativa, acotado por tic. No simula multitudes.
class CA454DeploymentFit : Actor
{
    Default { +SOLID +NOGRAVITY +THRUACTORS }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA454DeploymentProbe : EventHandler
{
    Actor Fit;
    int Identity, StepIndex, Samples, Failures, Completed, Points;
    bool Running;
    void StartRoute()
    {
        StepIndex=1;int count=CaelumPropertyRoutes.Count(Identity);
        vector3 start=CaelumPropertyRoutes.Point(Identity,0);
        vector3 end=CaelumPropertyRoutes.Point(Identity,count-1);
        vector3 expected=Identity<CaelumCityData.CREW_COUNT?CaelumPortData.CrewRoutePoint(Identity/2,0):CaelumCityData.GuardStation(Identity-CaelumCityData.CREW_COUNT);
        bool correct=count>1 && count==CaelumCityRoutes.Count(Identity)
            && (start-CaelumCityData.DoorOutside(CaelumPropertyData.ResidentHouse(Identity))).Length()<0.01
            && (end-expected).Length()<0.01;
        if(!correct){Failures++;Console.Printf("CA454 DEPLOY ENDPOINT FAIL id=%d count=%d",Identity,count);}
        Fit.SetOrigin(start,false);Fit.FindFloorCeiling();Points++;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_deployment")return;
        if(!CaelumBarracasData.IsCurrent()){Console.Printf("CA454 DEPLOY FAIL wrong geometry");return;}
        if(Fit!=null)Fit.Destroy();
        Fit=Actor.Spawn("CA454DeploymentFit",(0,0,0),NO_REPLACE);
        Fit.A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
        Fit.MaxStepHeight=GetDefaultByType("CaelumPortDefender").MaxStepHeight;
        Identity=0;Samples=0;Failures=0;Completed=0;Points=0;Running=true;StartRoute();
        int active=0;
        for(int i=6;i<CaelumPortData.GunCount();i++)if(CaelumPortData.ActiveGun(i))active++;
        if(active!=12){Failures++;Console.Printf("CA454 DEPLOY ACTIVE FAIL count=%d",active);}
    }
    override void WorldTick()
    {
        if(!Running)return;
        for(int budget=0;budget<512;budget++)
        {
            int count=CaelumPropertyRoutes.Count(Identity);
            if(StepIndex>=count)
            {
                Completed++;Identity++;
                if(Identity>=CaelumPortData.DefenderCount())
                {
                    Running=false;Fit.Destroy();Fit=null;
                    Console.Printf("CA454 DEPLOY %s routes=%d points=%d samples=%d failures=%d",Failures==0?"PASS":"FAIL",Completed,Points,Samples,Failures);return;
                }
                StartRoute();continue;
            }
            vector3 target=CaelumPropertyRoutes.Point(Identity,StepIndex);
            vector2 delta=target.XY-Fit.Pos.XY;
            if(delta.Length()<0.01){StepIndex++;Points++;continue;}
            bool moved=Fit.TryMove(Fit.Pos.XY+delta.Unit()*Min(16,delta.Length()),true);
            Fit.FindFloorCeiling();FCheckPosition check;Samples++;
            bool ok=moved && Fit.CheckPosition(Fit.Pos.XY,false,check) && check.floorz==0 && check.ceilingz>=Fit.Height;
            if(!ok)
            {
                Failures++;Console.Printf("CA454 DEPLOY MOVE FAIL id=%d step=%d pos=(%.1f,%.1f,%.1f) target=(%.1f,%.1f,%.1f) floor=%.1f ceiling=%.1f",Identity,StepIndex,Fit.Pos.X,Fit.Pos.Y,Fit.Pos.Z,target.X,target.Y,target.Z,check.floorz,check.ceilingz);
                StepIndex=count;
            }
        }
    }
}
