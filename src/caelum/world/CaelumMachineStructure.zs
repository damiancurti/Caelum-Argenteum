// Las piezas conservan su colisión; el daño pertenece a una sola estructura.
class CaelumMachineBlock : CaelumGateBlocker
{
    // Mantiene los contactos corporales originales de cañones y arietes.
    override void CollidedWith(Actor other,bool passive) {}
    override bool Used(Actor user)
    {let hull=CaelumMachineStructure(master);return hull!=null && CaelumMachineSession.Show(CaelumPlayer(user),hull.Machine,self);}
    Default { RenderStyle "Normal"; }
}

class CaelumMachineStructure : CaelumBreakableGate
{
    CaelumHostileMachine Machine;
    override void InitializeGate()
    {
        if(Machine==null)return;
        SetOrigin(Machine.Pos,false);Angle=Machine.Angle;
        Initialized=true;Mass=Machine.Mass;
        args[1]=CaelumMachineData.GateMaterial(Machine.MachineKind());
        EnsureGateBalance();
    }
    override void RefreshPassage()
    {if(Machine!=null)Machine.health=health;}
    override void BreakGroup()
    {
        if(Broken)return;
        Broken=true;Opened=true;health=0;BreakCount++;
        if(Machine!=null)Machine.DestroyByTarot();
    }
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double hitAngle)
    {
        int lost=Super.DamageMobj(inflictor,source,damage,mod,flags,hitAngle);
        if(lost>0 && Machine!=null){Machine.DamageSerial++;Machine.health=health;}
        return lost;
    }
    override bool Used(Actor actor)
    {return Machine!=null && Machine.Used(actor);}
    override void Tick() {}
}
