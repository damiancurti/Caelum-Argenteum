// Uso fisico de caballo, tren, carro y barco, sin comprar ni consumir un viaje.
class CA454VehicleUseCity : CaelumPortSiege
{
    override void Tick()
    {
        if(SetupRevision>0 || !CaelumCityWorld.Prepare())return;
        CaelumHouseResidents.Get(true).PrepareCity(self);SetupRevision=3;
    }
}
class CA454VehicleUseProbe : EventHandler
{
    CaelumTravelVehicle Current;
    Actor Contact;
    int Opened,Failures;
    Name Kind(int index)
    {return index==0?'CaelumCoveredCart':index==1?'CaelumMerchantShip':index==2?'CaelumRidingHorse':'CaelumSteamTrain';}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_vehicle_aim" && e.Name!="ca454_vehicle_check" && e.Name!="ca454_vehicle_report")return;
        let user=CaelumPlayer(players[0].mo);let session=CaelumTransportSession.Find(user);
        if(e.Name=="ca454_vehicle_report")
        {
            if(session!=null)session.Act(user,0);
            Console.Printf("CA454 VEHICLE COMPLETE %s opened=%d failures=%d",Opened==4 && Failures==0?"PASS":"FAIL",Opened,Failures);return;
        }
        int index=e.Args[0];
        if(e.Name=="ca454_vehicle_check")
        {
            bool okay=Current!=null && session!=null && session.Open && session.Source==Current && session.Valid(user);
            if(okay)Opened++;else Failures++;
            Console.Printf("CA454 VEHICLE USE %s id=%d kind=%s distance=%.3f route=%d",okay?"PASS":"FAIL",index,Kind(index),Current!=null?(user.Pos-Current.BoardingPoint).Length():-1,session!=null?session.SelectedRoute:-1);return;
        }
        if(session!=null)session.Act(user,0);
        user.bInvulnerable=true;user.FolkloreInteractionUseLatched=false;
        Current=CaelumTravelVehicle(ThinkerIterator.Create(Kind(index)).Next());Contact=null;
        if(Current==null || !Current.Ready){Failures++;Console.Printf("CA454 VEHICLE FAIL missing id=%d",index);return;}
        for(int side=0;side<9 && Contact==null;side++)
        {
            double angle=Current.Angle+side*45;
            vector3 point=Current.BoardingPoint+(Cos(angle),Sin(angle),0)*(side==8?0:48);
            user.SetOrigin(point,false);user.FindFloorCeiling();
            user.SetOrigin((point.X,point.Y,user.FloorZ),false);user.Vel=(0,0,0);
            if(!user.TestMobjLocation() || !Current.CanBoard(user))continue;
            for(int part=0;part<33;part++)
            {
                Actor target;if(part==32)target=Current;else target=Current.Parts[part];if(target==null)continue;
                vector3 delta=target.Pos+(0,0,target.Height/2)-user.Pos-(0,0,user.ViewHeight);
                user.Angle=VectorAngle(delta.X,delta.Y);user.Pitch=VectorAngle(delta.XY.Length(),-delta.Z);user.ClearInterpolation();
                if(CaelumUseGeometry.AimedAt(user,target) && user.CheckSight(target,SF_IGNOREVISIBILITY)){Contact=target;break;}
            }
        }
        if(Contact==null){Failures++;Console.Printf("CA454 VEHICLE FAIL reachable contact id=%d boarding=(%.1f,%.1f,%.1f)",index,Current.BoardingPoint.X,Current.BoardingPoint.Y,Current.BoardingPoint.Z);}
    }
}
