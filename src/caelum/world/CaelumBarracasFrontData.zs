// Generado desde los tres frentes aprobados y distancias existentes.
class CaelumBarracasFrontData : Object play
{
    const REVISION=1;
    const GATE_COUNT=4;
    const RAM_COUNT=6;
    static vector3 GatePoint(int i){switch(i){case 0:return (-16832,15232,0);case 1:return (-29760,-320,0);case 2:return (384,-1472,0);case 3:return (-4352,-14208,0);}return (-16832,15232,0);}
    static String GateName(int i){switch(i){case 0:return "CA_POI_PORT_GATE_6";case 1:return "CA_POI_PORT_GATE_7";case 2:return "CA_POI_PORT_GATE_EAST";case 3:return "CA_POI_PORT_GATE_SOUTH";}return "CA_POI_PORT_GATE_6";}
    static double GateOutward(int i){switch(i){case 0:return 90;case 1:return 180;case 2:return 0;case 3:return 270;}return 90;}
    static int GateMaterial(int i){switch(i){case 0:return 1;case 1:return 2;case 2:return 1;case 3:return 0;}return 1;}
    static int GateForLane(int i){switch(i){case 0:return 3;case 1:return 3;case 2:return 2;case 3:return 2;case 4:return 1;case 5:return 1;}return 3;}
    static vector3 RamStart(int i){switch(i){case 0:return (-4352,-14752,0);case 1:return (-4352,-15264,0);case 2:return (1568,-16640,0);case 3:return (1568,-17152,0);case 4:return (-30944,-16640,0);case 5:return (-30944,-17152,0);}return (-4352,-14752,0);}
    static double RamStartAngle(int i){switch(i){case 0:return 90;case 1:return 90;case 2:return 90;case 3:return 90;case 4:return 90;case 5:return 90;}return 90;}
    static bool RamLarge(int i){switch(i){case 0:return false;case 1:return false;case 2:return false;case 3:return false;case 4:return false;case 5:return true;}return false;}
    static bool RamReserve(int i){switch(i){case 0:return false;case 1:return true;case 2:return false;case 3:return true;case 4:return false;case 5:return true;}return false;}
    static int RamPointCount(int i){switch(i){case 0:return 0;case 1:return 0;case 2:return 3;case 3:return 3;case 4:return 3;case 5:return 3;}return 0;}
    static vector3 GunPoint(int i){switch(i){case 0:return (-4608,-15392,0);case 1:return (-4096,-15392,0);case 2:return (1568,-1728,0);case 3:return (1568,-1216,0);case 4:return (-30944,-64,0);case 5:return (-30944,-576,0);}return (-4608,-15392,0);}
    static double GunAngle(int i){switch(i){case 0:return 90;case 1:return 90;case 2:return 180;case 3:return 180;case 4:return 0;case 5:return 0;}return 90;}
    static vector3 ExitPoint(int i){switch(i){case 0:return (-4352,-22528,0);case 1:return (-4352,-22528,0);case 2:return (1568,-22528,0);case 3:return (1568,-22528,0);case 4:return (-30944,-22528,0);case 5:return (-30944,-22528,0);}return (-4352,-22528,0);}
    static vector3 RamPoint(int lane,int i){switch(lane){
        case 2:switch(i){case 0:return (1568,-2496,0);case 1:return (928,-2496,0);case 2:return (928,-1472,0);}break;
        case 3:switch(i){case 0:return (1568,-2496,0);case 1:return (928,-2496,0);case 2:return (928,-1472,0);}break;
        case 4:switch(i){case 0:return (-30944,-1344,0);case 1:return (-30304,-1344,0);case 2:return (-30304,-320,0);}break;
        case 5:switch(i){case 0:return (-30944,-1344,0);case 1:return (-30304,-1344,0);case 2:return (-30304,-320,0);}break;
        }return RamStart(lane);}
}
