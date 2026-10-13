// Isolated native death probe; not included in production.
class CA220Loot : StaticEventHandler
{
    int Failures;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA220 %s %s",ok?"PASS":"FAIL",label);}
    int Pickups()
    {
        int n=0;let it=ThinkerIterator.Create("Inventory");Inventory item;
        while((item=Inventory(it.Next()))!=null)if(item.Owner==null)n++;
        return n;
    }
    int Supply(CaelumCombatActor npc)
    {
        int n=0;for(int family=0;family<3;family++)
        {let item=CaelumDemonService.Potion(npc,family);if(item!=null)n+=item.Amount;}
        return n;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c220_reload")
        {
            let user=CaelumPlayer(players[e.Player].mo);
            let corpse=CaelumMandinga(ActorIterator.Create(47009,"CaelumMandinga").Next());
            Check(corpse!=null && corpse.health<=0 && corpse.MazeDropReleased && corpse.DemonDeathLootReleased,"dead carrier retains both saved death latches");
            int before=Pickups();corpse.Die(user,user,0,'None');
            Check(Pickups()==before,"loaded corpse cannot duplicate loot");
            let living=CaelumMandinga(ActorIterator.Create(47012,"CaelumMandinga").Next());
            Check(living!=null && living.health>0 && Supply(living)>0,"saved living unassigned carrier retains supplies");
            living.DamageMobj(user,user,1000000000,'None',DMG_FORCED);
            Check(living.health<=0 && Pickups()==before+1,"saved living carrier releases one potion on actual death");
            Console.Printf("CA220 DONE failures=%d",Failures);return;
        }
        if(e.Name!="c220_test")return;
        let user=CaelumPlayer(players[e.Player].mo);
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.ApplyCharacterProfile();user.GetPersistentCharacterState(true).ProfileCommitted=true;
        Check(CaelumMazeLayout.IsCardinal(),"actual cardinal MAP02 loaded");
        let npc=CaelumMandinga(ActorIterator.Create(47009,"CaelumMandinga").Next());
        Check(npc!=null && npc.health>0,"unassigned mapped Mandinga is alive");
        Check(CaelumDemonService.Potion(npc,0)!=null,"unassigned Mandinga has remaining potions");
        Check(!CaelumMazeLayout.HasDeathDrop(47009),"unassigned Mandinga has no predefined drop");
        int before=Pickups(),supply=Supply(npc);npc.DamageMobj(user,user,1000000000,'None',DMG_FORCED);
        Check(npc.health<=0,"native damage killed unassigned Mandinga");
        Check(Pickups()==before+1,"unassigned Mandinga releases one remaining potion");
        Check(Supply(npc)==supply-1,"drop consumes exactly one remaining native supply unit");
        before=Pickups();npc.Die(user,user,0,'None');
        Check(Pickups()==before,"duplicate death callback does not duplicate potion");
        npc=CaelumMandinga(ActorIterator.Create(47000,"CaelumMandinga").Next());
        vector3 anchor=npc.Pos;npc.SetOrigin(anchor+(0,96,0),false);
        Check(CaelumMazeLayout.HasDeathDrop(47000),"ammo carrier has predefined assignment");
        before=Pickups();npc.DamageMobj(user,user,1000000000,'None',DMG_FORCED);
        Check(Pickups()==before+1,"ammo carrier releases exactly one drop without potion");
        let it=ThinkerIterator.Create("CaelumArrowAmmo");Inventory item;bool found=false;
        while((item=Inventory(it.Next()))!=null)
            if(item.Owner==null && item.Amount==20 && (item.Pos-anchor).Length()<2)found=true;
        Check(found,"ammo appears at original dry recovery anchor after carrier moved");
        npc=CaelumMandinga(ActorIterator.Create(47001,"CaelumMandinga").Next());
        before=Pickups();npc.DamageMobj(user,user,1000000000,'None',DMG_FORCED);
        Check(npc.health<=0 && Pickups()==before+1,"key carrier releases one assigned key without potion");
        let keys=ThinkerIterator.Create("CaelumMazeSouthCellKey");bool keyFound=false;
        while((item=Inventory(keys.Next()))!=null)if(item.Owner==null && item.Amount==1)keyFound=true;
        Check(keyFound,"actual southern cell key remains recoverable");
        npc=CaelumMandinga(ActorIterator.Create(47010,"CaelumMandinga").Next());
        for(int family=0;family<3;family++)
        {let potion=CaelumDemonService.Potion(npc,family);if(potion!=null)potion.Destroy();}
        before=Pickups();npc.DamageMobj(user,user,1000000000,'None',DMG_FORCED);
        Check(npc.health<=0 && Pickups()==before,"exhausted Mandinga drops no invented potion");
        npc=CaelumMandinga(ActorIterator.Create(47011,"CaelumMandinga").Next());
        for(int family=0;family<3;family++)
        {let potion=CaelumDemonService.Potion(npc,family);if(potion!=null){if(family!=1)potion.Destroy();else potion.Amount=1;}}
        before=Pickups();npc.DamageMobj(user,user,1000000000,'None',DMG_FORCED);
        Check(npc.health<=0 && Pickups()==before+1 && Supply(npc)==0,"last remaining potion transfers once and exhausts stock");
        let rat=ActorIterator.Create(48000,"CaelumGiantRat").Next();before=Pickups();
        rat.DamageMobj(user,user,1000000000,'None',DMG_FORCED);
        Check(rat.health<=0 && Pickups()==before+1,"rat still releases its single ration");
        Console.Printf("CA220 DONE failures=%d",Failures);
    }
}
