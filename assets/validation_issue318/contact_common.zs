// Isolated owned test actors. No autonomous simulation obscures saved energy.
class CA318HeatBody : CaelumMandinga { override void Tick() {} }
class CA318HeatHolder : Actor
{
    CaelumCombatActor Demon,Victim,Far,Side,Wall;
    CaelumDemonBreath Stream;
    double Watts,Remaining,Pending,Exposure,Continuous,TotalPaid;
    Default { +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
