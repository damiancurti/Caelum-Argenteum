// Blanco inmóvil y resistente para repetir las prácticas de combate.
class CaelumTrainingDummy : Actor
{
    override int TakeSpecialDamage(Actor inflictor,Actor source,int damage,Name mod)
    {return Max(0,int(Super.TakeSpecialDamage(inflictor,source,damage,mod)
        *CaelumRally.DamageFactor(self,source)+0.5));}

    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        if(flags & DMG_FORCED)damage=Max(0,int(damage*CaelumRally.DamageFactor(self,source)+0.5));
        return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }

    Default
    {
        Health 1000000;
        // Colisión histórica independiente del modelo 3D y del sprite de respaldo.
        Radius 21;
        Height 72;
        Mass 10000;
        PainChance 0;
        Speed 0;
        +SOLID
        +SHOOTABLE
        +NOBLOOD
        +NODAMAGETHRUST
        +NOTELEPORT
        +DONTSPLASH
    }


    States
    {
    Spawn:
        CDMY A -1;
        Stop;
    Death:
        CDMY A -1;
        Stop;
    }
}
