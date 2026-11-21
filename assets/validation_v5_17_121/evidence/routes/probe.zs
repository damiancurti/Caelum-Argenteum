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
    bool Matches(Actor body)
    {Name kind=body.GetClassName();return (kind=='CA886SceneShelf' && (body.Pos-(-18304.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-18304.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-18304.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18112.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-18112.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-18112.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-17728.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-17728.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-17728.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-17536.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-17536.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-17536.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-17152.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-17152.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-17152.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-16960.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-16960.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-16960.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-16512.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-16512.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-16512.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-16320.000000000,-414.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneDesk' && (body.Pos-(-16320.000000000,-479.985036501,0.000000000)).Length()<.01 && Abs(body.Radius-31.985036501)<.01 && Abs(body.Height-24.800000000)<.01) || (kind=='CA886SceneChair' && (body.Pos-(-16320.000000000,-533.457036501,0.000000000)).Length()<.01 && Abs(body.Radius-9.843576586)<.01 && Abs(body.Height-28.160000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-2016.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1952.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1888.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1824.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1760.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1696.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1632.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1568.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1504.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1440.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1376.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1312.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1248.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1184.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1120.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-1056.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-992.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01) || (kind=='CA886SceneShelf' && (body.Pos-(-18466.000000000,-928.000000000,0.000000000)).Length()<.01 && Abs(body.Radius-30.000000000)<.01 && Abs(body.Height-72.000000000)<.01);}
    void CheckScene()
    {
        let user=players[0].mo;bool candidate=level.GetChecksum()=="b9e9c82d3ba489f368cf286c942913d4";
        bool okay=candidate || level.GetChecksum()=="7ad2fd5a73065dfdc435119c806a8a0c" || level.GetChecksum()=="f552012c9d4d7a2ba59d0809894ad272";
        int count=0,bad=0;Array<Actor> seen;
        let nearby=BlockThingsIterator.Create(user,3354);
        while(nearby.Next())
        {
            let body=nearby.thing;Name kind=body.GetClassName();
            if(kind!='CA886SceneDesk' && kind!='CA886SceneChair' && kind!='CA886SceneShelf')continue;
            bool duplicate=false;for(int i=0;i<seen.Size();i++)if(seen[i]==body)duplicate=true;
            if(duplicate)continue;seen.Push(body);count++;
            if(!Matches(body) || !body.TestMobjLocation() || !body.bSOLID || body.bUSESPECIAL
               || body is 'CaelumReadingDesk' || body is 'CaelumReadingShelf' || body is 'CaelumRestFurniture' || body is 'Inventory')bad++;
        }
        let vendor=CaelumDomesticMarket.Find(0);
        bool service=vendor!=null && vendor.ShopIdentity==0 && (vendor.Pos-(-18176,-2240,0)).Length()<.01;
        okay=okay && count==(candidate?42:0) && bad==0 && service;
        okay=okay && level.Sectors.Size()==392 && CaelumJusticeGeometry.Get()!=null;
        Console.Printf("CA886 SCENE %s candidate=%d props=%d invalid=%d vendor=%d",okay?"PASS":"FAIL",candidate,count,bad,service);
    }
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null){Console.Printf("CA866 FAIL player");return;}
        vector3 point;double angle,pitch;
        switch(index) { case 0: point=(-16000,-1472,0); angle=180.0; pitch=0; break;
case 1: point=(-16192,-1472,0); angle=180.0; pitch=0; break;
case 2: point=(-18304,-661.4570365014642,0); angle=90; pitch=0; break;
case 3: point=(-17728,-661.4570365014642,0); angle=90; pitch=0; break;
case 4: point=(-17152,-661.4570365014642,0); angle=90; pitch=0; break;
case 5: point=(-16512,-661.4570365014642,0); angle=90; pitch=0; break;
case 6: point=(-18210,-1440,0); angle=180; pitch=0; break;
case 7: point=(-18338.0,-1440,0); angle=180; pitch=0; break; default:Console.Printf("CA866 FAIL index");return; }
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);
        Console.Printf("CA866 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f height=%.3f floor=%s ceiling=%s",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ,user.Height,TexMan.GetName(user.CurSector.GetTexture(Sector.floor)),TexMan.GetName(user.CurSector.GetTexture(Sector.ceiling)));
        if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");
        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera");
        CheckScene();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca866_next"){if(View==0)Sizes();Place(View);View++;}
        else if(e.Name=="ca866_walk"){Place(0);WalkStart=players[0].mo.Pos;}
        else if(e.Name=="ca866_done")
        {
            let user=players[0].mo;double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA866 WALK distance=%.3f pos=%.3f,%.3f,%.3f",distance,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Console.Printf("CA866 %s views=%d",View==8 && distance>0?"PASS":"FAIL",View);
        }
    }
}

