// Presentación modular 4.36.0i. Pivotes absolutos y lienzos NoTrim;
// los callbacks de daño y munición permanecen en el arma real.
class CaelumFirstPersonLayerFrames : Actor
{
    States (Weapon, Overlay)
    {
    Weapon_4_1_0:
        D021 A -1;
        Stop;

    Weapon_4_2_0:
        D022 A -1;
        Stop;

    Weapon_4_3_0:
        D023 A -1;
        Stop;

    Weapon_5_1_0:
        D031 A -1;
        Stop;

    Weapon_5_2_0:
        D032 A -1;
        Stop;

    Weapon_5_3_0:
        D033 A -1;
        Stop;

    Weapon_0_1_0:
        D051 A -1;
        Stop;

    Weapon_0_2_0:
        D052 A -1;
        Stop;

    Weapon_0_3_0:
        D053 A -1;
        Stop;

    Weapon_7_1_0:
        D061 A -1;
        Stop;

    Weapon_7_2_0:
        D062 A -1;
        Stop;

    Weapon_7_3_0:
        D063 A -1;
        Stop;

    Weapon_10_1_0:
        D091 A -1;
        Stop;

    Weapon_10_2_0:
        D092 A -1;
        Stop;

    Weapon_10_3_0:
        D093 A -1;
        Stop;

    Weapon_11_1_0:
        D101 A -1;
        Stop;

    Weapon_11_2_0:
        D102 A -1;
        Stop;

    Weapon_11_3_0:
        D103 A -1;
        Stop;

    Weapon_12_1_0:
        D111 A -1;
        Stop;

    Weapon_12_2_0:
        D112 A -1;
        Stop;

    Weapon_12_3_0:
        D113 A -1;
        Stop;

    Weapon_14_1_0:
        D161 A -1;
        Stop;

    Weapon_14_2_0:
        D162 A -1;
        Stop;

    Weapon_14_3_0:
        D163 A -1;
        Stop;

    Weapon_14_1_1:
        D161 B -1;
        Stop;

    Weapon_14_2_1:
        D162 B -1;
        Stop;

    Weapon_14_3_1:
        D163 B -1;
        Stop;

    Weapon_14_1_2:
        D161 C -1;
        Stop;

    Weapon_14_2_2:
        D162 C -1;
        Stop;

    Weapon_14_3_2:
        D163 C -1;
        Stop;

    Weapon_15_1_0:
        D171 A -1;
        Stop;

    Weapon_15_2_0:
        D172 A -1;
        Stop;

    Weapon_15_3_0:
        D173 A -1;
        Stop;

    Weapon_15_1_1:
        D171 B -1;
        Stop;

    Weapon_15_2_1:
        D172 B -1;
        Stop;

    Weapon_15_3_1:
        D173 B -1;
        Stop;

    Weapon_15_1_2:
        D171 C -1;
        Stop;

    Weapon_15_2_2:
        D172 C -1;
        Stop;

    Weapon_15_3_2:
        D173 C -1;
        Stop;

    Weapon_16_1_0:
        D181 A -1;
        Stop;

    Weapon_16_2_0:
        D182 A -1;
        Stop;

    Weapon_16_3_0:
        D183 A -1;
        Stop;

    Weapon_16_1_1:
        D181 B -1;
        Stop;

    Weapon_16_2_1:
        D182 B -1;
        Stop;

    Weapon_16_3_1:
        D183 B -1;
        Stop;

    Weapon_16_1_2:
        D181 C -1;
        Stop;

    Weapon_16_2_2:
        D182 C -1;
        Stop;

    Weapon_16_3_2:
        D183 C -1;
        Stop;

    Weapon_2_1_0:
        D191 A -1;
        Stop;

    Weapon_2_2_0:
        D192 A -1;
        Stop;

    Weapon_2_3_0:
        D193 A -1;
        Stop;

    Weapon_2_1_1:
        D191 B -1;
        Stop;

    Weapon_2_2_1:
        D192 B -1;
        Stop;

    Weapon_2_3_1:
        D193 B -1;
        Stop;

    Weapon_2_1_2:
        D191 C -1;
        Stop;

    Weapon_2_2_2:
        D192 C -1;
        Stop;

    Weapon_2_3_2:
        D193 C -1;
        Stop;

    Hand_0:
        DH00 A -1;
        Stop;

    Hand_3:
        DH03 A -1;
        Stop;

    Hand_4:
        DH04 A -1;
        Stop;

    Hand_5:
        DH05 A -1;
        Stop;

    Hand_6:
        DH06 A -1;
        Stop;

    Hand_7:
        DH07 A -1;
        Stop;

    Hand_8:
        DH08 A -1;
        Stop;

    Hand_9:
        DH09 A -1;
        Stop;

    Hand_10:
        DH10 A -1;
        Stop;

    BowString:
        EBST A -1;
        Stop;

    BowArrow:
        EBAN A -1;
        Stop;

    Hand_11:
        DH11 A -1;
        Stop;

    Weapon_8_1_0:
        D071 A -1;
        Stop;
    Weapon_8_2_0:
        D072 A -1;
        Stop;
    Weapon_8_3_0:
        D073 A -1;
        Stop;

    // Estados nuevos al final para conservar los índices de los guardados.
    Shaft_7_1:
        GAX1 A -1;
        Stop;
    Shaft_7_2:
        GAX2 A -1;
        Stop;
    Shaft_7_3:
        GAX3 A -1;
        Stop;
    Shaft_12_1:
        GHB1 A -1;
        Stop;
    Shaft_12_2:
        GHB2 A -1;
        Stop;
    Shaft_12_3:
        GHB3 A -1;
        Stop;
    Hand_12:
        DH12 A -1;
        Stop;
    FlailHandle_1:
        GFS1 A -1;
        Stop;
    FlailChain_1:
        GFC1 A -1;
        Stop;
    FlailHandle_2:
        GFS2 A -1;
        Stop;
    FlailChain_2:
        GFC2 A -1;
        Stop;
    FlailHandle_3:
        GFS3 A -1;
        Stop;
    FlailChain_3:
        GFC3 A -1;
        Stop;
    }
}

