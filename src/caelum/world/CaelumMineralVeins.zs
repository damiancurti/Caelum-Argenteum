// Vetas 3D renovables del catálogo mineral compacto.
class CaelumMineralVeinEnvironmentProp : CaelumRockEnvironmentProp
{
    override bool IsNaturalResource() { return true; }
    override int GetRequiredHarvestDamageType()
    {
        return CaelumConstants.CATALOGUE_DAMAGE_PIERCING;
    }
}

class CaelumVeinIron : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_IRON;
    }
    override double GetResourceHardness() { return 5.5; }
    override double GetResourceAbundance() { return 0.6; }

    Default
    {
        Tag "$CA_VEIN_IRON";
        Radius 46;
        Height 56;
        Mass 30674;
    }
    States
    {
        Spawn: CAVE A -1; Stop;
    }
}

class CaelumVeinIron2 : CaelumVeinIron
{
    Default
    {
        Radius 34.5;
        Height 42;
        Mass 12941;
    }
}

class CaelumVeinIron3 : CaelumVeinIron
{
    Default
    {
        Radius 57.5;
        Height 70;
        Mass 59910;
    }
}

class CaelumVeinCoal : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_COAL;
    }
    override double GetResourceHardness() { return 2.5; }
    override double GetResourceAbundance() { return 0.6; }

    Default
    {
        Tag "$CA_VEIN_COAL";
        Radius 46;
        Height 56;
        Mass 30674;
    }
    States
    {
        Spawn: CAVE B -1; Stop;
    }
}

class CaelumVeinCoal2 : CaelumVeinCoal
{
    Default
    {
        Radius 34.5;
        Height 42;
        Mass 12941;
    }
}

class CaelumVeinCoal3 : CaelumVeinCoal
{
    Default
    {
        Radius 57.5;
        Height 70;
        Mass 59910;
    }
}

class CaelumVeinCopper : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_COPPER;
    }
    override double GetResourceHardness() { return 3.5; }
    override double GetResourceAbundance() { return 0.5; }

    Default
    {
        Tag "$CA_VEIN_COPPER";
        Radius 46;
        Height 56;
        Mass 30674;
    }
    States
    {
        Spawn: CAVE C -1; Stop;
    }
}

class CaelumVeinCopper2 : CaelumVeinCopper
{
    Default
    {
        Radius 34.5;
        Height 42;
        Mass 12941;
    }
}

class CaelumVeinCopper3 : CaelumVeinCopper
{
    Default
    {
        Radius 57.5;
        Height 70;
        Mass 59910;
    }
}

class CaelumVeinTin : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_TIN;
    }
    override double GetResourceHardness() { return 6.5; }
    override double GetResourceAbundance() { return 0.4; }

    Default
    {
        Tag "$CA_VEIN_TIN";
        Radius 46;
        Height 56;
        Mass 30674;
    }
    States
    {
        Spawn: CAVE D -1; Stop;
    }
}

class CaelumVeinTin2 : CaelumVeinTin
{
    Default
    {
        Radius 34.5;
        Height 42;
        Mass 12941;
    }
}

class CaelumVeinTin3 : CaelumVeinTin
{
    Default
    {
        Radius 57.5;
        Height 70;
        Mass 59910;
    }
}

class CaelumVeinSilver : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_SILVER;
    }
    override double GetResourceHardness() { return 3; }
    override double GetResourceAbundance() { return 0.2; }

    Default
    {
        Tag "$CA_VEIN_SILVER";
        Radius 46;
        Height 56;
        Mass 30674;
    }
    States
    {
        Spawn: CAVE E -1; Stop;
    }
}

class CaelumVeinSilver2 : CaelumVeinSilver
{
    Default
    {
        Radius 34.5;
        Height 42;
        Mass 12941;
    }
}

class CaelumVeinSilver3 : CaelumVeinSilver
{
    Default
    {
        Radius 57.5;
        Height 70;
        Mass 59910;
    }
}

class CaelumVeinGold : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_GOLD;
    }
    override double GetResourceHardness() { return 3; }
    override double GetResourceAbundance() { return 0.1; }

    Default
    {
        Tag "$CA_VEIN_GOLD";
        Radius 46;
        Height 56;
        Mass 30674;
    }
    States
    {
        Spawn: CAVE F -1; Stop;
    }
}

