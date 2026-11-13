// #454: progreso por actor guardado, sin recalcular una ruta global por pulso.
class CaelumBarracasMarch : Object play
{
    static bool Pending(CaelumSiegeCombatant entry)
    {
        if(entry==null || entry.Body==null || entry.CrewMachine is 'CaelumBatteringRam')return false;
        int mode=entry.CrewMachine is 'CaelumCannon'?1:0;
        if(entry.FrontMarchRevision<CaelumBarracasMarchData.REVISION
            || entry.FrontMarchLane!=entry.Lane || entry.FrontMarchMode!=mode)
        {
            entry.FrontMarchLane=entry.Lane;entry.FrontMarchMode=mode;entry.FrontMarchCursor=0;
            // Un relevo ya situado en el frente no vuelve al campo de llegada.
            entry.FrontMarchComplete=entry.Body.Pos.Y>CaelumBarracasMarchData.ENTRY_LINE_Y;
            entry.FrontMarchRevision=CaelumBarracasMarchData.REVISION;
        }
        return !entry.FrontMarchComplete;
    }

    static vector3 Destination(CaelumSiegeCombatant entry)
    {
        bool gun=entry.FrontMarchMode==1;
        int count=gun?CaelumBarracasMarchData.GunCount(entry.Lane)+1:CaelumBarracasMarchData.InfantryCount(entry.Lane);
        while(entry.FrontMarchCursor<count)
        {
            vector3 point;
            if(!gun)point=CaelumBarracasMarchData.InfantryPoint(entry.Lane,entry.FrontMarchCursor);
            else if(entry.FrontMarchCursor<CaelumBarracasMarchData.GunCount(entry.Lane))point=CaelumBarracasMarchData.GunPoint(entry.Lane,entry.FrontMarchCursor);
            else point=entry.CrewPost()+CaelumBarracasMarchData.GunApproachOffset(entry.Lane);
            if((entry.Body.Pos-point).Length()>entry.Body.Radius)return point;
            entry.FrontMarchCursor++;
        }
        entry.FrontMarchComplete=true;
        return gun?entry.CrewPost():CaelumBarracasAssault.GateForLane(entry.Lane);
    }
}