class CaelumFirstPersonLayers : Object play
{
    static bool Handles(int kind)
    {
        return kind==0 || kind==2 || kind==4 || kind==5 || kind==7 || kind==8
            || kind==10 || kind==11 || kind==12 || kind==14 || kind==15 || kind==16;
    }

    static State Pose(int kind, int tier, int phase)
    {
        return GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString(
            String.Format("Weapon_%d_%d_%d",kind,Clamp(tier,1,3),phase));
    }

    static Vector2 Pivot(int index)
    {
        switch(index)
        {
            case 36: return (85.000000000, 150.000000000);
            case 39: return (85.000000000, 150.000000000);
            case 42: return (85.000000000, 150.000000000);
            case 45: return (85.000000000, 158.000000000);
            case 48: return (85.000000000, 158.000000000);
            case 51: return (85.000000000, 158.000000000);
            case 0: return (235.000000000, 158.000000000);
            case 3: return (235.000000000, 158.000000000);
            case 6: return (235.000000000, 158.000000000);
            case 63: return (77.000000000, 118.000000000);
            case 66: return (77.000000000, 118.000000000);
            case 69: return (77.000000000, 118.000000000);
            case 72: return (235.000000000, 158.000000000);
            case 75: return (235.000000000, 158.000000000);
            case 78: return (235.000000000, 158.000000000);
            case 90: return (42.639593909, 131.979695431);
            case 93: return (37.225042301, 131.979695431);
            case 96: return (31.472081218, 131.979695431);
            case 99: return (85.000000000, 150.000000000);
            case 102: return (85.000000000, 150.000000000);
            case 105: return (85.000000000, 150.000000000);
            case 108: return (76.000000000, 104.000000000);
            case 111: return (76.000000000, 104.000000000);
            case 114: return (76.000000000, 104.000000000);
            case 126: return (101.333333334, 85.000000000);
            case 127: return (101.333333334, 85.000000000);
            case 128: return (101.333333334, 85.000000000);
            case 129: return (71.000000000, 85.000000000);
            case 130: return (71.000000000, 85.000000000);
            case 131: return (71.000000000, 85.000000000);
            case 132: return (54.000000000, 85.000000000);
            case 133: return (54.000000000, 85.000000000);
            case 134: return (54.000000000, 85.000000000);
            case 135: return (113.469387756, 104.081632653);
            case 136: return (113.469387756, 104.081632653);
            case 137: return (113.469387756, 104.081632653);
            case 138: return (88.163265306, 104.081632653);
            case 139: return (88.163265306, 104.081632653);
            case 140: return (88.163265306, 104.081632653);
            case 141: return (75.510204082, 104.081632653);
            case 142: return (75.510204082, 104.081632653);
            case 143: return (75.510204082, 104.081632653);
            case 144: return (166.000000000, 170.000000000);
            case 145: return (166.000000000, 170.000000000);
            case 146: return (166.000000000, 170.000000000);
            case 147: return (166.000000000, 170.000000000);
            case 148: return (166.000000000, 170.000000000);
            case 149: return (166.000000000, 170.000000000);
            case 150: return (166.000000000, 170.000000000);
            case 151: return (166.000000000, 170.000000000);
            case 152: return (166.000000000, 170.000000000);
            case 18: return (165.000000000, 174.000000000);
            case 19: return (165.000000000, 174.000000000);
            case 20: return (165.000000000, 174.000000000);
            case 21: return (165.000000000, 174.000000000);
            case 22: return (165.000000000, 174.000000000);
            case 23: return (165.000000000, 174.000000000);
            case 24: return (165.000000000, 174.000000000);
            case 25: return (165.000000000, 174.000000000);
            case 26: return (165.000000000, 174.000000000);
            case 200: return (235.000000000, 158.000000000);
            case 203: return (141.000000000, 139.000000000);
            case 204: return (161.000000000, 168.000000000);
            case 205: return (184.000000000, 174.000000000);
            case 206: return (142.000000000, 153.000000000);
            case 207: return (208.000000000, 170.000000000);
            case 208: return (65.000000000, 31.875000000);
            case 209: return (84.000000000, 125.000000000);
            case 210: return (236.000000000, 125.000000000);
            case 211: return (23.000000000, 26.000000000);
            case 212: return (141.000000000, 139.000000000);
        }
        return (0,0);
    }

