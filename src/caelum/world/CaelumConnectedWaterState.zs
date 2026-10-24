// Estado físico independiente de sectores, actores y reloj. Unidades SI/litros.
// El controlador conserva también el tiempo pendiente cuando limita el trabajo.
class CaelumConnectedWaterState : Object play
{
    int Revision;
    vector2 Liters, AreaM2, DepthM;
    int QualityA, QualityB;
    bool Open;
    double DiameterM, Discharge, InflowLps, DrainLps, InflowHeightM, DrainHeightM;
    double PendingSeconds, NextStepSeconds;
    int LastSteps;

    void Initialize()
    {
        if(Revision>=CaelumConnectedWaterData.REVISION)return;
        Revision=CaelumConnectedWaterData.REVISION;
        AreaM2=(CaelumConnectedWaterData.BASIN_AREA_M2,CaelumConnectedWaterData.BASIN_AREA_M2);
        DepthM=(CaelumConnectedWaterData.BASIN_DEPTH_M,CaelumConnectedWaterData.BASIN_DEPTH_M);
        DiameterM=CaelumConnectedWaterData.OPENING_DIAMETER_M;
        Discharge=CaelumConnectedWaterData.DISCHARGE_COEFFICIENT;
        InflowLps=CaelumConnectedWaterData.INFLOW_LPS;DrainLps=CaelumConnectedWaterData.DRAIN_LPS;
        InflowHeightM=CaelumConnectedWaterData.INFLOW_HEIGHT_M;
        DrainHeightM=CaelumConnectedWaterData.DRAIN_HEIGHT_M;
        Liters=(InflowHeightM*AreaM2.X*1000,DrainHeightM*AreaM2.Y*1000);
        QualityA=CaelumWaterQuality.POTABLE;QualityB=CaelumWaterQuality.POTABLE;
        NextStepSeconds=1;
    }
    clearscope vector2 Heights(vector2 volumes)
    {return (Max(0.0,volumes.X)/(AreaM2.X*1000),Max(0.0,volumes.Y)/(AreaM2.Y*1000));}

    clearscope double FlowLps(vector2 volumes)
    {
        if(!Open || DiameterM<=0 || AreaM2.X<=0 || AreaM2.Y<=0)return 0;
        vector2 h=Heights(volumes);
        if(Abs(h.X-h.Y)<=CaelumConnectedWaterData.HEIGHT_ROUNDOFF_M)return 0;
        double radius=DiameterM*0.5,high=Max(h.X,h.Y),low=Min(h.X,h.Y);
        double area=CaelumConnectedWaterData.PI*radius*radius,center=radius;
        // Bajo la abertura completa, usar el segmento mojado y su centroide.
        // Es una aproximación de orificio, no una simulación de fluido continuo.
        if(high<DiameterM)
        {
            double depth=Max(0.0,high),offset=radius-depth;
            double chord=Sqrt(Max(0.0,radius*radius-offset*offset));
            area=radius*radius*ACos(Clamp(offset/radius,-1.0,1.0))
                *CaelumConnectedWaterData.PI/180.0-offset*chord;
            if(area<=0)return 0;
            center=radius-2.0*chord*chord*chord/(3.0*area);
        }
        double head=Max(0.0,high-center)-Max(0.0,low-center);
        double flow=Discharge*area*Sqrt(2.0*CaelumPhysicsUnits.EARTH_GRAVITY_MPS2*head)*1000.0;
        return h.X>h.Y ? flow : -flow;
    }

