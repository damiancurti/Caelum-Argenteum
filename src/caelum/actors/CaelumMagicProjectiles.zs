// Proyectil elemental guiado compartido por los cuatro actores de prueba.
// Usa A_SeekerMissile, la misma primitiva nativa empleada por el Libro.
class CaelumActorHomingElementalProjectile : CaelumActorProjectile
{
    int CaelumLifetimeTicks;

    Default
    {
        Radius 4;
        Height 4;
        Speed 20;
        Damage 1;
        DamageType "CaelumMagicTest";
        Projectile;
        +SEEKERMISSILE
        +INTERPOLATEANGLES
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        return GetCaelumPreparedDamage(Max(1, damage));
    }

    void UpdateElementSprite()
    {
        if (!CaelumElementalPayloadPrepared) { return; }
        String visual = "XFIR";
        if (CaelumEssenceType == CaelumConstants.ESSENCE_FIRE)
            visual = CaelumSecondaryElement ? "XLIT" : "XFIR";
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_WATER)
            visual = CaelumSecondaryElement ? "XICE" : "XWAT";
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_EARTH)
            visual = CaelumSecondaryElement ? "XVSN" : "XERT";
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_WIND)
            visual = CaelumSecondaryElement ? "CELH" : "XAIR";
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_QUINTESSENCE)
            visual = "XQUI";
        sprite = GetSpriteIndex(visual);
        frame = visual == "CELH" ? (level.time / 2) % 12 : 0;
    }

    action void A_CaelumActorSeek()
    {
        // El proyectil nace con Target = lanzador. El objetivo del lanzador es
        // la referencia más robusta para estos actores de prueba.
        if (invoker.Tracer == null && invoker.Target != null)
            invoker.Tracer = invoker.Target.Target;
        if (invoker.Tracer != null && invoker.Tracer.health > 0)
            invoker.A_SeekerMissile(10, 30);
    }

    override void Tick()
    {
        Super.Tick();

        // Un proyectil guiado que pierde su blanco no puede permanecer para
        // siempre en el campo de pruebas. El límite evita acumulaciones
        // silenciosas cuando varios recintos se despiertan por un disparo.
        CaelumLifetimeTicks++;
        if (CaelumLifetimeTicks >= 350)
        {
            Destroy();
            return;
        }

        UpdateElementSprite();
    }

    States
    {
    Spawn:
        XFIR A 1 Bright A_CaelumActorSeek;
        Loop;
    Death:
        XFIR A 2 Bright;
        Stop;
    }
}
