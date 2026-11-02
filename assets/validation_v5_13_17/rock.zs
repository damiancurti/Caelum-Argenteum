// El preparador apunta; ambos lanzamientos llegan por el control nativo User3.
class CA513RockReview : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player!=0)return;
        let p=CaelumPlayer(players[0].mo);if(p==null)return;
        if(e.Name=='ca_review_rock_setup')
        {
            let ledger=CA513ManualState(p.FindInventory('CA513ManualState'));if(ledger==null)return;
            ledger.Place=4;
            p.RefillAnima();CaelumTarotService.Select(p,17);CaelumTarotService.Select(p,19);
        }
        if(e.Name=='ca_review_rock_result')
        {
            let room=CaelumTarotExamples.Get();let cargo=CaelumSunCargo.View(p);
            bool success=room!=null && cargo!=null && cargo.Body==room.HotRock && room.HotRock.Contained;
            Console.Printf("CA513ROCK %s native Tarot contains aimed rock",success?"PASS":"FAIL");
            Console.Printf("CA513ROCK selected=%d active17=%d active19=%d aimed=%s",
                CaelumTarotService.SelectedCount(p.GetPersistentCharacterState(false)),
                CaelumTarotService.IsActive(p.GetPersistentCharacterState(false),17),
                CaelumTarotService.IsActive(p.GetPersistentCharacterState(false),19),
                CaelumMajorTargets.Aim(p)!=null?CaelumMajorTargets.Aim(p).GetClassName():'none');
        }
    }
}