    static void Clear(CaelumPlayer user)
    { user.A_ClearOverlays(46,53); }

    static void Place(CaelumPlayer user, int layer, State pose, Vector2 position,
        Vector2 pivot, double size, double rotation, bool percent=false)
    {
        if(pose==null)return;
        bool fresh=user.player.FindPSprite(layer)==null;
        let view=user.player.GetPSprite(layer);
        if(view==null)return;
        if(view.CurState!=pose)view.SetState(pose);
        view.bAddWeapon=false; view.bAddBob=true; view.bPivotPercent=percent;
        view.bPowDouble=false; view.bCVarFast=false; view.bInterpolate=true;
        view.baseScale=(1.0,1.2); view.HAlign=0; view.VAlign=0;
        view.bFlip=false; view.bMirror=false;
        view.Coord0=(0,0); view.Coord1=(0,0);
        view.Coord2=(0,0); view.Coord3=(0,0);
        view.scale=(size,size); view.pivot=pivot;
        view.x=position.X; view.y=position.Y; view.rotation=rotation;
        if(fresh){view.oldx=view.x;view.oldy=view.y;}
    }

    static void Hand(CaelumPlayer user,int layer,int hand,Vector2 anchor,
        Vector2 relative,double size,double rotation)
    {
        vector2 turned=Turn(relative,rotation);
        State pose=GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString(
            String.Format("Hand_%d",hand));
        Place(user,layer,pose,anchor+turned,Pivot(200+hand),size,rotation,false);
    }

    static Vector2 Turn(Vector2 point,double rotation)
    {
        // GZDoom gira antihorario en pantalla. baseScale.Y=1.2 se aplica
        // antes del giro nativo: convertir también los desplazamientos.
        return (point.X*Cos(rotation)+point.Y*1.2*Sin(rotation),
            -point.X/1.2*Sin(rotation)+point.Y*Cos(rotation));
    }

    static Vector2 AxialOffset(Vector2 point,Vector2 axis,double stretch)
    {
        // Extender sólo por el eje del asta, sin ensancharla ni estirar la hoja.
        return axis*((point.X*axis.X+point.Y*axis.Y)*(stretch-1.0));
    }

