// Perfiles generados desde el catálogo aprobado (#405).
class CaelumSourceYerbaMate : CaelumLandSource
{
    override int Profile() { return 0; }
    Default
    {
        Tag "$CA_SOURCE_YERBA_MATE";
        Radius 20; Height 48; Mass 10;
        Activation THINGSPEC_Switch;
    }
    States { Spawn: CFBH A -1; Stop; }
}
class CaelumSourceMarcela : CaelumLandSource
{
    override int Profile() { return 1; }
    Default
    {
        Tag "$CA_SOURCE_MARCELA";
        Radius 20; Height 48; Mass 10;
        Activation THINGSPEC_Switch;
    }
    States { Spawn: CFBH A -1; Stop; }
}
class CaelumSourceMarcelaDecoration : CaelumSourceMarcela
{
    override bool IsNaturalResource() { return false; }
}
class CaelumSourceIrupeFlower : CaelumLandSource
{
    override int Profile() { return 2; }
    Default
    {
        Tag "$CA_SOURCE_IRUPE_FLOWER";
        Radius 20; Height 48; Mass 10;
        Activation THINGSPEC_Switch;
    }
    States { Spawn: CFBH A -1; Stop; }
}
class CaelumSourceCypellaFlower : CaelumLandSource
{
    override int Profile() { return 3; }
    Default
    {
        Tag "$CA_SOURCE_CYPELLA_FLOWER";
        Radius 20; Height 48; Mass 10;
        Activation THINGSPEC_Switch;
    }
    States { Spawn: CFBH A -1; Stop; }
}
class CaelumSourceCypellaFlowerDecoration : CaelumSourceCypellaFlower
{
    override bool IsNaturalResource() { return false; }
}
class CaelumSourceSugarcane : CaelumLandSource
{
    override int Profile() { return 4; }
    Default
    {
        Tag "$CA_SOURCE_SUGARCANE";
        Radius 20; Height 48; Mass 10;
        Activation THINGSPEC_Switch;
    }
    States { Spawn: CFBH A -1; Stop; }
}
class CaelumSourceCotton : CaelumLandSource
{
    override int Profile() { return 5; }
    Default
    {
        Tag "$CA_SOURCE_COTTON";
        Radius 20; Height 48; Mass 10;
        Activation THINGSPEC_Switch;
    }
    States { Spawn: CFBH A -1; Stop; }
}
class CaelumSourceHoney : CaelumLandSource
{
    override int Profile() { return 6; }
    Default
    {
        Tag "$CA_SOURCE_HONEY";
        Radius 20; Height 48; Mass 10;
        Activation THINGSPEC_Switch;
    }
    States { Spawn: CFBH A -1; Stop; }
}
class CaelumSourceHoneyDecoration : CaelumSourceHoney
{
    override bool IsNaturalResource() { return false; }
}
