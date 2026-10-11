class CA195LegacyBull : CaelumBull { override void Tick(){} }
class CA195LegacyRulo : CaelumRulo { override void Tick(){} }
class CA195Legacy : StaticEventHandler
{
    int Age,Passes,Failures;
    bool Loaded;
    CaelumBull Bull;
    CaelumRulo Resident;
    override void WorldLoaded(WorldEvent e){Loaded=e.IsSaveGame;Age=0;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(String label,bool ok)
    {if(ok)Passes++;else Failures++;Console.Printf("CA195 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Age++;
        if(!Loaded && Age==5)
        {
            Bull=CaelumBull(Actor.Spawn("CA195LegacyBull",(0,0,0)));Bull.ChangeTid(44951);
            Resident=CaelumRulo(Actor.Spawn("CA195LegacyRulo",(800,0,0)));Resident.ChangeTid(44952);
        }
        if(!Loaded && Age==6)
        {
            Bull.target=Resident;Bull.BeginBullCharge();Bull.Vel=(20,0,0);
            Resident.StoryAnchored=true;Resident.health=888;Resident.CurrentCombatAir=333;
            Check("baseline charge doubled mass",Bull.GetCollisionEffectiveMass()==1800);
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
        if(Loaded && Age==1)
        {
            Bull=CaelumBull(ActorIterator.Create(44951,"CA195LegacyBull").Next());
            Resident=CaelumRulo(ActorIterator.Create(44952,"CA195LegacyRulo").Next());
            Check("legacy actors survive",Bull!=null && Resident!=null);
            Check("active old charge natural mass",Bull.GetCollisionEffectiveMass()==900);
            Check("active old charge capped",Bull.Vel.XY.Length()<=10*32.0/35+0.000001);
            Check("active old charge retained",Bull.BullChargeActive);
            Check("resident health retained",Resident.health==888);
            Check("resident air retained",Resident.CurrentCombatAir==333);
            Check("resident tools included once",Abs(Resident.GetCollisionEffectiveMass()-315.527)<0.000001);
            Check("personality restored",CaelumPersonalityRules.Pack(CaelumPersonalityRules.Profile(Resident))==0);
            Console.Printf("CA195 DONE failures=%d passes=%d",Failures,Passes);
        }
    }
}
