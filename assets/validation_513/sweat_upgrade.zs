class CA133SweatUpgrade : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if(!e.IsSaveGame)return;
        let marker=CA133SweatMarker(ThinkerIterator.Create("CA133SweatMarker").Next());
        if(marker==null){Console.Printf("CA133 FAIL missing migration marker");return;}
        let s=CaelumThermalBody.Get(marker.Body,true);
        bool ok=s.Revision==3 && s.Exposure==marker.Exposure && s.Acclimation==marker.Acclimation
            && s.DamageRemainder==marker.Damage && s.ActorWaterKg[0]==marker.Water
            && s.Hydration==(marker.Revision<3 ? 100 : 43.25);
        s.Hydration=43.25;s.Initialize();s=CaelumThermalBody.Get(marker.Body,true);
        ok=ok && s.Hydration==43.25;
        let user=CaelumPlayer(players[0].mo);let p=CaelumThermalBody.Get(user,true);CaelumThermalBody.Refresh(user,p);
        ok=ok && user.CurrentThirst==marker.Thirst && p.Hydration==marker.Thirst;
        Console.Printf("CA133 %s revision migration preserves old state and initializes finite NPC water only once",ok ? "PASS" : "FAIL");
        Console.Printf("CA133 SWEAT_UPGRADE failures=%d",int(!ok));
    }
}
