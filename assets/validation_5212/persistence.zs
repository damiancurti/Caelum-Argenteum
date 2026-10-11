class CA195PersistentRulo : CaelumRulo { override void Tick(){} }
class CA195PersistentBull : CaelumM00Bull { override void Tick(){} }
class CA195Persistence : StaticEventHandler
{
    int Age,Passes,Failures;
    bool Loaded;
    CaelumAnchoredResident Npc;
    CaelumM00Bull Bull;
    override void WorldLoaded(WorldEvent e){Loaded=e.IsSaveGame;Age=0;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(String label,bool ok)
    {if(ok)Passes++;else Failures++;Console.Printf("CA195 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Age++;
        if(!Loaded && Age==5)
        {
            Npc=CaelumAnchoredResident(Actor.Spawn("CA195PersistentRulo",(0,0,0)));Npc.ChangeTid(44953);
            Bull=CaelumM00Bull(Actor.Spawn("CA195PersistentBull",(60,0,0)));Bull.ChangeTid(44954);
        }
        if(!Loaded && Age==6)
        {
            Npc.StoryAnchored=true;Npc.EnsureResidentTools();Npc.RuloPartyBull=Bull;Npc.RuloPartyMode=2;Npc.target=Bull;
            Bull.TrialReleased=true;Bull.bShootable=true;Bull.bInvulnerable=false;
            let kit=Npc.ResidentTools;kit.Equip(kit.Bolas);
            let flight=CaelumBolas.ThrowItem(Npc,kit.Bolas,35);flight.AttachVictim(Bull);
            kit.BeginMelee(false,true);kit.ChargeRemaining=1.234;kit.Melee.Durability=123;
            kit.Staff.UtilityStaffContactTics=17;
            Check("checkpoint ready",kit.Phase==kit.CHARGE_PREPARATION && CaelumBolas.Restrained(Bull));
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
        if(Loaded && Age==1)
        {
            Npc=CaelumAnchoredResident(ActorIterator.Create(44953,"CA195PersistentRulo").Next());
            Bull=CaelumM00Bull(ActorIterator.Create(44954,"CA195PersistentBull").Next());
            let kit=Npc.ResidentTools;Check("kit owner retained",kit.Owner==Npc);
            Check("charge remaining retained",Abs(kit.ChargeRemaining-1.234)<0.000001);
            Check("charged selection retained",kit.Charged && kit.Phase==kit.CHARGE_PREPARATION);
            Check("wear retained",kit.Melee.Durability==123 && kit.Staff.UtilityStaffContactTics==17);
            let flight=CaelumBolas.Binding(Bull);
            Check("binding graph retained",flight!=null && flight.SourceItem==kit.Bolas && kit.Bolas.Owner==flight);
            int before=kit.Melee.Durability;Npc.EnsureResidentTools();Npc.EnsureResidentTools();
            Check("ensure does not replenish",kit.Melee.Durability==before && kit.Bolas.Owner==flight);
            Check("carried mass excludes thrown item",Abs(Npc.GetCollisionEffectiveMass()-314)<0.000001);
            kit.Tick();Check("saved charge resumes",kit.ChargeRemaining<1.234 && kit.ChargeRemaining>1.2);
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
