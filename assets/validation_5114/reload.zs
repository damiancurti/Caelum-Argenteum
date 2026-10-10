class CA165Reload : StaticEventHandler
{
    int Elapsed;
    override void WorldTick()
    {
        Elapsed++;if(Elapsed!=20)return;
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        Console.Printf("CA165 %s reload retains repaired visual revision",u.DamageFeedbackRevision==2 && CaelumDamageFeedback.FlashAlpha(u)==0 && u.DamageVFXStrength==0?"PASS":"FAIL");
        Console.Printf("CA165 %s reload keeps Health without loss and entry position",u.health>=476 && u.health<=u.CaelumMaximumHealth && Abs(u.Pos.X)<32 && Abs(u.Pos.Y)<32 && Abs(u.Pos.Z)<0.001?"PASS":"FAIL");
    }
}
