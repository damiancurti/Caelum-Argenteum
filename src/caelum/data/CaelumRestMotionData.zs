// Generado desde rest_motion_460/DESIGN.json; tiempos aprobados del #460.
class CaelumRestMotionData : Object
{
    const REVISION=1;
    const NONE=0;
    const SIT_DOWN=1;
    const STAND_UP=2;
    const LIE_DOWN=3;
    const GET_UP=4;
    const EAT=5;
    const DRINK=6;
    const TRANSITION_STATES=44;
    const MEAL_SAMPLES=14;
    static clearscope int Duration(int motion)
    {
        switch(motion)
        {
        case SIT_DOWN: return 2*TICRATE;
        case STAND_UP: return 2*TICRATE;
        case LIE_DOWN: return 3*TICRATE;
        case GET_UP: return 3*TICRATE;
        case EAT: return 4*TICRATE;
        case DRINK: return 4*TICRATE;
        }
        return 0;
    }
    static clearscope int StateIndex(int motion,int elapsed,bool sleeping=false)
    {
        if(motion==EAT || motion==DRINK)
            return TRANSITION_STATES+(sleeping?MEAL_SAMPLES:0)+Clamp(elapsed*MEAL_SAMPLES/Duration(motion),0,MEAL_SAMPLES-1);
        if(motion==GET_UP && elapsed>=105)return 43;
        if(motion==GET_UP && elapsed>=94)return 42;
        if(motion==GET_UP && elapsed>=84)return 41;
        if(motion==GET_UP && elapsed>=74)return 40;
        if(motion==GET_UP && elapsed>=63)return 39;
        if(motion==GET_UP && elapsed>=52)return 38;
        if(motion==GET_UP && elapsed>=42)return 37;
        if(motion==GET_UP && elapsed>=32)return 36;
        if(motion==GET_UP && elapsed>=21)return 35;
        if(motion==GET_UP && elapsed>=10)return 34;
        if(motion==GET_UP && elapsed>=0)return 33;
        if(motion==LIE_DOWN && elapsed>=105)return 32;
        if(motion==LIE_DOWN && elapsed>=94)return 31;
        if(motion==LIE_DOWN && elapsed>=84)return 30;
        if(motion==LIE_DOWN && elapsed>=74)return 29;
        if(motion==LIE_DOWN && elapsed>=63)return 28;
        if(motion==LIE_DOWN && elapsed>=52)return 27;
        if(motion==LIE_DOWN && elapsed>=42)return 26;
        if(motion==LIE_DOWN && elapsed>=32)return 25;
        if(motion==LIE_DOWN && elapsed>=21)return 24;
        if(motion==LIE_DOWN && elapsed>=10)return 23;
        if(motion==LIE_DOWN && elapsed>=0)return 22;
        if(motion==STAND_UP && elapsed>=70)return 21;
        if(motion==STAND_UP && elapsed>=63)return 20;
        if(motion==STAND_UP && elapsed>=56)return 19;
        if(motion==STAND_UP && elapsed>=49)return 18;
        if(motion==STAND_UP && elapsed>=42)return 17;
        if(motion==STAND_UP && elapsed>=35)return 16;
        if(motion==STAND_UP && elapsed>=28)return 15;
        if(motion==STAND_UP && elapsed>=21)return 14;
        if(motion==STAND_UP && elapsed>=14)return 13;
        if(motion==STAND_UP && elapsed>=7)return 12;
        if(motion==STAND_UP && elapsed>=0)return 11;
        if(motion==SIT_DOWN && elapsed>=70)return 10;
        if(motion==SIT_DOWN && elapsed>=63)return 9;
        if(motion==SIT_DOWN && elapsed>=56)return 8;
        if(motion==SIT_DOWN && elapsed>=49)return 7;
        if(motion==SIT_DOWN && elapsed>=42)return 6;
        if(motion==SIT_DOWN && elapsed>=35)return 5;
        if(motion==SIT_DOWN && elapsed>=28)return 4;
        if(motion==SIT_DOWN && elapsed>=21)return 3;
        if(motion==SIT_DOWN && elapsed>=14)return 2;
        if(motion==SIT_DOWN && elapsed>=7)return 1;
        if(motion==SIT_DOWN && elapsed>=0)return 0;
        return -1;
    }
    static clearscope int SampleTic(int index)
    {
        switch(index)
        {
        case 0: return 0;
        case 1: return 7;
        case 2: return 14;
        case 3: return 21;
        case 4: return 28;
        case 5: return 35;
        case 6: return 42;
        case 7: return 49;
        case 8: return 56;
        case 9: return 63;
        case 10: return 70;
        case 11: return 0;
        case 12: return 7;
        case 13: return 14;
        case 14: return 21;
        case 15: return 28;
        case 16: return 35;
        case 17: return 42;
        case 18: return 49;
        case 19: return 56;
        case 20: return 63;
        case 21: return 70;
        case 22: return 0;
        case 23: return 10;
        case 24: return 21;
        case 25: return 32;
        case 26: return 42;
        case 27: return 52;
        case 28: return 63;
        case 29: return 74;
        case 30: return 84;
        case 31: return 94;
        case 32: return 105;
        case 33: return 0;
        case 34: return 10;
        case 35: return 21;
        case 36: return 32;
        case 37: return 42;
        case 38: return 52;
        case 39: return 63;
        case 40: return 74;
        case 41: return 84;
        case 42: return 94;
        case 43: return 105;
        case 44: return 0;
        case 45: return 10;
        case 46: return 20;
        case 47: return 30;
        case 48: return 40;
        case 49: return 50;
        case 50: return 60;
        case 51: return 70;
        case 52: return 80;
        case 53: return 90;
        case 54: return 100;
        case 55: return 110;
        case 56: return 120;
        case 57: return 130;
        case 58: return 0;
        case 59: return 10;
        case 60: return 20;
        case 61: return 30;
        case 62: return 40;
        case 63: return 50;
        case 64: return 60;
        case 65: return 70;
        case 66: return 80;
        case 67: return 90;
        case 68: return 100;
        case 69: return 110;
        case 70: return 120;
        case 71: return 130;
        }
        return 0;
    }
    static clearscope int NativeFrame(int index)
    {
        switch(index)
        {
        case 0: return 151;
        case 1: return 152;
        case 2: return 153;
        case 3: return 154;
        case 4: return 155;
        case 5: return 156;
        case 6: return 157;
        case 7: return 158;
        case 8: return 159;
        case 9: return 160;
        case 10: return 161;
        case 11: return 162;
        case 12: return 163;
        case 13: return 164;
        case 14: return 165;
        case 15: return 166;
        case 16: return 167;
        case 17: return 168;
        case 18: return 169;
        case 19: return 170;
        case 20: return 171;
        case 21: return 172;
        case 22: return 173;
        case 23: return 174;
        case 24: return 175;
        case 25: return 176;
        case 26: return 177;
        case 27: return 178;
        case 28: return 179;
        case 29: return 180;
        case 30: return 181;
        case 31: return 182;
        case 32: return 183;
        case 33: return 184;
        case 34: return 185;
        case 35: return 186;
        case 36: return 187;
        case 37: return 188;
        case 38: return 189;
        case 39: return 190;
        case 40: return 191;
        case 41: return 192;
        case 42: return 193;
        case 43: return 194;
        case 44: return 0;
        case 45: return 1;
        case 46: return 2;
        case 47: return 3;
        case 48: return 4;
        case 49: return 5;
        case 50: return 6;
        case 51: return 7;
        case 52: return 8;
        case 53: return 9;
        case 54: return 10;
        case 55: return 11;
        case 56: return 12;
        case 57: return 13;
        case 58: return 14;
        case 59: return 15;
        case 60: return 16;
        case 61: return 17;
        case 62: return 18;
        case 63: return 19;
        case 64: return 20;
        case 65: return 21;
        case 66: return 22;
        case 67: return 23;
        case 68: return 24;
        case 69: return 25;
        case 70: return 26;
        case 71: return 27;
        }
        return 0;
    }
    static clearscope String ModelPath(String original,int motion)
    {
        if(motion!=EAT && motion!=DRINK)return original;
        String path=original;path.Replace("characters/",motion==EAT?"characters/rest_motion/eat/":"characters/rest_motion/drink/");return path;
    }
    static clearscope String BaseFile(int slot)
    {
        switch(slot)
        {
        case 0: return "clothing.md3";
        case 1: return "armor.md3";
        case 2: return "cape.md3";
        case 3: return "face.md3";
        case 4: return "hair.md3";
        case 5: return "weapon.md3";
        case 6: return "shield.md3";
        }
        return "";
    }
}
