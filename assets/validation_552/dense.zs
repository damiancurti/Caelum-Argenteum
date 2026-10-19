// Coste diagnóstico con pares que chocan nativamente; sin cambios en src.
class CA311DenseBody : CA194Moving
{
    override void Tick()
    {
        double started=MSTimeF();
        Super.Tick();
        let probe=CA311Dense(StaticEventHandler.Find("CA311Dense"));
        if(probe!=null){probe.BodyMilliseconds+=MSTimeF()-started;probe.BodyTicks++;}
    }
    override void CollidedWith(Actor other, bool passive)
    {
        double started=MSTimeF();
        Super.CollidedWith(other,passive);
        let probe=CA311Dense(StaticEventHandler.Find("CA311Dense"));
        if(probe!=null){probe.ContactMilliseconds+=MSTimeF()-started;probe.Callbacks++;}
    }
}
class CA311Dense : CA194Combat
{
    Array<CA311DenseBody> Bodies;
    double BodyMilliseconds, ContactMilliseconds;
    int BodyTicks, Callbacks, Mode, Population, Layout;
    bool Running;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="c311_dense")return;
        Mode=e.Args[0];Population=e.Args[1];Layout=e.Args[2];Age=0;Running=true;
        for(int i=0;i<Population;i++)
        {
            int pair=i/2;
            Vector3 p=(-1500+(pair%16)*180+(i%2)*40,-1500+(pair/16)*180,0);
            if(Layout==1)p=(-272+(i%16)*34,-544+(i/16)*34,0);
            let b=CA311DenseBody(Actor.Spawn("CA311DenseBody",p));
            b.CombatToughness=0;b.CombatMaximumHealth=b.health=10000000;
            b.CombatLucidityPhysicalStunRemaining=1000;b.CollisionEffectiveMassMultiplier=b.CollisionDamageMultiplier=1;
            b.CombatArmor=new("CaelumArmorModel");b.CombatArmor.InitializeDefaults();
            b.AnatomyProfile=new("CaelumAnatomyProfile");
            b.AnatomyProfile.AddRegion(CaelumConstants.HIT_LOCATION_TORSO,3,0,1,0,1);
            b.DisableCaelumImpactContacts=Mode==0;b.bNoGravity=true;Bodies.Push(b);
        }
    }
    override void WorldTick()
    {
        if(!Running)return;
        Age++;
        if(Age>105 && Age<=455)
            Console.Printf("CA311 COST mode=%d population=%d layout=%d tic=%d body_ms=%.6f contact_ms=%.6f ticks=%d callbacks=%d",
                Mode,Population,Layout,Age,BodyMilliseconds,ContactMilliseconds,BodyTicks,Callbacks);
        BodyMilliseconds=ContactMilliseconds=0;BodyTicks=Callbacks=0;
        for(int i=0;i<Bodies.Size();i++)
        {
            let b=Bodies[i];int pair=i/2;
            if(Layout==0)
            {
                b.SetOrigin((-1500+(pair%16)*180+(i%2)*40,-1500+(pair/16)*180,0),false);
                b.Vel=(i%2==0?10:-10,0,0);
            }
            else
            {
                b.SetOrigin((-272+(i%16)*34,-544+(i/16)*34,0),false);
                b.Vel=(i%2==0?3:-3,(i/16)%2==0?3:-3,0);
            }
        }
        if(Age==456)
        {
            int living=0,edges=0,unique=0,duplicates=0;
            for(int i=0;i<Bodies.Size();i++)
            {
                let b=Bodies[i];if(b.health>0)living++;
                edges+=b.GetImpactContactCount();unique+=b.ImpactDiagnosticUniquePairTicks;
                duplicates+=b.ImpactDiagnosticDuplicateCallbacks;
            }
            Check("dense population survives",living,Population);
            Check("dense contact mode actually exercised",Mode==0?unique==0:unique>0,1);
            Check("grid has more than independent pairs",Layout==0 || Mode==0 || edges>Population,1);
            Console.Printf("CA311 DENSE mode=%d population=%d layout=%d edges=%d unique=%d duplicates=%d",Mode,Population,Layout,edges,unique,duplicates);
            Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);Running=false;
        }
    }
}
