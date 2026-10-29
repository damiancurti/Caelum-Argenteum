class CA410DecorProof : Inventory
{
    CaelumDecorItem Items[2];CaelumDecorBody Bodies[2];
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA410DecorChecks : CA410RestChecks
{
    override void UiTick()
    {
        let current=Menu.GetCurrentMenu();
        if(level.maptime>210 && ConversationMenu(current)!=null)current.MenuEvent(Menu.MKEY_Back,false);
    }
    CA410DecorProof Proof(CaelumPlayer u,bool create=false)
    {let p=CA410DecorProof(u.FindInventory('CA410DecorProof'));if(p==null && create){p=CA410DecorProof(Actor.Spawn('CA410DecorProof'));p.AttachToOwner(u);}return p;}
    void Face(CaelumPlayer u,Actor body)
    {
        vector3 target=body.Pos+(0,0,body.Height/2);
        vector3 d=target-(u.Pos+(0,0,u.ViewHeight));u.Angle=VectorAngle(d.X,d.Y);u.Pitch=-Atan2(d.Z,d.XY.Length());u.Vel=(0,0,0);
    }
    bool PicturePoint(CaelumPlayer u,CaelumDecorItem item)
    {
        for(int i=0;i<level.Lines.Size();i++)
        {
            let line=level.Lines[i];if(line.backsector!=null || line.special!=0 || line.frontsector==null)continue;
            vector2 edge=line.v2.p-line.v1.p;double length=edge.Length();if(length<CaelumDecorData.Width(0)+2)continue;
            edge/=length;vector2 center=(line.v1.p+line.v2.p)/2;
            for(int sign=-1;sign<=1;sign+=2)
            {
                vector2 normal=(-edge.Y,edge.X)*sign;
                vector3 point=(center.X+normal.X*48,center.Y+normal.Y*48,0);
                u.SetOrigin(point,false);u.FindFloorCeiling();u.SetOrigin((point.X,point.Y,u.FloorZ),false);u.FindFloorCeiling();
                u.Angle=VectorAngle(-normal.X,-normal.Y);u.Pitch=0;u.Vel=(0,0,0);
                if(!u.TestMobjLocation())continue;
                if(item.Place(u))return true;
            }
        }
        return false;
    }
    bool StatuePoint(CaelumPlayer u,CaelumDecorItem item)
    {
        for(int x=-400;x<=400;x+=64)for(int y=160;y<=640;y+=64)
        {
            u.SetOrigin((x,y,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
            if(Abs(u.FloorZ)<1 && u.TestMobjLocation() && item.Place(u))return true;
        }
        return false;
    }
    void NewSeed(CaelumPlayer u)
    {
        Profile(u);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);let p=Proof(u,true);
        for(int k=0;k<2;k++)
        {
            let item=CaelumDecorItem(Actor.Spawn(CaelumDecorData.ItemClass(k)));item.AttachToOwner(u);p.Items[k]=item;
            Check(k==0?PicturePoint(u,item):StatuePoint(u,item),"decoration places on actual permitted mansion geometry");
            let body=item.Decoration;if(body==null)continue;p.Bodies[k]=body;body.ChangeTid(7044+k);
            Check(item.Owner==body && body.PackedItem==item,"deployed piece retains one native inventory owner");
            Check(body.bSolid==(k==1) && Near(body.Height,CaelumDecorData.Height(k)),"wall picture is thin/nonblocking; statue has physical collision");
            Check(!(body is 'CaelumRestFurniture') && CaelumContaminationObject.Eligible(body),"decoration has exposure but no rest benefits");
            CaelumContaminationObject.LeavingWorld(body);CaelumContaminationStorage.Set(body,42);
            Face(u,body);let owner=item.LawfulOwner;item.LawfulOwner=null;
            Check(!item.Carry(u) && item.Owner==body,"another title cannot remove decoration");item.LawfulOwner=owner;
            u.DerivedStats.CarryCapacity=0;Check(!item.Carry(u),"insufficient capacity leaves physical decoration");
            u.DerivedStats.CarryCapacity=2000;Check(item.Carry(u),"owner carries through actual reach and sight");
            Check(item.Owner==u && item.Decoration==body && body.bInvisible && !body.bSolid,"transport preserves same hidden body");
            Check(!CaelumContaminationObject.Eligible(body) && Near(CaelumContaminationStorage.Value(item),42),"packed body has no duplicate exposure and retains dirt");
            Select(u,item);u.ToggleFormalInventoryStorage();Check(item.InMagicBox,"native Box stores decoration");
            Check(!item.Place(u),"Box item cannot deploy without retrieval");u.ToggleFormalInventoryStorage();
            Check(!item.InMagicBox && item.CreateTossable(1)==null,"packed native body cannot be copied by dropping");
        }
    }
    void NewResume(CaelumPlayer u)
    {
        Profile(u);let p=Proof(u);Check(p!=null,"saved decoration proof exists");if(p==null)return;
        for(int k=0;k<2;k++)
        {
            let item=p.Items[k];let body=p.Bodies[k];
            Check(item!=null && body!=null && item.Decoration==body && body.PackedItem==item && item.Owner==u,"save/hub retains real decoration and owner");
            if(item==null || body==null)continue;
            Check(body.TID==7044+k && Near(CaelumContaminationStorage.Value(item),42),"native identity and contamination survive travel");
            Check(k==0?PicturePoint(u,item):StatuePoint(u,item),"transported piece redeploys through geometry checks");
            Check(item.Decoration==body,"redeployment never duplicates decoration");
            Face(u,body);u.DerivedStats.CarryCapacity=2000;Check(item.Carry(u),"redeployed decoration can be carried again");
        }
    }
    void Reject(CaelumPlayer u)
    {
        Profile(u);let item=CaelumDecorItem(Actor.Spawn('CaelumPaintingItem'));item.AttachToOwner(u);
        u.Pitch=90;Check(!item.Place(u) && item.Owner==u && item.Decoration==null,"floor is not accepted as painting wall");
        Check(PicturePoint(u,item),"find real wall for obstruction checks");if(item.Decoration==null)return;
        let body=item.Decoration;vector3 origin=u.Pos;double yaw=u.Angle;
        let second=CaelumDecorItem(Actor.Spawn('CaelumPaintingItem'));second.AttachToOwner(u);
        Check(!second.Place(u) && second.Decoration==null,"overlapping decoration placement rejected without consuming item");
        Face(u,body);u.DerivedStats.CarryCapacity=2000;item.Carry(u);
        let blocker=Actor.Spawn('CA410RestObstacle',body.Pos-(Cos(body.Angle),Sin(body.Angle),0)*-2);
        u.SetOrigin(origin,false);u.Angle=yaw;u.Pitch=0;
        Check(!item.Place(u) && item.Owner==u && body.bInvisible,"obstructed wall preserves packed item");blocker.Destroy();
        u.Pitch=0;Check(item.Place(u),"cleared wall permits same body again");
    }
    void Gallery(CaelumPlayer u,int kind,bool icon)
    {
        Profile(u);u.DerivedStats.CarryCapacity=2000;
        let item=CaelumDecorItem(Actor.Spawn(CaelumDecorData.ItemClass(kind)));item.AttachToOwner(u);
        if(icon){u.EquipmentMenuOpen=true;Select(u,item);Check(true,"painted inventory sprite selected");return;}
        Check(kind==0?PicturePoint(u,item):StatuePoint(u,item),"world gallery uses real production placement");
        if(item.Decoration==null)return;
        let b=item.Decoration;
        u.SetOrigin(b.Pos+(Cos(b.Angle),Sin(b.Angle),0)*(kind==0?42:32),false);u.FindFloorCeiling();u.SetOrigin((u.Pos.X,u.Pos.Y,u.FloorZ),false);Face(u,b);
        Check(CaelumUseGeometry.AimedAt(u,b),"gallery aims at whole decorated object");
    }
    void Input(CaelumPlayer u,int stage)
    {
        Profile(u);let p=Proof(u,stage==0);
        if(stage==0)
        {
            let item=CaelumDecorItem(Actor.Spawn('CaelumPaintingItem'));item.AttachToOwner(u);p.Items[0]=item;
            Check(PicturePoint(u,item),"native-input painting placed");p.Bodies[0]=item.Decoration;
            if(item.Decoration!=null)Face(u,item.Decoration);
        }
        else Check(p!=null && p.Items[0]!=null && p.Items[0].Owner==u && p.Bodies[0].bInvisible,"native crouch/use carries aimed wall painting");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410o_away'){Level.ChangeLevel("CBTH410",0,CHANGELEVEL_NOINTERMISSION);return;}
        if(e.Name=='ca410o_home'){Level.ChangeLevel("MAP01",0,CHANGELEVEL_NOINTERMISSION);return;}
        if(e.Name=='ca410o_catalogue')Catalogue(u);
        else if(e.Name=='ca410o_craft')Craft(u);
        else if(e.Name=='ca410o_trade')Trade(u);
        else if(e.Name=='ca410o_items')Items(u);
        else if(e.Name=='ca410o_seed')NewSeed(u);
        else if(e.Name=='ca410o_resume')NewResume(u);
        else if(e.Name=='ca410o_reject')Reject(u);
        else if(e.Name=='ca410o_view')Gallery(u,e.Args[0],false);
        else if(e.Name=='ca410o_icon')Gallery(u,e.Args[0],true);
        else if(e.Name=='ca410o_input')Input(u,e.Args[0]);
        else return;
        Result();
        Console.Printf("CA410O COMPLETE %s map=%s",e.Name,level.MapName);
    }
}
