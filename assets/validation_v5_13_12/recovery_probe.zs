class CA616Probe : StaticEventHandler
{
    bool Done;
    override void WorldTick()
    {
        if(Done)return;let m=CaelumStandaloneMatch.View();if(m==null || m.Hunt==null || level.time<215)return;
        Done=true;let h=m.Hunt;bool okay=h.Arcana!=null && h.Arcana.Places!=null && h.Collected>=22;
        for(int i=0;i<22;i++)okay=okay && h.Arcana.Places.Markers[i]!=null;
        for(int slot=1;slot<4;slot++)
        {
            let r=CaelumPlayer(players[slot].mo).GetPersistentCharacterState(false);
            for(int i=0;i<22;i++)okay=okay && r.TarotOwned[i];
        }
        Console.Printf("CA616 %s saved collection, placed bodies and shared cards",okay?"PASS":"FAIL");
        Console.Printf("CA616 RESULT hunt");
    }
}
