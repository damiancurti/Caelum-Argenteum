// Marchas desde el campo sur, derivadas de la geometria aprobada.
class CaelumBarracasMarchData : Object play
{
    const REVISION=1;
    const ENTRY_LINE_Y=-16640;
    static int InfantryCount(int lane){switch(lane){case 0:return 2;case 1:return 2;case 2:return 5;case 3:return 5;case 4:return 5;case 5:return 5;}return 0;}
    static vector3 InfantryPoint(int lane,int step){switch(lane){
        case 0:switch(step){case 0:return (-4352,-16640,0);case 1:return (-4352,-14208,0);}break;
        case 1:switch(step){case 0:return (-4352,-16640,0);case 1:return (-4352,-14208,0);}break;
        case 2:switch(step){case 0:return (2080,-16640,0);case 1:return (2080,-2496,0);case 2:return (928,-2496,0);case 3:return (928,-1472,0);case 4:return (384,-1472,0);}break;
        case 3:switch(step){case 0:return (2080,-16640,0);case 1:return (2080,-2496,0);case 2:return (928,-2496,0);case 3:return (928,-1472,0);case 4:return (384,-1472,0);}break;
        case 4:switch(step){case 0:return (-31456,-16640,0);case 1:return (-31456,-1344,0);case 2:return (-30304,-1344,0);case 3:return (-30304,-320,0);case 4:return (-29760,-320,0);}break;
        case 5:switch(step){case 0:return (-31456,-16640,0);case 1:return (-31456,-1344,0);case 2:return (-30304,-1344,0);case 3:return (-30304,-320,0);case 4:return (-29760,-320,0);}break;
        }return (0,0,0);}
    static int GunCount(int lane){switch(lane){case 0:return 2;case 1:return 2;case 2:return 2;case 3:return 2;case 4:return 2;case 5:return 2;}return 0;}
    static vector3 GunPoint(int lane,int step){switch(lane){
        case 0:switch(step){case 0:return (-4608,-16640,0);case 1:return (-4608,-15904,0);}break;
        case 1:switch(step){case 0:return (-4096,-16640,0);case 1:return (-4096,-15904,0);}break;
        case 2:switch(step){case 0:return (2080,-16640,0);case 1:return (2080,-2240,0);}break;
        case 3:switch(step){case 0:return (2080,-16640,0);case 1:return (2080,-1728,0);}break;
        case 4:switch(step){case 0:return (-31456,-16640,0);case 1:return (-31456,-576,0);}break;
        case 5:switch(step){case 0:return (-31456,-16640,0);case 1:return (-31456,-1088,0);}break;
        }return (0,0,0);}
    static vector3 GunCrewStart(int lane,int slot){switch(lane){
        case 0:return slot==0?(-4698,-17664,0):(-4518,-17664,0);
        case 1:return slot==0?(-4186,-18176,0):(-4006,-18176,0);
        case 2:return slot==0?(2080,-17754,0):(2080,-17574,0);
        case 3:return slot==0?(2080,-18266,0):(2080,-18086,0);
        case 4:return slot==0?(-31456,-17574,0):(-31456,-17754,0);
        case 5:return slot==0?(-31456,-18086,0):(-31456,-18266,0);
        }return (0,0,0);}
    static vector3 GunApproachOffset(int lane){switch(lane){case 0:return (0,-180,0);case 1:return (0,-180,0);case 2:return (180,0,0);case 3:return (180,0,0);case 4:return (-180,0,0);case 5:return (-180,0,0);}return (0,0,0);}
}
