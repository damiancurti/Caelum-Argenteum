// Generado desde CITY.json; no modifica la geometría ni revela recorridos.
class CaelumBattleRouteData : Object
{
    const COUNT=37;
    static bool Contains(int id,vector3 p,bool revised=false)
    {
        if(revised && id>0)
        {
            switch(id)
            {
            case 1:return p.X>=-25984 && p.X<=-25856 && p.Y>=-11712 && p.Y<=-11648 && Abs(p.Z-16)<=1;
            case 2:return p.X>=-22656 && p.X<=-22528 && p.Y>=-13376 && p.Y<=-13312 && Abs(p.Z-16)<=1;
            case 3:return p.X>=-19712 && p.X<=-19584 && p.Y>=-13888 && p.Y<=-13824 && Abs(p.Z-16)<=1;
            case 4:return p.X>=-16576 && p.X<=-16448 && p.Y>=-14080 && p.Y<=-14016 && Abs(p.Z-16)<=1;
            case 5:return p.X>=-13440 && p.X<=-13312 && p.Y>=-14208 && p.Y<=-14144 && Abs(p.Z-16)<=1;
            case 6:return p.X>=-10432 && p.X<=-10304 && p.Y>=-14016 && p.Y<=-13952 && Abs(p.Z-16)<=1;
            case 7:return p.X>=-6080 && p.X<=-5952 && p.Y>=-13312 && p.Y<=-13248 && Abs(p.Z-16)<=1;
            case 8:return p.X>=-5440 && p.X<=-5312 && p.Y>=-13248 && p.Y<=-13184 && Abs(p.Z-16)<=1;
            case 9:return p.X>=-29312 && p.X<=-29184 && p.Y>=11904 && p.Y<=11968 && Abs(p.Z-16)<=1;
            case 10:return p.X>=-1216 && p.X<=-1088 && p.Y>=11904 && p.Y<=11968 && Abs(p.Z-16)<=1;
            case 11:return p.X>=-27392 && p.X<=-27200 && p.Y>=-10688 && p.Y<=-10624 && Abs(p.Z-16)<=1;
            case 12:return p.X>=-2112 && p.X<=-1984 && p.Y>=-12608 && p.Y<=-12544 && Abs(p.Z-16)<=1;
            case 13:return p.X>=-26560 && p.X<=-26432 && p.Y>=12992 && p.Y<=13056 && Abs(p.Z-16)<=1;
            case 14:return p.X>=-24000 && p.X<=-23872 && p.Y>=13824 && p.Y<=13888 && Abs(p.Z-16)<=1;
            case 15:return p.X>=-21504 && p.X<=-21440 && p.Y>=14656 && p.Y<=14784 && Abs(p.Z-16)<=1;
            case 16:return p.X>=-17024 && p.X<=-16896 && p.Y>=13952 && p.Y<=14016 && Abs(p.Z-16)<=1;
            case 17:return p.X>=-15040 && p.X<=-14912 && p.Y>=14976 && p.Y<=15040 && Abs(p.Z-16)<=1;
            case 18:return p.X>=-8448 && p.X<=-8320 && p.Y>=14848 && p.Y<=14912 && Abs(p.Z-16)<=1;
            case 19:return p.X>=-6528 && p.X<=-6400 && p.Y>=14080 && p.Y<=14144 && Abs(p.Z-16)<=1;
            case 20:return p.X>=-3008 && p.X<=-2880 && p.Y>=12672 && p.Y<=12736 && Abs(p.Z-16)<=1;
            case 21:return p.X>=-27712 && p.X<=-27584 && p.Y>=-11328 && p.Y<=-11264 && Abs(p.Z-16)<=1;
            case 22:return p.X>=-27584 && p.X<=-27520 && p.Y>=-6528 && p.Y<=-6400 && Abs(p.Z-16)<=1;
            case 23:return p.X>=-27968 && p.X<=-27904 && p.Y>=-4608 && p.Y<=-4480 && Abs(p.Z-16)<=1;
            case 24:return p.X>=-28672 && p.X<=-28608 && p.Y>=-896 && p.Y<=-768 && Abs(p.Z-16)<=1;
            case 25:return p.X>=-29632 && p.X<=-29504 && p.Y>=3264 && p.Y<=3328 && Abs(p.Z-16)<=1;
            case 26:return p.X>=-28480 && p.X<=-28416 && p.Y>=5632 && p.Y<=5760 && Abs(p.Z-16)<=1;
            case 27:return p.X>=-29504 && p.X<=-29376 && p.Y>=7616 && p.Y<=7680 && Abs(p.Z-16)<=1;
            case 28:return p.X>=-29376 && p.X<=-29248 && p.Y>=10752 && p.Y<=10816 && Abs(p.Z-16)<=1;
            case 29:return p.X>=-1472 && p.X<=-1344 && p.Y>=-11136 && p.Y<=-11072 && Abs(p.Z-16)<=1;
            case 30:return p.X>=-1152 && p.X<=-1088 && p.Y>=-8128 && p.Y<=-8000 && Abs(p.Z-16)<=1;
            case 31:return p.X>=128 && p.X<=256 && p.Y>=-4352 && p.Y<=-4288 && Abs(p.Z-16)<=1;
            case 32:return p.X>=192 && p.X<=320 && p.Y>=-2944 && p.Y<=-2880 && Abs(p.Z-16)<=1;
            case 33:return p.X>=512 && p.X<=640 && p.Y>=3648 && p.Y<=3712 && Abs(p.Z-16)<=1;
            case 34:return p.X>=-384 && p.X<=-320 && p.Y>=5120 && p.Y<=5248 && Abs(p.Z-16)<=1;
            case 35:return p.X>=-1152 && p.X<=-1088 && p.Y>=7936 && p.Y<=8064 && Abs(p.Z-16)<=1;
            case 36:return p.X>=-832 && p.X<=-704 && p.Y>=10624 && p.Y<=10688 && Abs(p.Z-16)<=1;
            }
            return false;
        }
        switch(id)
        {
        case 0:return p.X>=-30720 && p.X<=-29824 && p.Y>=-14592 && p.Y<=16640 && Abs(p.Z-0)<=1;
        case 1:return p.X>=-27840 && p.X<=-27712 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 2:return p.X>=-24000 && p.X<=-23872 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 3:return p.X>=-20160 && p.X<=-20032 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 4:return p.X>=-16320 && p.X<=-16192 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 5:return p.X>=-12480 && p.X<=-12352 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 6:return p.X>=-8640 && p.X<=-8512 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 7:return p.X>=-4800 && p.X<=-4672 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 8:return p.X>=-960 && p.X<=-832 && p.Y>=-13440 && p.Y<=-13376 && Abs(p.Z-16)<=1;
        case 9:return p.X>=-29568 && p.X<=-29376 && p.Y>=14464 && p.Y<=14528 && Abs(p.Z-16)<=1;
        case 10:return p.X>=448 && p.X<=640 && p.Y>=14464 && p.Y<=14528 && Abs(p.Z-16)<=1;
        case 11:return p.X>=-29568 && p.X<=-29376 && p.Y>=-12992 && p.Y<=-12928 && Abs(p.Z-16)<=1;
        case 12:return p.X>=448 && p.X<=640 && p.Y>=-12992 && p.Y<=-12928 && Abs(p.Z-16)<=1;
        case 13:return p.X>=-27840 && p.X<=-27712 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 14:return p.X>=-24000 && p.X<=-23872 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 15:return p.X>=-20160 && p.X<=-20032 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 16:return p.X>=-16320 && p.X<=-16192 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 17:return p.X>=-12480 && p.X<=-12352 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 18:return p.X>=-8640 && p.X<=-8512 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 19:return p.X>=-4800 && p.X<=-4672 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 20:return p.X>=-960 && p.X<=-832 && p.Y>=14912 && p.Y<=14976 && Abs(p.Z-16)<=1;
        case 21:return p.X>=-28672 && p.X<=-28608 && p.Y>=-12608 && p.Y<=-12480 && Abs(p.Z-16)<=1;
        case 22:return p.X>=-28672 && p.X<=-28608 && p.Y>=-8768 && p.Y<=-8640 && Abs(p.Z-16)<=1;
        case 23:return p.X>=-28672 && p.X<=-28608 && p.Y>=-4928 && p.Y<=-4800 && Abs(p.Z-16)<=1;
        case 24:return p.X>=-28672 && p.X<=-28608 && p.Y>=-1088 && p.Y<=-960 && Abs(p.Z-16)<=1;
        case 25:return p.X>=-28672 && p.X<=-28608 && p.Y>=2752 && p.Y<=2880 && Abs(p.Z-16)<=1;
        case 26:return p.X>=-28672 && p.X<=-28608 && p.Y>=6592 && p.Y<=6720 && Abs(p.Z-16)<=1;
        case 27:return p.X>=-28672 && p.X<=-28608 && p.Y>=10432 && p.Y<=10560 && Abs(p.Z-16)<=1;
        case 28:return p.X>=-28672 && p.X<=-28608 && p.Y>=14272 && p.Y<=14400 && Abs(p.Z-16)<=1;
        case 29:return p.X>=-320 && p.X<=-256 && p.Y>=-12608 && p.Y<=-12480 && Abs(p.Z-16)<=1;
        case 30:return p.X>=-320 && p.X<=-256 && p.Y>=-8768 && p.Y<=-8640 && Abs(p.Z-16)<=1;
        case 31:return p.X>=-320 && p.X<=-256 && p.Y>=-4928 && p.Y<=-4800 && Abs(p.Z-16)<=1;
        case 32:return p.X>=-320 && p.X<=-256 && p.Y>=-1088 && p.Y<=-960 && Abs(p.Z-16)<=1;
        case 33:return p.X>=-320 && p.X<=-256 && p.Y>=2752 && p.Y<=2880 && Abs(p.Z-16)<=1;
        case 34:return p.X>=-320 && p.X<=-256 && p.Y>=6592 && p.Y<=6720 && Abs(p.Z-16)<=1;
        case 35:return p.X>=-320 && p.X<=-256 && p.Y>=10432 && p.Y<=10560 && Abs(p.Z-16)<=1;
        case 36:return p.X>=-320 && p.X<=-256 && p.Y>=14272 && p.Y<=14400 && Abs(p.Z-16)<=1;
        }
        return false;
    }
    static String Id(int id)
    {
        switch(id)
        {
        case 0:return "battle-route-west-flank";
        case 1:return "battle-route-south_wall_0";
        case 2:return "battle-route-south_wall_1";
        case 3:return "battle-route-south_wall_2";
        case 4:return "battle-route-south_wall_3";
        case 5:return "battle-route-south_wall_4";
        case 6:return "battle-route-south_wall_5";
        case 7:return "battle-route-south_wall_6";
        case 8:return "battle-route-south_wall_7";
        case 9:return "battle-route-northwest";
        case 10:return "battle-route-northeast";
        case 11:return "battle-route-southwest";
        case 12:return "battle-route-southeast";
        case 13:return "battle-route-north_wall_0";
        case 14:return "battle-route-north_wall_1";
        case 15:return "battle-route-north_wall_2";
        case 16:return "battle-route-north_wall_3";
        case 17:return "battle-route-north_wall_4";
        case 18:return "battle-route-north_wall_5";
        case 19:return "battle-route-north_wall_6";
        case 20:return "battle-route-north_wall_7";
        case 21:return "battle-route-west_wall_0";
        case 22:return "battle-route-west_wall_1";
        case 23:return "battle-route-west_wall_2";
        case 24:return "battle-route-west_wall_3";
        case 25:return "battle-route-west_wall_4";
        case 26:return "battle-route-west_wall_5";
        case 27:return "battle-route-west_wall_6";
        case 28:return "battle-route-west_wall_7";
        case 29:return "battle-route-east_wall_0";
        case 30:return "battle-route-east_wall_1";
        case 31:return "battle-route-east_wall_2";
        case 32:return "battle-route-east_wall_3";
        case 33:return "battle-route-east_wall_4";
        case 34:return "battle-route-east_wall_5";
        case 35:return "battle-route-east_wall_6";
        case 36:return "battle-route-east_wall_7";
        }
        return "";
    }
    static String NameKey(int id)
    {return id==0?"CA_TACTICS_WEST":"CA_TACTICS_STAIRS";}
}
