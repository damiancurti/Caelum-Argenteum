// #421: identidades de conversaciones y estados narrativos aprobados.
class CaelumPortStoryData : Object
{
    const REVISION = 1;
    const PRISONER_BASE = 43650;
    const GUARD_FIRST = 43654;
    const GUARD_REPEAT = 43655;

    static clearscope String SituationKey(CaelumPersistentCharacterState record)
    {
        return record != null && record.PortSiegeNarrativeComplete ? "CA_PRISONER_SIEGE_COMPLETE"
            : record != null && record.PortSiegeNarrativeStarted ? "CA_PRISONER_SIEGE_ACTIVE"
            : "CA_PRISONER_SIEGE_PENDING";
    }
    static clearscope String NameKey(int id)
    {
        switch (id)
        {
            case 0: return "CA_PRISONER_UNITARIO_NAME";
            case 1: return "CA_PRISONER_FEDERAL_NAME";
            case 2: return "CA_PRISONER_BESTIA_NAME";
            case 3: return "CA_PRISONER_TAROT_NAME";
        }
        return "CA_PORT_SOLDIER";
    }
}