    static void SegmentedWeapon(CaelumPlayer user,int kind,int tier,
        Vector2 grip,double size,double rotation)
    {
        bool halberd=kind==12;
        vector2 shaftPivot=halberd?(85,150):(85,158);
        vector2 joint=halberd?(76,104):(77,118);
        double stretch=halberd?1.80:1.0;
        State shaft=GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString(
            String.Format("Shaft_%d_%d",kind,Clamp(tier,1,3)));
        Place(user,48,shaft,grip,shaftPivot,size,rotation,false);
        let view=user.player.FindPSprite(48);
        if(halberd && view!=null)
        {
            vector2 axis=joint-shaftPivot;
            axis/=axis.Length();
            view.Coord0=AxialOffset((0,0)-shaftPivot,axis,stretch);
            view.Coord1=AxialOffset((0,200)-shaftPivot,axis,stretch);
            view.Coord2=AxialOffset((320,0)-shaftPivot,axis,stretch);
            view.Coord3=AxialOffset((320,200)-shaftPivot,axis,stretch);
        }
        vector2 headPosition=grip+Turn((joint-shaftPivot)*(size*stretch),rotation);
        Place(user,50,Pose(kind,tier,0),headPosition,joint,
            size*(halberd?1.0:1.50),rotation,false);
    }

    static void BowLine(CaelumPlayer user,int layer,Vector2 from,Vector2 to)
    {
        vector2 delta=to-from;
        double length=Max(0.001,delta.Length());
        vector2 side=(delta.Y/length*0.40,-delta.X/length*0.40);
        State pose=GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString("BowString");
        Place(user,layer,pose,from,(0,0),1.0,0,false);
        let view=user.player.FindPSprite(layer);
        if(view==null)return;
        // Cuadrilátero entre anclas: no escalar X después de una rotación.
        // Coord0/1/2/3 son TL/BL/TR/BR del rectángulo de 1×1.
        view.Coord0=-side;
        view.Coord1=delta-side-(0,1);
        view.Coord2=side-(1,0);
        view.Coord3=delta+side-(1,1);
    }

    // Las palas y sus anclas proceden de SPRITES.json; la cuerda sigue los dos
    // extremos y la mano que tensa. Las imágenes no tienen una cuerda duplicada.
    static Vector2 BowTip(int kind,int tier,bool lower)
    {
        tier=Clamp(tier,1,3);
        if(kind==14)return lower?(tier==2?101:102,436):(tier==3?102:101,-446);
        return lower?(tier==1?95:tier==2?97:98,456):(tier==1?88:tier==2?90:91,-455);
    }

    static void BowPresentation(CaelumPlayer user,int kind,int tier,int phase,
        Vector2 grip,double size,double rotation)
    {
        double unit=size/(kind==14?6.0:4.9);
        double flexX=phase==1?1.15:1.0,flexY=phase==1?0.97:1.0;
        vector2 top=BowTip(kind,tier,false),bottom=BowTip(kind,tier,true);
        top=Turn(top*unit,rotation); bottom=Turn(bottom*unit,rotation);
        top=grip+(top.X*flexX,top.Y*flexY);
        bottom=grip+(bottom.X*flexX,bottom.Y*flexY);
        vector2 nock=phase==2?(top+bottom)*0.5:grip+Turn((phase==1?49:29,18),rotation);
        BowLine(user,46,top,nock);BowLine(user,47,nock,bottom);
        if(phase==2){user.A_ClearOverlays(53,53);return;}
        vector2 guide=grip+Turn((0,-8),rotation);
        vector2 direction=guide-nock;
        State arrow=GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString("BowArrow");
        // La flecha completa queda delante del arco, del pulgar y de la mano.
        double sourceAngle=VectorAngle(-1075,-1134*1.2);
        Place(user,53,arrow,nock,(1145.0/19.0,1155.0/19.0),1.0,
            sourceAngle-VectorAngle(direction.X,direction.Y*1.2),false);
    }

