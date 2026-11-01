class CA614SavedProbe : Actor
{
    int ExpectedReady,ExpectedKind,ExpectedTier;
    CaelumEquipmentItem Item;
    Default {+NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA614MatchProbe : StaticEventHandler
{
    bool Done;
    CA614SavedProbe Saved;
    void Check(bool ok,String label){Console.Printf("CA614 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        let m=CaelumStandaloneMatch.View();if(m==null || Done)return;
        if(m.Hunt!=null)m.Hunt.Hunter.bDormant=true;
        if(Saved==null)
        {
            let it=ThinkerIterator.Create('CA614SavedProbe');Saved=CA614SavedProbe(it.Next());
            Check(Saved!=null && m.Powerups!=null,"saved registry and item owner restored");
            let p=m.Powerups.Points[0];
            Check(p.Kind==Saved.ExpectedKind && p.ReadyAt==Saved.ExpectedReady && p.bInvisible,"recovery preserves roll and exact pending reappearance");
            Check(Saved.Item.Tier==Saved.ExpectedTier+1 && CaelumAwakening.Factor(Saved.Item)==1.25,"saved native tier and awakening retain ownership");
        }
        if(level.time==Saved.ExpectedReady-1)
            Check(m.Powerups.Points[0].bInvisible,"recovery does not shorten reappearance");
        if(level.time>Saved.ExpectedReady+2)
        {
            Check(m.Powerups.Points[0].ReadyAt==0 && !m.Powerups.Points[0].bInvisible,"recovered timer expires normally");
            Console.Printf("CA614 RESULT powerups");Done=true;
        }
    }
}
