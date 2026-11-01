// #251: la nube es presentación sin masa; el jugador conserva su cuerpo nativo.
class CaelumArcaneCloudModel : Actor
{
    CaelumArcaneCloudEffect Source;
    int VisualAge;

    void UpdatePosition()
    {
        if(Source==null || Source.Owner==null)return;
        let user=CaelumPlayer(Source.Owner);if(user==null)return;
        double size=Source.Width/2;
        Scale=(size,size);Alpha=CaelumArcaneCloudData.MODEL_ALPHA;
        Angle=user.Angle;
        // El mismo anclaje de pelvis que emplean las sillas, sin mover el cuerpo.
        double top=CaelumAppearanceRegistry.SeatSupportPixels()*user.Scale.Y;
        double bottom=top-CaelumArcaneCloudData.MODEL_HEIGHT*size/Max(.001,level.pixelstretch);
        SetOrigin(user.Pos+user.WorldOffset+(0,0,bottom),false);
    }

    void RainVisual()
    {
        int interval=CaelumElementalVFX.Dense()?CaelumArcaneCloudData.RAIN_DENSE_INTERVAL
            :CaelumArcaneCloudData.RAIN_INTERVAL;
        if(VisualAge%interval!=0)return;
        // Secuencia determinista cosmética, separada del azar de blancos.
        double phase=VisualAge*CaelumArcaneCloudData.RAIN_PHASE_STEP;
        double radius=Sqrt((VisualAge%CaelumArcaneCloudData.RAIN_SEQUENCE_LENGTH+0.5)
            /CaelumArcaneCloudData.RAIN_SEQUENCE_LENGTH);
        vector2 local=(Cos(phase)*radius*Source.Width/2,
            Sin(phase)*radius*Source.Width/2*CaelumArcaneCloudData.MODEL_HALF_DEPTH);
        vector3 point=Pos+(Cos(Angle)*local.X-Sin(Angle)*local.Y,
            Sin(Angle)*local.X+Cos(Angle)*local.Y,0);
        FLineTraceData hit;
        bool stopped=LineTrace(0,CaelumArcaneCloudData.RAIN_TRACE_DISTANCE,90,TRF_ABSPOSITION,
            point.Z,point.X,point.Y,hit);
        double distance=stopped?hit.Distance:CaelumArcaneCloudData.RAIN_TRACE_DISTANCE;
        int life=Min(TICRATE,int(distance/CaelumArcaneCloudData.RAIN_SPEED));
        if(life<=0)return;
        vector3 offset=point-Pos;
        A_SpawnParticle(CaelumArcaneCloudData.RAIN_COLOR,0,life,CaelumArcaneCloudData.RAIN_SIZE,
            0,offset.X,offset.Y,0,0,0,-CaelumArcaneCloudData.RAIN_SPEED,0,0,0,
            CaelumArcaneCloudData.RAIN_ALPHA);
    }

    override void Tick()
    {
        Super.Tick();
        if(Source==null || Source.Model!=self || !CaelumArcaneCloud.Active(CaelumPlayer(Source.Owner)))
        {Destroy();return;}
        UpdatePosition();RainVisual();VisualAge++;
    }
    Default { Radius 0;Height 0;Mass 0;+NOINTERACTION +NOGRAVITY RenderStyle "Translucent";Alpha 0.78; }
    States { Spawn:CARK A -1;Stop; }
}

class CaelumArcaneCloudFlight : PowerFlight
{
    override void Tick()
    {
        let effect=CaelumArcaneCloud.Status(CaelumPlayer(Owner));
        if(effect==null || !CaelumArcaneCloud.Active(CaelumPlayer(Owner))){Destroy();return;}
        EffectTics=effect.RemainingTics+1;
        Super.Tick();
    }
    override void EndEffect()
    {
        Actor owner=Owner;
        bool wasFlying=owner!=null && owner.bFly;
        bool hadNoGravity=owner!=null && owner.bNoGravity;
        bool wasCentering=owner!=null && owner.player!=null && owner.player.centering;
        Super.EndEffect();
        CaelumFlightOwnership.AfterEnd(owner,self,wasFlying,hadNoGravity,wasCentering);
    }
    override TextureID GetPowerupIcon(){return TexMan.CheckForTexture("");}
}

class CaelumArcaneCloudEffect : Inventory
{
    int Revision,RemainingTics,RainTics,LightningPhase;
    int RainPulses,LightningStrikes;
    double Power,Range,Width,LightningDamage,LightningRadius,StunDuration;
    CaelumArcaneCloudModel Model;

    void EnsurePresentation()
    {
        let user=CaelumPlayer(Owner);if(!CaelumArcaneCloud.Active(user))return;
        if(user.FindInventory("CaelumArcaneCloudFlight")==null)
            user.GiveInventoryType("CaelumArcaneCloudFlight");
        if(Model==null || Model.bDestroyed)
        {
            Model=CaelumArcaneCloudModel(Actor.Spawn("CaelumArcaneCloudModel",user.Pos,NO_REPLACE));
            if(Model!=null)Model.Source=self;
        }
        if(Model!=null)Model.UpdatePosition();
    }

