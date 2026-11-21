// Viaje normal de puertas: Used solicita captura y el renderizador envia ACK.
// El ensayo no llama ChangeMap, CompleteTravel ni fabrica acknowledgements.
class CA454HouseUseCity : CaelumPortSiege
{
    override void Tick()
    {
        if(SetupRevision>0 || !CaelumCityWorld.Prepare())return;
        CaelumHouseResidents.Get(true).PrepareCity(self);SetupRevision=3;
    }
}
class CA454HouseUseProbe : EventHandler
{
    int House(int orientation)
    {
        for(int i=0;i<CaelumCityData.HOUSE_COUNT;i++)
            if(!CaelumPropertyData.Offered(i) && CaelumBarracasData.HouseAngle(i)==orientation*90)return i;
        return -1;
    }
    void CheckRadius(int expected)
    {
        // Consulta diagnostica acotada a las 160 fachadas al pedir cada muestra.
        let it=ThinkerIterator.Create("CA454Facade31800");Actor item;int count=0;bool ok=true;
        while((item=Actor(it.Next()))!=null)
        {
            count++;
            Console.Printf("CA879 FACADE x=%.6f y=%.6f z=%.6f angle=%.6f radius=%.6f render=%.6f height=%.6f",item.Pos.X,item.Pos.Y,item.Pos.Z,item.Angle,item.Radius,item.RenderRadius,item.Height);
            ok=ok && item.RenderRadius==expected;
        }
        Console.Printf("CA879 %s count=%d expected=%d",ok && count==CaelumCityData.HOUSE_COUNT?"PASS":"FAIL",count,expected);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca879_radius"){CheckRadius(e.Args[0]);return;}

        if(e.Name!="ca454_house_in" && e.Name!="ca454_house_inside" && e.Name!="ca454_house_back")return;
        int house=House(e.Args[0]);let user=CaelumPlayer(players[0].mo);
        bool inside=e.Name=="ca454_house_inside";
        String expected=inside?CaelumHouseHubData.MapName(house):"MAP03";
        if(house<0 || user==null || level.MapName!=expected)
        {Console.Printf("CA454 HOUSE FAIL event=%s house=%d map=%s expected=%s",e.Name,house,level.MapName,expected);return;}
        if(e.Name=="ca454_house_back")
        {
            double distance=(user.Pos-CaelumBarracasData.DoorOutside(house)).Length();
            Console.Printf("CA454 HOUSE RETURN %s house=%d distance=%.3f",distance<=1?"PASS":"FAIL",house,distance);return;
        }
        let it=ThinkerIterator.Create("CaelumHousePortal");CaelumHousePortal portal,found;
        while((portal=CaelumHousePortal(it.Next()))!=null)
            if(portal.args[0]==house && (portal.args[1]!=0)==inside){found=portal;break;}
        if(found==null){Console.Printf("CA454 HOUSE FAIL missing portal house=%d",house);return;}
        double angle=found.Angle;
        user.SetOrigin(found.Pos+(Cos(angle),Sin(angle),0)*64,false);user.FindFloorCeiling();
        user.Angle=angle+180;user.Pitch=0;user.Vel=(0,0,0);user.ClearInterpolation();
        user.bInvulnerable=true;user.FolkloreInteractionUseLatched=false;
        bool fit=user.TestMobjLocation();bool used=fit && found.Used(user);
        let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
        bool requested=used && audio!=null && audio.HousePresentationActive && !audio.HouseTravelCommitted;
        Console.Printf("CA454 HOUSE USE %s house=%d inside=%d angle=%.1f fit=%d request=%d",requested?"PASS":"FAIL",house,inside,angle,fit,audio!=null?audio.HouseRequest:-1);
    }
}
