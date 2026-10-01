// Decoración de #61: reutiliza sólo la representación de los ceibos y arbustos.
// No hereda nodos de recursos ni modifica las reservas del jardín del tutorial.
class CaelumMansionSceneryTree : Actor
{
    Default
    {
        Radius 24;
        Height 158;
        +SOLID
        +NOGRAVITY
    }
    States { Spawn: CAVT R -1; Stop; }
}
class CaelumMansionSceneryTree2 : CaelumMansionSceneryTree
{
    Default { Radius 18; Height 118.5; }
}
class CaelumMansionSceneryTree3 : CaelumMansionSceneryTree
{
    Default { Radius 30; Height 197.5; }
}
class CaelumMansionSceneryShrub : Actor
{
    Default
    {
        Radius 20;
        Height 48;
        Scale 0.05;
        +NOGRAVITY
    }
    States { Spawn: CFBH A -1; Stop; }
}
