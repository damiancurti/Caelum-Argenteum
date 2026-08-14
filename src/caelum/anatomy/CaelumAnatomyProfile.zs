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
}
