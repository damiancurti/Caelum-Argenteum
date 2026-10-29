// #410: generado desde assets/map01_mansion/BATHROOMS.json.
class CaelumMansionBathroomData : Object
{
    const REVISION=1;
    const COUNT=12;
    static clearscope vector3 Position(int index)
    {
        switch(index)
        {
            case 0:return (-160,344,136);
            case 1:return (-424,240,136);
            case 2:return (-176,248,136);
            case 3:return (1184,416,136);
            case 4:return (1160,280,136);
            case 5:return (912,248,136);
            case 6:return (-160,-344,136);
            case 7:return (-424,-240,136);
            case 8:return (-176,-248,136);
            case 9:return (1184,-416,136);
            case 10:return (1160,-280,136);
            case 11:return (912,-248,136);
        }
        return (0,0,0);
    }
    static clearscope double Facing(int index)
    {
        switch(index)
        {
            case 0:return 180;
            case 1:return 0;
            case 2:return 270;
            case 3:return 180;
            case 4:return 180;
            case 5:return 180;
            case 6:return 180;
            case 7:return 0;
            case 8:return 0;
            case 9:return 180;
            case 10:return 180;
            case 11:return 90;
        }
        return 0;
    }
    static clearscope int Kind(int index)
    {
        switch(index)
        {
            case 0:return 0;
            case 1:return 1;
            case 2:return 2;
            case 3:return 0;
            case 4:return 1;
            case 5:return 2;
            case 6:return 0;
            case 7:return 1;
            case 8:return 2;
            case 9:return 0;
            case 10:return 1;
            case 11:return 2;
        }
        return -1;
    }
}
