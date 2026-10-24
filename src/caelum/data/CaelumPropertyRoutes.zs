// Rutas derivadas de la geometria existente; conserva los destinos de cada defensor.
class CaelumPropertyRoutes : Object play
{
    static int Count(int identity){switch(identity){
        case 69:return 6;
        case 229:return 6;
        case 389:return 6;
        case 549:return 8;
        }return CaelumCityRoutes.Count(identity);}
    static vector3 Point(int identity,int step){switch(identity){
        case 69:return Route69(step);
        case 229:return Route229(step);
        case 389:return Route389(step);
        case 549:return Route549(step);
        }return CaelumCityRoutes.Point(identity,step);}
    static vector3 Route69(int step){switch(step){
        case 0:return (-11360,1440,0);
        case 1:return (-11360,9504,0);
        case 2:return (-736,9504,0);
        case 3:return (-736,10528,0);
        case 4:return (-416,10528,0);
        case 5:return (-448,10496,0);
        }return (0,0,0);}
    static vector3 Route229(int step){switch(step){
        case 0:return (-11360,1440,0);
        case 1:return (-11360,-11424,0);
        case 2:return (-736,-11424,0);
        case 3:return (-736,-12832,0);
        case 4:return (160,-12832,0);
        case 5:return (184,-12840,0);
        }return (0,0,0);}
    static vector3 Route389(int step){switch(step){
        case 0:return (-11360,1440,0);
        case 1:return (-11488,1440,0);
        case 2:return (-11488,864,0);
        case 3:return (-28448,864,0);
        case 4:return (-28448,-9120,0);
        case 5:return (-28440,-9104,0);
        }return (0,0,0);}
    static vector3 Route549(int step){switch(step){
        case 0:return (-11360,1440,0);
        case 1:return (-11360,2400,0);
        case 2:return (-2080,2400,0);
        case 3:return (-2080,2528,0);
        case 4:return (-1056,2528,0);
        case 5:return (-1056,2400,0);
        case 6:return (-416,2400,0);
        case 7:return (-448,2416,0);
        }return (0,0,0);}
}
