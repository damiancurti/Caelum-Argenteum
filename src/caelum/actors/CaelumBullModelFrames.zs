// Generado desde DESIGN.json y el Blender editable del #369.
class CaelumBullModelFrames : Actor
{
    const WALK_STRIDE=26;
    const RUN_STRIDE=52;
    const VISUAL_RADIUS=44;
    const VISUAL_HEIGHT=61;
    const IDLE=0;
    const WALK=1;
    const RUN=2;
    const PREPARE=3;
    const PREPARETRIAL=4;
    const CHARGE=5;
    const GORE=6;
    const PAIN=7;
    const DEATH=8;
    const CORPSE=9;
    const REST=10;
    const STUN=11;
    static clearscope int Start(int poseId)
    {
        static const int values[]={0,20,36,52,55,64,80,83,91,105,106,126};
        return values[Clamp(poseId,0,11)];
    }
    static clearscope int Count(int poseId)
    {
        static const int values[]={20,16,16,3,9,16,3,8,14,1,20,10};
        return values[Clamp(poseId,0,11)];
    }
    static clearscope int Duration(int poseId)
    {
        static const int values[]={80,32,16,3,18,16,3,8,25,1,80,40};
        return values[Clamp(poseId,0,11)];
    }
    static clearscope int Sample(int frame)
    {
        static const int times[]={0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,0,2,4,6,8,11,13,15,17,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,0,1,2,3,4,5,6,7,0,2,4,6,7,9,11,13,15,17,18,20,22,24,0,0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,0,4,8,12,16,20,24,28,32,36};
        return times[Clamp(frame,0,135)];
    }
    static clearscope int FrameFor(int poseId,int elapsed)
    {
        int first=Start(poseId),count=Count(poseId);
        for(int i=count-1;i>0;i--)if(elapsed>=Sample(first+i))return first+i;
        return first;
    }
    States
    {
    Spawn:
        Goto F0;
    F0:
        B300 A 4;
        Goto F1;
    F1:
        B300 B 4;
        Goto F2;
    F2:
        B300 C 4;
        Goto F3;
    F3:
        B300 D 4;
        Goto F4;
    F4:
        B300 E 4;
        Goto F5;
    F5:
        B300 F 4;
        Goto F6;
    F6:
        B300 G 4;
        Goto F7;
    F7:
        B300 H 4;
        Goto F8;
    F8:
        B300 I 4;
        Goto F9;
    F9:
        B300 J 4;
        Goto F10;
    F10:
        B300 K 4;
        Goto F11;
    F11:
        B300 L 4;
        Goto F12;
    F12:
        B300 M 4;
        Goto F13;
    F13:
        B300 N 4;
        Goto F14;
    F14:
        B300 O 4;
        Goto F15;
    F15:
        B300 P 4;
        Goto F16;
    F16:
        B300 Q 4;
        Goto F17;
    F17:
        B300 R 4;
        Goto F18;
    F18:
        B300 S 4;
        Goto F19;
    F19:
        B300 T 4;
        Goto F0;
    F20:
        B300 U 2;
        Goto F21;
    F21:
        B300 V 2;
        Goto F22;
    F22:
        B300 W 2;
        Goto F23;
    F23:
        B300 X 2;
        Goto F24;
    F24:
        B300 Y 2;
        Goto F25;
    F25:
        B300 Z 2;
        Goto F26;
    F26:
        B301 A 2;
        Goto F27;
    F27:
        B301 B 2;
        Goto F28;
    F28:
        B301 C 2;
        Goto F29;
    F29:
        B301 D 2;
        Goto F30;
    F30:
        B301 E 2;
        Goto F31;
    F31:
        B301 F 2;
        Goto F32;
    F32:
        B301 G 2;
        Goto F33;
    F33:
        B301 H 2;
        Goto F34;
    F34:
        B301 I 2;
        Goto F35;
    F35:
        B301 J 2;
        Goto F20;
    F36:
        B301 K 1;
        Goto F37;
    F37:
        B301 L 1;
        Goto F38;
    F38:
        B301 M 1;
        Goto F39;
    F39:
        B301 N 1;
        Goto F40;
    F40:
        B301 O 1;
        Goto F41;
    F41:
        B301 P 1;
        Goto F42;
    F42:
        B301 Q 1;
        Goto F43;
    F43:
        B301 R 1;
        Goto F44;
    F44:
        B301 S 1;
        Goto F45;
    F45:
        B301 T 1;
        Goto F46;
    F46:
        B301 U 1;
        Goto F47;
    F47:
        B301 V 1;
        Goto F48;
    F48:
        B301 W 1;
        Goto F49;
    F49:
        B301 X 1;
        Goto F50;
    F50:
        B301 Y 1;
        Goto F51;
    F51:
        B301 Z 1;
        Goto F36;
    F52:
        B302 A 1;
        Goto F53;
    F53:
        B302 B 1;
        Goto F54;
    F54:
        B302 C -1;
        Stop;
    F55:
        B302 D 2;
        Goto F56;
    F56:
        B302 E 2;
        Goto F57;
    F57:
        B302 F 2;
        Goto F58;
    F58:
        B302 G 2;
        Goto F59;
    F59:
        B302 H 3;
        Goto F60;
    F60:
        B302 I 2;
        Goto F61;
    F61:
        B302 J 2;
        Goto F62;
    F62:
        B302 K 2;
        Goto F63;
    F63:
        B302 L -1;
        Stop;
    F64:
        B302 M 1;
        Goto F65;
    F65:
        B302 N 1;
        Goto F66;
    F66:
        B302 O 1;
        Goto F67;
    F67:
        B302 P 1;
        Goto F68;
    F68:
        B302 Q 1;
        Goto F69;
    F69:
        B302 R 1;
        Goto F70;
    F70:
        B302 S 1;
        Goto F71;
    F71:
        B302 T 1;
        Goto F72;
    F72:
        B302 U 1;
        Goto F73;
    F73:
        B302 V 1;
        Goto F74;
    F74:
        B302 W 1;
        Goto F75;
    F75:
        B302 X 1;
        Goto F76;
    F76:
        B302 Y 1;
        Goto F77;
    F77:
        B302 Z 1;
        Goto F78;
    F78:
        B303 A 1;
        Goto F79;
    F79:
        B303 B 1;
        Goto F64;
    F80:
        B303 C 1;
        Goto F81;
    F81:
        B303 D 1;
        Goto F82;
    F82:
        B303 E -1;
        Stop;
    F83:
        B303 F 1;
        Goto F84;
    F84:
        B303 G 1;
        Goto F85;
    F85:
        B303 H 1;
        Goto F86;
    F86:
        B303 I 1;
        Goto F87;
    F87:
        B303 J 1;
        Goto F88;
    F88:
        B303 K 1;
        Goto F89;
    F89:
        B303 L 1;
        Goto F90;
    F90:
        B303 M -1;
        Stop;
    F91:
        B303 N 2;
        Goto F92;
    F92:
        B303 O 2;
        Goto F93;
    F93:
        B303 P 2;
        Goto F94;
    F94:
        B303 Q 1;
        Goto F95;
    F95:
        B303 R 2;
        Goto F96;
    F96:
        B303 S 2;
        Goto F97;
    F97:
        B303 T 2;
        Goto F98;
    F98:
        B303 U 2;
        Goto F99;
    F99:
        B303 V 2;
        Goto F100;
    F100:
        B303 W 1;
        Goto F101;
    F101:
        B303 X 2;
        Goto F102;
    F102:
        B303 Y 2;
        Goto F103;
    F103:
        B303 Z 2;
        Goto F104;
    F104:
        B304 A -1;
        Stop;
    F105:
        B304 B -1;
        Stop;
    F106:
        B304 C 4;
        Goto F107;
    F107:
        B304 D 4;
        Goto F108;
    F108:
        B304 E 4;
        Goto F109;
    F109:
        B304 F 4;
        Goto F110;
    F110:
        B304 G 4;
        Goto F111;
    F111:
        B304 H 4;
        Goto F112;
    F112:
        B304 I 4;
        Goto F113;
    F113:
        B304 J 4;
        Goto F114;
    F114:
        B304 K 4;
        Goto F115;
    F115:
        B304 L 4;
        Goto F116;
    F116:
        B304 M 4;
        Goto F117;
    F117:
        B304 N 4;
        Goto F118;
    F118:
        B304 O 4;
        Goto F119;
    F119:
        B304 P 4;
        Goto F120;
    F120:
        B304 Q 4;
        Goto F121;
    F121:
        B304 R 4;
        Goto F122;
    F122:
        B304 S 4;
        Goto F123;
    F123:
        B304 T 4;
        Goto F124;
    F124:
        B304 U 4;
        Goto F125;
    F125:
        B304 V 4;
        Goto F106;
    F126:
        B304 W 4;
        Goto F127;
    F127:
        B304 X 4;
        Goto F128;
    F128:
        B304 Y 4;
        Goto F129;
    F129:
        B304 Z 4;
        Goto F130;
    F130:
        B305 A 4;
        Goto F131;
    F131:
        B305 B 4;
        Goto F132;
    F132:
        B305 C 4;
        Goto F133;
    F133:
        B305 D 4;
        Goto F134;
    F134:
        B305 E 4;
        Goto F135;
    F135:
        B305 F 4;
        Goto F126;
    }
}