class CA886CollisionProbe : Actor
{ Default {Radius 1;Height 1;+SOLID +CANPASS +NOGRAVITY RenderStyle "None";} States {Spawn:TNT1 A -1;Stop;} }
class CA886Routes : CA866Views
{
    int Moves;
    bool WalkTo(vector2 target)
    {
        let user=players[0].mo;
        int steps=int(Ceil((target-user.Pos.XY).Length()/16.0));
        for(int i=steps;i>0;i--)
        {
            vector2 step=(target-user.Pos.XY)/i;
            if(!user.TryMove(user.Pos.XY+step,0))return false;
            Moves++;
        }
        return (target-user.Pos.XY).Length()<.01;
    }
    void Routes()
    {
        let user=CaelumPlayer(players[0].mo);user.ClosePalomoMerchant();user.Vel=(0,0,0);
        Console.Printf("CA886 SERVICE PREP previous_box=%d wizard=%d",user.MagicBoxOwned,user.CreationWizardOpen);
        user.MagicBoxOwned=true;let record=user.GetPersistentCharacterState(true);record.MagicBoxOwned=true;user.PersistCharacterState();
        user.SetOrigin((-16000,-1472,0),false);user.FindFloorCeiling();
        user.SetOrigin((user.Pos.X,user.Pos.Y,user.FloorZ),false);
        bool okay=user.TestMobjLocation();Moves=0;
        okay=WalkTo((-16192.000000000,-1472.000000000)) && okay;
        okay=WalkTo((-17344.000000000,-1472.000000000)) && okay;
        okay=WalkTo((-16192.000000000,-1472.000000000)) && okay;
        okay=WalkTo((-16192.000000000,-661.457036501)) && okay;
        okay=WalkTo((-16512.000000000,-661.457036501)) && okay;
        okay=WalkTo((-17152.000000000,-661.457036501)) && okay;
        okay=WalkTo((-17728.000000000,-661.457036501)) && okay;
        okay=WalkTo((-18304.000000000,-661.457036501)) && okay;
        okay=WalkTo((-18210.000000000,-661.457036501)) && okay;
        okay=WalkTo((-18210.000000000,-1440.000000000)) && okay;
        okay=WalkTo((-18210.000000000,-2176.000000000)) && okay;
        okay=WalkTo((-18112.000000000,-2176.000000000)) && okay;
        okay=WalkTo((-18112.000000000,-2240.000000000)) && okay;
        user.Angle=180;user.Pitch=0;user.Vel=(0,0,0);user.FolkloreInteractionUseLatched=false;
        Console.Printf("CA886 ROUTE %s moves=%d pos=%.3f,%.3f,%.3f",okay?"PASS":"FAIL",Moves,user.Pos.X,user.Pos.Y,user.Pos.Z);
        CheckScene();
        let probe=Actor.Spawn('CA886CollisionProbe',user.Pos,NO_REPLACE);
        if(probe==null){Console.Printf("CA886 COLLISION FAIL missing probe");return;}
        probe.A_SetSize(user.Radius,user.Height,false);int blocked=0;
        probe.SetOrigin((-18304.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18304.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18304.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18112.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18112.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18112.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17728.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17728.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17728.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17536.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17536.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17536.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17152.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17152.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-17152.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16960.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16960.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16960.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16512.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16512.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16512.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16320.000000000,-414.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16320.000000000,-479.985036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-16320.000000000,-533.457036501,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-2016.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1952.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1888.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1824.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1760.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1696.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1632.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1568.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1504.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1440.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1376.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1312.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1248.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1184.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1120.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-1056.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-992.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        probe.SetOrigin((-18466.000000000,-928.000000000,0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;
        bool candidate=level.GetChecksum()=="b9e9c82d3ba489f368cf286c942913d4";
        Console.Printf("CA886 COLLISION %s blocked=%d samples=42 radius=%.3f height=%.3f",blocked==(candidate?42:0)?"PASS":"FAIL",blocked,probe.Radius,probe.Height);
        probe.Destroy();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca886_routes")Routes();
        else if(e.Name=="ca886_service")
        {
            let user=CaelumPlayer(players[0].mo);let vendor=CaelumDomesticMarket.Find(0);
            Console.Printf("CA886 SERVICE STATE box=%d wizard=%d aim=%d range=%.3f distance=%.3f angle=%.3f pitch=%.3f latched=%d menu=%d trade=%d available=%d",user.MagicBoxOwned,user.CreationWizardOpen,CaelumUseGeometry.AimedAt(user,vendor),user.UseRange,user.Distance3D(vendor),user.Angle,user.Pitch,user.FolkloreInteractionUseLatched,user.PalomoMerchantMenuOpen,user.CityTrade!=null,CaelumBattleConsequences.MerchantAvailable(user,vendor));
            bool okay=user.PalomoMerchantMenuOpen && user.CityTrade!=null && user.CityTrade.Vendor==vendor;
            Console.Printf("CA886 SERVICE %s identity=%d",okay?"PASS":"FAIL",vendor==null?-1:vendor.ShopIdentity);
            user.ClosePalomoMerchant();
        }
        else if(e.Name=="ca886_spanish"){Place(7);Console.Printf("CA886 LABEL %s",StringTable.Localize("CA886_SCENE_SHELF",false));}
        else Super.NetworkProcess(e);
    }
}
