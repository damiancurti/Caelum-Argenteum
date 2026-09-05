// Objetos físicos originales para poblar los biomas. Las masas usan el
// cilindro de colisión a 32 MU/m y una densidad nominal del material.
// Los nodos renovables guardan capacidad, fracciones y regeneración.
class CaelumEnvironmentProp : CaelumMovableProp
{
    bool ResourceStateInitialized;
    double ResourceRemainingUnits;
    double ResourceYieldCarry;

    virtual bool IsEnvironmentMovable() { return false; }
    virtual bool IsNaturalResource() { return false; }
    virtual int GetResourceMaterialType() { return -1; }
    virtual int GetRequiredHarvestDamageType()
    {
        return CaelumConstants.CATALOGUE_DAMAGE_NONE;
    }
    virtual double GetResourceHardness() { return 0.0; }
    virtual double GetResourceAbundance() { return 1.0; }

    double GetEnvironmentMassKg()
    {
        return Max(1.0, double(Mass));
    }

    double GetEnvironmentImpactMultiplier() { return 1.0; }

    double GetResourceCapacityUnits()
    {
        if (!IsNaturalResource()) { return 0.0; }
        // Arg4 permite al mapeador reemplazar la capacidad en kg.
        double capacityKg = args[4] > 0
            ? double(args[4])
            : GetEnvironmentMassKg() * Max(0.0, GetResourceAbundance());
        return capacityKg / CaelumConstants.MATERIAL_UNIT_WEIGHT;
    }

    double GetResourceHardnessMultiplier()
    {
        return Clamp(1.0 - GetResourceHardness() / 10.0, 0.0, 1.0);
    }

    void EnsureResourceState()
    {
        if (ResourceStateInitialized || !IsNaturalResource()) { return; }
        ResourceStateInitialized = true;
        ResourceRemainingUnits = GetResourceCapacityUnits();
        ResourceYieldCarry = 0.0;
    }

    bool SpawnExtractedMaterial(Actor extractor, int amount)
    {
        if (extractor == null || amount <= 0) { return false; }
        double deltaX = extractor.Pos.X - Pos.X;
        double deltaY = extractor.Pos.Y - Pos.Y;
        double distance = Sqrt(deltaX * deltaX + deltaY * deltaY);
        if (distance <= 0.0001)
        {
            deltaX = Cos(Angle);
            deltaY = Sin(Angle);
            distance = 1.0;
        }
        double offset = Radius + 20.0;
        Vector3 dropPos = (
            Pos.X + deltaX / distance * offset,
            Pos.Y + deltaY / distance * offset,
            Pos.Z + 8.0
        );
        CaelumMaterialPickup material = CaelumMaterialPickup(
            Spawn("CaelumMaterialPickup", dropPos, NO_REPLACE)
        );
        if (material == null) { return false; }
        material.args[0] = GetResourceMaterialType();
        material.args[1] = 1;
        material.Amount = amount;
        material.InMagicBox = false;
        material.UpdateMaterialVisuals();
        return true;
    }

    double TryExtractResource(
        Actor extractor,
        int damageKind,
        double strikePower
    )
    {
        EnsureResourceState();
        if (!IsNaturalResource()
            || extractor == null
            || damageKind != GetRequiredHarvestDamageType()
            || strikePower <= 0.0
            || ResourceRemainingUnits <= 0.0)
        {
            return 0.0;
        }

        // La abundancia fija la capacidad del yacimiento. La dureza y
        // la abundancia también determinan cuánto libera cada golpe.
        double released = strikePower
            * GetResourceHardnessMultiplier()
            * Max(0.0, GetResourceAbundance());
        double removed = Min(ResourceRemainingUnits, released);
        if (removed <= 0.0) { return 0.0; }

        double combined = ResourceYieldCarry + removed;
        int wholeUnits = int(Floor(combined));
        if (wholeUnits > 0
            && !SpawnExtractedMaterial(extractor, wholeUnits))
        {
            return 0.0;
        }
        ResourceRemainingUnits -= removed;
        ResourceYieldCarry = combined - wholeUnits;
        return removed;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        EnsureResourceState();
    }

    override void Tick()
    {
        Super.Tick();
        if (!IsNaturalResource()) { return; }
        EnsureResourceState();
        double capacity = GetResourceCapacityUnits();
        if (ResourceRemainingUnits >= capacity
            || (level.time + Mass) % TICRATE != 0)
        {
            return;
        }
        // Se actualiza una vez por segundo y se escalona por masa para
        // evitar que una arboleda completa haga trabajo el mismo tic.
        double recoveryPerUpdate = capacity
            * CaelumConstants.NATURAL_RESOURCE_RECOVERY_PER_GAME_DAY
            / (CaelumConstants.GAME_HOURS_PER_DAY
                * CaelumConstants.REAL_SECONDS_PER_GAME_HOUR);
        ResourceRemainingUnits = Min(
            capacity, ResourceRemainingUnits + recoveryPerUpdate
        );
    }

    override double GetRequiredPhysicalPower()
    {
        if (!IsEnvironmentMovable()) { return -1.0; }
        return GetEnvironmentMassKg() / 100.0;
    }

    override bool TryPushFrom(
        Actor pusher,
        double physicalPower,
        double pushForce
    )
    {
        if (pusher == null || !CanBePushedWith(physicalPower))
        {
            return false;
        }

        double pushAngle = VectorAngle(
            Pos.X - pusher.Pos.X,
            Pos.Y - pusher.Pos.Y
        );
        double massScale = 100.0 / GetEnvironmentMassKg();
        Thrust(Max(0.0, pushForce) * massScale, pushAngle);
        return true;
    }

    Default
    {
        Health 1;
        +SOLID
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "Normal";
    }
}

class CaelumRockEnvironmentProp : CaelumEnvironmentProp
{
    override bool IsEnvironmentMovable() { return true; }

    Default
    {
        -CANNOTPUSH
        -DONTTHRUST
    }
}

class CaelumTreeEnvironmentProp : CaelumEnvironmentProp
{
    override bool IsEnvironmentMovable() { return false; }
    override bool IsNaturalResource() { return true; }
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_WOOD;
    }
    override int GetRequiredHarvestDamageType()
    {
        return CaelumConstants.CATALOGUE_DAMAGE_SLASHING;
    }
    override double GetResourceHardness() { return 2.5; }
}

class CaelumRockGranite : CaelumRockEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_GRANITE";
        Radius 28;
        Height 42;
        Mass 8524;
    }
    States
    {
        Spawn: CARK A -1; Stop;
    }
}

class CaelumRockGraniteHalf : CaelumRockGranite
{
    Default
    {
        Radius 14;
        Height 21;
        Mass 1065;
    }
}

