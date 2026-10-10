class CA165Checks : StaticEventHandler
{
    int Elapsed,Passed,Failed;
    void Check(String label,bool ok)
    {if(ok)Passed++;else Failed++;Console.Printf("CA165 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        let r=u.GetPersistentCharacterState(false);
        int health=u.health,effect=r.TarotEffectTics,cooldown=r.TarotCooldownTics;
        vector3 position=u.Pos;int items=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)items++;
        Check("legacy checkpoint clears only its stale flash",u.DamageFeedbackRevision==2 && u.DamageVFXStrength==0 && CaelumDamageFeedback.FlashAlpha(u)==0 && health==476);
        Check("checkpoint is at authored MAP02 entry",level.MapName=="MAP02" && Abs(position.X)<32 && Abs(position.Y)<32 && Abs(position.Z)<0.001);
        Check("expired Fool stays expired",effect==0 && u.FindInventory("CaelumTarotFlight")==null);
        int loss=Max(1,int(u.CaelumMaximumHealth*0.1));
        double expected=CaelumDamageFeedback.FLASH_PER_HEALTH_FRACTION*loss/u.CaelumMaximumHealth;
        CaelumDamageFeedback.Record(u,null,'None',loss);
        Check("ordinary hit uses fraction of maximum Health",Abs(CaelumDamageFeedback.FlashAlpha(u)-expected)<0.000001 && u.DamageVFXKind==-1);
        u.DamageVFXTic=level.time-9;
        Check("half-duration fades to half",Abs(CaelumDamageFeedback.FlashAlpha(u)-expected*0.5)<0.000001);
        Check("render fraction continues fade",CaelumDamageFeedback.FlashAlpha(u,0.5)<CaelumDamageFeedback.FlashAlpha(u));
        CaelumDamageFeedback.EnsureRevision(u);
        Check("revision migration is idempotent",Abs(CaelumDamageFeedback.FlashAlpha(u)-expected*0.5)<0.000001);
        CaelumDamageFeedback.Record(u,null,'Fire',loss);
        Check("overlapping hits accumulate remaining flash",Abs(CaelumDamageFeedback.FlashAlpha(u)-expected*1.5)<0.000001 && u.DamageVFXKind==0);
        CaelumDamageFeedback.Record(u,null,'Ice',u.CaelumMaximumHealth);
        Check("large hit capped at authored maximum",CaelumDamageFeedback.FlashAlpha(u)==CaelumDamageFeedback.MAX_FLASH_ALPHA && u.DamageVFXKind==3);
        u.DamageVFXStrength=4;
        Check("renderer bounds malformed strength",CaelumDamageFeedback.FlashAlpha(u)==CaelumDamageFeedback.MAX_FLASH_ALPHA);
        u.DamageVFXTic=level.time-18;
        Check("flash expires at 18 tics",CaelumDamageFeedback.FlashAlpha(u)==0);
        u.DamageVFXTic=level.time+80000;u.DamageVFXStrength=0.032051282;
        Check("future timestamp cannot tint screen",CaelumDamageFeedback.FlashAlpha(u)==0);
        CaelumDamageFeedback.Record(u,null,'Poison',loss);
        Check("new hit cannot inherit a future timestamp",Abs(CaelumDamageFeedback.FlashAlpha(u)-expected)<0.000001 && u.DamageVFXKind==5);
        int nowItems=0;for(Inventory i=u.Inv;i!=null;i=i.Inv)nowItems++;
        Check("visual operations preserve gameplay state",u.health==health && u.Pos==position && r.TarotEffectTics==effect && r.TarotCooldownTics==cooldown && items==nowItems);
        CaelumDamageFeedback.ClearFlash(u);u.PersistCharacterState();
        Console.Printf("CA165 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
