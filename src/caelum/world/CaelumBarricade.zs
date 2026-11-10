// Barrera física, sin el mando de apertura que pertenece a los portones.
class CaelumBarricadeVisual : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY }
    States { Spawn: Intact: CAGT A -1; Stop; Damaged: CAGT B -1; Stop; Broken: TNT1 A -1; Stop; }
}
class CaelumBarricade : CaelumBreakableGate
{
    int MachineRevision,OwnerFaction,DamageSerial;
    CaelumPlayer Worker;
    override double StructureWidth() {return CaelumMachineData.BARRICADE_WIDTH;}
    override double StructureHeight() {return CaelumMachineData.BARRICADE_HEIGHT;}
    override double StructureThickness() {return CaelumMachineData.BARRICADE_THICKNESS;}
    override int StructureMass() {return CaelumMachineData.BARRICADE_MASS;}
    override class<Actor> StructureVisual() {return 'CaelumBarricadeVisual';}
    override bool Used(Actor user) {return CaelumMachineSession.Show(CaelumPlayer(user),self,self);}
    override void BreakGroup()
    {
        if(Broken)return;
        Broken=true;Opened=true;health=0;BreakCount++;RefreshPassage();
    }
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double hitAngle)
    {
        int lost=Super.DamageMobj(inflictor,source,damage,mod,flags,hitAngle);
        if(lost>0)DamageSerial++;
        return lost;
    }
    Default { Height 48; }
}
