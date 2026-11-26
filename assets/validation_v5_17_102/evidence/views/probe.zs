class CA847Views : EventHandler
{
    int View;
    vector3 WalkStart;
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null || level.MapName!="MAP02"){Console.Printf("CA847 FAIL map/player");return;}
        vector3 point; double angle;
        switch(index) { case 0: point=(0,-4864,0); angle=90; break;
case 1: point=(-160.0,-4256.0,0); angle=45; break;
case 2: point=(-2304.0,-4128.0,0); angle=0; break;
case 3: point=(-3936.0,-3232.0,0); angle=135; break;
case 4: point=(-2912,8160.0,0); angle=180; break; default:Console.Printf("CA847 FAIL index");return; }
        user.bInvulnerable=true;user.bNOTARGET=true;
        user.GetPersistentCharacterState(true).DemoNarrativeDelivered=2047;
        user.GetPersistentCharacterState(true).DemoNarrativePending=0;
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=0;user.Vel=(0,0,0);
        Console.Printf("CA847 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca847_next"){Place(View);View++;}
        else if(e.Name=="ca847_walk"){Place(2);WalkStart=players[0].mo.Pos;}
        else if(e.Name=="ca847_done")
        {
            let user=players[0].mo;
            double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA847 WALK distance=%.3f pos=%.3f,%.3f,%.3f",distance,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Console.Printf("CA847 %s views=%d",View==5 && distance>0?"PASS":"FAIL",View);
        }
    }
}