class CaelumRockGraniteHalf2 : CaelumRockGranite
{
    Default
    {
        Radius 10.5;
        Height 15.75;
        Mass 449;
    }
}

class CaelumRockGraniteHalf3 : CaelumRockGranite
{
    Default
    {
        Radius 17.5;
        Height 26.25;
        Mass 2081;
    }
}

class CaelumRockGranite2 : CaelumRockGranite
{
    Default
    {
        Radius 21;
        Height 31.5;
        Mass 3596;
    }
}

class CaelumRockGranite3 : CaelumRockGranite
{
    Default
    {
        Radius 35;
        Height 52.5;
        Mass 16648;
    }
}

class CaelumRockGraniteDouble : CaelumRockGranite
{
    Default
    {
        Radius 56;
        Height 84;
        Mass 68190;
    }
}

class CaelumRockGraniteDouble2 : CaelumRockGranite
{
    Default
    {
        Radius 42;
        Height 63;
        Mass 28768;
    }
}

class CaelumRockGraniteDouble3 : CaelumRockGranite
{
    Default
    {
        Radius 70;
        Height 105;
        Mass 133183;
    }
}

class CaelumRockGraniteGiant : CaelumRockGranite
{
    Default
    {
        Radius 140;
        Height 210;
        Mass 1065465;
    }
}

class CaelumRockGraniteGiant2 : CaelumRockGranite
{
    Default
    {
        Radius 105;
        Height 157.5;
        Mass 449493;
    }
}

class CaelumRockGraniteGiant3 : CaelumRockGranite
{
    Default
    {
        Radius 175;
        Height 262.5;
        Mass 2080986;
    }
}

class CaelumRockGraniteColossal : CaelumRockGranite
{
    Default
    {
        Radius 560;
        Height 840;
        Mass 68189741;
    }
}

class CaelumRockGraniteColossal2 : CaelumRockGranite
{
    Default
    {
        Radius 420;
        Height 630;
        Mass 28767547;
    }
}

class CaelumRockGraniteColossal3 : CaelumRockGranite
{
    Default
    {
        Radius 700;
        Height 1050;
        Mass 133183088;
    }
}

class CaelumRockSandstone : CaelumRockEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_SANDSTONE";
        Radius 44;
        Height 38;
        Mass 16222;
    }
    States
    {
        Spawn: CARK B -1; Stop;
    }
}

class CaelumRockSandstoneHalf : CaelumRockSandstone
{
    Default
    {
        Radius 22;
        Height 19;
        Mass 2028;
    }
}

class CaelumRockSandstoneHalf2 : CaelumRockSandstone
{
    Default
    {
        Radius 16.5;
        Height 14.25;
        Mass 855;
    }
}

class CaelumRockSandstoneHalf3 : CaelumRockSandstone
{
    Default
    {
        Radius 27.5;
        Height 23.75;
        Mass 3961;
    }
}

class CaelumRockSandstone2 : CaelumRockSandstone
{
    Default
    {
        Radius 33;
        Height 28.5;
        Mass 6844;
    }
}

class CaelumRockSandstone3 : CaelumRockSandstone
{
    Default
    {
        Radius 55;
        Height 47.5;
        Mass 31684;
    }
}

class CaelumRockSandstoneDouble : CaelumRockSandstone
{
    Default
    {
        Radius 88;
        Height 76;
        Mass 129780;
    }
}

class CaelumRockSandstoneDouble2 : CaelumRockSandstone
{
    Default
    {
        Radius 66;
        Height 57;
        Mass 54751;
    }
}

class CaelumRockSandstoneDouble3 : CaelumRockSandstone
{
    Default
    {
        Radius 110;
        Height 95;
        Mass 253476;
    }
}

class CaelumRockSandstoneGiant : CaelumRockSandstone
{
    Default
    {
        Radius 220;
        Height 190;
        Mass 2027808;
    }
}

class CaelumRockSandstoneGiant2 : CaelumRockSandstone
{
    Default
    {
        Radius 165;
        Height 142.5;
        Mass 855481;
    }
}

class CaelumRockSandstoneGiant3 : CaelumRockSandstone
{
    Default
    {
        Radius 275;
        Height 237.5;
        Mass 3960562;
    }
}

class CaelumRockSandstoneColossal : CaelumRockSandstone
{
    Default
    {
        Radius 880;
        Height 760;
        Mass 129779683;
    }
}

class CaelumRockSandstoneColossal2 : CaelumRockSandstone
{
    Default
    {
        Radius 660;
        Height 570;
        Mass 54750804;
    }
}

class CaelumRockSandstoneColossal3 : CaelumRockSandstone
{
    Default
    {
        Radius 1100;
        Height 950;
        Mass 253475944;
    }
}

class CaelumRockBasalt : CaelumRockEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_BASALT";
        Radius 28;
        Height 86;
        Mass 19393;
    }
    States
    {
        Spawn: CARK C -1; Stop;
    }
}

class CaelumRockBasaltHalf : CaelumRockBasalt
{
    Default
    {
        Radius 14;
        Height 43;
        Mass 2424;
    }
}

class CaelumRockBasaltHalf2 : CaelumRockBasalt
{
    Default
    {
        Radius 10.5;
        Height 32.25;
        Mass 1023;
    }
}

class CaelumRockBasaltHalf3 : CaelumRockBasalt
{
    Default
    {
        Radius 17.5;
        Height 53.75;
        Mass 4735;
    }
}

class CaelumRockBasalt2 : CaelumRockBasalt
{
    Default
    {
        Radius 21;
        Height 64.5;
        Mass 8181;
    }
}

class CaelumRockBasalt3 : CaelumRockBasalt
{
    Default
    {
        Radius 35;
        Height 107.5;
        Mass 37876;
    }
}

class CaelumRockBasaltDouble : CaelumRockBasalt
{
    Default
    {
        Radius 56;
        Height 172;
        Mass 155141;
    }
}

class CaelumRockBasaltDouble2 : CaelumRockBasalt
{
    Default
    {
        Radius 42;
        Height 129;
        Mass 65450;
    }
}

class CaelumRockBasaltDouble3 : CaelumRockBasalt
{
    Default
    {
        Radius 70;
        Height 215;
        Mass 303009;
    }
}

class CaelumRockBasaltGiant : CaelumRockBasalt
{
    Default
    {
        Radius 140;
        Height 430;
        Mass 2424073;
    }
}

class CaelumRockBasaltGiant2 : CaelumRockBasalt
{
    Default
    {
        Radius 105;
        Height 322.5;
        Mass 1022656;
    }
}

