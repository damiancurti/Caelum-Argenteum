// #597: nombres y roles ya definidos en MAP01; los números vienen del residente.
class CaelumStandaloneData : Object
{
    const REVISION=1;
    const DEATHMATCH=1;
    const TEAM_DEATHMATCH=2;
    const CAPTURE_ARCANA=3;
    const TAROT_HUNT=4;
    const HUMAN_PALOMO_MIN_PLAYERS=4;
    const CAPTURE_LIMIT=3;
    const OBJECTIVE_CARD=21; // El Mundo, catálogo existente.
    const OBJECTIVE_RETURN_TICS=30*35;
    static clearscope vector3 BasePosition(int teamId)
    {return CaelumArenaData.Start(level.MapName==CaelumArenaData.Map(1)?1:0,teamId==0?0:4);}
    const FRAG_LIMIT=20;
    const TIME_LIMIT_TICS=10*60*35;
    const RESPAWN_TICS=3*35;
    static clearscope class<CaelumAnchoredResident> Resident(int preset)
    {
        switch(preset)
        {
            case 0:return 'CaelumRulo';
            case 1:return 'CaelumRonnie';
            case 2:return 'CaelumArgento';
            default:return 'CaelumCaella';
        }
    }
    static clearscope int Branch(int preset)
    {
        switch(preset)
        {
            case 0:return CaelumConstants.CLASS_WARRIOR;
            case 1:return CaelumConstants.CLASS_EXPLORER;
            case 2:return CaelumConstants.CLASS_PRIEST;
            default:return CaelumConstants.CLASS_MAGE;
        }
    }
}

// Copia inmutable de las cifras del actor al iniciar la partida independiente.
// No contiene referencias al residente temporal ni a una campaña.
class CaelumStandaloneProfile : Object
{
    int Revision,Preset;
    double BodyMass,BodyHeight,BodyRadius;
    double Base[12];
    void Apply(CaelumAttributes target)
    {
        target.Strength=Base[0];target.Toughness=Base[1];target.Constitution=Base[2];
        target.Agility=Base[3];target.Dexterity=Base[4];target.Resilience=Base[5];
        target.Charisma=Base[6];target.Empathy=Base[7];target.Eloquence=Base[8];
        target.Intelligence=Base[9];target.Patience=Base[10];target.Insight=Base[11];
    }
}