    override void Tick()
    {
        Super.Tick();
        let user=CaelumPlayer(Owner);
        if(!CaelumArcaneCloud.Active(user)){Destroy();return;}
        EnsurePresentation();
        if(--RainTics<=0){RainTics=TICRATE;CaelumArcaneCloud.Rain(self);RainPulses++;}
        LightningPhase+=CaelumArcaneCloudData.STRIKES_PER_SECOND;
        if(LightningPhase>=TICRATE)
        {LightningPhase-=TICRATE;CaelumArcaneCloud.Lightning(self);}
        if(--RemainingTics<=0)Destroy();
    }
    override void OwnerDied(){Destroy();}
    override void PreTravelled()
    {
        // Sólo viaja el estado del efecto. Recrear el actor cosmético evita
        // conservar enlaces de sector de un mapa descargado.
        let old=Model;Model=null;if(old!=null)old.Destroy();
    }
    override void Travelled()
    {
        EnsurePresentation();
    }
    override void OnDestroy()
    {
        let user=CaelumPlayer(Owner);
        RemainingTics=0;
        let old=Model;Model=null;if(old!=null)old.Destroy();
        if(user!=null)
        {
            let flight=user.FindInventory("CaelumArcaneCloudFlight");
            if(flight!=null)flight.Destroy();
            if(user.health>0 && user.CurState==user.FindState("RestSeated"))
                user.SetState(user.SpawnState);
            user.ApplyPhysicalMovement();
        }
        Super.OnDestroy();
    }
    Default { Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn:TNT1 A -1;Stop; }
}

class CaelumArcaneCloud : Object
{
    static clearscope CaelumArcaneCloudEffect Status(CaelumPlayer user)
    {return user==null?null:CaelumArcaneCloudEffect(user.FindInventory("CaelumArcaneCloudEffect"));}

    static play bool CanRide(CaelumPlayer user)
    {return user!=null && user.player!=null && user.health>0 && user.player.playerstate==PST_LIVE
        && user.WaterLevel==0 && !user.IsPhysicallyImmobilized();}

    static play bool Active(CaelumPlayer user)
    {
        let effect=Status(user);
        return CanRide(user) && effect!=null && effect.Revision==CaelumArcaneCloudData.REVISION
            && effect.RemainingTics>0;
    }

    static play double SpeedFactor(CaelumPlayer user)
    {return Active(user)?CaelumArcaneCloudData.SPEED_FACTOR*Status(user).Power:1.0;}

    static play bool RainEligible(CaelumArcaneCloudEffect effect,Actor body)
    {
        let caster=CaelumPlayer(effect.Owner);
        if(!Active(caster) || body==null || body.health<=0 || CaelumRedemption.Pending(body))return false;
        let summoned=CaelumSummonedZupay(body);
        if(summoned!=null && summoned.AwaitingPlacement)return false;
        if(CaelumPlayer(body)==null && CaelumCombatActor(body)==null)return false;
        if(body==caster)return true;
        if(!CaelumRedemption.Allied(caster,body) || effect.Model==null)return false;
        vector3 origin=effect.Model.Pos;
        if(body.Pos.Z>=origin.Z)return false;
        vector2 relative=body.Pos.XY-origin.XY;
        double x=relative.X*Cos(caster.Angle)+relative.Y*Sin(caster.Angle);
        double y=(-relative.X*Sin(caster.Angle)+relative.Y*Cos(caster.Angle))
            /CaelumArcaneCloudData.MODEL_HALF_DEPTH;
        if(x*x+y*y>effect.Width*effect.Width/4)return false;
        FLineTraceData hit;
        // Descarga vertical real: techos, pisos 3D y cuerpos interpuestos detienen gotas.
        if(!caster.LineTrace(0,origin.Z-body.Pos.Z+body.Height,90,TRF_ABSPOSITION,
            origin.Z,body.Pos.X,body.Pos.Y,hit))return false;
        return hit.HitActor==body;
    }

    static play bool Strongest(CaelumArcaneCloudEffect effect,Actor body)
    {
        let it=ThinkerIterator.Create("CaelumArcaneCloudEffect");CaelumArcaneCloudEffect other;
        while((other=CaelumArcaneCloudEffect(it.Next()))!=null)
        {
            if(other==effect || !RainEligible(other,body))continue;
            if(other.Power>effect.Power || (other.Power==effect.Power
                && other.Owner.PlayerNumber()<effect.Owner.PlayerNumber()))return false;
        }
        return true;
    }