class CaelumRockBasaltGiant3 : CaelumRockBasalt
{
    Default
    {
        Radius 175;
        Height 537.5;
        Mass 4734518;
    }
}

class CaelumRockBasaltColossal : CaelumRockBasalt
{
    Default
    {
        Radius 560;
        Height 1720;
        Mass 155140681;
    }
}

class CaelumRockBasaltColossal2 : CaelumRockBasalt
{
    Default
    {
        Radius 420;
        Height 1290;
        Mass 65449975;
    }
}

class CaelumRockBasaltColossal3 : CaelumRockBasalt
{
    Default
    {
        Radius 700;
        Height 2150;
        Mass 303009143;
    }
}

class CaelumRockQuartz : CaelumRockEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_QUARTZ";
        Radius 32;
        Height 70;
        Mass 18211;
    }
    States
    {
        Spawn: CARK D -1; Stop;
    }
}

class CaelumRockQuartzHalf : CaelumRockQuartz
{
    Default
    {
        Radius 16;
        Height 35;
        Mass 2276;
    }
}

class CaelumRockQuartzHalf2 : CaelumRockQuartz
{
    Default
    {
        Radius 12;
        Height 26.25;
        Mass 960;
    }
}

class CaelumRockQuartzHalf3 : CaelumRockQuartz
{
    Default
    {
        Radius 20;
        Height 43.75;
        Mass 4446;
    }
}

class CaelumRockQuartz2 : CaelumRockQuartz
{
    Default
    {
        Radius 24;
        Height 52.5;
        Mass 7683;
    }
}

class CaelumRockQuartz3 : CaelumRockQuartz
{
    Default
    {
        Radius 40;
        Height 87.5;
        Mass 35569;
    }
}

class CaelumRockQuartzDouble : CaelumRockQuartz
{
    Default
    {
        Radius 64;
        Height 140;
        Mass 145691;
    }
}

class CaelumRockQuartzDouble2 : CaelumRockQuartz
{
    Default
    {
        Radius 48;
        Height 105;
        Mass 61464;
    }
}

class CaelumRockQuartzDouble3 : CaelumRockQuartz
{
    Default
    {
        Radius 80;
        Height 175;
        Mass 284553;
    }
}

class CaelumRockQuartzGiant : CaelumRockQuartz
{
    Default
    {
        Radius 160;
        Height 350;
        Mass 2276427;
    }
}

class CaelumRockQuartzGiant2 : CaelumRockQuartz
{
    Default
    {
        Radius 120;
        Height 262.5;
        Mass 960368;
    }
}

class CaelumRockQuartzGiant3 : CaelumRockQuartz
{
    Default
    {
        Radius 200;
        Height 437.5;
        Mass 4446147;
    }
}

class CaelumRockQuartzColossal : CaelumRockQuartz
{
    Default
    {
        Radius 640;
        Height 1400;
        Mass 145691359;
    }
}

class CaelumRockQuartzColossal2 : CaelumRockQuartz
{
    Default
    {
        Radius 480;
        Height 1050;
        Mass 61463542;
    }
}

class CaelumRockQuartzColossal3 : CaelumRockQuartz
{
    Default
    {
        Radius 800;
        Height 1750;
        Mass 284553436;
    }
}

class CaelumRockCoastal : CaelumRockEnvironmentProp
{
    Default
    {
        Tag "$CA_ROCK_COASTAL";
        Radius 45;
        Height 34;
        Mass 16502;
    }
    States
    {
        Spawn: CARK E -1; Stop;
    }
}

class CaelumRockCoastalHalf : CaelumRockCoastal
{
    Default
    {
        Radius 22.5;
        Height 17;
        Mass 2063;
    }
}

class CaelumRockCoastalHalf2 : CaelumRockCoastal
{
    Default
    {
        Radius 16.875;
        Height 12.75;
        Mass 870;
    }
}

class CaelumRockCoastalHalf3 : CaelumRockCoastal
{
    Default
    {
        Radius 28.125;
        Height 21.25;
        Mass 4029;
    }
}

class CaelumRockCoastal2 : CaelumRockCoastal
{
    Default
    {
        Radius 33.75;
        Height 25.5;
        Mass 6962;
    }
}

class CaelumRockCoastal3 : CaelumRockCoastal
{
    Default
    {
        Radius 56.25;
        Height 42.5;
        Mass 32231;
    }
}

class CaelumRockCoastalDouble : CaelumRockCoastal
{
    Default
    {
        Radius 90;
        Height 68;
        Mass 132018;
    }
}

class CaelumRockCoastalDouble2 : CaelumRockCoastal
{
    Default
    {
        Radius 67.5;
        Height 51;
        Mass 55695;
    }
}

class CaelumRockCoastalDouble3 : CaelumRockCoastal
{
    Default
    {
        Radius 112.5;
        Height 85;
        Mass 257848;
    }
}

class CaelumRockCoastalGiant : CaelumRockCoastal
{
    Default
    {
        Radius 225;
        Height 170;
        Mass 2062785;
    }
}

class CaelumRockCoastalGiant2 : CaelumRockCoastal
{
    Default
    {
        Radius 168.75;
        Height 127.5;
        Mass 870237;
    }
}

class CaelumRockCoastalGiant3 : CaelumRockCoastal
{
    Default
    {
        Radius 281.25;
        Height 212.5;
        Mass 4028876;
    }
}

class CaelumRockCoastalColossal : CaelumRockCoastal
{
    Default
    {
        Radius 900;
        Height 680;
        Mass 132018222;
    }
}

class CaelumRockCoastalColossal2 : CaelumRockCoastal
{
    Default
    {
        Radius 675;
        Height 510;
        Mass 55695187;
    }
}

class CaelumRockCoastalColossal3 : CaelumRockCoastal
{
    Default
    {
        Radius 1125;
        Height 850;
        Mass 257848089;
    }
}

class CaelumTreeDesertCardon : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON";
        Radius 24;
        Height 220;
        Mass 3645;
    }
    States
    {
        Spawn: CAVT A -1; Stop;
    }
}

class CaelumTreeDesertCardon2 : CaelumTreeDesertCardon
{
    Default
    {
        Radius 18;
        Height 165;
        Mass 1538;
    }
}

class CaelumTreeDesertCardon3 : CaelumTreeDesertCardon
{
    Default
    {
        Radius 30;
        Height 275;
        Mass 7119;
    }
}

class CaelumTreeDesertChurqui : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI";
        Radius 16;
        Height 118;
        Mass 2462;
    }
    States
    {
        Spawn: CAVT B -1; Stop;
    }
}

class CaelumTreeDesertChurqui2 : CaelumTreeDesertChurqui
{
    Default
    {
        Radius 12;
        Height 88.5;
        Mass 1039;
    }
}

