class CA616Probe : StaticEventHandler
{
    bool Done;
    override void WorldTick()
    {
        if(Done)return;let m=CaelumStandaloneMatch.View();if(m==null || m.Hunt==null || level.time<215)return;
        Done=true;let h=m.Hunt;bool okay=h.Arcana!=null && h.Arcana.Places==null && !CaelumHuntArcanaData.Present();
        for(int slot=0;slot<MAXPLAYERS;slot++)if(m.Seeker(slot))
        {
            let r=CaelumPlayer(players[slot].mo).GetPersistentCharacterState(false);
            for(int card=0;card<78;card++)okay=okay && r.TarotOwned[card]==h.Found[card];
        }
        Console.Printf("CA616 %s original geometry and progress migrate without new rooms",okay?"PASS":"FAIL");
        Console.Printf("CA616 RESULT hunt");
    }
}