    static play void Rain(CaelumArcaneCloudEffect effect)
    {
        let it=ThinkerIterator.Create("Actor");Actor body;
        double ratio=CaelumArcaneCloudData.RAIN_RECOVERY_RATIO*effect.Power;
        while((body=Actor(it.Next()))!=null)
        {
            if(!RainEligible(effect,body) || !Strongest(effect,body))continue;
            let user=CaelumPlayer(body);
            if(user!=null && user.DerivedStats!=null)
                user.CurrentAnima=Min(user.DerivedStats.MaximumAnima,
                    user.CurrentAnima+user.DerivedStats.MaximumAnima*ratio);
            else
            {
                let npc=CaelumCombatActor(body);
                if(npc!=null)npc.CurrentCombatAnima=Min(npc.MaximumCombatAnima,
                    npc.CurrentCombatAnima+npc.MaximumCombatAnima*ratio);
            }
        }
    }

    static play void Lightning(CaelumArcaneCloudEffect effect)
    {
        let caster=CaelumPlayer(effect.Owner);if(!Active(caster))return;
        Array<Actor> targets;
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)
            if(CaelumArcaneSunRules.Enemy(caster,body) && !CaelumRedemption.Pending(body)
                && (body.Pos+(0,0,body.Height/2)-caster.Pos).Length()<=effect.Range
                && caster.CheckSight(body,SF_IGNOREVISIBILITY))targets.Push(body);
        if(targets.Size()==0)return;
        let anchor=targets[Random[CaelumCloudLightning](0,targets.Size()-1)];
        vector3 center=anchor.Pos+(0,0,anchor.Height/2);
        Array<Actor> victims;
        it=ThinkerIterator.Create("Actor");
        while((body=Actor(it.Next()))!=null)
            if(CaelumArcaneSunRules.Enemy(caster,body) && !CaelumRedemption.Pending(body)
                && (body.Pos+(0,0,body.Height/2)-center).Length()<=effect.LightningRadius)victims.Push(body);
        if(victims.Size()==0)return;
        int damage=Max(1,int(effect.LightningDamage/victims.Size()+0.5));
        effect.LightningStrikes++;
        for(int i=0;i<victims.Size();i++)
        {
            body=victims[i];
            if(!CaelumArcaneSunRules.Enemy(caster,body))continue;
            let visual=Actor.Spawn("CaelumLightningImpactVisual",body.Pos,NO_REPLACE);
            if(visual!=null)visual.master=body;
            int before=body.health;
            body.DamageMobj(effect.Model,caster,damage,'Electric',0,0);
            // El bastón exige pérdida real de Salud para aplicar su estado secundario.
            let status=CaelumElementalStream.Status(body);
            if(body.health>0 && body.health<before && status!=null)
                status.ApplyControlEffect(CaelumConstants.ELEMENTAL_EFFECT_LIGHTNING_STUN,
                    effect.StunDuration,1.0,body);
        }
    }

    static play void AdvanceJourney(CaelumPlayer user,int elapsed)
    {
        let effect=Status(user);if(effect==null || elapsed<=0)return;
        effect.RemainingTics=Max(0,effect.RemainingTics-elapsed);
        if(effect.RemainingTics==0)effect.Destroy();
    }

    static play bool Release(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !CanRide(user) || user.DerivedStats==null)return false;
        let effect=Status(user);bool renewed=effect!=null && effect.RemainingTics>0;
        if(effect==null)effect=CaelumArcaneCloudEffect(user.GiveInventoryType("CaelumArcaneCloudEffect"));
        if(effect==null)return false;
        effect.Revision=CaelumArcaneCloudData.REVISION;
        effect.Power=CaelumClassAbilityRules.BeneficialPower(user);
        effect.Range=CaelumClassAbilityRules.Radius(user);
        effect.Width=CaelumArcaneCloudData.BASE_WIDTH*user.DerivedStats.AbilityRangePercent/100.0;
        effect.LightningDamage=CaelumConstants.SEAL_LIGHTNING_BASE_TOTAL_DAMAGE
            *user.DerivedStats.DebugStaffDamage/CaelumConstants.DEBUG_STAFF_BASE_DAMAGE;
        effect.LightningRadius=CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS
            *CaelumConstants.SEAL_LIGHTNING_RADIUS_STATUETTE_MULTIPLIER
            *user.DerivedStats.AbilityRangePercent/100.0;
        effect.StunDuration=CaelumConstants.ELEMENTAL_LIGHTNING_STUN_SECONDS
            *CaelumClassAbilityRules.HarmfulPower(user);
        effect.RemainingTics=Max(effect.RemainingTics,
            int(CaelumClassAbilityRules.EFFECT_SECONDS*effect.Power*TICRATE+0.5));
        if(!renewed){effect.RainTics=TICRATE;effect.LightningPhase=0;}
        effect.EnsurePresentation();user.ApplyPhysicalMovement();
        CaelumNotifications.Notify(user,StringTable.Localize("CA_ARCANE_CLOUD_CAST",false));
        return true;
    }
}
