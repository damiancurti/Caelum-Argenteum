// #410: generado desde assets/art_source/bathrooms/DATA.json.
class CaelumDomesticFixtureData : Object play
{
    const REVISION=1;
    const COUNT=3;
    static double Radius(int kind){switch(kind){
        case 0:return 12.800000;
        case 1:return 28.800000;
        case 2:return 11.200000;
        }return 0;}
    static double Height(int kind){switch(kind){
        case 0:return 32.000000;
        case 1:return 24.000000;
        case 2:return 60.800000;
        }return 0;}
    static double Facing(int kind){switch(kind){
        case 0:return 90.000000;
        case 1:return 90.000000;
        case 2:return 90.000000;
        }return 0;}
    static vector3 Offset(int kind){switch(kind){
        case 0:return (104,1080,0);
        case 1:return (316,1088,0);
        case 2:return (324,948,0);
        }return (0,0,0);}
    static Name ActorClass(int kind){switch(kind){
        case 0:return "CaelumDomesticSink";
        case 1:return "CaelumDomesticBathtub";
        case 2:return "CaelumDomesticToilet";
        }return "None";}
}