class CaelumVeinGold2 : CaelumVeinGold
{
    Default
    {
        Radius 34.5;
        Height 42;
        Mass 12941;
    }
}

class CaelumVeinGold3 : CaelumVeinGold
{
    Default
    {
        Radius 57.5;
        Height 70;
        Mass 59910;
    }
}

class CaelumVeinOpal : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_OPAL;
    }
    override double GetResourceHardness() { return 6; }
    override double GetResourceAbundance() { return 0.075; }

    Default
    {
        Tag "$CA_VEIN_OPAL";
        Radius 44;
        Height 68;
        Mass 34078;
    }
    States
    {
        Spawn: CAVE G -1; Stop;
    }
}

class CaelumVeinOpal2 : CaelumVeinOpal
{
    Default
    {
        Radius 33;
        Height 51;
        Mass 14377;
    }
}

class CaelumVeinOpal3 : CaelumVeinOpal
{
    Default
    {
        Radius 55;
        Height 85;
        Mass 66559;
    }
}

class CaelumVeinTopaz : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_TOPAZ;
    }
    override double GetResourceHardness() { return 8; }
    override double GetResourceAbundance() { return 0.05; }

    Default
    {
        Tag "$CA_VEIN_TOPAZ";
        Radius 44;
        Height 68;
        Mass 34078;
    }
    States
    {
        Spawn: CAVE H -1; Stop;
    }
}

class CaelumVeinTopaz2 : CaelumVeinTopaz
{
    Default
    {
        Radius 33;
        Height 51;
        Mass 14377;
    }
}

class CaelumVeinTopaz3 : CaelumVeinTopaz
{
    Default
    {
        Radius 55;
        Height 85;
        Mass 66559;
    }
}

class CaelumVeinSapphire : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_SAPPHIRE;
    }
    override double GetResourceHardness() { return 9; }
    override double GetResourceAbundance() { return 0.04; }

    Default
    {
        Tag "$CA_VEIN_SAPPHIRE";
        Radius 44;
        Height 68;
        Mass 34078;
    }
    States
    {
        Spawn: CAVE I -1; Stop;
    }
}

class CaelumVeinSapphire2 : CaelumVeinSapphire
{
    Default
    {
        Radius 33;
        Height 51;
        Mass 14377;
    }
}

class CaelumVeinSapphire3 : CaelumVeinSapphire
{
    Default
    {
        Radius 55;
        Height 85;
        Mass 66559;
    }
}

class CaelumVeinRuby : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_RUBY;
    }
    override double GetResourceHardness() { return 9; }
    override double GetResourceAbundance() { return 0.03; }

    Default
    {
        Tag "$CA_VEIN_RUBY";
        Radius 44;
        Height 68;
        Mass 34078;
    }
    States
    {
        Spawn: CAVE J -1; Stop;
    }
}

class CaelumVeinRuby2 : CaelumVeinRuby
{
    Default
    {
        Radius 33;
        Height 51;
        Mass 14377;
    }
}

class CaelumVeinRuby3 : CaelumVeinRuby
{
    Default
    {
        Radius 55;
        Height 85;
        Mass 66559;
    }
}

class CaelumVeinEmerald : CaelumMineralVeinEnvironmentProp
{
    override int GetResourceMaterialType()
    {
        return CaelumConstants.MATERIAL_RAW_EMERALD;
    }
    override double GetResourceHardness() { return 7.5; }
    override double GetResourceAbundance() { return 0.02; }

    Default
    {
        Tag "$CA_VEIN_EMERALD";
        Radius 44;
        Height 68;
        Mass 34078;
    }
    States
    {
        Spawn: CAVE K -1; Stop;
    }
}

class CaelumVeinEmerald2 : CaelumVeinEmerald
{
    Default
    {
        Radius 33;
        Height 51;
        Mass 14377;
    }
}

class CaelumVeinEmerald3 : CaelumVeinEmerald
{
    Default
    {
        Radius 55;
        Height 85;
        Mass 66559;
    }
}