    clearscope vector2 Derivative(vector2 volumes)
    {
        double flow=FlowLps(volumes);
        double fillLimit=InflowHeightM*AreaM2.X*1000;
        double drainLimit=DrainHeightM*AreaM2.Y*1000;
        // Al llegar al nivel regulado la válvula sólo compensa la salida/entrada.
        double input=volumes.X<fillLimit ? InflowLps : Min(InflowLps,Max(0.0,flow));
        double output=volumes.Y>drainLimit ? DrainLps : Min(DrainLps,Max(0.0,flow));
        if(volumes.X>fillLimit)input=0;
        if(volumes.Y<drainLimit)output=0;
        return (input-flow,flow-output);
    }
    clearscope vector2 Step(vector2 start,double seconds)
    {
        vector2 a=Derivative(start);
        vector2 b=Derivative(start+a*(seconds*0.5));
        vector2 c=Derivative(start+b*(seconds*0.5));
        vector2 d=Derivative(start+c*seconds);
        return start+(a+2*b+2*c+d)*(seconds/6.0);
    }
    static clearscope int Mixed(int a,int b)
    {return CaelumWaterQuality.Valid(a) && CaelumWaterQuality.Valid(b) ? a|b : CaelumWaterQuality.UNIDENTIFIED;}
    void MixTransferred(vector2 start,vector2 middle,vector2 finish)
    {
        double a=FlowLps(start),b=FlowLps(middle),c=FlowLps(finish);
        int originalA=QualityA,originalB=QualityB;
        if(a>0 || b>0 || c>0)QualityB=Mixed(QualityB,originalA);
        if(a<0 || b<0 || c<0)QualityA=Mixed(QualityA,originalB);
    }
    bool SettleIfClose()
    {
        double total=Liters.X+Liters.Y;
        if(InflowLps==0 && DrainLps==0)
        {
            double left=total*AreaM2.X/(AreaM2.X+AreaM2.Y);
            vector2 equal=(left,total-left);
            if(Max(Abs(equal.X-Liters.X),Abs(equal.Y-Liters.Y))>CaelumConnectedWaterData.ERROR_L*8)return false;
            MixTransferred(Liters,equal,equal);Liters=equal;PendingSeconds=0;return true;
        }
        double lo=Max(0.0,total-AreaM2.Y*DepthM.Y*1000);
        double hi=Min(total,AreaM2.X*DepthM.X*1000);
        for(int i=0;i<48;i++)
        {
            double mid=(lo+hi)*0.5;
            vector2 derivative=Derivative((mid,total-mid));
            if(derivative.X>0)lo=mid;else hi=mid;
        }
        vector2 target=((lo+hi)*0.5,total-(lo+hi)*0.5),speed=Derivative(target);
        if(Max(Abs(speed.X),Abs(speed.Y))>CaelumConnectedWaterData.STEADY_LPS
            || Max(Abs(target.X-Liters.X),Abs(target.Y-Liters.Y))>CaelumConnectedWaterData.ERROR_L*8)return false;
        MixTransferred(Liters,target,target);Liters=target;PendingSeconds=0;return true;
    }
    void Advance(double seconds)
    {
        PendingSeconds+=Max(0.0,seconds);LastSteps=0;
        if(!Open)
        {
            Liters.X=Min(InflowHeightM*AreaM2.X*1000, Liters.X+InflowLps*PendingSeconds)
                +Max(0.0,Liters.X-InflowHeightM*AreaM2.X*1000);
            Liters.Y=Max(DrainHeightM*AreaM2.Y*1000,Liters.Y-DrainLps*PendingSeconds)
                -Max(0.0,DrainHeightM*AreaM2.Y*1000-Liters.Y);
            PendingSeconds=0;NextStepSeconds=1;return;
        }
        while(PendingSeconds>0 && LastSteps<CaelumConnectedWaterData.MAX_STEPS_PER_SYNC)
        {
            LastSteps++;
            vector2 speed=Derivative(Liters);
            if(Max(Abs(speed.X),Abs(speed.Y))<CaelumConnectedWaterData.STEADY_LPS)
            {MixTransferred(Liters,Liters,Liters);PendingSeconds=0;break;}
            if(Max(Abs(speed.X),Abs(speed.Y))<CaelumConnectedWaterData.STEADY_SEARCH_LPS && SettleIfClose())break;
            double step=Min(PendingSeconds,Max(CaelumConnectedWaterData.MIN_STEP_SECONDS,NextStepSeconds));
            vector2 one=Step(Liters,step),half=Step(Liters,step*0.5),two=Step(half,step*0.5);
            double error=Max(Abs(two.X-one.X),Abs(two.Y-one.Y));
            bool bounded=two.X>=0 && two.Y>=0 && two.X<=AreaM2.X*DepthM.X*1000 && two.Y<=AreaM2.Y*DepthM.Y*1000;
            if(InflowLps==0 && DrainLps==0 && FlowLps(Liters)*FlowLps(two)<0)bounded=false;
            if((error>CaelumConnectedWaterData.ERROR_L || !bounded) && step>CaelumConnectedWaterData.MIN_STEP_SECONDS)
            {NextStepSeconds=step*0.5;continue;}
            // Un estado inválido no descarta el intervalo; queda pendiente y visible.
            if(!bounded)break;
            MixTransferred(Liters,half,two);Liters=two;
            PendingSeconds=Max(0.0,PendingSeconds-step);
            NextStepSeconds=error<CaelumConnectedWaterData.ERROR_L/32.0 ? step*2.0 : step;
        }
    }
    double Withdraw(int index,double requested)
    {
        if(PendingSeconds>0 || requested<=0 || index<0 || index>1)return 0;
        double available=index==0?Liters.X:Liters.Y;
        double taken=Min(available,requested);
        if(index==0){Liters.X-=taken;if(Liters.X==0)QualityA=CaelumWaterQuality.POTABLE;}
        else {Liters.Y-=taken;if(Liters.Y==0)QualityB=CaelumWaterQuality.POTABLE;}
        return taken;
    }
}
