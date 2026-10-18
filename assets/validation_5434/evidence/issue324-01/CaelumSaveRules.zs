class CaelumSaveRules : Object
{
    // #324: cinco minutos reales de juego activo, sin multiplicador de calendario.
    const ACTIVE_INTERVAL_SECONDS = 300;
    const MILLISECONDS_PER_SECOND = 1000;
    // GZDoom 4.14.2: Autosave (especial 15); gameaction_t::ga_nothing = 0.
    const NATIVE_AUTOSAVE_SPECIAL = 15;
    const NATIVE_ACTION_IDLE = 0;
}
