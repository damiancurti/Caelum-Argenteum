// #415: un vuelo ya pagado se incorpora a la primera ronda resumida.
// No vuelve a lanzar, tirar criticos, gastar recursos ni simular trayectorias.
class CaelumAbsentShot : Object play
{
    CaelumActorProjectile Shot;
    CaelumAbsentCombatant Source,Recipient;
    CaelumAbsentAttack Attack;
    bool Resolved;
    double Wear;

    static CaelumAbsentCombatant SourceRow(CaelumAbsentBattle battle,CaelumCombatActor owner)
    {
        if(owner==null)return null;
        let row=owner.AbsentCombatant;
        if(row!=null && row.Battle==battle)return row;
        for(int i=0;i<battle.Rows.Size();i++)if(battle.Rows[i].Body==owner)
        {owner.AbsentCombatant=battle.Rows[i];return battle.Rows[i];}
        let entry=owner.SiegeCombatant;let soldier=CaelumPortDefender(owner);
        bool belongs=entry!=null && entry.Encounter==battle.Encounter;
        if(soldier!=null && soldier.Port==battle.Encounter)belongs=true;
        if(!belongs)return null;
        // Puede haber muerto despues de lanzar, antes del primer abandono.
        // Retener su identidad como fuente no lo reincorpora a los combatientes.
        row=new('CaelumAbsentCombatant');row.Battle=battle;row.Body=owner;row.Identity=battle.Rows.Size();
        row.Friendly=owner.bFriendly;row.Participating=false;
        owner.AbsentCombatant=row;battle.Rows.Push(row);return row;
    }

    static void Capture(CaelumAbsentBattle battle)
    {
        // Censo tipado una vez al abandonar el mapa, nunca por tic/combatiente.
        // Se necesitan tambien vuelos cuyo lanzador haya muerto en esta ronda.
        let flights=ThinkerIterator.Create('CaelumActorProjectile');
        CaelumActorProjectile shot;
        while((shot=CaelumActorProjectile(flights.Next()))!=null)
        {
            if(!shot.bMissile || !shot.CaelumAttackPrepared)continue;
            bool magic=shot is 'CaelumActorSimpleElementalProjectile' || shot is 'CaelumActorExplosiveElementalProjectile';
            bool carbine=shot.GetClassName()=='CaelumCarbineProjectile';
            if(!magic && !carbine)continue;
            let owner=CaelumCombatActor(shot.target);
            let source=SourceRow(battle,owner);
            if(source==null)continue;
            let existing=shot.CaelumSummaryPending;
            if(existing!=null && !existing.Resolved && existing.Source.Battle==battle)continue;
            if(shot.CaelumSummaryRevision==0)
            {
                // El save anterior no conoce el blanco original: conserva el
                // ultimo blanco del tirador y sus parametros actuales una vez.
                let legacy=new('CaelumAbsentAttack');
                if(!legacy.Configure(owner,true))continue;
                shot.StoreSummaryAim(owner.target,legacy.Weapon,legacy.Tier,legacy.Minimum,legacy.Maximum,legacy.SignedOffsets);
                shot.CaelumSummaryOrigin=legacy.Origin;
            }
            let victim=CaelumCombatActor(shot.CaelumSummaryTarget);
            let recipient=victim!=null?victim.AbsentCombatant:null;
            if(recipient==null || recipient.Battle!=battle)continue;
            let pending=new('CaelumAbsentShot');pending.Shot=shot;pending.Source=source;pending.Recipient=recipient;
            pending.Attack=new('CaelumAbsentAttack');let attack=pending.Attack;
            attack.Kind=carbine?CaelumAbsentAttack.CARBINE
                :shot is 'CaelumActorExplosiveElementalProjectile'?CaelumAbsentAttack.EXPLOSIVE:CaelumAbsentAttack.MAGIC;
            attack.Weapon=shot.CaelumSummaryWeapon;attack.Tier=shot.CaelumSummaryTier;
            attack.Origin=shot.CaelumSummaryOrigin;attack.Minimum=shot.CaelumSummaryMinimum;
            attack.Maximum=shot.CaelumSummaryMaximum;attack.SignedOffsets=shot.CaelumSummarySigned;
            attack.Damage=shot.CaelumPreparedDamage;attack.Accuracy=shot.CaelumAttackAccuracySucceeded?1:0;
            attack.ProjectileRadius=shot.Radius;attack.Area=shot.CaelumActorExplosionRadius;
            attack.Essence=magic?shot.CaelumEssenceType:-1;attack.Debuff=shot.CaelumDebuffPowerPercent/100.0;
            attack.Penetration=shot.CaelumIdeologyPenetration;attack.Push=shot.CaelumPushMultiplier;
            shot.CaelumSummaryPending=pending;battle.Flights.Push(pending);
        }
    }

