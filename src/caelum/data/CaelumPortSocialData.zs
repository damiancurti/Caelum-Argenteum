// #419: etapas y calibración aprobadas, independientes del historial tutorial.
class CaelumPortSocialData : Object
{
    const REVISION = 1;
    const CONVERSATION_BASE = 43640;
    const STAGES = 4;
    const ARRIVAL = 0;
    const PREPARATION = 1;
    const THREAT = 2;
    const VICTORY = 3;
    const DIFFICULTY = 120.0;

    static clearscope double ReputationFactor(int reputation)
    {
        switch (CaelumFactionData.Rank(reputation))
        {
            case 2: return 0.75;
            case 3: return 1;
            case 4: return 1.10;
            case 5: return 1.20;
            case 6: return 1.30;
        }
        return 0;
    }

    static clearscope String EmotionKey(int stage)
    {
        switch (stage)
        {
            case ARRIVAL: return "CA_PORT_EMOTION_RELIEF";
            case PREPARATION: return "CA_PORT_EMOTION_CONCERN";
            case THREAT: return "CA_PORT_EMOTION_FEAR";
            case VICTORY: return "CA_PORT_EMOTION_VICTORY";
        }
        return "CA_PORT_EMOTION_UNTRIED";
    }
}
