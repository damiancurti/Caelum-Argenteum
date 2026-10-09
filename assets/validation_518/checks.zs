class CA137Checks : StaticEventHandler
{
    int Checks,Failures;
    CaelumCombatActor Body;
    CaelumActorProjectile Shot;
    CaelumCombatActor Federal;
    Actor Dummy;
    void Check(bool passed,String label)
    {Checks++;Console.Printf("CA137 %s %s",passed ? "PASS" : "FAIL",label);if(!passed)Failures++;}
    int Count(Name kind)
    {int count=0;let it=ThinkerIterator.Create(kind);while(it.Next()!=null)count++;return count;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(level.time==1){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;}
        if(level.time==70)
        {
            u.CaelumMaximumHealth=2000;u.health=2000;u.DamageVFXStrength=0;
            u.DamageMobj(null,null,50,'CaelumElementalDOT',DMG_NO_ARMOR|DMG_FORCED,0);
            Check(Abs(u.DamageVFXStrength-.02)<.000001 && u.player.damagecount==0,"50 of 2000 = 2.5 percent; no Doom flash");
            u.CaelumMaximumHealth=200;u.health=200;u.DamageVFXStrength=0;
            u.DamageMobj(null,null,5,'CaelumElementalDOT',DMG_NO_ARMOR|DMG_FORCED,0);
            Check(Abs(u.DamageVFXStrength-.02)<.000001,"same fractional hit has identical intensity");
            u.DamageVFXStrength=0;u.ElementalStatus.DealStatusDamage(u,null,1,5);
            Check(u.DamageVFXKind==5 && u.PendingDamageVFXKind==0,"poison tint preserves damage type and clears context");
            u.ElementalStatus.DealStatusDamage(u,null,1,0);
            Check(u.DamageVFXKind==0,"burn tint remains distinct from simultaneous poison");
            u.health=200;u.bINVULNERABLE=true;u.DamageVFXStrength=0;
            u.DamageMobj(null,null,50,'Hitscan',0,0);
            Check(u.DamageVFXStrength==0,"prevented damage creates no flash");u.bINVULNERABLE=false;
            Body=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(2200,4096,0)));Body.bDORMANT=true;
        }
        if(level.time==73)
        {
            Body.ElementalStatus.BurnRemaining=1;Body.ElementalStatus.PoisonRemaining=1;
            Body.ElementalStatus.FreezeRemaining=1;Body.ElementalStatus.LightningStunRemaining=1;
            Body.ElementalStatus.UpdateVisualEffects(Body);
        }
        if(level.time==76)
        {
            Check(Count('CaelumAttachedElementalVisual')==4,"four simultaneous states create four owned visuals");
            Body.SetOrigin((2280,4050,0),false);
        }
        if(level.time==78)
        {
            Check((Body.ElementalStatus.BurnVisual.Pos-Body.Pos).Length()<.001,"status follows moving body");
            Body.health=0;
        }
        if(level.time==82)
        {
            Check(Count('CaelumAttachedElementalVisual')==0,"death removes all status emitters even without owner status ticking");
            Shot=CaelumActorProjectile(Actor.Spawn("CaelumActorSimpleElementalProjectile",(2000,4096,60)));
            Shot.StoreCaelumElementalPayload(0,false,100,100);Shot.Vel=(0,0,0);Shot.ConfigureCaelumTravelDistance(320);
            Shot.ExplodeMissile(null,null);
        }
        if(level.time==84)Check(Count('CaelumElementalImpactVisual')==1,"one cosmetic impact per collision");
        if(level.time==103)
        {
            Check(Count('CaelumElementalImpactVisual')==0,"impact visual expires within its bound");
            Check(CaelumDamageFeedback.Tint(0)!=CaelumDamageFeedback.Tint(3)
                && CaelumDamageFeedback.Tint(5)!=CaelumDamageFeedback.Tint(7),"damage palettes remain distinct");
            u.SetOrigin((150,4096,0),false);
            Shot=CaelumActorProjectile(Actor.Spawn("CaelumPlayerMagicProjectile",(6,4096,20)));
            Shot.StoreCaelumElementalPayload(1,true,100,100);Shot.target=u;Shot.Vel=(-20,0,0);
            Federal=CaelumCombatActor(Actor.Spawn("CaelumPrisonerFederal",(2300,4096,0)));
            Dummy=Actor.Spawn("CaelumMandinga",(2430,4096,0));Dummy.bDORMANT=true;Dummy.bINVULNERABLE=true;
        }
        if(level.time==105)Check(Count('CaelumElementalImpactVisual')==1,"real wall collision produces one owned elemental impact");
        if(level.time==107)
        {
            u.SetOrigin((2300,3990,0),false);
            u.SetPlayerPrisonerRescueState(CaelumConstants.PRISONER_FEDERAL,CaelumConstants.PRISONER_STATE_FOLLOWING);
            Federal.target=Dummy;Federal.NextRangedSecondaryElement=true;Federal.SetStateLabel("Missile");
        }
        if(level.time==115)
        {
            Console.Printf("CA137 FEDERAL spawned=%d air=%.3f anima=%.3f secondary=%d range=%.3f target=%d",Federal.ImpactDiagnosticProjectilesSpawned,Federal.CurrentCombatAir,Federal.CurrentCombatAnima,Federal.NextRangedSecondaryElement,Federal.GetCombatAbilityRange(),Federal.target!=null);
            int rays=0;let it=ThinkerIterator.Create("CaelumActorSimpleElementalProjectile");CaelumActorProjectile p;
            while((p=CaelumActorProjectile(it.Next()))!=null)
                if(p.target==Federal && p.CaelumEssenceType==CaelumConstants.ESSENCE_WIND
                    && p.CaelumSecondaryElement && p.sprite==Actor.GetSpriteIndex("VFLI"))rays++;
            Check(rays==1,"actual Federal prisoner missile uses the staff lightning ray");
            Federal.Destroy();Dummy.Destroy();
            u.CaelumMaximumHealth=2000;u.health=5;u.DamageVFXStrength=0;
            u.DamageMobj(null,null,5000,'CaelumElementalDOT',DMG_NO_ARMOR|DMG_FORCED,0);
            Check(u.health<=0 && Abs(u.DamageVFXStrength-.002)<.000001,
                "fatal overkill flash counts only remaining positive Health");
            Console.Printf("CA137 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
class CA137Target : Actor
{
    Default { Health 1000000; Radius 20; Height 60; +SHOOTABLE +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
