// Preparación aislada de la revisión del autor; no se distribuye en el PK3.
class CA59Manual : EventHandler
{
    Array<CaelumAnchoredResident> People;
    CaelumPortDefender Guard;
    CaelumRentalAgent Agent;
    CaelumCityMerchant Vendor;
    int Mode;
    void PeopleSetup(CaelumPlayer u,int count)
    {
        Class<Actor> kinds[4]={"CaelumPrisonerUnitario","CaelumPrisonerFederal","CaelumPrisonerBestia","CaelumPrisonerTarot"};
        let r=u.GetPersistentCharacterState(true);
        let registry=CaelumSiegeEvents(EventHandler.Find("CaelumSiegeEvents"));
        for(int i=0;i<count;i++)
        {
            let p=CaelumAnchoredResident(Actor.Spawn(kinds[i],(96,i*120,0)));
            p.EscortPrisonerPort=true;p.Angle=180;People.Push(p);
            r.SetPrisonerRescueState(i,CaelumConstants.PRISONER_STATE_EXTRACTED);r.MarkPrisonerRewardClaimed(i);
            if(registry!=null)registry.RegisterPortPerson(p);
        }
        if(registry!=null)registry.SyncPortSurvivors();
    }
    void Setup(CaelumPlayer u,int mode)
    {
        self.Mode=mode;u.player.cheats|=CF_GODMODE;u.SetOrigin((0,0,0),false);u.Angle=0;u.Pitch=0;
        u.GrantMagicBoxFromPalomo(false);u.BuildPalomoCurrencyCreditPlan(250000);u.ApplyPalomoCurrencyPlan();
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeRevision=1;r.DemoNarrativeDelivered=2047;
        r.InitializeNewFactionState();CaelumPortQuests.Ensure(r);
        if(mode==419 || mode==420 || mode==421 || mode==422 || mode==4222 || mode==4211 || mode==4212)
        {
            PeopleSetup(u,mode==419?1:4);
            if(mode==419){r.SetFactionMembership(0,true);r.SetFactionMembership(1,true);u.Attributes.Empathy=0;}
            if(mode==4211 || mode==4212)r.PortSiegeNarrativeStarted=true;
            if(mode==4212)r.PortSiegeNarrativeComplete=true;
            Guard=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(-100,150,0)));
            Guard.HomeRevision=1;Guard.HomeIdentity=2;Guard.DeploymentComplete=true;Guard.Station=Guard.Pos;Guard.Angle=270;
            if(mode==422 || mode==4222)
            {
                if(mode==4222)
                {
                    CaelumPropertyRules.Acquire(u,69,false);CaelumPropertyRules.Acquire(u,69,false);CaelumPropertyRules.Acquire(u,69,true);
                    Console.Printf("CA59 paid history: two rentals and one purchase; expected restitution refund=102000 copper");
                }
                Agent=CaelumRentalAgent(Actor.Spawn("CaelumRentalAgent",(0,-48,0)));
                u.Angle=270;Agent.Angle=90;CaelumRentalAgent.Open(u,Agent);
            }
            else CaelumPrisonerRescue.OpenDialogue(u,People[0]);
        }
        if(mode==424)
        {
            Vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(48,0,0)));
            Vendor.Category=2;Vendor.ShopIdentity=-1;Vendor.WalletCopper=100000;
            Vendor.AccessCondition=CaelumFactionCondition.Create(0,-1000);
            Vendor.SeedSimple('CaelumCarbineAmmo',200);
            CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);
        }
        u.PersistCharacterState();Console.Printf("CA59 READY issue=%d; E=usar, TAB=Diario; escenario aislado",mode);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca59_setup")Setup(u,e.Args[0]);
        if(e.Name=="ca59_rank" && Vendor!=null)
        {
            u.ClosePalomoMerchant();u.GetPersistentCharacterState(true).FactionReputation[0]=e.Args[0];
            CaelumMerchantCoordinator.OpenCityTrade(u,Vendor);
        }
        if(e.Name=="ca59_verify")
        {
            if(Mode==424)Console.Printf("CA59 DETAIL box=%d wizard=%d menu=%d vendorhealth=%d distance=%.2f session=%d",u.MagicBoxOwned,u.CreationWizardOpen,u.PalomoMerchantMenuOpen,Vendor.health,u.Distance3D(Vendor),u.CityTrade!=null);
            bool blocked=Mode==424 && u.GetPersistentCharacterState(false).FactionReputation[0]<=-250;
            bool ok=Mode==424?Vendor!=null && (blocked?u.CityTrade==null:u.CityTrade!=null):People.Size()>0 && People[0].EscortPrisonerPort;
            if(Mode==422 || Mode==4222)ok=ok && Agent!=null && u.GetPersistentCharacterState(false).QuestState[10]==1;
            Console.Printf("CA59 %s setup and authoritative interaction",ok?"PASS":"FAIL");
        }
    }
}
