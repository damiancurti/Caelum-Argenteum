class CA165Baseline : StaticEventHandler
{
    int Elapsed;
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        double age=level.time-u.DamageVFXTic;
        double alpha=u.DamageVFXStrength*Max(0.0,1.0-age/CaelumDamageFeedback.FLASH_TICS);
        Console.Printf("CA165 BASELINE time=%d stamp=%d strength=%.12f alpha=%.12f health=%d pos=%.3f,%.3f,%.3f",level.time,u.DamageVFXTic,u.DamageVFXStrength,alpha,u.health,u.Pos.X,u.Pos.Y,u.Pos.Z);
        Console.Printf("CA165 %s future source-map timestamp amplifies overlay above 1",age<0 && alpha>1?"PASS":"FAIL");
    }
}