class CaelumTreeDesertChurqui3 : CaelumTreeDesertChurqui
{
    Default
    {
        Radius 20;
        Height 147.5;
        Mass 4808;
    }
}

class CaelumTreeDesertChanar : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR";
        Radius 18;
        Height 138;
        Mass 3644;
    }
    States
    {
        Spawn: CAVT C -1; Stop;
    }
}

class CaelumTreeDesertChanar2 : CaelumTreeDesertChanar
{
    Default
    {
        Radius 13.5;
        Height 103.5;
        Mass 1537;
    }
}

class CaelumTreeDesertChanar3 : CaelumTreeDesertChanar
{
    Default
    {
        Radius 22.5;
        Height 172.5;
        Mass 7117;
    }
}

class CaelumTreeJungleLapacho : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_LAPACHO";
        Radius 24;
        Height 238;
        Mass 13143;
    }
    States
    {
        Spawn: CAVT D -1; Stop;
    }
}

class CaelumTreeJungleLapacho2 : CaelumTreeJungleLapacho
{
    Default
    {
        Radius 18;
        Height 178.5;
        Mass 5545;
    }
}

class CaelumTreeJungleLapacho3 : CaelumTreeJungleLapacho
{
    Default
    {
        Radius 30;
        Height 297.5;
        Mass 25670;
    }
}

class CaelumTreeJungleLapachoAdult : CaelumTreeJungleLapacho
{
    Default
    {
        Radius 58.084034;
        Height 576;
        Mass 186310;
    }
}

class CaelumTreeJungleLapachoAdult2 : CaelumTreeJungleLapacho
{
    Default
    {
        Radius 43.563025;
        Height 432;
        Mass 78599;
    }
}

class CaelumTreeJungleLapachoAdult3 : CaelumTreeJungleLapacho
{
    Default
    {
        Radius 72.605042;
        Height 720;
        Mass 363887;
    }
}

class CaelumTreeJunglePaloRosa : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_PALO_ROSA";
        Radius 20;
        Height 310;
        Mass 9511;
    }
    States
    {
        Spawn: CAVT E -1; Stop;
    }
}

class CaelumTreeJunglePaloRosa2 : CaelumTreeJunglePaloRosa
{
    Default
    {
        Radius 15;
        Height 232.5;
        Mass 4012;
    }
}

class CaelumTreeJunglePaloRosa3 : CaelumTreeJunglePaloRosa
{
    Default
    {
        Radius 25;
        Height 387.5;
        Mass 18576;
    }
}

class CaelumTreeJunglePaloRosaAdult : CaelumTreeJunglePaloRosa
{
    Default
    {
        Radius 66.064516;
        Height 1024;
        Mass 342789;
    }
}

class CaelumTreeJunglePaloRosaAdult2 : CaelumTreeJunglePaloRosa
{
    Default
    {
        Radius 49.548387;
        Height 768;
        Mass 144614;
    }
}

class CaelumTreeJunglePaloRosaAdult3 : CaelumTreeJunglePaloRosa
{
    Default
    {
        Radius 82.580645;
        Height 1280;
        Mass 669509;
    }
}

class CaelumTreeJungleTimbo : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_TIMBO";
        Radius 32;
        Height 210;
        Mass 9278;
    }
    States
    {
        Spawn: CAVT F -1; Stop;
    }
}

class CaelumTreeJungleTimbo2 : CaelumTreeJungleTimbo
{
    Default
    {
        Radius 24;
        Height 157.5;
        Mass 3914;
    }
}

class CaelumTreeJungleTimbo3 : CaelumTreeJungleTimbo
{
    Default
    {
        Radius 40;
        Height 262.5;
        Mass 18120;
    }
}

class CaelumTreeJungleTimboAdult : CaelumTreeJungleTimbo
{
    Default
    {
        Radius 87.771429;
        Height 576;
        Mass 191444;
    }
}

class CaelumTreeJungleTimboAdult2 : CaelumTreeJungleTimbo
{
    Default
    {
        Radius 65.828571;
        Height 432;
        Mass 80765;
    }
}

class CaelumTreeJungleTimboAdult3 : CaelumTreeJungleTimbo
{
    Default
    {
        Radius 109.714286;
        Height 720;
        Mass 373914;
    }
}

class CaelumTreeTundraLenga : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_LENGA";
        Radius 20;
        Height 178;
        Mass 3754;
    }
    States
    {
        Spawn: CAVT G -1; Stop;
    }
}

class CaelumTreeTundraLenga2 : CaelumTreeTundraLenga
{
    Default
    {
        Radius 15;
        Height 133.5;
        Mass 1584;
    }
}

class CaelumTreeTundraLenga3 : CaelumTreeTundraLenga
{
    Default
    {
        Radius 25;
        Height 222.5;
        Mass 7333;
    }
}

class CaelumTreeTundraLengaAdult : CaelumTreeTundraLenga
{
    Default
    {
        Radius 71.910112;
        Height 640;
        Mass 174511;
    }
}

class CaelumTreeTundraLengaAdult2 : CaelumTreeTundraLenga
{
    Default
    {
        Radius 53.932584;
        Height 480;
        Mass 73622;
    }
}

class CaelumTreeTundraLengaAdult3 : CaelumTreeTundraLenga
{
    Default
    {
        Radius 89.88764;
        Height 800;
        Mass 340842;
    }
}

class CaelumTreeTundraNire : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_NIRE";
        Radius 22;
        Height 112;
        Mass 3118;
    }
    States
    {
        Spawn: CAVT H -1; Stop;
    }
}

class CaelumTreeTundraNire2 : CaelumTreeTundraNire
{
    Default
    {
        Radius 16.5;
        Height 84;
        Mass 1316;
    }
}

class CaelumTreeTundraNire3 : CaelumTreeTundraNire
{
    Default
    {
        Radius 27.5;
        Height 140;
        Mass 6090;
    }
}

class CaelumTreeTundraNireAdult : CaelumTreeTundraNire
{
    Default
    {
        Radius 62.857143;
        Height 320;
        Mass 72729;
    }
}

class CaelumTreeTundraNireAdult2 : CaelumTreeTundraNire
{
    Default
    {
        Radius 47.142857;
        Height 240;
        Mass 30683;
    }
}

class CaelumTreeTundraNireAdult3 : CaelumTreeTundraNire
{
    Default
    {
        Radius 78.571429;
        Height 400;
        Mass 142050;
    }
}

class CaelumTreeTundraGuindo : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_GUINDO";
        Radius 14;
        Height 206;
        Mass 2129;
    }
    States
    {
        Spawn: CAVT I -1; Stop;
    }
}

