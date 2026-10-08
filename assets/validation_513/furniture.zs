// Native interaction admission and collision checks, separate from author UI acceptance.
class CA133Furniture : EventHandler
{
    int Checks,Failures,House,Step,Started;
    void Check(bool result,String label)
    {Checks++;if(!result)Failures++;Console.Printf("CA133 %s %s",result ? "PASS" : "FAIL",label);}
    vector3 Waypoint(int step)
    {
        switch(step)
        {
        case 0:return (800,384,0);case 1:return (192,384,0);
        case 2:return (128,768,0);case 3:return (192,864,0);
        case 4:return (192,1024,0);case 5:return (192,864,0);
        case 6:return (128,768,0);case 7:return (192,384,0);
        case 8:return (800,384,0);default:return (1056,384,0);
        }
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);if(user==null || level.time<75)return;
        user.CreationWizardOpen=false;
        if(level.time<235)
        {
            int house=level.time-75,slot=CaelumCityData.FURNITURE_SLOT_BASE+house;
            let table=CaelumDiningWorld.Find(slot);let bed=CaelumRestFurnitureTrial.Find(slot);
            for(int n=0;n<7;n++)
            {
                let furniture=n==6 ? bed : CaelumRestFurniture(table.Chairs[n]);
                vector3 entry=furniture.Pos+(Cos(furniture.Angle),Sin(furniture.Angle),0)*(furniture.Radius+user.Radius+8);
                user.SetOrigin(entry,false);
                bool seated=user.TestMobjLocation() && furniture.Seat(user);
                furniture.Release(user,entry);
                Check(seated && furniture.Occupant==null && user.TestMobjLocation(),String.Format("house %d furniture %d seat and clear exit",house,n));
            }
            return;
        }
        if(House>=3)return;
        int id=House==0 ? 0 : House==1 ? 79 : 159;
        vector3 origin=CaelumCityData.HouseOrigin(id);
        if(Started==0){user.SetOrigin(CaelumCityData.DoorOutside(id),false);Started=level.time;}
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf door;
        while((door=CaelumHingedDoorLeaf(it.Next()))!=null)
            if(door.args[0]==CaelumCityData.DoorGroup(id)){door.RequestDoorGroup(user);break;}
        vector3 goal=origin+Waypoint(Step);
        vector2 delta=goal.XY-user.Pos.XY;
        if(delta.Length()<=0.5)
        {
            if(++Step>=10)
            {
                Check(true,String.Format("house %d native entrance, bedroom, bathroom and exit traversal",id));
                House++;Step=0;Started=0;
                if(House==3)Console.Printf("CA133 COMPLETE checks=%d failures=%d",Checks,Failures);
            }
        }
        else user.TryMove(user.Pos.XY+delta.Unit()*Min(8.0,delta.Length()),0);
        if(Started>0 && level.time-Started>1750){Check(false,String.Format("house %d blocked player route step %d",id,Step));House=3;}
    }
}
