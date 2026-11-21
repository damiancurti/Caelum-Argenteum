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
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null || level.MapName!="MAP01"){Console.Printf("CA866 FAIL map/player");return;}
        vector3 point;double angle,pitch;
        switch(index) { case 0: point=(-1600,0,0); angle=0; pitch=15; break;
case 1: point=(-1200,-900,0); angle=25; pitch=0; break;
case 2: point=(-400,0,0); angle=0; pitch=15; break; default:Console.Printf("CA866 FAIL index");return; }
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);
        Console.Printf("CA866 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f height=%.3f floor=%s ceiling=%s",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ,user.Height,TexMan.GetName(user.CurSector.GetTexture(Sector.floor)),TexMan.GetName(user.CurSector.GetTexture(Sector.ceiling)));
        if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");
        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera %d",index);
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

