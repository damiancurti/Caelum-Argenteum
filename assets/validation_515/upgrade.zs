class CA135Upgrade : StaticEventHandler
{
    override void WorldLoaded(WorldEvent e)
    {
        if(level.MapName!="CA135")return;
        let marker=CA135Marker(ThinkerIterator.Create("CA135Marker").Next());
        if(marker==null)return;
        let body=marker.Body;bool first=body.DemonSupplyRevision==0;
        CaelumDemonService.Initialize(body);CaelumDemonService.Initialize(body);
        if(first)
        {
            bool initial=true;
            for(int i=0;i<3;i++)initial=initial && CaelumDemonService.Potion(body,i)!=null && CaelumDemonService.Potion(body,i).Amount==6;
            let effect=CaelumRegenerationPower(body.FindInventory("CaelumLifeRegeneration"));
            Console.Printf("CA135 MIGRATION failures=%d",int(!(initial && body.DemonSupplyRevision==1
                && effect!=null && effect.PotionTotalRatio==0 && body.health==marker.SavedHealth
                && body.CurrentCombatAnima==marker.Anima && body.ThermalState.Exposure==marker.Exposure)));
            CaelumDemonService.Potion(body,0).Amount=2;
            CaelumDemonService.Potion(body,1).Destroy();
        }
        else
        {
            Console.Printf("CA135 PERSISTENCE saved=%d reopened=%d failures=%d",e.IsSaveGame,e.IsReopen,
                int(!(CaelumDemonService.Potion(body,0).Amount==2 && CaelumDemonService.Potion(body,1)==null
                && CaelumDemonService.Potion(body,2).Amount==6 && body.DemonSupplyRevision==1)));
        }
    }
}
