// #361: la pertenencia y duración proceden del encuentro, no de un estado duplicado.
// Al cargar o viajar se usan las referencias existentes; no hay censo nuevo.
class CaelumSiegeFocus : Object play
{
    static bool Active(CaelumPortSiege port)
    {
        return port!=null && port.SiegeStarted && !port.Victory
            && CaelumHouseHub.IsCity(port);
    }

    static bool ApplyToActor(CaelumCombatActor body)
    {
        let ca870Probe=CA870CallProbe.FindFor(body);
        int ca870Family=ca870Probe!=null?CA870CallProbe.Family(body):0;
        double ca870Start=ca870Probe!=null?MSTimeF():0;
        let ca870Result=CA870Original10(body);
        if(ca870Probe!=null)ca870Probe.Record(ca870Family*16+10,ca870Start);
        return ca870Result;
    }
    static bool CA870Original10(CaelumCombatActor body)
    {
        if(body==null || body.health<=0)return false;
        let soldier=CaelumPortDefender(body);
        let entry=body.SiegeCombatant;
        let port=soldier!=null ? soldier.Port
            : entry!=null && entry.Body==body && !entry.Exited
                ? CaelumPortSiege(entry.Encounter) : null;
        if(!Active(port))return false;
        body.CurrentCombatAdrenaline=body.MaximumCombatAdrenaline;
        return true;
    }

}
