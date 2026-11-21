class CA866Views : EventHandler
{
    int View;
    vector3 WalkStart;
    override void UiTick()
    { if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close(); }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null)return;
        let record=user.GetPersistentCharacterState(true);
        CaelumDemoNarrative.EnsureRevision(record);
        record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
        user.bInvulnerable=true;user.bNOTARGET=true;
    }
    void Sizes()
    {
        static const String names[]={"CMEX01","CMEX04","CMGR01","CMGR01A","CMGR01B","CMGR02","CMRF01","CMST01","CMST02","CMTB04","CMWD01","CMWV01"};
        for(int i=0;i<names.Size();i++)for(int kind=TexMan.Type_Wall;kind<=TexMan.Type_Flat;kind++)
        {
            let texture=TexMan.CheckForTexture(names[i],kind);
            let size=TexMan.GetScaledSize(texture);
            int width,height;[width,height]=TexMan.GetSize(texture);
            Console.Printf("CA866 SIZE %s kind=%d display_int=%dx%d scaled=%.3fx%.3f",names[i],kind,width,height,size.X,size.Y);
            if(size.X!=128 || size.Y!=128)Console.Printf("CA866 FAIL texture scale %s",names[i]);
        }
    }
    void CheckSurfaces() {
        String checksum=level.GetChecksum();bool candidate=checksum=="aff465778ccf8f593e33033a54b0a378";
        bool okay=candidate || checksum=="cdf94d679086e2d56821d23de343f095";
        {let s=level.Sectors[0];
        okay=okay && TexMan.GetName(s.GetTexture(Sector.floor))=="CMTB04";
        okay=okay && s.floorplane.ZatPoint((0,0))==160;
        okay=okay && TexMan.GetName(s.GetTexture(Sector.ceiling))=="CMTB04";
        okay=okay && s.ceilingplane.ZatPoint((0,0))==160;
        }
        {let s=level.Sectors[1];
        okay=okay && TexMan.GetName(s.GetTexture(Sector.floor))=="CVCI03";
        okay=okay && s.floorplane.ZatPoint((0,0))==0;
        okay=okay && TexMan.GetName(s.GetTexture(Sector.ceiling))==(candidate?"CMWD01":"CMTB04");
        okay=okay && s.ceilingplane.ZatPoint((0,0))==160;
        }
        {let s=level.Sectors[2];
        okay=okay && TexMan.GetName(s.GetTexture(Sector.floor))=="CMST03";
        okay=okay && s.floorplane.ZatPoint((0,0))==64;
        okay=okay && TexMan.GetName(s.GetTexture(Sector.ceiling))==(candidate?"CMWD01":"CMTB04");
        okay=okay && s.ceilingplane.ZatPoint((0,0))==128;
        }
        {let s=level.Sectors[3];
        okay=okay && TexMan.GetName(s.GetTexture(Sector.floor))=="CMST02";
        okay=okay && s.floorplane.ZatPoint((0,0))==0;
        okay=okay && TexMan.GetName(s.GetTexture(Sector.ceiling))=="F_SKY1";
        okay=okay && s.ceilingplane.ZatPoint((0,0))==1024;
        }
        {let s=level.Sectors[4];
        okay=okay && TexMan.GetName(s.GetTexture(Sector.floor))=="CMST02";
        okay=okay && s.floorplane.ZatPoint((0,0))==0;
        okay=okay && TexMan.GetName(s.GetTexture(Sector.ceiling))=="F_SKY1";
        okay=okay && s.ceilingplane.ZatPoint((0,0))==1024;
        }
        {let s=level.Sectors[5];
        okay=okay && TexMan.GetName(s.GetTexture(Sector.floor))=="CMST02";
        okay=okay && s.floorplane.ZatPoint((0,0))==0;
        okay=okay && TexMan.GetName(s.GetTexture(Sector.ceiling))=="CMST01";
        okay=okay && s.ceilingplane.ZatPoint((0,0))==160;
        }
        okay=okay && CaelumJusticeGeometry.Get()!=null;
        Console.Printf("CA883 SURFACE %s candidate=%d sectors=%d checksum=%s",okay?"PASS":"FAIL",candidate,6,checksum);
    }
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null || level.MapName!="CAH000"){Console.Printf("CA866 FAIL map/player");return;}
        vector3 point;double angle,pitch;
        switch(index) { case 0: point=(-21088,-12416,0); angle=105.945396; pitch=0; break;
case 1: point=(-21216.0,-12192.0,0); angle=90.0; pitch=0; break;
case 2: point=(-21536,-12416.0,0); angle=110.556045; pitch=0; break;
case 3: point=(-21696.0,-11872,0); angle=71.565051; pitch=0; break; default:Console.Printf("CA866 FAIL index");return; }
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);
        Console.Printf("CA866 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f height=%.3f floor=%s ceiling=%s",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ,user.Height,TexMan.GetName(user.CurSector.GetTexture(Sector.floor)),TexMan.GetName(user.CurSector.GetTexture(Sector.ceiling)));
        if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");
        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera %d",index);
        CheckSurfaces();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca866_next"){if(View==0)Sizes();Place(View);View++;}
        else if(e.Name=="ca866_walk"){Place(0);WalkStart=players[0].mo.Pos;}
        else if(e.Name=="ca866_done")
        {
            let user=players[0].mo;double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA866 WALK distance=%.3f pos=%.3f,%.3f,%.3f",distance,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Console.Printf("CA866 %s views=%d",View==4 && distance>0?"PASS":"FAIL",View);
        }
    }
}

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
    override void NetworkProcess(ConsoleEvent e)
    {
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
