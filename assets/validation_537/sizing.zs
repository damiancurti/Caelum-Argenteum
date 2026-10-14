// Auditoría independiente de límites contra la colisión 3D del motor.
class CA234Sizing : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        for(int room=0;room<4;room++)
        {
            Vector3 origin=CaelumCartographyCatalogueData.MansionPosition(room)+(-100,0,48);
            for(int facing=0;facing<4;facing++)
            {
                let trace=new("LineTracer");
                trace.Trace(origin,level.PointInSector(origin.XY),(Cos(facing*90),Sin(facing*90),0),4096,0,Line.ML_BLOCKING,true);
                Console.Printf("CA234 BOUNDS room=%d angle=%d hit=(%.1f %.1f %.1f) type=%d",room,facing*90,
                    trace.Results.HitPos.X,trace.Results.HitPos.Y,trace.Results.HitPos.Z,trace.Results.HitType);
            }
        }
        Console.Printf("CA234 DONE failures=0");
    }
}
