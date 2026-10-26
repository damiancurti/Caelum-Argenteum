class CA412BagLegacy : EventHandler
{
    void Assert(bool ok,String label){Console.Printf("CA412B %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca412b_old_seed')
        {
            u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
            u.CombatTimeRemaining=0;u.SetOrigin((128,128,0),false);u.Vel=(0,0,0);u.Angle=0;
            u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=80;
            CaelumWorldClock.Get(u,true);let p=u.GetPersistentCharacterState(true);p.ProfileCommitted=true;p.WorldPendingConnection=0;
            let bag=CaelumSleepingBag(u.GiveInventoryType('CaelumSleepingBag'));
            Assert(bag!=null && bag.BeginRest(u,5),"baseline native sleeping bag session starts");
            Assert(CaelumRestState.IsSleeping(u),"baseline real session active before save");
        }
        else if(e.Name=='ca412b_old_check')
        {
            let rest=CaelumRestState.Get(u);let bag=CaelumSleepingBag(u.FindInventory('CaelumSleepingBag'));
            Assert(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"old active rest survives load");
            Assert(rest!=null && rest.ElapsedTics>0,"old rest keeps advancing");
            Assert(bag!=null && bag.Amount==1 && bag.Owner==u,"old bag identity quantity and ownership preserved");
            Assert(rest!=null && CaelumRestBag(rest.Furniture)!=null && CaelumRestBag(rest.Furniture).Bag==bag,"old deployed model still points to original bag");
            CaelumRestState.Cancel(u);Assert(!CaelumRestState.IsActive(u),"old rest can release control");
        }
        else if(e.Name=='ca412b_fit_setup')
        {
            u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.SetOrigin((220,64,0),false);
            let tent=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',(128,128,0),NO_REPLACE));tent.Prepare();
        }
        else if(e.Name=='ca412b_fit')
        {
            u.SetOrigin((150,128,0),false);u.Angle=90;u.Vel=(0,0,0);
            bool fits=CaelumRestBag.HasRoom(u);
            Assert(fits==(e.Args[0]!=0),e.Args[0]!=0?"oriented footprint admits unchanged tent berth":"baseline circular footprint reproduces rejected berth");
        }
        else return;
        Console.Printf("CA412B RESULT legacy checks executed");
    }
}
