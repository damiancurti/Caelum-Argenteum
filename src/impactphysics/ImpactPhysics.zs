// Impact Physics Core API — GZDoom 4.14-compatible implementation.
// Generic collision mathematics; no Caelum-specific types are referenced.
//
// ZScript 4.14 treats user structs as reference-like values in function calls
// and does not support the C/C++-style struct return/value initialization that
// the first V4.26.0 draft used. These small Object classes keep the API generic
// while using semantics supported by the target engine.

class ImpactBody : Object
{
    double Mass;
    double Height;
    Vector3 Position;
    Vector3 Velocity;
    double Restitution;
    double SurfaceMultiplier;
}

class ImpactResult : Object
{
    bool Valid;
    bool StaticTarget;
    Vector3 Normal;
    double ClosingSpeed;
    double Impulse;
    double SourceDeltaSpeed;
    double TargetDeltaSpeed;
    double SourceEquivalentTics;
    double TargetEquivalentTics;
    double SourceEnergyPercent;
    double TargetEnergyPercent;
    double SourceContactMinimumHeightRatio;
    double SourceContactMaximumHeightRatio;
    double TargetContactMinimumHeightRatio;
    double TargetContactMaximumHeightRatio;

    void Reset()
    {
        Valid = false;
        StaticTarget = false;
        Normal = (0.0, 0.0, 0.0);
        ClosingSpeed = 0.0;
        Impulse = 0.0;
        SourceDeltaSpeed = 0.0;
        TargetDeltaSpeed = 0.0;
        SourceEquivalentTics = 1.0e9;
        TargetEquivalentTics = 1.0e9;
        SourceEnergyPercent = 0.0;
        TargetEnergyPercent = 0.0;
        SourceContactMinimumHeightRatio = 0.0;
        SourceContactMaximumHeightRatio = 1.0;
        TargetContactMinimumHeightRatio = 0.0;
        TargetContactMaximumHeightRatio = 1.0;
    }
}

// Un enlace persistente representa una arista del grafo de contactos. Ambos
// cuerpos guardan el mismo objeto, por lo que una multitud puede formar islas
// sin perder parejas cuando aparece un vecino nuevo.
class ImpactContactState : Object
{
    Actor FirstActor;
    Actor SecondActor;
    double ReleaseDistance;
    int SeparatedTics;
    int LastUpdatedTick;
    int LastCollisionTick;
    int LastResolutionTick;
    int LastSustainedTick;
    int LastCrushTick;
    int SustainedTics;
    double LastClosingSpeed;
    double LastTransmittedImpulse;
    double CurrentTickTransmittedImpulse;
    double AccumulatedClosingSpeed;
    double AccumulatedTransmittedImpulse;
    bool Active;

    void Initialize(Actor first, Actor second, double releaseDistance)
    {
        FirstActor = first;
        SecondActor = second;
        ReleaseDistance = Max(0.0, releaseDistance);
        SeparatedTics = 0;
        LastUpdatedTick = -1;
        LastCollisionTick = -1;
        LastResolutionTick = -1;
        LastSustainedTick = -1;
        LastCrushTick = -1;
        SustainedTics = 0;
        LastClosingSpeed = 0.0;
        LastTransmittedImpulse = 0.0;
        CurrentTickTransmittedImpulse = 0.0;
        AccumulatedClosingSpeed = 0.0;
        AccumulatedTransmittedImpulse = 0.0;
        Active = first != null && second != null;
    }

    bool Matches(Actor owner, Actor other)
    {
        return Active && other != null
            && ((FirstActor == owner && SecondActor == other)
                || (FirstActor == other && SecondActor == owner));
    }

    void RegisterCollision(int currentTick)
    {
        if (!Active) { return; }
        LastCollisionTick = currentTick;
        SeparatedTics = 0;
    }

    bool BeginResolutionTick(int currentTick)
    {
        RegisterCollision(currentTick);
        if (LastResolutionTick == currentTick)
        {
            return false;
        }
        LastResolutionTick = currentTick;
        return true;
    }

    void UpdateSeparation(int currentTick, int requiredSeparatedTics)
    {
        if (!Active || LastUpdatedTick == currentTick) { return; }
        LastUpdatedTick = currentTick;

        if (FirstActor == null || SecondActor == null
            || FirstActor.health <= 0 || SecondActor.health <= 0)
        {
            Active = false;
            return;
        }

        // Un contacto que ya no recibe callbacks de colision no puede quedar
        // como arista historica de la isla. Se toleran cinco tics completos
        // para conservar actores cuyo A_Chase avanza en cadencia de 4 o 5.
        if (LastCollisionTick >= 0
            && currentTick - LastCollisionTick > Max(1, requiredSeparatedTics))
        {
            Active = false;
            return;
        }

        double dx = SecondActor.Pos.X - FirstActor.Pos.X;
        double dy = SecondActor.Pos.Y - FirstActor.Pos.Y;
        double distance = Sqrt(dx * dx + dy * dy);
        if (distance > ReleaseDistance)
        {
            SeparatedTics++;
            if (SeparatedTics >= Max(1, requiredSeparatedTics))
            {
                Active = false;
            }
        }
        else
        {
            SeparatedTics = 0;
        }
    }

