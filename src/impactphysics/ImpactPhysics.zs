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
        if (deltaSpeed <= 0.0001) { return 1.0e9; }
        return (SanitizeHeight(height) * 0.5) / deltaSpeed;
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
