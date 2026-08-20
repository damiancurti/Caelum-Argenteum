// Proyectil elemental guiado compartido por los cuatro actores de prueba.
// Usa A_SeekerMissile, la misma primitiva nativa empleada por el Libro.
class CaelumActorHomingElementalProjectile : CaelumActorProjectile
{
    Default
    {
        Radius 4;
        Height 4;
        Speed 20;
        Damage 1;
        DamageType "CaelumMagicTest";
        Projectile;
        +NOGRAVITY
        +SEEKERMISSILE
        +INTERPOLATEANGLES
        +NOEXTREMEDEATH
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
            visual = CaelumSecondaryElement ? "XRAY" : "XAIR";
        else if (CaelumEssenceType == CaelumConstants.ESSENCE_QUINTESSENCE)
            visual = "XQUI";
        sprite = GetSpriteIndex(visual);
        frame = 0;
    }

    action void A_CaelumActorSeek()
    {
        // El proyectil nace con Target = lanzador. El objetivo del lanzador es
        // la referencia más robusta para estos actores de prueba.
        if (invoker.Tracer == null && invoker.Target != null)
            invoker.Tracer = invoker.Target.Target;
        if (invoker.Tracer != null && invoker.Tracer.health > 0)
        {
            invoker.A_SeekerMissile(10, 30);

            // El seeker nativo resuelve el giro horizontal. Recalculamos Vel.Z
            // hacia el centro vertical del objetivo para que el misil no pierda
            // altura progresivamente durante persecuciones largas.
            double targetZ = invoker.Tracer.Pos.Z + (invoker.Tracer.Height * 0.5);
            double deltaZ = targetZ - (invoker.Pos.Z + (invoker.Height * 0.5));
            double deltaX = invoker.Tracer.Pos.X - invoker.Pos.X;
            double deltaY = invoker.Tracer.Pos.Y - invoker.Pos.Y;
            double horizontalDistance = sqrt((deltaX * deltaX) + (deltaY * deltaY));
            double horizontalSpeed = sqrt((invoker.Vel.X * invoker.Vel.X) + (invoker.Vel.Y * invoker.Vel.Y));

            // Usamos el tiempo horizontal estimado hasta el blanco; de este modo
            // la corrección vertical no introduce una velocidad arbitraria.
            if (horizontalSpeed > 0.001)
            {
                double travelTics = max(horizontalDistance / horizontalSpeed, 1.0);
                invoker.Vel.Z = deltaZ / travelTics;
            }
            else
            {
                invoker.Vel.Z = 0;
            }
        }
    }

    override void Tick()
    {
        Super.Tick();
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
