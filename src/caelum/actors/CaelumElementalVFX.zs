// Sólo presentación. Ningún actor/partícula de esta capa causa daño o calor.
class CaelumElementalVFX : Object play
{
    static int Kind(CaelumActorProjectile shot)
    {
        return shot.CaelumEssenceType==CaelumConstants.ESSENCE_QUINTESSENCE
            ? 8 : Clamp(shot.CaelumEssenceType*2+int(shot.CaelumSecondaryElement),0,7);
    }

    static bool Dense()
    {
        let population=CaelumPopulationState.Get();
        return population!=null && population.HighDensity;
    }

    static bool Detail(Actor effect)
    {
        double distance=Dense() ? CaelumElementalVFXData.DENSE_DETAIL_DISTANCE
            : CaelumElementalVFXData.DETAIL_DISTANCE;
        // La distancia es puramente visual; el umbral usa combatientes de todo el mapa.
        for(int p=0;p<MAXPLAYERS;p++)
            if(playeringame[p] && players[p].mo!=null
                && (players[p].mo.Pos-effect.Pos).LengthSquared()<=distance*distance)return true;
        return false;
    }

    static void Light(Actor effect,int kind,bool enabled=true)
    {
        if(effect==null || effect.bDestroyed)return;
        if(enabled && Detail(effect))
            effect.A_AttachLight('CaelumElement',DynamicLight.PointLight,
                CaelumElementalVFXData.Tint(kind),CaelumElementalVFXData.LightRadius(kind),0,
                DynamicLight.LF_ATTENUATE|DynamicLight.LF_NOSHADOWMAP);
        else effect.A_RemoveLight('CaelumElement');
    }

    static void Projectile(CaelumActorProjectile shot)
    {
        if(shot==null || shot.bDestroyed || !shot.CaelumElementalPayloadPrepared
            || (shot.CaelumDiagnosticCompletionRecorded && shot.bMissile))return;
        // Revisión cosmética idempotente: campos ausentes nacen en cero;
        // jamás se reescribe edad ya guardada ni estado físico del proyectil.
        if(shot.CaelumVFXRevision<1)shot.CaelumVFXRevision=1;
        int kind=Kind(shot);
        shot.sprite=Actor.GetSpriteIndex(CaelumElementalVFXData.SpriteName(kind));
        shot.frame=(shot.CaelumVFXAge/CaelumElementalVFXData.FRAME_TICS)%4;
        if(!shot.bMissile)
        {
            Impact(shot);
            return;
        }
        if(shot.CaelumVFXAge%CaelumElementalVFXData.FRAME_TICS==0)Light(shot,kind);
        int interval=Dense() ? CaelumElementalVFXData.DENSE_TRAIL_INTERVAL
            : CaelumElementalVFXData.TRAIL_INTERVAL;
        if(kind!=7 && shot.CaelumVFXAge%interval==0 && Detail(shot))
        {
            // Partículas nativas: cola finita sin thinkers ni aleatoriedad de combate.
            vector3 drift=-shot.Vel*0.08;
            shot.A_SpawnParticle(CaelumElementalVFXData.Tint(kind),SPF_FULLBRIGHT,
                CaelumElementalVFXData.PARTICLE_LIFE,4*shot.Scale.X,0,
                0,0,shot.Height/2,drift.X,drift.Y,drift.Z,0,0,0,0.8);
        }
        shot.CaelumVFXAge++;
    }

    static void Impact(CaelumActorProjectile shot)
    {
        if(shot==null || shot.bDestroyed)return;
        if(shot.CaelumVFXRevision<1)shot.CaelumVFXRevision=1;
        shot.A_RemoveLight('CaelumElement');
        if(shot.CaelumVFXImpactShown || !shot.CaelumElementalPayloadPrepared)return;
        shot.CaelumVFXImpactShown=true;
        if(!Detail(shot))return;
        let effect=CaelumElementalImpactVisual(Actor.Spawn("CaelumElementalImpactVisual",shot.Pos,NO_REPLACE));
        if(effect!=null){effect.Kind=Kind(shot);effect.Scale=shot.Scale;}
    }
}

class CaelumElementalImpactVisual : Actor
{
    int Kind,Age;
    override void Tick()
    {
        Super.Tick();
        if(bDestroyed)return;
        if(Age>=CaelumElementalVFXData.IMPACT_TICS){Destroy();return;}
        sprite=GetSpriteIndex(CaelumElementalVFXData.SpriteName(Kind));
        frame=Min(3,Age/CaelumElementalVFXData.FRAME_TICS);
        Alpha=1.0-double(Age)/CaelumElementalVFXData.IMPACT_TICS;
        Scale*=1.035;
        if(Age==0)CaelumElementalVFX.Light(self,Kind);
        Age++;
    }
    Default { +NOINTERACTION +NOGRAVITY +BRIGHT RenderStyle "Add"; }
    States { Spawn: TNT1 A -1; Stop; }
}
