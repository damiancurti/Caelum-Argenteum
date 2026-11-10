// #447: reglas aprobadas el 2026-11-09. Los números de tropas conservan su fuente.
class CaelumBattleData : Object
{
    const REVISION=1;
    const PREPARING=0;
    const ACTIVE=1;
    const VICTORY=2;
    const DEFEAT=3;
    const LIBERATED=4;
    // Tolerancia de representación del calendario, muy inferior a un tic.
    const CLOCK_EPSILON=0.00001;

    static double WaveCivilSeconds()
    {
        return double(CaelumReinforcementData.INTERVAL)/TICRATE
            *3600.0/CaelumConstants.REAL_SECONDS_PER_GAME_HOUR;
    }
}
