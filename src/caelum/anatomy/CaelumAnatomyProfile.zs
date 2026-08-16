// Ordered, normalized anatomy regions. Multiple entries may share one
// vulnerability grade, so unusual actors can expose several heads, weak
// points, tails, or other authored regions without changing combat code.
class CaelumAnatomyProfile : Object
{
    const MAXIMUM_REGIONS = 16;

    int RegionCount;
    int RegionLocation[16];
    int RegionVulnerability[16];
    double RegionMinimumHeight[16];
    double RegionMaximumHeight[16];
    double RegionMinimumLateral[16];
    double RegionMaximumLateral[16];

    void ClearRegions()
    {
        RegionCount = 0;
    }

    void AddRegion(
        int location,
        int vulnerability,
        double minimumHeight,
        double maximumHeight,
        double minimumLateral,
        double maximumLateral
    )
    {
        if (RegionCount >= MAXIMUM_REGIONS) { return; }
        int index = RegionCount++;
        RegionLocation[index] = location;
        RegionVulnerability[index] = Clamp(
            vulnerability,
            0,
            CaelumConstants.VULNERABILITY_GRADE_COUNT - 1
        );
        RegionMinimumHeight[index] = Clamp(minimumHeight, 0.0, 1.0);
        RegionMaximumHeight[index] = Clamp(maximumHeight, 0.0, 1.0);
        RegionMinimumLateral[index] = Clamp(minimumLateral, 0.0, 1.0);
        RegionMaximumLateral[index] = Clamp(maximumLateral, 0.0, 1.0);
    }

    void InitializeHumanoid()
    {
        ClearRegions();
        // Specific overlapping regions must precede broader ones.
        AddRegion(
            CaelumConstants.HIT_LOCATION_HEAD,
            CaelumConstants.VULNERABILITY_CRITICAL_POINT,
            0.80, 1.00, 0.00, 1.00
        );
        AddRegion(
            CaelumConstants.HIT_LOCATION_ARMS,
            CaelumConstants.VULNERABILITY_WEAK_POINT,
            0.30, 0.50, 0.50, 1.00
        );
        AddRegion(
            CaelumConstants.HIT_LOCATION_TORSO,
            CaelumConstants.VULNERABILITY_SENSITIVE_POINT,
            0.40, 0.80, 0.00, 1.00
        );
        AddRegion(
            CaelumConstants.HIT_LOCATION_LEGS,
            CaelumConstants.VULNERABILITY_NEUTRAL_POINT,
            0.00, 0.40, 0.00, 1.00
        );
    }

    int FindRegion(double heightRatio, double lateralRatio)
    {
        double normalizedHeight = Clamp(heightRatio, 0.0, 1.0);
        double normalizedLateral = Clamp(lateralRatio, 0.0, 1.0);
        for (int i = 0; i < RegionCount; i++)
        {
            if (normalizedHeight >= RegionMinimumHeight[i]
                && normalizedHeight <= RegionMaximumHeight[i]
                && normalizedLateral >= RegionMinimumLateral[i]
                && normalizedLateral <= RegionMaximumLateral[i])
            {
                return i;
            }
        }
        return -1;
    }

    int GetLocation(int regionIndex)
    {
        if (regionIndex < 0 || regionIndex >= RegionCount)
        {
            return CaelumConstants.HIT_LOCATION_TORSO;
        }
        return RegionLocation[regionIndex];
    }

    int GetVulnerability(int regionIndex)
    {
        if (regionIndex < 0 || regionIndex >= RegionCount)
        {
            return CaelumConstants.VULNERABILITY_SENSITIVE_POINT;
        }
        return RegionVulnerability[regionIndex];
    }

    int FindRegionForLocation(int location)
    {
        for (int i = 0; i < RegionCount; i++)
        {
            if (RegionLocation[i] == location) { return i; }
        }
        return -1;
    }

    // Interseca la esfera de una explosión con cada volumen anatómico. La
    // altura define un tramo vertical y la lateralidad un anillo del cilindro
    // del actor; por eso los brazos laterales no cuentan como torso ni se
    // duplican cuando la onda alcanza ambos lados.
    int GetExplosionTouchedRegionMask(
        Actor owner,
        Vector3 explosionOrigin,
        double explosionRadius
    )
    {
        if (owner == null || explosionRadius <= 0.0) { return 0; }

        double deltaX = explosionOrigin.X - owner.Pos.X;
        double deltaY = explosionOrigin.Y - owner.Pos.Y;
        double radialDistance = Sqrt(deltaX * deltaX + deltaY * deltaY);
        int touchedRegions = 0;
        bool armsAlreadyTouched = false;

        for (int i = 0; i < RegionCount; i++)
        {
            int location = RegionLocation[i];
            if (location == CaelumConstants.HIT_LOCATION_ARMS
                && armsAlreadyTouched)
            {
                continue;
            }

            double minimumZ = owner.Pos.Z
                + RegionMinimumHeight[i] * owner.Height;
            double maximumZ = owner.Pos.Z
                + RegionMaximumHeight[i] * owner.Height;
            double verticalGap = 0.0;
            if (explosionOrigin.Z < minimumZ)
            {
                verticalGap = minimumZ - explosionOrigin.Z;
            }
            else if (explosionOrigin.Z > maximumZ)
            {
                verticalGap = explosionOrigin.Z - maximumZ;
            }

            double innerRadius = RegionMinimumLateral[i] * owner.Radius;
            double outerRadius = RegionMaximumLateral[i] * owner.Radius;
            double horizontalGap = 0.0;
            if (radialDistance < innerRadius)
            {
                horizontalGap = innerRadius - radialDistance;
            }
            else if (radialDistance > outerRadius)
            {
                horizontalGap = radialDistance - outerRadius;
            }

            double closestDistance = Sqrt(
                horizontalGap * horizontalGap + verticalGap * verticalGap
            );
            if (closestDistance <= explosionRadius)
            {
                touchedRegions |= 1 << i;
                if (location == CaelumConstants.HIT_LOCATION_ARMS)
                {
                    armsAlreadyTouched = true;
                }
            }
        }
        return touchedRegions;
    }
}
