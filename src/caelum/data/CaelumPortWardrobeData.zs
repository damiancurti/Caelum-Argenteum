// #423: asignación cosmética; no concede prendas, armas ni atributos.
class CaelumPortWardrobeData : Object play
{
    const REVISION=1;
    const FACE_COUNT=4;
    const FRAME_COUNT=17;

    static int SpriteFor(Actor body,int face)
    {
        switch(face)
        {
        case 1:return body.GetSpriteIndex("V9G1");
        case 2:return body.GetSpriteIndex("V9G2");
        case 3:return body.GetSpriteIndex("V9G3");
        default:return body.GetSpriteIndex("V9G0");
        }
    }

    static int FrameFor(CaelumPortDefender body)
    {
        int f=body.frame;
        if(body.sprite==body.WardrobeCarbineSprite)return f==0?9:f<=2?9+f:f==3?12:13;
        if(body.sprite==body.WardrobeCrouchSprite)return f==0?14:f==1?15:16;
        if(body.sprite==body.WardrobeWalkSprite)return 1+f%2;
        if(body.sprite==body.WardrobeMeleeSprite)
        {
            if(f>=18)return f==18?6:f==19?7:8;
            if(f>=10)return f<=13?3:4;
            return 5;
        }
        return 0;
    }
}

// Registro nativo de los cuatro rostros. No se instancia ni añade capas/actores.
class CaelumPortWardrobeRegistry : Actor
{
    States
    {
    Spawn:
        V9G0 ABCDEFGHIJKLMNOPQ 1;
        V9G1 ABCDEFGHIJKLMNOPQ 1;
        V9G2 ABCDEFGHIJKLMNOPQ 1;
        V9G3 ABCDEFGHIJKLMNOPQ 1;
        Stop;
    }
}
