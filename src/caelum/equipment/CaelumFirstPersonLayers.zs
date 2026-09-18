// Anclas independientes para modificar orientación, escala y agarre sin
// duplicar el daño ni retocar los PNG aprobados.
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
    }
}

class CaelumFirstPersonLayers : Object play
{
    static bool Handles(int kind)
    {
        return kind==0 || kind==2 || kind==4 || kind==5 || kind==7
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
            case 36: return (0.776119403, 0.920000000);
            case 39: return (0.782608696, 0.920000000);
            case 42: return (0.782608696, 0.920000000);
            case 45: return (0.674418605, 0.818181818);
            case 48: return (0.674418605, 0.818181818);
            case 51: return (0.690476190, 0.818181818);
            case 0: return (0.271186441, 0.826086957);
            case 3: return (0.275862069, 0.826086957);
            case 6: return (0.275862069, 0.826086957);
            case 63: return (0.759259259, 0.792000000);
            case 66: return (0.759259259, 0.792000000);
            case 69: return (0.759259259, 0.792000000);
            case 90: return (0.375000000, 0.773006135);
            case 93: return (0.395833333, 0.773006135);
            case 96: return (0.387755102, 0.773006135);
            case 99: return (0.789473684, 0.740000000);
            case 102: return (0.789473684, 0.740000000);
            case 105: return (0.789473684, 0.740000000);
            case 108: return (0.742857143, 0.714285714);
            case 111: return (0.739130435, 0.717514124);
            case 114: return (0.730158730, 0.717514124);
            case 126: return (0.654794521, 0.499496475);
            case 129: return (0.301298701, 0.491592483);
            case 132: return (0.229268293, 0.501513623);
            case 127: return (0.654794521, 0.499496475);
            case 130: return (0.301298701, 0.491592483);
            case 133: return (0.229268293, 0.501513623);
            case 128: return (0.654794521, 0.499496475);
            case 131: return (0.301298701, 0.491592483);
            case 134: return (0.229268293, 0.501513623);
            case 135: return (0.494199536, 0.504056795);
            case 138: return (0.441108545, 0.503546099);
            case 141: return (0.362525458, 0.501513623);
            case 136: return (0.494199536, 0.504056795);
            case 139: return (0.441108545, 0.503546099);
            case 142: return (0.362525458, 0.501513623);
            case 137: return (0.494199536, 0.504056795);
            case 140: return (0.441108545, 0.503546099);
            case 143: return (0.362525458, 0.501513623);
            case 144: return (0.497109827, 0.797297297);
            case 147: return (0.500000000, 0.797297297);
            case 150: return (0.500000000, 0.797297297);
            case 145: return (0.500000000, 0.787234043);
            case 148: return (0.500000000, 0.787234043);
            case 151: return (0.500000000, 0.787234043);
            case 146: return (0.500000000, 0.787234043);
            case 149: return (0.502890173, 0.788732394);
            case 152: return (0.502890173, 0.788732394);
            case 18: return (0.506493506, 0.851612903);
            case 21: return (0.500000000, 0.851612903);
            case 24: return (0.506493506, 0.851612903);
            case 19: return (0.494382022, 0.850574713);
            case 22: return (0.505494505, 0.850574713);
            case 25: return (0.500000000, 0.849710983);
            case 20: return (0.500000000, 0.852760736);
            case 23: return (0.494623656, 0.852760736);
            case 26: return (0.494623656, 0.852760736);
            case 200: return (0.267441860, 0.382352941);
            case 203: return (0.808695652, 0.336956522);
            case 204: return (0.300000000, 0.418181818);
            case 205: return (0.421052632, 0.480000000);
            case 206: return (0.682242991, 0.447058824);
            case 207: return (0.425287356, 0.523809524);
            case 208: return (0.774015748, 0.471661864);
            case 209: return (0.763636364, 0.257425743);
            case 210: return (0.236363636, 0.257425743);
        }
        return (0,0);
    }

    static void Clear(CaelumPlayer user)
    { user.A_ClearOverlays(46,52); }

    static void Place(CaelumPlayer user, int layer, State pose, Vector2 position,
        Vector2 pivot, double size, double rotation, bool percent=true)
    {
        if(pose==null)return;
        bool fresh=user.player.FindPSprite(layer)==null;
        let view=user.player.GetPSprite(layer);
        if(view==null)return;
        if(view.CurState!=pose)view.SetState(pose);
        view.bAddWeapon=false; view.bAddBob=true; view.bPivotPercent=percent;
        view.bPowDouble=false; view.bCVarFast=false; view.bInterpolate=true;
        view.scale=(size,size); view.pivot=pivot;
        view.x=position.X; view.y=position.Y; view.rotation=rotation;
        if(fresh){view.oldx=view.x;view.oldy=view.y;}
    }

    static void Hand(CaelumPlayer user,int layer,int hand,Vector2 anchor,
        Vector2 relative,double size,double rotation)
    {
        vector2 turned=(relative.X*Cos(rotation)-relative.Y*Sin(rotation),
            relative.X*Sin(rotation)+relative.Y*Cos(rotation));
        State pose=GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString(
            String.Format("Hand_%d",hand));
        Place(user,layer,pose,anchor+turned,Pivot(200+hand),size,rotation,true);
    }

    static Vector2 Turn(Vector2 point,double rotation)
    {
        return (point.X*Cos(rotation)-point.Y*Sin(rotation),
            point.X*Sin(rotation)+point.Y*Cos(rotation));
    }

    static void BowLine(CaelumPlayer user,int layer,Vector2 from,Vector2 to)
    {
        vector2 delta=to-from;
        State pose=GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString("BowString");
        Place(user,layer,pose,from,(0,0),1.0,VectorAngle(delta.X,delta.Y),false);
        let view=user.player.FindPSprite(layer);
        if(view!=null)view.scale=(Max(0.001,delta.Length()),0.55);
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
        top=grip+Turn((top.X*unit*flexX,top.Y*unit*flexY),rotation);
        bottom=grip+Turn((bottom.X*unit*flexX,bottom.Y*unit*flexY),rotation);
        vector2 nock=phase==2?(top+bottom)*0.5:grip+Turn((phase==1?49:29,18),rotation);
        BowLine(user,46,top,nock);BowLine(user,47,nock,bottom);
        user.A_ClearOverlays(49,49);
        if(phase==2){user.A_ClearOverlays(48,48);return;}
        vector2 guide=grip+Turn((0,-8),rotation);
        vector2 direction=guide-nock;
        State arrow=GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString("BowArrow");
        Place(user,48,arrow,nock,(0.970216606,0.950544845),1.0,
            VectorAngle(direction.X,direction.Y)+135.0,true);
    }

    static void Draw(CaelumPlayer user,int kind,int tier,int phase,
        double dx,double dy,double rotation)
    {
        // Sólo crece el arma: las manos conservan las proporciones de la daga.
        bool ranged=kind==2 || kind==14 || kind==15 || kind==16;
        bool bow=kind==14 || kind==15;
        if(!bow)user.A_ClearOverlays(46,47);
        bool large=kind==10 || kind==11 || kind==12;
        bool rightLeaning=kind==4 || kind==7 || kind==11 || kind==12;
        double size=kind==0?1.20:kind==7?1.18:kind==10?1.38:kind==11?1.32:kind==12?1.13:ranged?0.82:1.0;
        vector2 grip=bow?(141,160):ranged?(165,210):kind==10?(235,182):large?(235,172):(kind==0 || rightLeaning)?(235,164):(235,158);
        grip+=(dx,dy);
        if(ranged)
        {
            if(bow)
            {
                // Ambas manos provienen del conjunto original; la izquierda
                // se dibuja detrás de la derecha, con el mismo tamaño de guante.
                Hand(user,51,3,grip,(0,0),0.85,rotation);
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
            user.A_ClearOverlays(48,49);
            Hand(user,52,0,grip,(0,0),1.0,rotation);
            // La izquierda sostiene el tramo inferior, sin tapar la derecha.
            if(large)Hand(user,51,3,grip,(0,24),0.85,rotation);
            else user.A_ClearOverlays(51,51);
        }
        // El reflejo mantiene la orientación de la hoja aprobada; esta rotación
        // independiente inclina el mango hacia la derecha alrededor del agarre.
        double weaponRotation=rotation+(rightLeaning?28.0:0.0);
        vector2 weaponGrip=grip;
        if(rightLeaning)weaponGrip+=(4,3);
        Place(user,50,Pose(kind,tier,phase),weaponGrip,Pivot(kind*9+(Clamp(tier,1,3)-1)*3+phase),size,weaponRotation);
        if(bow)
        {
            let body=user.player.FindPSprite(50);
            if(body!=null)body.scale=(size*(phase==1?1.15:1.0),size*(phase==1?0.97:1.0));
            BowPresentation(user,kind,tier,phase,grip,size,rotation);
        }
    }
}
