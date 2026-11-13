// Generado por generate_barracas_ram_crews.py; solo puestos, sin cambios de atributos.
class CaelumBarracasRamCrewData : Object { const REVISION=1;
const CLEARANCE_RADIUS=21.333333;
static double Spacing(bool large){return large?61:61;}
static vector3 Offset(bool large,int slot){return large?LargePost(slot):SmallPost(slot);}
static vector3 SmallPost(int slot){switch(slot){
case 0:return (19.333334,-90.0,0);
case 1:return (19.333334,90.0,0);
case 2:return (-41.666666,-90.0,0);
case 3:return (-41.666666,90.0,0);
case 4:return (-102.666666,-90.0,0);
case 5:return (-102.666666,90.0,0);
}return (0,0,0);}
static vector3 LargePost(int slot){switch(slot){
case 0:return (65.657311627,-157.244483653,0);
case 1:return (65.657311627,157.244483653,0);
case 2:return (65.657311627,-218.244483653,0);
case 3:return (65.657311627,218.244483653,0);
case 4:return (4.657311627,-157.244483653,0);
case 5:return (4.657311627,157.244483653,0);
case 6:return (4.657311627,-218.244483653,0);
case 7:return (4.657311627,218.244483653,0);
case 8:return (-56.342688373,-157.244483653,0);
case 9:return (-56.342688373,157.244483653,0);
case 10:return (-56.342688373,-218.244483653,0);
case 11:return (-56.342688373,218.244483653,0);
case 12:return (-117.342688373,-157.244483653,0);
case 13:return (-117.342688373,157.244483653,0);
case 14:return (-117.342688373,-218.244483653,0);
case 15:return (-117.342688373,218.244483653,0);
case 16:return (-178.342688373,-157.244483653,0);
case 17:return (-178.342688373,157.244483653,0);
case 18:return (-178.342688373,-218.244483653,0);
case 19:return (-178.342688373,218.244483653,0);
case 20:return (-239.342688373,-157.244483653,0);
case 21:return (-239.342688373,157.244483653,0);
case 22:return (-239.342688373,-218.244483653,0);
case 23:return (-239.342688373,218.244483653,0);
case 24:return (-300.342688373,-157.244483653,0);
case 25:return (-300.342688373,157.244483653,0);
case 26:return (-300.342688373,-218.244483653,0);
case 27:return (-300.342688373,218.244483653,0);
case 28:return (-361.342688373,-157.244483653,0);
case 29:return (-361.342688373,157.244483653,0);
case 30:return (-361.342688373,-218.244483653,0);
case 31:return (-361.342688373,218.244483653,0);
}return (0,0,0);}
}
