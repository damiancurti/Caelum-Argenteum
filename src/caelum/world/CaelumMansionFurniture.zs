// Mobiliario de MAP01. No altera geometría, inventarios, hitos ni rutas del hub.
class CaelumMansionFurniture : Object play
{
    static bool Bed(int slot,vector3 position,double facing)
    {
        if(CaelumRestFurnitureTrial.Find(slot)!=null)return true;
        let bed=CaelumRestBed(Actor.Spawn("CaelumRestBed",position,NO_REPLACE));
        if(bed==null)return false;
        if(!bed.TestMobjLocation() || Abs(bed.FloorZ-position.Z)>1){bed.Destroy();return false;}
        bed.TrialSlot=slot;bed.Angle=facing;return true;
    }
    static bool Prepare()
    {
        if(level.MapName!="MAP01")return true;
        bool ready=true;
        // Rulo / Ronnie al norte; Caella / Argento al sur. Acceso y NPC libres.
        for(int i=0;i<4;i++)
        {
            double x=i%2==0?-384:944;
            double side=i<2?1:-1;
            if(!CaelumDiningWorld.Place(101+i,(x,side*392,136),1,90))ready=false;
            if(!Bed(101+i,(x+176,side*472,136),side>0?90:270))ready=false;
        }
        if(!CaelumDiningWorld.Place(105,(1552,0,0),2,90))ready=false;
        if(!CaelumDiningWorld.Place(106,(496,-192,264),3))ready=false;
        return ready;
    }
}
