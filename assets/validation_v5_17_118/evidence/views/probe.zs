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
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null){Console.Printf("CA866 FAIL player");return;}
        vector3 point;double angle,pitch;
        switch(index) { case 0: point=(-1568,-4352,0); angle=90; pitch=0; break;
case 1: point=(-1568,-4352,0); angle=180; pitch=0; break;
case 2: point=(-1572.0,-4544.0,0); angle=180; pitch=0; break;
case 3: point=(-12416,-8352,0); angle=270; pitch=0; break;
case 4: point=(-12224.0,-8356.0,0); angle=270; pitch=0; break;
case 5: point=(-23136,-2752,0); angle=0; pitch=0; break;
case 6: point=(-23132.0,-2560.0,0); angle=0; pitch=0; break;
case 7: point=(-27072,3808,0); angle=90; pitch=0; break;
case 8: point=(-27264.0,3812.0,0); angle=90; pitch=0; break; default:Console.Printf("CA866 FAIL index");return; }
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);
        vector3 target;bool aim=false;
        switch(index){case 1: target=(-1660,-4352.0,80.0);aim=true;break;
case 2: target=(-1664.0,-4544.0,96.0);aim=true;break;
case 3: target=(-12416.0,-8444,80.0);aim=true;break;
case 4: target=(-12224.0,-8448.0,96.0);aim=true;break;
case 5: target=(-23044,-2752.0,80.0);aim=true;break;
case 6: target=(-23040.0,-2560.0,96.0);aim=true;break;
case 7: target=(-27072.0,3900,80.0);aim=true;break;
case 8: target=(-27264.0,3904.0,96.0);aim=true;break; default:break;}
        if(aim)user.Pitch=-atan2(target.Z-(user.Pos.Z+user.ViewHeight),(target.XY-user.Pos.XY).Length());
        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera %d",index);
        // Diagnostico acotado: una consulta de las 160 fachadas por camara.
        let it=ThinkerIterator.Create("CA454Facade31800");Actor item,nearest;double best=1e30;int count=0;
        while((item=Actor(it.Next()))!=null)
        {
            count++;double distance=(item.Pos.XY-user.Pos.XY).Length();
            if(distance<best){best=distance;nearest=item;}
        }
        if(nearest!=null)Console.Printf("CA866 FACADE index=%d count=%d pos=%.3f,%.3f,%.3f floor=%.3f angle=%.3f distance=%.3f render=%.3f",index,count,nearest.Pos.X,nearest.Pos.Y,nearest.Pos.Z,nearest.FloorZ,nearest.Angle,best,nearest.RenderRadius);


        Console.Printf("CA866 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f height=%.3f floor=%s ceiling=%s",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ,user.Height,TexMan.GetName(user.CurSector.GetTexture(Sector.floor)),TexMan.GetName(user.CurSector.GetTexture(Sector.ceiling)));
        if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca866_next"){Place(View);View++;}
        else if(e.Name=="ca866_walk"){Place(0);WalkStart=players[0].mo.Pos;}
        else if(e.Name=="ca866_done")
        {
            let user=players[0].mo;double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA866 WALK distance=%.3f pos=%.3f,%.3f,%.3f",distance,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Console.Printf("CA866 %s views=%d",View==9 && distance>0?"PASS":"FAIL",View);
        }
    }
}