    void Queue(CaelumAbsentCombatant row,CaelumAbsentDamage result)
    {
        row.Queue(null,result);Wear+=result.WeaponWear;
        if(row.Killer==null && row.LifeFraction+row.PendingLife>=row.Body.health)row.Killer=Source.Body;
        if(result.FireDose>0 && (row.PendingFire<=0 || Attack.Debuff>row.PendingFirePower))
        {row.PendingFire=result.FireDose;row.PendingFirePower=Attack.Debuff;row.FireSource=Source.Body;}
    }

    void Resolve()
    {
        if(Resolved || Shot==null)return;
        Resolved=true;
        // El cuerpo residente puede haber viajado; usar la identidad reanclada.
        if(Source.Body!=null)Shot.target=Source.Body;
        bool impact=Shot.bMissile && !Shot.bDestroyed && Recipient.Alive()
            && Source.Body!=null && !Source.Body.bDestroyed
            && !Shot.PreventSummoningFriendlyFire(Recipient.Body)
            && !Shot.PreventCaelumMassDiagnosticFriendlyFire(Recipient.Body);
        if(impact)
        {
            Shot.ResolveCaelumCritical(Recipient.Body);Attack.Critical=Shot.CaelumCriticalHit?1:0;
            Queue(Recipient,Attack.Direct(Source.Body,Recipient.Body,Recipient.Blocking(Source.Body)));
            if(Attack.Kind==CaelumAbsentAttack.EXPLOSIVE && Attack.Area>0)
            {
                Attack.Damage=Shot.CaelumActorExplosionDamage;
                vector3 origin=Recipient.Body.Pos+(0,0,Recipient.Body.Height/2);
                double p=CaelumMeanAim.BodyProbability(Attack.Origin,Recipient.Body.Pos,Recipient.Body.Radius,
                    Recipient.Body.Height,Attack.ProjectileRadius,Attack.Minimum,Attack.Maximum,Attack.SignedOffsets);
                let battle=Source.Battle;
                Array<CaelumAbsentCombatant> nearby;
                battle.Nearby(origin,Attack.Area,nearby,true);
                for(int i=0;i<nearby.Size();i++)
                {
                    let row=nearby[i];
                    if(row==Source || !row.Alive() || Shot.PreventSummoningFriendlyFire(row.Body))continue;
                    Shot.ResolveCaelumCritical(row.Body);Attack.Critical=Shot.CaelumCriticalHit?1:0;
                    Queue(row,Attack.Splash(Source.Body,row.Body,origin,p,row.Blocking(Source.Body)));
                }
            }
        }
        // No ejecutar Death: su A_Explode repetiría el resultado resumido.
        Shot.CaelumSummaryPending=null;
        Shot.RegisterCaelumDiagnosticCompletion(impact,!impact);Shot.Destroy();
    }

    void CommitWear()
    {
        if(Wear<=0 || Source==null)return;
        let soldier=CaelumPortDefender(Source.Body);
        if(soldier!=null && soldier.Carbine!=null && soldier.Carbine.Weapon!=null)
        {
            Source.GunFraction+=Wear;int lost=int(Source.GunFraction);
            soldier.Carbine.Weapon.Durability=Max(0,soldier.Carbine.Weapon.Durability-lost);
            Source.GunFraction-=lost;
        }
        Wear=0;
    }
}
