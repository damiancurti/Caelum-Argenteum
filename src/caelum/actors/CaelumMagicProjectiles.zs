// Proyectil recto y de impacto único para grupos numerosos de NPC. No busca
// blancos, no explota y no calcula distancia recorrida mediante raíces por tic.
class CaelumActorSimpleElementalProjectile : CaelumActorProjectile
{
    int CaelumLifetimeTicks;
    bool CaelumVisualPrepared;

    Default
    {
        Radius 4;
        Height 4;
        Speed 20;
        Damage 1;
        DamageType "CaelumMagicTest";
        Projectile;
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        return Max(1, GetCaelumPreparedDamage(Max(1, damage)));
    }

    void PrepareElementSprite()
    {
        if (CaelumVisualPrepared || !CaelumElementalPayloadPrepared) { return; }
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
        frame = visual == "CELH" ? level.time % 12 : 0;
        CaelumVisualPrepared = true;
    }

    override void Tick()
    {
        Super.Tick();
        PrepareElementSprite();
        CaelumLifetimeTicks++;

        // La velocidad de esta clase es constante. Tiempo x velocidad limita
        // exactamente su alcance sin guardar posiciones ni calcular raíces.
        if ((CaelumMaximumTravelDistance > 0.0
                && CaelumLifetimeTicks * Max(1.0, Speed)
                    >= CaelumMaximumTravelDistance)
            || CaelumLifetimeTicks >= 350)
        {
            Destroy();
        }
    }

    States
    {
    Spawn:
        XFIR A 1 Bright;
        Loop;
    Death:
        TNT1 A 1;
        Stop;
    }
}

// Variante explosiva conservada para armas que realmente la requieran y para
// la comparación A/B de MAP02. Tampoco ejecuta búsqueda guiada por tic.
class CaelumActorExplosiveElementalProjectile : CaelumActorProjectile
{
    int CaelumLifetimeTicks;
    Vector3 CaelumPreviousPosition;
    double CaelumDistanceTraveled;
    bool CaelumTravelTrackingInitialized;

    Default
    {
        Radius 4;
        Height 4;
        Speed 20;
        Damage 1;
        DamageType "CaelumMagicTest";
        Projectile;
        +NOEXTREMEDEATH
    }

    override int DoSpecialDamage(Actor victim, int damage, Name damageType)
    {
        return Max(1, int(
            GetCaelumPreparedDamage(Max(1, damage))
                * CaelumConstants.ESSENCE_EXPLOSIVE_DIRECT_DAMAGE_RATIO + 0.5
        ));
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

    action void A_CaelumActorExplode()
    {
        invoker.A_Explode(
            invoker.CaelumActorExplosionDamage,
            invoker.CaelumActorExplosionRadius,
            0,
            false
        );
    }

    override void Tick()
    {
        Vector3 positionBeforeTick = Pos;
        Super.Tick();

        if (!CaelumTravelTrackingInitialized)
        {
            CaelumPreviousPosition = positionBeforeTick;
            CaelumTravelTrackingInitialized = true;
        }
        Vector3 traveled = Pos - CaelumPreviousPosition;
        CaelumDistanceTraveled += traveled.Length();
        CaelumPreviousPosition = Pos;

        // El alcance derivado del lanzador es el límite funcional. Diez
        // segundos permanecen como salvaguarda absoluta independiente.
        if (CaelumMaximumTravelDistance > 0.0
            && CaelumDistanceTraveled >= CaelumMaximumTravelDistance)
        {
            Destroy();
            return;
        }

        // Incluso la variante explosiva conserva un límite absoluto de vida.
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
        XFIR A 1 Bright;
        Loop;
    Death:
        XFIR A 0 Bright A_CaelumActorExplode;
        XFIR A 2 Bright;
        Stop;
    }
}
