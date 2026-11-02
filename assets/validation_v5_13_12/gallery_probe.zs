class CA616Probe : StaticEventHandler
{
    bool Done;
    override void WorldTick()
    {
        if(Done || level.time<110)return;let m=CaelumStandaloneMatch.View();if(m==null || m.Hunt==null)return;
        Done=true;let places=m.Hunt.Arcana.Places;
        for(int slot=0;slot<4;slot++)
        {
            let p=CaelumPlayer(players[slot].mo);int card=slot==0?1:slot==1?17:slot==2?19:10;
            vector3 at=CaelumHuntArcanaData.Center(card)+(0,-112,0);
            if(card==10)at=CaelumHuntArcanaData.Center(card)+(0,0,0);
            CaelumTarotJustice.Move(p,at,90);p.Pitch=0;
            Actor target=places.Bodies[card];if(card==10)target=places.WheelRoom;
            Console.Printf("CA616 %s gallery card=%d sight=%d body=%s invisible=%d x=%.1f y=%.1f",p.CheckSight(target)?"PASS":"FAIL",card,p.CheckSight(target),target.GetClassName(),target.bInvisible,target.Pos.X,target.Pos.Y);
        }
        Console.Printf("CA616 RESULT hunt");
    }
}