    static void Flail(CaelumPlayer user,int tier,Vector2 grip,double rotation,double chainTurn)
    {
        tier=Clamp(tier,1,3);
        double handleAngle=rotation-39.5;
        vector2 joint=(213,61), originalGrip=(235,158);
        // Hundir medio tramo expuesto bajo el guante por el eje del mango.
        vector2 handlePosition=grip-Turn((joint-originalGrip)*0.50,handleAngle);
        vector2 chainPosition=handlePosition+Turn(joint-originalGrip,handleAngle);
        let frames=GetDefaultByType("CaelumFirstPersonLayerFrames");
        State handle=frames.FindStateByString(String.Format("FlailHandle_%d",tier));
        State chain=frames.FindStateByString(String.Format("FlailChain_%d",tier));
        // Eje anilla-centro de bola vertical; no hereda el giro del mango.
        double hangingAngle=VectorAngle(-29,77*1.2)-90.0;
        Place(user,46,chain,chainPosition,joint,1.0,hangingAngle+chainTurn,false);
        Place(user,50,handle,handlePosition,originalGrip,1.0,handleAngle,false);
    }

    static void Draw(CaelumPlayer user,int kind,int tier,int phase,
        double dx,double dy,double rotation,double chainTurn=0)
    {
        // Sólo crece el arma: las manos conservan las proporciones de la daga.
        bool ranged=kind==2 || kind==14 || kind==15 || kind==16;
        bool bow=kind==14 || kind==15;
        if(!bow){user.A_ClearOverlays(kind==8?47:46,47);user.A_ClearOverlays(53,53);}
        bool large=kind==10 || kind==11 || kind==12;
        bool rightLeaning=kind==4 || kind==5 || kind==7 || kind==11 || kind==12;
        double size=kind==0?1.20:kind==7?1.18:kind==10?1.38:kind==11?1.32:kind==12?1.13:ranged?0.82:1.0;
        vector2 grip=bow?(141,160):ranged?(165,210):kind==10?(235,182):kind==12?(222,180):kind==8?(200,158):large?(235,172):(kind==0 || rightLeaning)?(235,164):(235,158);
        grip+=(dx,dy);
        if(ranged)
        {
            if(bow)
            {
                // Ambas manos provienen del conjunto original; la izquierda
                // se dibuja detrás de la derecha, con el mismo tamaño de guante.
                // Índice detrás; pulgar y falanges de los otros dedos delante.
                user.A_ClearOverlays(48,48);
                Hand(user,49,3,grip,(0,0),0.85,rotation);
                Hand(user,51,12,grip,(0,0),0.85,rotation);
                Hand(user,52,phase==2?7:4,grip,phase==2?(55,24):phase==1?(49,18):(29,18),1.0,rotation);
            }
            else
            {
                // Las dos manos quedan bajo la culata; la izquierda, centrada.
                user.A_ClearOverlays(51,52);
                Hand(user,48,6,grip,(-8,-25),0.88,rotation);
                Hand(user,49,5,grip,(23,-27),0.88,rotation);
            }
        }
        else
        {
            // El mango separado usa 48; no recrearlo cada tic para interpolar.
            user.A_ClearOverlays(49,49);
            if(kind!=7 && kind!=12)user.A_ClearOverlays(48,48);
            Hand(user,52,0,grip,(0,0),1.0,rotation);
            // La izquierda sostiene el tramo inferior, sin tapar la derecha.
            if(large)Hand(user,51,3,grip,(0,24),0.85,rotation);
            else user.A_ClearOverlays(51,51);
        }
        // Signo comprobado en hw_weapon.cpp de GZDoom 4.14.2: negativo
        // lleva la punta hacia la derecha; positivo, hacia la izquierda.
        // Mangual: -62° + 22,5° = -39,5°; su cadena va en una capa aparte.
        // Su agarre se centra para mantener toda la cadena dentro del encuadre.
        double weaponRotation=rotation+(rightLeaning?-28.0:kind==8?-39.5:0.0);
        vector2 weaponGrip=grip;
        if(rightLeaning)weaponGrip+=(4,3);
        if(kind==8)Flail(user,tier,grip,rotation,chainTurn);
        else if(kind==7 || kind==12)
            SegmentedWeapon(user,kind,tier,weaponGrip,size,weaponRotation);
        else
            Place(user,50,Pose(kind,tier,phase),weaponGrip,Pivot(kind*9+(Clamp(tier,1,3)-1)*3+phase),size,weaponRotation);
        if(bow)
        {
            let body=user.player.FindPSprite(50);
            if(body!=null)body.scale=(size*(phase==1?1.15:1.0),size*(phase==1?0.97:1.0));
            BowPresentation(user,kind,tier,phase,grip,size,rotation);
        }
    }
}
