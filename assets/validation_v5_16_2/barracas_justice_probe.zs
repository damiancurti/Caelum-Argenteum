class CA454JusticeCity : CaelumPortSiege
{
    override void Tick(){}
}
class CA454JusticeBody : CaelumCombatActor
{
    Default {Health 10000;Radius 12;Height 56;Mass 80;Speed 0;PainChance 0;+ISMONSTER +SOLID +SHOOTABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA454JusticeProbe : EventHandler
{
    CaelumTarotJustice Duel;
    CA454JusticeBody TargetBody;
    vector3 PlayerOrigin,TargetOrigin;
    int Passed,Failures,OriginalRemaining,ReturnTic;
    bool WaitingReturn;

    void Check(bool okay,String label)
    {if(okay)Passed++;else Failures++;Console.Printf("CA454 JUSTICE %s %s",okay?"PASS":"FAIL",label);}

    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=="ca454_justice_start")
        {
            let sector=CaelumJusticeGeometry.Get();
            Console.Printf("CA454 JUSTICE GEOMETRY checksum=%s sector=%d",level.GetChecksum(),CaelumJusticeGeometry.SectorIndex(level.MapName));
            Check(sector!=null,"registered candidate arena");if(sector==null)return;
            vector3 centre=CaelumJusticeGeometry.Center(level.MapName);
            Check(sector.lines.Size()==4 && sector.floorplane.ZatPoint(centre.XY)==0 && sector.ceilingplane.ZatPoint(centre.XY)==160,"preserved arena envelope");
            PlayerOrigin=CaelumPortData.FormationPosition(0);
            TargetOrigin=PlayerOrigin+(CaelumPortData.FORMATION_SPACING,0,0);
            user.SetOrigin(PlayerOrigin,false);user.Angle=0;user.Pitch=0;
            TargetBody=CA454JusticeBody(Actor.Spawn('CA454JusticeBody',TargetOrigin,NO_REPLACE));
            Check(user.TestMobjLocation() && TargetBody.TestMobjLocation(),"clear original positions");
            Check(CaelumTarotJustice.Start(user,TargetBody,60*TICRATE),"native duel starts");
            let link=CaelumJusticeLink.View(user);Duel=link!=null?link.Duel:null;
            if(Duel==null)return;
            OriginalRemaining=Duel.RemainingTics;
            Check(Duel.Bodies[1]==TargetBody && CaelumJusticeLink.View(TargetBody).Duel==Duel,"exact pair links");
            Check(user.CurSector==sector && TargetBody.CurSector==sector && user.TestMobjLocation() && TargetBody.TestMobjLocation(),"both bodies fit appended room");
            Console.Printf("CA454 JUSTICE CAPTURE passed=%d failures=%d",Passed,Failures);
        }
        if(e.Name=="ca454_justice_resume")
        {
            Check(Duel!=null && TargetBody!=null,"saved pair exists");if(Duel==null)return;
            Check(CaelumJusticeLink.View(user).Duel==Duel && CaelumJusticeLink.View(TargetBody).Duel==Duel,"saved pair references");
            Check(Duel.RemainingTics>0 && Duel.RemainingTics<OriginalRemaining,"timer continues without restart");
            Check(user.CurSector==CaelumJusticeGeometry.Get() && TargetBody.CurSector==user.CurSector,"saved arena placement");
            Console.Printf("CA454 JUSTICE RESUME failures=%d",Failures);
        }
        if(e.Name=="ca454_justice_expire" && Duel!=null)
        {Duel.RemainingTics=1;WaitingReturn=true;ReturnTic=level.time;}
    }

    override void WorldTick()
    {
        if(!WaitingReturn || level.time-ReturnTic<3)return;
        WaitingReturn=false;let user=CaelumPlayer(players[0].mo);
        Check(!CaelumJusticeLink.Bound(user) && !CaelumJusticeLink.Bound(TargetBody),"expiry clears pair links");
        Check((user.Pos-PlayerOrigin).Length()<0.01 && (TargetBody.Pos-TargetOrigin).Length()<0.01,"both survivors return to exact origins");
        Check(user.health>0 && TargetBody.health>0,"no death or replacement");
        Console.Printf("CA454 JUSTICE COMPLETE passed=%d failures=%d",Passed,Failures);
    }
}
