// Actores de presentación para los tres personajes incorporados en 4.29.0aq.
// El paquete gráfico no define estadísticas, facciones, colisiones ni botín.
// Por eso estas clases exponen arte y secuencias sin adelantar balance de 4.30.
class CaelumCharacterPresentationActor : Actor abstract
{
    Default
    {
        Radius 1;
        Height 1;
        // Cubre el semiancho visible de los lienzos 256×256 a Scale 0.3125.
        RenderRadius 40;
        Speed 0;
        +NOBLOCKMAP
        +CANNOTPUSH
        +DONTTHRUST
        +NOBLOOD
        +NOTELEPORT
        RenderStyle "Normal";
    }
}

class CaelumPalomo : CaelumCharacterPresentationActor
{
    Default
    {
        Tag "$CA_PALOMO_NAME";
        // Escala común del paquete: los humanoides quedan alrededor de 72 MU.
        Scale 0.3125;
    }

    States
    {
    Spawn:
        PALM A -1;
        Stop;
    Walk:
        PALM BC 4;
        Loop;
    Talk:
        PALM D -1;
        Stop;
    Laugh:
        PLLF ABCBD 5;
        Loop;
    Anger:
        PLAG ABC 6;
        PLAG D -1;
        Stop;
    Joy:
        PLJY ABCD 6;
        Loop;
    Surprise:
        PLSP ABC 4;
        PLSP C 4;
        PLSP D -1;
        Stop;
    Sadness:
        PLSD ABC 9;
        PLSD D -1;
        Stop;
    Thought:
        PLTH ABCD 7;
        Loop;
    }
}

class CaelumMandinga : CaelumCharacterPresentationActor
{
    Default
    {
        Tag "$CA_MANDINGA_NAME";
        Scale 0.3125;
    }

    States
    {
    Spawn:
        MNDG A -1;
        Stop;
    Walk:
        MNDG BC 4;
        Loop;
    Attack:
        MNDG D 6;
        MNDG E 4;
        Goto Spawn;
    Pain:
        MNDG F 5;
        Goto Spawn;
    Death:
        MNDG GHIJK 5;
        MNDG L -1;
        Stop;
    }
}

class CaelumZupayColossus : CaelumCharacterPresentationActor
{
    Default
    {
        Tag "$CA_ZUPAY_COLOSSUS_NAME";
        // 208 px desde el pivote al borde × 0,3125.
        RenderRadius 65;
        // 384 px visibles × 0,3125 = 120 MU: 3 m frente a humano de 1,8 m.
        Scale 0.3125;
    }

    States
    {
    Spawn:
        ZUPY A -1;
        Stop;
    Walk:
        ZUPY BC 4;
        Loop;
    Attack:
        ZUPY D 6;
        ZUPY E 4;
        Goto Spawn;
    Pain:
        ZUPY F 5;
        Goto Spawn;
    Death:
        ZUPY GHIJK 5;
        ZUPY L -1;
        Stop;
    Lift:
        ZUPY MN 6;
        ZUPY O -1;
        Stop;
    Throw:
        ZUPY P 6;
        ZUPY Q 4;
        // El proyectil nacerá aquí, en Q→R, cuando se definan roca y balance.
        ZUPY R 5;
        Goto Spawn;
    }
}
