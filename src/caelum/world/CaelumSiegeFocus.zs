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
