class CA143Upgrade : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="CA143" || (!e.IsSaveGame && !e.IsReopen))return;
        let marker=CA143LegacyMarker(ThinkerIterator.Create("CA143LegacyMarker").Next());
        if(marker==null)return;
        let body=marker.Body;let carbine=body.Carbine;bool first=carbine.Revision==1;
        carbine.Initialize(body);carbine.Initialize(body);
        bool shared=carbine.Revision==2 && carbine.Holder==body && carbine.StandingHeight==marker.FullHeight
            && carbine.Magazine==3 && carbine.ReloadRemaining==1.25 && carbine.Weapon.Durability==marker.Durability;
        if(first)
        {
            Console.Printf("CA143 MIGRATION failures=%d",int(!(shared && !carbine.Crouched && !carbine.Aiming && body.Height==marker.FullHeight)));
            carbine.SetCrouched(body,true);carbine.Aiming=true;
        }
        else
            Console.Printf("CA143 POSTURE saved=%d reopened=%d failures=%d",e.IsSaveGame,e.IsReopen,
                int(!(shared && carbine.Crouched && carbine.Aiming && body.Height==marker.FullHeight*0.5)));
    }
}
