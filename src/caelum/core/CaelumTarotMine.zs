// El suelo apuntado pertenece a la secuencia antes del pago o del viaje.
class CaelumTarotGroundAim : Object play
{
    bool Found;
    vector3 Point;
    double Damage,RangeMultiplier;
    static CaelumTarotGroundAim Capture(CaelumPlayer user)
    {
        let aim=new("CaelumTarotGroundAim");if(user==null)return aim;
        if(user.DerivedStats!=null)
        {
            aim.Damage=user.DerivedStats.DebugStaffDamage*user.EffectiveOffensiveDamageMultiplier;
            aim.RangeMultiplier=user.DerivedStats.AbilityRangePercent/100.0;
        }
        vector3 eye=CaelumTelekinesisRules.Eye(user);FLineTraceData hit;
        aim.Found=user.LineTrace(user.Angle,CaelumMajorTargets.Range(user),user.Pitch,
            TRF_ABSPOSITION|TRF_THRUACTORS,eye.Z,eye.X,eye.Y,hit)
            && hit.HitType==FLineTraceData.TRACE_HitFloor;
        if(aim.Found)aim.Point=hit.HitLocation;
        return aim;
    }
    bool Valid(CaelumPlayer user)
    {
        if(!Found || user==null || !level.IsPointInLevel(Point))return false;
        vector3 eye=CaelumTelekinesisRules.Eye(user),ray=Point-eye;
        if(ray.Length()>CaelumMajorTargets.Range(user))return false;
        FLineTraceData hit;
        return user.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length()+0.01,-VectorAngle(ray.XY.Length(),ray.Z),
            TRF_ABSPOSITION|TRF_THRUACTORS,eye.Z,eye.X,eye.Y,hit)
            && hit.HitType==FLineTraceData.TRACE_HitFloor && (hit.HitLocation-Point).Length()<0.02;
    }
}

class CaelumTarotMineState : Inventory
{
    CaelumTarotMine Mine;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumTarotMine : CaelumMagicMine
{
    int Revision,RemainingTics;
    CaelumPlayer Caster;
    CaelumTarotMineState Ledger;

    static bool Place(CaelumPlayer user,CaelumTarotGroundAim aim,int duration)
    {
        if(aim==null || !aim.Valid(user))return false;
        let holder=CaelumTarotMineState(user.FindInventory('CaelumTarotMineState'));
        if(holder==null)holder=CaelumTarotMineState(user.GiveInventoryType('CaelumTarotMineState'));
        let mine=CaelumTarotMine(Actor.Spawn('CaelumTarotMine',aim.Point+(0,0,0.5),NO_REPLACE));
        mine.Revision=CaelumMajorArcanaData.MINE_REVISION;mine.Caster=user;mine.target=user;
        mine.Ledger=holder;mine.RemainingTics=duration;
        mine.args[0]=Max(1,int(aim.Damage*CaelumMajorArcanaData.TRAP_DAMAGE_MULTIPLIER+0.5));
        mine.args[1]=Max(1,int(CaelumMajorArcanaData.AREA_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER
            *aim.RangeMultiplier+0.5));
        if(holder.Mine!=null)holder.Mine.Destroy();holder.Mine=mine;
        CaelumMajorWorldEvents.TimeSourcesChanged();
        return true;
    }
    override bool IsPressedBy(Actor body)
    {return Super.IsPressedBy(body) && CaelumMajorTargets.Enemy(Caster,body);}
    override int ExplosionFlags(){return XF_THRUSTLESS|XF_HURTSOURCE;}
    override void Tick()
    {
        // Super.Tick conserva física y presión nativas; el salto usa sólo presión.
        if(Caster!=null && Caster.SessionIdentityPending)return;
        if(Caster==null || RemainingTics<=0){Destroy();return;}
        Super.Tick();AdvanceEffect(false);
    }
    void AdvanceEffect(bool checkContact=true)
    {
        if(Caster!=null && Caster.SessionIdentityPending)return;
        if(Caster==null || RemainingTics<=0){Destroy();return;}
        if(checkContact)CheckPressure();
        if(--RemainingTics<=0)Destroy();
    }
    override void OnDestroy()
    {
        if(Ledger!=null && Ledger.Mine==self)Ledger.Mine=null;
        Super.OnDestroy();
    }
}
