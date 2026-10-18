// Prototipo aislado: no se incluye en el paquete normal.
class CA318Work : Object play
{
    const PERIOD=100;
    CaelumCombatActor Body;
    int Mode,Phase,HDue,ODue,WDue,RDue,Failures,Notices;
    bool Audit,HReady,OReady,WReady;
    double HInputs[64],OInputs[64],WInputs[16],HOutputs[16],OOutputs[16];
    double Weight;
    Inventory InvHead;
    Sector LastSector;
    int Requested[5],Computed[5],RawCalls[5];
    int ThermalForced,ThermalPeriodic;
    int NextDue(){return level.time+1+(Phase-(level.time+1)%PERIOD+PERIOD)%PERIOD;}
    void Failure(String label){Failures++;if(Failures<=3)Console.Printf("STAGGER MISMATCH class=%s label=%s tic=%d",Body.GetClassName(),label,level.time);}
    static void InventoryChanged(Actor body)
    {
        let npc=CaelumCombatActor(body);
        if(npc==null || npc.CA318Work==null)return;
        let w=npc.CA318Work;w.WReady=false;w.HReady=false;w.OReady=false;w.Notices++;
        if((w.Mode&16)!=0 && npc.ThermalState!=null)npc.ThermalState.NextUpdateTic=Min(npc.ThermalState.NextUpdateTic,level.maptime+1);
    }
    static void Changed(Actor body,bool died=false)
    {
        let npc=CaelumCombatActor(body);if(npc==null)return;
        if(npc.CA318Work!=null){npc.CA318Work.HReady=false;npc.CA318Work.Notices++;}
        if(died)for(int i=npc.CA318TargetUsers.Size()-1;i>=0;i--)
        {
            let user=npc.CA318TargetUsers[i];
            if(user!=null && user.SharedTarget==npc)user.SharedTargetValid=false;
            npc.CA318TargetUsers.Delete(i);
        }
    }
}
