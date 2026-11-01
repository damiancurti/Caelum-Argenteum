// Un único rayo por secuencia dirigida; conserva el objetivo original de El Mundo.
class CaelumMajorTargets : Object play
{
    static double Range(CaelumPlayer user)
    {
        return user!=null && user.DerivedStats!=null
            ? CaelumMajorArcanaData.TARGET_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER
                *Max(0.0,user.DerivedStats.AbilityRangePercent)/100.0 : 0;
    }

    static Actor Aim(CaelumPlayer user)
    {
        if(user==null || user.player==null)return null;
        vector3 eye=CaelumTelekinesisRules.Eye(user);FLineTraceData hit;
        if(!user.LineTrace(user.Angle,Range(user),user.Pitch,
            TRF_ABSPOSITION|TRF_SOLIDACTORS,eye.Z,eye.X,eye.Y,hit))return null;
        return hit.HitActor;
    }

    static bool Visible(CaelumPlayer user,Actor target)
    {
        return target!=null && !target.bDestroyed && user!=null
            && (target.Pos+(0,0,target.Height/2)-CaelumTelekinesisRules.Eye(user)).Length()
                <=Range(user)+target.Radius && user.CheckSight(target);
    }

    static bool Enemy(CaelumPlayer user,Actor body)
    {
        if(user==null || body==null || body==user || body.health<=0 || !body.bShootable)return false;
        let opponent=CaelumPlayer(body);
        if(opponent!=null)
        {
            let session=CaelumArenaState.View(user),other=CaelumArenaState.View(opponent);
            let match=session!=null?session.MatchState:null;
            if(match!=null && other!=null && other.MatchState==match)
            {
                int a=user.PlayerNumber(),b=opponent.PlayerNumber();
                return match.Status==CaelumArenaMatch.FIGHTING && a>=0 && b>=0
                    && match.Members[a]==user && match.Members[b]==opponent
                    && (match.Withdrawn&((1<<a)|(1<<b)))==0
                    && (match.Mode==0 || match.Teams[a]!=match.Teams[b]);
            }
        }
        let image=CaelumTarotClone(body);if(image!=null)return Enemy(user,image.Caster);
        if(CaelumRedemption.Commander(body)!=null)return !CaelumRedemption.Allied(user,body);
        let controller=CaelumTarotEmperor.Commander(body);
        if(controller!=null)return Enemy(user,controller);
        let combat=CaelumCombatActor(body);
        return combat!=null?CaelumVisualPerception.RelatedOpponent(combat,user):CaelumSummoning.Enemy(user,body);
    }

    static CaelumHostileMachine Machine(Actor hit)
    {
        if(hit==null)return null;
        if(hit is 'CaelumCannonBlock' || hit is 'CaelumRamBlock')hit=hit.master;
        return hit is 'CaelumCannon' || hit is 'CaelumBatteringRam'
            ? CaelumHostileMachine(hit) : null;
    }

    static bool Tower(Actor hit)
    {
        let machine=Machine(hit);
        return machine!=null && machine.DestroyByTarot();
    }
}
