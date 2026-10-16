// Generado desde DESIGN.json y el Blender editable del #283.
class CaelumDomingoPilotFrames : Actor
{
    const IDLEBREATHING=0;
    const WALK=1;
    const RUN=2;
    const MELEE=3;
    const MISSILE=4;
    const PAIN=5;
    const DEATH=6;
    const RAISE=7;
    const SEATED=8;
    const SLEEPING=9;
    const CROUCH=10;
    const SITDOWN=11;
    const STANDUP=12;
    const LIEDOWN=13;
    const GETUP=14;
    const JUMPPREPARE=15;
    const LANDING=16;
    const JUMPAIR=17;
    const GUARDIDLEBREATHING=18;
    const GUARDWALK=19;
    const GUARDRUN=20;
    const GUARDJUMPPREPARE=21;
    const GUARDLANDING=22;
    const GUARDJUMPAIR=23;
    static clearscope int Start(int poseId)
    {
        static const int values[]={0,14,22,34,48,64,72,101,122,136,150,151,162,173,184,195,231,267,268,282,290,302,338,374};
        return values[Clamp(poseId,0,23)];
    }
    static clearscope int Count(int poseId)
    {
        static const int values[]={14,8,12,14,16,8,29,21,14,14,1,11,11,11,11,36,36,1,14,8,12,36,36,1};
        return values[Clamp(poseId,0,23)];
    }
    static clearscope int Duration(int poseId)
    {
        static const int values[]={70,8,12,14,16,8,56,40,70,70,1,40,40,40,40,35,35,1,70,8,12,35,35,1};
        return values[Clamp(poseId,0,23)];
    }
    static clearscope int Sample(int frame)
    {
        static const int times[]={0,5,10,15,20,25,30,35,40,45,50,55,60,65,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,8,9,10,11,0,1,2,3,4,5,6,7,8,9,10,11,12,13,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,0,5,10,15,20,25,30,35,40,45,50,55,60,65,0,5,10,15,20,25,30,35,40,45,50,55,60,65,0,0,4,8,12,16,20,24,28,32,36,40,0,4,8,12,16,20,24,28,32,36,40,0,4,8,12,16,20,24,28,32,36,40,0,4,8,12,16,20,24,28,32,36,40,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,0,0,5,10,15,20,25,30,35,40,45,50,55,60,65,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,8,9,10,11,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,0};
        return times[Clamp(frame,0,374)];
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
        D300 A 5;
        Goto F1;
    F1:
        D300 B 5;
        Goto F2;
    F2:
        D300 C 5;
        Goto F3;
    F3:
        D300 D 5;
        Goto F4;
    F4:
        D300 E 5;
        Goto F5;
    F5:
        D300 F 5;
        Goto F6;
    F6:
        D300 G 5;
        Goto F7;
    F7:
        D300 H 5;
        Goto F8;
    F8:
        D300 I 5;
        Goto F9;
    F9:
        D300 J 5;
        Goto F10;
    F10:
        D300 K 5;
        Goto F11;
    F11:
        D300 L 5;
        Goto F12;
    F12:
        D300 M 5;
        Goto F13;
    F13:
        D300 N 5;
        Goto F0;
    F14:
        D300 O 1;
        Goto F15;
    F15:
        D300 P 1;
        Goto F16;
    F16:
        D300 Q 1;
        Goto F17;
    F17:
        D300 R 1;
        Goto F18;
    F18:
        D300 S 1;
        Goto F19;
    F19:
        D300 T 1;
        Goto F20;
    F20:
        D300 U 1;
        Goto F21;
    F21:
        D300 V 1;
        Goto F14;
    F22:
        D300 W 1;
        Goto F23;
    F23:
        D300 X 1;
        Goto F24;
    F24:
        D300 Y 1;
        Goto F25;
    F25:
        D300 Z 1;
        Goto F26;
    F26:
        D301 A 1;
        Goto F27;
    F27:
        D301 B 1;
        Goto F28;
    F28:
        D301 C 1;
        Goto F29;
    F29:
        D301 D 1;
        Goto F30;
    F30:
        D301 E 1;
        Goto F31;
    F31:
        D301 F 1;
        Goto F32;
    F32:
        D301 G 1;
        Goto F33;
    F33:
        D301 H 1;
        Goto F22;
    F34:
        D301 I 1;
        Goto F35;
    F35:
        D301 J 1;
        Goto F36;
    F36:
        D301 K 1;
        Goto F37;
    F37:
        D301 L 1;
        Goto F38;
    F38:
        D301 M 1;
        Goto F39;
    F39:
        D301 N 1;
        Goto F40;
    F40:
        D301 O 1;
        Goto F41;
    F41:
        D301 P 1;
        Goto F42;
    F42:
        D301 Q 1;
        Goto F43;
    F43:
        D301 R 1;
        Goto F44;
    F44:
        D301 S 1;
        Goto F45;
    F45:
        D301 T 1;
        Goto F46;
    F46:
        D301 U 1;
        Goto F47;
    F47:
        D301 V -1;
        Stop;
    F48:
        D301 W 1;
        Goto F49;
    F49:
        D301 X 1;
        Goto F50;
    F50:
        D301 Y 1;
        Goto F51;
    F51:
        D301 Z 1;
        Goto F52;
    F52:
        D302 A 1;
        Goto F53;
    F53:
        D302 B 1;
        Goto F54;
    F54:
        D302 C 1;
        Goto F55;
    F55:
        D302 D 1;
        Goto F56;
    F56:
        D302 E 1;
        Goto F57;
    F57:
        D302 F 1;
        Goto F58;
    F58:
        D302 G 1;
        Goto F59;
    F59:
        D302 H 1;
        Goto F60;
    F60:
        D302 I 1;
        Goto F61;
    F61:
        D302 J 1;
        Goto F62;
    F62:
        D302 K 1;
        Goto F63;
    F63:
        D302 L -1;
        Stop;
    F64:
        D302 M 1;
        Goto F65;
    F65:
        D302 N 1;
        Goto F66;
    F66:
        D302 O 1;
        Goto F67;
    F67:
        D302 P 1;
        Goto F68;
    F68:
        D302 Q 1;
        Goto F69;
    F69:
        D302 R 1;
        Goto F70;
    F70:
        D302 S 1;
        Goto F71;
    F71:
        D302 T -1;
        Stop;
    F72:
        D302 U 2;
        Goto F73;
    F73:
        D302 V 2;
        Goto F74;
    F74:
        D302 W 2;
        Goto F75;
    F75:
        D302 X 2;
        Goto F76;
    F76:
        D302 Y 2;
        Goto F77;
    F77:
        D302 Z 2;
        Goto F78;
    F78:
        D303 A 2;
        Goto F79;
    F79:
        D303 B 2;
        Goto F80;
    F80:
        D303 C 2;
        Goto F81;
    F81:
        D303 D 2;
        Goto F82;
    F82:
        D303 E 2;
        Goto F83;
    F83:
        D303 F 2;
        Goto F84;
    F84:
        D303 G 2;
        Goto F85;
    F85:
        D303 H 2;
        Goto F86;
    F86:
        D303 I 2;
        Goto F87;
    F87:
        D303 J 2;
        Goto F88;
    F88:
        D303 K 2;
        Goto F89;
    F89:
        D303 L 2;
        Goto F90;
    F90:
        D303 M 2;
        Goto F91;
    F91:
        D303 N 2;
        Goto F92;
    F92:
        D303 O 2;
        Goto F93;
    F93:
        D303 P 2;
        Goto F94;
    F94:
        D303 Q 2;
        Goto F95;
    F95:
        D303 R 2;
        Goto F96;
    F96:
        D303 S 2;
        Goto F97;
    F97:
        D303 T 2;
        Goto F98;
    F98:
        D303 U 2;
        Goto F99;
    F99:
        D303 V 2;
        Goto F100;
    F100:
        D303 W -1;
        Stop;
    F101:
        D303 X 2;
        Goto F102;
    F102:
        D303 Y 2;
        Goto F103;
    F103:
        D303 Z 2;
        Goto F104;
    F104:
        D304 A 2;
        Goto F105;
    F105:
        D304 B 2;
        Goto F106;
    F106:
        D304 C 2;
        Goto F107;
    F107:
        D304 D 2;
        Goto F108;
    F108:
        D304 E 2;
        Goto F109;
    F109:
        D304 F 2;
        Goto F110;
    F110:
        D304 G 2;
        Goto F111;
    F111:
        D304 H 2;
        Goto F112;
    F112:
        D304 I 2;
        Goto F113;
    F113:
        D304 J 2;
        Goto F114;
    F114:
        D304 K 2;
        Goto F115;
    F115:
        D304 L 2;
        Goto F116;
    F116:
        D304 M 2;
        Goto F117;
    F117:
        D304 N 2;
        Goto F118;
    F118:
        D304 O 2;
        Goto F119;
    F119:
        D304 P 2;
        Goto F120;
    F120:
        D304 Q 2;
        Goto F121;
    F121:
        D304 R -1;
        Stop;
    F122:
        D304 S 5;
        Goto F123;
    F123:
        D304 T 5;
        Goto F124;
    F124:
        D304 U 5;
        Goto F125;
    F125:
        D304 V 5;
        Goto F126;
    F126:
        D304 W 5;
        Goto F127;
    F127:
        D304 X 5;
        Goto F128;
    F128:
        D304 Y 5;
        Goto F129;
    F129:
        D304 Z 5;
        Goto F130;
    F130:
        D305 A 5;
        Goto F131;
    F131:
        D305 B 5;
        Goto F132;
    F132:
        D305 C 5;
        Goto F133;
    F133:
        D305 D 5;
        Goto F134;
    F134:
        D305 E 5;
        Goto F135;
    F135:
        D305 F 5;
        Goto F122;
    F136:
        D305 G 5;
        Goto F137;
    F137:
        D305 H 5;
        Goto F138;
    F138:
        D305 I 5;
        Goto F139;
    F139:
        D305 J 5;
        Goto F140;
    F140:
        D305 K 5;
        Goto F141;
    F141:
        D305 L 5;
        Goto F142;
    F142:
        D305 M 5;
        Goto F143;
    F143:
        D305 N 5;
        Goto F144;
    F144:
        D305 O 5;
        Goto F145;
    F145:
        D305 P 5;
        Goto F146;
    F146:
        D305 Q 5;
        Goto F147;
    F147:
        D305 R 5;
        Goto F148;
    F148:
        D305 S 5;
        Goto F149;
    F149:
        D305 T 5;
        Goto F136;
    F150:
        D305 U -1;
        Stop;
    F151:
        D305 V 4;
        Goto F152;
    F152:
        D305 W 4;
        Goto F153;
    F153:
        D305 X 4;
        Goto F154;
    F154:
        D305 Y 4;
        Goto F155;
    F155:
        D305 Z 4;
        Goto F156;
    F156:
        D306 A 4;
        Goto F157;
    F157:
        D306 B 4;
        Goto F158;
    F158:
        D306 C 4;
        Goto F159;
    F159:
        D306 D 4;
        Goto F160;
    F160:
        D306 E 4;
        Goto F161;
    F161:
        D306 F -1;
        Stop;
    F162:
        D306 G 4;
        Goto F163;
    F163:
        D306 H 4;
        Goto F164;
    F164:
        D306 I 4;
        Goto F165;
    F165:
        D306 J 4;
        Goto F166;
    F166:
        D306 K 4;
        Goto F167;
    F167:
        D306 L 4;
        Goto F168;
    F168:
        D306 M 4;
        Goto F169;
    F169:
        D306 N 4;
        Goto F170;
    F170:
        D306 O 4;
        Goto F171;
    F171:
        D306 P 4;
        Goto F172;
    F172:
        D306 Q -1;
        Stop;
    F173:
        D306 R 4;
        Goto F174;
    F174:
        D306 S 4;
        Goto F175;
    F175:
        D306 T 4;
        Goto F176;
    F176:
        D306 U 4;
        Goto F177;
    F177:
        D306 V 4;
        Goto F178;
    F178:
        D306 W 4;
        Goto F179;
    F179:
        D306 X 4;
        Goto F180;
    F180:
        D306 Y 4;
        Goto F181;
    F181:
        D306 Z 4;
        Goto F182;
    F182:
        D307 A 4;
        Goto F183;
    F183:
        D307 B -1;
        Stop;
    F184:
        D307 C 4;
        Goto F185;
    F185:
        D307 D 4;
        Goto F186;
    F186:
        D307 E 4;
        Goto F187;
    F187:
        D307 F 4;
        Goto F188;
    F188:
        D307 G 4;
        Goto F189;
    F189:
        D307 H 4;
        Goto F190;
    F190:
        D307 I 4;
        Goto F191;
    F191:
        D307 J 4;
        Goto F192;
    F192:
        D307 K 4;
        Goto F193;
    F193:
        D307 L 4;
        Goto F194;
    F194:
        D307 M -1;
        Stop;
    F195:
        D307 N 1;
        Goto F196;
    F196:
        D307 O 1;
        Goto F197;
    F197:
        D307 P 1;
        Goto F198;
    F198:
        D307 Q 1;
        Goto F199;
    F199:
        D307 R 1;
        Goto F200;
    F200:
        D307 S 1;
        Goto F201;
    F201:
        D307 T 1;
        Goto F202;
    F202:
        D307 U 1;
        Goto F203;
    F203:
        D307 V 1;
        Goto F204;
    F204:
        D307 W 1;
        Goto F205;
    F205:
        D307 X 1;
        Goto F206;
    F206:
        D307 Y 1;
        Goto F207;
    F207:
        D307 Z 1;
        Goto F208;
    F208:
        D308 A 1;
        Goto F209;
    F209:
        D308 B 1;
        Goto F210;
    F210:
        D308 C 1;
        Goto F211;
    F211:
        D308 D 1;
        Goto F212;
    F212:
        D308 E 1;
        Goto F213;
    F213:
        D308 F 1;
        Goto F214;
    F214:
        D308 G 1;
        Goto F215;
    F215:
        D308 H 1;
        Goto F216;
    F216:
        D308 I 1;
        Goto F217;
    F217:
        D308 J 1;
        Goto F218;
    F218:
        D308 K 1;
        Goto F219;
    F219:
        D308 L 1;
        Goto F220;
    F220:
        D308 M 1;
        Goto F221;
    F221:
        D308 N 1;
        Goto F222;
    F222:
        D308 O 1;
        Goto F223;
    F223:
        D308 P 1;
        Goto F224;
    F224:
        D308 Q 1;
        Goto F225;
    F225:
        D308 R 1;
        Goto F226;
    F226:
        D308 S 1;
        Goto F227;
    F227:
        D308 T 1;
        Goto F228;
    F228:
        D308 U 1;
        Goto F229;
    F229:
        D308 V 1;
        Goto F230;
    F230:
        D308 W -1;
        Stop;
    F231:
        D308 X 1;
        Goto F232;
    F232:
        D308 Y 1;
        Goto F233;
    F233:
        D308 Z 1;
        Goto F234;
    F234:
        D309 A 1;
        Goto F235;
    F235:
        D309 B 1;
        Goto F236;
    F236:
        D309 C 1;
        Goto F237;
    F237:
        D309 D 1;
        Goto F238;
    F238:
        D309 E 1;
        Goto F239;
    F239:
        D309 F 1;
        Goto F240;
    F240:
        D309 G 1;
        Goto F241;
    F241:
        D309 H 1;
        Goto F242;
    F242:
        D309 I 1;
        Goto F243;
    F243:
        D309 J 1;
        Goto F244;
    F244:
        D309 K 1;
        Goto F245;
    F245:
        D309 L 1;
        Goto F246;
    F246:
        D309 M 1;
        Goto F247;
    F247:
        D309 N 1;
        Goto F248;
    F248:
        D309 O 1;
        Goto F249;
    F249:
        D309 P 1;
        Goto F250;
    F250:
        D309 Q 1;
        Goto F251;
    F251:
        D309 R 1;
        Goto F252;
    F252:
        D309 S 1;
        Goto F253;
    F253:
        D309 T 1;
        Goto F254;
    F254:
        D309 U 1;
        Goto F255;
    F255:
        D309 V 1;
        Goto F256;
    F256:
        D309 W 1;
        Goto F257;
    F257:
        D309 X 1;
        Goto F258;
    F258:
        D309 Y 1;
        Goto F259;
    F259:
        D309 Z 1;
        Goto F260;
    F260:
        D30A A 1;
        Goto F261;
    F261:
        D30A B 1;
        Goto F262;
    F262:
        D30A C 1;
        Goto F263;
    F263:
        D30A D 1;
        Goto F264;
    F264:
        D30A E 1;
        Goto F265;
    F265:
        D30A F 1;
        Goto F266;
    F266:
        D30A G -1;
        Stop;
    F267:
        D30A H -1;
        Stop;
    F268:
        D30A I 5;
        Goto F269;
    F269:
        D30A J 5;
        Goto F270;
    F270:
        D30A K 5;
        Goto F271;
    F271:
        D30A L 5;
        Goto F272;
    F272:
        D30A M 5;
        Goto F273;
    F273:
        D30A N 5;
        Goto F274;
    F274:
        D30A O 5;
        Goto F275;
    F275:
        D30A P 5;
        Goto F276;
    F276:
        D30A Q 5;
        Goto F277;
    F277:
        D30A R 5;
        Goto F278;
    F278:
        D30A S 5;
        Goto F279;
    F279:
        D30A T 5;
        Goto F280;
    F280:
        D30A U 5;
        Goto F281;
    F281:
        D30A V 5;
        Goto F268;
    F282:
        D30A W 1;
        Goto F283;
    F283:
        D30A X 1;
        Goto F284;
    F284:
        D30A Y 1;
        Goto F285;
    F285:
        D30A Z 1;
        Goto F286;
    F286:
        D30B A 1;
        Goto F287;
    F287:
        D30B B 1;
        Goto F288;
    F288:
        D30B C 1;
        Goto F289;
    F289:
        D30B D 1;
        Goto F282;
    F290:
        D30B E 1;
        Goto F291;
    F291:
        D30B F 1;
        Goto F292;
    F292:
        D30B G 1;
        Goto F293;
    F293:
        D30B H 1;
        Goto F294;
    F294:
        D30B I 1;
        Goto F295;
    F295:
        D30B J 1;
        Goto F296;
    F296:
        D30B K 1;
        Goto F297;
    F297:
        D30B L 1;
        Goto F298;
    F298:
        D30B M 1;
        Goto F299;
    F299:
        D30B N 1;
        Goto F300;
    F300:
        D30B O 1;
        Goto F301;
    F301:
        D30B P 1;
        Goto F290;
    F302:
        D30B Q 1;
        Goto F303;
    F303:
        D30B R 1;
        Goto F304;
    F304:
        D30B S 1;
        Goto F305;
    F305:
        D30B T 1;
        Goto F306;
    F306:
        D30B U 1;
        Goto F307;
    F307:
        D30B V 1;
        Goto F308;
    F308:
        D30B W 1;
        Goto F309;
    F309:
        D30B X 1;
        Goto F310;
    F310:
        D30B Y 1;
        Goto F311;
    F311:
        D30B Z 1;
        Goto F312;
    F312:
        D30C A 1;
        Goto F313;
    F313:
        D30C B 1;
        Goto F314;
    F314:
        D30C C 1;
        Goto F315;
    F315:
        D30C D 1;
        Goto F316;
    F316:
        D30C E 1;
        Goto F317;
    F317:
        D30C F 1;
        Goto F318;
    F318:
        D30C G 1;
        Goto F319;
    F319:
        D30C H 1;
        Goto F320;
    F320:
        D30C I 1;
        Goto F321;
    F321:
        D30C J 1;
        Goto F322;
    F322:
        D30C K 1;
        Goto F323;
    F323:
        D30C L 1;
        Goto F324;
    F324:
        D30C M 1;
        Goto F325;
    F325:
        D30C N 1;
        Goto F326;
    F326:
        D30C O 1;
        Goto F327;
    F327:
        D30C P 1;
        Goto F328;
    F328:
        D30C Q 1;
        Goto F329;
    F329:
        D30C R 1;
        Goto F330;
    F330:
        D30C S 1;
        Goto F331;
    F331:
        D30C T 1;
        Goto F332;
    F332:
        D30C U 1;
        Goto F333;
    F333:
        D30C V 1;
        Goto F334;
    F334:
        D30C W 1;
        Goto F335;
    F335:
        D30C X 1;
        Goto F336;
    F336:
        D30C Y 1;
        Goto F337;
    F337:
        D30C Z -1;
        Stop;
    F338:
        D30D A 1;
        Goto F339;
    F339:
        D30D B 1;
        Goto F340;
    F340:
        D30D C 1;
        Goto F341;
    F341:
        D30D D 1;
        Goto F342;
    F342:
        D30D E 1;
        Goto F343;
    F343:
        D30D F 1;
        Goto F344;
    F344:
        D30D G 1;
        Goto F345;
    F345:
        D30D H 1;
        Goto F346;
    F346:
        D30D I 1;
        Goto F347;
    F347:
        D30D J 1;
        Goto F348;
    F348:
        D30D K 1;
        Goto F349;
    F349:
        D30D L 1;
        Goto F350;
    F350:
        D30D M 1;
        Goto F351;
    F351:
        D30D N 1;
        Goto F352;
    F352:
        D30D O 1;
        Goto F353;
    F353:
        D30D P 1;
        Goto F354;
    F354:
        D30D Q 1;
        Goto F355;
    F355:
        D30D R 1;
        Goto F356;
    F356:
        D30D S 1;
        Goto F357;
    F357:
        D30D T 1;
        Goto F358;
    F358:
        D30D U 1;
        Goto F359;
    F359:
        D30D V 1;
        Goto F360;
    F360:
        D30D W 1;
        Goto F361;
    F361:
        D30D X 1;
        Goto F362;
    F362:
        D30D Y 1;
        Goto F363;
    F363:
        D30D Z 1;
        Goto F364;
    F364:
        D30E A 1;
        Goto F365;
    F365:
        D30E B 1;
        Goto F366;
    F366:
        D30E C 1;
        Goto F367;
    F367:
        D30E D 1;
        Goto F368;
    F368:
        D30E E 1;
        Goto F369;
    F369:
        D30E F 1;
        Goto F370;
    F370:
        D30E G 1;
        Goto F371;
    F371:
        D30E H 1;
        Goto F372;
    F372:
        D30E I 1;
        Goto F373;
    F373:
        D30E J -1;
        Stop;
    F374:
        D30E K -1;
        Stop;
    }
}