    bool RegisterSustainedTransfer(
        int currentTick,
        double closingSpeed,
        double impulse,
        int crushIntervalTics
    )
    {
        RegisterCollision(currentTick);
        if (LastSustainedTick == currentTick)
        {
            // CollidedWith puede notificarse mas de una vez en un mismo tic.
            // Contar solo una muestra evita multiplicar presion por callbacks.
            AccumulatedClosingSpeed = Max(
                AccumulatedClosingSpeed,
                Max(0.0, closingSpeed)
            );
            double sanitizedImpulse = Max(0.0, impulse);
            if (sanitizedImpulse > CurrentTickTransmittedImpulse)
            {
                AccumulatedTransmittedImpulse +=
                    sanitizedImpulse - CurrentTickTransmittedImpulse;
                CurrentTickTransmittedImpulse = sanitizedImpulse;
            }
            return false;
        }
        LastSustainedTick = currentTick;
        SustainedTics++;
        AccumulatedClosingSpeed = Max(
            AccumulatedClosingSpeed,
            Max(0.0, closingSpeed)
        );
        CurrentTickTransmittedImpulse = Max(0.0, impulse);
        AccumulatedTransmittedImpulse += CurrentTickTransmittedImpulse;

        if (LastCrushTick < 0)
        {
            LastCrushTick = currentTick;
            return false;
        }
        if (crushIntervalTics <= 0
            || currentTick - LastCrushTick < crushIntervalTics)
        {
            return false;
        }

        // El pulso usa la suma real de impulso que cruzo esta arista durante
        // el intervalo. No inventa una velocidad nominal de marcha.
        LastClosingSpeed = AccumulatedClosingSpeed;
        LastTransmittedImpulse = AccumulatedTransmittedImpulse;
        AccumulatedClosingSpeed = 0.0;
        AccumulatedTransmittedImpulse = 0.0;
        LastCrushTick = currentTick;
        return LastTransmittedImpulse > 0.0001;
    }
}

class ImpactPhysics
{
    static double SanitizeMass(double mass)
    {
        return Max(0.0001, mass);
    }

    static double SanitizeHeight(double height)
    {
        return Max(0.0001, height);
    }

    static Vector3 NormalizeHorizontal(Vector3 value)
    {
        double length = Sqrt(value.X * value.X + value.Y * value.Y);
        if (length <= 0.0001)
        {
            return (0.0, 0.0, 0.0);
        }
        return (value.X / length, value.Y / length, 0.0);
    }

    static double EquivalentTics(double height, double deltaSpeed)
    {
        // V4.26.2: universal physical reference. `height` remains in the
        // signature for API compatibility and contact geometry, but no longer
        // changes kinetic severity. 56 MU is the standard 1.8 m Caelum actor;
        // half that height is the fixed 28 MU reference distance.
        double referenceDistance = 28.0;
        if (deltaSpeed <= 0.0001) { return 1.0e9; }
        return referenceDistance / deltaSpeed;
    }

    static double EnergyPercent(double equivalentTics)
    {
        double threshold = 35.0;
        if (equivalentTics >= threshold) { return 0.0; }

        double safeTics = Max(0.0001, equivalentTics);
        double speedRatio = threshold / safeTics;
        double energyRatio = speedRatio * speedRatio;
        double referenceEnergy = threshold * threshold;
        return Max(
            0.0,
            100.0 * (energyRatio - 1.0)
                / (referenceEnergy - 1.0)
        );
    }

