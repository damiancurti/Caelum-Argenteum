// Same fixture classes compile against both 5.2.10 and 5.2.11.
class CA194LegacyBody : CaelumCombatActor
{
    override void Tick() {}
    Default { Radius 16; Height 56; Mass 80; Health 1000000; +NOGRAVITY; +SHOOTABLE; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA194Legacy : StaticEventHandler
{
    int Age,Passes,Failures;
    bool Loaded;
    override void WorldLoaded(WorldEvent event){Loaded=event.IsSaveGame;Age=0;}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    void Check(String label,bool ok)
    {
        if(ok)Passes++;else Failures++;
        Console.Printf("CA194 %s %s",ok?"PASS":"FAIL",label);
    }
    override void WorldTick()
    {
        Age++;if(Age!=10)return;
        if(!Loaded)
        {
            let a=CaelumCombatActor(Actor.Spawn("CA194LegacyBody",(0,0,0)));
            let b=CaelumCombatActor(Actor.Spawn("CA194LegacyBody",(32,0,0)));
            a.ChangeTid(44942);b.ChangeTid(44943);
            a.LatchImpactContact(b);
            let pressure=CaelumWeightPressure(a.GiveInventoryType("CaelumWeightPressure"));
            pressure.DamageCarry=123.456;pressure.ContactTics=20;
            Check("legacy checkpoint actors",a!=null && b!=null);
        }
        else
        {
            let a=CaelumCombatActor(ActorIterator.Create(44942,"CA194LegacyBody").Next());
            let b=CaelumCombatActor(ActorIterator.Create(44943,"CA194LegacyBody").Next());
            Check("old actors loaded",a!=null && b!=null);if(a==null || b==null)return;
            let c=a.GetImpactContactState(b);
            Check("old contact graph loaded",c!=null && c==b.GetImpactContactState(a));
            let p=CaelumWeightPressure(a.FindInventory("CaelumWeightPressure"));
            Check("old percentage carry loaded",p!=null && Abs(p.DamageCarry-123.456)<0.00001);
            int before=a.health;a.bSolid=true;CaelumWeightPressure.Update(a);
            Check("old carry reset without HP conversion",p.DamageCarry==0 && a.health==before);
            CaelumWeightPressure.Update(a);Check("migration idempotent",p.DamageCarry==0 && a.health==before);
            a.CollidedWith(b,false);b.CollidedWith(a,true);
            Check("loaded resting contact no replay",a.health==before && b.health==1000000);
        }
        Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
    }
}
