class CA136Rollback : StaticEventHandler
{
    int Delay;
    override void WorldLoaded(WorldEvent e){if(level.MapName=="CA136")Delay=10;}
    override void WorldTick()
    {
        if(Delay<=0 || --Delay>0)return;
        let marker=CA136Saved(ThinkerIterator.Create("CA136Saved").Next());
        let user=CaelumPlayer(players[0].mo);
        bool ok=marker!=null && marker.Gun!=null && marker.Boxed!=null
            && marker.Gun.Durability==marker.OldDurability && user.WeaponModel.Durability==marker.OldDurability
            && marker.Boxed.Durability==marker.OldBoxedDurability && marker.Boxed.InMagicBox
            && user.StandardBowMagazine==23 && user.FindNativeAmmunition(1).Amount==41;
        Console.Printf("CA136 %s preserved original save reloads with old executable content",ok ? "PASS" : "FAIL");
        Console.Printf("CA136 COMPLETE checks=1 failures=%d",ok ? 0 : 1);
    }
}