    static void ResolveBodies(
        ImpactBody sourceBody,
        ImpactBody targetBody,
        Vector3 collisionNormal,
        ImpactResult result
    )
    {
        if (result == null) { return; }
        result.Reset();
        if (sourceBody == null || targetBody == null) { return; }

        Vector3 normal = NormalizeHorizontal(collisionNormal);
        if (Abs(normal.X) <= 0.0001 && Abs(normal.Y) <= 0.0001)
        {
            return;
        }

        double relativeX =
            sourceBody.Velocity.X - targetBody.Velocity.X;
        double relativeY =
            sourceBody.Velocity.Y - targetBody.Velocity.Y;
        double closingSpeed =
            relativeX * normal.X + relativeY * normal.Y;
        if (closingSpeed <= 0.0) { return; }

        double sourceMass = SanitizeMass(sourceBody.Mass);
        double targetMass = SanitizeMass(targetBody.Mass);
        double inverseMassSum = 1.0 / sourceMass + 1.0 / targetMass;
        if (inverseMassSum <= 0.0) { return; }

        double restitution = Clamp(
            (sourceBody.Restitution + targetBody.Restitution) * 0.5,
            0.0,
            1.0
        );
        double impulse =
            (1.0 + restitution) * closingSpeed / inverseMassSum;

        result.Valid = true;
        result.StaticTarget = false;
        result.Normal = normal;
        result.ClosingSpeed = closingSpeed;
        result.Impulse = impulse;
        result.SourceDeltaSpeed = impulse / sourceMass;
        result.TargetDeltaSpeed = impulse / targetMass;
        result.SourceEquivalentTics = EquivalentTics(
            sourceBody.Height, result.SourceDeltaSpeed
        );
        result.TargetEquivalentTics = EquivalentTics(
            targetBody.Height, result.TargetDeltaSpeed
        );
        result.SourceEnergyPercent =
            EnergyPercent(result.SourceEquivalentTics);
        result.TargetEnergyPercent =
            EnergyPercent(result.TargetEquivalentTics);

        // Neutral geometric contact interval from vertical cylinder overlap.
        double sourceBottom = sourceBody.Position.Z;
        double sourceTop = sourceBottom + SanitizeHeight(sourceBody.Height);
        double targetBottom = targetBody.Position.Z;
        double targetTop = targetBottom + SanitizeHeight(targetBody.Height);
        double overlapBottom = Max(sourceBottom, targetBottom);
        double overlapTop = Min(sourceTop, targetTop);
        if (overlapTop >= overlapBottom)
        {
            result.SourceContactMinimumHeightRatio = Clamp(
                (overlapBottom - sourceBottom) / SanitizeHeight(sourceBody.Height),
                0.0, 1.0
            );
            result.SourceContactMaximumHeightRatio = Clamp(
                (overlapTop - sourceBottom) / SanitizeHeight(sourceBody.Height),
                0.0, 1.0
            );
            result.TargetContactMinimumHeightRatio = Clamp(
                (overlapBottom - targetBottom) / SanitizeHeight(targetBody.Height),
                0.0, 1.0
            );
            result.TargetContactMaximumHeightRatio = Clamp(
                (overlapTop - targetBottom) / SanitizeHeight(targetBody.Height),
                0.0, 1.0
            );
        }
    }

    static void ResolveStatic(
        ImpactBody sourceBody,
        Vector3 surfaceNormal,
        ImpactResult result
    )
    {
        if (result == null) { return; }
        result.Reset();
        result.StaticTarget = true;
        if (sourceBody == null) { return; }

        Vector3 normal = NormalizeHorizontal(surfaceNormal);
        if (Abs(normal.X) <= 0.0001 && Abs(normal.Y) <= 0.0001)
        {
            return;
        }

        double closingSpeed = Abs(
            sourceBody.Velocity.X * normal.X
                + sourceBody.Velocity.Y * normal.Y
        );
        if (closingSpeed <= 0.0001) { return; }

        result.Valid = true;
        result.Normal = normal;
        result.ClosingSpeed = closingSpeed;
        result.Impulse = SanitizeMass(sourceBody.Mass) * closingSpeed;
        result.SourceDeltaSpeed = closingSpeed;
        result.TargetDeltaSpeed = 0.0;
        result.SourceEquivalentTics = EquivalentTics(
            sourceBody.Height, closingSpeed
        );
        result.TargetEquivalentTics = 1.0e9;
        result.SourceEnergyPercent =
            EnergyPercent(result.SourceEquivalentTics);
        result.TargetEnergyPercent = 0.0;
    }

    static void ResolveExternal(
        ImpactBody targetBody,
        double sourceMass,
        Vector3 sourceVelocity,
        Vector3 collisionNormal,
        double sourceRestitution,
        ImpactResult result
    )
    {
        if (result == null) { return; }
        result.Reset();
        if (targetBody == null) { return; }

        ImpactBody sourceBody = new("ImpactBody");
        if (sourceBody == null) { return; }

        sourceBody.Mass = SanitizeMass(sourceMass);
        sourceBody.Height = targetBody.Height;
        sourceBody.Velocity = sourceVelocity;
        sourceBody.Restitution = sourceRestitution;
        sourceBody.SurfaceMultiplier = 1.0;

        ResolveBodies(
            sourceBody,
            targetBody,
            collisionNormal,
            result
        );
    }
}