class CaelumTreeTundraGuindo2 : CaelumTreeTundraGuindo
{
    Default
    {
        Radius 10.5;
        Height 154.5;
        Mass 898;
    }
}

class CaelumTreeTundraGuindo3 : CaelumTreeTundraGuindo
{
    Default
    {
        Radius 17.5;
        Height 257.5;
        Mass 4158;
    }
}

class CaelumTreeTundraGuindoAdult : CaelumTreeTundraGuindo
{
    Default
    {
        Radius 43.495146;
        Height 640;
        Mass 63845;
    }
}

class CaelumTreeTundraGuindoAdult2 : CaelumTreeTundraGuindo
{
    Default
    {
        Radius 32.621359;
        Height 480;
        Mass 26934;
    }
}

class CaelumTreeTundraGuindoAdult3 : CaelumTreeTundraGuindo
{
    Default
    {
        Radius 54.368932;
        Height 800;
        Mass 124696;
    }
}

class CaelumTreeMountainPehuen : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_PEHUEN";
        Radius 18;
        Height 286;
        Mass 4886;
    }
    States
    {
        Spawn: CAVT J -1; Stop;
    }
}

class CaelumTreeMountainPehuen2 : CaelumTreeMountainPehuen
{
    Default
    {
        Radius 13.5;
        Height 214.5;
        Mass 2061;
    }
}

class CaelumTreeMountainPehuen3 : CaelumTreeMountainPehuen
{
    Default
    {
        Radius 22.5;
        Height 357.5;
        Mass 9543;
    }
}

class CaelumTreeMountainPehuenAdult : CaelumTreeMountainPehuen
{
    Default
    {
        Radius 64.447552;
        Height 1024;
        Mass 224272;
    }
}

class CaelumTreeMountainPehuenAdult2 : CaelumTreeMountainPehuen
{
    Default
    {
        Radius 48.335664;
        Height 768;
        Mass 94615;
    }
}

class CaelumTreeMountainPehuenAdult3 : CaelumTreeMountainPehuen
{
    Default
    {
        Radius 80.559441;
        Height 1280;
        Mass 438032;
    }
}

class CaelumTreeMountainCypress : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_CYPRESS";
        Radius 14;
        Height 226;
        Mass 2123;
    }
    States
    {
        Spawn: CAVT K -1; Stop;
    }
}

class CaelumTreeMountainCypress2 : CaelumTreeMountainCypress
{
    Default
    {
        Radius 10.5;
        Height 169.5;
        Mass 896;
    }
}

class CaelumTreeMountainCypress3 : CaelumTreeMountainCypress
{
    Default
    {
        Radius 17.5;
        Height 282.5;
        Mass 4147;
    }
}

class CaelumTreeMountainCypressAdult : CaelumTreeMountainCypress
{
    Default
    {
        Radius 35.681416;
        Height 576;
        Mass 35154;
    }
}

class CaelumTreeMountainCypressAdult2 : CaelumTreeMountainCypress
{
    Default
    {
        Radius 26.761062;
        Height 432;
        Mass 14831;
    }
}

class CaelumTreeMountainCypressAdult3 : CaelumTreeMountainCypress
{
    Default
    {
        Radius 44.60177;
        Height 720;
        Mass 68660;
    }
}

class CaelumTreeMountainCoihue : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_COIHUE";
        Radius 20;
        Height 254;
        Mass 5844;
    }
    States
    {
        Spawn: CAVT L -1; Stop;
    }
}

class CaelumTreeMountainCoihue2 : CaelumTreeMountainCoihue
{
    Default
    {
        Radius 15;
        Height 190.5;
        Mass 2466;
    }
}

class CaelumTreeMountainCoihue3 : CaelumTreeMountainCoihue
{
    Default
    {
        Radius 25;
        Height 317.5;
        Mass 11415;
    }
}

class CaelumTreeMountainCoihueAdult : CaelumTreeMountainCoihue
{
    Default
    {
        Radius 75.590551;
        Height 960;
        Mass 315542;
    }
}

class CaelumTreeMountainCoihueAdult2 : CaelumTreeMountainCoihue
{
    Default
    {
        Radius 56.692913;
        Height 720;
        Mass 133119;
    }
}

class CaelumTreeMountainCoihueAdult3 : CaelumTreeMountainCoihue
{
    Default
    {
        Radius 94.488189;
        Height 1200;
        Mass 616293;
    }
}

class CaelumTreePlainsOmbu : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_PLAINS_OMBU";
        Radius 35;
        Height 196;
        Mass 9208;
    }
    States
    {
        Spawn: CAVT M -1; Stop;
    }
}

class CaelumTreePlainsOmbu2 : CaelumTreePlainsOmbu
{
    Default
    {
        Radius 26.25;
        Height 147;
        Mass 3885;
    }
}

class CaelumTreePlainsOmbu3 : CaelumTreePlainsOmbu
{
    Default
    {
        Radius 43.75;
        Height 245;
        Mass 17984;
    }
}

class CaelumTreePlainsOmbuAdult : CaelumTreePlainsOmbu
{
    Default
    {
        Radius 68.571429;
        Height 384;
        Mass 69243;
    }
}

class CaelumTreePlainsOmbuAdult2 : CaelumTreePlainsOmbu
{
    Default
    {
        Radius 51.428571;
        Height 288;
        Mass 29212;
    }
}

class CaelumTreePlainsOmbuAdult3 : CaelumTreePlainsOmbu
{
    Default
    {
        Radius 85.714286;
        Height 480;
        Mass 135241;
    }
}

class CaelumTreePlainsTala : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_PLAINS_TALA";
        Radius 20;
        Height 148;
        Mass 4824;
    }
    States
    {
        Spawn: CAVT N -1; Stop;
    }
}

class CaelumTreePlainsTala2 : CaelumTreePlainsTala
{
    Default
    {
        Radius 15;
        Height 111;
        Mass 2035;
    }
}

class CaelumTreePlainsTala3 : CaelumTreePlainsTala
{
    Default
    {
        Radius 25;
        Height 185;
        Mass 9423;
    }
}

class CaelumTreePlainsTalaAdult : CaelumTreePlainsTala
{
    Default
    {
        Radius 34.594595;
        Height 256;
        Mass 24968;
    }
}

class CaelumTreePlainsTalaAdult2 : CaelumTreePlainsTala
{
    Default
    {
        Radius 25.945946;
        Height 192;
        Mass 10533;
    }
}

class CaelumTreePlainsTalaAdult3 : CaelumTreePlainsTala
{
    Default
    {
        Radius 43.243243;
        Height 320;
        Mass 48765;
    }
}

