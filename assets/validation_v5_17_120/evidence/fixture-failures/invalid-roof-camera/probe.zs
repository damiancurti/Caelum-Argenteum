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
        String checksum=level.GetChecksum();bool candidate=checksum=="7ad2fd5a73065dfdc435119c806a8a0c";
        bool okay=candidate || checksum=="f552012c9d4d7a2ba59d0809894ad272";
        {let s=level.Sectors[307];
        okay=okay && TexMan.GetName(s.GetTexture(Sector.floor))==(candidate?"CMWD01":"CMTB04");
        okay=okay && s.floorplane.ZatPoint((0,0))==160;
        okay=okay && TexMan.GetName(s.GetTexture(Sector.ceiling))=="CMTB04";
        okay=okay && s.ceilingplane.ZatPoint((0,0))==184;
        }
        okay=okay && CaelumJusticeGeometry.Get()!=null;
        okay=okay && CaelumJusticeGeometry.SectorIndex(level.MapName)==391 && (CaelumJusticeGeometry.Center(level.MapName)-(2560.0,20672.0,0.0)).Length()==0;
        Console.Printf("CA883 SURFACE %s candidate=%d sectors=%d checksum=%s",okay?"PASS":"FAIL",candidate,1,checksum);
    }
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null || level.MapName!="MAP03"){Console.Printf("CA866 FAIL map/player");return;}
        vector3 point;double angle,pitch;
        switch(index) { case 0: point=(-16000,-1472,0); angle=180.0; pitch=0; break;
case 1: point=(-16192,-1472,0); angle=180.0; pitch=0; break;
case 2: point=(-16192,-1472,184); angle=180.0; pitch=75; break; default:Console.Printf("CA866 FAIL index");return; }
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
            Console.Printf("CA866 %s views=%d",View==3 && distance>0?"PASS":"FAIL",View);
        }
    }
}
