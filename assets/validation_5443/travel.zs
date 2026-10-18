// Un inventario de prueba observa los viajes nativos de cuerpos y suscripciones.
class CA353Journey : Inventory
{
    int Stage,Passes,Failures;
    CaelumHouseResident Resident;
    CaelumSummonedZupay Summon;
    CaelumCombatActor Convert;
    CaelumSiegeCombatant Leader;
    CaelumActorMaintenance OldResidentCache,OldSummonCache,OldConvertCache;
    int ResidentHP,SummonHP,ConvertHP;
    int SummonUnits,ConvertUnits;
    void Check(bool valid,String label)
    { if(valid)Passes++;else{Failures++;Console.Printf("CA282 FAIL %s",label);} }
    void CreateBodies()
    {
        let roster=CaelumHouseResidents.Get(true);roster.EnsureRecords();
        roster.CreateResident(0,(2048,0,0));Resident=roster.Residents[0];
        Resident.Body.bInvulnerable=true;Resident.Body.bDormant=true;
        let summonEffect=CaelumSummoningEffect(Owner.GiveInventoryType("CaelumSummoningEffect"));
        Summon=CaelumSummonedZupay(Actor.Spawn("CaelumSummonedZupay",(4096,0,0),NO_REPLACE));
        summonEffect.Revision=CaelumSummoning.REVISION;summonEffect.Power=1;summonEffect.Range=2048;summonEffect.RemainingTics=35000;
        summonEffect.Body=Summon;Summon.Binding=summonEffect;Summon.SummonPower=1;
        Summon.bInvulnerable=true;Summon.bDormant=true;Summon.master=Owner;Summon.SetFriendPlayer(Owner.player);
        let effect=CaelumRedemptionEffect(Owner.GiveInventoryType("CaelumRedemptionEffect"));
        effect.Revision=CaelumRedemption.REVISION;effect.RemainingTics=35000;effect.Power=1;effect.Range=2048;
        Convert=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(6144,0,0),NO_REPLACE));
        Convert.bInvulnerable=true;Convert.bDormant=true;
        let bond=CaelumRedemptionBody(Convert.GiveInventoryType("CaelumRedemptionBody"));bond.Remember();bond.Convert(effect);effect.Converts.Push(bond);
        Stage=1;
    }
    void Prepare()
    {
        Check(Resident.Body.CombatProfileInitialized && Summon.CombatProfileInitialized && Convert.CombatProfileInitialized,"native travel profiles initialized");
        CaelumPopulationState.Get().HighDensity=true;
        OldResidentCache=Resident.Body.GetActorMaintenance();OldSummonCache=Summon.GetActorMaintenance();OldConvertCache=Convert.GetActorMaintenance();
        OldResidentCache.HealthDue=OldSummonCache.HealthDue=OldConvertCache.HealthDue=level.maptime+10000;
        ResidentHP=Resident.Body.health;SummonHP=Summon.health;ConvertHP=Convert.health;
        SummonUnits=CaelumDemonService.Potion(Summon,0).Amount;ConvertUnits=CaelumDemonService.Potion(Convert,0).Amount;
        Leader=new("CaelumSiegeCombatant");Leader.SharedTarget=Owner;Leader.SharedTargetValid=true;Leader.SharedTargetWasPresent=true;
        CaelumTargetSubscriptions.Watch(Leader);
        Check(CaelumPlayer(Owner).TargetSubscribers.Users.Size()==1,"live player subscription before map travel");
        Stage++;
    }
    void Verify()
    {
        Check(Resident!=null && Resident.Body!=null && Summon!=null && Convert!=null,"same real bodies survive map travel");
        Check(Resident.Body.health==ResidentHP && Summon.health==SummonHP && Convert.health==ConvertHP,"travel retains health");
        Check(CaelumDemonService.Potion(Summon,0).Amount==SummonUnits && CaelumDemonService.Potion(Convert,0).Amount==ConvertUnits,"travel retains finite inventory");
        Check(!Leader.SharedTargetValid && Leader.SharedTargetSubscription==null,"player PreTravelled invalidates old-map subscription");
        Check(CaelumPlayer(Owner).TargetSubscribers==null || CaelumPlayer(Owner).TargetSubscribers.Users.Size()==0,"no retained old-map subscribers");
        Check(Resident.Resume((2048,0,0)),"house resident actual resume");
        CaelumPopulationState.Get().HighDensity=true;
        let a=Resident.Body.GetActorMaintenance();let b=Summon.GetActorMaintenance();let c=Convert.GetActorMaintenance();
        Check(a!=OldResidentCache && b!=OldSummonCache && c!=OldConvertCache,"travel replaces map-local caches");
        Check(a.NextDue()<=level.maptime+100 && b.NextDue()<=level.maptime+100 && c.NextDue()<=level.maptime+100,"new map deadline bound");
        Console.Printf("CA353 TRAVEL stage=%d map=%s passes=%d failures=%d",Stage,level.MapName,Passes,Failures);
        if(Failures==0)Console.Printf("CA282 DONE passes=%d failures=0",Passes);
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA353TravelProbe : EventHandler
{
    int Age;
    override void WorldLoaded(WorldEvent e) { Age=0; }
    override void WorldTick()
    {
        Age++;let user=CaelumPlayer(players[0].mo);if(user==null)return;
        if(Age==5 && user.FindInventory("CA353Journey")==null)
        {user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();user.bInvulnerable=true;}
        let journey=CA353Journey(user.FindInventory("CA353Journey"));
        if(Age==5 && journey!=null && journey.Stage>=2)journey.Verify();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=players[0].mo;if(user==null)return;
        let journey=CA353Journey(user.FindInventory("CA353Journey"));
        if(e.Name=="ca353_travel_create")
        {journey=CA353Journey(user.GiveInventoryType("CA353Journey"));journey.CreateBodies();}
        if(e.Name=="ca353_travel_prepare")journey.Prepare();
        if(e.Name=="ca353_travel_verify")journey.Verify();
    }
}