class CaelumTreePlainsEspinillo : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO";
        Radius 16;
        Height 106;
        Mass 2211;
    }
    States
    {
        Spawn: CAVT O -1; Stop;
    }
}

class CaelumTreePlainsEspinillo2 : CaelumTreePlainsEspinillo
{
    Default
    {
        Radius 12;
        Height 79.5;
        Mass 933;
    }
}

class CaelumTreePlainsEspinillo3 : CaelumTreePlainsEspinillo
{
    Default
    {
        Radius 20;
        Height 132.5;
        Mass 4319;
    }
}

class CaelumTreeCoastCoronillo : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_COAST_CORONILLO";
        Radius 18;
        Height 142;
        Mass 3970;
    }
    States
    {
        Spawn: CAVT P -1; Stop;
    }
}

class CaelumTreeCoastCoronillo2 : CaelumTreeCoastCoronillo
{
    Default
    {
        Radius 13.5;
        Height 106.5;
        Mass 1675;
    }
}

class CaelumTreeCoastCoronillo3 : CaelumTreeCoastCoronillo
{
    Default
    {
        Radius 22.5;
        Height 177.5;
        Mass 7754;
    }
}

class CaelumTreeCoastCoronilloAdult : CaelumTreeCoastCoronillo
{
    Default
    {
        Radius 32.450704;
        Height 256;
        Mass 23261;
    }
}

class CaelumTreeCoastCoronilloAdult2 : CaelumTreeCoastCoronillo
{
    Default
    {
        Radius 24.338028;
        Height 192;
        Mass 9813;
    }
}

class CaelumTreeCoastCoronilloAdult3 : CaelumTreeCoastCoronillo
{
    Default
    {
        Radius 40.56338;
        Height 320;
        Mass 45432;
    }
}

class CaelumTreeCoastWillow : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_COAST_WILLOW";
        Radius 20;
        Height 178;
        Mass 3072;
    }
    States
    {
        Spawn: CAVT Q -1; Stop;
    }
}

class CaelumTreeCoastWillow2 : CaelumTreeCoastWillow
{
    Default
    {
        Radius 15;
        Height 133.5;
        Mass 1296;
    }
}

class CaelumTreeCoastWillow3 : CaelumTreeCoastWillow
{
    Default
    {
        Radius 25;
        Height 222.5;
        Mass 6000;
    }
}

class CaelumTreeCoastWillowAdult : CaelumTreeCoastWillow
{
    Default
    {
        Radius 53.932584;
        Height 480;
        Mass 60236;
    }
}

class CaelumTreeCoastWillowAdult2 : CaelumTreeCoastWillow
{
    Default
    {
        Radius 40.449438;
        Height 360;
        Mass 25412;
    }
}

class CaelumTreeCoastWillowAdult3 : CaelumTreeCoastWillow
{
    Default
    {
        Radius 67.41573;
        Height 600;
        Mass 117648;
    }
}

class CaelumTreeCoastCeibo : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO";
        Radius 24;
        Height 158;
        Mass 3054;
    }
    States
    {
        Spawn: CAVT R -1; Stop;
    }
}

class CaelumTreeCoastCeibo2 : CaelumTreeCoastCeibo
{
    Default
    {
        Radius 18;
        Height 118.5;
        Mass 1288;
    }
}

class CaelumTreeCoastCeibo3 : CaelumTreeCoastCeibo
{
    Default
    {
        Radius 30;
        Height 197.5;
        Mass 5965;
    }
}

class CaelumTreeCityJacaranda : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_CITY_JACARANDA";
        Radius 20;
        Height 196;
        Mass 3758;
    }
    States
    {
        Spawn: CAVT S -1; Stop;
    }
}

class CaelumTreeCityJacaranda2 : CaelumTreeCityJacaranda
{
    Default
    {
        Radius 15;
        Height 147;
        Mass 1586;
    }
}

class CaelumTreeCityJacaranda3 : CaelumTreeCityJacaranda
{
    Default
    {
        Radius 25;
        Height 245;
        Mass 7340;
    }
}

class CaelumTreeCityJacarandaAdult : CaelumTreeCityJacaranda
{
    Default
    {
        Radius 48.979592;
        Height 480;
        Mass 55200;
    }
}

class CaelumTreeCityJacarandaAdult2 : CaelumTreeCityJacaranda
{
    Default
    {
        Radius 36.734694;
        Height 360;
        Mass 23288;
    }
}

class CaelumTreeCityJacarandaAdult3 : CaelumTreeCityJacaranda
{
    Default
    {
        Radius 61.22449;
        Height 600;
        Mass 107813;
    }
}

class CaelumTreeCityTipa : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_CITY_TIPA";
        Radius 26;
        Height 226;
        Mass 8056;
    }
    States
    {
        Spawn: CAVT T -1; Stop;
    }
}

class CaelumTreeCityTipa2 : CaelumTreeCityTipa
{
    Default
    {
        Radius 19.5;
        Height 169.5;
        Mass 3399;
    }
}

class CaelumTreeCityTipa3 : CaelumTreeCityTipa
{
    Default
    {
        Radius 32.5;
        Height 282.5;
        Mass 15734;
    }
}

class CaelumTreeCityTipaAdult : CaelumTreeCityTipa
{
    Default
    {
        Radius 73.628319;
        Height 640;
        Mass 182950;
    }
}

class CaelumTreeCityTipaAdult2 : CaelumTreeCityTipa
{
    Default
    {
        Radius 55.221239;
        Height 480;
        Mass 77182;
    }
}

class CaelumTreeCityTipaAdult3 : CaelumTreeCityTipa
{
    Default
    {
        Radius 92.035398;
        Height 800;
        Mass 357324;
    }
}

class CaelumTreeCityPlane : CaelumTreeEnvironmentProp
{
    Default
    {
        Tag "$CA_TREE_CITY_PLANE";
        Radius 20;
        Height 244;
        Mass 5240;
    }
    States
    {
        Spawn: CAVT U -1; Stop;
    }
}

class CaelumTreeCityPlane2 : CaelumTreeCityPlane
{
    Default
    {
        Radius 15;
        Height 183;
        Mass 2211;
    }
}

class CaelumTreeCityPlane3 : CaelumTreeCityPlane
{
    Default
    {
        Radius 25;
        Height 305;
        Mass 10235;
    }
}

class CaelumTreeCityPlaneAdult : CaelumTreeCityPlane
{
    Default
    {
        Radius 57.704918;
        Height 704;
        Mass 125860;
    }
}

class CaelumTreeCityPlaneAdult2 : CaelumTreeCityPlane
{
    Default
    {
        Radius 43.278689;
        Height 528;
        Mass 53097;
    }
}

