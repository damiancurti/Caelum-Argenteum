class CA304Corpse : Actor
{
    int Ticks,Ordinal;
    override void Tick(){Ticks++;Super.Tick();}
    Default { Monster;Radius 2;Height 8;Health 10;-COUNTKILL +NOGRAVITY }
    States
    {
    Spawn: TNT1 A -1;Stop;
    Death: TNT1 A 1 A_NoBlocking;TNT1 A -1;Stop;
    }
}
class CA304Possession : Inventory
{
    int Ticks;
    override void Tick(){Ticks++;Super.Tick();}
    Default { Inventory.MaxAmount 20; }
}
class CA304Corpses : EventHandler
{
    Array<CA304Corpse> Bodies;
    Actor Loot;
    int Passed,Failed,BodyTicks,ItemTicks;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA304 %s %s",ok?"PASS":"FAIL",label);}
    void Seed()
    {
        for(int i=0;i<105;i++)
        {
            let body=CA304Corpse(Actor.Spawn("CA304Corpse",(500+i*8,1000,0)));
            Bodies.Push(body);
            body.Ordinal=i;
            let item=CA304Possession(body.GiveInventoryType("CA304Possession"));item.Amount=3;
            body.health=0;body.Die(null,null,DMG_FORCED,'None');
        }
        Loot=Actor.Spawn("CaelumShieldPickup",(400,1000,0));
    }
    void Counts()
    {
        Bodies.Resize(105);
        int active=0,hidden=0;
        let it=ThinkerIterator.Create("CA304Corpse");CA304Corpse body;
        while((body=CA304Corpse(it.Next()))!=null)
        {Bodies[body.Ordinal]=body;if(body.health<=0){if(CaelumCorpseArchive.Suspended(body))hidden++;else active++;}}
        it=ThinkerIterator.Create("CA304Corpse",CaelumCorpseArchiveData.DORMANT_STAT);
        while((body=CA304Corpse(it.Next()))!=null)
        {Bodies[body.Ordinal]=body;if(body.health<=0 && CaelumCorpseArchive.Suspended(body))hidden++;}
        Loot=Actor(ThinkerIterator.Create("CaelumShieldPickup").Next());
        Check(active==100 && hidden==5,"100 active and 5 suspended corpses; explicit static lookup finds archives");
        Check(CaelumCorpseArchive.Suspended(Bodies[0]) && CaelumCorpseArchive.Suspended(Bodies[4])
            && !CaelumCorpseArchive.Suspended(Bodies[5]) && !CaelumCorpseArchive.Suspended(Bodies[104]),"FIFO retains latest deaths");
        Check(Bodies[0].bInvisible && Bodies[0].bNoInteraction && Bodies[0].bNOSECTOR
            && Bodies[0].bNOBLOCKMAP && !Bodies[0].bSolid,"archived bodies leave rendering and collision");
        Check(Loot!=null && !Loot.bDestroyed && !Loot.bInvisible,"dropped loot remains");
        BodyTicks=Bodies[0].Ticks;
        let item=CA304Possession(Bodies[0].FindInventory("CA304Possession"));ItemTicks=item.Ticks;
        Check(item.Amount==3 && item.Owner==Bodies[0],"original inventory retained");
    }
    void Frozen()
    {
        let item=CA304Possession(Bodies[0].FindInventory("CA304Possession"));
        Check(Bodies[0].Ticks==BodyTicks && item.Ticks==ItemTicks,"body and inventory execute no simulation ticks");
        Check(CaelumResurrection.Restore(Bodies[0],(500,1500,0)),"native resurrection accepts archived body");
        Check(Bodies[0].health>0 && !Bodies[0].bInvisible && !Bodies[0].bNoInteraction
            && !Bodies[0].bNOSECTOR && !Bodies[0].bNOBLOCKMAP,"resurrection restores world links and presentation");
        Check(item.Amount==3 && item.Owner==Bodies[0],"resurrection does not duplicate inventory");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c304_seed")Seed();
        else if(e.Name=="c304_counts")Counts();
        else if(e.Name=="c304_frozen")Frozen();
        else if(e.Name=="c304_resumed")
        {
            let item=CA304Possession(Bodies[0].FindInventory("CA304Possession"));
            Check(Bodies[0].Ticks>BodyTicks && item.Ticks>ItemTicks,"native ticks resume after resurrection");
            Bodies[0].health=0;Bodies[0].Die(null,null,DMG_FORCED,'None');
        }
        else if(e.Name=="c304_redeath")
        {let a=CaelumCorpseArchive.Get();
            Console.Printf("CA304 ARCHIVE recent=%d pending=%d archived=%d first=%d zeroHidden=%d fiveHidden=%d dead=%d corpse=%d",a.Recent.Size(),a.Pending.Size(),a.ArchivedCount,a.Recent.Size()>0?CA304Corpse(a.Recent[0]).Ordinal:-1,CaelumCorpseArchive.Suspended(Bodies[0]),CaelumCorpseArchive.Suspended(Bodies[5]),Bodies[0].health,Bodies[0].bCorpse);
            Check(!CaelumCorpseArchive.Suspended(Bodies[0]) && CaelumCorpseArchive.Suspended(Bodies[5]),"new death returns at newest FIFO position");}
        else if(e.Name=="c304_loaded")Counts();
        else if(e.Name=="c304_outside")
        {
            int active=0;let it=ThinkerIterator.Create("CA304Corpse");while(it.Next()!=null)active++;
            Check(active==105 && CaelumCorpseArchive.Get()==null,"other maps preserve all 105 ordinary corpses");
        }
        else if(e.Name=="c304_playerdie")
        {let user=players[0].mo;user.health=user.player.health=0;user.Die(null,null,DMG_FORCED,'None');}
        else if(e.Name=="c304_playercheck")
        {
            let a=CaelumCorpseArchive.Get();
            Check(a.Recent.Size()==100 && a.Recent.Find(players[0].mo)<a.Recent.Size()
                && !CaelumCorpseArchive.Suspended(players[0].mo),"current dead player stays visible within total corpse cap");
        }
        else if(e.Name=="c304_redemption")
        {
            let user=CaelumPlayer(players[0].mo);user.SetOrigin((500,1500,0),false);
            let effect=CaelumRedemptionEffect(user.GiveInventoryType("CaelumRedemptionEffect"));
            effect.Revision=CaelumRedemption.REVISION;effect.RemainingTics=350;
            effect.PulseTics=35;effect.Range=4000;effect.Power=1;
            CaelumRedemption.Pulse(effect);
            int alive=0;for(int i=0;i<Bodies.Size();i++)if(Bodies[i].health>0)alive++;
            Console.Printf("CA304 REDEMPTION alive=%d raised=%d",alive,effect.RaisedThisCast.Size());
            Check(alive==105,"Redemption discovers and restores all 105 bodies across native thinker lists");
            Check(!CaelumCorpseArchive.Suspended(Bodies[1]),"Redemption resumes archived simulation");
        }
        else if(e.Name=="c304_done")Console.Printf("CA304 DONE failures=%d passes=%d",Failed,Passed);
    }
}
