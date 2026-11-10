// #448: acceso aprobado por el autor; el tamaño lo conserva #429.
class CaelumMilitaryData : Object
{
    const REVISION=2;
    const GUARD_FACTION=CaelumConstants.FACTION_UNITARIOS;
    const MINIMUM_REPUTATION=50;
    const COMMANDER_PRIORITY=1;
    const MEMBER_PRIORITY=2;
    enum Order { NONE, HOLD, ADVANCE, REGROUP, WITHDRAW };
}
