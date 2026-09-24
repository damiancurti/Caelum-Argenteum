// Generado desde LAYOUT.json y generate_map02_maze.py.
class CaelumMazeLayout : Object play
{
    const REVISION = 2;
    static bool IsCurrent(){return level.MapName=="MAP02" && ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next()!=null;}
    static vector3 TravelPosition(int id)
    {
        if(id==2)return (704,17856,0);
        if(id==4)return (2368,17856,0);
        if(id==6)return (704,18752,0);
        if(id==14)return (1536,19200,0);
        return (0,0,0);
    }
    const TIME_ADVANCE_ZONE_COUNT = 10;
    static vector3 TimeAdvanceZonePosition(int index)
    {
        if(index==0)return (-1728,-160,0);
        if(index==1)return (-1024,-160,0);
        if(index==2)return (-2560,768,0);
        if(index==3)return (-2560,4864,0);
        if(index==4)return (-2560,8960,0);
        if(index==5)return (-2560,13056,0);
        if(index==6)return (2464,3680,0);
        if(index==7)return (2464,7776,0);
        if(index==8)return (2464,11872,0);
        if(index==9)return (2464,15968,0);
        return (0,0,0);
    }
    static vector3 ArrivalChairPosition(){return (-1536,-160,0);}
    static vector3 ArrivalBedPosition(){return (-1728,-160,0);}
    static vector3 ArrivalWorkbenchPosition(){return (-1024,-160,0);}
}
