// Diagnostic bridge compiled against the unmodified previous release.
class CA410ReadingChecks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=='ca410rd_profile')
        {
            u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
            u.GetPersistentCharacterState(true).ProfileCommitted=true;
            u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);return;
        }
        if(e.Name!='ca410rd_oldseed' && e.Name!='ca410rd_rollback')return;
        let shelf=CaelumReadingShelf(ThinkerIterator.Create('CaelumReadingShelf').Next());
        bool okay=shelf!=null;
        if(e.Name=='ca410rd_oldseed' && okay)
        {
            u.SetOrigin(shelf.Pos+(-64,0,0),false);u.Vel=(0,0,0);
            let book=CaelumRecipeBook(Actor.Spawn('CaelumRecipeBook',u.Pos,NO_REPLACE));
            book.Sheets[0]=true;book.AttachToOwner(u);
            okay=CaelumRecipeSession.OpenBook(u,book) && CaelumRecipeSession.Get(u).Start();
            let reading=CaelumRecipeSession.Get(u);reading.RemainingSeconds=77.125;reading.Open=false;
        }
        let book=CaelumRecipeBook(u.FindInventory('CaelumRecipeBook'));let reading=CaelumRecipeSession.Get(u);
        okay=okay && book!=null && book.Sheets[0] && book.Owner==u && reading!=null
            && reading.Active && reading.Book==book && Abs(reading.RemainingSeconds-77.125)<.000001;
        Console.Printf("CA410RD %s original package retains carried book and reading",okay?"PASS":"FAIL");
        Console.Printf("CA410RD RESULT passed=%d failed=%d",int(okay),int(!okay));
    }
}
