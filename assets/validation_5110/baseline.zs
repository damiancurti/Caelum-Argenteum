class CA154FallingProbe : Actor
{
    Default { Radius 1; Height 1; +NOBLOCKMAP }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA154Baseline : StaticEventHandler
{
    int Elapsed;
    Actor Probe;
    override void WorldTick()
    {
        Elapsed++;
        if(Elapsed==10)
        {
            Probe=Actor.Spawn("CA154FallingProbe",(100,0,2000));
            Console.Printf("CA154 BASE levelgravity=%.12f actorgravity=%.12f effective=%.12f",level.gravity,Probe.Gravity,Probe.GetGravity());
        }
        if(Elapsed>=10 && Elapsed<=16)
            Console.Printf("CA154 FALL tick=%d z=%.12f vz=%.12f",Elapsed,Probe.Pos.Z,Probe.Vel.Z);
        if(Elapsed==20)
        {
            level.gravity*=9.81*32/(35*35);
            Probe.SetOrigin((100,0,2000),false);Probe.Vel=(0,0,0);
            Console.Printf("CA154 EARTH levelgravity=%.12f effective=%.12f",level.gravity,Probe.GetGravity());
        }
        if(Elapsed>=20 && Elapsed<=26)
            Console.Printf("CA154 EARTH FALL tick=%d z=%.12f vz=%.12f",Elapsed,Probe.Pos.Z,Probe.Vel.Z);
        if(Elapsed==30)
        {
            Probe.Gravity=0.5;
            Console.Printf("CA154 HALF effective=%.12f",Probe.GetGravity());
            Console.Printf("CA154 BASELINE COMPLETE");
        }
    }
}