class CaelumTreeCityPlaneAdult3 : CaelumTreeCityPlane
{
    Default
    {
        Radius 72.131148;
        Height 880;
        Mass 245819;
    }
}

class CaelumTreeDesertCardonAdult : CaelumTreeDesertCardon
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON_ADULT";
    }
}

class CaelumTreeDesertCardonYoung : CaelumTreeDesertCardon
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON_YOUNG";
        Radius 12;
        Height 110;
        Mass 456;
    }
}

class CaelumTreeDesertCardonAdult2 : CaelumTreeDesertCardon2
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON_ADULT";
    }
}

class CaelumTreeDesertCardonYoung2 : CaelumTreeDesertCardon2
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON_YOUNG";
        Radius 9;
        Height 82.5;
        Mass 192;
    }
}

class CaelumTreeDesertCardonAdult3 : CaelumTreeDesertCardon3
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON_ADULT";
    }
}

class CaelumTreeDesertCardonYoung3 : CaelumTreeDesertCardon3
{
    Default
    {
        Tag "$CA_TREE_DESERT_CARDON_YOUNG";
        Radius 15;
        Height 137.5;
        Mass 890;
    }
}

class CaelumTreeDesertChurquiAdult : CaelumTreeDesertChurqui
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI_ADULT";
    }
}

class CaelumTreeDesertChurquiYoung : CaelumTreeDesertChurqui
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI_YOUNG";
        Radius 8;
        Height 59;
        Mass 308;
    }
}

class CaelumTreeDesertChurquiAdult2 : CaelumTreeDesertChurqui2
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI_ADULT";
    }
}

class CaelumTreeDesertChurquiYoung2 : CaelumTreeDesertChurqui2
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI_YOUNG";
        Radius 6;
        Height 44.25;
        Mass 130;
    }
}

class CaelumTreeDesertChurquiAdult3 : CaelumTreeDesertChurqui3
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI_ADULT";
    }
}

class CaelumTreeDesertChurquiYoung3 : CaelumTreeDesertChurqui3
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHURQUI_YOUNG";
        Radius 10;
        Height 73.75;
        Mass 601;
    }
}

class CaelumTreeDesertChanarAdult : CaelumTreeDesertChanar
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR_ADULT";
    }
}

class CaelumTreeDesertChanarYoung : CaelumTreeDesertChanar
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR_YOUNG";
        Radius 9;
        Height 69;
        Mass 455;
    }
}

class CaelumTreeDesertChanarAdult2 : CaelumTreeDesertChanar2
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR_ADULT";
    }
}

class CaelumTreeDesertChanarYoung2 : CaelumTreeDesertChanar2
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR_YOUNG";
        Radius 6.75;
        Height 51.75;
        Mass 192;
    }
}

class CaelumTreeDesertChanarAdult3 : CaelumTreeDesertChanar3
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR_ADULT";
    }
}

class CaelumTreeDesertChanarYoung3 : CaelumTreeDesertChanar3
{
    Default
    {
        Tag "$CA_TREE_DESERT_CHANAR_YOUNG";
        Radius 11.25;
        Height 86.25;
        Mass 890;
    }
}

class CaelumTreePlainsEspinilloAdult : CaelumTreePlainsEspinillo
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO_ADULT";
    }
}

class CaelumTreePlainsEspinilloYoung : CaelumTreePlainsEspinillo
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO_YOUNG";
        Radius 8;
        Height 53;
        Mass 276;
    }
}

class CaelumTreePlainsEspinilloAdult2 : CaelumTreePlainsEspinillo2
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO_ADULT";
    }
}

class CaelumTreePlainsEspinilloYoung2 : CaelumTreePlainsEspinillo2
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO_YOUNG";
        Radius 6;
        Height 39.75;
        Mass 117;
    }
}

class CaelumTreePlainsEspinilloAdult3 : CaelumTreePlainsEspinillo3
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO_ADULT";
    }
}

class CaelumTreePlainsEspinilloYoung3 : CaelumTreePlainsEspinillo3
{
    Default
    {
        Tag "$CA_TREE_PLAINS_ESPINILLO_YOUNG";
        Radius 10;
        Height 66.25;
        Mass 540;
    }
}

class CaelumTreeCoastCeiboAdult : CaelumTreeCoastCeibo
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO_ADULT";
    }
}

class CaelumTreeCoastCeiboYoung : CaelumTreeCoastCeibo
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO_YOUNG";
        Radius 12;
        Height 79;
        Mass 382;
    }
}

class CaelumTreeCoastCeiboAdult2 : CaelumTreeCoastCeibo2
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO_ADULT";
    }
}

class CaelumTreeCoastCeiboYoung2 : CaelumTreeCoastCeibo2
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO_YOUNG";
        Radius 9;
        Height 59.25;
        Mass 161;
    }
}

class CaelumTreeCoastCeiboAdult3 : CaelumTreeCoastCeibo3
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO_ADULT";
    }
}

class CaelumTreeCoastCeiboYoung3 : CaelumTreeCoastCeibo3
{
    Default
    {
        Tag "$CA_TREE_COAST_CEIBO_YOUNG";
        Radius 15;
        Height 98.75;
        Mass 746;
    }
}

class CaelumTreeJungleLapachoYoung : CaelumTreeJungleLapacho
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_LAPACHO_YOUNG";
    }
}

class CaelumTreeJungleLapachoYoung2 : CaelumTreeJungleLapacho2
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_LAPACHO_YOUNG";
    }
}

class CaelumTreeJungleLapachoYoung3 : CaelumTreeJungleLapacho3
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_LAPACHO_YOUNG";
    }
}

class CaelumTreeJunglePaloRosaYoung : CaelumTreeJunglePaloRosa
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_PALO_ROSA_YOUNG";
    }
}

class CaelumTreeJunglePaloRosaYoung2 : CaelumTreeJunglePaloRosa2
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_PALO_ROSA_YOUNG";
    }
}

class CaelumTreeJunglePaloRosaYoung3 : CaelumTreeJunglePaloRosa3
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_PALO_ROSA_YOUNG";
    }
}

class CaelumTreeJungleTimboYoung : CaelumTreeJungleTimbo
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_TIMBO_YOUNG";
    }
}

class CaelumTreeJungleTimboYoung2 : CaelumTreeJungleTimbo2
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_TIMBO_YOUNG";
    }
}

class CaelumTreeJungleTimboYoung3 : CaelumTreeJungleTimbo3
{
    Default
    {
        Tag "$CA_TREE_JUNGLE_TIMBO_YOUNG";
    }
}

class CaelumTreeTundraLengaYoung : CaelumTreeTundraLenga
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_LENGA_YOUNG";
    }
}

