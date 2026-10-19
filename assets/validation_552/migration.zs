// Prueba de la revisión guardada: no es otro solucionador de impactos.
class CA311Migration : CA194Combat
{
    override void WorldTick()
    {
        Age++;if(Age!=5)return;
        let a=Fresh(80),b=Fresh(80);b.SetOrigin(a.Pos+(32,0,0),false);
        let c=a.LatchImpactContact(b);
        Check("new edge revision",c.ReleaseDistanceRevision,1);
        Check("new edge release distance assigned",c.ReleaseDistance,48);
        c.ReleaseDistanceRevision=0;c.ReleaseDistance=0;c.SeparatedTics=4;
        c.PendingWorkJoules=1000;CaelumImpactEnergy.CaptureWork(c);
        let geometry=c.PendingGeometry;int beforeA=a.health,beforeB=b.health,stamp=c.LastCollisionTick;
        a.UpdateImpactContactLatch();
        Check("NPC native latch update migrates",c.ReleaseDistanceRevision,1);
        Check("NPC migration restores existing geometry rule",c.ReleaseDistance,48);
        Check("migration preserves shared edge",c==b.GetImpactContactState(a),1);
        Check("migration preserves pending energy",c.PendingWorkJoules,1000);
        Check("migration preserves pending geometry",c.PendingGeometry==geometry,1);
        Check("migration preserves collision stamp",c.LastCollisionTick,stamp);
        Check("migration cannot apply damage",a.health==beforeA && b.health==beforeB,1);
        c.ReleaseDistance=71;c.SeparatedTics=2;
        CaelumImpactEnergy.RepairLegacyContact(c);
        Check("migration revision makes repeated call inert",c.ReleaseDistance==71 && c.SeparatedTics==2,1);
        c.ReleaseDistanceRevision=0;
        CaelumImpactEnergy.RepairLegacyContact(c);
        Check("legacy positive geometry preserved",c.ReleaseDistance==71 && c.SeparatedTics==2,1);
        c.PendingWorkJoules=0;a.Destroy();b.Destroy();
        let u=CaelumPlayer(players[0].mo);u.CreationWizardOpen=false;u.CharacterCreationComplete=true;
        b=Fresh(80);b.SetOrigin(u.Pos+(u.Radius+b.Radius,0,0),false);
        c=u.LatchImpactContact(b);double expected=c.ReleaseDistance;
        c.ReleaseDistanceRevision=0;c.ReleaseDistance=0;c.SeparatedTics=4;
        u.UpdateImpactContactLatch();
        Check("player update migrates old contact",c.ReleaseDistanceRevision,1);
        Check("player reference geometry restored",c.ReleaseDistance,expected);
        Check("player shared identity retained",c==b.GetImpactContactState(u),1);
        b.Destroy();
        Console.Printf("CA194 DONE failures=%d passes=%d",Failures,Passes);
    }
}
