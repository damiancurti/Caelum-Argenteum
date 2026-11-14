// #686: inspeccion inicial de arte; las pruebas de inventario se agregan aparte.
class CA686HeadwearCamera : Actor
{
    Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA686HeadwearEvents : EventHandler
{
    Array<CaelumEquipmentItem> Drops;
    CA686HeadwearCamera Camera;
    int Failures,DetailIndex,DetailAngle;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA686 %s %s",okay?"PASS":"FAIL",label);}
    void Restore()
    {
        for(int i=0;i<Drops.Size();i++)
        {Drops[i].SetOrigin(((i-2)*45,0,0),false);Drops[i].bNOGRAVITY=false;Drops[i].Vel=(0,0,0);}
    }
    void Detail(int index,int angle)
    {
        if(index<0 || index>=Drops.Size())return;
        Restore();DetailIndex=index;DetailAngle=angle;
        static const double extents[]={110.0,100.71857116918693,113.0,96.99999999999999,103.8017927355906};static const double heights[]={42.05882352941176,23.303837511027346,28.25,43.30357142857142,24.01722029197716};
        let item=Drops[index];double distance=max(9.,extents[index]*item.Scale.X*1.4);
        if(angle==0){item.SetOrigin(item.Pos+(0,0,64),false);item.bNOGRAVITY=true;}
        vector3 center=item.Pos+(0,0,heights[index]*item.Scale.Y);
        if(angle==0){Camera.SetOrigin(center+(0,-distance,-distance*.65),false);Camera.Angle=90;Camera.Pitch=-33.023868;}
        else {Camera.SetOrigin(center+(-cos(angle)*distance,-sin(angle)*distance,distance*.5),false);Camera.Angle=angle;Camera.Pitch=26.565051;}
        players[0].camera=Camera;Camera.ClearInterpolation();
    }
    void Verify()
    {
        Check(Drops.Size()==5,"five isolated headwear previews");
        for(int i=0;i<Drops.Size();i++)
        {
            let item=Drops[i];String label=String.Format("headwear %d",i);
            Check(item!=null && item.GetClass()=='CaelumClothingPickup',label.." native class");
            if(item==null)continue;
            Check(item.ItemType==11+i && item.EquipmentSize==CaelumConstants.EQUIPMENT_SIZE_M && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING,label.." original type and medium size");
            Check(abs(item.Pos.Z-item.floorz)<.01 && item.sprite==Actor.GetSpriteIndex(CaelumClothingData.SpriteName(11+i)),label.." native floor and original sprite state");
        }
        Console.Printf("CA686 COMPLETE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca686_prepare")
        {
            if(Drops.Size()!=0)return;
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;
            for(int i=0;i<5;i++){let item=CaelumClothing.Create(user,11+i,CaelumConstants.EQUIPMENT_SIZE_M);item.UpdateWorldSprite();Drops.Push(item);}
            Restore();Camera=CA686HeadwearCamera(Actor.Spawn('CA686HeadwearCamera',(0,-150,130),NO_REPLACE));Camera.Angle=90;Camera.Pitch=38;
            players[0].camera=Camera;user.bInvisible=true;let hud=CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));if(hud!=null)hud.HUDFont=null;
        }
        if(e.Name=="ca686_verify")Verify();
        if(e.Name=="ca686_view")
        {
            Restore();if(e.Args[0]==4)players[0].camera=players[0].mo;else players[0].camera=Camera;
            if(e.Args[0]==2){Camera.SetOrigin((160,0,70),false);Camera.Angle=180;Camera.Pitch=23;}
            else if(e.Args[0]==7){Camera.SetOrigin((0,150,70),false);Camera.Angle=270;Camera.Pitch=23;}
            else {Camera.SetOrigin((0,-150,100),false);Camera.Angle=90;Camera.Pitch=30;}
            Camera.ClearInterpolation();
        }
        if(e.Name=="ca686_detail")Detail(e.Args[0],e.Args[1]);
        if(e.Name=="ca686_next")Detail((DetailIndex+1)%5,90);
        if(e.Name=="ca686_rotate")Detail(DetailIndex,DetailAngle==90?160:DetailAngle==160?270:DetailAngle==270?0:90);
    }
}