class CaelumTreeTundraLengaYoung2 : CaelumTreeTundraLenga2
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_LENGA_YOUNG";
    }
}

class CaelumTreeTundraLengaYoung3 : CaelumTreeTundraLenga3
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_LENGA_YOUNG";
    }
}

class CaelumTreeTundraNireYoung : CaelumTreeTundraNire
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_NIRE_YOUNG";
    }
}

class CaelumTreeTundraNireYoung2 : CaelumTreeTundraNire2
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_NIRE_YOUNG";
    }
}

class CaelumTreeTundraNireYoung3 : CaelumTreeTundraNire3
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_NIRE_YOUNG";
    }
}

class CaelumTreeTundraGuindoYoung : CaelumTreeTundraGuindo
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_GUINDO_YOUNG";
    }
}

class CaelumTreeTundraGuindoYoung2 : CaelumTreeTundraGuindo2
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_GUINDO_YOUNG";
    }
}

class CaelumTreeTundraGuindoYoung3 : CaelumTreeTundraGuindo3
{
    Default
    {
        Tag "$CA_TREE_TUNDRA_GUINDO_YOUNG";
    }
}

class CaelumTreeMountainPehuenYoung : CaelumTreeMountainPehuen
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_PEHUEN_YOUNG";
    }
}

class CaelumTreeMountainPehuenYoung2 : CaelumTreeMountainPehuen2
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_PEHUEN_YOUNG";
    }
}

class CaelumTreeMountainPehuenYoung3 : CaelumTreeMountainPehuen3
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_PEHUEN_YOUNG";
    }
}

class CaelumTreeMountainCypressYoung : CaelumTreeMountainCypress
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_CYPRESS_YOUNG";
    }
}

class CaelumTreeMountainCypressYoung2 : CaelumTreeMountainCypress2
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_CYPRESS_YOUNG";
    }
}

class CaelumTreeMountainCypressYoung3 : CaelumTreeMountainCypress3
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_CYPRESS_YOUNG";
    }
}

class CaelumTreeMountainCoihueYoung : CaelumTreeMountainCoihue
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_COIHUE_YOUNG";
    }
}

class CaelumTreeMountainCoihueYoung2 : CaelumTreeMountainCoihue2
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_COIHUE_YOUNG";
    }
}

class CaelumTreeMountainCoihueYoung3 : CaelumTreeMountainCoihue3
{
    Default
    {
        Tag "$CA_TREE_MOUNTAIN_COIHUE_YOUNG";
    }
}

class CaelumTreePlainsOmbuYoung : CaelumTreePlainsOmbu
{
    Default
    {
        Tag "$CA_TREE_PLAINS_OMBU_YOUNG";
    }
}

class CaelumTreePlainsOmbuYoung2 : CaelumTreePlainsOmbu2
{
    Default
    {
        Tag "$CA_TREE_PLAINS_OMBU_YOUNG";
    }
}

class CaelumTreePlainsOmbuYoung3 : CaelumTreePlainsOmbu3
{
    Default
    {
        Tag "$CA_TREE_PLAINS_OMBU_YOUNG";
    }
}

class CaelumTreePlainsTalaYoung : CaelumTreePlainsTala
{
    Default
    {
        Tag "$CA_TREE_PLAINS_TALA_YOUNG";
    }
}

class CaelumTreePlainsTalaYoung2 : CaelumTreePlainsTala2
{
    Default
    {
        Tag "$CA_TREE_PLAINS_TALA_YOUNG";
    }
}

class CaelumTreePlainsTalaYoung3 : CaelumTreePlainsTala3
{
    Default
    {
        Tag "$CA_TREE_PLAINS_TALA_YOUNG";
    }
}

class CaelumTreeCoastCoronilloYoung : CaelumTreeCoastCoronillo
{
    Default
    {
        Tag "$CA_TREE_COAST_CORONILLO_YOUNG";
    }
}

class CaelumTreeCoastCoronilloYoung2 : CaelumTreeCoastCoronillo2
{
    Default
    {
        Tag "$CA_TREE_COAST_CORONILLO_YOUNG";
    }
}

class CaelumTreeCoastCoronilloYoung3 : CaelumTreeCoastCoronillo3
{
    Default
    {
        Tag "$CA_TREE_COAST_CORONILLO_YOUNG";
    }
}

class CaelumTreeCoastWillowYoung : CaelumTreeCoastWillow
{
    Default
    {
        Tag "$CA_TREE_COAST_WILLOW_YOUNG";
    }
}

class CaelumTreeCoastWillowYoung2 : CaelumTreeCoastWillow2
{
    Default
    {
        Tag "$CA_TREE_COAST_WILLOW_YOUNG";
    }
}

class CaelumTreeCoastWillowYoung3 : CaelumTreeCoastWillow3
{
    Default
    {
        Tag "$CA_TREE_COAST_WILLOW_YOUNG";
    }
}

class CaelumTreeCityJacarandaYoung : CaelumTreeCityJacaranda
{
    Default
    {
        Tag "$CA_TREE_CITY_JACARANDA_YOUNG";
    }
}

class CaelumTreeCityJacarandaYoung2 : CaelumTreeCityJacaranda2
{
    Default
    {
        Tag "$CA_TREE_CITY_JACARANDA_YOUNG";
    }
}

class CaelumTreeCityJacarandaYoung3 : CaelumTreeCityJacaranda3
{
    Default
    {
        Tag "$CA_TREE_CITY_JACARANDA_YOUNG";
    }
}

class CaelumTreeCityTipaYoung : CaelumTreeCityTipa
{
    Default
    {
        Tag "$CA_TREE_CITY_TIPA_YOUNG";
    }
}

class CaelumTreeCityTipaYoung2 : CaelumTreeCityTipa2
{
    Default
    {
        Tag "$CA_TREE_CITY_TIPA_YOUNG";
    }
}

class CaelumTreeCityTipaYoung3 : CaelumTreeCityTipa3
{
    Default
    {
        Tag "$CA_TREE_CITY_TIPA_YOUNG";
    }
}

class CaelumTreeCityPlaneYoung : CaelumTreeCityPlane
{
    Default
    {
        Tag "$CA_TREE_CITY_PLANE_YOUNG";
    }
}

class CaelumTreeCityPlaneYoung2 : CaelumTreeCityPlane2
{
    Default
    {
        Tag "$CA_TREE_CITY_PLANE_YOUNG";
    }
}

class CaelumTreeCityPlaneYoung3 : CaelumTreeCityPlane3
{
    Default
    {
        Tag "$CA_TREE_CITY_PLANE_YOUNG";
    }
}
