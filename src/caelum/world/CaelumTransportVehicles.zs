// El caballo utiliza ocho sprites pintados; las partes solo aportan colision.
class CaelumRidingHorse : CaelumTravelVehicle
{
    override int TravelMode(){return CaelumTransportData.MODE_HORSE;}
    override bool Prepare()
    {
        bool ok=Part(0,-18,0,0,16,58) && Part(1,18,0,0,16,64);
        BoardingPoint=LocalPoint(0,-40,0);Ready=ok;return ok;
    }
    Default {Scale 0.4;Height 64;Tag "$CA_TRANSPORT_HORSE";}
    States {Spawn:CHRS A -1;Stop;}
}

class CaelumSteamTrain : CaelumTravelVehicle
{
    override int TravelMode(){return CaelumTransportData.MODE_TRAIN;}
    override bool Prepare()
    {
        bool ok=true;int slot=0;
        for(int along=-CaelumTransportVehicleData.TRAIN_HALF_LENGTH+32;along<=CaelumTransportVehicleData.TRAIN_HALF_LENGTH-32;along+=64)
            for(int side=-1;side<=1;side+=2)
                if(!Part(slot++,along,side*(CaelumTransportVehicleData.TRAIN_HALF_WIDTH-32),0,32,CaelumTransportVehicleData.TRAIN_HEIGHT))ok=false;
        vector3 boarding=CaelumTransportVehicleData.TrainBoarding();
        BoardingPoint=LocalPoint(boarding.X,boarding.Y,boarding.Z);Ready=ok;return ok;
    }
    Default {Height 148;Tag "$CA_TRANSPORT_TRAIN";}
}

class CaelumTransportSignVisual : Actor
{
    Default {Radius 12;Height 72;+SOLID +NOGRAVITY +CANNOTPUSH +DONTTHRUST +INVULNERABLE Tag "$CA_TRANSPORT_TITLE";}
    States {Spawn:CSSG A -1;Stop;}
}
